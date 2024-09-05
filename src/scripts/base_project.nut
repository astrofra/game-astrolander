/*
*/	

//
class	BaseProjectHandler
{
	scene				=	0
	scene_filename		=	""
	prev_scene_filename	=	""
	black_screen_scene	=	0

	first_scene_filename	=	"levels/screen_logo.nms"
	
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
			if (!UIIsCommandListDone(SceneGetUI(ProjectSceneGetInstance(scene))))
				UISetCommandList(SceneGetUI(ProjectSceneGetInstance(black_screen_scene)), "globalfade 0.1,1;")
			else
			{
				ProjectUnloadScene(project, black_screen_scene)
				black_screen_scene = 0
			}
		}

	}
	
	function	LeaveCurrentScene(project, scene)
	{
		if (scene != 0)
			if (!UIIsCommandListDone(SceneGetUI(ProjectSceneGetInstance(scene))))
				return

		black_screen_scene = ProjectInstantiateScene(project, "levels/screen_loader.nms")
//		UISetCommandList(SceneGetUI(ProjectSceneGetInstance(black_screen_scene)), "nop 0.1;")
		ProjectAddLayer(project, black_screen_scene, -1.0)

		dispatch = LoadNextScene
	}

	function	LoadNextScene(project, scene)
	{
		if	(!UIIsCommandListDone(SceneGetUI(ProjectSceneGetInstance(black_screen_scene))))
			return

		if (scene == 0)
		{
			ProjectLoadScene(project, scene_filename)
			UISetCommandList(SceneGetUI(ProjectSceneGetInstance(black_screen_scene)), "globalfade 0.25, 1;")
			prev_scene_filename = scene_filename
			dispatch = MainUpdate
		}
		else
		{
			if	(UIIsCommandListDone(SceneGetUI(ProjectSceneGetInstance(scene))))
			{
				ProjectUnloadScene(project, scene)
				ProjectLoadScene(project, scene_filename)
				UISetCommandList(SceneGetUI(ProjectSceneGetInstance(black_screen_scene)), "globalfade 0.25, 1;")
				prev_scene_filename = scene_filename
				dispatch = MainUpdate
			}
		}
	}

	function	ProjectLoadScene(project, scene_filename)
	{
		if	(FileExists(scene_filename))
		{
			print("ProjectHandler::ProjectLoadScene() Loading scene '" + scene_filename + "'.")
			scene = ProjectInstantiateScene(project, scene_filename)
			UISetCommandList(SceneGetUI(ProjectSceneGetInstance(scene)), "globalfade 0,1; nop 0.1; globalfade 0.25, 0;")
			ProjectAddLayer(project, scene, 0.5)
		}
		else
			error("ProjectHandler::ProjectLoadScene() Cannot find scene '" + scene_filename + "'.")

		return	scene
	}

	function	OnSetup(project)
	{
		print("ProjectHandler::OnSetup()")
		ProjectGotoScene(first_scene_filename)
	}
	
	constructor()
	{
		print("ProjectHandler::constructor()")
		dispatch = MainUpdate
	}
}
