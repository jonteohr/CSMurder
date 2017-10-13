/*
* 
* INCLUDE FOR THE SOURCEMOD PLUGIN; CS MURDER
* https://condolent.xyz
* 
*/
#if defined _CSMURDER_included
 #endinput
#endif
#define _CSMURDER_included

#define	OVERLAY_NONE		0
#define	OVERLAY_MURDERER	1
#define	OVERLAY_BYSTANDER	2
#define	OVERLAY_DETECTIVE	3
#define	PINK				0
#define	GREEN				1
#define	BLUE				2
#define	ORANGE				3
#define	TEAL				4
#define	RED					5
#define	CSAddon_NONE				0
#define	CSAddon_Flashbang1			(1<<0)
#define	CSAddon_Flashbang2			(1<<1)
#define	CSAddon_HEGrenade			(1<<2)
#define	CSAddon_SmokeGrenade		(1<<3)
#define	CSAddon_C4					(1<<4)
#define	CSAddon_DefuseKit			(1<<5)
#define	CSAddon_PrimaryWeapon		(1<<6)
#define	CSAddon_SecondaryWeapon		(1<<7)
#define	CSAddon_Holster				(1<<8)

char g_sBystanderOverlay[PLATFORM_MAX_PATH];
char g_sDetectiveOverlay[PLATFORM_MAX_PATH];
char g_sMurdererOverlay[PLATFORM_MAX_PATH];

int g_iColor[MAXPLAYERS +1];
int g_iWeaponCD[MAXPLAYERS + 1];

UserMsg g_FadeUserMsgId;

/**
* Called when a murderer is created
*
* @param murderer		Client index of murderer
*/
forward Action OnMurdererCreated(int murderer);

/**
* Called when a detective is created
*
* @param detective		Client index of detective
*/
forward Action OnDetectiveCreated(int detective);

/**
* Sets the specified entity as a murderer
*
* @param client			Entity client index
* @return				true if successful
* @error				Invalid client index, client not in game.
*/
native bool SetClientMurderer(int client);

/**
* Sets the specified entity as a detective
*
* @param client			Entity client index
* @return				true if successful
* @error				Invalid client index, client not in game.
*/
native bool SetClientDetective(int client);

/**
* Sets the specified entity as a bystander
*
* @param client			Entity client index
* @return				true if successful
* @error				Invalid client index, client not in game.
*/
native bool SetClientBystander(int client);

/**
* Prints a role-specific overlay to the client
*
* @param client			Entity client index
* @param overlay		Precached overlay model
* @return				true if successful
* @error				Invalid client index, client not in game, invalid overlay.
*/
stock bool ShowRoleOverlay(int client, int overlay) {
	if(overlay == OVERLAY_NONE)
		ClientCommand(client, "r_screenoverlay \"\"");
	if(overlay == OVERLAY_BYSTANDER)
		ClientCommand(client, "r_screenoverlay \"%s\"", g_sBystanderOverlay);
	if(overlay == OVERLAY_DETECTIVE)
		ClientCommand(client, "r_screenoverlay \"%s\"", g_sDetectiveOverlay);
	if(overlay == OVERLAY_MURDERER)
		ClientCommand(client, "r_screenoverlay \"%s\"", g_sMurdererOverlay);
	
	return true;
}

/**
* Checks if the client is a bystander
*
* @param client			Entity client index
* @return				true if yes
* @error				Invalid client index, client not in game.
*/
native bool IsBystander(int client);

/**
* Checks if the client is a detective
*
* @param client			Entity client index
* @return				true if yes
* @error				Invalid client index, client not in game.
*/
native bool IsDetective(int client);

/**
* Checks if the client is a murderer
*
* @param client			Entity client index
* @return				true if yes
* @error				Invalid client index, client not in game.
*/
native bool IsMurderer(int client);

/**
* Checks several parameters to see if the specified client is a valid user.
*
* @param client 		Client index
* @param bAllowBots		Allow bots? (Default = false)
* @param bAllowDead		Allow dead? (Default = false)
* @return				true if valid
* @error				Invalid client index, client not in game.
*/
stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = false)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

/**
* Downloads and precaches overlays
*
* @param szMaterial		Path to the overlay-file.
						Do not include file names!
*/
stock bool DownloadCacheOverlay(char[] szMaterial = "") {
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", szMaterial);
	AddFileToDownloadsTable(sBuffer);
	PrecacheModel(sBuffer, true);
	Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", szMaterial);
	AddFileToDownloadsTable(sBuffer);
	PrecacheModel(sBuffer, true);
}

/**
* Get a random alive player in any team
*
* @return				A random client
*/
stock int GetRandomPlayer() {
	int[] clients = new int[MaxClients];
	int clientCount;
	
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i))	{
		clients[clientCount++] = i;
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

/**
* Get a random alive bystander without a cooldown
*
* @param Bypass			Set to true to bypass weapon cooldown
* @return				A random client index
*/
stock int GetRandomBystander(bool Bypass = false) {
	int[] clients = new int[MaxClients];
	int clientCount;
	
	for (int i = 1; i <= MaxClients; i++) {
		if(Bypass == false) {
			if(IsValidClient(i) && !IsMurderer(i) && g_iWeaponCD[i] < GetTime()) {
				clients[clientCount++] = i;
			}
		} else {
			if(IsValidClient(i) && !IsMurderer(i)) {
				clients[clientCount++] = i;
			}
		}
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

/**
* Blinds a player
*
* @param target			Client entity index of target
* @param amount			Amount (0-255)
*/
stock void PerformBlind(int target, int amount) {
	if(IsClientInGame(target)) {
		int targets[2];
		targets[0] = target;
		
		int color[4] = { 0, 0, 0, 0 };
		color[0] = 0;
		color[1] = 0;
		color[2] = 0;
		color[3] = amount;
		
		int flags;
		if (amount == 0)
			flags = (0x0001 | 0x0010);
		else
			flags = (0x0002 | 0x0008);

		Handle message = StartMessageEx(g_FadeUserMsgId, targets, 1);
		
		if (GetUserMessageType() == UM_Protobuf)
		{
			PbSetInt(message, "duration", 768);
			PbSetInt(message, "hold_time", 1536);
			PbSetInt(message, "flags", flags);
			PbSetColor(message, "clr", color);
		}
		else
		{
			BfWriteShort(message, 768);
			BfWriteShort(message, 1536);
			BfWriteShort(message, flags);
			BfWriteByte(message, color[0]);
			BfWriteByte(message, color[1]);
			BfWriteByte(message, color[2]);
			BfWriteByte(message, color[3]);
		}

		EndMessage();
	}
}

/**
* Updates the specified clients' playtime
*
* @param client			Entity client index
* @return				true if successful
* @error				Client is not in the database
*/
stock bool UpdateClientPlaytime(int client) {
	if(!SQL_IsUserInTable(client))
		return false;
	
	int oldTime = SQL_GetUserPlaytime(client);
	int newTime = (oldTime - GetTime());
	SQL_SetUserPlaytime(client, newTime);
	
	return true;
}