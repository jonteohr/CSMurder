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
 
public void _Hint_OnMapStart() {
	CreateTimer(0.5, HintTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action HintTimer(Handle timer) {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		char sName[64];
		GetClientName(i, sName, sizeof(sName));
		
		char sMessage[128];
		
		if(g_iColor[i] == PINK)
			Format(sMessage, sizeof(sMessage), "<font size='24' color='#ff6699'>%s</font>", sName);
		if(g_iColor[i] == GREEN)
			Format(sMessage, sizeof(sMessage), "<font size='24' color='#99cc00'>%s</font>", sName);
		if(g_iColor[i] == BLUE)
			Format(sMessage, sizeof(sMessage), "<font size='24' color='#3399ff'>%s</font>", sName);
		if(g_iColor[i] == ORANGE)
			Format(sMessage, sizeof(sMessage), "<font size='24' color='#ff9933'>%s</font>", sName);
		if(g_iColor[i] == TEAL)
			Format(sMessage, sizeof(sMessage), "<font size='24' color='#00ff99'>%s</font>", sName);
		if(g_iColor[i] == RED)
			Format(sMessage, sizeof(sMessage), "<font size='24' color='#ff4d4d'>%s</font>", sName);
		
		PrintHintText(i, "%s", sMessage);
	}
}