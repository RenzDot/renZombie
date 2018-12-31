// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Handles respawn of zombies
// Author: Renz, 2016
// // // // // // // // // // // // // // // // // // // // // // // // // // // // ////

waituntil {time > 0};





renz_agentList = [];
while {count renz_spawnQueue != 0} do {
{	_convertUnit = _x spawn {
params ["_unit" , ["_speed", "fast", [""]]];
_grp = group _unit; 
_grp enableAttack false;
_grp setCombatMode "BLUE";  


if (side _unit == civilian) then {
_indGroup = createGroup independent;
_indGroup copyWaypoints _grp;
units _grp joinSilent _indGroup;


_grp = _indGroup;
};

_agentType = [side _unit] call {
params ["_side"];
if (_side == independent) exitWith {"I_Survivor_F"};
if (_side == west) exitWith {"B_Survivor_F"};
"O_Survivor_F"
};

_unit setSkill 1;
_unit allowFleeing 0;
_unit allowDamage false;
[_unit, "NoVoice"] remoteExecCall ["setSpeaker", 0];

removegoggles _unit;
_unit disableAI "ALL";
_unit setCaptive true;
_unit enableAI "TEAMSWITCH";
_unit enableAI "CHECKVISIBLE";
_unit setBehaviour "CARELESS";


_pos = getPosATL _unit;
_objName = vehicleVarName _unit;
_createAgent = compile format["%1 = createAgent ['%2', %3, [], 0, 'CAN_COLLIDE']; %1 setVehicleVarName '%1'; %1", [_objName, "_agent"] select (_objName == ""), _agentType, _pos];
_agent = call _createAgent;
_agent hideObjectGlobal true;

removeGoggles _agent;
removeUniform _agent;

_agent forceAddUniform uniform _unit;
{_agent  addItemToUniform _x} forEach uniformItems _unit;

_agent addVest vest _unit;
{_agent addItemToVest _x} forEach vestItems _unit;

_agent addBackpack backpack _unit;
{_agent addItemToBackpack _x } forEach backpackItems _unit;

_agent addHeadgear headgear _unit;
_agent addGoggles goggles _unit;

{_agent linkItem _x} forEach assignedItems _unit;

removeAllWeapons _unit;
_agent disableAI "ALL";
_agent enableAI "PATH";
_agent enableAI "MOVE";
_agent enableAI "ANIM";
_agent enableAI "TEAMSWITCH";
_agent setBehaviour "CARELESS";

_agent forceSpeed -1;
_agent allowFleeing 0;
_agent setunitpos "up";
_agent enableStamina false;
_agent sethit ["body", 0.5];
_agent sethit ["head", 0.8];
_agent hideObjectGlobal false;
_agent disableCollisionWith _unit;
[_agent, "dead"] remoteExec ["setMimic"];
[_agent, "NoVoice"] remoteExec ["setSpeaker", 0, true];
_agent forceWalk ( [true, false] select (_speed == "fast")	);
_agent setAnimSpeedCoef ( [0.8, renz_animSpeed] select (_speed == "fast")	);

_agent setVariable ["renz_cycleNo", 0];  
_agent setVariable ["renz_isZombie", true];
_agent setVariable ["renz_target", objNull];
_agent setVariable ["renz_targetFinder", _unit];
_agent setVariable ["renz_soundTimer", floor (random 15)];
_agent setVariable ["renz_soundSet", selectRandom ["A","B","C"] ];  

_agent addEventHandler ["KILLED", {
params ["_agent"]; 
deleteVehicle (_agent getVariable "renz_targetFinder");
playSound3D [renz_SoundPath + format["Death_%1.ogg", ceil random 5], _agent, false ,getPosATL _agent vectorAdd [0,0,1.8], 1.5];

}];

_unit hideObjectGlobal true;
_unit attachTo [_agent, [0,0,0]];
_unit setVariable ["renz_zombieHost", _agent];
_unit addEventHandler ["KILLED", {
params ["_unit"]; 
(_unit getVariable "renz_zombieHost") setDamage 1; 
deleteVehicle _unit;
}];

if (random 1 > 0.5) then {
_agent addEventHandler ["AnimChanged", {
params ["_agent", "_anim"];
if (_anim == "ApanPknlMwlkSnonWnonDf") exitWith {	_agent playMove "ApanPercMwlkSnonWnonDf"	};
if (_anim == "ApanPercMsprSnonWnonDf") exitWith {	_agent playMove "ApanPknlMsprSnonWnonDf"	};
if (_anim == "ApanPercMsprSnonWnonDfl") exitWith {	_agent playMove "ApanPknlMsprSnonWnonDfl"};
if (_anim == "ApanPercMsprSnonWnonDfr") exitWith {	_agent playMove "ApanPknlMsprSnonWnonDfr"};
}];
};
































_params = _this;
_params set [0, _agent];
renz_agentList pushBack _params;
};
waitUntil {scriptDone _convertUnit};
renz_spawnQueue deleteAt _forEachIndex; 
} forEach renz_spawnQueue;
};

renz_queueActive = false;

{	_x execVM "renZombie\renZ.sqf" } forEach renz_agentList;
renz_agentList = [];
