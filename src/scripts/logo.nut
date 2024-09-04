/*
	File: scripts/logo.nut
	Author: Astrofra
*/

/*!
	@short	LogoScreen
	@author	Astrofra
*/
class	LogoScreen
{
	display_timer		=	0
	sfx_channel			=	-1
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		if ((g_clock - display_timer) > SecToTick(Sec(5.0)))
		{
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/title.nms")
//			MixerChannelUnlock(g_mixer, sfx_channel)
//			MixerChannelStopAll(g_mixer)
		}
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		display_timer = g_clock
		local	ui, logo, logo_flash, logo_handler
		ui = SceneGetUI(scene)

		logo_handler = UIAddWindow(ui, -1, 0, 0, 2, 2)

		logo = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/astrofra_logo.png"), 0, 0, 256, 256)
		WindowSetPivot(logo, 128, 128)
		WindowSetPosition(logo, 1280 / 2.0, 960 / 2.0 - 16.0)
		WindowSetParent(logo, logo_handler)

		logo_flash = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/astrofra_logo_flash.png"), 0, 0, 256, 256)
		WindowSetPivot(logo_flash, 128, 128)
		WindowSetPosition(logo_flash, 1280 / 2.0, 960 / 2.0 - 16.0)
		WindowSetOpacity(logo_flash, 1.0)
		WindowSetParent(logo_flash, logo_handler)

		WindowSetCommandList(logo_handler, "nop 0.5;toposition 0.25,0,8;toposition 0.25,0,10;")
		WindowSetCommandList(logo_flash, "toalpha 0,1;toalpha 2.0,0;")

//		sfx_channel = MixerSoundStart(g_mixer, EngineLoadSound(g_engine, "audio/sfx/sfx_polaroid.wav"))
//		MixerChannelLock(g_mixer, sfx_channel)
	}
}
