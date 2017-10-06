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
char g_sNames[][12] = {
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
	"Lima"
};

public void _Names_CVars() {
	gc_bNames = AutoExecConfig_CreateConVar("sm_murder_names", "1", "Set each players name to a random phonetic name?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void _Names_OnRoundStart() {
	for(int i = 1; i <= MaxClients; i++) {
		if(gc_bNames.IntValue != 1)
			break;
		if(!IsValidClient(i))
			continue;
		int iName = GetRandomInt(0, 11);
		SetClientName(i, g_sNames[iName]);
	}
}