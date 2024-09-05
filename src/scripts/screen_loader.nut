/*
	File: scripts/screen_loader.nut
	Author: Astrofra
*/

/*!
	@short	LogoScreen
	@author	Astrofra
*/
class	LoaderScreen
{
	display_timer		=	0
	sfx_channel			=	-1
	/*!
		@short	OnUpdate
		Called each frame.
	*/

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		print("LoaderScreen::OnSetup()")
		display_timer = g_clock
		local	ui, logo, logo_flash, logo_handler
		ui = SceneGetUI(scene)

		CreateOpaqueScreen(ui)

		logo = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/loading.png"), 0, 0, 256, 64)
		WindowSetPivot(logo, 128, 32)
		WindowSetPosition(logo, g_screen_width / 2.0, g_screen_height / 2.0) //1.125 - 16.0)
//		WindowSetOpacity(logo, 0.5)
//		WindowSetCommandList(logo, "loop;toalpha 0,0.35;toalpha 0,0.25;toalpha 0,0.45;toalpha 0,0.25;toalpha 0,0.4;next;")
	}
}
