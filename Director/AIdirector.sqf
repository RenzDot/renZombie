params ["_trigger"];

/*
--- Relax Stage ---
Maintain minimal threat population for 3-5 minutes
Monitor survivor intensity increases
*/

waitUntil {!isNil "inGame"};

//systemChat "New cycle started";

private _pList = [];
private _dList = [];
private _siList = [];
_playerList = list _trigger;
_relaxTime = (180 + random 120);	//Relax stage lasts max of 5 minutes
//_relaxTime = 1;
_release = 20 + random 40;//Spawns min. population every 20-60 seconds
_relaxCycle = 0;

{_x setVariable ["renz_svIntensity", 0]} forEach _playerList;

for "_i" from 1 to _relaxTime do {
	_relaxCycle = _relaxCycle + 1;
	_playerList = list _trigger;
	if (count _playerList == 0) exitWith {};
	_minPopulation = 1;
	//_minPopulation = (ceil (((0.05)*(count _playerList)^2) + 1.5)) min 5;
	
	{		//Decay survivor intensity
		_x setVariable ["renz_svIntensity",  ( (_x getVariable ["renz_svIntensity", 0]) + (renz_decayRate)*1) max 0 ];
	} forEach _playerList;
	
	//Maintain minimal threat population
	if (renz_ZombieCount < _minPopulation && {_relaxCycle >= _release}) then {//Find the closest player to trigger	
		_relaxCycle = 0;
		_release = 20 + random 40;//Spawns min. population every 20-60 seconds
		
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
		
		_distance = 150;
		_zSide = side renz_minGroup;
		_targetPos = getPosATL _closestPlayer; 
		_angle = (_closestPlayer getDir _trigger) + (random 45) - (random 45);
		_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), (_targetPos select 2)];
		_enemies = (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
		_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
		
		//_a = "Sign_Arrow_Large_Blue_F" createVehicle _searchPos;
		//_a setPos _searchPos;
		
		_timeout = 30;
		while {!_isEmpty} do {
			_angle = _angle + 20;
			_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), 0];
			_enemies =  (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
			_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
			_timeOut = _timeOut - 1;
			//_a = "Sign_Arrow_Large_Cyan_F" createVehicle _searchPos;
			//_a setPos _searchPos;
			if (_timeOut == 0) exitWith {systemChat "No valid spawn pos"};
			sleep 0.1;
		};
		
		for "_i" from 1 to ((_minPopulation - renz_ZombieCount) max 0) do {
			_angle = _angle + 10;
			_spawnPos =  [(_searchPos select 0) + (sin(_angle) * (random 30 - random 30)),(_searchPos select 1) + (sin(180 - (90 + _angle)) * (random 30 - random 30)), 0];
			_script = [_targetPlayer, _spawnPos, renz_minGroup] spawn renz_fnc_directorSpawn;
			//_a = "Sign_Arrow_Large_Green_F" createVehicle _spawnPos;
			//_a setPos _spawnPos;
			waitUntil {scriptDone _script};
		};
	};
	
	sleep 1;
}; 


/*
 --- Build up stage ---
- Adjust N
- Size of active area
Pick random N count depending on player count
Spawn full threat mob (30-40 zombies). 
Reveal player with least intensity to mob
Spawn mob in direction of next obj, behind players
On each zombie death, spawn a replacement
Place replacement in direction of next obj
Reveal to player with least intensity to replacement zombie
Continue until peak threshold reached by 15% of players
*/


//Maintain a horde
//systemChat "Build up mode started";
_playerList = list _trigger;
if (count _playerList == 0) exitWith {};
_peaks = {_x > renz_peakIntensity} count _siList;
_delay = 2;

_maxPopulation = (	((0.5)*((count _playerList)^2) + 15) + round random 10	) min 50;

//while {_peaks <= (count _playerList*0.15) && count _playerList != 0} do {//Spawn zombies until peak intensity reached by 15% of players (So at 7 players, 2 players must reach peak SI)
while {_peaks < [1,2] select (count _playerList > 1) && count _playerList != 0} do {//Spawn zombies until 2 players (or 1 if only one player) reach peak intensity
	_playerList = list _trigger;
	
	{		//Decay survivor Intensity
		_x setVariable ["renz_svIntensity",  ((_x getVariable ["renz_svIntensity", 0]) + (renz_decayRate)*_delay) max 0 ];
	} forEach _playerList;
	
	if (renz_ZombieCount < _maxPopulation) then {//Find the closest player to trigger	
		
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
		
		_distance = 150;
		_zSide = side renz_mobGroup;
		_targetPos = getPosATL _closestPlayer; 
		_angle = (_closestPlayer getDir _trigger) + (random 45) - (random 45);
		_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), (_targetPos select 2)];
		_enemies = (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
		_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
		
		//_a = "Sign_Arrow_Large_Red_F" createVehicle _searchPos;
		//_a setPos _searchPos;
		
		_timeout = 30;
		while {!_isEmpty} do {
			_angle = _angle + 20;
			_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), 0];
			_enemies =  (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
			_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
			_timeOut = _timeOut - 1;
			if (_timeOut == 0) exitWith {systemChat "No valid spawn pos"};
			
			//_a = "Sign_Arrow_Large_Yellow_F" createVehicle _searchPos;
			//_a setPos _searchPos;
			
			sleep 0.1;
		};
		
		for "_i" from 1 to ((_maxPopulation - renz_ZombieCount) max 0) do {
			_angle = _angle + 10;
			_spawnPos =  [(_searchPos select 0) + (sin(_angle) * (random 30 - random 30)),(_searchPos select 1) + (sin(180 - (90 + _angle)) * (random 30 - random 30)), 0];
			_script = [_targetPlayer, _spawnPos, renz_mobGroup] spawn renz_fnc_directorSpawn;
			//_a = "Sign_Arrow_Large_F" createVehicle _spawnPos;
			//_a setPos _spawnPos;
			waitUntil {scriptDone _script};
		};
	};

	_peaks = {_x > renz_peakIntensity} count _siList;
	//systemChat str ["No. of peaks", _peaks, (_peaks <= [1,2] select (count _playerList > 1) && count _playerList != 0), _siList];
	sleep _delay;
	
};
//systemChat "Sustaining peak...";

// --- Sustain peak stage ---
/*
Wait for 3-5 seconds
Stop spawning full threat population 
*/
_playerList = list _trigger;
if (count _playerList == 0) exitWith {};
for "_i" from 1 to 20 + (floor random 40) do {
	_playerList = list _trigger;
	//systemChat str _playerList;
	if (count _playerList == 0) exitWith {};
	if (renz_ZombieCount < _maxPopulation) then {//Find the closest player to trigger	
		
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
		
		_distance = 150;
		_zSide = side renz_mobGroup;
		_targetPos = getPosATL _closestPlayer; 
		_angle = (_closestPlayer getDir _trigger) + (random 45) - (random 45);
		_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), (_targetPos select 2)];
		_enemies = (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
		_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
		
		/*_a = "Sign_Arrow_Large_Red_F" createVehicle _searchPos;
		_a setPos _searchPos;*/
		
		_timeout = 30;
		while {!_isEmpty} do {
			_angle = _angle + 20;
			_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), 0];
			_enemies =  (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
			_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
			_timeOut = _timeOut - 1;
			/*_a = "Sign_Arrow_Large_Yellow_F" createVehicle _searchPos;
			_a setPos _searchPos;*/
			if (_timeOut == 0) exitWith {
				systemChat "Error: No valid spawn position"
			};
			sleep 0.1;
		};
		
		for "_i" from 1 to ((_maxPopulation - renz_ZombieCount) max 0) do {
			_angle = _angle + 10;
			_spawnPos =  [(_searchPos select 0) + (sin(_angle) * (random 30 - random 30)),(_searchPos select 1) + (sin(180 - (90 + _angle)) * (random 30 - random 30)), 0];
			_script = [_targetPlayer, _spawnPos, renz_mobGroup] spawn renz_fnc_directorSpawn;
			/*_a = "Sign_Arrow_Large_F" createVehicle _spawnPos;
			_a setPos _spawnPos;*/
			waitUntil {scriptDone _script};
		};
	};
	
	//systemChat str _i;
	sleep 1;
};


// --- Peak fade stage ---
/*
Reduce N count to 10 (minimal threat population)
Spawn random zombie when N is available 
Decay survivor intensity for everyone, ignore further increases
return to relax mode
*/

_highestIntensity = selectMax _siList;
//systemChat "Peak decay comencing at " + _highestIntensity;
for "_i" from _highestIntensity to 1 step renz_decayRate*2 do {
	_playerList = list _trigger;
	if (count _playerList == 0) exitWith {};
	if (_i < renz_minIntensity) then {//Spawn minimal threat
	
	
		_minPopulation = (ceil (((0.05)*(count _playerList)^2) + 1.5)) min 5;
		if (renz_ZombieCount < _minPopulation) then {//Find the closest player to trigger	
		
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
			
			_distance = 150;
			_zSide = side renz_minGroup;
			_targetPos = getPosATL _closestPlayer; 
			_angle = (_closestPlayer getDir _trigger) + (random 45) - (random 45);
			_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), (_targetPos select 2)];
			_enemies = (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
			_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
			
			//_a = "Sign_Arrow_Large_Blue_F" createVehicle _searchPos;
			//_a setPos _searchPos;
			
			_timeout = 30;
			while {!_isEmpty} do {
				_angle = _angle + 20;
				_searchPos = [(_targetPos select 0) + (sin(_angle) * _distance),(_targetPos select 1) + (sin(180 - (90 + _angle)) * _distance), 0];
				_enemies =  (_searchPos nearEntities 100) select {_zSide != side group _x && !isAgent teamMember _x};
				_isEmpty =	(count _enemies == 0) && !(surfaceIsWater [_searchPos select 0, _searchPos select 1]);
				_timeOut = _timeOut - 1;
				//_a = "Sign_Arrow_Large_Cyan_F" createVehicle _searchPos;
				//_a setPos _searchPos;
				if (_timeOut == 0) exitWith {systemChat "No valid spawn pos"};
				sleep 0.1;
			};
			
			for "_i" from 1 to ((_minPopulation - renz_ZombieCount) max 0) do {
				_angle = _angle + 10;
				_spawnPos =  [(_searchPos select 0) + (sin(_angle) * (random 30 - random 30)),(_searchPos select 1) + (sin(180 - (90 + _angle)) * (random 30 - random 30)), 0];
				_script = [_targetPlayer, _spawnPos, renz_minGroup] spawn renz_fnc_directorSpawn;
				//_a = "Sign_Arrow_Large_Green_F" createVehicle _spawnPos;
				//_a setPos _spawnPos;
				waitUntil {scriptDone _script};
			};
		};
		
		
		
	
	};
	
	//systemChat str _i;
	sleep 1;
};


//Active area
/*
- Needs to remove zombies outside of active area
Get player position closest to next obj
Select a spawn pos an distance away from closest player pos, facing towards the next obj
Make spawn pos global

*/

//Survivor Intensity
/*
Represent suvivor intensity as value for each player
Only consider max suvivor intensity
- On infected dies, add (1/distance) points to everyone
- 
- On player death (not player disconnect), add 50 points to everyone
*/


//Classes
/*
All classes have chemlight flares
- Reporter: Has map, GPS, Compass & Binos + 30 mag Pistol
- Zoo Keeper: Marksman rifle (M14 depending on dlc)
- Boss: Infinite zubar ammo
- Butler: Rifle + bodyarmour
- Tourist: Machinegun (apex dependant)
- Salesman: Mobile ammo crate (Recieves team's ammo regularly) + sub machinegun
- Store Owner: Rifle + Flare gun + grenades
- Docter: Extra first aids + pistol
*/