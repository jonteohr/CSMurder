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

// Strings
char g_sNames[][26] = {
	"Alfa",
	"Bravo",
	"Charlie",
	"Delta",
	"Echo",
	"Foxtrot",
	"Golf",
	"Hotel",
	"India",
	"Juliett",
	"Kilo",
	"Lima",
	"Mike",
	"November",
	"Oscar",
	"Papa",
	"Quebec",
	"Romeo",
	"Sierra",
	"Tango",
	"Uniform",
	"Victor",
	"Whiskey",
	"XRay",
	"Yankee",
	"Zulu"
};

char g_iNameTaken[26];

public void _Names_CVars() {
	gc_bNames = AutoExecConfig_CreateConVar("sm_murder_names", "1", "Set each players name to a random phonetic name?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void _Names_OnRoundStart() {
	for(int i = 0; i < sizeof(g_iNameTaken); i++) if(g_iNameTaken[i] != 0) g_iNameTaken[i] = 0; // Reset reservations
	for(int i = 1; i <= MaxClients; i++) {
		if(gc_bNames.IntValue != 1)
			break;
		if(!IsValidClient(i))
			continue;
		SetName(i);
	}
}

public void SetName(int client) {
	int iName = GetRandomInt(0, 25);
	
	if(g_iNameTaken[iName] == 0) { // Name is not taken
		g_iNameTaken[iName] = 1;
		SetClientName(client, g_sNames[iName]);
	} else { // Someone has this name, redo the cycle
		SetName(client);
	}
}