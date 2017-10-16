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

int g_iMurderLevel;

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
	CreateTimer(0.5, HintTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void _Overlay_OnRoundStart() {
	
	CreateTimer(4.0, OverlayTimer);
	g_iMurderLevel = SQL_GetUserLevel(g_iMurderer);
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
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		ShowRoleOverlay(i, OVERLAY_NONE); // Remove it
	}
}

public Action HintTimer(Handle timer) {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		char sName[64];
		GetClientName(i, sName, sizeof(sName));
		
		char sHex[128];
		
		if(g_iColor[i] == PINK)
			Format(sHex, sizeof(sHex), "#ff6699");
		if(g_iColor[i] == GREEN)
			Format(sHex, sizeof(sHex), "#99cc00");
		if(g_iColor[i] == BLUE)
			Format(sHex, sizeof(sHex), "#3399ff");
		if(g_iColor[i] == ORANGE)
			Format(sHex, sizeof(sHex), "#ff9933");
		if(g_iColor[i] == TEAL)
			Format(sHex, sizeof(sHex), "#00ff99");
		if(g_iColor[i] == RED)
			Format(sHex, sizeof(sHex), "#ff4d4d");
		
		if(IsMurderer(i)) // Murderer special hint
			PrintHintText(i, "<font size='34' color='%s'><b>%s</b></font>\n<font color='#FE4040' size='18'>%t</font>", sHex, sName, "Murder Hint Level", g_iMurderLevel);
			
		PrintHintText(i, "<font size='34' color='%s'><b>%s</b></font>", sHex, sName);
	}
}