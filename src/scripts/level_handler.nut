/*
	File: scripts/level_handler.nut
	Author: Astrofra
*/

		Include("scripts/utils.nut")
		Include("scripts/ui.nut")
		Include("scripts/thread_handler.nut")
		Include("scripts/bonus.nut")
		Include("scripts/camera_handler.nut")
		Include("scripts/stopwatch_handler.nut")
		Include("scripts/feedback_emitter.nut")
		Include("scripts/minimap.nut")

/*!
	@short	LevelHandler
	@author	Astrofra
*/
class	LevelHandler	extends	SceneWithThreadHandler
{
/*<
	<Parameter =
		<level_name = <Name = "Level Name"> <Type = "String"> <Default = "default_name">>
	>
>*/

	player					=	0	//	Player item
	player_script			=	0	//	Player script instance
	camera_handler			=	0	//	Camera
	homebase_item			=	0	//	Where the player wants to go back

	state					=	0

	path					=	0
	path_length				=	0.0

	minimap					=	0

	artefact				=	0
	total_artifact_to_found	=	0
	bonus					=	0

	stopwatch_handler		=	0

	feedback_emitter		=	0

	game_ui					=	0

	level_name				=	"default"

	update_function			=	0
	timer_table				=	0

	sfx_got_item			=	0

	//--------------------------------------------------
	//	Timer generic routine
	//--------------------------------------------------
	function	WaitForTimer(timer_name, timer_duration)
	//--------------------------------------------------
	{
		//	Does this timer already exist?
		if (!timer_table.rawin(timer_name))
			timer_table.rawset(timer_name, g_clock)
		else
		{
			if (g_clock - timer_table[timer_name] >= SecToTick(timer_duration))
				return false
		}
		return true
	}

	//--------------------------------
	function	ResetTimer(timer_name)
	//--------------------------------
	{
		timer_table.rawdelete(timer_name)
	}

	//-------------------------
	function	OnUpdate(scene)
	//-------------------------
	{
		base.OnUpdate(scene)
		stopwatch_handler.Update()
		feedback_emitter.Update()
		minimap.Update({player = ItemGetWorldPosition(player), artifacts = GetArtifactsPositionList(), bonus = GetBonusPositionList(), homebase = GetHomebasePosition()})
		if (update_function != 0)
			update_function(scene)
	}

	function	GetArtifactsPositionList()
	{
		local	_list = []
		foreach(_item in artefact)
			_list.append(ItemGetWorldPosition(_item))

		return _list
	}

	function	GetBonusPositionList()
	{
		local	_list = []
		return _list
	}

	function	GetHomebasePosition()
	{
		return	ItemGetWorldPosition(homebase_item)
	}

	//----------------------------------
	function	UpdateIntroScreen(scene)
	//----------------------------------
	{
		if (WaitForTimer("UpdateIntroScreen", Sec(2.0)))
		{
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
			game_ui.GameMessageWindowSetVisible("get_ready", true)
			player_script.update_function = player_script.UpdatePlayerIsDead
		}
		else
		{
			ResetTimer("UpdateIntroScreen")
			game_ui.GameMessageWindowSetVisible("get_ready", false)
			update_function = UpdateGameIsRunning
			player_script.update_function = player_script.UpdatePlayerIsAlive
			stopwatch_handler.Start()
		}
	}

	//------------------------------------------
	function	UpdateLevelCompleteScreen(scene)
	//------------------------------------------
	{
		if (WaitForTimer("UpdateLevelCompleteScreen", Sec(3.0)))
		{
			stopwatch_handler.Stop()
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
			game_ui.GameMessageWindowSetVisible("mission_complete", true)
			player_script.update_function = player_script.UpdatePlayerIsDead
		}
		else
		{
			ResetTimer("UpdateLevelCompleteScreen")
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
			game_ui.GameMessageWindowSetVisible("mission_complete", false)
			GoToNextLevel(scene)
		}
	}

	//-------------------------------------
	function	UpdateGameOverScreen(scene)
	//-------------------------------------
	{
		if (WaitForTimer("UpdateGameOverScreen", Sec(3.0)))
		{
			stopwatch_handler.Stop()
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
			player_script.update_function = player_script.UpdatePlayerIsDead
		}
		else
		{
			ExitGame(scene)
			ResetTimer("UpdateGameOverScreen")
		}
	}

	//------------------------------------
	function	UpdateGameIsRunning(scene)
	//------------------------------------
	{
		camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
		//UpdateCompass()
		CheckIfPlayerGetArtifacts(scene)
		CheckIfPlayerGetBonus(scene, "BonusFuel")
		CheckIfPlayerGetBonus(scene, "BonusFastClock")
		CheckIfPlayerGetBonus(scene, "BonusSlowClock")
		CheckIfPlayerGetBonus(scene, "BonusTime")
		CheckIfPlayerGetBonus(scene, "BonusShield")
		CheckPlayerStats(scene)
		game_ui.UpdateStopwatch(stopwatch_handler.clock)
	}

	//---------------------------------------
	function	UpdateGameReturnToBase(scene)
	//---------------------------------------
	{
		camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
		//UpdateCompass()
		CheckIfPlayerGetBonus(scene, "BonusFuel")
		CheckIfPlayerGetBonus(scene, "BonusFastClock")
		CheckIfPlayerGetBonus(scene, "BonusSlowClock")
		CheckIfPlayerGetBonus(scene, "BonusTime")
		CheckIfPlayerGetBonus(scene, "BonusShield")
		CheckIfPlayerIsBackToBase(scene)
		CheckPlayerStats(scene)
		game_ui.UpdateStopwatch(stopwatch_handler.clock)
	}

	//-------------------------
	function	UpdateCompass()
	//-------------------------
	{
		//	Compute compass position
		local	_pos
		_pos = CameraWorldToScene2d(camera_handler.camera , ItemGetWorldPosition(player), game_ui.ui)
//		_pos.Print("2D Player position")

		//	Compute compass orientation
		local	_angle = 0.0
		local	_beacon_pos, _dir 

		if (artefact.len() > 0)
			_beacon_pos = ItemGetWorldPosition(artefact[0])
		else
			_beacon_pos = ItemGetWorldPosition(homebase_item)

		_dir = (_beacon_pos - ItemGetWorldPosition(player)).Normalize()

		//3|0
		//-+-
		//2|1
		if (_dir.x >= 0.0)							//	Quadrant 0 & 1
			_angle = _dir.AngleWithVector(Vector(0,1,0))
		else
		if ((_dir.x < 0.0) && (_dir.y < 0.0))		//	Quadrant 2
			_angle = DegreeToRadian(180.0) + _dir.AngleWithVector(Vector(0,-1,0))
		else
		if ((_dir.x < 0.0) && (_dir.y >= 0.0))		//	Quadrant 3
			_angle = -_dir.AngleWithVector(Vector(0,1,0))
		
		game_ui.UpdateCompass(_pos, _angle)
	}

	//-----------
	constructor()
	//-----------
	{
		path		=	[]
		artefact	=	[]
		timer_table	=	{}
		bonus		=	{	BonusFuel = [],				//	Additional fuel
							BonusHeal = [], 			//	Additional health
							BonusTime = [], 			//	Freeze the timer for a short period of time
							BonusShield = [],			//	Invincibility to collisions for a short period of time
							BonusSlowClock = [],		//	EngineClockScale * 0.5
							BonusFastClock = [],		//	EngineClockScale * 2.0
					}
	}

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		base.OnSetup(scene)
		LoadSounds()
		camera_handler = CameraHandler(scene)
		stopwatch_handler = StopwatchHandler()
		feedback_emitter = FeedbackEmitter(scene)
		game_ui	=	InGameUI(SceneGetUI(scene))
		game_ui.UpdateRoomName(g_locale.level_names[level_name])
		state = "Game"
	}

	//----------------------------
	function	OnSetupDone(scene)
	//----------------------------
	{
		print("LevelHandler::OnSetupDone()")
		SceneFindPlayer(scene)
		camera_handler.SetMaxSneakSpeed(player_script.max_speed / 2.0)
		camera_handler.StickToPlayerPosition(ItemGetWorldPosition(player))

		SceneFindPath(scene)
		SceneFindArtefacts(scene)
		SceneFindBonus(scene, "BonusFuel")
		SceneFindBonus(scene, "BonusHeal")
		SceneFindBonus(scene, "BonusTime")
		SceneFindBonus(scene, "BonusShield")
		SceneFindBonus(scene, "BonusSlowClock")
		SceneFindBonus(scene, "BonusFastClock")
		homebase_item = LegacySceneFindItem(scene, "homebase")
		UpdateArtifactCounter()
		minimap = MiniMap(scene)

		update_function = UpdateIntroScreen
		player_script.update_function = player_script.UpdatePlayerIsDead
	}

	//------------------------
	function	CloseGame(scene)
	//------------------------
	{
		// Start the game over info display.
		print("GAME OVER")

		// Set the UI command list to pause for 2 seconds, then fade to black in 0.5 seconds.
		UISetCommandList(SceneGetUI(scene), "nop 2; globalfade 0.5, 1;")

		// Next update sets the end game flag and waits for an action from the project script.
		game_dispatcher = ExitGame
		SceneSuspendScriptUpdate(scene, 3.0 * SystemGetClockFrequency())
	}

	//------------------------------
	function	GoToNextLevel(scene)
	//------------------------------
	{
		state = "NextGame"
	}

	//------------------------
	function	ExitGame(scene)
	//------------------------
	{
		print("LevelHandler::ExitGame()")
		state = "ExitGame"
	}

	//------------------------------------------
	function	CheckIfPlayerIsBackToBase(scene)
	//------------------------------------------
	{
		local	_item_pos = ItemGetWorldPosition(homebase_item)
		local	_dist = ItemGetWorldPosition(player).Dist(_item_pos)

		if ((_dist < Mtr(3.0)) && (player_script.current_speed < Mtrs(0.5)))
			update_function = UpdateLevelCompleteScreen

	}

	//---------------------------------
	function	CheckPlayerStats(scene)
	//---------------------------------
	{
		if (ItemGetScriptInstance(player).damage >= 100)
		{
			game_ui.GameMessageWindowSetVisible("game_over_damage", true)
			update_function = UpdateGameOverScreen
		}
		else
		if (ItemGetScriptInstance(player).fuel <= 0) 
		{
			game_ui.GameMessageWindowSetVisible("game_over_no_fuel", true)
			update_function = UpdateGameOverScreen
		}

	}

	//	Artefacts/Bonus
	//------------------------------------------
	function	CheckIfPlayerGetArtifacts(scene)
	//------------------------------------------
	{
		foreach(_item in artefact)
		{
			local	_item_pos = ItemGetWorldPosition(_item)
			local	_dist = ItemGetWorldPosition(player).Dist(_item_pos)

			if (_dist < Mtr(2.5))
			{
				ScenePlayerGetsArtifact(scene, _item)
				UpdateArtifactCounter()
			}
		}
	}

	//------------------------------------------
	function	CheckIfPlayerGetBonus(scene, bonus_name)
	//------------------------------------------
	{
		foreach(_item in bonus[bonus_name])
		{
			local	_item_pos = ItemGetWorldPosition(_item)
			local	_dist = ItemGetWorldPosition(player).Dist(_item_pos)

			//	If a bonus was reached
			if (_dist < Mtr(2.5))
			{
				//	Remove it, from scene & from the bonus list
				ItemActivateHierarchy(_item, false)
				feedback_emitter.Emit(ItemGetWorldPosition(_item))
				PlaySfxGotItem()

				local	idx, val
				foreach(idx,val in bonus[bonus_name])
					if (ItemCompare(val, _item))
					{
						bonus[bonus_name].remove(idx)
//						ItemActivateHierarchy(_item, false)
					}

				//	Increase the players stats according to the bonus type
				switch(bonus_name)
				{
					case "BonusFuel":
						player_script.Refuel()
						break;

					case "BonusHeal":
						player_script.Heal()
						break;

					case "BonusTime":
						CreateThread(ThreadBonusTime)
						break;

					case "BonusShield":
						CreateThread(ThreadBonusShield)
						break;

					case "BonusSlowClock":
						CreateThread(ThreadBonusSlowClock)
						break;

					case "BonusFastClock":
						CreateThread(ThreadBonusFastClock)
						break;
				}
				return
			}
		}
	}

	//-----------------------------------------------
	function	ScenePlayerGetsArtifact(scene, _item)
	//-----------------------------------------------
	{
		print("LevelHandler::ScenePlayerGetsArtifact() item = " + ItemGetName(_item))
		local	idx, val
		foreach(idx,val in artefact)
			if (ItemCompare(val, _item))
			{
				artefact.remove(idx)
				ItemActivateHierarchy(_item, false)
			}

		feedback_emitter.Emit(ItemGetWorldPosition(_item))
		PlaySfxGotItem()

		if (artefact.len() < 1)
		{
			update_function = UpdateGameReturnToBase
			game_ui.GameMessageWindowShowOnce("return_base")
		}
	}

	//-----------------------------------
	function	SceneFindArtefacts(scene)
	//-----------------------------------
	{
		local	_list, _item
		_list = SceneGetItemList(scene)
		foreach(_item in _list)
			if (ItemGetName(_item) == "Artifact")
				artefact.append(_item)

		total_artifact_to_found = artefact.len()
		print("LevelHandler::SceneFindArtefacts() found " + total_artifact_to_found.tostring() + " artefact(s).")	
	}

	//---------------------------------
	function	UpdateArtifactCounter()
	//---------------------------------
	{
		game_ui.UpdateArtifactCounter((total_artifact_to_found - artefact.len()).tostring() + "/" + total_artifact_to_found.tostring())
	}

	//	=====
	//	Bonus
	//-------------------------------------------
	function	SceneFindBonus(scene, bonus_name)
	//-------------------------------------------
	{
		local	_list, _bonus_list
		_list = SceneGetItemList(scene)
		foreach(_item in _list)
			if (ItemGetName(_item) == bonus_name)
				bonus[bonus_name].append(_item)
		print("LevelHandler::SceneFindBonus() found " + bonus[bonus_name].len().tostring() + " " + bonus_name)	
	}

	//	=====
	//	Paths
	//------------------------------
	function	SceneFindPath(scene)
	//------------------------------
	{
		local	n = 0
		
		while(true)
		{
			local	_item = LegacySceneFindItem(scene, "path_" + n.tostring())
			if (ObjectIsValid(_item))
				path.append(_item)
			else
				break

			n++
		}

		if (path.len() > 0)
		{
			local	_prev_path_point = path[0]
			foreach(_path_point in path)
			{
				path_length += ItemGetWorldPosition(_prev_path_point).Dist(ItemGetWorldPosition(_path_point))
			}
		}

		print("LevelHandler::SceneFindPath() found " + path.len().tostring() + " path point(s), total length = " + path_length.tostring() + " m.")	
	}

	//	=======
	//	Players
	//	=======
	function	SceneFindPlayer(scene)
	{
		player = LegacySceneFindItem(scene, "player")
		if (ObjectIsValid(player))
		{
			player_script = ItemGetScriptInstance(player)
			print("LevelHandler::SceneFindPlayers() found " + ItemGetName(player) + ".")
		}
		else
			print("LevelHandler::SceneFindPlayers() player not found.")
	}

	//	=========
	//	Sounds
	//	=========

	function	LoadSounds()
	{
		//	Feedbacks
		sfx_got_item = EngineLoadSound(g_engine, "audio/sfx/sfx_got_item.wav")
	}

	function	PlaySfxGotItem()
	{
		local	_chan
		_chan = MixerSoundStart(g_mixer, sfx_got_item)
	}
}
