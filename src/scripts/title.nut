/*
	File: 04 - simple ball game with a title/title.nut
	Author: Emmanuel Julien
*/
		Include("scripts/locale.nut")
		Include("scripts/globals.nut")
		Include("scripts/ui.nut")


g_ui_cursor <- UICreateCursor(0);


/*
*/
class	Title
{
	ui						=	0
	title_ui				=	0

	sfx_music				=	0
	channel_music			=	0

	w_cfg_control_reverse	=	0

	state			=	"running"

	/*
	*/
	function	OnUpdate(scene)
	{
		local ui_device = GetInputDevice("mouse")
		UISetCursorState(ui, g_ui_cursor, DeviceInputValue(ui_device, DeviceAxisX), DeviceInputValue(ui_device, DeviceAxisY), DeviceIsKeyDown(ui_device, KeyButton0))

		if	(DeviceIsKeyDown(g_device, KeySpace))
		{
			StartGame()
		}		
	}

	function	StartGame()
	{
			//MixerChannelUnlock(g_mixer, channel_music)
			//MixerChannelStop(g_mixer, channel_music)
			MixerChannelStopAll(g_mixer)
			MixerChannelUnlockAll(g_mixer)
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
/*
		sfx_music = EngineLoadSound(g_engine, "audio/music/intro_riff.wav")
*/
	}

	function	OnSetupDone(scene)
	{
		print("Title::OnSetupDone()")
		MixerChannelStopAll(g_mixer)
		MixerChannelUnlockAll(g_mixer)
		//channel_music = MixerSoundStart(g_mixer, sfx_music)
		//MixerChannelSetGain(g_mixer, channel_music, 0.5)
		//MixerChannelSetLoopMode(g_mixer, channel_music, LoopRepeat)
	}
}
