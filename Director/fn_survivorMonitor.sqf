//By Renz
//Monitors survivor intensity from players side

params["_p"];
	
//Player dies 
_p addEventHandler ["Killed",{//Reset svIntensity on player's death
	params["_p"];
	_p setVariable ["renz_svIntensity", 0];
}];