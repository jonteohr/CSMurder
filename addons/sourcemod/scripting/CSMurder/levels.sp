/*
 * SourceMod CSGO Murder
 * by: Hypr
 *
 * This file is part of the CSGO Murder project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public void _Levels_CVars() {
	gc_bXray = AutoExecConfig_CreateConVar("sm_murder_xray", "1", "Enable the xray-feature for the murderer?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iXrayLvl = AutoExecConfig_CreateConVar("sm_murder_xray_level", "1", "What level should the xray feature for murders be unlocked?\n0 = No specific level needed.", FCVAR_NOTIFY, true, 0.0, true, 3.0);
}

public void _Levels_OnPluginStart() {
	RegConsoleCmd("sm_level", Command_Level);
}

public Action Command_Level(int client, int args) {
	if(!IsValidClient(client, _, true))
		return Plugin_Handled;
	
	int level = SQL_GetUserLevel(client);
	
	CPrintToChat(client, "%s %t", g_sPrefix, "User Level", level);
	
	return Plugin_Handled;
}

public void _Levels_OnRoundStart() {
	g_iKills = 0;
}

public void _Levels_OnPlayerKill() {
	g_iKills++;
}

public void _Levels_OnRoundEnd() {
	int prevKills = SQL_GetUserKills(g_iMurderer);
	SQL_SetUserKills(g_iMurderer, (prevKills + g_iKills));
	
	int curKills = SQL_GetUserKills(g_iMurderer);
	
	if(curKills >= 5) { // Level up!
		SQL_SetUserLevel(g_iMurderer, 1);
		CPrintToChat(g_iMurderer, "%s %t", g_sPrefix, "Level Up", SQL_GetUserLevel(g_iMurderer));
	} else if(curKills >= 10) {
		SQL_SetUserLevel(g_iMurderer, 2);
		CPrintToChat(g_iMurderer, "%s %t", g_sPrefix, "Level Up", SQL_GetUserLevel(g_iMurderer));
	} else if(curKills >= 20) {
		SQL_SetUserLevel(g_iMurderer, 3);
		CPrintToChat(g_iMurderer, "%s %t", g_sPrefix, "Level Up", SQL_GetUserLevel(g_iMurderer));
	}
}

public void MurderXray(int client, bool state) {
	if(IsValidClient(client))
		SendConVarValue(client, FindConVar("mp_teammates_are_enemies"), state ? "1" : "0");
}
