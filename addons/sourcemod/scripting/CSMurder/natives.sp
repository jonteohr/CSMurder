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


////////////////////////////////////////
//				INTERNAL
////////////////////////////////////////

public void GetWeaponClassname(int weapon, char[] buffer, int size) {
	if(weapon != -1) {
		switch(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")) {
			case 60: Format(buffer, size, "weapon_m4a1_silencer");
			case 61: Format(buffer, size, "weapon_usp_silencer");
			case 63: Format(buffer, size, "weapon_cz75a");
			case 64: Format(buffer, size, "weapon_revolver");
			default: GetEntityClassname(weapon, buffer, size);
		}
	}
}

public void SetPistolMag(int client, int iMag) {
	int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	
	if(iWeapon != -1) {
		SetEntProp(iWeapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 1);
	}
}

public void SetPistolAmmo(int client, int iAmmo) {
	int iWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	
	if(iWeapon != -1) {
		SetEntProp(iWeapon, Prop_Data, "m_iClip1", 0);
	}
}

public void SetPistolSpawn(int client) {
	int iWeap = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if(iWeap != -1) {
		SetEntProp(iWeap, Prop_Send, "m_iPrimaryReserveAmmoCount", 1);
		SetEntProp(iWeap, Prop_Send, "m_iSecondaryReserveAmmoCount", 0);
		SetEntProp(iWeap, Prop_Data, "m_iClip1", 0);
	}
}

////////////////////////////////////////
//				EXTERNAL
////////////////////////////////////////

public int Native_SetClientMurderer(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	g_iMurderer = client;
	g_iRoleSet[client] = 1;
	Client_RemoveAllWeapons(client);
	GivePlayerItem(client, "weapon_knife");
	GivePlayerItem(client, "weapon_decoy");
	
	CPrintToChat(client, "");
	CPrintToChat(client, "{red}---------------------------------------------------");
	CPrintToChat(client, "");
	CPrintToChat(client, "%s %t", g_sPrefix, "You are Murderer");
	CPrintToChat(client, "%s %t", g_sPrefix, "Murderer Objective");
	CPrintToChat(client, "");
	CPrintToChat(client, "{red}---------------------------------------------------");
	
	Call_StartForward(gF_OnMurdererCreated);
	Call_PushCell(client);
	Call_Finish();
	
	return true;
}

public int Native_SetClientBystander(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	g_iBystander[client] = 1; // 1 = Bystander. 0 = Not a bystander.
	g_iRoleSet[client] = 1;
	Client_RemoveAllWeapons(client);
	GivePlayerItem(client, "weapon_decoy");
	
	CPrintToChat(client, "");
	CPrintToChat(client, "{darkblue}---------------------------------------------------");
	CPrintToChat(client, "");
	CPrintToChat(client, "%s %t", g_sPrefix, "You are Bystander");
	CPrintToChat(client, "%s %t", g_sPrefix, "Bystander Objective");
	CPrintToChat(client, "");
	CPrintToChat(client, "{darkblue}---------------------------------------------------");
	
	return true;
}

public int Native_SetClientDetective(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	g_iDetective = client;
	g_iRoleSet[client] = 1;
	Client_RemoveAllWeapons(client);
	
	char sBuffer[64];
	GetConVarString(gc_sWeapon, sBuffer, sizeof(sBuffer));
	GivePlayerItem(client, sBuffer);
	g_iPistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	RequestFrame(SetPistolSpawn, client);
	GivePlayerItem(client, "weapon_decoy");
	
	CPrintToChat(client, "");
	CPrintToChat(client, "{darkblue}---------------------------------------------------");
	CPrintToChat(client, "");
	CPrintToChat(client, "%s %t", g_sPrefix, "You are Detective");
	CPrintToChat(client, "%s %t", g_sPrefix, "Detective Objective");
	CPrintToChat(client, "");
	CPrintToChat(client, "{darkblue}---------------------------------------------------");
	
	Call_StartForward(gF_OnDetectiveCreated);
	Call_PushCell(client);
	Call_Finish();
	
	return true;
}

public int Native_IsBystander(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	if(g_iBystander[client] != 1 || g_iDetective == client || g_iMurderer == 1)
		return false;
	
	return true;
}

public int Native_IsMurderer(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	if(g_iMurderer != client || g_iDetective == client || g_iBystander[client] == 1)
		return false;
		
	return true;
}

public int Native_IsDetective(Handle plugin, int numParams) {
	int client = GetNativeCell(1);
	
	if(g_iBystander[client] == 1 || g_iDetective != client || g_iMurderer == 1)
		return false;
	
	return true;
}