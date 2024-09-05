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
	game_subtitle			=	0
	
	start_button			=	0
	option_button			=	0
	title_left_arrow		=	0
	title_right_arrow		=	0
	leaderboard_button		=	0
	title_leaderboard_arrow	=	0
	game_copyright			=	0

	gfx_hero				=	0

	blue_background			=	0

	//	Option screen
	option_right_arrow		=	0

	level_easy_button		=	0
	level_normal_button		=	0
	level_hard_button		=	0
	control_reverse			=	0
	back_from_option_button	=	0
	nickname_textfield		=	0
	credit_button			=	0
	sfx_volume_button		=	0
	music_volume_button		=	0
	language_button			=	0

	//	Level selection screen
	back_from_level_button	=	0
	level_left_arrow		=	0
	level_button_table		=	0
	level_button_id_table	=	0
	level_thumbnail			=	0
	level_thumbnail_bg		=	0
	level_lock_icon			=	0
	level_name				=	0
	level_name_shadow		=	0
	next_world_arrow		=	0
	next_world_button		=	0
	play_level_arrow		=	0
	play_level_button		=	0
	selector_hilite			=	0

	current_selected_level	=	0
	current_world			=	0
		
	function	OnRenderContextChanged()
	{
		game_subtitle[1].rebuild()
		game_subtitle[1].refresh()
		
		start_button[1].rebuild()
		start_button[1].refresh()
		
		option_button[1].rebuild()
		option_button[1].refresh()
		
		leaderboard_button[1].rebuild()
		leaderboard_button[1].refresh()
		
		game_copyright[1].rebuild()
		game_copyright[1].refresh()
		
		back_from_option_button[1].rebuild()
		back_from_option_button[1].refresh()

		sfx_volume_button[1].rebuild()
		music_volume_button[1].refresh()
		
		control_reverse[1].rebuild()
		control_reverse[1].refresh()
		
		back_from_level_button[1].rebuild()
		back_from_level_button[1].refresh()
		
		level_name[1].rebuild()
		level_name[1].refresh()
		
		play_level_button[1].rebuild()
		play_level_button[1].refresh()
		
		next_world_button[1].rebuild()
		next_world_button[1].refresh()
		
		nickname_textfield.rebuild()
		nickname_textfield.refresh()
		
		CreateLevelButtonGrid()
		WindowShow(selector_hilite, false)
	}

	constructor(_ui)
	{
		base.constructor(_ui)

		//	Main Title	------------------------------------------------------------
		CreateOpaqueScreen(ui)

		master_window_handler = UIAddWindow(ui, CreateNewUIID(), 0, 0, 16, 16)
		master_window_option = UIAddWindow(ui, CreateNewUIID(), -virtual_screen_width, 0, 16, 16)
		master_window_level = UIAddWindow(ui, CreateNewUIID(), virtual_screen_width, 0, 16, 16)

		local	blue_background_texture = EngineLoadTexture(g_engine, "ui/main_menu_back.png")
		blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetPosition(blue_background, g_screen_width / 2.0 - (TextureGetWidth(blue_background_texture) / 2.0 * 1.5), g_screen_height / 2.0 - (TextureGetHeight(blue_background_texture) / 2.0 * 1.5))
		WindowSetZOrder(blue_background, 1.0)
		WindowSetParent(blue_background, master_window_level)

		blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetPosition(blue_background, g_screen_width / 2.0 - (TextureGetWidth(blue_background_texture) / 2.0 * 1.5), g_screen_height / 2.0 - (TextureGetHeight(blue_background_texture) / 2.0 * 1.5))
		WindowSetZOrder(blue_background, 1.0)
		WindowSetParent(blue_background, master_window_option)

		gfx_hero = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_hero.png"), 128 + 512, -100 + 512, 1024, 1024)
		WindowSetPivot(gfx_hero, 512, 512)

		local	_glass = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_hero_reflection_0.png"), 242, 222, 256, 512)
		WindowSetParent(_glass, gfx_hero)
		WindowSetCommandList(_glass, "loop;toalpha 0, 0.75;nop 0.15;toalpha 0, 0.95;nop 0.1;toalpha 0.1, 0.65;nop 0.1;toalpha 0,1;nop 0.15;toalpha 0, 0.85;nop 0.05;toalpha 0.2, 0.75;next;")

		local	_glass = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_hero_reflection_1.png"), 511, 190, 256, 512)
		WindowSetParent(_glass, gfx_hero)
		WindowSetCommandList(_glass, "loop;nop 0.1;toalpha 0.1, 0.75;nop 0.15;toalpha 0, 0.5;nop 0.1;toalpha 0, 0.65;nop 0.1;toalpha 0,1;nop 0.15;next;")
		WindowSetCommandList(gfx_hero, "loop;toscale 5,0.975,0.975;toscale 5,0.95,0.95;toscale 5,1.025,1.025;toscale 5,1.05,1.05;next;")

		game_title_texture = EngineLoadTexture(g_engine, "ui/title_astlan.png")
		game_title = UIAddSprite(ui, -1, game_title_texture, 0, 0, TextureGetWidth(game_title_texture), TextureGetHeight(game_title_texture))
		WindowSetPivot(game_title, TextureGetWidth(game_title_texture) / 2.0, TextureGetHeight(game_title_texture) / 2.0)
		WindowSetPosition(game_title, g_screen_width / 2.0, TextureGetHeight(game_title_texture) / 2.0 * 1.15)

		game_subtitle = LabelWrapper(ui, tr("Astro Lander"), 0, 170, 50, 800, 100, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		game_subtitle[1].drop_shadow = true
		game_subtitle[1].refresh()
		WindowSetParent(game_subtitle[0], game_title)

		title_left_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_left.png"), 16, 700, 256, 128)
		title_right_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)

		start_button = LabelWrapper(ui, tr("Play", "screen nav."), -10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		option_button = LabelWrapper(ui, tr("Options", "screen nav."), 10, 30, 50, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)

		WindowSetParent(option_button[0], title_left_arrow)
		WindowSetParent(start_button[0], title_right_arrow)
		WindowSetEventHandlerWithContext(title_left_arrow, EventCursorDown, this, TitleUI.ScrollToOptionScreen)
		WindowSetEventHandlerWithContext(title_right_arrow, EventCursorDown, this, TitleUI.GoToLevelScreen)
		WindowSetEventHandlerWithContext(option_button[0], EventCursorDown, this, TitleUI.ScrollToOptionScreen)
		WindowSetEventHandlerWithContext(start_button[0], EventCursorDown, this, TitleUI.GoToLevelScreen) 

		title_leaderboard_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_left.png"), 16, 700 - 128 - 16, 256, 128)
		leaderboard_button = LabelWrapper(ui, tr("Leaders", "leaderboard"), 10, 30, 50, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(leaderboard_button[0], title_leaderboard_arrow)

		WindowSetEventHandlerWithContext(title_leaderboard_arrow, EventCursorDown, this, TitleUI.GotoLeaderboard)
		WindowSetEventHandlerWithContext(leaderboard_button[0], EventCursorDown, this, TitleUI.GotoLeaderboard) //OnTitleUIStartGame)


		game_copyright = LabelWrapper(ui, tr("(c) 2011-2012 Astrofra."), (g_screen_width * 0.5) - 400, 900, 30, 800, 64, Vector(117, 155, 168, 128), g_main_font_name, TextAlignCenter)

		//	Options	------------------------------------------------------------

		option_right_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		WindowSetParent(option_right_arrow, master_window_option)

		back_from_option_button = LabelWrapper(ui, tr("Back", "screen nav."), -10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_from_option_button[0], option_right_arrow)
		WindowSetEventHandlerWithContext(option_right_arrow, EventCursorDown, this, TitleUI.ScrollToTitleScreen)
		WindowSetEventHandlerWithContext(back_from_option_button[0], EventCursorDown, this, TitleUI.ScrollToTitleScreen)
				
		//	Reverse controls
		local	_control_reverse_button = AddButtonRed(g_screen_width * 0.5, g_screen_height * 0.525, true)
		control_reverse = LabelWrapper(ui, CreateStringControlReverse(), -170, 32, 30, 600, 64, g_ui_color_white, g_main_font_name, TextAlignCenter)
		WindowSetEventHandlerWithContext(control_reverse[0], EventCursorDown, this, TitleUI.OnTitleUIReverseControls)
		WindowSetEventHandlerWithContext(_control_reverse_button, EventCursorDown, this, TitleUI.OnTitleUIReverseControls)
		WindowSetParent(control_reverse[0], _control_reverse_button)

		//	Change UI language
		local	_language_button = AddButtonRed(g_screen_width * 0.5, g_screen_height * 0.675, true)
		language_button = LabelWrapper(ui, tr("English", "options"), -20, 20, 40, 300, 90, g_ui_color_white, g_main_font_name, TextAlignCenter)
		WindowSetEventHandlerWithContext(language_button[0], EventCursorDown, this, TitleUI.OnTitleUINextLanguage)
		WindowSetEventHandlerWithContext(_language_button, EventCursorDown, this, TitleUI.OnTitleUINextLanguage)
		WindowSetParent(language_button[0], _language_button)

		//	Goto Credits Page
		local	_credit_button = AddButtonGenericBlack(g_screen_width * 0.5, g_screen_height * 0.825, true)
		credit_button = LabelWrapper(ui, tr("Credits", "screen nav."), -30, 0, 40, 300, 90, g_ui_color_white, g_main_font_name, TextAlignCenter)
		WindowSetEventHandlerWithContext(credit_button[0], EventCursorDown, this, TitleUI.OnTitleUIGotoCredits)
		WindowSetEventHandlerWithContext(_credit_button, EventCursorDown, this, TitleUI.OnTitleUIGotoCredits)
		WindowSetParent(credit_button[0], _credit_button)

		local	enter_nickname_text = LabelWrapper(ui, tr("Player's Nickname", "options"), g_screen_width * 0.5 - 256, g_screen_height * 0.25 - 110, 48, 512, 80, g_ui_color_white, g_main_font_name, TextAlignCenter)
		WindowSetParent(enter_nickname_text[0], master_window_option)

		if (IsTouchPlatform())
			nickname_textfield = EditableTouchTextField(ui, 512, 80, g_screen_width * 0.5, g_screen_height * 0.25)
		else
			nickname_textfield = EditableTextField(ui, 512, 80, g_screen_width * 0.5, g_screen_height * 0.25)
		WindowSetParent(nickname_textfield.handler, master_window_option)

		local	_sfx_volume = AddButtonGenericRed(g_screen_width * 0.375, g_screen_height * 0.4, true)
		sfx_volume_button = LabelWrapper(ui, SfxVolumeCreateString(), -135, 10, 30, 512, 80, g_ui_color_white, g_main_font_name, TextAlignCenter)
		WindowSetParent(_sfx_volume, master_window_option)
		WindowSetParent(sfx_volume_button[0], _sfx_volume)
		WindowSetEventHandlerWithContext(_sfx_volume, EventCursorDown, this, TitleUI.OnTitleIncreaseSfxVolume)
		WindowSetEventHandlerWithContext(sfx_volume_button[0], EventCursorDown, this, TitleUI.OnTitleIncreaseSfxVolume)

		local	_music_volume = AddButtonGenericRed(g_screen_width * 0.625, g_screen_height * 0.4, true)
		music_volume_button = LabelWrapper(ui, MusicVolumeCreateString(), -135, 10, 30, 512, 80, g_ui_color_white, g_main_font_name, TextAlignCenter)
		WindowSetParent(_music_volume, master_window_option)
		WindowSetParent(music_volume_button[0], _music_volume)
		WindowSetEventHandlerWithContext(_music_volume, EventCursorDown, this, TitleUI.OnTitleIncreaseMusicVolume)
		WindowSetEventHandlerWithContext(music_volume_button[0], EventCursorDown, this, TitleUI.OnTitleIncreaseMusicVolume)

		//	Level Selector	------------------------------------------------------------

		current_selected_level = ProjectGetScriptInstance(g_project).player_data.current_selected_level
		level_left_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_left.png"), 16, 700, 256, 128)
		WindowSetParent(level_left_arrow, master_window_level)
		back_from_level_button = LabelWrapper(ui, tr("Back", "screen nav."), 10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_from_level_button[0], level_left_arrow)
		WindowSetEventHandlerWithContext(level_left_arrow, EventCursorDown, this, TitleUI.ScrollToTitleScreen)
		WindowSetEventHandlerWithContext(back_from_level_button[0], EventCursorDown, this, TitleUI.ScrollToTitleScreen)

		level_button_table = []
		CreateLevelButtonGrid()
		selector_hilite = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/level_selector_hilite.png"), 0, 0, 256, 256)
		WindowSetZOrder(selector_hilite, 0.7)
		WindowShow(selector_hilite, false)
		HiliteLevelSelection()

		level_thumbnail_bg = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/level_thumbnail_background.png"), 0, 0, 256, 360)
		WindowSetOpacity(level_thumbnail_bg, 0.25)
		WindowSetPivot(level_thumbnail_bg, 256 / 2.0, 360 / 2.0)
		WindowSetPosition(level_thumbnail_bg, g_screen_width - 256.0, (g_screen_height * 0.5) - (128.0 * 1.5))
		WindowSetScale(level_thumbnail_bg, 1.45, 1.45)
		WindowSetParent(level_thumbnail_bg, master_window_level)
		level_thumbnail = LevelSelectorLoadLevelThumbnail(current_selected_level, g_screen_width - 256.0, (g_screen_height * 0.5) - 128.0)
		WindowSetParent(level_thumbnail, master_window_level)

		level_lock_icon = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/lock_2.png"), 0, 0, 256, 256)
		WindowSetPivot(level_lock_icon, 256 / 2.0, 256 / 2.0)
		WindowSetPosition(level_lock_icon, g_screen_width - 256.0, (g_screen_height * 0.5) - (128.0 * 1.15))
		WindowSetScale(level_lock_icon, 1.25, 1.25)
		WindowSetParent(level_lock_icon, master_window_level)
		WindowSetOpacity(level_lock_icon, 0.75)

		level_name = LabelWrapper(ui, GetLevelName(current_selected_level),g_screen_width - 350.0 - 256.0, (g_screen_height * 0.5) - 256 - 40 - 128.0, 55, 700, 80, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		level_name[1].drop_shadow = true
		level_name[1].refresh()
		WindowSetParent(level_name[0], master_window_level)

		play_level_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate_green.png"), g_screen_width - 256.0 - 128.0, (g_screen_height * 0.5) + 128.0 - 64.0, 256, 128)
		WindowSetParent(play_level_arrow, master_window_level)
		play_level_button = LabelWrapper(ui, tr("Start", "screen nav."), 5, 25, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(play_level_button[0], play_level_arrow)
		WindowSetEventHandlerWithContext(play_level_arrow, EventCursorDown, this, TitleUI.OnTitleUIStartGame)
		WindowSetEventHandlerWithContext(play_level_button[0], EventCursorDown, this, TitleUI.OnTitleUIStartGame)

		next_world_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		WindowSetParent(next_world_arrow, master_window_level)
		next_world_button = LabelWrapper(ui, tr("Next", "screen nav."), -10, 30, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(next_world_button[0], next_world_arrow)
		WindowSetEventHandlerWithContext(next_world_arrow, EventCursorDown, this, TitleUI.GoToNextWorldPage)		
		WindowSetEventHandlerWithContext(next_world_button[0], EventCursorDown, this, TitleUI.GoToNextWorldPage)

		WindowSetParent(game_title, master_window_handler)
		WindowSetParent(game_copyright[0], master_window_handler)
		WindowSetParent(gfx_hero, master_window_handler)
		WindowSetParent(title_left_arrow, master_window_handler)
		WindowSetParent(title_right_arrow, master_window_handler)
		WindowSetParent(title_leaderboard_arrow, master_window_handler)

		WindowSetParent(master_window_option, master_window_handler)
		WindowSetParent(master_window_level, master_window_handler)

//		WindowSetParent(level_easy_button[0], master_window_option)
//		WindowSetParent(level_normal_button[0], master_window_option)
//		WindowSetParent(level_hard_button[0], master_window_option)

		WindowSetParent(_control_reverse_button, master_window_option)
		WindowSetParent(_language_button, master_window_option)
		WindowSetParent(_credit_button, master_window_option)

		HandleLevelLock()
		
		WindowSetOpacity(master_window_option, 0.0)
		WindowSetOpacity(master_window_level, 0.0)

		switch(g_title_screen_index)
		{
			case -1:
				GoToOptionScreen()
				break;
			case 0:
			case 1:
				break;
		}

		//AddLogo()
	}

	function	Update()
	{
		base.Update()
		nickname_textfield.Update()
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
				WindowSetEventHandlerWithContext(_level_number_button[0], EventCursorDown, this, TitleUI.OnTitleUISelectLevel)
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
		local	_fname = "ui/minimaps/level_" + _idx.tostring()

		if (FileExists(_fname + ".png"))
			return EngineLoadTexture(g_engine, _fname + ".png")
		else
		if (FileExists(_fname + ".tga"))
			return EngineLoadTexture(g_engine, _fname + ".tga")
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
		ButtonFeedback(table.window)

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

		WindowSetEventHandlerWithContext(level_left_arrow, EventCursorDown, this, TitleUI.GoToPreviousWorldPage)
		WindowSetEventHandlerWithContext(back_from_level_button[0], EventCursorDown, this, TitleUI.GoToPreviousWorldPage)

		PlaySfxUISelect()
	}

	//-----------------------------------------
	function	GoToPreviousWorldPage(event, table)
	//-----------------------------------------
	{
		ButtonFeedback(table.window)

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
		{
			WindowSetEventHandlerWithContext(level_left_arrow, EventCursorDown, this, TitleUI.ScrollToTitleScreen)
			WindowSetEventHandlerWithContext(back_from_level_button[0], EventCursorDown, this, TitleUI.ScrollToTitleScreen)
		}
		else
		{
			WindowSetEventHandlerWithContext(level_left_arrow, EventCursorDown, this, TitleUI.GoToPreviousWorldPage)
			WindowSetEventHandlerWithContext(back_from_level_button[0], EventCursorDown, this, TitleUI.GoToPreviousWorldPage)
		}

		PlaySfxUISelect()
	}

	function	GoToLevelScreen(event, table)
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		MixerChannelStop(g_mixer, SceneGetScriptInstance(g_scene).channel_music)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_seasons.nms")
	}

	//-------------------------------------------
	function	ScrollToLevelScreen(event, table)
	//-------------------------------------------
	{
		if (table != 0)
			ButtonFeedback(table.window)

		current_world = 0
		CreateLevelButtonGrid()
		FadeInLevelButtonGrid()
		HiliteLevelSelection()

		WindowSetCommandList(master_window_level, "toalpha 0.5,1;")
		WindowSetCommandList(master_window_handler, CreateTweeningCommandList(WindowGetPosition(master_window_handler).x, -virtual_screen_width))
		PlaySfxUINextPage()
		g_title_screen_index = 1
	}

	//----------------------------
	function	GoToOptionScreen()
	//----------------------------
	{
		WindowSetCommandList(master_window_option, "toalpha 0.0,1;")
		WindowSetPosition(master_window_handler, virtual_screen_width, 0)
		g_title_screen_index = -1
	}

	//-------------------------------------------
	function	ScrollToOptionScreen(event, table)
	//-------------------------------------------
	{
		WindowSetCommandList(master_window_option, "toalpha 0.5,1;")
		WindowSetCommandList(master_window_handler, CreateTweeningCommandList(WindowGetPosition(master_window_handler).x, virtual_screen_width))
		PlaySfxUINextPage()
		g_title_screen_index = -1
	}

	//-------------------------------------------
	function	ScrollToTitleScreen(event, table)
	//-------------------------------------------
	{
		WindowSetCommandList(master_window_option, "toalpha 0.5,0.0;")
		WindowSetCommandList(master_window_level, "toalpha 0.5,0.0;")
		WindowSetCommandList(master_window_handler, CreateTweeningCommandList(WindowGetPosition(master_window_handler).x, 0))
		PlaySfxUINextPage()
		g_title_screen_index = 0

		GlobalSaveGame()
	}

	//---------------------------------------
	function	GotoLeaderboard(event, table)
	//---------------------------------------
	{
		ButtonFeedback(table.window)
		PlaySfxUINextPage()
		SceneGetScriptInstance(g_scene).GotoLeaderboard()
	}

	//--------------------------------------------
	function	OnTitleUIGotoCredits(event, table)
	//--------------------------------------------
	{
		ButtonFeedback(table.window)
		PlaySfxUINextPage()
		SceneGetScriptInstance(g_scene).GotoCredits()
	}

	//--------------------------------------------
	function	OnTitleUINextLanguage(event, table)
	//--------------------------------------------
	{
		SwitchToNextLanguage()
		GlobalSaveGame()
		SceneGetScriptInstance(g_scene).ReloadTitleScreen()
	}

	//--------------------------------------------
	function	OnTitleUISelectLevel(event, table)
	//--------------------------------------------
	{
		local	_button_id = SpriteGetName(table.sprite)
		local	_level = level_button_id_table[_button_id]
		current_selected_level = _level
		ProjectGetScriptInstance(g_project).player_data.current_selected_level = current_selected_level

		WindowSetParent(selector_hilite, table.sprite)
		WindowShow(selector_hilite, true)

		local	_x = WindowGetPosition(level_thumbnail).x
		local	_y = WindowGetPosition(level_thumbnail).y
		UIDeleteWindow(ui, level_thumbnail)
		level_thumbnail = LevelSelectorLoadLevelThumbnail(current_selected_level, _x, _y)
		WindowSetParent(level_thumbnail, master_window_level)
		WindowSetZOrder(level_lock_icon, -1.0)

//		TextSetText(level_name[1] , GetLevelName(current_selected_level))
//		TextSetText(level_name_shadow[1] , GetLevelName(current_selected_level))
		level_name[1].label = GetLevelName(current_selected_level)
		level_name[1].refresh()
		
		HandleLevelLock()

		PlaySfxUISelect()
	}
	
	//-------------------------------
	function	IsLevelLocked(_level)
	{
		local	game = ProjectGetScriptInstance(g_project)
		local	_level_key = "level_" + (Max(0, _level - 1)).tostring()
		
		if ((_level > 0) && (!game.player_data.rawin(_level_key) || !game.player_data[_level_key].complete))
			return	true
		else
			return false
	}

	function	HandleLevelLock()
	{		
		if (IsLevelLocked(current_selected_level))
		{
			WindowShow(level_lock_icon, true)
			WindowSetOpacity(level_thumbnail, 0.5)
			WindowSetOpacity(play_level_arrow, 0.5)
		}
		else
		{
			WindowShow(level_lock_icon, false)
			WindowSetOpacity(level_thumbnail, 1.0)
			WindowSetOpacity(play_level_arrow, 1.0)
		}
	}

	//----------------------------------------
	function	OnTitleUIStartGame(event, table)
	//----------------------------------------
	{
		ButtonFeedback(table.window)

		if (!IsLevelLocked(current_selected_level))
		{
			ProjectGetScriptInstance(g_project).player_data.current_level = current_selected_level
			SceneGetScriptInstance(g_scene).StartGame()
			PlaySfxUIValidate()
		}
		else
			PlaySfxUIError()
	}

	//	Options --------------------------

	//--------------------------------------
	function	CreateStringControlReverse()
	//--------------------------------------
	{	return (tr("Reverse Ctrl", "options") + "\n" + (g_reversed_controls?tr("Yes", "options"):tr("No", "options")))	}

	//------------------------------------------------
	function	OnTitleUIReverseControls(event, table)
	//------------------------------------------------
	{
		g_reversed_controls = !g_reversed_controls
//		TextSetText(control_reverse[1], CreateStringControlReverse())
		control_reverse[1].label = CreateStringControlReverse()
		control_reverse[1].refresh()
		GlobalSaveGame()
		PlaySfxUISelect()
		ButtonFeedback(table.window)
	}

	//-----------------------------------------
	function	CreateSelectedOptionString(str)
	//-----------------------------------------
	{	return  ("[" + str + "]")	}

	//---------------------------------
	function	SfxVolumeCreateString()
	//---------------------------------
	{
		return (tr("Sfx Volume", "options") + "\n" + (GlobalGetSfxVolume() * 100.0).tointeger().tostring() + "%") 
	}

	//-----------------------------------
	function	MusicVolumeCreateString()
	//-----------------------------------
	{
		return (tr("Music Volume", "options") + "\n" + (GlobalGetMusicVolume() * 100.0).tointeger().tostring() + "%") 
	}

	//------------------------------------------------
	function	OnTitleIncreaseSfxVolume(event, table)
	//------------------------------------------------
	{
		ButtonFeedback(table.window)

		local	_vol = GlobalGetSfxVolume()
		_vol += 0.1
		if (_vol > 1.01)
			_vol = 0.0

		GlobalSetSfxVolume(_vol)
		sfx_volume_button[1].label = SfxVolumeCreateString()
		sfx_volume_button[1].refresh()

		PlaySfxUISelect()
	}

	//--------------------------------------------------
	function	OnTitleIncreaseMusicVolume(event, table)
	//--------------------------------------------------
	{
		ButtonFeedback(table.window)

		local	_vol = GlobalGetMusicVolume()
		_vol += 0.1
		if (_vol > 1.01)
			_vol = 0.0

		GlobalSetMusicVolume(_vol)
		music_volume_button[1].label = MusicVolumeCreateString()
		music_volume_button[1].refresh()

		SceneGetScriptInstance(g_scene).TitleScreenSetMusicVolume()

		PlaySfxUISelect()
	}

}
