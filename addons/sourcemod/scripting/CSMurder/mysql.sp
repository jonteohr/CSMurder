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

Handle gH_Db;

public void _MySQL_OnPluginStart() {
	char sErrorBuff[128];
	char sQuery[128];
	
	gH_Db = SQL_Connect("csmurder", true, sErrorBuff, sizeof(sErrorBuff));
	Format(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS csmurder (ID int NOT NULL AUTO_INCREMENT, SteamID varchar(128) NOT NULL, Playtime int, Rank varchar(128), PRIMARY KEY (ID));");
	
	if(gH_Db != null) { // Successfully initialized MySQL connection
		
		Handle SQL = SQL_Query(gH_Db, sQuery); // Send the actual query
		CloseHandle(SQL);
		
	} else { // Couldn't connect to MySQL
		PrintToServer("Couldn't connect to CSMurder Database: %s", sErrorBuff);
	}
}

public bool SQL_IsUserInTable(int client) {
	char SteamID[64];
	char sQuery[128];
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "SELECT * FROM csmurder WHERE SteamID LIKE '%s'", SteamID);
	
	Handle SQL = SQL_Query(gH_Db, sQuery);
	if(SQL != null) {
		if(SQL_FetchRow(SQL))
			return true;
	}
	
	CloseHandle(SQL);
	
	return false;
}

public void SQL_AddUserToTable(int client) {
	char SteamID[64];
	char sQuery[128];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "INSERT INTO csmurder (SteamID, Playtime, Rank) VALUES ('%s', 0, 'Newbie');", SteamID);
	
	SQL_Query(gH_Db, sQuery);
}

public int SQL_GetUserPlaytime(int client) {
	int iPlayTime;
	char SteamID[64];
	char sQuery[128];
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "SELECT PlayTime FROM csmurder WHERE SteamID LIKE '%s'", SteamID);
	
	Handle SQL = SQL_Query(gH_Db, sQuery);
	if(SQL != null) {
		if(SQL_FetchRow(SQL)) {
			iPlayTime = SQL_FetchInt(SQL, 0);
			
			return iPlayTime;
		}
	}
	
	CloseHandle(SQL);
	
	return false; // something went wrong
}

public void SQL_SetUserPlaytime(int client, int playtime) {
	char SteamID[64];
	char sQuery[128];
	
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	Format(sQuery, sizeof(sQuery), "UPDATE csmurder SET Playtime = %d WHERE SteamID LIKE '%s'", playtime, SteamID);
	
	SQL_Query(gH_Db, sQuery);
}