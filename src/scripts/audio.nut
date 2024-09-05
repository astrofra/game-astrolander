/*
	File: scripts/lander_audio.nut
	Author: Astrofra
*/

/*!
	@short	LanderAudio
	@author	Astrofra
*/

//------------------------------
function	GlobalGetSfxVolume()
//------------------------------
//	Range 0 <-> 1.0
{
	local	_game = ProjectGetScriptInstance(g_project)
	return (_game.player_data.sfx_volume)
}

//------------------------------
function	GlobalSetSfxVolume(_vol)
//------------------------------
//	Range 0 <-> 1.0
{
	local	_game = ProjectGetScriptInstance(g_project)
	_game.player_data.sfx_volume = Clamp(_vol, 0.0, 1.0)
}

//--------------------------------
function	GlobalGetMusicVolume()
//--------------------------------
//	Range 0 <-> 1.0
{
	local	_game = ProjectGetScriptInstance(g_project)
	return (_game.player_data.music_volume)
}

//--------------------------------
function	GlobalSetMusicVolume(_vol)
//--------------------------------
//	Range 0 <-> 1.0
{
	local	_game = ProjectGetScriptInstance(g_project)
	_game.player_data.music_volume = Clamp(_vol, 0.0, 1.0)
}

