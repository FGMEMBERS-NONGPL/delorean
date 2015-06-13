var speed = 0;
var fuel_lev = 0;
var fuel = props.globals.getNode("consumables/fuel/tank/level-norm");
var running = props.globals.getNode("/engines/engine/running");
var gear = props.globals.getNode("/engines/engine/gear");
var clutch = props.globals.getNode("/engines/engine/clutch");
var rpm = props.globals.getNode("/engines/engine/rpm");
var throttle = props.globals.getNode("/engines/engine/throttle");
var rev_throttle = props.globals.getNode("/engines/engine/rev_throttle");
var elevator = props.globals.getNode("/controls/flight/elevator");
var leftdoor = props.globals.getNode("/controls/door-left");
var rightdoor = props.globals.getNode("/controls/door-right");
var oiltempf = props.globals.getNode("/engines/engine/oil-temperature-degf");
var oilpressure = props.globals.getNode("/engines/engine/oil-pressure-psi");
var keyturn = props.globals.getNode("/controls/keyturn");
var live = props.globals.getNode("/controls/live");
var voltage = props.globals.getNode("/controls/voltage");
var startup = props.globals.getNode("/engines/engine/startup");
var k = 0;
var turn_sec = 0;
var gear_prev = 0;
var mbrake = 0;
var tbrake = 0;
var ef = 0;
var cl = 0;
var rdd = 0; ##right door desired position
var ldd = 0; ##left door desired position
var db = 0;
var delta = 0;
var outdoor_f = 0;
var oiltemp_f = 0;
var oildelta = 0;
var oiltempind = 0;
var turnmark = 0;

var loop = func {

   if (oiltempf.getValue() < getprop("/environment/temperature-degf")) {
	oiltempf.setValue(getprop("/environment/temperature-degf"));
   }
   
   

	##1 kt = 15 wheel rpm
	##gear ratios 	3.36:1, 2.06:1, 1.38:1, 1.06:1, 0.82:1
	##rev gear 3.44:1
	
	if (gear_prev != gear.getValue()) {
	 if (clutch.getValue() == 1) {
	  gear_prev = gear.getValue();
	  gui.popupTip(sprintf("Gear: %d", gear_prev));
	 } else 
	 {gear.setValue(gear_prev);
	  setprop("/controls/gearchange", 1);
	  setprop("/controls/gearchange", 0);
	  }
	}




      if (elevator.getValue() < 0) {elevator.setValue(0);}
      speed = getprop("velocities/groundspeed-kt");

     if ((gear.getValue() == 0) or (clutch.getValue() == 1)) {
	 k = 0;
	 if (running.getValue() == 1) {rpm.setValue(600+5400*elevator.getValue())} else {rpm.setValue(0)};
      }
	else if (gear.getValue() == 1) {
	 ##k = 50.4;
	 k = 100;
	 rpm.setValue(k*(speed));
	 if ((rpm.getValue() < 1500) and (running.getValue() == 1)) {
	  rpm.setValue(3000*elevator.getValue());
	 }
    }
	else if (gear.getValue() == 2) {
       ##k =  30.9;
	  k = 60;
	 rpm.setValue(k*speed);
	}
      else if (gear.getValue() == 3) {
	 ##k = 20.7;
	 k = 45;
	 rpm.setValue(k*speed);
	}
	  else if (gear.getValue() == 4) {
	 ##k = 15.9;
	 k = 30;
	 rpm.setValue(k*speed);
	}
	  else if (gear.getValue() == 5) {
	 ##k = 12.3;
	 k = 25;
	 rpm.setValue(k*speed);
	}
	

	
	if ((gear.getValue() > 0) and (rpm.getValue() < 800) and (clutch.getValue() == 0)) {
	 running.setValue(0);
	}
	
	if ((running.getValue() == 1) and ((gear.getValue() > 0) and  (clutch.getValue() == 0))) { 
	 ef = 1-abs(rpm.getValue()-3000)/3000;
	 if (ef < 0) {ef = 0};
	 throttle.setValue((0.9*elevator.getValue()+0.1)*ef);
	} else throttle.setValue(0);

	##Startup
	if (keyturn.getValue() == 1) {
	 if (live.getValue() == 0) {
	  live.setValue(1);
	  voltage.setValue(12);
	 }
	 startup.setValue(0);
	}
	if ((keyturn.getValue() == 2) and (running.getValue() == 0)) {
	 if (voltage.getValue() > 10) {
	  if ((gear.getValue() == 0) or (clutch.getValue() == 1)) {
	   startup.setValue(1);
	  }
	 }
	}
	
	
	if ((running.getValue() == 1) and (rpm.getValue() != 0)) {
	 setprop("engines/engine/smoke", rpm.getValue()/600);
	}
	
	if (startup.getValue() == 1) {
	 if ((fuel.getValue() > 0.00001) and (oiltempf.getValue() < 240)) {
	  running.setValue(1);
	  startup.setValue(0);
	  keyturn.setValue(1);
	  setprop("/engines/engine/smoke", 6);
	 }
	}
	
	if (keyturn.getValue() == 0) {
	 running.setValue(0);
	 live.setValue(0);
	 voltage.setValue(0);
	}
	
	

	if (running.getValue() == 1) {
	 if (fuel.getValue() < 0.00001) {
	  running.setValue(0);
	  }
	 else {
	  fuel_lev = fuel.getValue();
	  fuel.setValue(fuel_lev - (0.9*elevator.getValue()+0.1)*0.00001);
	 }
	}

	if (running.getValue() == 1) {
	 if ((gear.getValue() == -1) and (clutch.getValue() == 0)) {
	  rpm.setValue(125*speed);
	  if (rpm.getValue() < 1500) {rpm.setValue(3000*elevator.getValue());}
	  ef = 1-abs(rpm.getValue()-3000)/3000;
	  if (ef < 0) {ef = 0};
	  rev_throttle.setValue((0.9*elevator.getValue()+0.1)*ef);
	 } else rev_throttle.setValue(0);
	} else rev_throttle.setValue(0);
	
	
	if ((running.getValue() == 0) and (rpm.getValue() > 1000)) {
	 if ((clutch.getValue() == 0) and (gear.getValue() != 0)) {
	  if (live.getValue() == 1) {running.setValue(1);}
	 }
	}
		
	


	turn_sec = turn_sec + 0.1;

	if ((turn_sec > 0.5) and ((getprop("controls/lighting/alarm") == 1) or (getprop("controls/lighting/turn") == -1))) {
	 setprop("controls/lighting/left_turn", 1)}
	else {setprop("controls/lighting/left_turn", 0)};

	if ((turn_sec > 0.5) and ((getprop("controls/lighting/alarm") == 1) or (getprop("controls/lighting/turn") == 1))) {
	 setprop("controls/lighting/right_turn", 1)}
	else {setprop("controls/lighting/right_turn", 0)};
	
	if (turn_sec > 1) {turn_sec = 0};
	
	if ((turnmark == 1) and (abs(getprop("controls/flight/aileron")) < 0.1)) {
	 setprop("/controls/lighting/turn", 0);
	 turnmark = 0;
	}
	
	if ((getprop("controls/flight/aileron") > 0.4) and (getprop("controls/lighting/turn") != 0)) {
	 turnmark = 1;
	}

	if ((getprop("/devices/status/keyboard/event/key") == 104) and (getprop("/devices/status/keyboard/event/pressed") == 1)) {
	 setprop("/controls/horn/horn", 1);
	} else {setprop ("/controls/horn/horn", 0)}

	mbrake = rpm.getValue()/6000-(0.9*elevator.getValue()+0.1)*running.getValue();
	if (mbrake < 0) {mbrake = 0;}
	##tbrake =  getprop("/controls/gear/brake-right");
	if ((gear.getValue() != 0) and (clutch.getValue() == 0)) {
	 if (running.getValue() == 1) {setprop("/controls/gear/engine-brake", mbrake);}
	 else setprop("/controls/gear/engine-brake", 0.5/gear.getValue());
	}
	##else {setprop("/controls/gear/brake-left", tbrake)};
	

	if (getprop("/controls/dlchange") == 1) {
	 if (leftdoor.getValue() != ldd) {
	  db = leftdoor.getValue();
	  if (ldd == 0) {
	   db = db - 1;
	   leftdoor.setValue(db);
	  } else {
	   db = db + 1;
	   leftdoor.setValue(db);
	  }
	  if (leftdoor.getValue() == ldd) {
	   setprop("/controls/dlchange", 0);
	  }
	 } else {
	  if (leftdoor.getValue() == 10) {ldd = 0;}
	  else ldd = 10;
	 }
	}
	
	if (getprop("/controls/drchange") == 1) {
	 if (rightdoor.getValue() != rdd) {
	  db = rightdoor.getValue();
	  if (rdd == 0) {
	   db = db - 1;
	   rightdoor.setValue(db);
	  } else {
	   db = db + 1;
	   rightdoor.setValue(db);
	  }
	  if (rightdoor.getValue() == rdd) {
	   setprop("/controls/drchange", 0);
	  }
	 } else {
	  if (rightdoor.getValue() == 10) {rdd = 0;}
	  else rdd = 10;
	 }
	}
	
	if (gear.getValue() == 1) {
	 setprop("/controls/gearstick-x", -30);
	 setprop("/controls/gearstick-y", 30);
	}
    if (gear.getValue() == 2) {
	 setprop("/controls/gearstick-x", -30);
	 setprop("/controls/gearstick-y", -30);
	}
	if (gear.getValue() == 3) {
	 setprop("/controls/gearstick-x", 0);
	 setprop("/controls/gearstick-y", 30);
	}
	if (gear.getValue() == 4) {
	 setprop("/controls/gearstick-x", 0);
	 setprop("/controls/gearstick-y", -30);
	}
	if (gear.getValue() == 5) {
	 setprop("/controls/gearstick-x", 30);
	 setprop("/controls/gearstick-y", 30);
	}
	if (gear.getValue() == -1) {
	 setprop("/controls/gearstick-x", 30);
	 setprop("/controls/gearstick-y", -30);
	}
	if (gear.getValue() == 0) {
	 setprop("/controls/gearstick-x", 0);
	 setprop("/controls/gearstick-y", 0);
	}
	
	
	##Temp
	outdoortemp_f = getprop("/environment/temperature-degf");
	if (running.getValue() == 1) {
	 oiltemp_f = oiltempf.getValue();
	 if (oiltemp_f < 150) {oiltemp_f = oiltemp_f + 5*rpm.getValue()/6000;} else oiltemp_f = oiltemp_f + 1*rpm.getValue()/6000;
	}
	delta = oiltemp_f - outdoortemp_f;
	oiltemp_f = oiltemp_f - delta*(0.9*getprop("velocities/airspeed-kt")/150+0.1)*0.01;
	oiltempf.setValue(oiltemp_f);
	
	if ((rpm.getValue() > 2000) and (oiltemp_f < 40)) {running.setValue(0);}
	if ((running.getValue() == 1) and (oiltemp_f > 260)) {
	 running.setValue(0);
	 setprop("engines/engine/reheat-smoke", 1);
	}
	if (oiltemp_f < 240) {setprop("engines/engine/reheat-smoke", 0);}
	
	if (live.getValue() == 1) {
	 if (oiltemp_f < 100) {setprop("/engines/engine/oiltemp-ind", 0);}
	 elsif (oiltemp_f < 220) {
   	  oiltempind = (oiltemp_f - 100)/240;
	  setprop("/engines/engine/oiltemp-ind", oiltempind);
	 } elsif (oiltemp_f < 260) {
	  oiltempind = (oiltemp_f - 220)/80 + 0.5;
	  setprop("/engines/engine/oiltemp-ind", oiltempind);
	 } else 
	  setprop("/engines/engine/oiltemp-ind", 1);
	}
	else  setprop("/engines/engine/oiltemp-ind", 0);
	
	if (running.getValue() == 1) {
	 if (rpm.getValue() < 1000) {oilpressure.setValue(50);}
	 elsif (rpm.getValue() < 3000) {oilpressure.setValue((30*rpm.getValue()-1000)/2000+50);}
	 else oilpressure.setValue(80);
	} else oilpressure.setValue(0);

	
	settimer (loop, 0.1, 1);
}

loop();




   
