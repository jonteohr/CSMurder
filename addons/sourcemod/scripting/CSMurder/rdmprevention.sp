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

// Integers
int g_iRDMTimer;
int g_iRDMWarnings[MAXPLAYERS + 1];
int g_iRDMCountdown;

public void _RDM_CVars() {
	
	gc_bRDM = AutoExecConfig_CreateConVar("sm_murder_rdmprevention", "1", "Enable RDM Prevention?\nThe RDM Prevention system is configured by the 4 CVars below.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iRDMTime = AutoExecConfig_CreateConVar("sm_murder_rdmprevention_time", "10", "The time range (in seconds) for sm_murder_rdmprevention.", FCVAR_NOTIFY, true, 1.0);
	gc_iRDMWarnings = AutoExecConfig_CreateConVar("sm_murder_rdmprevention_warnings", "3", "How many warnings before a player gets kicked for RDM?", FCVAR_NOTIFY);
	gc_iRDMTactic = AutoExecConfig_CreateConVar("sm_murder_rdmprevention_punishment", "1", "The punishment to give when a detective has reached 3/3 warnings.\n0 = Slay. 1 = Kick. 2 = Ban.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	gc_iRDMBan = AutoExecConfig_CreateConVar("sm_murder_rdmprevention_banlength", "60", "If sm_murder_rdmprevention_punishment is set to 2!\nLength of the ban the player receives in minutes.\n0 = Permanent ban.", FCVAR_NOTIFY);
	
}

public void _RDM_OnRoundStart() {
	if(gc_bRDM.IntValue == 1) {
		g_iRDMCountdown = (GetTime() + g_iRDMTimer); // Set the rounds time limit for RDM
		g_iRDMTimer = gc_iRDMTime.IntValue;
	}
}

public void _RDM_OnMapStart() {
	for(int i = 0; i < sizeof(g_iRDMWarnings); i++) if(g_iRDMWarnings[i] != 0) g_iRDMWarnings[i] = 0; // Reset warnings on map start
}

public void _RDM_OnTakeDamage(int victim, int attacker) {
	
	if(g_iRDMCountdown > GetTime() && gc_bRDM.IntValue == 1) { // If kill happens whithin the time limit with RDM Prevention enabled
		if(IsValidClient(victim) && IsValidClient(attacker)) {
			if(!IsMurderer(attacker)) {
				
				if(g_iRDMWarnings[attacker] < gc_iRDMWarnings.IntValue) { // Player does not have full warnings
					g_iRDMWarnings[attacker]++;
					CPrintToChat(attacker, "%s %t", g_sPrefix, "Player Warned RDM", g_iRDMWarnings[attacker], gc_iRDMWarnings.IntValue);
					
				} else { // Player has gotten too many warnings
					if(gc_iRDMTactic.IntValue == 0) {
						ForcePlayerSuicide(attacker);
						CPrintToChat(attacker, "%s %t", g_sPrefix, "Slain by RDM Prevention");
					}
					
					if(gc_iRDMTactic.IntValue == 1)
						KickClient(attacker, "RDM Prevention");
					
					if(gc_iRDMTactic.IntValue == 2)
						BanClient(attacker, gc_iRDMBan.IntValue, BANFLAG_AUTHID|BANFLAG_AUTO, "Banned by RDM Prevention", "Banned by RDM Prevention", _, attacker);
					
				}
				
			}
		}
	}
}