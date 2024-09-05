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
	UILoadFont("ui/tabimyou.ttf")
	UILoadFont("ui/yanone_kaffeesatz.ttf")

/*	
	//	Enable this and watch the editor crash.
    UISetSkin    (
                    ui, "ui/skin/t.png", "ui/skin/l.png", "ui/skin/r.png", "ui/skin/b.png",
                    "ui/skin/tl.png", "ui/skin/tr.png", "ui/skin/bl.png", "ui/skin/br.png", 0xff9ebc24,
                    0xffffffff, 30, 20, 10, "anna"
                )
*/


}

//------------------------------------------------------------
function	CreateOpaqueScreen(ui, _color = Vector(0,0,0,255))
//------------------------------------------------------------
{
		//ui = SceneGetUI(scene)
		_color = _color.Scale(1.0 / 255.0)
		local	_black_screen
		local	_tex, _pic
		_tex = EngineLoadTexture(g_engine, "graphics/black.jpg")
		_pic = NewPicture(16, 16)
		PictureFill(_pic, _color)
		TextureUpdate(_tex, _pic)
		_black_screen = UIAddSprite(ui, -1, _tex, g_screen_width / 2.0, g_screen_height / 2.0, 16.0, 16.0)
		WindowSetPivot(_black_screen, 8, 8)
		WindowCentre(_black_screen)
		WindowSetScale(_black_screen, 2048.0 / 16.0 * 1.5, 2048 / 16.0 * 1.5)
		WindowSetZOrder(_black_screen, 1.0)
}

//-----------------------
class	EditableTextField
//-----------------------
{
	ui					=	0

	x					=	0
	y					=	0
	w					=	0
	h					=	0

	max_char			=	10

	back_texture 		= 	0
	back_picture 		= 	0

	border				=	6

	handler 			=	0
	label				=	0
	text 				=	""
	has_focus			=	false
	
	is_dirty			=	true

	cursor_blink_timer	=	0
	cursor_is_on		=	false

	keyboard_device		=	0

	defocus_callback_context	= 0
	defocus_callback_function	= 0

	keys_table			=	[KeyBackspace, /*KeySpace,*/ KeyA, KeyB, KeyC, KeyD, KeyE, KeyF, KeyG, KeyH, KeyI, KeyJ, KeyK, KeyL, KeyM, KeyN, KeyO, KeyP, KeyQ, KeyR, KeyS, KeyT, KeyU, KeyV, KeyW, KeyX, KeyY, KeyZ,
							KeyNumpad0, KeyNumpad1, KeyNumpad2, KeyNumpad3, KeyNumpad4, KeyNumpad5, KeyNumpad6, KeyNumpad7, KeyNumpad8, KeyNumpad9]
	sign_table			=	["<", /*" ",*/ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
							"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

	//--------------
	constructor(_ui, _w = 512.0, _h = 80.0, _x = 640.0, _y = 240.0)
	//--------------
	{
		ui	=	_ui
		keyboard_device = GetKeyboardDevice()
		text = ""
		cursor_blink_timer = g_clock
	
		x = _x
		y = _y
		w = _w
		h = _h

		//	Create the background
		//	Assign a click handler
		back_texture = EngineNewTexture(g_engine)
		back_picture = NewPicture(w, h)
		FillBackground()
		handler = UIAddSprite(ui, -1, back_texture, x, y, w, h)
		WindowSetPivot(handler, w * 0.5, h * 0.5)

		//	Create label
		label = Label(ui, w - border * 2, h - border * 2, w * 0.5 + border, h * 0.5 + border * 0.5, true, true)
		label.label = ""
		label.label_color = RGBAToHex(g_ui_color_black)
		label.font_size = 60
		label.font = g_main_font_name
		label.label_align = "left"
		label.refresh()
		WindowSetParent(label.window, handler)
		//	Assign a click handler
		WindowSetEventHandlerWithContext(label.window, EventCursorDown, this, OnTextFieldFocus)
		WindowSetEventHandlerWithContext(label.window, EventCursorLeave, this, OnTextFieldDefocus)
		
		is_dirty = true
	}

	function	FillBackground()
	{
		if (has_focus)
			PictureFill(back_picture, g_ui_color_green.Scale(1.0 / 255.0))
		else
			PictureFill(back_picture, g_ui_color_white.Scale((1.0 / 255.0) * 0.5))

		PictureFillRect(back_picture, g_ui_color_white.Scale(1.0 / 255.0), Rect(4,4, w - 4, h - 4))
		TextureUpdate(back_texture, back_picture)
	}
	
	function	rebuild()
	{
		label.rebuild()
		is_dirty = true
	}
	
	function	refresh()
	{
		label.refresh()
		is_dirty = false
	}

	//------------------
	function	Update()
	//------------------
	{
		if (!has_focus)
			return

		RefreshTextField()
	}

	//----------------------
	function	SetText(str)
	//----------------------
	{
		text = str
		is_dirty = true
		RefreshTextField()
		label.refresh()
	}

	//----------------------------
	function	RefreshTextField()
	//----------------------------
	{
		local	_key = GetKeys()
		is_dirty = false

		switch(_key)
		{
			case	"":
				break
			case	"<":
				if (text.len() > 0)
				{
					text = text.slice(0, text.len() - 1)
					is_dirty = true
				}
				break
			default:
				if (text.len() < max_char)
				{
					text += _key
					is_dirty = true
				}
				break
		}

		//	Display text content
		local	_cursor = ""

		if (has_focus)
		{
			if ((g_clock - cursor_blink_timer) > SecToTick(Sec(0.5)))
			{
				cursor_is_on = !cursor_is_on
				cursor_blink_timer = g_clock
				is_dirty = true
			}

			_cursor = cursor_is_on?"|":""
		}

		label.label = RGBAToTag(g_ui_color_black) + text + RGBAToTag(g_ui_color_red) + _cursor
		
		if (is_dirty)
		{
			label.refresh()
			print("EditableTextField::refresh()")
			is_dirty = false
		}
	}

	//------------------
	function	GetKeys()
	//------------------
	{
		foreach(i, _key in keys_table)
			if (DeviceKeyPressed(keyboard_device, _key))
				return sign_table[i]

		return	""
	}

	//-----------------------------------------
	function	OnTextFieldFocus(event, table)
	//-----------------------------------------
	{
		has_focus = true
		is_dirty = true
		FillBackground()
		label.refresh()
	}

	//-------------------------------------------
	function	OnTextFieldDefocus(event, table)
	//-------------------------------------------
	{
		has_focus = false
		is_dirty = true
		FillBackground()
		RefreshTextField()
		label.refresh()
		if (defocus_callback_function != 0)
		{
			local	callback = defocus_callback_context[defocus_callback_function]
			callback(text)
		}
	}

	//-------------------------------------------
	function	RegisterDefocusCallback(context, callback)
	//-------------------------------------------
	{
		defocus_callback_context = context
		defocus_callback_function = callback
	}
}

//-----------
class	Label
//-----------
{
	window				=	0

	texture				=	0
	picture				=	0

	label				=	"Label"
	label_color			=	0xffffffff
	label_align			=	"center"
	font				=	"default"
	font_size			=	16
	font_tracking		=	0
	font_leading		=	0
	font_vcenter		=	0

	drop_shadow			=	false
	drop_shadow_color	=	0x000000ff

	function	refresh()
	{
		local size = WindowGetSize(window)

		picture = NewPicture(size.x, size.y)
		PictureFill(picture, Vector(0, 0, 0, 0))

		if	(label != "")
		{
			local rect = PictureGetRect(picture)
			local parm = { size = font_size, color = label_color, align = label_align, format = "paragraph", tracking = font_tracking leading = font_leading }

			if	(font_vcenter)
			{
				local out_rect = TextComputeRect(rect, label, font, parm)
				rect.sy += (rect.GetHeight() - out_rect.GetHeight()) / 2.0
			}

			rect.sx += 2; rect.ex -= 2

			if	(drop_shadow)
			{
				parm.color = drop_shadow_color
				rect.sx -= 1; rect.sy += 1
				PictureTextRender(picture, rect, label, font, parm)
				rect.sx -= 1; rect.sy += 1
				PictureTextRender(picture, rect, label, font, parm)
				rect.sx += 2; rect.sy -= 2
				parm.color = label_color
			}

			PictureTextRender(picture, rect, label, font, parm)
			rect.sx -= 2; rect.ex += 2
		}

		TextureUpdate(texture, picture)
		picture = 0
	}

	function	rebuild()
	{
		TextureRelease(texture)
	}

	constructor(ui, w, h, x = 0, y = 0, center = false, vcenter = false)
	{
		texture = EngineNewTexture(g_engine)
		window = UIAddSprite(ui, -1, texture, x, y, w, h)

		if	(center)
			WindowSetPivot(window, w / 2, h / 2)

		font_vcenter = vcenter
	}
}

function	LabelWrapper(ui, name, x, y, size = 32, w = 200, h = 64, font_color = g_hud_font_color, font_name = "aerial", text_align = TextAlignLeft)
{

	local	instance, center = false, vcenter = true
	instance = Label(ui, w, h, x, y, center, vcenter)
	instance.font_size = size
	instance.label = name
	instance.font = font_name
	instance.label_color = RGBAToHex(font_color)
	switch(text_align)
	{
		case 	TextAlignCenter:
			instance.label_align = "center"
			break
		case	TextAlignLeft:
			instance.label_align = "left"
			break
		case	TextAlignRight:
			instance.label_align = "right"
			break
		default:
			instance.label_align = "center"
			break
	}

	instance.refresh()

	return [instance.window, instance]
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
	sfx_error		=	0
	sfx_page		=	0
	sfx_pause		=	0
	sfx_resume		=	0

	//--------------
	constructor(_ui)
	//--------------
	{
		ui = _ui

		//UISetInternalResolution(ui, g_screen_width, g_screen_height)

		local	_texture = EngineLoadTexture(g_engine, "ui/cursor.png")

		if (!IsTouchPlatform())
		{
			cursor_sprite = UIAddSprite(ui, -1, _texture, 0, 0, TextureGetWidth(_texture),	TextureGetHeight(_texture))
			WindowSetScale(cursor_sprite, 2.0, 2.0)
			WindowSetZOrder(cursor_sprite, -1)
		}

		fade_timeout = g_clock
		cursor_opacity	=	1.0

		LoadSounds()
	}
	
	function	AddButtonBlack(_x, _y, _center_pivot = false)
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_generic_black.png"), _x, _y, 240, 90)
		if (_center_pivot)
			WindowSetPivot(_button, 120, 45)
		return _button
	}

	function	AddButtonRed(_x, _y, _center_pivot = false)
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate_red.png"), _x, _y, 256, 128)
		if (_center_pivot)
			WindowSetPivot(_button, 128, 64)
		return _button
	}

	function	AddButtonGreen(_x, _y, _center_pivot = false)
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate_green.png"), _x, _y, 256, 128)
		if (_center_pivot)
			WindowSetPivot(_button, 128, 64)
		return _button
	}

	function	ButtonFeedback(_window)
	{
		WindowSetCommandList(_window, "toalpha 0.05, 0.35; toalpha 0.1, 1.0;")
	}

	function	LoadSounds()
	{
		sfx_select = EngineLoadSound(g_engine, "audio/sfx/gui_up_down.wav")
		sfx_validate = EngineLoadSound(g_engine, "audio/sfx/gui_validate.wav")
		sfx_error = EngineLoadSound(g_engine, "audio/sfx/gui_error.wav")
		sfx_page = EngineLoadSound(g_engine, "audio/sfx/gui_next_page.wav")
		sfx_pause = EngineLoadSound(g_engine, "audio/sfx/gui_game_pause.wav")
		sfx_resume = EngineLoadSound(g_engine, "audio/sfx/gui_game_resume.wav")
	}

	function	PlaySfxUISelect()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_select)	}

	function	PlaySfxUIValidate()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_validate)	}
	
	function	PlaySfxUIError()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_error)	}

	function	PlaySfxUINextPage()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_page)	}

	function	PlaySfxUIPause()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_pause)	}

	function	PlaySfxUIResume()
	{		local	_chan	= MixerSoundStart(g_mixer, sfx_resume)	}

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

		if (!IsTouchPlatform())
		{
			//	Actual desktop cursor
			local	dr = RendererGetViewport(g_render)

			local	viewport_ar = dr.z / dr.w
			local	reference_ar = g_screen_width / g_screen_height

			local	kx = viewport_ar / reference_ar, ky = 1.0

			_x = (_x - 0.5) * kx + 0.5
			_y = (_y - 0.5) * ky + 0.5

			WindowSetPosition(cursor_sprite, _x * g_screen_width, _y * g_screen_height)

			if ((_dx > 0.0) || (_dx > 0.0))
				fade_timeout = g_clock

			FadeTimeout()
	
		}


	}

}

