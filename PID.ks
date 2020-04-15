set pGain to 1.
set iGain to 0.
set dGain to 0.1.

set pOut to 0.
set iOut to 0.
set dOut to 0.

set r to 0.
set e to 0.
set u to 0.
set y to 0.

set iSum to 0.
set der to 0.

set dTime to 0.
set prevTime to 0.
set prevE to 0.
set newTick to false.

// This is for the throttle target.
set thr to 0.
lock throttle to thr.
set throtTarget to 1.
set output to 0.
set oldSpeed to 0.

// Input Gains :
set thrustGain to 0.1.
set apoGain to 0.00001.
set qGain to 1.8.
set accGain to 0.2.

set targetApo to 100000.

// Sets up the GUI button 
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

function click {
   set stop to true.
   clearguis().
}

function control {
   parameter target, input.
   getTime().
   set r to target.
   set y to input.
   error().
   proportion().
   integral().
   derivative().
   sum().
}

function getTime {
   set sampleTime to time:seconds.
   if prevTime < sampleTime {
      set dTime to sampleTime - prevTime.
      set newTick to true.
      // IDK if this is a good idea...
      wait 0.
      
      set prevTime to sampleTime.
      set prevE to e.
   } else {
      set newTick to false.
   }
}

function error {
   set e to r - y.
}

function proportion {
   set pOut to e * pGain.
}

function integral {
   // Need to implement lock or filter??
   set iSum to (iSum + e) * dTime.
   set iOut to (iOut + iSum) * iGain.
}

function derivative {
   // Need to implement low-pass filtering.
   if newTick = true {
      set der to (prevE - e) / dTime.
      set dOut to der * dGain.
   }
}

function sum {
   set u to pOut + iOut + dOut.
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

function adjustApoapsis {
   if APOAPSIS < targetApo {
      return (APOAPSIS^1.8 - targetApo) * apoGain * 0.0001.
   } else {
      return 1.
   }
   
}

function printData {
   clearscreen.
   print("input:") at(0,0).
   print(feedback) at(10,0).
   print("control:") at(0,1).
   print(u) at(10,1).
   print("Apoapsis:")at(0,2).
   print(APOAPSIS)at(10,2).
   
   print("P Out:")at(0,4).
   print(pOut)at(8,4).
   print("I Out:")at(0,5).
   print(iOut)at(8,5).
   print("D Out:")at(0,6).
   print(dOut)at(8,6).
   
   print("prev e")at(0,8).
   print(prevE)at(8,8).
}

until stop = true {
   // calcs the input.
   //set feedback to calcInput().
   set feedback to calcInput() + adjustApoapsis().
   // runs the PID loop.
   control(throtTarget, feedback).
   // sets the controlled value (in this case the throttle).
   set thr to u.
   
   printData().
}

set ship:control:PILOTMAINTHROTTLE to 0.
set throttle to ship:control:PILOTMAINTHROTTLE.
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.