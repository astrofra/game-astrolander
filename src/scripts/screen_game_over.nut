/*
	File: scripts/screen_game_over.nut
	Author: Astrofra
*/

/*!
	@short	LogoScreen
	@author	Astrofra
*/
class	GameOverScreen
{
	display_timer		=	0
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		if ((g_clock - display_timer) > SecToTick(Sec(10.0)))
		{
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
			MixerChannelStopAll(g_mixer)
		}
	}
	
	function	OnSetup(scene)
	{
		print("GameOverScreen::OnSetup()")
		display_timer = g_clock
		local	ui, story_texture, fname
		ui = SceneGetUI(scene)

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
	}
}
