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
 
int g_iMurderer = -1;
int g_iBystander[MAXPLAYERS + 1];
int g_iDetective = -1;
int g_iRoleSet[MAXPLAYERS +1];

public void _Roles_OnRoundStart() {
	ResetRoles(); // Reset all roles before doing anything
	
	SetMurderer(); // Set a random murderer
	SetDetective();
	SetBystanders(); // Set the rest as bystanders
 }

public void ResetRoles() {
	for(int i = 0; i < sizeof(g_iBystander); i++) if(g_iBystander[i] != 0) g_iBystander[i] = 0; // Reset bystanders
	for(int i = 0; i < sizeof(g_iRoleSet); i++) if(g_iRoleSet[i] != 0) g_iRoleSet[i] = 0;
	
	g_iMurderer = -1; // Reset the murderer
	g_iDetective = -1; // Reset detective
	
}

public void SetMurderer() {
	int murderer = GetRandomPlayer(); // Get a random online player
	
	if(IsValidClient(murderer) && g_iDetective != murderer && g_iBystander[murderer] != 1) {
		SetClientMurderer(murderer);
	}
}

public void SetBystanders() {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		if(g_iRoleSet[i] == 1)
			continue;
		
		if(g_iMurderer == -1) { // Making sure no role ends up empty
			SetClientMurderer(i);
		} else if(g_iDetective == -1) { // Making sure no role ends up empty
			SetClientDetective(i);
		} else {
			SetClientBystander(i);
		}
	}
}

public void SetDetective() {
	int iDetective = GetRandomPlayer();
	
	if(IsValidClient(iDetective) && g_iMurderer != iDetective && g_iBystander[iDetective] != 1) {
		SetClientDetective(iDetective);
	}
}