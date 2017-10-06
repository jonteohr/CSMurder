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

public void _Overlay_CVars() {
	gc_sMurdererOverlay = AutoExecConfig_CreateConVar("sm_murder_overlay_murderer", "overlays/murder/murderer", "The path inside the /materials/ folder to the overlay for the murderer.\nDo no include file extensions!", FCVAR_NOTIFY);
	gc_sDetectiveOverlay = AutoExecConfig_CreateConVar("sm_murder_overlay_detective", "overlays/murder/detective", "The path inside the /materials/ folder to the overlay for the detective.\nDo no include file extensions!", FCVAR_NOTIFY);
	gc_sBystanderOverlay = AutoExecConfig_CreateConVar("sm_murder_overlay_bystander", "overlays/murder/bystander", "The path inside the /materials/ folder to the overlay for the bystanders.\nDo no include file extensions!", FCVAR_NOTIFY);
}

public void _Overlay_OnPluginStart() { // Set overlay paths according to the config
	GetConVarString(gc_sMurdererOverlay, g_sMurdererOverlay, sizeof(g_sMurdererOverlay));
	GetConVarString(gc_sBystanderOverlay, g_sBystanderOverlay, sizeof(g_sBystanderOverlay));
	GetConVarString(gc_sDetectiveOverlay, g_sDetectiveOverlay, sizeof(g_sDetectiveOverlay));
}

public void _Overlay_OnMapStart() {
	DownloadCacheOverlay(g_sMurdererOverlay);
	DownloadCacheOverlay(g_sBystanderOverlay);
	DownloadCacheOverlay(g_sDetectiveOverlay);
}

public void _Overlay_OnRoundStart() {
	int iEndTime = (GetTime() + 4);
	
	CreateTimer(1.0, OverlayTimer, iEndTime, TIMER_REPEAT);
	
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		if(IsMurderer(i))
			ShowRoleOverlay(i, OVERLAY_MURDERER);
		if(IsDetective(i))
			ShowRoleOverlay(i, OVERLAY_DETECTIVE);
		if(IsBystander(i))
			ShowRoleOverlay(i, OVERLAY_BYSTANDER);
	}
}


public Action OverlayTimer(Handle timer, int iEndTime) {
	if(GetTime() <= iEndTime) { // Check if the overlay has been shown for 4 seconds. Then destroy it!
		for(int i = 1; i <= MaxClients; i++) {
			if(!IsValidClient(i))
				continue;
			ShowRoleOverlay(i, OVERLAY_NONE); // Remove it
		}
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}