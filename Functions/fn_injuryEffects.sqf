params ["_unit"];

_targetDmg = damage _unit;
_unit say3D selectRandom ["WoundedGuyA_07", "WoundedGuyB_04","WoundedGuyB_06", "WoundedGuyB_07","WoundedGuyB_08"];
if (_targetDmg >= 0.4) then {
	_unit allowFleeing 1;
};


if (_unit != player) exitWith {};

addCamShake [10, _targetDmg, 25]; 
0 = ["DynamicBlur", 730, [0]] spawn {  
	params ["_name", "_priority", "_effect", "_handle"];  
	while {_handle = ppEffectCreate [_name, _priority]; _handle < 0 } do {  
	_priority = _priority + 1;  
	};  

	_handle ppEffectEnable true;  
	_handle ppEffectAdjust [5];  
	_handle ppEffectCommit 0;  
	waitUntil {ppEffectCommitted _handle};  
	_handle ppEffectAdjust [2];  
	_handle ppEffectCommit 0.2;  
	uiSleep 0.2; 
	_handle ppEffectEnable false;  
	ppEffectDestroy _handle;  
}; 