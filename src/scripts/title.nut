/*
	File: 04 - simple ball game with a title/title.nut
	Author: Emmanuel Julien
*/

/*
*/
class	Title
{
	ui			=	0

	state		=	"running"

	/*
	*/
	function	OnUpdate(scene)
	{
		KeyboardUpdate()
		if	(KeyboardSeekFunction(DeviceKeyPress, KeySpace))
			state = "startgame"
	}

	function	CreateLabel(name, x, y, size = 70, w = 300, h = 64)
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
		ui = SceneGetUI(scene)
		UILoadFont("ui/creative_block.ttf")

		CreateLabel("Press Space", 640, 600, 60, 400)
		CreateLabel("A game by Astrofra (c) 2011 Mutant Inc.", 640, 900, 32, 900, 64)
	}
}
