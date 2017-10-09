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
	gc_iDroppedWeapon = AutoExecConfig_CreateConVar("sm_murder_respawnweapon", "30", "The amount of seconds it takes for the dropped weapon to respawn to a random player", FCVAR_NOTIFY);
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
	
	SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0); // Disable glow
	
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
	char sGun[64];
	
	GetWeaponClassname(iWeapon, sWeapon, sizeof(sWeapon));
	GetConVarString(gc_sWeapon, sGun, sizeof(sGun));
	
	if(!IsValidClient(client))
		return Plugin_Continue;
	
	if(buttons & IN_ATTACK || buttons & IN_ATTACK2) { // Trying to throw decoy
		if(StrEqual(sWeapon, "weapon_decoy")) {
			if(buttons & IN_ATTACK)
				buttons &= ~IN_ATTACK;
			if(buttons & IN_ATTACK2)
				buttons &= ~IN_ATTACK2;
			
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

public void _Hide_OnRoundStart() {
	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i)) {
			SDKHookEx(i, SDKHook_PostThinkPost, OnPostThinkPost);
			SetEntProp(i, Prop_Send, "m_nRenderFX", RENDERFX_NONE);
			SetEntProp(i, Prop_Send, "m_nRenderMode", RENDER_NONE);
		}
	}
	
	int entity = MaxClients+1;
	
	while((entity = FindEntityByClassname(entity, "weaponworldmodel")) != -1 ) {
		SetEntProp(entity, Prop_Send, "m_nModelIndex", 0);
	}
}

public void OnPostThinkPost(int client) {
	//SetEntProp(client, Prop_Send, "m_iPrimaryAddon", CSAddon_NONE);
	SetEntProp(client, Prop_Send, "m_iSecondaryAddon", CSAddon_NONE);
	SetEntProp(client, Prop_Send, "m_iAddonBits", CSAddon_NONE);
}

public void DropWeapon(int client, int weapon) {
	if(weapon != -1) {
		g_iPistol = weapon;
		CS_DropWeapon(client, weapon, true, true);
		CreateTimer(gc_iDroppedWeapon.FloatValue, WeaponRespawner);
		SetEntProp(weapon, Prop_Send, "m_bGlowEnabled", 1);
	}
}

public Action WeaponRespawner(Handle timer) {
	int client = GetRandomBystander();
	
	RemoveEdict(g_iPistol);
	RequestFrame(GiveGunFrame, client);
}

public void GiveGunFrame(int client) {
	char sGun[64];
	GetConVarString(gc_sWeapon, sGun, sizeof(sGun));
	
	GivePlayerItem(client, sGun);
	SetPistolSpawn(client);
}

////////////////////////////////////////
//			MAKE GUN GLOW			  //
////////////////////////////////////////
public void OnEntityCreated(int entity, const char[] classname) {
	char sGun[64]; // The created gun
	char sAllowed[64]; // The gun in config
	GetConVarString(gc_sWeapon, sAllowed, sizeof(sAllowed));
	
	GetWeaponClassname(entity, sGun, sizeof(sGun));
	
	if(StrEqual(sGun, sAllowed, false)) {
		CreateTimer(0.0, makeGlowCb, EntIndexToEntRef(entity));
	}
}

public Action makeGlowCb(Handle Timer, int entityEx) {
    int entity = EntRefToEntIndex(entityEx);
    float fPos[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);
    float fAngles[3];
    GetEntPropVector(entity, Prop_Send, "m_angRotation", fAngles);
    int kitGlow = CreateEntityByName("prop_dynamic_glow");
    DispatchKeyValue(kitGlow, "model", "models/props_docks/cleat_small_01.mdl");
    DispatchKeyValue(kitGlow, "disablereceiveshadows", "1");
    DispatchKeyValue(kitGlow, "disableshadows", "1");
    DispatchKeyValue(kitGlow, "solid", "0");
    DispatchKeyValue(kitGlow, "spawnflags", "256");
    SetEntProp(kitGlow, Prop_Send, "m_CollisionGroup", 11);
    DispatchSpawn(kitGlow);
    SetEntPropFloat(kitGlow, Prop_Send, "m_flModelScale", 2.0);
    TeleportEntity(kitGlow, fPos, fAngles, NULL_VECTOR);
    SetEntProp(kitGlow, Prop_Send, "m_bShouldGlow", true, true);
    SetEntPropFloat(kitGlow, Prop_Send, "m_flGlowMaxDist", 15000000.0);
    SetGlowColor(kitGlow, "0 255 0");
    AcceptEntityInput(kitGlow, "SetGlowColor");
    SetEntPropFloat(kitGlow, Prop_Send, "m_flModelScale", 1.0);
    SetVariantString("!activator");
    AcceptEntityInput(kitGlow, "SetParent", entity);
} 

stock void SetGlowColor(int entity, const char[] color)
{
    char colorbuffers[3][4];
    ExplodeString(color, " ", colorbuffers, sizeof(colorbuffers), sizeof(colorbuffers[]));
    int colors[4];
    for (int i = 0; i < 3; i++)
    colors[i] = StringToInt(colorbuffers[i]);
    colors[3] = 255;
    SetVariantColor(colors);
    AcceptEntityInput(entity, "SetGlowColor");
}  