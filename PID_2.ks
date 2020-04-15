set pGainT to 1.
set iGainT to 0.
set dGainT to 0.

set pGainA to 3.
set iGainA to 0.
set dGainA to 0.

set pOutT to 0.
set iOutT to 0.
set dOutT to 0.

set pOutA to 0.
set iOutA to 0.
set dOutA to 0.

set rT to 0.
set eT to 0.
set uT to 0.
set yT to 0.

set rA to 0.
set eA to 0.
set uA to 0.
set yA to 0.

set iSumT to 0.
set iSumA to 0.
set derT to 0.
set derA to 0.

set dTime to 0.
set prevTime to 0.
set prevET to 0.
set prevEA to 0.
set newTick to false.

// Throttle target :
set thr to 0.
set axisx to R(0,0,0).
lock throttle to thr.
//lock steering to axisX.
set throtTarget to 1.
set output to 0.
set oldSpeed to 0.

// Throttle Input Gains :
set thrustGain to 0.1.
set apoGain to 0.00001.
set qGain to 1.8.
set accGain to 0.3.
set targetApo to 100000.

// Axis Target :
set reference to ship:facing.
set targetYaw to 0.
set turnRate to 0.01.

// Sets up the GUI button
{
local gui is gui(250).
set gui:x to 500.
set gui:y to 180.
local label is gui:addlabel("Stop Controller").
set label:style:align to "center".
set label:style:hstretch to true.
local ok to gui:addbutton("Stop").
gui:show().
set ok:onclick to Click@.
set stop to false.
}

function click {
   set stop to true.
   clearguis().
}

function controlThrottle {
   parameter target, input.
   getTime().
   
   // Throttle PID :
   set eT to errorOut(target, input).
   
   set pOutT to proportionOut(eT, pGainT).
   
   set iOutT to integralOut(iSumT, eT, dTime, iGainT).
   
   set dOutT to derivativeOut(prevET, eT, dTime, dGainT).
   
   set uT to sumOut(pOutT, iOutT, dOutT).
}

function controlAxis {
   parameter target, input.
   // Axis PID :
   set eA to errorOut(target, input).
   
   set pOutA to proportionOut(eA, pGainA).
   
   set iOutA to integralOut(iSumA, eA, dTime, iGainA).
   
   set dOutA to derivativeOut(prevEA, eA, dTime, dGainA).
   
   set uA to sumOut(pOutA, iOutA, dOutA).
}

// function setHeading {
   // parameter x, y.
   // set HEADING(x, y).
// }

function getTime {
   set sampleTime to time:seconds.
   if prevTime < sampleTime {
      set dTime to sampleTime - prevTime.
      set newTick to true.
      // IDK if this is a good idea...
      wait 0.
      
      set prevTime to sampleTime.
      set prevET to eT.
      set prevEA to eA.
   } else {
      set newTick to false.
   }
}

function error {
   set eT to rT - yT.
}

function errorOut {
   parameter r, y.
   return r - y.
}

function proportion {
   set pOutT to e * pGain.
}

function proportionOut {
   parameter e, pGain.
   return e * pGain.
}

function integral {
   // Need to implement lock or filter??
   set iSum to (iSum + e) * dTime.
   set iOut to (iOut + iSum) * iGain.
}

function integralOut {
   // Need to implement lock or filter??
   parameter iSum, e, dTime, iGain.
   return ((iSum + e) * dTime) * iGain.
}

function derivative {
   // Need to implement low-pass filtering.
   if newTick = true {
      set der to (prevE - e) / dTime.
      set dOut to der * dGain.
   }
}

function derivativeOut {
   // Need to implement low-pass filtering.
   parameter prevE, e, dTime, dGain.
   if newTick = true {
      return ((prevE - e) / dTime) * dGain.
   }
}

function sum {
   set u to pOut + iOut + dOut.
}

function sumOut {
   parameter pOut, iOut, dOut.
   return pOut + iOut + dOut.
}

function calcInput {
   set adjTrhust to SHIP:AVAILABLETHRUST * thrustGain.
   set speed to verticalspeed + groundspeed.
   set acc to (speed - oldSpeed) * accGain.
   set output to (acc * adjTrhust) * 0.1.
   wait 0.
   set oldSpeed to speed.
   return output * (ship:Q * qGain).
   //return acc.
}

function calcThrottleInput {
   set adjTrhust to SHIP:AVAILABLETHRUST * thrustGain.
   set speed to verticalspeed + groundspeed.
   set acc to (speed - oldSpeed) * accGain.
   set output to (acc * adjTrhust) * 0.1.
   wait 0.
   set oldSpeed to speed.
   return output * (ship:Q * qGain).
   //return acc.
}

function calcAxisInput {
   set yA to ship:facing - reference.
   //simpleGravTurn().
   return yA.
}

function simpleGravTurn {
   if newTick = true {
      set targetYaw to targetYaw - turnRate.
   }
}

function adjustThrottleApoapsis {
   if APOAPSIS < targetApo {
      return (APOAPSIS^1.8 - targetApo) * apoGain * 0.0001.
   } else {
      return 1.
   }
}

function printData {
   clearscreen.
   print("input:") at(0,0).
   print(feedbackT) at(15,0).
   print("thr Control:") at(0,1).
   print(uT) at(15,1).
   print("Apoapsis:")at(0,2).
   print(APOAPSIS)at(15,2).
   
   print("Axs fac-Ref:")at(0,4).
   print(ship:facing - reference)at(15,4).
   print("Axs Ref")at(0,5).
   print(reference)at(15,5).
   print("Axs Control:")at(0,6).
   print(uA)at(15,6).
   
   print("PT Out:")at(0,8).
   print(pOutT)at(15,8).
   print("IT Out:")at(0,9).
   print(iOutT)at(15,9).
   print("DT Out:")at(0,10).
   print(dOutT)at(15,10).
   
   print("PA Out:")at(0,12).
   print(pOutA)at(15,12).
   print("IT Out:")at(0,13).
   print(iOutA)at(15,13).
   print("DT Out:")at(0,14).
   print(dOutA)at(15,14).
   
   print("prev eT")at(0,16).
   print(prevET)at(15,16).
   print("prev eA")at(0,17).
   print(prevEA)at(15,17).
}

function main {
   until stop = true {
      // calcs the input.
      //set feedback to calcThrottleInput().
      set feedbackT to calcThrottleInput() + adjustThrottleApoapsis().
      set feedbackA to calcAxisInput().
      
      // runs the PID loop.
      controlThrottle(throtTarget, feedbackT).
      controlAxis(targetYaw, feedbackA:yaw).
      // sets the controlled value (in this case the throttle).
      set thr to uT.
      lock steering to R(0, uA, 90).
      //setHeading(90, uA).
      printData().
   }
}

main().

set ship:control:PILOTMAINTHROTTLE to 0.
set throttle to ship:control:PILOTMAINTHROTTLE.
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.