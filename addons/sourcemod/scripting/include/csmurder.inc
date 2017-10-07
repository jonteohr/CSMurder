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

char g_sBystanderOverlay[PLATFORM_MAX_PATH];
char g_sDetectiveOverlay[PLATFORM_MAX_PATH];
char g_sMurdererOverlay[PLATFORM_MAX_PATH];

int g_iColor[MAXPLAYERS +1];

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
* Show a menu with name and color of the client.
*
* @param client			Entity client index
* @return				true if successful
* @error				Invalid client index, client not in game.
*/
stock bool ShowUI(int client) {
	if(g_iColor[client] == PINK) {
		
	}
	if(g_iColor[client] == GREEN) {
		
	}
	if(g_iColor[client] == BLUE) {
	
	}
	if(g_iColor[client] == ORANGE) {
	
	}
	if(g_iColor[client] == TEAL) {
	
	}
	if(g_iColor[client] == RED) {
		
	}
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
* Kills timer
*
* @param timer			Handle to the timer
* @return				true if successful
* @error				Invalid timer handle
*/
stock bool ClearTimer(Timer &timer) {
	if(timer != null) {
		delete timer;
		timer = null;
		return true;
	}
	return false;
}