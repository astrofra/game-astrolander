/*
*/	

//
class	BaseProjectHandler
{
	scene				=	0
	scene_filename		=	""
	prev_scene_filename	=	""
	black_screen_scene	=	0
	
	dispatch			=	0
	
	function	ProjectGotoScene(_fname)
	{
		scene_filename = _fname
	}

	function	OnUpdate(project)
	{
		dispatch(project, scene)
	}
	
	function	MainUpdate(project, scene)
	{
		if (scene_filename != prev_scene_filename)
		{
			dispatch = LeaveCurrentScene
			if (scene != 0)
				UISetCommandList(SceneGetUI(ProjectSceneGetInstance(scene)), "globalfade 0.25, 1;")
		}

		if (black_screen_scene != 0)
		{
			ProjectUnloadScene(project, black_screen_scene)
			black_screen_scene = 0
		}
	}
	
	function	LeaveCurrentScene(project, scene)
	{
		if (scene == 0)
		{
			ProjectLoadScene(project, scene_filename)
			prev_scene_filename = scene_filename
			dispatch = MainUpdate
		}
		else
		{
			if	(UIIsCommandListDone(SceneGetUI(ProjectSceneGetInstance(scene))))
			{
				ProjectUnloadScene(project, scene)		
				ProjectLoadScene(project, scene_filename)
				prev_scene_filename = scene_filename
				dispatch = MainUpdate
			}
		}
	}

	function	ProjectLoadScene(project, scene_filename)
	{
		if	(FileExists(scene_filename))
		{
			//	Create a black screen
			black_screen_scene = ProjectInstantiateScene(project, "levels/black_screen.nms")
			ProjectAddLayer(project, black_screen_scene, -1.0)

			print("ProjectHandler::LeaveCurrentScene() Loading scene '" + scene_filename + "'.")
			scene = ProjectInstantiateScene(project, scene_filename)
			ProjectAddLayer(project, scene, 0.5)
			UISetCommandList(SceneGetUI(ProjectSceneGetInstance(scene)), "globalfade 0,1; nop 0.1; globalfade 0.25, 0;")
		}
		else
			error("ProjectHandler::LeaveCurrentScene() Cannot find scene '" + scene_filename + "'.")

		return	scene
	}

	function	OnSetup(project)
	{
		print("ProjectHandler::OnSetup()")
		ProjectGotoScene("levels/preloader.nms")
	}
	
	constructor()
	{
		print("ProjectHandler::constructor()")
		dispatch = MainUpdate
	}
}
