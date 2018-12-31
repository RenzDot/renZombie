// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Makes zombie hit doors open
// Author: Renz
// To use: Requires "allowFunctionsRecompile = 1;" in description. This runs automatically everytime a door is opened, as it recompiles BIS_fnc_Door
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //

BIS_fnc_Door = {
	private _fnc_scriptNameParent = if (isNil "_fnc_scriptName") then {"BIS_fnc_Door"} else {_fnc_scriptName};
	private _fnc_scriptName = "BIS_fnc_Door";
	scriptName _fnc_scriptName;

	private
	[
		"_structure",
		"_door",
		"_target"
	];

	_structure = param [0, objNull, [objNull]];
	_door = param [1, 0, [0]];
	_target = param [2, 0, [0]];
	
	if (!(isNull (_structure))) then {	
		if ((_structure getVariable [format ["bis_disabled_Door_%1", _door], 0]) != 1) then {
			private _soundDoor = format ["Door_%1_sound_source", _door];
			private _noSoundDoor = format ["Door_%1_noSound_source", _door];
			
			if (_target != 0) then {//Door open event		
				if (		(_structure animationSourcePhase _soundDoor) < 0.1 ) then {
					private _doorMan = [_structure, _door] call renz_fnc_getDoorMan;//Get door man
					_structure animateSource [_soundDoor, 0.1, true];
					
					if (!isNull _doorMan && {_doorMan getVariable ["renz_isZombie", false]} ) then {//Door man is zombie
							[_doorMan, 0] remoteExecCall ["renz_fnc_switchMove"];
							[_doorMan, ["doorBreak",40]] remoteExec ["say3D"];
							_structure animateSource [_soundDoor, _target];
							_structure animateSource [_noSoundDoor, _target];
						
					} else {//Normal door open
						_structure animateSource [_soundDoor, _target];
						_structure animateSource [_noSoundDoor, _target];
						
						//Reduce buggyness of "Land_i_Shed_Ind_F"
						[_structure, _door] call renz_fnc_shedDoorFix;
					};
				};
				
				
			} else {//Normal door close
				_structure animateSource [_soundDoor, _target];
				_structure animateSource [_noSoundDoor, _target];
			};
		
		
		
		
		
		
		} else {//Door is locked
			_structure animateSource [format ["Door_%1_locked_source", _door], (1 - (_structure animationSourcePhase (format ["Door_%1_locked_source", _door])))];
		};
	};
	
}; 