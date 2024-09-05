/*
	File: scripts/lander_audio.nut
	Author: Astrofra
*/

/*!
	@short	LanderAudio
	@author	Astrofra
*/

//------------------------
class	GlobalAudioHandler
//------------------------
{
	sound_table		=	0

	constructor()
	{
		sound_table = {}
		sound_table.rawset("explode", EngineLoadSound(g_engine, "audio/sfx/sfx_explode.wav"))
	}

	function	Delete()	//	FIXME ?
	{
//		sound_table = {}
	}

	//-----------------------------
	function	PlaySound(sound_id)
	//-----------------------------
	{
		if (sound_id in sound_table)
		{
			local	_sfx_channel = MixerSoundStart(g_mixer, sound_table[sound_id])
			MixerChannelSetGain(g_mixer, _sfx_channel, GlobalGetSfxVolume())
		}
	}
}

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

