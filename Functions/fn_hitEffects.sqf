//Zombie Hit effects for client side
params ["_unit", "_client", "_onFoot","_reach"];

sleep 0.3;
if ( (_unit distance _client) < (_reach + 2) && {alive _unit}	) then {//Allows the attack to fail 
		
	// --- Knockback ---
	private _vel = velocity _client;
	private _unitDir = (_unit getDir _client);
	_client setVelocity [(_vel select 0) + (sin(_unitDir) * renz_pushForce),  (_vel select 1) + (sin(180 - (90 + _unitDir)) * renz_pushForce), (_vel select 2) + renz_pushForce	];
		
	// --- Damage type ---
	if (_onFoot) then {
		
		// --- People ----
		private _damage = damage _client + 0.08;
		_client setDamage _damage;

		if (_damage < 1) then {//Blur player screen
			if (_client == player) then {
				private _priority = 730;
				private _name = "DynamicBlur";
				private "_handle";
			
				addCamShake [10, _damage, 25]; 
				
				while {_handle = ppEffectCreate [_name, _priority]; _handle < 0 } do {  _priority = _priority + 1	};  
				_handle ppEffectEnable true;  
				_handle ppEffectAdjust [5];  
				_handle ppEffectCommit 0;  
				waitUntil {ppEffectCommitted _handle};  
				_handle ppEffectAdjust [2];  
				_handle ppEffectCommit 0.2;  
				uiSleep 0.2; 
				_handle ppEffectEnable false;  
				ppEffectDestroy _handle;  
				 	
			} else {//Make client AI flee
				_client allowFleeing (	[0, 1] select (_damage >= 0.4 && _damage < 0.6 )	);
			};
		
		};
			
	} else {
		// --- Vehicles ---
		if (_client isKindOf "LandVehicle") exitWith {
			_client setHitIndex [6, (_client getHitIndex 6) + 0.01];
			_client setHitIndex [7, ((_client getHitIndex 7) + 0.2) min 0.9];
		};
		
		if (_client isKindOf "Air") exitWith {
			_client setHitIndex [6, (_client getHitIndex 6) + 0.01];
			_client setHitIndex [7, ((_client getHitIndex 7) + 0.2) min 0.9];
		};
		playSound3D [renz_SoundPath +  "MetalBang_1.ogg", _client, false, getPosASL _client, 0.2];
	};
	
	
	
	
	
};
