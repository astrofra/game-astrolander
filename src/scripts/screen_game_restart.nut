/*
	File: scripts/screen_game_restart.nut
	Author: Astrofra
*/

/*!
	@short	LogoScreen
	@author	Astrofra
*/
class	ScreenGameRestart
{
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		ProjectGetScriptInstance(g_project).ProjectStartGame()
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		local	ui
		ui = SceneGetUI(scene)

		CreateOpaqueScreen(ui)
	}
}
