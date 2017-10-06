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

public void _Tags_CVars() {
	gc_bServerTag = AutoExecConfig_CreateConVar("sm_murder_servertag", "1", "Automatically add a \"Murder\" tag to your servers sv_tags?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
}

public void _Tags_OnPluginStart() {
	if(gc_bServerTag.IntValue == 1) {
		
		ConVar gc_sTags = FindConVar("sv_tags");
		char sTags[128];
		
		GetConVarString(gc_sTags, sTags, sizeof(sTags));
		
		if(StrContains(sTags, SERVERTAG, false) == -1) {
			char murderTag[64];
			Format(murderTag, sizeof(murderTag), ", %s", SERVERTAG);
			
			StrCat(sTags, sizeof(sTags), murderTag);
			SetConVarString(gc_sTags, sTags);
		}
		
	}
}