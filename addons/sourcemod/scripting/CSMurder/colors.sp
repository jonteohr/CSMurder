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

int iRed[6] = {
	255, // Pink
	153, // Green
	51, // Blue
	255, // Orange
	0, // Teal
	255 // Red
};
int iGreen[6] = {
	102, // Pink
	204, // Green
	153, // Blue
	153, // Orange
	255, // Teal
	77 // Red
};
int iBlue[6] = {
	153, // Pink
	0, // Green
	255, // Blue
	51, // Orange
	153, // Teal
	77 // Red
};

public void _Colors_OnRoundStart() {
	for(int i = 1; i <= MaxClients; i++) {
		if(!IsValidClient(i))
			continue;
		int iColor = GetRandomInt(0, 5);
		SetEntityRenderColor(i, iRed[iColor], iGreen[iColor], iBlue[iColor]);
		g_iColor[i] = iColor;
	}
}