/*
	File: 04 - simple ball game with a title/title.nut
	Author: Emmanuel Julien
*/

/*
*/
class	Title
{
	ui				=	0

	sfx_music		=	0
	channel_music	=	0

	state			=	"running"

	/*
	*/
	function	OnUpdate(scene)
	{
		KeyboardUpdate()
		if	(KeyboardSeekFunction(DeviceKeyPress, KeySpace))
		{
			MixerChannelStopAll(g_mixer)
			MixerChannelUnlockAll(g_mixer)
			state = "startgame"
		}
	}

	function	CreateTitleLabel(name, x, y, size = 70, w = 300, h = 64)
	{
		local	window = UIAddWindow(ui, -1, x, y, w, h)
		WindowSetPivot(window, w / 2, h / 2)
		local	widget = UIAddStaticTextWidget(ui, -1, name, "creative_block")
		WindowSetBaseWidget(window, widget)
		TextSetSize(widget, size)
		TextSetColor(widget, 64, 32, 160, 255)
		TextSetAlignment(widget, TextAlignCenter)
	}

	/*
	*/
	function	OnSetup(scene)
	{
		print("Title::OnSetup()")
		ui = SceneGetUI(scene)
		UILoadFont("ui/creative_block.ttf")

		CreateTitleLabel("Press Space", 640, 600, 60, 400)
		CreateTitleLabel("A game by Astrofra (c) 2011 Mutant Inc.", 640, 900, 32, 900, 64)

		sfx_music = EngineLoadSound(g_engine, "audio/music/intro_riff.wav")
	}

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
