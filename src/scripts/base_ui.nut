

//------------
class	BaseUI
//------------
{
	ui				=	0
	cursor_sprite	=	0

	touch_device	=	0
	cursor_dt_x		=	0
	cursor_dt_y		=	0
	cursor_prev_x	=	0
	cursor_prev_y	=	0
	cursor_down_timestamp		=	0
	cursor_click	=	0
	cursor_swipe	=	0

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

		touch_device
		if (IsTouchPlatform())
			touch_device = GetInputDevice("touch0")
		else
			touch_device = GetInputDevice("mouse")
			
		fade_timeout = g_clock
		cursor_opacity	=	1.0

		LoadSounds()
	}

	//------------------------	
	function	AddButtonGenericRed(_x, _y, _center_pivot = false)
	//------------------------	
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_generic_red.png"), _x, _y, 240, 90)
		if (_center_pivot)
			WindowSetPivot(_button, 120, 45)
		return _button
	}

	//------------------------	
	function	AddButtonGenericBlack(_x, _y, _center_pivot = false)
	//------------------------	
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_generic_black.png"), _x, _y, 240, 90)
		if (_center_pivot)
			WindowSetPivot(_button, 120, 45)
		return _button
	}

	//------------------------	
	function	AddButtonRed(_x, _y, _center_pivot = false)
	//------------------------	
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate_red.png"), _x, _y, 256, 128)
		if (_center_pivot)
			WindowSetPivot(_button, 128, 64)
		return _button
	}

	//------------------------	
	function	AddButtonGreen(_x, _y, _center_pivot = false)
	//------------------------	
	{
		local	_button = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate_green.png"), _x, _y, 256, 128)
		if (_center_pivot)
			WindowSetPivot(_button, 128, 64)
		return _button
	}

	//------------------------	
	function	ButtonFeedback(_window)
	//------------------------	
	{
		if (_window != 0)
		{
			if (WindowIsCommandListDone(_window))
			{
				local	_opacity = WindowGetOpacity(_window)
				WindowSetCommandList(_window, "toalpha 0.05, 0.35; toalpha 0.1, " + _opacity.tostring() + ";")
			}
		}
	}

	//------------------------	
	function	LoadSounds()
	//------------------------	
	{
		sfx_select = EngineLoadSound(g_engine, "audio/sfx/gui_up_down.wav")
		sfx_validate = EngineLoadSound(g_engine, "audio/sfx/gui_validate.wav")
		sfx_error = EngineLoadSound(g_engine, "audio/sfx/gui_error.wav")
		sfx_page = EngineLoadSound(g_engine, "audio/sfx/gui_next_page.wav")
		sfx_pause = EngineLoadSound(g_engine, "audio/sfx/gui_game_pause.wav")
		sfx_resume = EngineLoadSound(g_engine, "audio/sfx/gui_game_resume.wav")
	}

	function	PlaySfxUISelect()
	{		
		if (!g_sound_enabled)	return
		local	_chan	= MixerSoundStart(g_mixer, sfx_select)
		MixerChannelSetGain(g_mixer, _chan, 1.0 * GlobalGetSfxVolume())	
	}

	function	PlaySfxUIValidate()
	{		
		if (!g_sound_enabled)	return
		local	_chan	= MixerSoundStart(g_mixer, sfx_validate)	
		MixerChannelSetGain(g_mixer, _chan, 1.0 * GlobalGetSfxVolume())
	}
	
	function	PlaySfxUIError()
	{		
		if (!g_sound_enabled)	return
		local	_chan	= MixerSoundStart(g_mixer, sfx_error)
		MixerChannelSetGain(g_mixer, _chan, 1.0 * GlobalGetSfxVolume())
	}

	function	PlaySfxUINextPage()
	{		
		if (!g_sound_enabled)	return
		local	_chan	= MixerSoundStart(g_mixer, sfx_page)
		MixerChannelSetGain(g_mixer, _chan, 1.0 * GlobalGetSfxVolume())
	}

	function	PlaySfxUIPause()
	{		
		if (!g_sound_enabled)	return
		local	_chan	= MixerSoundStart(g_mixer, sfx_pause)
		MixerChannelSetGain(g_mixer, _chan, 1.0 * GlobalGetSfxVolume())
	}

	function	PlaySfxUIResume()
	{		
		if (!g_sound_enabled)	return
		local	_chan	= MixerSoundStart(g_mixer, sfx_resume)
		MixerChannelSetGain(g_mixer, _chan, 1.0 * GlobalGetSfxVolume())
	}

	function	FadeTimeout()
	{
		if ((g_clock - fade_timeout) > SecToTick(Sec(5.0)))
			cursor_opacity = Clamp((cursor_opacity - g_dt_frame), 0.0, 1.0)
		else
			cursor_opacity = Clamp((cursor_opacity + 10.0 * g_dt_frame), 0.0, 1.0)

		WindowSetOpacity(cursor_sprite, cursor_opacity)	
	}

	//----------------------------------------
	function	NormalizedToScreenSpace(_x,_y)
	//----------------------------------------
	{
		//	Actual desktop cursor
		local	dr = RendererGetViewport(g_render)

		local	viewport_ar = dr.z / dr.w
		local	reference_ar = g_screen_width / g_screen_height

		local	kx = viewport_ar / reference_ar, ky = 1.0

		_x = (_x - 0.5) * kx + 0.5
		_y = (_y - 0.5) * ky + 0.5
		_x *= g_screen_width
		_y *= g_screen_height

		return	({x = _x, y = _y})
	}

	//------------------------
	function	Update()
	//------------------------
	{
		if (cursor_down_timestamp == -1)
			cursor_click = false

		local ui_device = GetInputDevice("mouse")
		local	_x, _y, _dx, _dy
		_x = DeviceInputValue(ui_device, DeviceAxisX)
		_y = DeviceInputValue(ui_device, DeviceAxisY)

		UISetCursorState(ui, g_ui_cursor, _x, _y, DeviceIsKeyDown(ui_device, KeyButton0))

		_dx = Abs(_x - cursor_prev_x)
		_dy = Abs(_y - cursor_prev_y)

		local	_nc = NormalizedToScreenSpace(_x, _y),
				_pnc = NormalizedToScreenSpace(cursor_prev_x, cursor_prev_y)

		cursor_dt_x = _nc.x - _pnc.x
		cursor_dt_y = _nc.y - _pnc.y

		cursor_prev_x = _x
		cursor_prev_y = _y

		if (!IsTouchPlatform())
		{
			//	Actual desktop cursor
			local	screen_cursor = NormalizedToScreenSpace(_x, _y)
			WindowSetPosition(cursor_sprite, screen_cursor.x, screen_cursor.y)

			if ((_dx > 0.0) || (_dx > 0.0))
				fade_timeout = g_clock

			FadeTimeout()	
		}

		if (DeviceIsKeyDown(touch_device, KeyButton0))
		{
			if (DeviceWasKeyDown(touch_device, KeyButton0))
			{
				if ((g_clock - cursor_down_timestamp) > SecToTick(Sec(0.1)))
					cursor_swipe = true
			}
			else
				cursor_down_timestamp = g_clock
		}
		else
		{
			if (DeviceWasKeyDown(touch_device, KeyButton0))
			{
				if ((g_clock - cursor_down_timestamp) < SecToTick(Sec(0.05)))
					cursor_click = true
				else
					cursor_click = false
			}
			else
				cursor_click = false	

			cursor_swipe = false
		}
	}

}