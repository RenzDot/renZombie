// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Spawns zombies based on the player's emotional intensity
// Author: Renz, 2016
// To use: 
// Put "0 = thisTrigger execVM 'renZombie\Director\directorInit.sqf' " inside a trigger init. When the trigger's conditions are true, this script will run. 
//The trigger must be run on server only
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
params["_trigger"];

renz_zombieTrigger = _trigger;
if (!isServer) exitWith {};

if (isNil "renz_directorInit") then {
	
	renz_directorInit = true;
	renz_fnc_directorSpawn = compile preprocessFileLineNumbers "renZombie\Director\spawnZombie.sqf";
	renz_zombieTypes = ["C_man_sport_3_F","C_Man_casual_4_F","C_Man_casual_2_F","C_Nikos_aged","C_Man_casual_5_F","C_Man_casual_6_F","I_C_Soldier_Bandit_1_F","I_C_Soldier_Bandit_2_F","I_C_Soldier_Bandit_3_F","I_C_Soldier_Bandit_4_F","I_C_Soldier_Bandit_5_F","I_C_Soldier_Bandit_8_F"];
	renz_ZombieCount = 0;
	renz_isSpawning = false;
	
	renz_decayRate = -1;
	renz_minIntensity = 40;
	renz_maxIntensity = 300;
	renz_peakIntensity = 240;
};

renz_minGroup = createGroup resistance;
renz_mobGroup = createGroup resistance;
_minMan = renz_minGroup createUnit ["I_G_Survivor_F", [0,0,0], [], 0, "CAN_COLLIDE"];//Ensures minGroup is never deleted
_maxMan = renz_mobGroup createUnit ["I_G_Survivor_F", [0,0,0], [], 0, "CAN_COLLIDE"];//Ensures maxGroup is never deleted 

{
	_x disableAI "ALL";
	_x enableSimulation false;
} forEach [_minMan, _maxMan];

while {triggerActivated _trigger} do {
	_director = _trigger execVM "renZombie\Director\AIdirector.sqf"; 
	waitUntil {scriptDone _director};
};