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

public void _Settings_CVars() {
	gc_bSettings = AutoExecConfig_CreateConVar("sm_murder_settings", "1", "Allow the plugin to set the game settings automatically?\nThis will override conflicting settings in server.cfg!", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void _Settings_OnMapStart() {
	if(gc_bSettings.IntValue == 1) {
		// Ints
		SetConVarInt(FindConVar("mp_friendlyfire"), 1, true, true);
		SetConVarInt(FindConVar("mp_autokick"), 0, true, true);
		SetConVarInt(FindConVar("mp_teammates_are_enemies"), 1, true, true);
		SetConVarInt(FindConVar("mp_buytime"), 0, true, true);
		SetConVarInt(FindConVar("mp_freezetime"), 0, true, true);
		SetConVarInt(FindConVar("mp_respawn_immunitytime"), 0, true, true);
		SetConVarInt(FindConVar("mp_randomspawn"), 1, true, true);
		SetConVarInt(FindConVar("mp_weapons_glow_on_ground"), 1, true, true);
		SetConVarString(FindConVar("mp_t_default_melee"), "", true, true);
		SetConVarString(FindConVar("mp_t_default_secondary"), "", true, true);
		SetConVarString(FindConVar("mp_ct_default_melee"), "", true, true);
		SetConVarString(FindConVar("mp_ct_default_secondary"), "", true, true);
		
		// Strings
		SetConVarString(FindConVar("sv_server_graphic2"), "materials/murder/graphic.png", true, true);
	}
}

public void _Settings_OnRoundStart() {
	char sClass[64];
	
	for(int i = 0; i <= GetMaxEntities(); i++) { // Remove hostages and bombs
		if(IsValidEntity(i) && IsValidEdict(i)) {
		
			GetEdictClassname(i, sClass, sizeof(sClass));
			if(StrContains("hostage_entity", sClass, false) != -1)
				RemoveEdict(i);
		}
	}
}