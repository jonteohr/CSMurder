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

int g_iPlayers = 0;

public void _Players_CVars() {
	gc_bMinPlayers = AutoExecConfig_CreateConVar("sm_murder_minplayers_enable", "1", "Enable \"Player Count Checks\" on round starts and only start the round when there's enough players online?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iMinPlayers = AutoExecConfig_CreateConVar("sm_murder_minplayers", "3", "The actual minimum amount of online players needed to start the round.", FCVAR_NOTIFY, true, 1.0);
}

public void _Players_OnMapStart() {
	for(int i = 1; i <= MaxClients; i++) if(IsValidClient(i)) g_iPlayers++;
}

public void _Players_OnRoundStart() {
	if(gc_bMinPlayers.IntValue == 1 && g_iPlayers < gc_iMinPlayers.IntValue) { // Not enough players
		ServerCommand("mp_pause_match");
		ServerCommand("mp_freezetime 1");
		ServerCommand("mp_restartgame 1");
	}
}

public void _Players_ClientConnect(int client) {
	if(gc_bMinPlayers.IntValue == 1) {
		g_iPlayers++;

		if(g_iPlayers < gc_iMinPlayers.IntValue) { // Not enough players
			ServerCommand("mp_unpause_match");
			ServerCommand("mp_freezetime 0");
			ServerCommand("mp_restartgame 1");
		}
	}
}

public void _Players_ClientDisconnect(int client) {
	if(gc_bMinPlayers.IntValue == 1 && IsValidClient(client, false, true))
		g_iPlayers--;
}