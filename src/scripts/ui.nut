/* UI
*/

g_ui_IDs			<-	0
g_hud_font_color	<-	Vector(0,0,0,255)

function	CreateNewUIID()
{
	g_ui_IDs++
	return g_ui_IDs
}

function	UICommonSetup(ui)
{
	UILoadFont("ui/banksb20caps.ttf")
	UILoadFont("ui/aerial.ttf")
	UILoadFont("ui/profont.ttf")

/*	
	//	Enable this and watch the editor crash.
    UISetSkin    (
                    ui, "ui/skin/t.png", "ui/skin/l.png", "ui/skin/r.png", "ui/skin/b.png",
                    "ui/skin/tl.png", "ui/skin/tr.png", "ui/skin/bl.png", "ui/skin/br.png", 0xff9ebc24,
                    0xffffffff, 30, 20, 10, "anna"
                )
*/


}

function	CreateOpaqueScreen(ui)
{
		//ui = SceneGetUI(scene)
		local	_black_screen
		_black_screen = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "graphics/black.jpg"), 1280.0 / 2.0, 960.0 / 2.0, 16.0, 16.0)
		WindowSetPivot(_black_screen, 8, 8)
		WindowCentre(_black_screen)
		WindowSetScale(_black_screen, 2048.0 / 16.0 * 1.5, 2048 / 16.0 * 1.5)
		WindowSetZOrder(_black_screen, 1.0)
}

//----------------------
function	CreateLabel(ui, name, x, y, size = 32, w = 200, h = 64, font_color = g_hud_font_color, font_name = "aerial", text_align = TextAlignLeft)
//----------------------
{
	// Create UI window.
	local	_id
	_id = CreateNewUIID()
	local	window = UIAddWindow(ui, _id, x, y, w, h)

	// Center window pivot.
	//WindowSetPivot(window, w / 2, h / 2)

	// Create UI text widget and set as window base widget.
	local	widget = UIAddStaticTextWidget(ui, -1, name, font_name)
	WindowSetBaseWidget(window, widget)

	// Set text attributes.
	TextSetSize(widget, size)
	TextSetColor(widget, font_color.x, font_color.y, font_color.z, font_color.w)
	TextSetAlignment(widget, text_align)

	// Return window.
	return [ window, widget, _id ]
}

//------------
class	BaseUI
//------------
{
	ui				=	0
	cursor_sprite	=	0

	cursor_prev_x	=	0
	cursor_prev_y	=	0

	fade_timeout	=	0
	cursor_opacity	=	1.0

	sfx_select		=	0
	sfx_validate	=	0
	sfx_page		=	0
	sfx_pause		=	0

	//--------------
	constructor(_ui)
	//--------------
	{
		ui = _ui

		local	_texture = EngineLoadTexture(g_engine, "ui/cursor.png")

		if (!g_is_touch_platform)
		{
			cursor_sprite = UIAddSprite(ui, -1, _texture, 0, 0, TextureGetWidth(_texture),	TextureGetHeight(_texture))
			WindowSetScale(cursor_sprite, 2.0, 2.0)
			WindowSetZOrder(cursor_sprite, -1)
		}

		fade_timeout = g_clock
		cursor_opacity	=	1.0

		LoadSounds()
	}

	function	LoadSounds()
	{
		sfx_select = EngineLoadSound(g_engine, "audio/sfx/gui_up_down.wav")
		sfx_validate = EngineLoadSound(g_engine, "audio/sfx/gui_validate.wav")
		sfx_page = EngineLoadSound(g_engine, "audio/sfx/gui_next_page.wav")
		sfx_pause = EngineLoadSound(g_engine, "audio/sfx/gui_game_pause.wav")
	}

	function	PlaySfxUISelect()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_select)	}

	function	PlaySfxUIValidate()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_validate)	}

	function	PlaySfxUINextPage()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_page)	}

	function	PlaySfxUIPause()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_pause)	}

	function	FadeTimeout()
	{
		if ((g_clock - fade_timeout) > SecToTick(Sec(5.0)))
			cursor_opacity = Clamp((cursor_opacity - g_dt_frame), 0.0, 1.0)
		else
			cursor_opacity = Clamp((cursor_opacity + 10.0 * g_dt_frame), 0.0, 1.0)

		WindowSetOpacity(cursor_sprite, cursor_opacity)	
	}

	//------------------------
	function	UpdateCursor()
	//------------------------
	{
		local ui_device = GetInputDevice("mouse")
		local	_x, _y, _dx, _dy
		_x = DeviceInputValue(ui_device, DeviceAxisX)
		_y = DeviceInputValue(ui_device, DeviceAxisY)

		UISetCursorState(ui, g_ui_cursor, _x, _y, DeviceIsKeyDown(ui_device, KeyButton0))

		_dx = Abs(_x - cursor_prev_x)
		_dy = Abs(_y - cursor_prev_y)

		cursor_prev_x = _x
		cursor_prev_y = _y

		if (!g_is_touch_platform)
		{
			//	Actual desktop cursor
			local	dr = RendererGetViewport(g_render)

			local	viewport_ar = dr.z / dr.w
			local	reference_ar = 1280.0 / 960.0

			local	kx = viewport_ar / reference_ar, ky = 1.0

			_x = (_x - 0.5) * kx + 0.5
			_y = (_y - 0.5) * ky + 0.5

			WindowSetPosition(cursor_sprite, _x * 1280.0, _y * 960.0)

			if ((_dx > 0.0) || (_dx > 0.0))
				fade_timeout = g_clock

			FadeTimeout()
	
		}


	}

}

