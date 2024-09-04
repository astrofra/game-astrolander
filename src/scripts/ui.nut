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

//-------------
class	TitleUI	extends	BaseUI
//-------------
{

//	ui	=	0

	virtual_screen_width	=	1600

	master_window_handler	=	0
	master_window_option	=	0
	master_window_level		=	0

	//	Title screen
	game_title				=	0
	game_title_texture		=	0
	start_button			=	0
	option_button			=	0
	title_left_arrow		=	0
	title_right_arrow		=	0

	gfx_hero				=	0

	blue_background			=	0

	//	Option screen
	option_right_arrow		=	0

	level_easy_button		=	0
	level_normal_button		=	0
	level_hard_button		=	0
	control_reverse			=	0
	back_from_option_button	=	0

	//	Level selection screen
	back_from_level_button	=	0
	level_left_arrow		=	0
	level_button_table		=	0
	level_button_id_table	=	0
	level_thumbnail			=	0
	level_name				=	0
	next_world_arrow		=	0
	next_world_button		=	0
	play_level_arrow		=	0
	play_level_button		=	0
	selector_hilite			=	0

	current_selected_level	=	0
	current_world			=	0

	constructor(_ui)
	{
		base.constructor(_ui)

		//	Main Title

		master_window_handler = UIAddWindow(ui, CreateNewUIID(), 0, 0, 16, 16)
		master_window_option = UIAddWindow(ui, CreateNewUIID(), -virtual_screen_width, 0, 16, 16)
		master_window_level = UIAddWindow(ui, CreateNewUIID(), virtual_screen_width, 0, 16, 16)

		local	blue_background_texture = EngineLoadTexture(g_engine, "ui/main_menu_back.png")
		blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetPivot(blue_background, TextureGetWidth(blue_background_texture) / 2.0, TextureGetHeight(blue_background_texture) / 2.0)
		WindowSetPosition(blue_background, 1280.0 / 2.0, 960.0 / 2.0)
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetZOrder(blue_background, 1.0)
		WindowSetParent(blue_background, master_window_level)

		gfx_hero = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_hero.png"), 128 + 512, -100 + 512, 1024, 1024)
		WindowSetPivot(gfx_hero, 512, 512)

		local	_glass = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_hero_reflection_0.png"), 242, 222, 256, 512)
		WindowSetParent(_glass, gfx_hero)
		WindowSetCommandList(_glass, "loop;toalpha 0, 0.75;nop 0.15;toalpha 0, 0.95;nop 0.1;toalpha 0.1, 0.65;nop 0.1;toalpha 0,1;nop 0.15;toalpha 0, 0.85;nop 0.05;toalpha 0.2, 0.75;next;")

		local	_glass = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_hero_reflection_1.png"), 511, 190, 256, 512)
		WindowSetParent(_glass, gfx_hero)
		WindowSetCommandList(_glass, "loop;nop 0.1;toalpha 0.1, 0.75;nop 0.15;toalpha 0, 0.5;nop 0.1;toalpha 0, 0.65;nop 0.1;toalpha 0,1;nop 0.15;next;")
		WindowSetCommandList(gfx_hero, "loop;toscale 5,0.975,0.975;toscale 5,0.95,0.95;toscale 5,1.025,1.025;toscale 5,1.05,1.05;next;")

//		local	_shadow_game_title = CreateLabel(ui, g_locale.game_title, -10, 5, 200, 800, 200, Vector(0, 0, 0, 255), g_main_font_name, TextAlignCenter)
//		game_title = CreateLabel(ui, g_locale.game_title, 640 - 400, 30, 200, 800, 200, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		game_title_texture = EngineLoadTexture(g_engine, "ui/title_astlan.png")
		game_title = UIAddSprite(ui, -1, game_title_texture, 0, 0, TextureGetWidth(game_title_texture), TextureGetHeight(game_title_texture))
		WindowSetPivot(game_title, TextureGetWidth(game_title_texture) / 2.0, TextureGetHeight(game_title_texture) / 2.0)
		WindowSetPosition(game_title, 1280.0 / 2.0, TextureGetHeight(game_title_texture) / 2.0 * 1.15)
		local	_game_subtitle = CreateLabel(ui, g_locale.game_subtitle, 0, 170, 50, 800, 100, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(_game_subtitle[0], game_title)
//		WindowSetParent(_shadow_game_title[0], game_title[0])

		title_left_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_blue_left.png"), 16, 700, 256, 128)
		title_right_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_blue_right.png"), 1280 - 16 - 256, 700, 256, 128)

		start_button = CreateLabel(ui, g_locale.start_game, 0, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		option_button = CreateLabel(ui, g_locale.option, 0, 30, 50, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)

		WindowSetParent(option_button[0], title_left_arrow)
		WindowSetParent(start_button[0], title_right_arrow)

		WidgetSetEventHandlerWithContext(start_button[1], EventCursorDown, this, TitleUI.ScrollToLevelScreen) //OnTitleUIStartGame)
		WidgetSetEventHandlerWithContext(option_button[1], EventCursorDown, this, TitleUI.ScrollToOptionScreen)
		local	_copyright = CreateLabel(ui, g_locale.copyright, 640 - 400, 900, 30, 800, 64, Vector(117, 155, 168, 128), g_main_font_name, TextAlignCenter)

		//	Options

		option_right_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_blue_right.png"), 1280 - 16 - 256, 700, 256, 128)
		WindowSetParent(option_right_arrow, master_window_option)

		level_easy_button = CreateLabel(ui, g_locale.level_easy, 640 - 200 - 300, 680, 40, 400, 64, Vector(64, 32, 160, 255), g_main_font_name, TextAlignCenter)
		level_normal_button = CreateLabel(ui, CreateSelectedOptionString(g_locale.level_normal), 640 - 200, 680, 40, 400, 64, Vector(64, 32, 160, 255), g_main_font_name, TextAlignCenter)
		level_hard_button = CreateLabel(ui, g_locale.level_hard, 640 - 200 + 300, 680, 40, 400, 64, Vector(64, 32, 160, 255), g_main_font_name, TextAlignCenter)

		back_from_option_button = CreateLabel(ui, g_locale.back_to_title, -10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_from_option_button[0], option_right_arrow)

		WidgetSetEventHandlerWithContext(level_easy_button[1], EventCursorDown, this, TitleUI.OnTitleUISelectLevelEasy)
		WidgetSetEventHandlerWithContext(level_normal_button[1], EventCursorDown, this, TitleUI.OnTitleUISelectLevelNormal)
		WidgetSetEventHandlerWithContext(level_hard_button[1], EventCursorDown, this, TitleUI.OnTitleUISelectLevelHard)
		WidgetSetEventHandlerWithContext(back_from_option_button[1], EventCursorDown, this, TitleUI.ScrollToTitleScreen)
		
		control_reverse = CreateLabel(ui, CreateStringControlReverse(), 640 - 300, 750, 32, 600, 64, Vector(64, 32, 160, 255), g_main_font_name, TextAlignCenter)
		WidgetSetEventHandlerWithContext(control_reverse[1], EventCursorDown, this, TitleUI.OnTitleUIReverseControls)

		//	Level Selector

		level_left_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_blue_left.png"), 16, 700, 256, 128)
		WindowSetParent(level_left_arrow, master_window_level)
		back_from_level_button = CreateLabel(ui, g_locale.back_to_title, -10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_from_level_button[0], level_left_arrow)
		WidgetSetEventHandlerWithContext(back_from_level_button[1], EventCursorDown, this, TitleUI.ScrollToTitleScreen)

		level_button_table = []
		CreateLevelButtonGrid()
		selector_hilite = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/level_selector_hilite.png"), 0, 0, 256, 256)
		WindowSetZOrder(selector_hilite, 0.7)
		WindowShow(selector_hilite, false)
		HiliteLevelSelection()

		level_thumbnail = LevelSelectorLoadLevelThumbnail(current_selected_level, 1280.0 - 256.0, 480.0 - 128.0)
		WindowSetParent(level_thumbnail, master_window_level)

		level_name = CreateLabel(ui, GetLevelName(current_selected_level),1280 - 256.0 - 256.0, 480 - 256 - 40 - 128.0, 50, 512, 80, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(level_name[0], master_window_level)

		play_level_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate.png"), 1280 - 256.0 - 128.0, 480.0 + 128.0 - 64.0, 256, 128)
		WindowSetParent(play_level_arrow, master_window_level)
		play_level_button = CreateLabel(ui, g_locale.play_level, -10, 30, 65, 256, 80, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(play_level_button[0], play_level_arrow)
		WidgetSetEventHandlerWithContext(play_level_button[1], EventCursorDown, this, TitleUI.OnTitleUIStartGame)

		next_world_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_blue_right.png"), 1280 - 16 - 256, 700, 256, 128)
		WindowSetParent(next_world_arrow, master_window_level)
		next_world_button = CreateLabel(ui, g_locale.next_level, -10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(next_world_button[0], next_world_arrow)
		WidgetSetEventHandlerWithContext(next_world_button[1], EventCursorDown, this, TitleUI.GoToNextWorldPage)

		WindowSetParent(game_title, master_window_handler)
		WindowSetParent(_copyright[0], master_window_handler)
		WindowSetParent(gfx_hero, master_window_handler)
		WindowSetParent(title_left_arrow, master_window_handler)
		WindowSetParent(title_right_arrow, master_window_handler)

		WindowSetParent(master_window_option, master_window_handler)
		WindowSetParent(master_window_level, master_window_handler)

		WindowSetParent(level_easy_button[0], master_window_option)
		WindowSetParent(level_normal_button[0], master_window_option)
		WindowSetParent(level_hard_button[0], master_window_option)
		WindowSetParent(control_reverse[0], master_window_option) 

		//AddLogo()
	}

	function	UpdateCursor()
	{
		base.UpdateCursor()
	}

	//---------------------------------
	function	CreateLevelButtonGrid()
	//---------------------------------
	{
		if (level_button_table.len() > 0)
		{
			local	_level_button
			foreach(_level_button in level_button_table)
			{
				UIDeleteWindow(ui, _level_button.level_button)
				UIDeleteWindow(ui, _level_button.level_number_button)
			}

			level_button_table = []
		}

		level_button_id_table = {}

		local	_xoffset = 128.0, _yoffset = 16.0

		local	_x, _y
		local	_button_bg = EngineLoadTexture(g_engine, "ui/level_selector_background.png")
		for (_y = 0; _y < 2; _y++)
			for(_x = 0; _x < 2; _x++)
			{
				local	_level_number = _x + _y * 2 + (current_world * 4)
				local	_level_button = UIAddSprite(ui, -1, _button_bg, _xoffset + _x * 256 * 1.25, _yoffset + _y * 256 * 1.1, 256, 256)
				WindowSetParent(_level_button, master_window_level)
				local	_level_number_button = CreateLabel(ui, (_level_number + 1).tostring(), 0, 0, 120, 256, 256, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
				WindowSetParent(_level_number_button[0], _level_button)
				WidgetSetEventHandlerWithContext(_level_number_button[1], EventCursorDown, this, TitleUI.OnTitleUISelectLevel)
				level_button_id_table.rawset(WindowGetName(_level_number_button[0]), _level_number)

				level_button_table.append({ level_button = _level_button, level_number_button = _level_number_button[0] })
			}
	}

	//---------------------------------
	function	FadeInLevelButtonGrid()
	//---------------------------------
	{
		if (level_button_table.len() > 0)
		{
			local	_level_button
			foreach(_idx, _level_button in level_button_table)
				WindowSetCommandList(_level_button.level_button, "toalpha 0,0; nop " + ((_idx + 1) * 0.1).tostring() + "; toalpha 0.1, 1.0;")
		}
	}

	//----------------------------
	function	GetLevelName(_idx)
	//----------------------------
	{
		local	_str
		try
		{
			_str = g_locale.level_names[("level_" + _idx.tostring())]
		}
		catch(e)
		{
			_str = "level #" + (_idx + 1).tostring()
		}
		
		return _str
	}

	//------------------------------------------------
	function	LoadMinimapTextureFromLevelIndex(_idx)
	//------------------------------------------------
	{
		local	_fname = "ui/minimaps/level_" + _idx.tostring() + ".tga"

		if (FileExists(_fname))
			return EngineLoadTexture(g_engine, _fname)
		else
			return 0
	}

	//-------------------------------------------------------
	function	LevelSelectorLoadLevelThumbnail(_idx, _x, _y)
	//-------------------------------------------------------
	{
		local	_id = CreateNewUIID()

		local	_minimap = LoadMinimapTextureFromLevelIndex(_idx)

		local	_w, _h, _window

		if (_minimap == 0)
		{
			_w = 128
			_h = 128
			_window = UIAddWindow(ui, _id, 0.0, 0.0, _w, _h)
		}
		else
		{
			_w = TextureGetWidth(_minimap)
			_h = TextureGetHeight(_minimap)
			_window = UIAddSprite(ui, _id, _minimap, 0.0, 0.0, _w, _h)
		}

		WindowSetPivot(_window, (_w * 0.5), (_h * 0.5))
		WindowSetScale(_window, 0.75, 0.75)
		WindowSetPosition(_window , _x, _y)

		SpriteSetTexture

		return _window
	}

	//	+---+ +---+ +---+  O = options
	//	| O | | T | | S |  T = title
	//	+---+ +---+ +---+  S = level selection


	//-------------------------------------------------------
	function	CreateTweeningCommandList(start_pos, end_pos)
	//-------------------------------------------------------
	{
		start_pos = start_pos.tofloat()
		end_pos = end_pos.tofloat()

		local n,	step	= 10.0, _str = ""

		for(n = 0.0; n <= step; n++)
		{
			local	_lerp	=	n / step;
			local	_time = (1.0 - Pow(MakeTriangleWave(_lerp), 0.25)) * 0.25;
			local	_current_pos = Lerp(_lerp, start_pos, end_pos)

			print("_time = " + _time)

			_str += "toposition " + _time.tostring() + ", " + _current_pos.tostring() + ", 0;"
		}

		return (_str)
	}

	//--------------------------------
	function	HiliteLevelSelection()
	//--------------------------------
	{
		if ((current_selected_level >= current_world * 4) && (current_selected_level < (current_world + 1) * 4))
		{
			local	_local_level_index
			_local_level_index = current_selected_level - (current_world * 4)
			WindowSetParent(selector_hilite, level_button_table[_local_level_index].level_button)
			WindowShow(selector_hilite, true)
//			PlaySfxUISelect()
		}
	}

	//-----------------------------------------
	function	GoToNextWorldPage(event, table)
	//-----------------------------------------
	{
		current_world++

		WindowShow(selector_hilite, false)

		if (current_world > 5)
		{
			current_world = 5
			return
		}
		
		if (current_world == 5)
			WindowShow(next_world_arrow, false)

		CreateLevelButtonGrid()
		FadeInLevelButtonGrid()
		HiliteLevelSelection()

		WidgetSetEventHandlerWithContext(back_from_level_button[1], EventCursorDown, this, TitleUI.GoToPreviousWorldPage)

		PlaySfxUISelect()
	}

	//-----------------------------------------
	function	GoToPreviousWorldPage(event, table)
	//-----------------------------------------
	{
		current_world--

		WindowShow(selector_hilite, false)

		if (current_world < 0)
		{
			current_world = 0
			return
		}

		CreateLevelButtonGrid()
		FadeInLevelButtonGrid()
		HiliteLevelSelection()

		WindowShow(next_world_arrow, true)

		if (current_world == 0)
			WidgetSetEventHandlerWithContext(back_from_level_button[1], EventCursorDown, this, TitleUI.ScrollToTitleScreen)
		else
			WidgetSetEventHandlerWithContext(back_from_level_button[1], EventCursorDown, this, TitleUI.GoToPreviousWorldPage)

		PlaySfxUISelect()
	}

	//-------------------------------------------
	function	ScrollToLevelScreen(event, table)
	//-------------------------------------------
	{
		current_world = 0
		CreateLevelButtonGrid()
		FadeInLevelButtonGrid()
		HiliteLevelSelection()
		WindowSetCommandList(master_window_handler, CreateTweeningCommandList(WindowGetPosition(master_window_handler).x, -virtual_screen_width))
		PlaySfxUINextPage()
	}

	//-------------------------------------------
	function	ScrollToOptionScreen(event, table)
	//-------------------------------------------
	{
		WindowSetCommandList(master_window_handler, CreateTweeningCommandList(WindowGetPosition(master_window_handler).x, virtual_screen_width))
		PlaySfxUINextPage()
	}

	//-------------------------------------------
	function	ScrollToTitleScreen(event, table)
	//-------------------------------------------
	{
		WindowSetCommandList(master_window_handler, CreateTweeningCommandList(WindowGetPosition(master_window_handler).x, 0))
		PlaySfxUINextPage()
	}
	
	//--------------------------------------
	function	CreateStringControlReverse()
	//--------------------------------------
	{	return (g_locale.control_reverse + " : " + (g_reversed_controls?g_locale.yes:g_locale.no))	}

	//------------------------------------------------
	function	OnTitleUIReverseControls(event, table)
	//------------------------------------------------
	{
		g_reversed_controls = !g_reversed_controls
		TextSetText(control_reverse[1], CreateStringControlReverse())
		GlobalSaveGame()
		PlaySfxUISelect()
	}

	//--------------------------------------------
	function	OnTitleUISelectLevel(event, table)
	//--------------------------------------------
	{
		local	_button_id = SpriteGetName(table.sprite)
		local	_level = level_button_id_table[_button_id]
		current_selected_level = _level

		WindowSetParent(selector_hilite, table.sprite)
		WindowShow(selector_hilite, true)

		local	_x = WindowGetPosition(level_thumbnail).x
		local	_y = WindowGetPosition(level_thumbnail).y
		UIDeleteWindow(ui, level_thumbnail)
		level_thumbnail = LevelSelectorLoadLevelThumbnail(current_selected_level, _x, _y)
		WindowSetParent(level_thumbnail, master_window_level)

		TextSetText(level_name[1] , GetLevelName(current_selected_level))
		PlaySfxUISelect()
	}

	//----------------------------------------
	function	OnTitleUIStartGame(event, table)
	//----------------------------------------
	{
		ProjectGetScriptInstance(g_project).player_data.current_level = current_selected_level
		SceneGetScriptInstance(g_scene).StartGame()
		PlaySfxUIValidate()
	}

	function	CreateSelectedOptionString(str)
	{	return  ("[" + str + "]")	}

	function	OnTitleUISelectLevelEasy(event, table)
	{
		print("TitleUI::OnTitleUISelectLevelEasy()")
		g_clock_scale = g_clock_scale_easy
		print("TitleUI::g_clock_scale = " + g_clock_scale)

		TextSetText(level_easy_button[1],CreateSelectedOptionString(g_locale.level_easy))
		TextSetText(level_normal_button[1], g_locale.level_normal)
		TextSetText(level_hard_button[1], g_locale.level_hard)
		PlaySfxUISelect()
//		SceneGetScriptInstance(g_scene).StartGame()
	}

	function	OnTitleUISelectLevelNormal(event, table)
	{
		print("TitleUI::OnTitleUISelectLevelNormal()")
		g_clock_scale = 1.0
		print("TitleUI::g_clock_scale = " + g_clock_scale)

		TextSetText(level_easy_button[1],g_locale.level_easy)
		TextSetText(level_normal_button[1], CreateSelectedOptionString(g_locale.level_normal))
		TextSetText(level_hard_button[1], g_locale.level_hard)
		PlaySfxUISelect()
//		SceneGetScriptInstance(g_scene).StartGame()
	}

	function	OnTitleUISelectLevelHard(event, table)
	{
		print("TitleUI::OnTitleUISelectLevelHard()")
		g_clock_scale = g_clock_scale_hard
		print("TitleUI::g_clock_scale = " + g_clock_scale)

		TextSetText(level_easy_button[1],g_locale.level_easy)
		TextSetText(level_normal_button[1], g_locale.level_normal)
		TextSetText(level_hard_button[1], CreateSelectedOptionString(g_locale.level_hard))
		PlaySfxUISelect()
//		SceneGetScriptInstance(g_scene).StartGame()
	}

	function	AddLogo()
	{
		local	logo = UIAddBitmapWindow(ui, -1, "ui/muteblast_logo.png", 640, 850, 512, 512)
		WindowSetPivot(logo, 256, 256)
		WindowSetScale(logo, 0.65, 0.65)
	}

}
