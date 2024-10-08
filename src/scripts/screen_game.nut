/*
	File: scripts/screen_game.nut
	Author: Astrofra
*/

/*!
	@short	LevelHandler
	@author	Astrofra
*/
class	LevelHandler	extends	SceneWithThreadHandler
{
/*<
	<Parameter =
		<level_name = <Name = "Level Name"> <Type = "String"> <Default = "default_name">>
		<music_filename = <Name = "Music Filename"> <Type = "String"> <Default = "">>
		<is_underwater = <Name = "Underwater Level"> <Type = "Bool"> <Default = 0>>
	>
>*/

	player					=	0	//	Player item
	player_script			=	0	//	Player script instance
	camera_handler			=	0	//	Camera
	homebase_item			=	0	//	Where the player wants to go back
	
	replay_handler			=	0

	music_filename			=	""
	music_channel			=	-1

	game					=	0

	state					=	0
	paused					=	false

	path					=	0
	path_length				=	0.0

	minimap					=	0

	artefact				=	0
	total_artifact_to_found	=	0
	bonus					=	0

	stopwatch_handler		=	0

	feedback_emitter		=	0

	ui						=	0
	game_ui					=	0

	level_name				=	"default"
	is_underwater			=	false

	update_function			=	0
	timer_table				=	0

	sfx_got_item			=	0
	sfx_got_item_special	=	0
	sfx_mission_complete	=	0
	sfx_game_over			=	0

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
			//print("g_clock = " + g_clock)
			//print("g_clock - timer_table[timer_name] = " + (g_clock - timer_table[timer_name]).tostring())
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

	//---------------------
	function	PauseGame()
	//---------------------
	{
		if (paused)
			return
//		replay_handler.SaveItemMotion("c:/motion")
		paused	=	true
		game_ui.ShowPauseWindow()
	}

	//---------------------
	function	ResumeGame()
	//---------------------
	{
		if (!paused)
			return
		paused	=	false
		EngineSetClockScale(g_engine, g_clock_scale)
		game_ui.HidePauseWindow()
	}

	//---------------------
	function	ResumeAndExitGame(scene)
	//---------------------
	{
		if (!paused)
			return
		paused	=	false
		EngineSetClockScale(g_engine, g_clock_scale)
		game_ui.HidePauseWindow()
		//ExitGame(scene)
		ExitToTitleScreen(scene)
	}

	//-----------------------
	function	HandlePause()
	//-----------------------
	{
		if (paused)
			if (game_ui.IsCommandListDone())
				EngineSetClockScale(g_engine, 0.0)
	}

	function	OnRenderUI(scene)
	{
		game_ui.UpdateStopwatch(stopwatch_handler.clock)
	}

	//-------------------------
	function	OnUpdate(scene)
	//-------------------------
	{
		base.OnUpdate(scene)

		game_ui.Update()

		HandlePause()

		stopwatch_handler.Update()
		feedback_emitter.Update()
		minimap.Update({player = ItemGetWorldPosition(player), artifacts = GetArtifactsPositionList(), bonus = GetBonusPositionList(), homebase = GetHomebasePosition()})
		if (update_function != 0)
			update_function(scene)
			
//		replay_handler.UpdateItemMotionRecord(g_clock, ItemGetWorldPosition(player), ItemGetRotation(player))
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
		//	Actually does only display fuel bonuses
		foreach(_item in bonus.BonusFuel)
			_list.append(ItemGetWorldPosition(_item))

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
		if (WaitForTimer("UpdateIntroScreen", Sec(2.0) * g_clock_scale))
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
		if (WaitForTimer("UpdateLevelCompleteScreen", Sec(3.75) * g_clock_scale))
		{
			stopwatch_handler.Stop()
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
			player_script.update_function = player_script.UpdatePlayerIsDead
		}
		else
		{
			ResetTimer("UpdateLevelCompleteScreen")
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
			game_ui.GameMessageWindowSetVisible("mission_complete", false)
			GoToLevelEndScreen(scene)
		}
	}

	//-------------------------------------
	function	UpdateGameOverScreen(scene)
	//-------------------------------------
	{
		if (WaitForTimer("UpdateGameOverScreen", Sec(6.0) * g_clock_scale))
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
		CheckIfPlayerGetBonus(scene, "BonusHeal")
		CheckIfPlayerGetBonus(scene, "BonusFastClock")
		CheckIfPlayerGetBonus(scene, "BonusSlowClock")
		CheckIfPlayerGetBonus(scene, "BonusTime")
		CheckIfPlayerGetBonus(scene, "BonusShield")
		CheckPlayerStats(scene)
//		game_ui.UpdateStopwatch(stopwatch_handler.clock)
	}

	//---------------------------------------
	function	UpdateGameReturnToBase(scene)
	//---------------------------------------
	{
		camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
		//UpdateCompass()
		CheckIfPlayerGetBonus(scene, "BonusFuel")
		CheckIfPlayerGetBonus(scene, "BonusHeal")
		CheckIfPlayerGetBonus(scene, "BonusFastClock")
		CheckIfPlayerGetBonus(scene, "BonusSlowClock")
		CheckIfPlayerGetBonus(scene, "BonusTime")
		CheckIfPlayerGetBonus(scene, "BonusShield")
		CheckIfPlayerIsBackToBase(scene)
		CheckPlayerStats(scene)
//		game_ui.UpdateStopwatch(stopwatch_handler.clock)
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

	//--------------------------
	function	RecordGameData()
	//--------------------------
	{
		game.player_data.latest_run	= {
								stopwatch = stopwatch_handler.clock,
								fuel = player_script.fuel,
								life = player_script.life,
								new_record_stopwatch = false,
								new_record_fuel = false,
								new_record_life = false,
								wall_hits = 0
		}

		local	_level_key = "level_" + game.player_data.current_level.tostring()

		local	_record	=	{	complete = false,//true,
								stopwatch = -1.0, //stopwatch_handler.clock,
								fuel = 0.0, //player_script.fuel,
								life = 0.0, //player_script.life,
								wall_hits = 0,
								score = -1,
								attempt = 0,
							}

		if (!game.player_data.rawin(_level_key))
		{
			game.player_data.rawset(_level_key, 0)
			game.player_data[_level_key] = _record
		}

		game.player_data[_level_key].attempt++

		game.player_data[_level_key].complete = true

		if ((game.player_data[_level_key].stopwatch < 0.0) || (stopwatch_handler.clock < game.player_data[_level_key].stopwatch))
		{
			if (game.player_data[_level_key].stopwatch > -1.0)
			{
				game.player_data.latest_run.new_record_stopwatch = true
				print("LevelHandler::RecordGameData() : stopwatch record!")
				print("stopwatch_handler.clock                = " + stopwatch_handler.clock)
				print("game.player_data[_level_key].stopwatch = " + game.player_data[_level_key].stopwatch)
			}

			game.player_data[_level_key].stopwatch = stopwatch_handler.clock
		}

		if (player_script.fuel > game.player_data[_level_key].fuel)
		{
			game.player_data[_level_key].fuel = player_script.fuel
			game.player_data.latest_run.new_record_fuel = true
			print("LevelHandler::RecordGameData() : remaining fuel record!")

		}

		if (player_script.life > game.player_data[_level_key].life)
		{
			game.player_data[_level_key].life = player_script.life
			game.player_data.latest_run.new_record_life = true
			print("LevelHandler::RecordGameData() : remaining life record!")

		}
		
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

		if (EngineGetToolMode(g_engine) != NoTool)
		{
			if (!("g_locale" in getroottable()) || !("game_subtitle" in g_locale))
				LoadLocaleTable()
		}

//		RandomOffsetLevelBlocks(scene)
		game = ProjectGetScriptInstance(g_project)
		LoadSounds()
		camera_handler = CameraHandler(scene)
		stopwatch_handler = StopwatchHandler()
		feedback_emitter = FeedbackEmitter(scene)

		//	UI		
		ui		=	SceneGetUI(scene)
		game_ui	=	InGameUI(scene)
//		game_ui.how_to_control.OpenHowToControl()
		
		level_name = "level_" + (ProjectGetScriptInstance(g_project).player_data.current_level).tostring()
		local	level_name_str
		try	{	level_name_str = g_locale.level_names[level_name]	}
		catch(e)	{	level_name_str = level_name	}
		game_ui.UpdateRoomName(level_name_str)		

		print("LevelHandler::OnSetup() g_clock_scale = " + g_clock_scale)

		EngineSetClockScale(g_engine, g_clock_scale)

		SetAmbientColor(scene)
	}

	//----------------------------
	function	OnSetupDone(scene)
	//----------------------------
	{
		print("LevelHandler::OnSetupDone()")
		SceneFindPlayer(scene)
		camera_handler.SetMaxSneakSpeed(player_script.max_speed / 2.0)
		camera_handler.StickToPlayerPosition(ItemGetWorldPosition(player))
		
//		replay_handler = ReplayItemMotion(player, g_clock)

		//	Seek for various gameplay items
		SceneFindPath(scene)
		SceneFindArtefacts(scene)
		SceneFindBonus(scene, "BonusFuel")
		SceneFindBonus(scene, "BonusHeal")
		SceneFindBonus(scene, "BonusTime")
		SceneFindBonus(scene, "BonusShield")
		SceneFindBonus(scene, "BonusSlowClock")
		SceneFindBonus(scene, "BonusFastClock")
		homebase_item = LegacySceneFindItem(scene, "homebase")

		//	Minimap
		minimap = MiniMap(scene)
	
		UpdateArtifactCounter()

		update_function = UpdateIntroScreen
		player_script.update_function = player_script.UpdatePlayerIsDead

		PlayLevelMusic()
	}

	//----------------------------------------
	function	RandomOffsetLevelBlocks(scene)
	//----------------------------------------
	{
		local	_block_list = []
		foreach(_item in SceneGetItemList(scene))
		{
			local	_item_name = ItemGetName(_item)
			if (_item_name.len() > ("g_block_").len())
			{
				local	_slice = _item_name.slice(0,7)
				if (_slice == "g_block")
				{
					local	_pos = ItemGetPosition(_item)
					_pos.z += (Irand(-2, 2).tofloat() * 0.1)
					ItemSetPosition(_item, _pos)
				}
			}
		}			
	}
	
	//-----------------------------------
	function	GoToLevelEndScreen(scene)
	//-----------------------------------
	//	Victory!
	{
		StopLevelMusic()
		GlobalAudioHandler.Delete()
		RecordGameData()
		if (game.player_data.current_level > 3)
			GlobalSetPlayerGuid()
		GlobalSaveGame()
		EngineSetClockScale(g_engine, 1.0)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_level_end.nms")
	}

	//------------------------
	function	ExitGame(scene)
	//------------------------
	{
		print("LevelHandler::ExitGame()")
		EngineSetClockScale(g_engine, 1.0)
		StopLevelMusic()
		GlobalAudioHandler.Delete()
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_game_over.nms")
	}

	//------------------------
	function	ExitToTitleScreen(scene)
	//------------------------
	{
		print("LevelHandler::ExitToTitleScreen()")
		EngineSetClockScale(g_engine, 1.0)
		StopLevelMusic()
		GlobalAudioHandler.Delete()
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
	}

	//----------------------------
	function	RestartGame(scene)
	//----------------------------
	{
		print("LevelHandler::RestartGame()")
		if (!paused)
			return
		paused	=	false
		EngineSetClockScale(g_engine, g_clock_scale)
		game_ui.HidePauseWindow()
		StopLevelMusic()
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_game_restart.nms")
	}

	//------------------------------------------
	function	CheckIfPlayerIsBackToBase(scene)
	//------------------------------------------
	{
		local	_item_pos = ItemGetWorldPosition(homebase_item)
		local	_dist = ItemGetWorldPosition(player).Dist(_item_pos)

//		if ((_dist < Mtr(3.0)) && (player_script.current_speed < Mtrs(0.5)))
		if ((_dist < Mtr(3.0)) && (player_script.LanderIsStopped()))
		{
			PlaySfxMissionComplete()
			game_ui.GameMessageWindowSetVisible("return_base", false, 10.0)		// [EJ]
			game_ui.GameMessageWindowSetVisible("mission_complete", true)
			update_function = UpdateLevelCompleteScreen
		}
	}

	//---------------------------------
	function	CheckPlayerStats(scene)
	//---------------------------------
	{
		if (ItemGetScriptInstance(player).life <= 0)
		{
			game_ui.GameMessageWindowSetVisible("return_base", false, 4.0)		// [EJ] make sure this message is hidden asap so we can read the next one (should I automate that in UI?).
			game_ui.GameMessageWindowSetVisible("game_over_damage", true)
			PlaySfxGameOver()
			update_function = UpdateGameOverScreen
		}
		else
		if (ItemGetScriptInstance(player).fuel <= 0) 
		{
			game_ui.GameMessageWindowSetVisible("return_base", false, 4.0)		// [EJ]
			game_ui.GameMessageWindowSetVisible("game_over_no_fuel", true)
			PlaySfxGameOver()
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
				SceneDeleteItemHierarchy(scene, _item) //ItemActivateHierarchy(_item, false)
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
				//ItemActivateHierarchy(_item, false)
				SceneDeleteItemHierarchy(scene, _item)
			}

		feedback_emitter.Emit(ItemGetWorldPosition(_item))
		PlaySfxGotItem()
		camera_handler.EnableCloseUp(false)

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
		sfx_got_item_special = EngineLoadSound(g_engine, "audio/sfx/sfx_got_item_special.wav")
		sfx_mission_complete = EngineLoadSound(g_engine, "audio/sfx/sfx_mission_complete.wav")
		sfx_game_over = EngineLoadSound(g_engine, "audio/sfx/sfx_game_over.wav")
		g_audio_handler = GlobalAudioHandler()
	}

	function	PlaySfxGotItem()
	{
		local	_chan
		_chan = MixerSoundStart(g_mixer, sfx_got_item)
		MixerChannelSetGain(g_mixer, _chan, GlobalGetSfxVolume())
	}

	function	PlaySfxGotItemSpecial()
	{
		local	_chan
		_chan = MixerSoundStart(g_mixer, sfx_got_item_special)
		MixerChannelSetGain(g_mixer, _chan, GlobalGetSfxVolume())
	}

	function	PlaySfxMissionComplete()
	{
		local	_chan
		StopLevelMusic()
		_chan = MixerSoundStart(g_mixer, sfx_mission_complete)
		MixerChannelSetGain(g_mixer, _chan, GlobalGetSfxVolume())
	}

	function	PlaySfxGameOver()
	{
		local	_chan
		StopLevelMusic()
		_chan = MixerSoundStart(g_mixer, sfx_game_over)
		MixerChannelSetGain(g_mixer, _chan, GlobalGetSfxVolume())
	}

	function	PlayLevelMusic()
	{
		local	_rand_music = [	"children_of_science.ogg"
								"creepy_forest.ogg",
								"drip_drop.ogg",
								"egyptian_meditation_music.ogg",
								"out_there.ogg",
								"rat_sewer.ogg",
								"strangers_on_the_train.ogg",
								"town_in_ruins.ogg",
								"youre_my_hero.ogg",
								"sea_horizons.ogg",
								"steel_horizons.ogg"
								]
		if ((typeof music_filename != "string") || (music_filename == ""))
			music_filename = "audio/music/" + _rand_music[Irand(0,8)]

		if (FileExists(music_filename))
		{
				music_channel = MixerStreamStart(g_mixer, music_filename)
				MixerChannelSetLoopMode(g_mixer, music_channel, LoopRepeat)
				MixerChannelSetGain(g_mixer, music_channel, 1.0 * GlobalGetMusicVolume())
//				MixerChannelLock(g_mixer, music_channel)
		}
		else
			print("PlayLevelMusic() : Cannot find music '" + music_filename + "'.")
	}

	function	StopLevelMusic()
	{
		if (music_channel != -1)
		{
			MixerChannelStop(g_mixer, music_channel)
			MixerChannelUnlock(g_mixer, music_channel)
		}
	}	
	
	//-----------------
	//	OS Interactions
	//-----------------
	
	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		game_ui.OnRenderContextChanged()
	}	
	
	function	OnHardwareButtonPressed(button)
	{
		switch (button)
		{
			case	HardwareButtonBack:
				print("ScreenGame::OnHardwareButtonPressed(HardwareButtonBack)")
				game_ui.UIGamePause()
				break
		}
	}
}
