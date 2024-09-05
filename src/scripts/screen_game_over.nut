/*
	File: scripts/screen_game_over.nut
	Author: Astrofra
*/

/*!
	@short	LogoScreen
	@author	Astrofra
*/
class	GameOverScreen	extends	BaseUI
{
	display_timer		=	0

	back_button			=	0
	skip_arrow			=	0
	skip_button			=	0

	constructor()
	{
		base.constructor(SceneGetUI(g_scene))
	}

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		base.Update()

		if ((g_clock - display_timer) > SecToTick(Sec(20.0)))
		{
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
			MixerChannelStopAll(g_mixer)
		}
	}
	
	function	OnSetup(scene)
	{
		print("GameOverScreen::OnSetup()")
		display_timer = g_clock
		local	story_texture, fname

		CreateOpaqueScreen(ui)
	
		fname = "ui/story_game_over.jpg"
		if (FileExists(fname))
		{
			story_texture = EngineLoadTexture(g_engine, fname)
			local	story_image
			story_image = UIAddSprite(ui, -1, story_texture, 0, 0, TextureGetWidth(story_texture), TextureGetHeight(story_texture))
			WindowShow(story_image, false)
			WindowSetPivot(story_image, TextureGetWidth(story_texture) * 0.5, TextureGetHeight(story_texture) * 0.5)
			WindowSetPosition(story_image, g_screen_width * 0.5, g_screen_height * 0.5)
			WindowSetOpacity(story_image, 0.0)
			WindowSetCommandList(story_image, "nop 0.5; show; toalpha 2.0, 1.0+toscale 10.0,1.1,1.1;")
		}
		else
		{
			print("GameOverScreen::ShowStoryImage() : Cannot find file '" + fname + "'.")
		}

		//	Back button
		local	back_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_left.png"), 16, 700, 256, 128)
		back_button = LabelWrapper(ui, "Back", 10, 25, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_button[0], back_arrow)
		WindowSetEventHandlerWithContext(back_arrow, EventCursorDown, this, GameOverScreen.BackToGame)
		WindowSetEventHandlerWithContext(back_button[0], EventCursorDown, this, GameOverScreen.BackToGame)

		//	Skip button
		skip_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		skip_button = LabelWrapper(ui, tr("Skip", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(skip_button[0], skip_arrow)
		WindowSetEventHandlerWithContext(skip_arrow, EventCursorDown, this, GameOverScreen.BackToTitleScreen)
		WindowSetEventHandlerWithContext(skip_button[0], EventCursorDown, this, GameOverScreen.BackToTitleScreen)
		WindowSetOpacity(skip_arrow, 0.0)
		WindowSetCommandList(skip_arrow, "toalpha 0,0;nop 1.5;toalpha 0.25,1;")
	}

	//-------------------------------------------
	function	BackToGame(event, table)
	//-------------------------------------------
	{
		ButtonFeedback(table.window)
//		MixerChannelStop(g_mixer, channel_music)
//		ProjectGetScriptInstance(g_project).player_data.current_level = current_selected_level
		ProjectGetScriptInstance(g_project).ProjectStartGame()
		PlaySfxUIValidate()
	}

	function	BackToTitleScreen(event, table)
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
//		MixerChannelStop(g_mixer, channel_music)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
	}

	//-----------------
	//	OS Interactions
	//-----------------

	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		skip_button[1].rebuild()
		skip_button[1].refresh()
	}
}
