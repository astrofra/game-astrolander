/*
	File: 04 - simple ball game with a title/title.nut
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

	/*
	*/
	function	OnUpdate(scene)
	{
		title_ui.UpdateCursor()

		if	(DeviceIsKeyDown(g_device, KeySpace))
		{
			StartGame()
		}		
	}

	function	StartGame()
	{
			print("Title::StartGame()")
//			MixerChannelUnlock(g_mixer, channel_music)
//			MixerChannelUnlockAll(g_mixer)
			MixerChannelStop(g_mixer, channel_music)
//			MixerChannelStopAll(g_mixer)
			state = "startgame"
	}

	/*
	*/
	function	OnSetup(scene)
	{
		print("Title::OnSetup()")
		ui = SceneGetUI(scene)
		UICommonSetup(ui)
		title_ui = TitleUI(ui)
	}

	function	OnSetupDone(scene)
	{
		print("Title::OnSetupDone()")

		MixerChannelStopAll(g_mixer)
//		MixerChannelUnlockAll(g_mixer)
//		channel_music = MixerStreamStart(g_mixer, "audio/music/bobby_cole-downtempo_guitar_interval-w.ogg")
//		MixerChannelSetGain(g_mixer, channel_music, 0.5)
//		MixerChannelSetLoopMode(g_mixer, channel_music, LoopRepeat)
	}
}
