// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Reduces the buggyness of "Land_i_Shed_Ind_F" doors opened by AI
// Author: Renz
// To use: Called inside fn_doorZombie.sqf
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //

params ["_structure","_door"];
if (typeOf _structure == "Land_i_Shed_Ind_F") then {
	/*if (true) then {
		if (_door == 4) exitWith {_door = 6};
		if (_door == 3) exitWith {_door = 2};
		if (_door == 2) exitWith {_door = 4};
		if (_door == 1) exitWith {_door = 3};
	};*/
	
	_door = [3,4,2,6] select (_door - 1);
	
	private _doorMan = [_structure, _door] call renz_fnc_getDoorMan;//Get door man
	
	if (!isPlayer _doorMan) then {
		_structure animateSource [format ["Door_%1_sound_source", _door], _target];
		_structure animateSource [format ["Door_%1_noSound_source", _door], _target];
		if (_doorMan getVariable ["renz_isZombie", false] ) then {//Door man is zombie
			[_doorMan, ["doorBreak",40]] remoteExec ["say3D"];
			[_doorMan, 0] remoteExecCall ["renz_fnc_switchMove"];
		};
	};
	
};