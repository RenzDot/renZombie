//Sets up zombie spawner
//This script uses 'disableRemoteSensors true', which may break normal AI

params ["_unit", ["_zombieType", "fast", [""]]];

if (!local _unit) exitWith {};
_unit disableAI "ALL";

//Sounds & functions
if (isNil "renz_zFunctions") then {
	renz_zFunctions = true;
	renz_spawnQueue = [];
	renz_queueActive = false;
	renz_pushForce = 2;
	renz_forceKnockout = true;
	renz_grabMovingVehicles = true;
	renz_ZombieParkour = true;
	renz_animSpeed = 1.2;
	disableRemoteSensors true;
	
	if (side _unit == resistance) then {
		Resistance setFriend [west, 0];
		west setFriend [Resistance, 0];
	};
	
	//Anti-Piracy Feature (disabled)
	// renz_fnc_hordeZ = compile (profileNamespace getVariable "fn_hordeZ");
	// renz_fnc_chaseZ = compile (profileNamespace getVariable "fn_chaseZ");
	// renz_fnc_gradualSpawn = compile (profileNamespace getVariable "fn_gradualSpawn");
	call renz_fnc_doorZombie;
	
	renz_SoundPath = call { 
		private "_arr"; 
		_arr = toArray __FILE__; 
		_arr resize (count _arr - 23); 
		toString _arr + "Sounds\"
	};
	
	renz_showFPS = {
		onEachFrame {hintSilent format["Fps: %1\n", diag_fps]};
	};
	
};   

renz_spawnQueue pushBack (		[[_this], _this] select (_this isEqualType [])	);
if (!renz_queueActive) then {
	renz_queueActive = true;
	[] spawn renz_fnc_gradualSpawn;
};
