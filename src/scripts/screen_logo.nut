/*
	File: scripts/screen_logo.nut
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

	ui					=	0

	logo				=	0
	logo_flash			=	0
	logo_handler		=	0

	owloh_sprite		=	0
	oh_sprite			=	0

	update_function		=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		update_function(scene)
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		ui = SceneGetUI(scene)
		CreateOpaqueScreen(ui)
		update_function = ShowOwlLogo //ShowAstrofraLogo
	}

	function	ShowAstrofraLogo(scene)
	{
		logo_handler = UIAddWindow(ui, -1, 0, 0, 2, 2)

		logo = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/astrofra_logo.png"), 0, 0, 256, 256)
		WindowSetPivot(logo, 128, 128)
		WindowSetPosition(logo, g_screen_width / 2.0, g_screen_height / 2.0 - 16.0)
		WindowSetParent(logo, logo_handler)

		logo_flash = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/astrofra_logo_flash.png"), 0, 0, 256, 256)
		WindowSetPivot(logo_flash, 128, 128)
		WindowSetPosition(logo_flash, g_screen_width / 2.0, g_screen_height / 2.0 - 16.0)
		WindowSetOpacity(logo_flash, 1.0)
		WindowSetParent(logo_flash, logo_handler)

		WindowSetScale(logo, 0.9, 0.875)
		WindowSetScale(logo_flash, 0.9, 0.875)

		WindowSetCommandList(logo_handler, "nop 0.125;toposition 0.25,0,-4;toposition 0.25,0,-10;")
		WindowSetCommandList(logo_flash, "toalpha 0,1;toalpha 2.0,0;")

		if (g_sound_enabled)
			sfx_channel = MixerSoundStart(g_mixer, EngineLoadSound(g_engine, "audio/sfx/sfx_startup_sound.wav"))

		display_timer = g_clock
		update_function = WaitOnAstrofraLogo
	}

	function	WaitOnAstrofraLogo(scene)
	{
		if ((g_clock - display_timer) > SecToTick(Sec(3.0)))
		{
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
			update_function = Idle
		}
	}

	function	ShowOwlLogo(scene)
	{
		owloh_sprite = addSprite(ui, EngineLoadTexture(g_engine, "ui/owl_logo.png"), g_screen_width * 0.5, g_screen_height * 0.5, 336, 300, true)
		oh_sprite = addSprite(ui, EngineLoadTexture(g_engine, "ui/owl_logo_oh.png"), 290 - 25 + 2.5, -2.5, 88, 85, true)
		WindowSetParent(oh_sprite, owloh_sprite)
		SpriteSetZOrder(oh_sprite, -0.01)
		SpriteSetOpacity(oh_sprite, 0)

		SpriteSetScale(owloh_sprite, 1.25 * 1.265, 1.25 * 1.265)

		display_timer = g_clock
		update_function = ShowOwlScreech
	}

	function	ShowOwlScreech(scene)
	{
		if ((g_clock - display_timer) > SecToTick(Sec(1.0)))
		{
			SpriteSetOpacity(oh_sprite, 1.0)
//			MixerStreamStart(g_mixer, "sfx_owl_screech.ogg")
			display_timer = g_clock
			update_function = WaitOnOwlLogo
		}
	}

	function	WaitOnOwlLogo(scene)
	{
		if ((g_clock - display_timer) > SecToTick(Sec(2.0)))
		{
			WindowSetCommandList(owloh_sprite, "toalpha 0.25,0;")
			WindowSetCommandList(oh_sprite, "toalpha 0.15,0;")
			display_timer = g_clock
			update_function = WaitFadeOwlLogo
		}
	}

	function	WaitFadeOwlLogo(scene)
	{
		if ((g_clock - display_timer) > SecToTick(Sec(0.5)))
			update_function = ShowAstrofraLogo
	}

	function	Idle(scene)
	{
	}
}
