// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Stores scripts inside profileNameSpace
// Author: Renz
// To use: Provide file path to the script and the variable name to store it in
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //

params [["_path",""],["_varName", ""]];

profileNameSpace setVariable [_varName, preprocessFileLineNumbers _path];
systemChat format ["'%1' is now stored in '%2'", _path, _varName];