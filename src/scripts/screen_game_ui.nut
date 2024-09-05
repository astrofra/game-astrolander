//	Game UI

//--------------
class	InGameUI extends	BaseUI
//--------------
{
	scene					=	0
//	ui						=	0
	
	message_background		=	0
	life_gauge				=	0
	fuel_gauge				=	0
	artifact_count			=	0
	room_name				=	0
	stopwatch				=	0
	beacon_window			=	0
	beacon_angle			=	0
	
	button_help				=	0
	sprite_skip				=	0
	button_skip				=	0

	message_origin_y		=	g_screen_height / 2.0 + 250.0	//	Y coordinate of the ingame on screen messages

	inventory_bitmaps		=	0

	update_frequency		=	0

	game_window				=	{
		game_over_no_fuel	= { handler = 0, visible = false }
		game_over_damage	= { handler = 0, visible = false }
		game_over_time		= { handler = 0, visible = false }
		get_ready			= { handler = 0, visible = false }
		return_base			= { handler = 0, visible = false }
		mission_complete	= { handler = 0, visible = false }
	}

	pause_window			=	{
		global_handler	=	0
		pause_resume	=	{	button = 0, text = 0},
		pause_restart	=	{	button = 0, text = 0},
		pause_quit		=	{	button = 0, text = 0}
	}

	touch_feedback			=	0
	
	//--------------
	constructor(_scene) //_ui)
	//--------------
	{		
		print("InGameUI::Setup()")
		scene = _scene
		base.constructor(SceneGetUI(scene))
		UICommonSetup(ui)
		CreateHelpButtons()
		CreateMessageBackground()
		CreatePauseWindow()
		life_gauge = CreateLifeGauge()
		fuel_gauge = CreateFuelGauge()
		stopwatch = CreateStopwatch()
		room_name = CreateLevelName()
		artifact_count = CreateArtifactCounter()
		touch_feedback = CreateTouchFeedback()
		//beacon_window = CreateCompass()

		inventory_bitmaps = []
		game_window.game_over_no_fuel.handler	= CreateGameMessageWindow(g_locale.game_over + "\n" + "~~Size(60)" + g_locale.no_fuel)
		game_window.game_over_damage.handler	= CreateGameMessageWindow(g_locale.game_over + "\n" + "~~Size(60)" + g_locale.dead_by_damage)
		game_window.game_over_time.handler		= CreateGameMessageWindow(g_locale.game_over + "\n" + "~~Size(60)" + g_locale.no_time_left)
		game_window.get_ready.handler			= CreateGameMessageWindow(g_locale.get_ready)
		game_window.return_base.handler			= CreateGameMessageWindow(g_locale.return_base)
		game_window.mission_complete.handler	= CreateGameMessageWindow(g_locale.mission_complete)
	}
	
	//-----------------------------
	function	CreatePauseWindow()
	//-----------------------------
	{
		pause_window.global_handler = UIAddWindow(ui, -1, 0, 0, 1, 1)
		pause_window.pause_resume.button = AddButtonGreen(g_screen_width * 0.25, message_origin_y, true)
		pause_window.pause_restart.button = AddButtonRed(g_screen_width * 0.5, message_origin_y, true)
		pause_window.pause_quit.button = AddButtonRed(g_screen_width * 0.75, message_origin_y, true)

		WindowSetZOrder(pause_window.pause_resume.button, -0.99)
		WindowSetZOrder(pause_window.pause_restart.button, -0.99)
		WindowSetZOrder(pause_window.pause_quit.button, -0.99)

		WindowSetParent(pause_window.pause_resume.button,pause_window.global_handler)
		WindowSetParent(pause_window.pause_restart.button,pause_window.global_handler)
		WindowSetParent(pause_window.pause_quit.button,pause_window.global_handler)

		pause_window.pause_resume.text = CreateLabel(ui, g_locale.pause_resume_game, 0, 0, 50, 256, 128 - 10, g_ui_color_white , g_main_font_name, TextAlignCenter)
		pause_window.pause_restart.text = CreateLabel(ui, g_locale.pause_restart_level, 0, 0, 50, 256,  128 - 10, g_ui_color_white, g_main_font_name, TextAlignCenter)
		pause_window.pause_quit.text = CreateLabel(ui, g_locale.pause_quit_game, 0, 0, 50, 256,  128 - 10, g_ui_color_white, g_main_font_name, TextAlignCenter)

		WindowSetParent(pause_window.pause_resume.text[0], pause_window.pause_resume.button)
		WindowSetParent(pause_window.pause_restart.text[0], pause_window.pause_restart.button)
		WindowSetParent(pause_window.pause_quit.text[0], pause_window.pause_quit.button)

		WindowSetZOrder(pause_window.pause_resume.text[0], -0.99)
		WindowSetZOrder(pause_window.pause_restart.text[0], -0.99)
		WindowSetZOrder(pause_window.pause_quit.text[0], -0.99)

		WindowSetEventHandlerWithContext(pause_window.pause_resume.button, EventCursorDown, this, InGameUI.PauseResumeGame)
		WidgetSetEventHandlerWithContext(pause_window.pause_resume.text[1], EventCursorDown, this, InGameUI.PauseResumeGame)

		WindowShow(pause_window.global_handler, false)
	}

	//--------------------------------------
	function	PauseResumeGame(event, table)
	//--------------------------------------
	{
		print("InGameUI::PauseResumeGame()")
		PlaySfxUIResume()
		SceneGetScriptInstance(scene).ResumeGame()
		ButtonFeedback(table.window)
	}

	//---------------------------
	function	ShowPauseWindow()
	//---------------------------
	{
		print("InGameUI::ShowPauseWindow()")
		ShowMessageBackground()
		WindowSetCommandList(pause_window.global_handler, "toalpha 0,0;show;nop 0.1;toalpha 0.1,1;")
	}

	//---------------------------
	function	HidePauseWindow()
	//---------------------------
	{
		print("InGameUI::HidePauseWindow()")
		HideMessageBackground()
		WindowSetCommandList(pause_window.global_handler, "toalpha 0,1;show;nop 0.1;toalpha 0.1,0;hide;")
	}

	//-----------------------------
	function	IsCommandListDone()
	//-----------------------------
	{
		if (!WindowIsCommandListDone(pause_window.global_handler))
			return	false

		return	true
	}
	
	//-----------------------------------
	function	CreateMessageBackground()
	//-----------------------------------
	{
		local	_bg_handler	=	0
		_bg_handler = UIAddWindow(ui, -1, 0, 0, 1, 1)
		message_background = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/background_message.png"), g_screen_width / 2.0, message_origin_y, 512, 128)
		WindowSetPivot(message_background, 256, 64)
		WindowSetParent(message_background, _bg_handler)
		WindowSetScale(message_background, 6.0, 3.0)
		WindowSetOpacity(_bg_handler, 0.75)
		WindowShow(message_background, false)
		WindowSetZOrder(message_background, -0.9)
	}

	//------------------------
	function	UpdateCursor()
	//------------------------
	{
		base.UpdateCursor()
	}

	//---------------------------------	
	function	ShowMessageBackground()
	//---------------------------------	
	{
		WindowSetCommandList(message_background, "toalpha 0,0;toscale 0,6,0;show;toalpha 0.1, 1+toscale 0.2,6,3;")
	}

	//-------------------------------------
	function	ShowMessageBackgroundOnce()
	//-------------------------------------
	{
		WindowSetCommandList(message_background, "toalpha 0,0;toscale 0,6,0;show;toalpha 0.1, 1+toscale 0.2,6,3;nop " + (5.0 * g_clock_scale).tostring() + ";toalpha 0,1;toscale 0,6,3;toalpha 0.1, 0+toscale 0.1,6,0;hide;")
	}

	//---------------------------------
	function	HideMessageBackground()
	//---------------------------------
	{
		WindowSetCommandList(message_background, "nop 0.25;toalpha 0,1;toscale 0,6,3;toalpha 0.1, 0+toscale 0.1,6,0;hide;")
	}
	
	//-----------------------------
	function	CreateHelpButtons()
	//-----------------------------
	{
				local	_button_texture = EngineLoadTexture(g_engine, "ui/hud_button.png")

				local	_button_sprite = UIAddSprite(ui, -1, _button_texture, 0, 0, 128, 128)
				WindowSetPivot(_button_sprite, 64, 64)
				WindowSetScale(_button_sprite, 0.7, 0.7)
				WindowSetPosition(_button_sprite, -60, 50)
				button_help = CreateLabel(ui, g_locale.hud_help, 0, 0, 100, 128, 128, g_ui_color_white, g_main_font_name, TextAlignCenter)
				WindowSetParent(button_help[0], _button_sprite)
				//WindowSetOpacity(_button_sprite, 0.35)
				WindowSetEventHandlerWithContext(_button_sprite, EventCursorDown, this, InGameUI.OnGameUIHelp)
				WidgetSetEventHandlerWithContext(button_help[1], EventCursorDown, this, InGameUI.OnGameUIHelp)


				local	_button_sprite = UIAddSprite(ui, -1, _button_texture, 0, 0, 128, 128)
				WindowSetPivot(_button_sprite, 64, 64)
				WindowSetScale(_button_sprite, 0.7, 0.7)
				WindowSetPosition(_button_sprite, -60 - (50 * 2.0), 50)
				button_skip = CreateLabel(ui, g_locale.hud_skip, 0, -10, 100, 128, 128, g_ui_color_white, g_main_font_name, TextAlignCenter)
				WindowSetParent(button_skip[0], _button_sprite)
				//WindowSetOpacity(_button_sprite, 0.35)
				WindowSetEventHandlerWithContext(_button_sprite, EventCursorDown, this, InGameUI.OnGameUISkipLevel)
				WidgetSetEventHandlerWithContext(button_help[1], EventCursorDown, this, InGameUI.OnGameUIHelp)
				WindowSetZOrder(button_skip[0], -0.9)
	}

	//------------------------------------
	function	OnGameUIHelp(event, table)
	//------------------------------------
	{
		print("InGameUI::OnGameUIHelp()")
		PlaySfxUIPause()
		ButtonFeedback(table.window)
		HideAllMessages()
		SceneGetScriptInstance(scene).PauseGame() //ExitGame(scene)
	}

	//---------------------------
	function	HideAllMessages()
	//---------------------------
	{
		WindowShow(game_window.game_over_no_fuel.handler, false)
		WindowResetCommandList(game_window.game_over_no_fuel.handler)
		WindowShow(game_window.game_over_damage.handler, false)
		WindowResetCommandList(game_window.game_over_damage.handler)
		WindowShow(game_window.game_over_time.handler, false)
		WindowResetCommandList(game_window.game_over_time.handler)
		WindowShow(game_window.get_ready.handler, false)
		WindowResetCommandList(game_window.get_ready.handler)
		WindowShow(game_window.return_base.handler, false)
		WindowResetCommandList(game_window.return_base.handler)
		WindowShow(game_window.mission_complete.handler, false)
		WindowResetCommandList(game_window.mission_complete.handler)
	}

	//-----------------------------------------
	function	OnGameUISkipLevel(event, table)
	//-----------------------------------------
	{
		print("InGameUI::OnGameUISkipLevel()")
		ButtonFeedback(table.window)
		SceneGetScriptInstance(scene).GoToLevelEndScreen(scene)
	}

	function	CreateTouchFeedback()
	{
		local	_texture,
				_touch_feedback = { left = 0, right = 0	},
				_touch_scale

		_touch_scale = 2.0

		_texture = EngineLoadTexture(g_engine, "ui/touch_feedback.png")
		_touch_feedback.left = UIAddSprite(ui, CreateNewUIID(), _texture, 0.0, 0.0, 256.0, 256.0)
		WindowCenterPivot(_touch_feedback.left)
		WindowSetPosition(_touch_feedback.left, (g_screen_width * 0.5) * 0.3, (g_screen_height * 0.5) + 256.0)
		WindowSetScale(_touch_feedback.left, _touch_scale, _touch_scale)

		_touch_feedback.right = UIAddSprite(ui, CreateNewUIID(), _texture, 0.0, 0.0, 256.0, 256.0)
		WindowCenterPivot(_touch_feedback.right)
		WindowSetPosition(_touch_feedback.right, g_screen_width - (g_screen_width * 0.5) * 0.3, (g_screen_height * 0.5) + 256.0)
		WindowSetScale(_touch_feedback.right, _touch_scale, _touch_scale)

		WindowShow(_touch_feedback.left, false)
		WindowShow(_touch_feedback.right, false)

		return _touch_feedback
	}

	function	UpdateTouchFeedback(left_enabled, right_enabled, 
									left_pos = Vector(0.3, 0.7, 0),
									right_pos = Vector(1.0 - 0.3, 0.7, 0) )
	{
		WindowShow(touch_feedback.left, left_enabled)
		WindowShow(touch_feedback.right, right_enabled)
		WindowSetPosition(touch_feedback.left, left_pos.x * g_screen_width, left_pos.y * g_screen_height)
		WindowSetPosition(touch_feedback.right, right_pos.x * g_screen_width, right_pos.y * g_screen_height)
	}

	//-------------------------
	function	CreateCompass()
	//-------------------------
	{
		print("InGameUI::CreateCompass()")
		local	compass_window, beacon_window
		local	_texture

		_texture = EngineLoadTexture(g_engine, "ui/beacon_arrow.png")
		beacon_window = UIAddSprite(ui, CreateNewUIID(), _texture, 0.0, 0.0, 245.0, 245.0)
		WindowCenterPivot(beacon_window)

		WindowSetPosition(beacon_window, 245.0 / 2.0, 245.0 / 2.0)
		WindowSetScale(beacon_window, 0.85, 0.85)

		return beacon_window
	}

	//-------------------------------
	function	UpdateCompass(_pos, _angle)
	//-------------------------------
	{

		WindowSetPosition(beacon_window, _pos.x, _pos.y)
		WindowSetRotation(beacon_window, _angle)
	}

	//----------------------------------------
	function	CreateGameMessageWindow(_text)
	//----------------------------------------
	{
		local	_window, _widget
		//	Start menu window
		_window = UIAddWindow(ui, -1, g_screen_width / 2.0, message_origin_y, 800.0, 300.0)
//		WindowSetStyle(_window, StyleMovable)
		WindowSetTitle(_window, "")
		WindowCenterPivot(_window)		
		WindowSetCommandList(_window, "hide;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(ui, -1);
		WindowSetBaseWidget(_window, hsizer);
		
		//local	_title_name = "Game Over"
		_widget = UIAddStaticTextWidget(ui, -1, _text, g_main_font_name)
		TextSetParameters(_widget, { size = 80, align = "center", color = 0x000000ff })
		SizerAddWidget(hsizer, _widget)

		WindowSetZOrder(_window, -1.0)

		//	window_game_over = _window
		return _window
	}

	//-------------------------------------------------------------------------------------
	function	GameMessageWindowSetVisible(window_handler, flag = true, speed_scale = 1.0)
	//-------------------------------------------------------------------------------------
	{
		local	_win = game_window[window_handler]

		if (_win.visible == flag)
			return

		print("InGameUI::GameMessageWindowSetVisible('" + window_handler + "') : flag = " + flag)

		if (flag)
		{
			ShowMessageBackground()
			WindowResetCommandList(_win.handler)
			WindowSetCommandList(_win.handler, "toalpha 0,0;show;toalpha " + (0.25 * g_clock_scale).tostring() + "," + g_clock_scale.tostring() + " ;")
		}
		else
		{
			HideMessageBackground()
			WindowResetCommandList(_win.handler)
			WindowSetCommandList(_win.handler, "toalpha 0,1;show;toalpha " + (0.25 / speed_scale * g_clock_scale).tostring() + ",0;hide;")
		}

		_win.visible = flag
	}

	//----------------------------------------
	function	GameMessageWindowShowOnce(window_handler)
	//----------------------------------------
	{
		local	_win = game_window[window_handler]
		if (_win.visible == true)
			return

		ShowMessageBackgroundOnce()
		WindowSetCommandList(_win.handler, "toalpha 0,0;show;toalpha " + (0.25 * g_clock_scale).tostring() + "," + g_clock_scale.tostring() + ";nop " + (5 * g_clock_scale).tostring() + ";toalpha 0.25,0;")

		_win.visible = false
	}

	//----------------------------------------
	function	UpdateInventory(inventory)
	//----------------------------------------
	{
		local	x,y
		local	i, new_bitmap

		x = 650.0
		y = 8.0

		foreach(i in inventory_bitmaps)
			UIDeleteWindow(ui, i)

		inventory_bitmaps = []
/*
		foreach(i in inventory)
		{
			new_bitmap = UIAddBitmapWindow(ui, -1, "data/maps/keys/" + i + ".tga", x, y, 256, 256)
			WindowSetScale(new_bitmap, 0.175, 0.175)
			inventory_bitmaps.append(new_bitmap)
			x += 32
		}
		*/
	}

	//----------------------------
	function	UpdateStopwatch(t)
	//----------------------------
	{
		if (++update_frequency > 5)
		{
			TextSetText(stopwatch[1], TimeToString(t))
			update_frequency = 0
		}

		update_frequency++
	}

	//----------------------------------------
	function	UpdateLifeGauge(v)
	//----------------------------------------
	{		TextSetText(life_gauge[1], CreateGaugeBar(v))	}

	//----------------------------------------
	function	UpdateFuelGauge(v)
	//----------------------------------------
	{		TextSetText(fuel_gauge[1], CreateGaugeBar(v))	}

	//----------------------------------------
	function	UpdateRoomName(name)
	//----------------------------------------
	{		TextSetText(room_name[1], name)	}

	//----------------------------------------
	function	UpdateArtifactCounter(c)
	//----------------------------------------
	{		TextSetText(artifact_count[1], c)	}

	//----------------------------------------
	function	CreateGaugeBar(n)
	//----------------------------------------
	{
		n = (n.tofloat() / 2.0).tointeger()
		local i, str
		str = ""
		for(i = 0; i < n; i++)
			str += "|"

		return str
	}
	
	//----------------------------------------
	function	CreateLevelName()
	//----------------------------------------
	{
		print("InGameUI::CreateLevelName()")
		local	_name = CreateLabel(ui, "Level Name", 0, g_screen_height - 64, 32, 1024)
		return _name
	}

	//----------------------------------------
	function	CreateStopwatch()
	//----------------------------------------
	{
		print("InGameUI::CreateStopwatch()")
		CreateLabel(ui, g_locale.hud_stopwatch, g_screen_width - 400, 0, 32, 400)
		local	_stopwatch = CreateLabel(ui, TimeToString(0.0), g_screen_width - 400 + 130, 0, 32, 400, 64, g_hud_font_color, "profont")
		return _stopwatch
	}

	//----------------------------------------
	function	CreateArtifactCounter()
	//----------------------------------------
	{
		print("InGameUI::CreateArtifactCounter()")
		CreateLabel(ui, g_locale.hud_artifacts, g_screen_width - 400, 40, 32, 380)// g_screen_height - 64, 32, 380)
		local	_counter = CreateLabel(ui, "0/0", g_screen_width - 400 + 280,  40) //g_screen_height - 64)
		return _counter
	}
	//----------------------------------------
	function	CreateLifeGauge()
	//----------------------------------------
	{
		print("InGameUI::CreateLifeGauge()")

		CreateLabel(ui, g_locale.hud_damage, 0, 0) //310 + 0, 0)
		CreateLabel(ui, "~~Color(0,0,0,64)" + CreateGaugeBar(100), 200, 0, 32, 680)
		local	_gauge	= CreateLabel(ui, CreateGaugeBar(100), 200, 0, 32, 680)
		return _gauge
	}

	//----------------------------------------
	function	CreateFuelGauge()
	//----------------------------------------
	{
		print("InGameUI::CreateFuelGauge()")

		CreateLabel(ui, g_locale.hud_fuel, 0, 40)
		CreateLabel(ui, "~~Color(0,0,0,64)" + CreateGaugeBar(100),  200, 40, 32, 680)
		local	_gauge	= CreateLabel(ui, CreateGaugeBar(100), 200, 40, 32, 680)
		return _gauge
	}
}