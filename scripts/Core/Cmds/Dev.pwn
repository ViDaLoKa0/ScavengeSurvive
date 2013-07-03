CMD:adminlvl(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	new level;

	if(sscanf(params, "d", level))
		return Msg(playerid, YELLOW, " >  Usage: /adminlvl [level]");

	if(!SetPlayerAdminLevel(playerid, level))
		return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 4");


	MsgF(playerid, YELLOW, " >  Admin Level Secretly Set To: %d", level);

	return 1;
}

//==============================================================================Player

ACMD:setadmin[4](playerid, params[])
{
	new
		id,
		level;

	if (sscanf(params, "dd", id, level))
		return Msg(playerid, YELLOW, " >  Usage: /setadmin [playerid] [level]");

	if(playerid == id)
		return Msg(playerid, RED, " >  You cannot set your own level");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && gPlayerData[playerid][ply_Admin] < 3)
		return 3;

	if(!IsPlayerConnected(id))
		return 4;

	if(!SetPlayerAdminLevel(id, level))
		return Msg(playerid, RED, " >  Admin level must be equal to or between 0 and 3");


	MsgF(playerid, YELLOW, " >  You made %P"#C_YELLOW" a Level %d Admin", id, level);
	MsgF(id, YELLOW, " >  %P"#C_YELLOW" Made you a Level %d Admin", playerid, level);

	return 1;
}

ACMD:setvip[4](playerid, params[])
{
	new id, toggle;

	if(sscanf(params, "dd", id, toggle))
		return Msg(playerid, YELLOW, " >  Usage: /setvip [playerid]");

	if(gPlayerData[id][ply_Admin] >= gPlayerData[playerid][ply_Admin] && playerid != id)
		return 3;

	if(toggle)
	{
		t:bPlayerGameSettings[id]<IsVip>;
		MsgF(playerid, YELLOW, " >  You gave VIP status to %P", id);
	}
	else
	{
		f:bPlayerGameSettings[id]<IsVip>;
		MsgF(playerid, YELLOW, " >  You removed VIP status from %P", id);
	}
	return 1;
}

ACMD:setpinglimit[4](playerid, params[])
{
	new val = strval(params);

	if(!(100 < val < 1000))
	{
		Msg(playerid, YELLOW, " >  Ping limit must be between 100 and 1000");
		return 1;
	}

	gPingLimit = strval(params);
	MsgF(playerid, YELLOW, " >  Ping limit has been updated to %d.", gPingLimit);

	return 1;
}

ACMD:gamename[3](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	MsgF(playerid, YELLOW, " >  GameMode name set to "#C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[3](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	MsgF(playerid, YELLOW, " >  Hostname set to "#C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[3](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /mapname [name]");

	new str[74];
	format(str, sizeof(str), "mapname %s", params);
	SendRconCommand(str);

	return 1;
}

ACMD:gmx[4](playerid, params[])
{
	RestartGamemode();
	return 1;
}

ACMD:loadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Loading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Reloading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	MsgF(playerid, YELLOW, " >  Unloading Filterscript: "#C_BLUE"'%s'", params);

	return 1;
}

//==============================================================================Utilities

ACMD:sp[4](playerid, params[])
{
	new PositionName[128];

	if(!sscanf(params, "s[128]", PositionName))
	{
		new
			string[128],
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		if(IsPlayerInAnyVehicle(playerid))
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			GetVehiclePos(vehicleid, x, y, z);
			GetVehicleZAngle(vehicleid, r);
		}
		else
		{
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, r);
		}

		format(string, 128, "%.4f, %.4f, %.4f, %.4f", x, y, z, r);
		file_Open("savedpositions.txt");
		file_SetStr(PositionName, string);
		file_Save("savedpositions.txt");
		file_Close();

		MsgF(playerid, ORANGE, " >  %s = %s "#C_BLUE"Saved!", PositionName, string);
	}
	else
	{
		Msg(playerid, YELLOW, " >  Usage: /sp [position name]");
	}
 
	return 1;
}

ACMD:tp[4](playerid, params[])
{
	new PositionName[128];

	if(!sscanf(params, "s[128]", PositionName))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r,
			data[256];

		file_Open("savedpositions.txt");
		{
			if(!file_IsKey(PositionName))
			{
				Msg(playerid, RED, " >  Position not found");
				return 1;
			}
		}
		file_Close();

		file_GetStr(PositionName, data);
		sscanf(data, "p<,>ffff", x, y, z, r);
		MsgF(playerid, YELLOW, " >  "#C_BLUE"%s = %s "#C_YELLOW"Loaded!", PositionName, data);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			SetVehiclePos(vehicleid, x, y, z);
			SetVehicleZAngle(vehicleid, r);
		}
		else
		{
			SetPlayerPos(playerid, x, y, z);
			SetPlayerFacingAngle(playerid, r);
		}
	}
	else
	{
		Msg(playerid, YELLOW, " >  Usage: /tp [position name]");
	}

	return 1;
}

ACMD:sound[4](playerid, params[])
{
	new
		soundid = strval(params),
		Float:x,
		Float:y,
		Float:z;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 20.0, x, y, z))PlayerPlaySound(i, soundid, x, y, z);
	}
	
	return 1;
}

ACMD:anim[4](playerid, params[])
{
	new
		lib[20],
		anim[30],
		loop,
		Float:speed;

	if(sscanf(params, "s[20]s[30]D(0)F(4.0)", lib, anim, loop, speed))
	{
		Msg(playerid, YELLOW, "Usage: /anim LIB ANIM LOOP SPEED");
		return 1;
	}
	
	ApplyAnimation(playerid, lib, anim, speed, loop, 1, 1, 0, 0, 1);

	return 1;
}

ACMD:gotopos[4](playerid, params[])
{
	new
		Float:x,
		Float:y,
		Float:z;

	if(sscanf(params, "fff", x, y, z) || sscanf(params, "p<,>fff", x, y, z))
		return Msg(playerid, YELLOW, "Usage: /gotopos x, y, z (With or without commas)");

	MsgF(playerid, YELLOW, " >  Teleported to %f, %f, %f", x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}

ACMD:getanim[4](playerid, params[])
{
	new
		animlib[32],
		animname[32],
		idx = GetPlayerAnimationIndex(playerid);

	GetAnimationName(idx, animlib, 32, animname, 32);
	MsgF(playerid, YELLOW, "Lib: %s Name: %s Idx: %d", animlib, animname, idx);

	return 1;
}

ACMD:visob[4](playerid, params[])
{
	MsgF(playerid, YELLOW, "Current Visible Objects: %d", Streamer_CountVisibleItems(playerid, STREAMER_TYPE_OBJECT));
	return 1;
}

ACMD:ActionText[4](playerid, params[])
{
	ShowActionText(playerid, "This is a message~n~This is a new line~n~~g~h~r~e~b~l~y~l~p~o ~g~w~r~o~y~r~b~l~p~d~y~!", 3000);
	return 1;
}

ACMD:decam[4](playerid, params[])
{
	new Float:cx, Float:cy, Float:cz, Float:px, Float:py, Float:pz;
	GetPlayerCameraPos(playerid, cx, cy, cz);
	GetPlayerPos(playerid, px, py, pz);
	SetPlayerCameraPos(playerid, cx, cy, cz);
	SetPlayerCameraLookAt(playerid, px, py, pz);
	return 1;
}

ACMD:recam[1](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}

ACMD:cob[4](playerid, params[])
{
	new o;
	if(!sscanf(params,"d",o))
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		CreateObject(o, x, y, z, 0, 0, 0);
	}
	return 1;
}

//==============================================================================World Movement Commands

ACMD:setvw[4](playerid, params[])
{
	SetPlayerVirtualWorld(playerid, strval(params));
	return 1;
}

ACMD:setint[4](playerid, params[])
{
	SetPlayerInterior(playerid, strval(params));
	return 1;
}

ACMD:hud[4](playerid, params[])
{
	if(bPlayerGameSettings[playerid] & ShowHUD)
	{
		PlayerTextDrawHide(playerid, HungerBarBackground);
		PlayerTextDrawHide(playerid, HungerBarForeground);
		HideWatch(playerid);
		f:bPlayerGameSettings[playerid]<ShowHUD>;
	}
	else
	{
		PlayerTextDrawShow(playerid, HungerBarBackground);
		PlayerTextDrawShow(playerid, HungerBarForeground);
		ShowWatch(playerid);
		t:bPlayerGameSettings[playerid]<ShowHUD>;
	}
}

ACMD:vowner[4](playerid, params[])
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		owner[MAX_PLAYER_NAME];

	if(!IsValidVehicle(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	GetVehicleOwner(vehicleid, owner);

	MsgF(playerid, YELLOW, " >  Vehicle owner: '%s'", owner);

	return 1;
}

ACMD:vdelete[4](playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	DestroyVehicle(vehicleid);

	return 1;
}

ACMD:vrespawn[4](playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
	{
		Msg(playerid, RED, " >  You are not in a vehicle.");
		return 1;
	}

	RespawnVehicle(vehicleid);

	return 1;
}

ACMD:weather[4](playerid, params[])
{
	if(strlen(params) > 2)
	{
		for(new i; i < sizeof(WeatherData); i++)
		{
			if(strfind(WeatherData[i][weather_name], params, true) != -1)
			{
				foreach(new j : Player)
				{
					SetPlayerWeather(j, i);
				}

				gWeatherID = i;
				MsgAdminsF(gPlayerData[playerid][ply_Admin], YELLOW, " >  Weather set to "#C_BLUE"%s", WeatherData[i]);

				return 1;
			}
		}
		Msg(playerid, RED, " >  Invalid weather!");
	}

	return 1;
}

ACMD:ann[4](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return Msg(playerid,YELLOW," >  Usage: /ann [Message]");

	GameTextForAll(params, 5000, 5);

	return 1;
}
