private ["_tipo","_coste","_grupo","_unit","_tam","_roads","_road","_pos","_camion","_texto","_mrk","_hr","_exists","_positionTel","_typeGroup","_resourcesFIA","_hrFIA"];

if (!([player] call hasRadio)) exitWith {hint localize "STR_HINTS_FD_YNARIYITBA"};
if ("campsFIA" in missionsX) exitWith {hint localize "STR_TSK_TD_BEMP_RESTR"};

_tipo = _this select 0;
_markers = mrkAAF;
_maxCamps = 3;

// BE module
_permission = true;
_text = "Error in permission system, module ft.";
if ((activeBE) && (_tipo == "create")) then {
	_permission = ["camp"] call fnc_BE_permission;
	_text = "We cannot maintain any additional camps.";
	_maxCamps = 100;
};

if !(_permission) exitWith {hint _text};
// BE module

openMap true;
positionTel = [];
if (_tipo == "create") then {hint localize "STR_HINTS_FD_COTPYWTETC"};
if (_tipo == "delete") then {hint localize "STR_HINTS_FD_COTCTAAC"};
if (_tipo == "rename") then {hint localize "STR_HINTS_FD_COTCTRAC"};

onMapSingleClick "positionTel = _pos;";

waitUntil {sleep 1; (count positionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

if (getMarkerPos guer_respawn distance positionTel < 100) exitWith {hint localize "STR_HINTS_FD_LITCTB"; openMap false;};

openMap false;
_positionTel = positionTel;
_pos = [];

if ((_tipo == "delete") and (count campsFIA < 1)) exitWith {hint localize "STR_HINTS_FD_NCTA"};
if ((_tipo == "delete") and ({(alive _x) and (!captive _x) and ((side _x == side_green) or (side _x == side_red)) and (_x distance _positionTel < 500)} count allUnits > 0)) exitWith {hint localize "STR_HINTS_FD_YCDACWEANI"};

_coste = 500;
_hr = 0;

if ((_tipo == "create") && (count campsFIA > _maxCamps)) exitWith {hint localize "STR_HINTS_FD_YCOSAMOFFC"};

if (_tipo == "create") then {
	_typeGroup = guer_grp_sniper;
	_formatX = ([guer_grp_sniper, "guer"] call AS_fnc_pickGroup);
	if !(typeName _typeGroup == "ARRAY") then {
		_typeGroup = [_formatX] call groupComposition;
	};
	{_coste = _coste + (server getVariable _x); _hr = _hr +1} forEach _typeGroup;
};

_txt = "";
_break = false;
while {(_tipo == "delete") && !(_break)} do {
	scopeName "loop1";
	_mrk = [campsFIA,_positionTel] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	if (_positionTel distance _pos > 50) exitWith {_break = true; _txt = "No camp nearby.";};
	breakOut "loop1";
};

while {(_tipo == "rename")} do {
	scopeName "loop2";
	_mrk = [campsFIA,_positionTel] call BIS_fnc_nearestPosition;
	_pos = getMarkerPos _mrk;
	if (_positionTel distance _pos > 50) exitWith {_break = true; _txt = "No camp nearby.";};

	createDialog "rCamp_Dialog";

	((uiNamespace getVariable "rCamp") displayCtrl 1400) ctrlSetText cName;

	waitUntil {dialog};
	waitUntil {!dialog};
	if (cName == "") exitWith {_break = true; _txt = "No name entered...";};
	_mrk setMarkerText cName;
	for "_i" from 0 to (count campList - 1) do {
		if ((campList select _i) select 0 == _mrk) then {
			(campList select _i) set [1, cName];
		};
	};
	publicVariable "campList";
	cName = "";
	hint localize "STR_HINTS_FD_CR";
	breakOut "loop2";
};

if (_break) exitWith {openMap false; hint _txt;};

_resourcesFIA = server getVariable "resourcesFIA";
_hrFIA = server getVariable "hr";

if (((_resourcesFIA < _coste) or (_hrFIA < _hr)) and (_tipo == "create")) exitWith {hint format [localize "STR_HINTS_FD_YLORTBTC",_hr,_coste]};

if (_tipo == "create") then {
	[-_hr,-_coste] remoteExec ["resourcesFIA",2];
};

if (_tipo != "rename") then {
	[[_tipo,_positionTel],"establishCamp"] call BIS_fnc_MP;
};
