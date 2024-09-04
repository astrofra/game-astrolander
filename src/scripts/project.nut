/*
	File: 04 - Simple Ball Game with a Title/simple_ball.nut
	Author: Emmanuel Julien
*/

	Include("scriptlib/nad.nut")
	Include("scripts/globals.nut")
	Include("scripts/project_base.nut")
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
	Include("scripts/ui.nut")
	Include("scripts/title_ui.nut")
	Include("scripts/title.nut")
	Include("scripts/game_ui.nut")
	Include("scripts/level_end_ui.nut")
	Include("scripts/utils.nut")
	Include("scripts/vfx.nut")


function	GlobalSaveGame()
{
	local	_game = ProjectGetScriptInstance(g_project)
	_game.save_game.SavePlayerData(_game.player_data)
}

//
class	ProjectHandler	extends	ProjectHandlerBase
{
	save_game			=	0

	player_data		=	{
			current_level		=	0
			score				=	0
			latest_run			=	0
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
		base.OnUpdate(project)
	}

	function	OnSetup(project)
	{
		base.OnSetup(project)
	}
	
	constructor()
	{
		base.constructor()
	}
}