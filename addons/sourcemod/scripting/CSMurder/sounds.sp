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

public void _Sounds_OnMapStart() {
	AddFileToDownloadsTable("sound/murder/scream.mp3");
	AddFileToDownloadsTable("sound/murder/detective.mp3");
	
	PrecacheSoundAny("murder/scream.mp3", true);
	PrecacheSoundAny("murder/detective.mp3", true);
}

// Play effect for the murderer
public Action OnMurdererCreated(int client) {
	EmitSoundToClientAny(client, "murder/scream.mp3");
	
	return Plugin_Continue;
}

public Action OnDetectiveCreated(int client) {
	EmitSoundToClientAny(client, "murder/detective.mp3");
	
	return Plugin_Continue;
}