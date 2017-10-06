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

// Integers
int g_iSmoke = -1;
bool g_bSmoking;

// Handles
Handle myTimer;

public void _Smoke_CVars() {
	gc_bSmoke = AutoExecConfig_CreateConVar("sm_murder_smoke", "1", "Create dark smoke around the murderer if he/she has not killed anyone in the time specified in sm_murder_smoke_timer?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iSmokeTimer = AutoExecConfig_CreateConVar("sm_murder_smoke_timer", "180", "The time in seconds it takes before the murderer starts smoking.", FCVAR_NOTIFY, true, 0.0);
}

public void _Smoke_OnMapStart() {
	if(gc_bSmoke.IntValue == 1)
		PrecacheModel("materials/sprites/smoke.vmt");
}

public void _Smoke_OnRoundStart() {
	if(gc_bSmoke.IntValue == 1) {
		g_bSmoking = false;
		
		if(myTimer != null)
			KillTimer(myTimer);
			
		myTimer = CreateTimer(gc_iSmokeTimer.FloatValue, SmokeCheckTimer);
	}
}

public void _Smoke_OnRoundEnd() {
	if(gc_bSmoke.IntValue == 1) {
		g_bSmoking = false;
	}
}

public void _Smoke_OnPlayerDeath() { // Murderer killed somebody
	if(gc_bSmoke.IntValue == 1) {
		
		if(myTimer != null) {
			KillTimer(myTimer);
			myTimer = CreateTimer(gc_iSmokeTimer.FloatValue, SmokeCheckTimer);
		}
		
	}
}

public void ExecSmoke() {
	if(IsValidClient(g_iMurderer)) {
		g_bSmoking = true;
		CPrintToChat(g_iMurderer, "%s %t", g_sPrefix, "Client Smoking");
		
		CreateTimer(0.3, SmokeTimer, _, TIMER_REPEAT);
	}
}

/////////////////////
//		TIMERS
/////////////////////
public Action SmokeCheckTimer(Handle timer) {
	ExecSmoke();
	
	delete timer;
}

public Action SmokeTimer(Handle timer) { // Create smoke each x seconds on the client
	if(g_bSmoking != true)
		return Plugin_Stop;
	
	float origin[3];
	GetClientAbsOrigin(g_iMurderer, origin);
	
	TE_SetupSmoke(origin, g_iSmoke, 3.8, 30);
	TE_SendToAll();
	
	return Plugin_Continue;
}