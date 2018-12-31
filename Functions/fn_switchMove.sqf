// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
// Author: Renz
// Description: Makes switchMove run for everyone
// // // // // // // // // // // // // // // // // // // // // // // // // // // // //
	
params ["_unit","_id"];

_unit switchMove ([
	"AwopPercMstpSgthWnonDnon_end",//Hit
	"AmovPercMrunSnonWnonDf_AmovPercMstpSnonWnonDnon_gthEnd",//Running hit
	"ApanPercMstpSnonWnonDnon_G03",//Idle 
	"AmovPercMstpSnonWnonDnon_AcrgPknlMstpSnonWnonDnon_getInMedium",//Get in medium
	"AcrgPknlMstpSnonWnonDnon_AmovPercMstpSnonWnonDnon_getOutMedium",//Get out medium
	"AcrgPknlMstpSnonWnonDnon_AmovPercMstpSnonWnonDnon_getOutLow",//Get out low
	"apctracked2_slot1_out",//Commander turned out
	"AmovPercMstpSnonWnonDnon_AcrgPknlMstpSnonWnonDnon_getInLow",//Get in low
	"AfalPercMstpSnonWnonDnon"//Fall
] select _id);