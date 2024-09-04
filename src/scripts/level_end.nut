/* Level End Screen */

//-----------------------------
function	ComputeScore(scene)
//-----------------------------
{

	local	_dt_count, 
			game,
			level_end_ui,
			ui

	game = SceneGetScriptInstance(scene).game
	level_end_ui = SceneGetScriptInstance(scene).level_end_ui
	ui = SceneGetScriptInstance(scene).ui

	//	Unwind life bar
	local	life = game.player_data.latest_run.life,
			fuel = game.player_data.latest_run.fuel

	while(life > 0)
	{
		_dt_count = g_dt_frame * 60.0 * 2.0

		if (life > 0)
		{
			life-=_dt_count
			game.player_data.score+=(_dt_count * 10.0)
		}

		local	_stats = {
				life = (life / 2.0).tointeger() * 2,
				fuel = fuel.tointeger(), //(fuel / 2.0).tointeger() * 2,
				score = game.player_data.score.tointeger()
			}

		level_end_ui.UpdateStats(_stats)

		suspend()
	}

	game.player_data.score = game.player_data.score.tointeger()

	//	Perfect Drive bonus
	if (game.player_data.latest_run.life >= 100)
	{
		GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))

		print("Perfect Drive! + 1000")
		game.player_data.score += 1000

		local	_stats = {
				life = 0, //(life / 2.0).tointeger() * 2,
				fuel = fuel.tointeger(), //(fuel / 2.0).tointeger() * 2,
				score = game.player_data.score.tointeger()
			}

		level_end_ui.UpdateStats(_stats)
		level_end_ui.ShowMessagePerfect()
		GenericThreadWait(Sec(0.25) * EngineGetClockScale(g_engine))
		level_end_ui.ShowMessageScoreBonus()
		GenericThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
	}

	//	Life record ?
	if (game.player_data.latest_run.new_record_life)
	{
		GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.ShowNewRecordLife()
		GenericThreadWait(Sec(0.1) * EngineGetClockScale(g_engine))
		level_end_ui.ShowMessageScoreBonus(g_locale.endlevel_remain_life + " : " + game.player_data.latest_run.life.tointeger())
		GenericThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
	}

	GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))

	//	Unwind fuel bar
	while(fuel > 0)
	{
		_dt_count = g_dt_frame * 60.0 * 2.0

		if (fuel > 0)
		{
			fuel-=_dt_count
			game.player_data.score+=(_dt_count * 10.0)
		}

		local	_stats = {
				life = 0, //(life / 2.0).tointeger() * 2,
				fuel = (fuel / 2.0).tointeger() * 2,
				score = game.player_data.score.tointeger()
			}

		level_end_ui.UpdateStats(_stats)

		suspend()
	}

	game.player_data.score = game.player_data.score.tointeger()

	//	Life record ?
	if (game.player_data.latest_run.new_record_fuel)
	{
		GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.ShowNewRecordLife()
		GenericThreadWait(Sec(0.1) * EngineGetClockScale(g_engine))
		level_end_ui.ShowMessageScoreBonus(g_locale.endlevel_remain_fuel + " : " + game.player_data.latest_run.fuel.tointeger())
		GenericThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
	}

	//	Stopwatch record ?
	if (game.player_data.latest_run.new_record_stopwatch)
	{
		GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.ShowNewRecordLife()
		GenericThreadWait(Sec(0.1) * EngineGetClockScale(g_engine))
		level_end_ui.ShowMessageScoreBonus(TimeToString(game.player_data.latest_run.stopwatch))
		GenericThreadWait(Sec(2.0) * EngineGetClockScale(g_engine))
	}

	GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))

	//	Story image ?
	print("LevelEnd::ComputeScore() : game.player_data.current_level + 1 = " + (game.player_data.current_level + 1).tostring())
	print("((game.player_data.current_level + 1) / 4.0).tointeger() * 4 = " + (((game.player_data.current_level + 1) / 4.0).tointeger() * 4).tostring())
	if ((game.player_data.current_level > 0) && ((game.player_data.current_level + 1) == (((game.player_data.current_level + 1) / 4.0).tointeger() * 4)))
	{
		level_end_ui.FadeOutScoreDebrief()
		GenericThreadWait(Sec(0.5) * EngineGetClockScale(g_engine))
		level_end_ui.ShowStoryImage(((game.player_data.current_level + 1.0) / 4.0).tointeger() - 1)
		GenericThreadWait(Sec(6.0) * EngineGetClockScale(g_engine))
	}

	//	Fade out
	UISetCommandList(ui, "globalfade 0.5, 1;")

	while(!UIIsCommandListDone(ui))
		suspend()

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

	constructor()
	{
		game = ProjectGetScriptInstance(g_project)
	}

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		print("LevelEnd::OnSetup() game.player_data.current_level = " + game.player_data.current_level)

		base.OnSetup(scene)

		ui = SceneGetUI(scene)
		UICommonSetup(ui)
		level_end_ui = LevelEndUI(ui)

		state = "LevelEnd"

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