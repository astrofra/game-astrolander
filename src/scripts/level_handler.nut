/*
	File: scripts/level_handler.nut
	Author: Astrofra
*/

		Include("scripts/ui.nut")
		Include("scripts/camera_handler.nut")

/*!
	@short	LevelHandler
	@author	Astrofra
*/
class	LevelHandler
{
/*<
	<Parameter =
		<level_name = <Name = "Level Name"> <Type = "String"> <Default = "default">>
	>
>*/

	player					=	0	//	Player item
	player_script			=	0	//	Player script instance
	camera_handler			=	0	//	Camera
	homebase_item			=	0	//	Where the player wants to go back

	state					=	0

	path					=	0
	path_length				=	0.0

	artefact				=	0
	total_artifact_to_found	=	0
	bonus					=	0

	game_ui					=	0

	level_name				=	"default"

	update_function			=	0
	timer_table				=	0

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
		if (update_function != 0)
			update_function(scene)
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
		}
	}

	//------------------------------------------
	function	UpdateLevelCompleteScreen(scene)
	//------------------------------------------
	{
		if (WaitForTimer("UpdateLevelCompleteScreen", Sec(3.0)))
		{
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
		UpdateCompass()
		CheckIfPlayerGetArtifacts(scene)
		CheckIfPlayerGetBonus(scene, "fuel")
		CheckPlayerStats(scene)
	}

	//---------------------------------------
	function	UpdateGameReturnToBase(scene)
	//---------------------------------------
	{
		camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player), ItemGetLinearVelocity(player))
		UpdateCompass()
		CheckIfPlayerGetBonus(scene, "fuel")
		CheckIfPlayerIsBackToBase(scene)
		CheckPlayerStats(scene)
	}

	//-------------------------
	function	UpdateCompass()
	//-------------------------
	{
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
		
		game_ui.UpdateCompass(_angle)
	}

	//-----------
	constructor()
	//-----------
	{
		path		=	[]
		artefact	=	[]
		timer_table	=	{}
		bonus		=	{	fuel = [],	heal = [], time = []	}
	}

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		camera_handler = CameraHandler(scene)
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
		SceneFindPath(scene)
		SceneFindArtefacts(scene)
		SceneFindBonus(scene, "fuel")
		UpdateArtifactCounter()
		homebase_item = SceneFindItem(scene, "homebase")
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

			if (_dist < Mtr(3.0))
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
			if (_dist < Mtr(3.0))
			{
				//	Remove it, from scene & from the bonus list
				ItemActivateHierarchy(_item, false)
				local	idx, val
				foreach(idx,val in bonus[bonus_name])
					if (ItemCompare(val, _item))
					{
						bonus[bonus_name].remove(idx)
						ItemActivateHierarchy(_item, false)
					}

				//	Increase the players stats according to the bonus type
				switch(bonus_name)
				{
					case "fuel":
						player_script.Refuel()
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
		local	n = 0
		
		while(true)
		{
			local	_item = SceneFindItem(scene, "artefact_" + n.tostring())
			if (ObjectIsValid(_item))
				artefact.append(_item)
			else
				break

			n++
		}

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
			local	_item = SceneFindItem(scene, "path_" + n.tostring())
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
		player = SceneFindItem(scene, "player")
		if (ObjectIsValid(player))
		{
			player_script = ItemGetScriptInstance(player)
			print("LevelHandler::SceneFindPlayers() found " + ItemGetName(player) + ".")
		}
		else
			print("LevelHandler::SceneFindPlayers() player not found.")
	}
}
