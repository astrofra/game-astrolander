/*
	File: 04 - simple ball game with a title/screen_title.nut
	Author: Emmanuel Julien
*/

g_ui_cursor <- UICreateCursor(0);

/*
*/
class	Title
{
	ui						=	0
	title_ui				=	0

	channel_music			=	0

	w_cfg_control_reverse	=	0

	state			=	"running"

	//------------------------------
	function	NicknameChanged(str)
	//------------------------------
	{
		print("Title::NicknameChanged() str = " + str)
		ProjectGetScriptInstance(g_project).player_data.nickname = str
		GlobalSaveGame()
	}

	//-------------------------
	function	OnUpdate(scene)
	//-------------------------
	{
		title_ui.Update()
	}

	//---------------------
	function	StartGame()
	//---------------------
	{
		print("Title::StartGame()")
		MixerChannelStop(g_mixer, channel_music)
		ProjectGetScriptInstance(g_project).ProjectStartGame()
	}

	//---------------------------
	function	GotoLeaderboard()
	//---------------------------
	{
		print("Title::GotoLeaderboard()")
		MixerChannelStop(g_mixer, channel_music)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_leaderboard.nms")
	}

	//-----------------------
	function	GotoCredits()
	//-----------------------
	{
		print("Title::GotoCredits()")
		MixerChannelStop(g_mixer, channel_music)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_credits.nms")
	}

	//-----------------------------
	function	ReloadTitleScreen()
	//-----------------------------
	{
		print("Title::ReloadTitleScreen()")
		MixerChannelStop(g_mixer, channel_music)
		ProjectGetScriptInstance(g_project).prev_scene_filename = ""
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
	}

	//------------------------
	function	OnSetup(scene)
	//------------------------
	{
		print("Title::OnSetup()")
		ui = SceneGetUI(scene)
		UICommonSetup(ui)
		title_ui = TitleUI(ui)
		title_ui.nickname_textfield.RegisterDefocusCallback(this, "NicknameChanged")
		title_ui.nickname_textfield.SetText(ProjectGetScriptInstance(g_project).player_data.nickname)
	}

	//----------------------------
	function	OnSetupDone(scene)
	//----------------------------
	{
		print("Title::OnSetupDone()")

		if (g_sound_enabled) channel_music = MixerStreamStart(g_mixer, "audio/music/chill_main_menu_music.ogg")
		TitleScreenSetMusicVolume()
		MixerChannelSetLoopMode(g_mixer, channel_music, LoopRepeat)
	}

	function	TitleScreenSetMusicVolume()
	{
		MixerChannelSetGain(g_mixer, channel_music, GlobalGetMusicVolume())
	}
	
	//-----------------
	//	OS Interactions
	//-----------------
	
	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		title_ui.OnRenderContextChanged()
	}
	
	//-----------------------------------------
	function	OnHardwareButtonPressed(button)
	//-----------------------------------------
	{
		switch (button)
		{
			case	HardwareButtonBack:
				print("ScreenTitle::OnHardwareButtonPressed(HardwareButtonBack)")
				ProjectEnd(g_project)
				break
		}
	}
}
