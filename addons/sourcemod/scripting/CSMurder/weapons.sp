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
		
		SpawnDummyModel(weapon);
		
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
	g_iPistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	SetPistolSpawn(client);
}

////////////////////////////////////////
//			MAKE GUN GLOW			  //
////////////////////////////////////////

stock char GetDummyModelName(int entity) {
	char dummy_classname[64];
	char dummy_modelname[PLATFORM_MAX_PATH];
	GetEdictClassname(entity, dummy_classname, sizeof(dummy_classname));
	
	if (StrEqual(dummy_classname, "weapon_glock", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_glock18.mdl");
	else if (StrEqual(dummy_classname, "weapon_hkp2000", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_hkp2000.mdl");
	else if (StrEqual(dummy_classname, "weapon_usp_silencer", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_223.mdl");
	else if (StrEqual(dummy_classname, "weapon_deagle", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_deagle.mdl");
	else if (StrEqual(dummy_classname, "weapon_revolver", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_revolver.mdl");
	else if (StrEqual(dummy_classname, "weapon_p250", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_p250.mdl");
	else if (StrEqual(dummy_classname, "weapon_elite", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_elite.mdl");
	else if (StrEqual(dummy_classname, "weapon_tec9", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_tec9.mdl");
	else if (StrEqual(dummy_classname, "weapon_fiveseven", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_fiveseven.mdl");
	else if (StrEqual(dummy_classname, "weapon_cz75a", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_cz_75.mdl");
	else if (StrEqual(dummy_classname, "weapon_famas", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_famas.mdl");
	else if (StrEqual(dummy_classname, "weapon_g3sg1", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_snip_g3sg1.mdl");
	else if (StrEqual(dummy_classname, "weapon_galilar", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_galilar.mdl");
	else if (StrEqual(dummy_classname, "weapon_ak47", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_ak47.mdl");
	else if (StrEqual(dummy_classname, "weapon_aug", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_aug.mdl");
	else if (StrEqual(dummy_classname, "weapon_m249", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_mach_m249.mdl");
	else if (StrEqual(dummy_classname, "weapon_m4a1", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_m4a1.mdl");
	else if (StrEqual(dummy_classname, "weapon_m4a1_silencer", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_m4a1_s.mdl");
	else if (StrEqual(dummy_classname, "weapon_mac10", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_smg_mac10.mdl");
	else if (StrEqual(dummy_classname, "weapon_mag7", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_shot_mag7.mdl");
	else if (StrEqual(dummy_classname, "weapon_mp7", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_smg_mp7.mdl");
	else if (StrEqual(dummy_classname, "weapon_mp9", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_smg_mp9.mdl");
	else if (StrEqual(dummy_classname, "weapon_negev", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_mach_negev.mdl");
	else if (StrEqual(dummy_classname, "weapon_nova", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_shot_nova.mdl");
	else if (StrEqual(dummy_classname, "weapon_bizon", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_smg_bizon.mdl");
	else if (StrEqual(dummy_classname, "weapon_p90", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_smg_p90.mdl");
	else if (StrEqual(dummy_classname, "weapon_sawedoff", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_shot_sawedoff.mdl");
	else if (StrEqual(dummy_classname, "weapon_scar20", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_snip_scar20.mdl");
	else if (StrEqual(dummy_classname, "weapon_sg556", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_rif_sg556.mdl");
	else if (StrEqual(dummy_classname, "weapon_smokegrenade", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_smokegrenade.mdl");
	else if (StrEqual(dummy_classname, "weapon_ssg08", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_snip_ssg08.mdl");
	else if (StrEqual(dummy_classname, "weapon_ump45", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_smg_ump45.mdl");
	else if (StrEqual(dummy_classname, "weapon_xm1014", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_shot_xm1014.mdl");
	else if (StrEqual(dummy_classname, "weapon_awp", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_snip_awp.mdl");
	else if (StrEqual(dummy_classname, "weapon_taser", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_taser.mdl");
	else if (StrEqual(dummy_classname, "weapon_hegrenade", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_fraggrenade.mdl");
	else if (StrEqual(dummy_classname, "weapon_decoy", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_decoy.mdl");
	else if (StrEqual(dummy_classname, "weapon_flashbang", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_flashbang.mdl");
	else if (StrEqual(dummy_classname, "weapon_incgrenade", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_incendiarygrenade.mdl");
	else if (StrEqual(dummy_classname, "weapon_molotov", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_molotov.mdl");
	else if (StrEqual(dummy_classname, "weapon_knife", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_knife_default_ct.mdl");
	else if (StrEqual(dummy_classname, "weapon_healthshot", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_healthshot.mdl");
	else if (StrEqual(dummy_classname, "weapon_tagrenade", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_eq_sensorgrenade.mdl");
	else if(StrEqual(dummy_classname, "weapon_c4", false))
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_c4_planted.mdl");
	else
		FormatEx(dummy_modelname, sizeof(dummy_modelname), "models/weapons/w_pist_elite.mdl");
	
	return dummy_modelname;
}
 
stock void SpawnDummyModel(int index) {
	if(IsValidEntity(entArray[index][ent_dummy_weapon]))
		return;
	
	float origin[3];
	GetEntPropVector(entArray[index][ent_weaponid], Prop_Send, "m_vecOrigin", origin);
	entArray[index][ent_dummy_weapon] = CreateEntityByName("prop_dynamic_glow");
	if (entArray[index][ent_dummy_weapon] == -1) return;
	DispatchKeyValue(entArray[index][ent_dummy_weapon], "model", GetDummyModelName(entArray[index][ent_weaponid]));
	DispatchKeyValue(entArray[index][ent_dummy_weapon], "disablereceiveshadows", "1");
	DispatchKeyValue(entArray[index][ent_dummy_weapon], "disableshadows", "1");
	DispatchKeyValue(entArray[index][ent_dummy_weapon], "solid", "0");
	DispatchKeyValue(entArray[index][ent_dummy_weapon], "spawnflags", "256");
	SetEntProp(entArray[index][ent_dummy_weapon], Prop_Send, "m_CollisionGroup", 11);
	DispatchSpawn(entArray[index][ent_dummy_weapon]);
	TeleportEntity(entArray[index][ent_dummy_weapon], origin, NULL_VECTOR, NULL_VECTOR);
	SetEntProp(entArray[index][ent_dummy_weapon], Prop_Send, "m_bShouldGlow", true, true);
	SetEntPropFloat(entArray[index][ent_dummy_weapon], Prop_Send, "m_flGlowMaxDist", 10000000.0);
	SetGlowColor(entArray[index][ent_dummy_weapon], "255 50 150");
	SetVariantString("!activator");
	AcceptEntityInput(entArray[index][ent_dummy_weapon], "SetParent", entArray[index][ent_weaponid]);
}
 
stock void SetGlowColor(int entity, const char[] color) {
	char colorbuffers[3][4];
	ExplodeString(color, " ", colorbuffers, sizeof(colorbuffers), sizeof(colorbuffers[]));
	int colors[4];
	for (int i = 0; i < 3; i++)
		colors[i] = StringToInt(colorbuffers[i]);
	colors[3] = 255; // Set alpha
	SetVariantColor(colors);
	AcceptEntityInput(entity, "SetGlowColor");
}