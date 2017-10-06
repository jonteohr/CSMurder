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

public void _Weapons_CVars() {
	gc_sWeapon = AutoExecConfig_CreateConVar("sm_murder_weapon", "weapon_revolver", "The weapon the detective receives.\nMust be a pistol!", FCVAR_NOTIFY);
	gc_iWeaponCD = AutoExecConfig_CreateConVar("sm_murder_cooldown", "15", "The amount of seconds a bystander will be prevented from picking up weapon(s) after killing an innocent.", FCVAR_NOTIFY, true, 1.0);
}

public void _Weapons_OnRoundStart() {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		SDKHook(i, SDKHook_WeaponCanUse, WeaponCanUse);
	}
	
	for(int i = 0; i < sizeof(g_iWeaponCD); i++) g_iWeaponCD[i] = 0; // Reset weapon cooldowns
}

public Action WeaponCanUse(int client, int weapon) {
	char sWeapon[64]; // Weapon that fires this
	GetWeaponClassname(weapon, sWeapon, sizeof(sWeapon));
	
	char sGun[64]; // Allowed weapon
	GetConVarString(gc_sWeapon, sGun, sizeof(sGun));
	
	if(!IsValidClient(client))
		return Plugin_Handled;
		
	if(IsMurderer(client)) { // The murderer cannot pickup any weapons except knife
		if(StrEqual(sWeapon, "weapon_knife") || StrEqual(sWeapon, "weapon_decoy"))
			return Plugin_Continue;
		
		return Plugin_Handled;
	}
	if(!StrEqual(sWeapon, sGun) && !StrEqual(sWeapon, "weapon_decoy")) // Make sure only allowed weapons can be equipped
		return Plugin_Handled;
		
	if(g_iWeaponCD[client] > GetTime()) // Client has a cooldown due to killing innocent
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public void CooldownClient(int client) {
	g_iWeaponCD[client] = (GetTime() + gc_iWeaponCD.IntValue);
}

///////////////////////////
//	DENY THROWING DECOY
///////////////////////////
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2]) {
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	char sWeapon[64];
	
	GetWeaponClassname(iWeapon, sWeapon, sizeof(sWeapon));
	
	if(!IsValidClient(client))
		return Plugin_Continue;
	
	if(StrEqual(sWeapon, "weapon_decoy")) {
		if(buttons & IN_ATTACK)
			buttons &= ~IN_ATTACK;
		if(buttons & IN_ATTACK2)
			buttons &= ~IN_ATTACK2;
		
		return Plugin_Changed;
	}
	
	if(buttons & IN_WEAPON2 && IsDetective(client)) { // Detective swaps to gun
		/* TODO */
	}
	
	if(buttons & IN_GRENADE1) {
		if(IsMurderer(client)) { // Murderer hides knife
			/* TODO */
		}
		
		if(IsDetective(client)) { // Detective hides pistol
			/* TODO */
		}
	}
	
	
	return Plugin_Continue;
}
