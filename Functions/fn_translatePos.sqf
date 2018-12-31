// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// translates a position given the getDir and the position
// Author: Renz
// To use: Define in CfgFunctions and call to return a result
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //


/*
_pos - Starting position [x,y,z]
_dir - direction to move from (degrees)
_dis - Distance to move 
*/
params ["_pos", "_dir","_dis"];

_x1 = _dis*(sin _dir);
_y1 = _dis*(cos _dir);

//hintSilent str [_x1,_y1];
[(_pos select 0) + _x1, (_pos select 1) + _y1, (_pos select 2)]