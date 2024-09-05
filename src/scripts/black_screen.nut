/*
	File: scripts/black_screen.nut
	Author: Astrofra
*/

/*!
	@short	levels_black_screen
	@author	Astrofra
*/
class	levels_black_screen
{
	ui		=	0
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		local	ui = SceneGetUI(scene)
		CreateOpaqueScreen(ui)
		//local	_label = CreateLabel(ui, tr("Loading"), (g_screen_width * 0.5) - 200, g_screen_height * 0.8, 30, 400, 64, g_ui_color_white, g_hud_font_name, TextAlignCenter)
		//WindowSetCommandList(_label[0], "loop;toalpha 0,0.5;nop 2;toalpha 0,0.25;nop 2;next;")
	}
}
