/*
	AstroLander, main project file.
	Author : Francois Gutherz
*/

	Include("scriptlib/nad.nut")
	Include("scripts/globals.nut")
	Include("scripts/locale.nut")
	Include("scripts/global_callbacks.nut")
	Include("scripts/base_project.nut")
	Include("scripts/ace_deleter.nut")
	Include("scripts/achievements.nut")
	Include("scripts/slideshow.nut")
	Include("scripts/camera_handler.nut")
	Include("scripts/feedback_emitter.nut")
	Include("scripts/inventory.nut")
	Include("scripts/thread_handler.nut")
	Include("scripts/screen_game.nut")
	Include("scripts/level_generator.nut")
	Include("scripts/bonus.nut")
	Include("scripts/minimap.nut")
	Include("scripts/particle_emitter.nut")
	Include("scripts/save.nut")
	Include("scripts/stopwatch_handler.nut")
	Include("scripts/ui.nut")
	Include("scripts/screen_title_ui.nut")
	Include("scripts/screen_title.nut")
	Include("scripts/screen_game_ui.nut")
	Include("scripts/screen_level_end_ui.nut")
	Include("scripts/utils.nut")
	Include("scripts/vfx.nut")

//------------------------------------------------
class	ProjectHandler	extends	BaseProjectHandler
//------------------------------------------------
{
	keyboard_device		=	0
	save_game			=	0

	player_data		=	{
			guid					=	""
			nickname 				=	""
			total_score				=	0
			current_selected_level	=	0
			current_level			=	0
			latest_run				=	0
	}

	function	ProjectStartGame()
	{
		ProjectGotoScene(ProjectGetCurrentLevelFilename())
	}

	function	ProjectGetCurrentLevelFilename()
	{
		return ("levels/level_" + player_data.current_level.tostring() + ".nms")
	}

	function	OnUpdate(project)
	{
		GenerateEncodedTimeStamp()
		base.OnUpdate(project)
/*
		if (!IsTouchPlatform())
		{
			if (DeviceKeyPressed(keyboard_device, KeyR))
			{
				print("ProjectHandler::Faking a Render Context Loss!!!")
				OnRenderContextChanged()
			}
	
			if (DeviceKeyPressed(keyboard_device, KeyB))
			{
				print("ProjectHandler::Faking the Android Device 'Back' button pressed !!!")
				OnHardwareButtonPressed(HardwareButtonBack)
			}
		}
*/
	}

	function	OnSetup(project)
	{
		base.OnSetup(project)
		GlobalLoadGame()
		if (player_data.nickname == "")
			player_data.nickname = g_locale.guest_nickname + " " + (Irand(1,9) * 100 + Irand(0,9) * 10 + Irand(0,9)).tostring()

		if (!IsTouchPlatform())
			keyboard_device = GetKeyboardDevice()
	}
	
	constructor()
	{
		LoadLocaleTable()
		base.constructor()
		save_game = SaveGame()
	}
}