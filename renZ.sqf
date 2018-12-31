//renZombie Script V3 by Renz

params["_unit"];
if (!local _unit) exitWith {};     
/*_type = typeOf _unit;
_orginalPos = position _unit;
_side = side _unit;*/

if (isNil "renz_ZombieCount") then {renz_ZombieCount = 0};
renz_ZombieCount = renz_ZombieCount + 1;
_brains = [renz_fnc_chaseZ, renz_fnc_hordeZ] select (renz_zombieCount > 5);

//Zombie now pursuits its target while its alive
while {alive _unit} do {
	if (true) then _brains;
	sleep 1;
};

renz_ZombieCount = (renz_ZombieCount - 1) max 0;
deleteVehicle  (_unit getVariable "renz_targetFinder");