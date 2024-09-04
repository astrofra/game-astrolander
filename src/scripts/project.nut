/*
	File: 04 - Simple Ball Game with a Title/simple_ball.nut
	Author: Emmanuel Julien
*/

	Include("scriptlib/nad.nut")
	Include("scripts/globals.nut")
	Include("scripts/ace_deleter.nut")
	Include("scripts/achievements.nut")
	Include("scripts/camera_handler.nut")
	Include("scripts/feedback_emitter.nut")
	Include("scripts/inventory.nut")
	Include("scripts/thread_handler.nut")
	Include("scripts/level_handler.nut")
	Include("scripts/level_generator.nut")
	Include("scripts/bonus.nut")
	Include("scripts/locale.nut")
	Include("scripts/minimap.nut")
	Include("scripts/particle_emitter.nut")
	Include("scripts/save.nut")
	Include("scripts/stopwatch_handler.nut")
	Include("scripts/title.nut")
	Include("scripts/ui.nut")
	Include("scripts/game_ui.nut")
	Include("scripts/utils.nut")
	Include("scripts/vfx.nut")


function	GlobalSaveGame()
{
	local	_game = ProjectGetScriptInstance(g_project)
	_game.save_game.SavePlayerData(_game.player_data)
}

//
class	TitleScreenLogic
{
	dispatch			=	0

	scene				=	0

	function	Setup(game, project)
	{
		print("TitleScreenLogic::Setup()")
		scene = ProjectInstantiateScene(project, "levels/title.nms")
		ProjectAddLayer(project, scene, 0.5)
		dispatch = Update
	}
	function	Update(game, project)
	{
		if	(ProjectSceneGetScriptInstance(scene).state == "startgame")
		{
			UISetCommandList(SceneGetUI(ProjectSceneGetInstance(scene)), "globalfade 0.5, 1;")
			dispatch = FadeOut
		}
	}
	function	FadeOut(game, project)
	{
		if	(UIIsCommandListDone(SceneGetUI(ProjectSceneGetInstance(scene))))
		{
			ProjectUnloadScene(project, scene)
			game.screen_logic = GameScreenLogic()
		}
	}

	function	Dispatch(game, project)
	{
		dispatch(game, project)
	}
	constructor()
	{
		dispatch = Setup
	}
}

//
class	GameScreenLogic
{
	dispatch			=	0

	scene				=	0

	function	Setup(game, project)
	{
		print("GameScreenLogic::Setup()")
		scene = ProjectInstantiateScene(project, "levels/level_" + game.player_data.current_level.tostring() + ".nms")
		ProjectAddLayer(project, scene, 0.5)
		dispatch = Update
	}

	function	Update(game, project)
	{
		if	(ProjectSceneGetScriptInstance(scene).state == "ExitGame")
		{
			print("GameScreenLogic::Update() state = " + ProjectSceneGetScriptInstance(scene).state)
			ProjectUnloadScene(project, scene)
			game.screen_logic = TitleScreenLogic()
		}
		else
		if	(ProjectSceneGetScriptInstance(scene).state == "NextGame")
		{
			print("GameScreenLogic::Update() state = " + ProjectSceneGetScriptInstance(scene).state)

			game.player_data.current_level++
			game.save_game.SavePlayerData(game.player_data)

			ProjectUnloadScene(project, scene)
			game.screen_logic = GameScreenLogic()
		}
		
	}

	function	Dispatch(game, project)
	{
		dispatch(game, project)
	}
	constructor()
	{
		dispatch = Setup
	}
}

//
class	ProjectHandler
{
	screen_logic		=	0

	save_game			=	0

	player_data		=	{
			current_level		=	0
	}

	constructor()
	{
		print("ProjectHandler::constructor()")
		save_game = SaveGame()
	}

	function	OnUpdate(project)
	{
		screen_logic.Dispatch(this, project)
	}

	function	OnSetup(project)
	{
		print("ProjectHandler::OnSetup()")
		player_data = save_game.LoadPlayerData(player_data)
		screen_logic = TitleScreenLogic()
	}
}
