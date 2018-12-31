// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Author: Renz
// Description: Makes a particle for everyone
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
	
params ["_obj","_pos","_particleNo"];

if (player distance _pos > getObjectViewDistance select 0) exitWith {};

_particleParams = switch (str _particleNo) do {
	case "0": {[["\A3\data_f\missileSmoke", 1, 0, 1], "", "Billboard", 1, 5, [0,0,0], [0, 0, -0.75], 0, 10, 7.9, 0.075, [0.4, 2, 4], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _obj];};//Gate hit

	default {""};
};

//              
//[["\A3\data_f\cl_basic.p3d", 1, 0, 1], "", "Billboard", 1, 15, [0, 0, 0], [0, 0, -0.75], 0, 10, 7.9, 0.075, [0.4, 2, 4], [[0.1, 0.1, 0.1, 0.7], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _obj]
_particles = "#particlesource" createVehicleLocal _pos; 
_particles setParticleParams _particleParams;
_particles setParticleRandom [0, [0.2, 0.2, 0.2], [0, 0, 0.5], 0, 0.1, [0, 0, 0, 0], 0, 0];
_particles  setDropInterval 1;
sleep 1;

deleteVehicle _particles;