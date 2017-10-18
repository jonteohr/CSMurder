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

Database gH_Db;

public void SQL_OnMapEnd() {
	delete gH_Db; // Close the connection
}

public void _MySQL_OnPluginStart() {
	char sErrorBuff[128];
	char sQuery[255];
	
	gH_Db = SQL_Connect("csmurder", true, sErrorBuff, sizeof(sErrorBuff));
	
	if(gH_Db != null) { // Successfully initialized MySQL connection
		
		Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS csmurder (ID int NOT NULL AUTO_INCREMENT, SteamID varchar(128) NOT NULL, JoinDate int, MurderKills int, MurderLevel int, PRIMARY KEY (ID));");
		
		if(!SQL_FastQuery(gH_Db, sQuery)) {
			char err[255];
			SQL_GetError(gH_Db, err, sizeof(err));
			PrintToServer("error: %s", err);
		}
		
	} else { // Couldn't connect to MySQL
		PrintToServer("### Couldn't connect to CSMurder Database: %s ###", sErrorBuff);
	}
}

public bool SQL_IsUserInTable(int client) {
	char SteamID[64];
	char sQuery[255];
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "SELECT * FROM csmurder WHERE SteamID LIKE '%s'", SteamID);
	
	DBResultSet SQL = SQL_Query(gH_Db, sQuery);
	
	if(SQL != null)
		if(SQL_FetchRow(SQL))
			return true;
	
	CloseHandle(SQL);
	
	return false;
}

public void SQL_AddUserToTable(int client) {
	char SteamID[64];
	char sQuery[255];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "INSERT INTO csmurder (SteamID, JoinDate, MurderKills, MurderLevel) VALUES ('%s', '%d', '0', '0');", SteamID, GetTime());
	
	if(!SQL_FastQuery(gH_Db, sQuery)) {
		char err[255];
		SQL_GetError(gH_Db, err, sizeof(err));
		PrintToServer("Error: %s", err);
	}
}

public int SQL_GetUserJoinDate(int client) {
	int JoinDate;
	char SteamID[64];
	char sQuery[255];
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "SELECT JoinDate FROM csmurder WHERE SteamID LIKE '%s'", SteamID);
	
	DBResultSet SQL = SQL_Query(gH_Db, sQuery);
	if(SQL != null) {
		if(SQL_FetchRow(SQL)) {
			JoinDate = SQL_FetchInt(SQL, 0);
			return JoinDate;
		}
	}
	
	CloseHandle(SQL);
	
	return false; // something went wrong
}

public int SQL_GetUserKills(int client) {
	char SteamID[64];
	char sQuery[255];
	
	int kills;
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "SELECT MurderKills FROM csmurder WHERE SteamID LIKE '%s'", SteamID);
	
	DBResultSet SQL = SQL_Query(gH_Db, sQuery);
	
	if(SQL != null)
		if(SQL_FetchRow(SQL))
			kills = SQL_FetchInt(SQL, 0);
			
	CloseHandle(SQL);
	
	return kills;
}

public void SQL_SetUserKills(int client, int kills) {
	char SteamID[64];
	char sQuery[255];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "UPDATE csmurder SET MurderKills = '%d' WHERE SteamID LIKE '%s';", kills, SteamID);
	
	if(!SQL_FastQuery(gH_Db, sQuery)) {
		char err[255];
		SQL_GetError(gH_Db, err, sizeof(err));
		PrintToServer("Error: %s", err);
	}
}

public int SQL_GetUserLevel(int client) {
	char SteamID[64];
	char sQuery[255];
	
	int level;
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	Format(sQuery, sizeof(sQuery), "SELECT MurderLevel FROM csmurder WHERE SteamID LIKE '%s'", SteamID);
	
	DBResultSet SQL = SQL_Query(gH_Db, sQuery);
	if(SQL != null)
		if(SQL_FetchRow(SQL))
			level = SQL_FetchInt(SQL, 0);
	CloseHandle(SQL);
	
	return level;
}

public void SQL_SetUserLevel(int client, int level) {
	char SteamID[64];
	char sQuery[255];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "UPDATE csmurder SET MurderLevel = '%d' WHERE SteamID LIKE '%s';", level, SteamID);
	if(!SQL_FastQuery(gH_Db, sQuery)) {
		char err[255];
		SQL_GetError(gH_Db, err, sizeof(err));
		PrintToServer("Error: %s", err);
	}
}



///////////////////////////////////
//
//			IMPLEMENTATIONS
//
///////////////////////////////////
public void _MySQL_OnMapStart() {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i, _, true))
			continue;
		
		if(!SQL_IsUserInTable(i)) // Add user to DB if not exists
			SQL_AddUserToTable(i);
	}
}

public void _MySQL_OnClientPutInServer(int client) {
	if(IsValidClient(client, _, true))
		if(!SQL_IsUserInTable(client))
			SQL_AddUserToTable(client);
}