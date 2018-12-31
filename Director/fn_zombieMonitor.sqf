//By Renz
//Monitors survivor intensity from zombies side

params["_z"];

//Zombie Dies
_z addEventHandler ["Killed",{
	params["_z", "_killer","_instigator"];
	_si = _instigator getVariable "renz_svIntensity";
	
	//Add SI to instigator
	if (!isNil "_si" ) then {
		if (alive _instigator) then {
			_i = ceil (-1)*(1/30)*(	(_instigator distance _z)^2	) + 30;
			_si =  _si + (_i max 0);
			_instigator setVariable ["renz_svIntensity", [renz_maxIntensity, _si] select (_si < renz_maxIntensity) ];
			
		};
	};
	
	
	//Add SI to zombie's target
	_target =  _z getVariable ["renz_target",objNull];
	if (!isNull _target) then {
		_si = _target getVariable "renz_svIntensity";
		if (!isNil "_si" && alive _target) then {
			_i = ceil (-1)*(1/30)*(	(_target distance _z)^2	) + 30;
			_si =  _si + (_i max 0);
			_target setVariable ["renz_svIntensity", [renz_maxIntensity, _si] select (_si < renz_maxIntensity) ];
			
		};
	};
	
}];


//Zombie attacks
_z addEventHandler ["AnimChanged",{
	params["_z", "_anim"];
	_target = _z getVariable ["renz_target",objNull];

	if (!isNull _target) then {
		_anim = animationState _z;
		if (_anim == "awoppercmstpsgthwnondnon_end") then {
			[_z,_target, _anim] spawn {
				params ["_z","_target","_anim"];
				_targetDmg = getDammage _target; 
				//systemChat "Attack Detected";
				waitUntil {animationState _z != _anim};
				
				//Zombie hits player
				if (_targetDmg !=  getDammage _target) then {
					_si = _target getVariable "renz_svIntensity";
					if (!isNil "_si") then {
						_si =  _si + 30;
						_target setVariable ["renz_svIntensity", [renz_maxIntensity, _si] select (_si < renz_maxIntensity) ];
					};
					
				}; 
			};
		};
	};
	
	
}];