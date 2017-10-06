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

Handle hAdminMenu = INVALID_HANDLE;
TopMenuObject obj_dmcommands;

public void _AdminMenu_OnPluginStart() {
	Handle topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE)) {
		OnAdminMenuReady(topmenu);
	}
}

public void OnLibraryRemoved(const char[] name) {
	if(StrEqual(name, "adminmenu")) {
		hAdminMenu = INVALID_HANDLE;
	}
}

public void OnAdminMenuReady(Handle topmenu) {
	
	if(obj_dmcommands == INVALID_TOPMENUOBJECT) {
		OnAdminMenuCreated(topmenu);
	}
	
	if(topmenu == hAdminMenu) {
		return;
	}
	
	hAdminMenu = topmenu;
	
	AttachAdminMenu();
	
}

public void OnAdminMenuCreated(Handle topmenu) {
	
	if(topmenu == hAdminMenu && obj_dmcommands != INVALID_TOPMENUOBJECT) {
		return;
	}
	
	obj_dmcommands = AddToTopMenu(topmenu, "Murder", TopMenuObject_Category, CategoryHandler, INVALID_TOPMENUOBJECT);
	
}

public void CategoryHandler(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength) {
	
	if(action == TopMenuAction_DisplayTitle) {
		Format(buffer, maxlength, "Murder");
	} else if(action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "Murder");
	}
	
}

public void AttachAdminMenu() {
	
	TopMenuObject player_commands = FindTopMenuCategory(hAdminMenu, ADMINMENU_PLAYERCOMMANDS);
	
	if(player_commands == INVALID_TOPMENUOBJECT) {
		return; // *ERROR*
	}
	
	AddToTopMenu(hAdminMenu, "sm_bluffmurderer", TopMenuObject_Item, Adminmenu_RevealMurderer, obj_dmcommands, "sm_bluffmurderer", ADMFLAG_GENERIC);
	
}

public void Adminmenu_RevealMurderer(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int client, char[] buffer, int maxlength) {
	
	if(action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "%t", "Reveal Murderer Title");
	} else if(action == TopMenuAction_SelectOption) {
		CPrintToChat(client, "%s %t", g_sPrefix, "Reveal Murderer", g_iMurderer);
	}
	
}
