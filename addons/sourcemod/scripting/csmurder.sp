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

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colorvariables>
#include <csmurder>
#include <autoexecconfig>
#include <smlib>
#include <emitsoundany>
#undef REQUIRE_PLUGIN
#include <adminmenu>
#include <updater>

// Compiler options
#pragma semicolon 1
#pragma newdecls required

// Global defs
#define	PLUGIN_VERSION				"Beta 0.3.5"
#define	SERVERTAG					"Murder"
#define	UPDATE_URL					"http://csmurder.net/updater/updater.txt"

// Integers
int g_iDroppedWep = -1;

// Strings
char g_sPrefix[128];

// Console Variables
ConVar gc_sWeapon;
ConVar gc_iWeaponCD;
ConVar gc_sMurdererOverlay;
ConVar gc_sDetectiveOverlay;
ConVar gc_sBystanderOverlay;
ConVar gc_bServerTag;
ConVar gc_sChatTag;
ConVar gc_bSettings;
ConVar gc_bSmoke;
ConVar gc_iSmokeTimer;
ConVar gc_bRDM;
ConVar gc_iRDMTime;
ConVar gc_iRDMWarnings;
ConVar gc_iRDMTactic;
ConVar gc_iRDMBan;
ConVar gc_bNames;
ConVar gc_bMinPlayers;
ConVar gc_iMinPlayers;
ConVar gc_iBlind;
ConVar gc_iDroppedWeapon;

// Handles
Handle gF_OnMurdererCreated;
Handle gF_OnDetectiveCreated;

// Modules
#include "CSMurder/roles.sp"
#include "CSMurder/natives.sp"
#include "CSMurder/roundsettings.sp"
#include "CSMurder/overlays.sp"
#include "CSMurder/deaths.sp"
#include "CSMurder/weapons.sp"
#include "CSMurder/sounds.sp"
#include "CSMurder/colors.sp"
#include "CSMurder/tags.sp"
#include "CSMurder/rdmprevention.sp"
#include "CSMurder/adminmenu.sp"
#include "CSMurder/names.sp"
#include "CSMurder/smoke.sp"
#include "CSMurder/players.sp"

public Plugin myinfo = {
	name = "[CS:GO] Murder",
	author = "Hypr",
	description = "A recreation of the GMOD Murder mod, but for CS:GO.",
	version = PLUGIN_VERSION,
	url = "http://csmurder.net"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	if (GetEngineVersion() != Engine_CSGO) { // Make sure that the server is a CS:GO server
		SetFailState("Game is not supported. CS:GO ONLY!");
	}
	
	gF_OnMurdererCreated = CreateGlobalForward("OnMurdererCreated", ET_Event, Param_Cell);
	gF_OnDetectiveCreated = CreateGlobalForward("OnDetectiveCreated", ET_Event, Param_Cell);
	
	CreateNative("SetClientMurderer", Native_SetClientMurderer);
	CreateNative("SetClientDetective", Native_SetClientDetective);
	CreateNative("SetClientBystander", Native_SetClientBystander);
	CreateNative("IsBystander", Native_IsBystander);
	CreateNative("IsDetective", Native_IsDetective);
	CreateNative("IsMurderer", Native_IsMurderer);

	RegPluginLibrary("csmurder");
	
	return APLRes_Success;
}

public void OnPluginStart() {
	LoadTranslations("csmurder.phrases.txt");
	SetGlobalTransTarget(LANG_SERVER);
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd);
	HookEvent("weapon_fire", OnWeaponFire, EventHookMode_Post);
	HookEvent("item_equip", OnItemEquip, EventHookMode_Post);
	
	AutoExecConfig_SetFile("murder"); // Locate the config
	AutoExecConfig_SetCreateFile(true); // Create the config if it does not exist
	
	AutoExecConfig_CreateConVar("sm_murder_version", PLUGIN_VERSION, "The running version of the plugin.\nDebugging only, do not change this!", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	gc_sChatTag = AutoExecConfig_CreateConVar("sm_murder_chattag", "Murder", "The prefix for messages in chat.", FCVAR_NOTIFY);
	
	_Weapons_CVars();
	_Smoke_CVars();
	_RDM_CVars();
	_Players_CVars();
	_Names_CVars();
	_Deaths_CVars();
	_Tags_CVars();
	_Settings_CVars();
	_Overlay_CVars();
	
	AutoExecConfig_ExecuteFile(); // Execute the config
	AutoExecConfig_CleanFile(); // Clean the config from spaces etc.
	
	_Overlay_OnPluginStart();
	_Tags_OnPluginStart();
	
	/* Setting chat Prefix */
	char sPrefix[64];
	char sFormat[128];
	GetConVarString(gc_sChatTag, sPrefix, sizeof(sPrefix));
	Format(sFormat, sizeof(sFormat), "[{red}%s{default}] ", sPrefix);
	g_sPrefix = sFormat;
	
	/* Updater stuff */
	if(LibraryExists("updater")) { // Check for updates if updater.smx exists
		Updater_AddPlugin(UPDATE_URL);
		Updater_ForceUpdate();
	}
}

/* More updater stuff */
public void OnLibraryAdded(const char[] name) {
	if(StrEqual(name, "updater")) { // Check for updates if updater.smx exists
		Updater_AddPlugin(UPDATE_URL);
		Updater_ForceUpdate();
	}
}

////////////////////////////////////////
//				EVENTS
////////////////////////////////////////

public void OnMapStart() {
	_Settings_OnMapStart(); // Set game settings
	_Overlay_OnMapStart(); // Overlay downloads etc.
	_Sounds_OnMapStart(); // Sound settings
	_RDM_OnMapStart();
	_Smoke_OnMapStart();
	_Players_OnMapStart();
	
	for(int i = 1; i <= MaxClients; i++) if(IsValidClient(i)) SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamageAlive);
}

public void OnClientPutInServer(int client) {
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageAlive);
	SDKHookEx(client, SDKHook_PostThinkPost, OnPostThinkPost);
	_Players_ClientConnect(client);
}

public void OnClientDisconnect(int client) {
	if(client == g_iMurderer) {
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Died Mysteriously");
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Reveal", client);
		g_iKiller = -1;
		CS_TerminateRound(5.0, CSRoundEnd_Draw);
	}
	
	_Players_ClientDisconnect(client);
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	g_iDroppedWep = -1;
	_Names_OnRoundStart(); // Give phonetic names
	_Roles_OnRoundStart(); // Set roles
	_Overlay_OnRoundStart(); // Set overlay for each role
	_Weapons_OnRoundStart(); // Hooking weapon blocks etc.
	_Colors_OnRoundStart(); // Give players colors
	_RDM_OnRoundStart(); // Set & Reset times
	_Smoke_OnRoundStart(); // Set the timer for when smoke appears
	_Players_OnRoundStart();
	
	for(int i = 1; i <= MaxClients; i++) { // Get online players count
		if(!IsValidClient(i))
			continue;
		
		char sWeapon[64];
		char sGun[64];
		GetConVarString(gc_sWeapon, sGun, sizeof(sGun));
		GetClientWeapon(i, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, sGun)) {
			SetPistolMag(i, 1);
			SetPistolAmmo(i, 0);
		}	
	}
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast) {
	if(g_iMurderer != -1 && IsValidClient(g_iMurderer)) {
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Won");
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Reveal", g_iMurderer);
	}
	_Smoke_OnRoundEnd();
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	_Deaths_OnPlayerDeath(event);
}

public void OnWeaponFire(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	char sWeapon[64];
	char sGun[64];
	
	GetConVarString(gc_sWeapon, sGun, sizeof(sGun));
	GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
	
	if(StrEqual(sWeapon, sGun))
		SetPistolMag(client, 1);
}

public void OnItemEquip(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int Knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	
	char sItem[64];
	char sGun[64];
	
	GetConVarString(gc_sWeapon, sGun, sizeof(sGun));
	GetWeaponClassname(iWeapon, sItem, sizeof(sItem));
	
	_Players_SetSpeed(client, sItem, sGun, Knife);
}