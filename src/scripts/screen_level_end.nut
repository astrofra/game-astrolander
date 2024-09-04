/* Level End Screen */

//------------------------------
function	ComputeScoreThreadWait(s)
//------------------------------
{
	local	_timeout

	_timeout = g_clock
				
	while (((g_clock - _timeout) < SecToTick(Sec(s))) && (!SceneGetScriptInstance(g_scene).skip))
		suspend()
}

//-----------------------------
function	ComputeScore(scene)
//-----------------------------
{

	local	_dt_count, 
			game,
			level_end_ui,
			ui, sfx_feedback_counter = 0

	local	sfx_channel, sfx_count, sfx_end_count, sfx_new_record = []

	sfx_count = AudioLoadSfx("gui_up_down.wav")
	sfx_end_count = AudioLoadSfx("gui_next_page.wav")
	sfx_new_record.append(AudioLoadSfx("sfx_success_light_0.wav"))
	sfx_new_record.append(AudioLoadSfx("sfx_success_light_1.wav"))
	sfx_new_record.append(AudioLoadSfx("sfx_success_light_2.wav"))
	sfx_new_record.append(AudioLoadSfx("sfx_success_light_3.wav"))

	local	current_channel = 0

	game = SceneGetScriptInstance(scene).game
	level_end_ui = SceneGetScriptInstance(scene).level_end_ui
	ui = SceneGetScriptInstance(scene).ui

	while(!UIIsCommandListDone(ui))
		suspend()

	ComputeScoreThreadWait(Sec(0.5))

	sfx_channel = array(4,0)
	foreach(i, chan in sfx_channel)
	{
		sfx_channel[i] = MixerSoundStart(g_mixer, sfx_count)
//	MixerChannelLock(g_mixer, sfx_channel)
		MixerChannelSetGain(g_mixer, sfx_channel[i], 1.0)
		MixerChannelSetLoopMode(g_mixer, sfx_channel[i], LoopNone)
	}

	local	_level_key = "level_" + game.player_data.current_level.tostring(),
			_score	=	0.0

	//	Unwind life bar
	local	life = game.player_data.latest_run.life,
			fuel = game.player_data.latest_run.fuel

	while(life > 0)
	{
		_dt_count = 1 //g_dt_frame * 60.0 * 2.0

		if (life > 0)
		{
			life-=_dt_count
			_score+=(_dt_count * 10.0)
		}

		local	_stats = {
				life = (life / 2.0).tointeger() * 2,
				fuel = fuel.tointeger(), //(fuel / 2.0).tointeger() * 2,
				score = _score.tointeger()
			}

		if (!SceneGetScriptInstance(scene).skip)
		{
			level_end_ui.UpdateStats(_stats)

			sfx_feedback_counter++
			if (sfx_feedback_counter > 5)
			{
				sfx_feedback_counter = 0
				current_channel++
				if (current_channel >= sfx_channel.len())
					current_channel = 0
				MixerChannelStart(g_mixer, sfx_channel[current_channel], sfx_count)
			}

			ComputeScoreThreadWait(Sec(1.0 / 60.0))
		}

	}

	//game.player_data.score = game.player_data.score.tointeger()

	//	Perfect Drive bonus
	if (game.player_data.latest_run.life >= 100)
	{
		if (!SceneGetScriptInstance(scene).skip)
			ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))

		print("Perfect Drive! + 1000")
		_score += 1000

		local	_stats = {
				life = 0, //(life / 2.0).tointeger() * 2,
				fuel = fuel.tointeger(), //(fuel / 2.0).tointeger() * 2,
				score = _score.tointeger()
			}

		level_end_ui.UpdateStats(_stats)

		if (!SceneGetScriptInstance(scene).skip)
		{
			level_end_ui.ShowMessagePerfect()
			ComputeScoreThreadWait(Sec(0.25) * EngineGetClockScale(g_engine))
			current_channel++
			if (current_channel >= sfx_channel.len())
				current_channel = 0
			MixerChannelStart(g_mixer, sfx_channel[current_channel], sfx_new_record[0])
			level_end_ui.ShowMessageScoreBonus()
			ComputeScoreThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
		}
	}

	//	Life record ?
	if (game.player_data.latest_run.new_record_life)
	{
		if (!SceneGetScriptInstance(scene).skip)
		{
			ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
			level_end_ui.ShowNewRecordLife()
			current_channel++
			if (current_channel >= sfx_channel.len())
				current_channel = 0
			MixerChannelStart(g_mixer, sfx_channel[current_channel], sfx_new_record[1])
			ComputeScoreThreadWait(Sec(0.1) * EngineGetClockScale(g_engine))
			level_end_ui.ShowMessageScoreBonus(g_locale.endlevel_remain_life + " : " + game.player_data.latest_run.life.tointeger())
			ComputeScoreThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
		}
	}

	if (!SceneGetScriptInstance(scene).skip)
		ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))

	//	Unwind fuel bar
	while(fuel > 0)
	{
		_dt_count = 1 //g_dt_frame * 60.0 * 2.0

		if (fuel > 0)
		{
			fuel-=_dt_count
			_score+=(_dt_count * 10.0)
		}

		local	_stats = {
				life = 0, //(life / 2.0).tointeger() * 2,
				fuel = (fuel / 2.0).tointeger() * 2,
				score = _score.tointeger()
			}

		if (!SceneGetScriptInstance(scene).skip)
		{
			level_end_ui.UpdateStats(_stats)

			sfx_feedback_counter++
			if (sfx_feedback_counter > 5)
			{
				sfx_feedback_counter = 0
				current_channel++
				if (current_channel >= sfx_channel.len())
					current_channel = 0
				MixerChannelStart(g_mixer, sfx_channel[current_channel], sfx_count)
			}

			ComputeScoreThreadWait(Sec(1.0 / 60.0))
		}
	}

	//game.player_data.score = game.player_data.score.tointeger()

	//	Fuel record ?
	if (game.player_data.latest_run.new_record_fuel && !SceneGetScriptInstance(scene).skip)
	{
		ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.ShowNewRecordFuel()
		current_channel++
		if (current_channel >= sfx_channel.len())
			current_channel = 0
		MixerChannelStart(g_mixer, sfx_channel[current_channel], sfx_new_record[2])
		ComputeScoreThreadWait(Sec(0.1) * EngineGetClockScale(g_engine))
		level_end_ui.ShowMessageScoreBonus(g_locale.endlevel_remain_fuel + " : " + game.player_data.latest_run.fuel.tointeger())
		ComputeScoreThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
	}

	//	Stopwatch record ?
	print("ComputeScore() : game.player_data.latest_run.new_record_stopwatch = " + game.player_data.latest_run.new_record_stopwatch)
	if (game.player_data.latest_run.new_record_stopwatch && !SceneGetScriptInstance(scene).skip)
	{
		_score+=500
		local	_stats = {
				life = 0, //(life / 2.0).tointeger() * 2,
				fuel = (fuel / 2.0).tointeger() * 2,
				score = _score.tointeger()
			}
		ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.UpdateStats(_stats)
		level_end_ui.ShowNewRecordTime()
		current_channel++
		if (current_channel >= sfx_channel.len())
			current_channel = 0
		MixerChannelStart(g_mixer, sfx_channel[current_channel], sfx_new_record[3])
		ComputeScoreThreadWait(Sec(0.1) * EngineGetClockScale(g_engine))
		level_end_ui.ShowMessageScoreBonus(TimeToString(game.player_data.latest_run.stopwatch))
		ComputeScoreThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
	}
	
	//	Save score & datas
	if (game.player_data[_level_key].score < _score)
		game.player_data[_level_key].score = _score.tointeger()
	
	GlobalSaveGame()	

	if (!SceneGetScriptInstance(scene).skip)
		ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))

	//	Story image ?
	print("LevelEnd::ComputeScore() : game.player_data.current_level + 1 = " + (game.player_data.current_level + 1).tostring())
	print("((game.player_data.current_level + 1) / 4.0).tointeger() * 4 = " + (((game.player_data.current_level + 1) / 4.0).tointeger() * 4).tostring())
	if ((game.player_data.current_level > 0) && ((game.player_data.current_level + 1) == (((game.player_data.current_level + 1) / 4.0).tointeger() * 4)))
	{
		level_end_ui.FadeOutScoreDebrief()
		ComputeScoreThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.ShowStoryImage(((game.player_data.current_level + 1.0) / 4.0).tointeger() - 1)
		if (!SceneGetScriptInstance(scene).skip)
			ComputeScoreThreadWait(Sec(6.0) * EngineGetClockScale(g_engine))
		else
			ComputeScoreThreadWait(Sec(1.0) * EngineGetClockScale(g_engine))
	}
/*
	//	Fade out
	UISetCommandList(ui, "globalfade 0.5, 1;")

	while(!UIIsCommandListDone(ui))
		suspend()
*/

	EngineSetClockScale(g_engine, 1.0)

	if (SceneGetScriptInstance(scene).skip)
		UISetCommandList(ui, "globalfade 0.1, 1;")

	ProjectGetScriptInstance(g_project).player_data.current_level++
	ProjectGetScriptInstance(g_project).ProjectStartGame()
}

//------------------------------------------------
class	LevelEnd	extends	SceneWithThreadHandler
//------------------------------------------------
{
	game					=	0

	ui						=	0
	level_end_ui			=	0

	state					=	0

	skip					=	false

	constructor()
	{
		game = ProjectGetScriptInstance(g_project)
	}

	//----------------------------
	function	GetLevelName(_idx)
	//----------------------------
	{
		local	_str
		try
		{
			_str = g_locale.level_names[("level_" + _idx.tostring())]
		}
		catch(e)
		{
			_str = "level #" + (_idx + 1).tostring()
		}
		
		return _str
	}

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		print("LevelEnd::OnSetup() game.player_data.current_level = " +game.player_data.current_level)

		base.OnSetup(scene)

		ui = SceneGetUI(scene)
		UICommonSetup(ui)
		level_end_ui = LevelEndUI(ui)
		level_end_ui.UpdateLevelName(GetLevelName(game.player_data.current_level))

//		state = "LevelEnd"

		//ComputeScore(scene)
		CreateThread(ComputeScore)
	}

	//-------------------------
	function	OnSetupDone(scene)
	//-------------------------
	{
	}

	//-------------------------
	function	OnUpdate(scene)
	//-------------------------
	{
		base.OnUpdate(scene)
		level_end_ui.UpdateCursor()
	}
}