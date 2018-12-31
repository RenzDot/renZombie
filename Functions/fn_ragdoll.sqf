// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Author: Renz
// Description: Makes switchMove run for everyone
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
	
params ["_target","_velocity","_unit"];

_noFallDamage = _target addEventHandler["HandleDamage",{	if ( (_this select 4) == "") then {0}	}];
_physics = "Land_DustMask_F" createVehicleLocal [0,0,0];
_physics attachTo [_target, [0,0,0], "Spine3"];
_physics setMass 1e10;
_physics setVelocity _velocity;
detach _physics;
0 = [_physics, _target, _noFallDamage, _unit] spawn {
	params ["_physics", "_target", "_noFallDamage","_unit"];
	deleteVehicle _physics;
	_timeout = time + 1;
	waitUntil {animationState _target == "unconscious" OR time >= _timeOut};
	_target removeEventHandler ["HandleDamage",_noFallDamage]; 
};