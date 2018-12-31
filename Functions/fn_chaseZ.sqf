// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Allows a zombie chase targets and parkour over walls
// Author: Renz, 2016
// // // // // // // // // // // // // // // // // // // // // // // // // // // // ////

params["_unit"];


_targetFinder = (_unit getVariable "renz_targetFinder");
_target = _targetFinder findNearestEnemy _unit; 

if (isNull _target) exitWith {	
if (		isNull(_unit getVariable ["renz_idleMode", scriptNull])		) then {
private _idle = _unit spawn {
sleep random 3;
if (_this getVariable "renz_cycleNo" != 0) then {
private _pos = getPosATL _this;
_pos = [(_pos select 0) + (random [-25,0,25]), (_pos select 1) + (random [-25,0,25]), 0];
_this forceWalk true;
_this moveTo _pos;
waitUntil {_this distance _pos < 2};
};
_this disableAI "ANIM";
[_this, 2] remoteExecCall ["renz_fnc_switchMove"];
sleep 180 + random 120;
};

_unit setVariable ["renz_idleMode", _idle];
};

sleep 2.0;
};


_cycleNo = (_unit getVariable "renz_cycleNo");
_unit setVariable ["renz_cycleNo", [_cycleNo + 1, 0] select (_cycleNo >= 4)];

_idleScript = _unit getVariable ["renz_idleMode", scriptNull];
if (!isNull _idleScript) then {
terminate _idleScript;
_unit forceWalk false;
_unit enableAI "ANIM";
};

_unit setVariable ["renz_target", _target];

_obstructions = 0;
_structureList = [];
_distance = _unit distance _target;

if (_distance < 30) then {
_structureList = lineIntersectsSurfaces[eyePos _target, eyePos _unit, _target, _unit, true, 1, "GEOM", "NONE"];
_obstructions = {!((_x select 2) isKindOf "man")} count _structureList;


if (_distance < 5) then {
private _targetVehicle = vehicle _target;
private _onFoot = _targetVehicle iskindof "man";
private _reach = 2;


if (_obstructions == 0) then {
private _hitTrue = true;

if (!_onFoot) then {
_reach = 5;

if ({alive _x} count crew _targetVehicle == 0) then {
private _civ = createAgent ["C_scientist_F", [0,0,0],[],0,"CAN_COLLIDE"];
_civ hideObjectGlobal true;
_civ disableAI "ALL";
_civ moveInDriver _targetVehicle;
group _targetFinder reveal [_civ, 4];
deleteVehicle _civ;	
_hitTrue = false;
} else {

if (abs speed _targetVehicle >= 3) then {
private _carList = lineIntersectsSurfaces[eyePos _unit, eyePos _target, _unit, objNull, true, 1, "GEOM", "NONE"]; 

if (count _carList != 0) then {
private _carInfo = (_carList select 0);
if (	(_carInfo select 2) == _targetVehicle) then {
private _surfaceATL = ASLtoATL (_carInfo select 0);


if (_unit distance _surfaceATL <= 2.5) then {

private _holdDir = (	(_unit getDir _targetVehicle) - getDir _targetVehicle	);
private _holdPos = (		[(_targetVehicle worldToModel _surfaceATL), _holdDir, -0.3] call renz_fnc_translatePos	) vectorAdd [0,0,-0.2];


_unit attachTo [_targetVehicle, _targetVehicle worldToModel getPosATL _unit];
_unit setDir _holdDir;
[_unit, 7] remoteExecCall ["renz_fnc_switchMove"];
waitUntil {animationState _unit != "AmovPercMstpSnonWnonDnon_AcrgPknlMstpSnonWnonDnon_getInLow"};


_unit attachTo [_targetVehicle, _holdPos];
_unit setDir _holdDir;
[_unit, 6] remoteExecCall ["renz_fnc_switchMove"];
playSound3D [renz_SoundPath + "metalPunch_1.ogg", _gate, false ,_surfaceATL, 3];

[_targetVehicle, getMass _targetVehicle + 5000] remoteExecCall ["setMass", owner _targetVehicle];
private _abs = abs speed _targetVehicle;
private _breakSpeed = 40;
private _canGrab = true;
private _cycle = 0;


while {_canGrab} do {

sleep 1;
private _rdm = random 2;
private _soundTimer = (_unit getVariable "renz_soundTimer") + _rdm;
if (_rdm > 1.7) then {
playSound3D [renz_SoundPath + "MetalBang_2.ogg", _targetVehicle, false, getPosASL _targetVehicle, 0.4];
_targetVehicle setHitPointDamage ["hitHull",( _targetVehicle getHitPointDamage "hitHull") + 0.01];
};

if (_soundTimer >= 15) then {
_groan = format ["%1_groan%2", _unit getVariable "renz_soundSet", ceil random 5];
[_unit, [_groan,50]] remoteExec ["say3D"];
_unit setVariable ["renz_soundTimer", 0];

} else {
_unit setVariable ["renz_soundTimer", _soundTimer ];
};

_abs = abs speed _targetVehicle;
_cycle = [_cycle + 1, 0] select (_cycle == 4);

if (animationState _unit != "apctracked2_slot1_out" || {alive _x} count crew _targetVehicle == 0 || !alive _unit || _cycle == 4 && _abs < 3 || _abs > _breakSpeed && (random 1) > 0.8) then {
_canGrab = false;
};

};


detach _unit;
if (_abs > _breakSpeed) then {	 playSound3D [renz_SoundPath + "boneBreak.ogg", _unit, false, getPosASL _unit, 1]	};
[_targetVehicle, getMass _targetVehicle - 5000] remoteExecCall ["setMass", owner _targetVehicle];
private _pos = [getPosATL _unit, getDir _unit, -1] call renz_fnc_translatePos;
_pos = [(_pos select 0), (_pos select 1), (_pos select 2) -1.2];
[_unit, 5] remoteExecCall ["renz_fnc_switchMove"]; 
_unit setPosATL _pos;
_unit setDir (_holdDir + 180);
sleep 2;
};	
};

};

} else {
_hitTrue = false;
};

};


};


if (_distance <= _reach && _hitTrue ) then {
_unit setDir (_unit getDir _target);
[_unit, 0] remoteExecCall ["renz_fnc_switchMove"];
[_unit, _targetVehicle, _onFoot, _reach] remoteExec ["renz_fnc_hitEffects", _target];
[_unit, format["%1_attack%2", _unit getVariable "renz_soundSet", ceil random 2]] remoteExec ["say3D"];
_unit moveTo getPosATL _target;
sleep 1.6 + (random 1);

};

};

};

};


_soundTimer = (_unit getVariable "renz_soundTimer") + (random 1 + 0.5);
if (_soundTimer >= 15) then {
_unit setVariable ["renz_soundTimer", 0];
private _groan = format ["%1_groan%2", _unit getVariable "renz_soundSet", ceil random 5];
[_unit, [_groan,50]] remoteExec ["say3D"];
} else {
_unit setVariable ["renz_soundTimer", _soundTimer ];
};


_moveToPos = getPosATL _target;

if ((_moveToPos select 2) < 0.1) then {
private _velocity = velocity _target;
_moveToPos = [(_moveToPos select 0) + (_velocity select 0), (_moveToPos select 1) + (_velocity select 1), 0]; ;
};


if (_obstructions == 0) then {
_unit moveTo _moveToPos;
} else {
private _structureInfo = (_structureList select 0);
private _structure = _structureInfo select 2;
private _parkourType = 0;
private _surfaceATL = ASLtoATL (_structureInfo select 0);
private _parkour = true;
private "_doorNames";




if (		([ (getModelInfo _structure) select 1, ""] select (isNull _structure)) find "\walls\" != -1	) then {
_doorNames = animationNames _structure; 
private _isGate = (count _doorNames > 0);

if (_isGate) then {
private _gate = _structure;
private _isClosed = ({_gate animationPhase _x > 0.1} count _doorNames) == 0;

if (_isClosed) then {
if (_target distance _surfaceATL < 10) then {
_parkourType = 1;

} else {
_parkourType = 2;

};
} else {
_parkour = false;
};

} else {
_parkourType = 3;
};
} else {
_parkour = false;
};





if (_parkourType > 1) then {
if (	  (_structure modelToWorld ((boundingBoxReal _structure) select 1)) select 2 > 3	) then {
_parkour = false;
} else {
if (typeOf _structure == "Land_InvisibleBarrier_F") then {
_parkour = false;
}; 
}

};




if (_parkour) then {
private _ledgeWidthEstimate = abs (	((_structure worldToModel _surfaceATL) select 1)*2		);
private _modelDir = (getDir _structure) + ([0,180] select (	(  (_structure worldToModel getPosWorld _unit) select 1  ) > 0	));
private _yOffset = -(_ledgeWidthEstimate + 0.88531) - 1;
private _readyPos = [(_surfaceATL select 0) + (sin(_modelDir) * _yOffset), (_surfaceATL select 1) + (sin(180 - (90 + _modelDir)) * _yOffset), 0];

if (_unit distance _readyPos < 2) then {
if (_parkourType == 1) then {


private _gate = _structure;
_gateDmg = damage _gate;
_gate setDamage (_gateDmg + 0.01);
_unit setDir (_unit getDir _gate);
[_unit, 0] remoteExecCall ["renz_fnc_switchMove"];

{_gate animate [_x, 0.05]} forEach _doorNames;
[_gate, _surfaceATL, 0] remoteExec ["renz_fnc_particleSource"];
sleep 0.05;

if ( {_gate animationPhase _x > 0.1} count _doorNames == 0 ) then {
{_gate animate [_x, 0]} forEach _doorNames;
};

sleep 0.4 + random 0.3;


} else {



_ledgeHieght =  (_structure modelToWorld ((boundingBoxReal _structure) select 1)) select 2;
private _animSpeed = getAnimSpeedCoef _unit;
private _yOffset = (-1.48531) - _ledgeWidthEstimate;
private _zOffset = (_ledgeHieght - 1.32201) - 0.3;
private _offsetStart = [(_surfaceATL select 0) + (sin(_modelDir) * _yOffset), (_surfaceATL select 1) + (sin(180 - (90 + _modelDir)) * _yOffset), _zOffset];
private _noFallDamage = _unit addEventHandler["HandleDamage",{	if ( (_this select 4) == "") then {0}	}];


_unit setDir _modelDir;
_unit disableAI "ANIM";
_unit setAnimSpeedCoef 1;
_unit setPos [_offsetStart select 0, _offsetStart select 1, 0];
[_unit, 3] remoteExec ["renz_fnc_switchMove"];
sleep 0.4;



private _stool =  createSimpleObject ["a3\structures_f_epa\walls\invisiblebarrier_f.p3d", [0,0,0]];
_stool setPos _offsetStart; 
_stool setDir _modelDir;
_unit setPos _offsetStart;
sleep 0.75;


deleteVehicle _stool;
if (alive _unit) then {
private _xOffset = 0.430111;
private _yOffset = 1.29791;

private _offsetEnd = [(_surfaceATL select 0) + (sin(_modelDir) * _Yoffset), (_surfaceATL select 1) + (sin(180 - (90 + _modelDir)) * _Yoffset)];
_modelDir = _modelDir + 90;
_offsetEnd = [(_offsetEnd select 0) + (sin(_modelDir) * _Xoffset), (_offsetEnd select 1) + (sin(180 - (90 + _modelDir)) * _Xoffset)];

_unit setposATL [_offsetEnd select 0, _offsetEnd select 1, _zOffset];
_unit disableCollisionWith _structure;
_unit setAnimSpeedCoef 0.6;
[_unit, 4] remoteExecCall ["renz_fnc_switchMove"];
_unit disableAI "MOVE";
_unit enableAI "ANIM";
sleep 1.2;

_unit enableAI "MOVE";
_unit setAnimSpeedCoef _animSpeed;
_unit removeEventHandler ["HandleDamage",_noFallDamage]; 
[_unit, _structure] spawn {sleep 4; (_this select 0) enableCollisionWith (_this select 1)};
};

};
} else {
_unit moveTo _readyPos;
};

} else {
_unit moveTo _moveToPos;
};


};
