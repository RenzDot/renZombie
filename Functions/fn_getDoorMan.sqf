// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Returns the person who opened a door
// Author: Renz
// To use: Used inside fn_doorZombie.sqf
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //

params ["_structure", "_door"];

private _doorMan = objNull;

{		
	_pos1 = ASLtoATL eyePos _x;
	_dis = 3;
	_dir1 = getDir _x;
	
	for "_i" from -100 to 100 step 20 do {
		_dir2 = _dir1 + _i;
		_x1 = _dis*(sin _dir2);
		_y1 = _dis*(cos _dir2);
		_pos2 = [(_pos1 select 0) + _x1, (_pos1 select 1) + _y1, (_pos1 select 2)-0.6];
		
		if (	(	(	([_structure, "GEOM"] intersect [_pos1, _pos2]) select 0		) 	select 0) == format ["door_%1", _door]	) exitWith {
			_doorMan = _x;
		};
	};
	
} forEach (		(_structure modelToWorld (boundingCenter _structure))  nearEntities ((sizeOf typeOf _structure)/2)		);

_doorMan 