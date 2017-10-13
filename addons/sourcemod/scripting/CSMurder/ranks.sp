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

public void _Ranks_CVars() {
	gc_bRanks = AutoExecConfig_CreateConVar("sm_murder_ranks", "1", "Enable/Disable player ranks that promotes them depending on playtime?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bChatRanks = AutoExecConfig_CreateConVar("sm_murder_ranks_chat", "1", "Show the players rank in chat as a prefix to their name?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bClanRanks = AutoExecConfig_CreateConVar("sm_murder_ranks_clantag", "1", "Show the players rank as a clan tag in scoreboard?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void _Ranks_OnPluginStart() {
	if(gc_bRanks.IntValue == 1)
		RegConsoleCmd("sm_rank", Command_Rank);
}

public Action Command_Rank(int client, int args) {
	if(!IsValidClient(client, _, true))
		return Plugin_Handled;
	
	/*
		TODO
		Make it days, hours, minutes
	*/
	
	char rank[32];
	SQL_GetUserRank(client, rank, sizeof(rank));
	
	CPrintToChat(client, "%s %t", g_sPrefix, "User Rank", rank);
	CPrintToChat(client, "%s %t", g_sPrefix, "User Playtime", SQL_GetUserPlaytime(client));
	
	return Plugin_Handled;
}

public void _Ranks_OnMapStart() {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i, _, true))
			continue;
		
		if(!SQL_IsUserInTable(i)) // Add user to DB if not exists
			SQL_AddUserToTable(i);
	}
}

public void _Ranks_OnClientPutInServer(int client) {
	if(IsValidClient(client, _, true))
		if(!SQL_IsUserInTable(client))
			SQL_AddUserToTable(client);
}