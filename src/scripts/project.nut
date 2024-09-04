/*
	File: 04 - Simple Ball Game with a Title/simple_ball.nut
	Author: Emmanuel Julien
*/

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
		scene = ProjectInstantiateScene(project, "levels/test_level_0.nms")
		ProjectAddLayer(project, scene, 0.5)

		dispatch = Update
	}
	function	Update(game, project)
	{
		if	(ProjectSceneGetScriptInstance(scene).state == "ExitGame")
		{
			ProjectUnloadScene(project, scene)
			game.screen_logic = TitleScreenLogic()
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

	function	OnUpdate(project)
	{
		screen_logic.Dispatch(this, project)
	}
	function	OnSetup(project)
	{
		print("ProjectHandler::OnSetup()")
		screen_logic = TitleScreenLogic()
	}
}
