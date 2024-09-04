/*
	File: 04 - simple ball game with a title/title.nut
	Author: Emmanuel Julien
*/
		Include("scripts/locale.nut")
		Include("scripts/globals.nut")
/*
*/
class	Title
{
	ui						=	0

	sfx_music				=	0
	channel_music			=	0

	w_cfg_control_reverse	=	0

	state			=	"running"

	timeout			=	0

	/*
	*/
	function	OnUpdate(scene)
	{
		timeout -= g_dt_frame

		if	((timeout < 0) || DeviceIsKeyDown(g_device, KeySpace))
		{
			MixerChannelUnlock(g_mixer, channel_music)
			MixerChannelStop(g_mixer, channel_music)
			//MixerChannelStopAll(g_mixer)
			//MixerChannelUnlockAll(g_mixer)
			state = "startgame"
		}
		else
		if	(DeviceKeyPressed(g_device, KeyF1))
		{
			g_reversed_controls = !g_reversed_controls
			TextSetText(w_cfg_control_reverse[1], CreateStringControlReverse())
		}
		
	}

	function	CreateTitleLabel(name, x, y, size = 70, w = 300, h = 64, font_name = "creative_block")
	{
		local	window = UIAddWindow(ui, -1, x, y, w, h)
		WindowSetPivot(window, w / 2, h / 2)
		local	widget = UIAddStaticTextWidget(ui, -1, name, font_name)
		WindowSetBaseWidget(window, widget)
		TextSetSize(widget, size)
		TextSetColor(widget, 64, 32, 160, 255)
		TextSetAlignment(widget, TextAlignCenter)

		return ([window, widget])
	}

	/*
	*/
	function	OnSetup(scene)
	{
		print("Title::OnSetup()")
		ui = SceneGetUI(scene)
		UILoadFont("ui/creative_block.ttf")

		CreateTitleLabel(g_locale.press_space, 640, 600, 60, 400)
		CreateTitleLabel(g_locale.copyright, 640, 900, 32, 900, 64)

		w_cfg_control_reverse = CreateTitleLabel(CreateStringControlReverse(), 640, 650, 28, 400, 64)

		sfx_music = EngineLoadSound(g_engine, "audio/music/intro_riff.wav")

		timeout = Sec(4)
	}

	function	CreateStringControlReverse()
	{	return (g_locale.control_reverse + " (F1) : " + (g_reversed_controls?g_locale.yes:g_locale.no))	}

	function	OnSetupDone(scene)
	{
		print("Title::OnSetupDone()")
		MixerChannelStopAll(g_mixer)
		MixerChannelUnlockAll(g_mixer)
		channel_music = MixerSoundStart(g_mixer, sfx_music)
		//MixerChannelSetGain(g_mixer, channel_music, 0.5)
		MixerChannelSetLoopMode(g_mixer, channel_music, LoopRepeat)
	}
}
