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

float de_dust2[12][3] = {
	{
		696.450317,
		2239.525391,
		-66.666924
	},
	{
		1109.653931,
		2966.479736,
		132.124969
	},
	{
		374.724152,
		2264.280518,
		96.031250
	},
	{
		21.935041,
		1481.415894,
		0.031250
	},
	{
		-390.020660,
		724.545898,
		3.107464
	},
	{
		-825.133362,
		2181.989990,
		-100.872215
	},
	{
		-2006.598511,
		2632.601563,
		32.031250
	},
	{
		198.431854,
		2487.502686,
		-126.968750
	},
	{
		-1050.146851,
		1476.782104,
		-111.968750
	},
	{
		271.672791,
		337.861450,
		8.709747
	},
	{
		258.941681,
		-829.953613,
		13.721905
	},
	{
		-1634.060669,
		-525.585938,
		133.755371
	}
};

float de_safehouse[12][3] = {
	{
		696.450317,
		2239.525391,
		-66.666924
	},
	{
		1109.653931,
		2966.479736,
		132.124969
	},
	{
		374.724152,
		2264.280518,
		96.031250
	},
	{
		21.935041,
		1481.415894,
		0.031250
	},
	{
		-390.020660,
		724.545898,
		3.107464
	},
	{
		-825.133362,
		2181.989990,
		-100.872215
	},
	{
		-2006.598511,
		2632.601563,
		32.031250
	},
	{
		198.431854,
		2487.502686,
		-126.968750
	},
	{
		-1050.146851,
		1476.782104,
		-111.968750
	},
	{
		271.672791,
		337.861450,
		8.709747
	},
	{
		258.941681,
		-829.953613,
		13.721905
	},
	{
		-1634.060669,
		-525.585938,
		133.755371
	}
};
	
int g_iSpawnedLoc[12];

public void _Spawns_OnRoundStart() {
	
	for(int i = 0; i < sizeof(g_iSpawnedLoc); i++) if(g_iSpawnedLoc[i] != 0) g_iSpawnedLoc[i] = 0;
	
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		SpawnClient(i);
	}
}

public void SpawnClient(int client) {
	int iSpawn = GetRandomInt(0, 11);
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	
	if(g_iSpawnedLoc[iSpawn] == 0) { // If nobody has spawned here yet
		g_iSpawnedLoc[iSpawn] = 1;
		
		if(StrEqual(sMap, "de_dust2", false))
			TeleportEntity(client, de_dust2[iSpawn], NULL_VECTOR, NULL_VECTOR);
		if(StrEqual(sMap, "de_safehouse", false))
			TeleportEntity(client, de_safehouse[iSpawn], NULL_VECTOR, NULL_VECTOR);
	} else { // Someone has already spawned at the point, get a new one!
		SpawnClient(client); // Redo the cycle
	}
}