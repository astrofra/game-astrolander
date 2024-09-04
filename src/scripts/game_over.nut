/*
	File: scripts/logo.nut
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
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/title.nms")
			MixerChannelStopAll(g_mixer)
		}
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	
	function	ShowStoryImage(scene)
	{
		print("GameOverScreen::ShowStoryImage()")
		local	story_texture, fname
		local	ui = SceneGetUI(scene)
		
		fname = "ui/story_game_over.jpg"
		if (FileExists(fname))
		{
			story_texture = EngineLoadTexture(g_engine, fname)
			local	story_image
			story_image = UIAddSprite(ui, -1, story_texture, 0, 0, TextureGetWidth(story_texture), TextureGetHeight(story_texture))
			WindowShow(story_image, false)
			WindowSetPivot(story_image, TextureGetWidth(story_texture) * 0.5, TextureGetHeight(story_texture) * 0.5)
			WindowSetPosition(story_image, 1280.0 * 0.5, 960.0 * 0.5)
			WindowSetOpacity(story_image, 0.0)
			WindowSetCommandList(story_image, "nop 0.5; show; toalpha 2.0, 1.0+toscale 10.0,1.1,1.1;")
		}
		else
		{
			print("LevelEndUI::ShowStoryImage() : Cannot find file '" + fname + "'.")
		}
	}
	
	function	OnSetupDone(scene)
	{
		ShowStoryImage(scene)
	}
	
	function	OnSetup(scene)
	{
		display_timer = g_clock
		//MixerSoundStart(g_mixer, EngineLoadSound(g_engine, "audio/sfx/sfx_polaroid.wav"))
	}
}
