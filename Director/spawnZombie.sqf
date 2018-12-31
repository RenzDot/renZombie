//By Renz
// Spawns a zombie

params["_target", "_spawnPos","_zGroup"];

_can = "Land_Can_Dented_F" createVehicleLocal _spawnPos;//Uses the objects pos to place a zombie outside of objects
_targetFinder = _zGroup createUnit [ selectRandom renz_zombieTypes, getposATL _can, [], 0, "NONE"]; 
[_targetFinder] join _zGroup;//Force join side

0 = [_targetFinder] call renz_fnc_zombie;

deleteVehicle _can;
//systemChat str ["zombie count", renz_ZombieCount];

waitUntil {!isNull (_targetFinder getVariable "renz_zombieHost")};
_host = _targetFinder getVariable "renz_zombieHost";
_host execVM 'renZombie\Director\fn_zombieMonitor.sqf'; 

//Civilian hats
removeHeadGear _host;
_host addHeadgear (selectRandom ["","","","","","","H_Booniehat_grn","H_Cap_tan","H_Cap_blk","H_Booniehat_dirty","H_Cap_red","H_Cap_blue","H_Cap_oli","H_StrawHat","H_Hat_blue","H_Hat_brown","H_Hat_checker","H_Hat_tan","H_Hat_grey","H_StrawHat_dark","H_Cap_grn","H_Beret_blk"]);
removeVest _host;

_zGroup reveal [_target, 4];



