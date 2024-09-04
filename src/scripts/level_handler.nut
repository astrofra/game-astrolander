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
	player			=	0
	player_script	=	0
	camera_handler	=	0

	state			=	0

	path			=	0
	path_length		=	0.0

	artefact		=	0

	game_hui		=	0

	update_function	=	0
	timer_table		=	0

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
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player))
			game_hui.GameMessageWindowSetVisible("get_ready", true)
			player_script.update_function = player_script.UpdatePlayerIsDead
		}
		else
		{
			ResetTimer("UpdateIntroScreen")
			game_hui.GameMessageWindowSetVisible("get_ready", false)
			update_function = UpdateGameIsRunning
			player_script.update_function = player_script.UpdatePlayerIsAlive
		}
	}

	//-------------------------------------
	function	UpdateGameOverScreen(scene)
	//-------------------------------------
	{
		if (WaitForTimer("UpdateGameOverScreen", Sec(3.0)))
		{
			camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player))
			player_script.update_function = player_script.UpdatePlayerIsDead
		}
		else
		{
			ResetTimer("UpdateGameOverScreen")
			ExitGame(scene)
		}
	}



	//------------------------------------
	function	UpdateGameIsRunning(scene)
	//------------------------------------
	{
		camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player))
		CheckIfPlayerGetArtifacts(scene)
		CheckPlayerStats(scene)
	}

	//---------------------------------------
	function	UpdateGameReturnToBase(scene)
	//---------------------------------------
	{
		camera_handler.FollowPlayerPosition(ItemGetWorldPosition(player))
		CheckPlayerStats(scene)
	}

	//-----------
	constructor()
	//-----------
	{
		path		=	[]
		artefact	=	[]
		timer_table	=	{}
	}

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		game_hui	=	InGameUI(SceneGetUI(scene))
		camera_handler = CameraHandler(scene)
		state = "Game"
	}

	//----------------------------
	function	OnSetupDone(scene)
	//----------------------------
	{
		print("LevelHandler::OnSetupDone()")
		SceneFindPlayer(scene)
		SceneFindPath(scene)
		SceneFindArtefacts(scene)
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

	//------------------------
	function	ExitGame(scene)
	//------------------------
	{
		//MixerChannelStopAll(g_mixer)
		state = "ExitGame"
	}

	//---------------------------------
	function	CheckPlayerStats(scene)
	//---------------------------------
	{
		if (ItemGetScriptInstance(player).damage >= 100)
		{
			game_hui.GameMessageWindowSetVisible("game_over_damage", true)
			update_function = UpdateGameOverScreen
		}

		if (ItemGetScriptInstance(player).fuel <= 0) 
		{
			game_hui.GameMessageWindowSetVisible("game_over_no_fuel", true)
			update_function = UpdateGameOverScreen
		}

	}

	//	Artefacts
	//------------------------------------------
	function	CheckIfPlayerGetArtifacts(scene)
	//------------------------------------------
	{
		foreach(_item in artefact)
		{
			local	_item_pos = ItemGetWorldPosition(_item)
			local	_dist = ItemGetWorldPosition(player).Dist(_item_pos)

			if (_dist < Mtr(3.0))
				ScenePlayerGetsArtifact(scene, _item)
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
			game_hui.GameMessageWindowShowOnce("return_base")
		}
	}

	function	SceneFindArtefacts(scene)
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

		print("LevelHandler::SceneFindArtefacts() found " + artefact.len().tostring() + " artefact(s).")	
	}

	//	=====
	//	Paths
	//	=====
	function	SceneFindPath(scene)
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
