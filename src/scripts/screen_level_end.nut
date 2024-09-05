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

//--------------------------------
function	ShowScoreScreen(scene)
//--------------------------------
{
	ComputeScoreThreadWait(Sec(6.0))
	SceneGetScriptInstance(scene).update_function = SceneGetScriptInstance(scene).GotoNextLevel
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

	update_function			=	0

	pending_request			=	-1
	available_request	=	"none"

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
		level_end_ui.DisplayDebrief(ComputeScoreFromLevelStats(scene))
		level_end_ui.AddNextButton()
		GlobalSaveGame()
		
//		update_function = GotoNextLevel
//		level_end_ui.UpdateLevelName(GetLevelName(game.player_data.current_level))
	}

	//-------------------------
	function	OnSetupDone(scene)
	//-------------------------
	{
		pending_request = SubmitTotalScore()
		CreateThread(ShowScoreScreen)
	}

	//-------------------------------------------
	function	ComputeScoreFromLevelStats(scene)
	//-------------------------------------------
	{

		//	Begin "fake project mode"
/*
		if (EngineGetToolMode(g_engine) != ToolProjectPreview)
		{
			game = {
				player_data		=	{
						total_score				=	15000
						current_selected_level	=	0
						current_level			=	0
						latest_run				=	0
						level_0 = { life = 80, fuel = 80, score = 250, stopwatch = 30000 }
				}
			}

			game.player_data.latest_run	= {
								stopwatch = 10500,
								fuel = 60,
								life = 20,
								new_record_stopwatch = false,
								new_record_fuel = false,
								new_record_life = false,
								wall_hits = 0
			}
		}//	End "fake project mode"
*/
		local	_current_level_key = "level_" + game.player_data.current_level.tostring()

		//	Compute Remaining Life Bonus
		local	_life_bonus_amount = Clamp(game.player_data.latest_run.life - 50, 0, 100) // No bonus if less than 50% Life
		_life_bonus_amount *= 10

		//	Compute Remaining Fuel Bonus
		local	_fuel_bonus_amount = Clamp(game.player_data.latest_run.fuel - 25, 0, 100) // No bonus if less than 25% Fuel
		_fuel_bonus_amount *= 5

		//	Compute Stopwatch Record Bonus
		local	reference_stopwach = 0.0
		local	_stopwatch_bonus = Max(reference_stopwach - game.player_data.latest_run.stopwatch, 0.0)
		local	_level_score = 150 + (game.player_data.current_level * 50) +  _life_bonus_amount + _fuel_bonus_amount + _stopwatch_bonus

		if (game.player_data[_current_level_key].score < _level_score)
		{
			game.player_data[_current_level_key].score = _level_score
			game.player_data[_current_level_key].life = game.player_data.latest_run.life
			game.player_data[_current_level_key].fuel = game.player_data.latest_run.fuel
			game.player_data[_current_level_key].stopwatch = game.player_data.latest_run.stopwatch
		}

		GlobalCalculateTotalScore()

		local	debrief_table = []

		debrief_table.append({	/*text = g_locale.endlevel_level_name, */
								value = GetLevelName(game.player_data.current_level)	})

		debrief_table.append({	text = g_locale.endlevel_remain_life,
								value = game.player_data.latest_run.life.tointeger().tostring(),
								bonus = _life_bonus_amount.tointeger()})
		debrief_table.append({	text = g_locale.endlevel_remain_fuel,
								value = game.player_data.latest_run.fuel.tointeger().tostring(),
								bonus = _fuel_bonus_amount.tointeger() })
		debrief_table.append({	text = g_locale.endlevel_time,
								value = TimeToString(game.player_data.latest_run.stopwatch),
								bonus = _stopwatch_bonus.tointeger()})

		debrief_table.append({	text = g_locale.endlevel_score ,
								value = _level_score.tointeger().tostring()	})

		debrief_table.append({	text = g_locale.total_score,	
								value = game.player_data.total_score.tointeger().tostring()	})

		return debrief_table
	}

	//-------------------------
	function	OnUpdate(scene)
	//-------------------------
	{
		base.OnUpdate(scene)
		level_end_ui.UpdateCursor()
		HttpUpdate()

		if (update_function != 0)
			update_function(scene)

	}

	function	GotoNextLevel(scene)
	{
		update_function = 0
		ProjectGetScriptInstance(g_project).player_data.current_level++
		ProjectGetScriptInstance(g_project).ProjectStartGame()
	}
	
	//----------------------------
	function	SubmitTotalScore()
	//----------------------------
	{
		print("LevelEnd::SubmitTotalScore()")
		local	_guid, _name, _score, _player_data, _check_key
		_player_data = ProjectGetScriptInstance(g_project).player_data

		if (("guid" in _player_data) && ("nickname" in _player_data))
		{
			_guid = _player_data.guid.tostring()
			_name = _player_data.nickname.tostring()
			_score = _player_data.total_score.tointeger().tostring()

			_check_key = CalculateCheckKey([_guid, _name, _score])
	
			local	post = "command=set&guid=" + _guid + "&name=" + _name + "&score=" + _score + "&session=" + _check_key
			print("post = " + post)
			return HttpPost(g_base_url + "/leaderboard.php", post)
		}
	}
	
	//-----------------
	//	OS Interactions
	//-----------------
	
	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		level_end_ui.OnRenderContextChanged()
	}	
	
	//---------------------
	function	HttpRequestComplete(uid, data)
	//---------------------
	{
		print("LevelEnd::onHttpRequestComplete() uid = " + uid)
		if	(pending_request != uid)		// ignore
			return

		print("Score submit request done.")
		available_request = "data"
		print("Request returned : " + data)
		pending_request = -1
	}
	
	//---------------------
	function	HttpRequestError(uid)
	//---------------------
	{
		print("LevelEnd::onHttpRequestError() uid = " + uid)
		if	(pending_request != uid)		// ignore
			return

		available_request = "error"
		pending_request = -1
	}
	

}