// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Turns a player into a zombie after the player dies. 
// Author: Renz, 2017
// To use: Run with passed zombie's side with spawn. Requires sounds from renZombie folder
// If directorInit.sqf is running from renZombie folder, then the player is positioned depending on where renz_zombieTrigger is placed. Else thier just positioned whereever
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //

params ["_zombieSide"];

renz_zombieSide = _zombieSide;
renz_cureTime = 120;

if (isServer) then {
	renz_zPlayerGroup = createGroup _zombieSide;
	_z = renz_zPlayerGroup createUnit ["I_G_Survivor_F", [0,0,0], [], 0, "CAN_COLLIDE"];//Ensures renz_zPlayerGroup is never deleted
	_z enableSimulation false;
	_z disableAI "ALL";
	publicVariable "renz_zPlayerGroup";
};

"colorCorrections" ppEffectAdjust [0.5, 1.04, -0.004, [0.5, 1.0, 0.0, 0.0], [0.5, 1.0, 0.5, 0],  [0.2, 0.5, 0.5, 0.0] ];  
"colorCorrections" ppEffectCommit 0; 
"filmGrain" ppEffectAdjust [0.3, 0.1, 0.1, 0.1, 1.5, false];
"filmGrain" ppEffectCommit 0; 

waituntil {!isNil "inGame"};
if (!isServer && (player != player)) then { waitUntil {player == player}; waitUntil {time > 1}; };
waitUntil {!isNil "renz_zPlayerGroup"};

renz_infectplayer = {
	params ["_p"];
	
	
	removeVest _p;
	removeGoggles _p;
	removeAllItems _p;
	removeHeadGear _p;
	removeAllWeapons _p;
	
	
	_p enableFatigue false;
	_p setAnimSpeedCoef 1.2;
	[_p, "dead"] remoteExec ["setMimic"];
	_p setVariable ["renz_isPlayerZombie", true];
	_p switchMove "ApanPercMstpSnonWnonDnon_G03";
	[_p] joinSilent renz_zPlayerGroup;//Ensures player is not attacked by other zombies
	_p forceAddUniform selectRandom ["U_C_Man_casual_1_F", "U_C_Man_casual_2_F","U_C_Man_casual_2_F","U_C_HunterBody_grn"];
	hintSilent format ["YOU ARE A ZOMBIE\n\n%5\n\n%1\n\n%2\n\n%3\n\n%4\n\n", format ["Use '%1' (Grenade Key) to attack survivors", actionKeysNames ["throw", 1] ], format ["Use '%1' (Reload key) to ask for Braaainssss", actionKeysNames ["ReloadMagazine", 1] ], "Press 'V' to jump parkour!", "Press 'N' to toggle Night Vision","Attack Survivors"];
	
	//Remove weapons
	_noWep = _p spawn {	
		while {(player getVariable "renz_isPlayerZombie")} do {		
			if (primaryWeapon _this != "") then {
				(format ["Error: %1 no weapon", name player]) remoteExec ["systemChat"];
			}; 
			removeAllWeapons _this; 
			sleep 2;
		};
	};
	
	//Force 3rd person
	
	[] spawn {
		waitUntil {player switchCamera "EXTERNAL"; !(player getVariable "renz_isPlayerZombie")};
		player switchCamera "Internal";
	};
	
	renz_isjump = false;
	renz_NVtrue = false;
	renz_isEating = false;
	renz_isGroaning = false;
	renz_playerHitting = false;
	
	
	
};

renz_addZombieEH = {
	params ["_p"];
	zHealEH = player addEventHandler ["HandleHeal", {true}];//Disable healing
	zInventoryEH = player addEventHandler ["InventoryOpened", {true}];//Disable inventory
	zDamageEH = player addEventHandler["HandleDamage",{		//Remove fall damage
		if ( (_this select 4) == "") then {damage (_this select 0)};	
	}];
	zTakeEH = player addEventHandler ["Take",{//Prevent taking weapons
		params ["_p", "_container","_item"];
		removeAllWeapons _p;
		removeAllItems _p;
		titleText ["You ate the item","PLAIN DOWN"];
		//_p switchMove "";
		systemChat "You ate the item";
		[] spawn {
			if (!renz_isEating) then {
				renz_isEating = true;
				[player, ["Eating",50]] remoteExec ["say3D"];
				sleep 4.5;
				renz_isEating = false;
			};
		};
	
	}];

	zHitEH = player addEventHandler ["Hit", {//prevent revive behaviour
		_p = _this select 0;
		_lastInstigator = (_this select 3);
		_p call {
			params ["_p"];
			if (lifeState player == "INCAPACITATED") then {
				_p setDamage 1;
			};
		};
	}];
	
	//Custom key binds
	[] spawn {
		waitUntil {!isNull (findDisplay 46)};
		zkeysEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			private _key = (_this select 1);
			
			//Attach hitting to Throw Key
			if (	_key in actionKeys "throw"	) exitWith {
				if (animationState player != "awoppercmstpsgthwnondnon_end" && alive player && !renz_playerHitting) then {
					renz_playerHitting = true;
					player switchMove "AwopPercMstpSgthWnonDnon_end";
					[player, "AwopPercMstpSgthWnonDnon_end"] remoteExecCall ["switchMove"];
					[player, [format ["A_attack%1",ceil random 2],50]] remoteExec ["say3D"];
					_pDir = getDir player;
						
					{
						_hitDir = player getDir _x;
						if (	 _hitDir > (_pDir - 90) && _hitDir <= (_pDir + 90) ) then {//Ensure zombie player is facing the target
							[player, _x, (vehicle _x isKindOf "man"), 2.5] remoteExec ["renz_fnc_hitEffects", _x];	
						};
							
					} forEach (	((getPosATL player) nearEntities 2.5) select {renz_zombieSide != side group _x && !isAgent teamMember _x}	);
					[] spawn {//Attack cooldown
						sleep 1;
						renz_playerHitting = false;
					
					};
				};
			};
				
			//Attach groan sound to reload Key
			if (_key in actionKeys "reloadMagazine") exitWith {
				if (!renz_isGroaning) then {
					renz_isGroaning = true;
					[] spawn {
						[player, [format ["A_groan%1",ceil random 5],50]] remoteExec ["say3D"];
						sleep 3;
						renz_isGroaning = false;
					};
				};
			};
				
			if (_key == 49) exitWith {
				if (renz_NVtrue) then {
					renz_NVtrue = false;
					setAperture -1;
					"colorCorrections" ppEffectEnable false;
					"filmGrain" ppEffectEnable false; 
				} else {
					renz_NVtrue = true;
					setAperture 0.75;
					"colorCorrections" ppEffectEnable true;
					"filmGrain" ppEffectEnable true; 
				};
					
			};
				
				
			//Attach jump to "V"
			if (_key == 47 && !renz_isjump) then {
				renz_isjump = true;
				[] spawn {
					private _v = velocity player;
					private _p = getPos player;
					private _d = getDir player;
					private _f = 7;//jump parkour force
					_x1 = _f*(sin _d);
					_y1 = _f*(cos _d);
					player setVelocity [(_v select 0)+_x1, (_v select 1)+_y1, (_v select 2) + _f];
					playSound3D ["A3\Sounds_F\ambient\battlefield\battlefield_explosions3.wss", player, false, [_p select 0, _p select 1, -2], 2, 1, 0];
					_timer = time + 4;
					waitUntil {vectorMagnitude velocity player < 2 || time >= _timer};
					renz_isjump = false;
				};
				
			};
				
			if (renz_isjump) then {//Movement in air while jump parkouring
				private _v = velocity player;
				
				if (vectorMagnitude _v < 20) then {
					private _d = getDir player;
					private _f = 2;//Force of movement
					if (_key in actionKeys "MoveForward") then {
						_d = _d;
					};
						
					if (_key in actionKeys "MoveBack") then {
						_d = _d + 180;
					};
						
					if (_key in actionKeys "TurnLeft") then {//MoveLeft 
						_d = _d - 90;
					};
						
					if (_key in actionKeys "TurnRight") then {//MoveRight
						_d = _d + 90;
					};
						
					_x1 = _f*(sin _d);
					_y1 = _f*(cos _d);
					player setVelocity [(_v select 0)+_x1, (_v select 1)+_y1, _v select 2 ];
				};
				
			};
			
			
		}];//KeyDown EH finish
		
		
	};//Spawn finish
	


	
};


player setVariable ["renz_isPlayerZombie", false];
player addEventHandler ["Respawn", {
	params ["_p", "_corpse"];
	if (!(player getVariable "renz_isPlayerZombie")) then {
		"YOU WERE ZOMBIFIED" hintC  ["Attack survivors", format ["Use %1 (Grenade Key) to hit people", actionKeysNames ["throw", 1] ], format ["Use %1 (Reload key) to ask for Braaainsss", actionKeysNames ["ReloadMagazine", 1] ], "Press 'V' to jump parkour!", "Press 'N' to toggle Night Vision"];
		player say3D "Scream_1";
		player setVariable ["renz_isPlayerZombie", true];
		player setVariable ["renz_isZombie", true];
		
		renz_newZombie = profileNameSteam;
		publicVariableServer "renz_newZombie";
		//systemChat "Sending new name to server";
		
		_p call renz_addZombieEH;
		
		// --- Cure player ---
		[] spawn {
			sleep 15; 
			for "_i" from 1 to renz_cureTime do {
				hintSilent format ["You will be cured in %1 s", renz_cureTime - _i];
				sleep 1;
			};
			hint "You were cured!";

			//Remove zombie EH
			setAperture -1;
			player switchMove "";
			player setAnimSpeedCoef 1;
			player setVelocity [0,0,0];
			"filmGrain" ppEffectEnable false; 
			"colorCorrections" ppEffectEnable false;
			player setVariable ["renz_isZombie", false];
			player setVariable ["renz_isPlayerZombie", false];
			player removeEventHandler ["Hit", zHitEH];
			player removeEventHandler ["Take", zTakeEH];
			player removeEventHandler ["HandleHeal", zHealEH];
			player removeEventHandler ["HandleDamage", zDamageEH];
			player removeEventHandler ["InventoryOpened", zInventoryEH];
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", zkeysEH];

			//Survivor gear
			player forceAddUniform "U_B_T_Soldier_AR_F";
			removeHeadGear player;
			player addVest "V_TacChestrig_grn_F";
			player addHeadgear "H_Watchcap_blk";
			0 = [] spawn {//Fixes the camera does not switch back sometimes
				_time = time + 10;
				waitUntil {player switchCamera "Internal"; time > _time};
			};
 			for "_i" from 1 to 5 do {player addItemToVest "30Rnd_9x21_Yellow_Mag"};
			for "_i" from 1 to 18 do {player addItemToVest "30Rnd_556x45_Stanag_green"};
			for "_i" from 1 to 2 do {player addItemToVest "FirstAidKit"};
			for "_i" from 1 to 2 do {player addItemToVest "HandGrenade"};
			player setDamage 0.1;//Fixes health bar not updating
			player addWeapon "arifle_Mk20_ACO_pointer_F";
			player addWeapon "hgun_Rook40_F";
			player removePrimaryWeaponItem "acc_pointer_IR";
			player addPrimaryWeaponItem "acc_flashlight";


			//Teleport to survivors
			_westPlayers = (call BIS_fnc_listPlayers) select {side group _x == west && alive _x && _x != player};
			_westPlayers append (allPlayers select {side group _x == west && alive _x && _x != player});
			_freindly =  selectRandom _westPlayers;
			player setPosWorld getposWorld _freindly;
			[player] joinSilent (group _freindly);
			[1, 15,true,true] call BIS_fnc_cinemaBorder;
		
		};
		

	};
	
	_p call renz_infectplayer;
	
	//--- Find empty spawn pos ---
	[] spawn {
		if (isNil "renz_zombieTrigger") exitWith {};//Player just respawns at marker (e.g. )
		_trigger = renz_zombieTrigger;
		_playerList = list _trigger;
	
		_pList = [];//Array of players
		_dList = [];//Array of distances of each survivor from trigger
		_siList = [];//Array of survivor intensities of each player
		{	if (alive _x) then {
				_pList pushBack _x;
				_dList pushBack (_x distance _trigger);
				_siList pushBack (_x getVariable ["renz_svIntensity", 0]);
			};
		} forEach _playerList;
		private _closestPlayer = _pList select (	_dList find (selectMin _dList)		);
		private _targetPlayer = _pList select (	_siList find (selectMin _siList)		); //Target player of lowest survivor intensity
		
		_distance = 400 + random 100;
		_zSide = renz_zombieSide;
		_targetPos = getPosATL _closestPlayer; 
		_angle = (_closestPlayer getDir _trigger) + (random 45) - (random 45);
		_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), (_targetPos select 2)];
		_enemies = (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
		_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);

		_timeout = 30;
		while {!_isEmpty} do {
			_angle = _angle + 20;
			_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), 0];
			_enemies =  (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
			_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
			_timeOut = _timeOut - 1;
			
			if (_timeOut == 0) exitWith {
				systemChat "Error: No valid spawn position"
			};
		};
		
		_spawnPos = [(_searchPos select 0) + (sin(_angle) * (random 30 - random 30)),(_searchPos select 1) + (sin(180 - (90 + _angle)) * (random 30 - random 30)), 0];
		player setPos _spawnPos;
	
	};
	
}]; 
