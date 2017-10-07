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

int g_iKiller;

public void _Deaths_OnPlayerDeath(Event event) {
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsMurderer(victim) && IsValidClient(g_iKiller)) { // If the murderer was killed
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Killed", g_iKiller);
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Reveal", victim);
		g_iKiller = -1;
		CS_TerminateRound(5.0, CSRoundEnd_Draw);
	} else if(IsMurderer(victim) && !IsValidClient(g_iKiller)) { // If murderer suicided
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Died Mysteriously");
		CPrintToChatAll("%s %t", g_sPrefix, "Murderer Reveal", victim);
		g_iKiller = -1;
		CS_TerminateRound(5.0, CSRoundEnd_Draw);
	}
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom) {
	if(!IsValidClient(victim) || !IsValidClient(attacker))
		return Plugin_Continue;
		
	int iWeapon = GetPlayerWeaponSlot(attacker, CS_SLOT_SECONDARY);
	
	if(IsDetective(attacker) && !IsMurderer(victim)) { // Detective killed innocent
		damage *= 0;
		CS_DropWeapon(attacker, iWeapon, true, true);
		CooldownClient(attacker); // Prevent client from picking up weapon for the specified time
		RequestFrame(SlayOnNextFrame, victim);
		
		_RDM_OnTakeDamage(victim, attacker); // Execute RDM Prevention if enabled
		
		return Plugin_Changed;
	}
	
	if(IsMurderer(attacker)) {
		attacker = victim;
		damage *= 100.0;
		_Smoke_OnPlayerDeath();
		
		return Plugin_Changed;
	}
	if(IsMurderer(victim)) {
		damage *= 0;
		RequestFrame(SlayOnNextFrame, victim);
		g_iKiller = attacker;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void SlayOnNextFrame(int client) {
	ForcePlayerSuicide(client);
}