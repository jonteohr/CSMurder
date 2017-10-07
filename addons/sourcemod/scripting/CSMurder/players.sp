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
bool g_bPaused;

public void _Players_CVars() {
	gc_bMinPlayers = AutoExecConfig_CreateConVar("sm_murder_minplayers_enable", "1", "Enable \"Player Count Checks\" on round starts and only start the round when there's enough players online?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iMinPlayers = AutoExecConfig_CreateConVar("sm_murder_minplayers", "3", "The actual minimum amount of online players needed to start the round.", FCVAR_NOTIFY, true, 1.0);
}

public void _Players_OnMapStart() {
	for(int i = 1; i <= MaxClients; i++) if(IsValidClient(i)) g_iPlayers++;
}

public void _Players_OnRoundStart() {
	if(gc_bMinPlayers.IntValue == 1 && g_iPlayers < gc_iMinPlayers.IntValue && g_bPaused == false) { // Not enough players
		ServerCommand("mp_pause_match");
		ServerCommand("mp_freezetime 1");
		ServerCommand("mp_restartgame 1");
		g_bPaused = true;
	}
}

public void _Players_ClientConnect(int client) {
	if(gc_bMinPlayers.IntValue == 1) {
		g_iPlayers++;

		if(g_iPlayers > gc_iMinPlayers.IntValue && g_bPaused == true) { // Enough players
			ServerCommand("mp_unpause_match");
			ServerCommand("mp_freezetime 0");
			ServerCommand("mp_restartgame 1");
			g_bPaused = false;
		}
	}
}

public void _Players_ClientDisconnect(int client) {
	if(gc_bMinPlayers.IntValue == 1 && IsValidClient(client, false, true))
		g_iPlayers--;
}

public void _Players_SetSpeed(int client, char[] sItem, char[] sGun, int Knife) {
	
	/*	Murderer	*/
	if(IsValidClient(client) && IsMurderer(client) && Knife != -1) {
		if(StrEqual(sItem, "weapon_decoy", false)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
		if(StrEqual(sItem, "weapon_knife", false)) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.15);
		}
	}
}