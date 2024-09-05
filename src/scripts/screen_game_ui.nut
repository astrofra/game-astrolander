//	Game UI

//--------------
class	InGameUI extends	BaseUI
//--------------
{
	scene					=	0
//	ui						=	0
	font_digital			=	0
	
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

//	inventory_bitmaps		=	0

	update_frequency		=	0

	how_to_control			=	0

	game_window				=	{
		game_over_no_fuel	= { handler = 0, window = 0, visible = false }
		game_over_damage	= { handler = 0, window = 0,  visible = false }
		game_over_time		= { handler = 0, window = 0,  visible = false }
		get_ready			= { handler = 0, window = 0,  visible = false }
		return_base			= { handler = 0, window = 0,  visible = false }
		mission_complete	= { handler = 0, window = 0,  visible = false }
	}

	pause_window			=	{
		global_handler	=	0
		pause_howto		=	{	button = 0, text = 0},
		pause_resume	=	{	button = 0, text = 0},
		pause_restart	=	{	button = 0, text = 0},
		pause_quit		=	{	button = 0, text = 0}
	}

	touch_feedback			=	0
	
	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		print("InGameUI::OnRenderContextChanged()")
		
		//	Hud
		life_gauge[1].rebuild()
		life_gauge[1].refresh()

		fuel_gauge[1].rebuild()
		fuel_gauge[1].refresh()

		artifact_count[1].rebuild()
		artifact_count[1].refresh()

		room_name[1].rebuild()
		room_name[1].refresh()
		
		//stopwatch[1].rebuild()
		//stopwatch[1].refresh()
		
		//	In game Message
		game_window.game_over_no_fuel.handler.rebuild()
		game_window.game_over_damage.handler.rebuild()
		game_window.game_over_time.handler.rebuild()
		game_window.get_ready.handler.rebuild()
		game_window.return_base.handler.rebuild()
		game_window.mission_complete.handler.rebuild()
		game_window.game_over_no_fuel.handler.refresh()
		game_window.game_over_damage.handler.refresh()
		game_window.game_over_time.handler.refresh()
		game_window.get_ready.handler.refresh()
		game_window.return_base.handler.refresh()
		game_window.mission_complete.handler.refresh()

		//	Pause menu
		pause_window.pause_howto.text[1].rebuild()
		pause_window.pause_howto.text[1].refresh()
		pause_window.pause_resume.text[1].rebuild()
		pause_window.pause_resume.text[1].refresh()
		pause_window.pause_restart.text[1].rebuild()
		pause_window.pause_restart.text[1].refresh()
		pause_window.pause_quit.text[1].rebuild()
		pause_window.pause_quit.text[1].refresh()
	}	
	
	//--------------
	constructor(_scene) //_ui)
	//--------------
	{		
		print("InGameUI::Setup()")
		scene = _scene
		base.constructor(SceneGetUI(scene))
		UICommonSetup(ui)
		font_digital = RendererLoadWriterFont(EngineGetRenderer(g_engine), "ui/profont.nml", "ui/profont")

		//	Create the main HUD
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

//		inventory_bitmaps = []
		game_window.game_over_no_fuel.handler	= CreateGameMessageWindow(tr("Game Over") + "\n" + "~~Size(60)" + tr("Out of Fuel!"))
		game_window.game_over_no_fuel.window	= game_window.game_over_no_fuel.handler.window

		game_window.game_over_damage.handler	= CreateGameMessageWindow(tr("Game Over") + "\n" + "~~Size(60)" + tr("Brain Damage!"))
		game_window.game_over_damage.window		= game_window.game_over_damage.handler.window
		
		game_window.game_over_time.handler		= CreateGameMessageWindow(tr("Game Over") + "\n" + "~~Size(60)" + tr("No Time Left!"))
		game_window.game_over_time.window		= game_window.game_over_time.handler.window
		
		game_window.get_ready.handler			= CreateGameMessageWindow(tr("Get Ready!"))
		game_window.get_ready.window			= game_window.get_ready.handler.window
		
		game_window.return_base.handler			= CreateGameMessageWindow(tr("Go to Base!\n~~Size(40)You found all the artifacts."))
		game_window.return_base.window			= game_window.return_base.handler.window
		
		game_window.mission_complete.handler	= CreateGameMessageWindow(tr("Mission Complete!"))
		game_window.mission_complete.window		= game_window.mission_complete.handler.window

		//	Create the "how to control the ship" UI elements.
		//how_to_control = HowToControl(ui)
	}
	
	//-----------------------------
	function	CreatePauseWindow()
	//-----------------------------
	{
		pause_window.global_handler = UIAddWindow(ui, -1, 0, 0, 1, 1)
		local	_tx = [0.2, 0.4, 0.6, 0.8], _temp = []
		foreach(x in _tx)
			_temp.append(RangeAdjust(x, 0.2, 0.8, 0.15, 0.85))
		_tx = _temp

		pause_window.pause_howto.button = AddButtonGreen(g_screen_width * _tx[1], message_origin_y, true)
		pause_window.pause_resume.button = AddButtonGreen(g_screen_width * _tx[0], message_origin_y, true)
		pause_window.pause_restart.button = AddButtonRed(g_screen_width * _tx[2], message_origin_y, true)
		pause_window.pause_quit.button = AddButtonRed(g_screen_width * _tx[3], message_origin_y, true)

		WindowSetZOrder(pause_window.pause_howto.button, -0.99)
		WindowSetZOrder(pause_window.pause_resume.button, -0.99)
		WindowSetZOrder(pause_window.pause_restart.button, -0.99)
		WindowSetZOrder(pause_window.pause_quit.button, -0.99)

		WindowSetParent(pause_window.pause_howto.button,pause_window.global_handler)
		WindowSetParent(pause_window.pause_resume.button,pause_window.global_handler)
		WindowSetParent(pause_window.pause_restart.button,pause_window.global_handler)
		WindowSetParent(pause_window.pause_quit.button,pause_window.global_handler)

		pause_window.pause_howto.text = LabelWrapper(ui, tr("HELP", "screen nav."), 0, 0, 50, 256, 128 - 10, g_ui_color_white , g_main_font_name, TextAlignCenter)
		pause_window.pause_resume.text = LabelWrapper(ui, tr("RESUME", "screen nav."), 0, 0, 50, 256, 128 - 10, g_ui_color_white , g_main_font_name, TextAlignCenter)
		pause_window.pause_restart.text = LabelWrapper(ui, tr("RESTART", "screen nav."), 0, 0, 50, 256,  128 - 10, g_ui_color_white, g_main_font_name, TextAlignCenter)
		pause_window.pause_quit.text = LabelWrapper(ui, tr("QUIT", "screen nav."), 0, 0, 50, 256,  128 - 10, g_ui_color_white, g_main_font_name, TextAlignCenter)

		WindowSetParent(pause_window.pause_howto.text[0], pause_window.pause_howto.button)
		WindowSetParent(pause_window.pause_resume.text[0], pause_window.pause_resume.button)
		WindowSetParent(pause_window.pause_restart.text[0], pause_window.pause_restart.button)
		WindowSetParent(pause_window.pause_quit.text[0], pause_window.pause_quit.button)

		WindowSetZOrder(pause_window.pause_howto.text[0], -0.99)
		WindowSetZOrder(pause_window.pause_resume.text[0], -0.99)
		WindowSetZOrder(pause_window.pause_restart.text[0], -0.99)
		WindowSetZOrder(pause_window.pause_quit.text[0], -0.99)

		WindowSetEventHandlerWithContext(pause_window.pause_howto.button, EventCursorDown, this, InGameUI.PauseHowTo)
		WindowSetEventHandlerWithContext(pause_window.pause_howto.text[0], EventCursorDown, this, InGameUI.PauseHowTo)

		WindowSetEventHandlerWithContext(pause_window.pause_resume.button, EventCursorDown, this, InGameUI.PauseResumeGame)
		WindowSetEventHandlerWithContext(pause_window.pause_resume.text[0], EventCursorDown, this, InGameUI.PauseResumeGame)

		WindowSetEventHandlerWithContext(pause_window.pause_restart.button, EventCursorDown, this, InGameUI.PauseRestartGame)
		WindowSetEventHandlerWithContext(pause_window.pause_restart.text[0], EventCursorDown, this, InGameUI.PauseRestartGame)

		WindowSetEventHandlerWithContext(pause_window.pause_quit.button, EventCursorDown, this, InGameUI.PauseQuitGame)
		WindowSetEventHandlerWithContext(pause_window.pause_quit.text[0], EventCursorDown, this, InGameUI.PauseQuitGame)


		WindowShow(pause_window.global_handler, false)
	}

	//--------------------------------------
	function	PauseHowTo(event, table)
	//--------------------------------------
	{
		print("InGameUI::PauseHowTo()")
		PlaySfxUIResume()
		if (how_to_control == 0)
			how_to_control = HowToControl(ui)
		how_to_control.OpenHowToControl()
		ButtonFeedback(table.window)
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

	//--------------------------------------
	function	PauseRestartGame(event, table)
	//--------------------------------------
	{
		print("InGameUI::PauseRestartGame()")
		PlaySfxUIResume()
		SceneGetScriptInstance(scene).RestartGame(scene)
		ButtonFeedback(table.window)
	}

	//--------------------------------------
	function	PauseQuitGame(event, table)
	//--------------------------------------
	{
		print("InGameUI::PauseQuitGame()")
		PlaySfxUIResume()
		SceneGetScriptInstance(scene).ResumeAndExitGame(scene)
		ButtonFeedback(table.window)
	}

	//---------------------------
	function	ShowPauseWindow()
	//---------------------------
	{
		print("InGameUI::ShowPauseWindow()")
		HideAllMessages()
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
	function	Update()
	//------------------------
	{
		base.Update()
		if (how_to_control != 0)
			how_to_control.Update()
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
				button_help = LabelWrapper(ui, tr("||", "screen nav."), 0, 0, 100, 128, 128, g_ui_color_white, g_main_font_name, TextAlignCenter)
				WindowSetParent(button_help[0], _button_sprite)
				//WindowSetOpacity(_button_sprite, 0.35)
				WindowSetEventHandlerWithContext(_button_sprite, EventCursorDown, this, InGameUI.OnGameUIHelp)
				WindowSetEventHandlerWithContext(button_help[0], EventCursorDown, this, InGameUI.OnGameUIHelp)

				if (EngineGetToolMode(g_engine) == NoTool)
					return

				local	_button_sprite = UIAddSprite(ui, -1, _button_texture, 0, 0, 128, 128)
				WindowSetPivot(_button_sprite, 64, 64)
				WindowSetScale(_button_sprite, 0.7, 0.7)
				WindowSetPosition(_button_sprite, -60 - (50 * 2.0), 50)
				button_skip = LabelWrapper(ui, tr(">>", "screen nav."), 0, -10, 100, 128, 128, g_ui_color_white, g_main_font_name, TextAlignCenter)
				WindowSetParent(button_skip[0], _button_sprite)
				//WindowSetOpacity(_button_sprite, 0.35)
				WindowSetEventHandlerWithContext(_button_sprite, EventCursorDown, this, InGameUI.OnGameUISkipLevel)
				WindowSetEventHandlerWithContext(button_skip[0], EventCursorDown, this, InGameUI.OnGameUISkipLevel)
				WindowSetZOrder(button_skip[0], -0.9)

	}

	//------------------------------------
	function	OnGameUIHelp(event, table)
	//------------------------------------
	{
		print("InGameUI::OnGameUIHelp()")
		ButtonFeedback(table.window)
		UIGamePause()
	}
	
	//-----------------------
	function	UIGamePause()
	//-----------------------
	{
		if (!SceneGetScriptInstance(scene).paused)
		{
			PlaySfxUIPause()
			HideAllMessages()
			SceneGetScriptInstance(scene).PauseGame()
		}
		else
		{
			SceneGetScriptInstance(scene).ResumeGame()
			PlaySfxUIResume()
		}
	}

	//---------------------------
	function	HideAllMessages()
	//---------------------------
	{
		WindowResetCommandList(game_window.game_over_no_fuel.window)
		WindowShow(game_window.game_over_no_fuel.window, false)
		WindowResetCommandList(game_window.game_over_damage.window)
		WindowShow(game_window.game_over_damage.window, false)
		WindowResetCommandList(game_window.game_over_time.window)
		WindowShow(game_window.game_over_time.window, false)
		WindowResetCommandList(game_window.get_ready.window)
		WindowShow(game_window.get_ready.window, false)
		WindowResetCommandList(game_window.return_base.window)
		WindowShow(game_window.return_base.window, false)
		WindowResetCommandList(game_window.mission_complete.window)
		WindowShow(game_window.mission_complete.window, false)
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
		local	screen_cursor_left = NormalizedToScreenSpace(left_pos.x, left_pos.y)
		local	screen_cursor_right = NormalizedToScreenSpace(right_pos.x, right_pos.y)
		WindowShow(touch_feedback.left, left_enabled)
		WindowShow(touch_feedback.right, right_enabled)
		WindowSetPosition(touch_feedback.left, screen_cursor_left.x, screen_cursor_left.y)
		WindowSetPosition(touch_feedback.right,screen_cursor_right.x, screen_cursor_right.y)
	}

	//----------------------------------------
	function	CreateGameMessageWindow(_text)
	//----------------------------------------
	{

		local	_message = Label(ui, 800, 300, g_screen_width / 2.0, message_origin_y, true, true)
		_message.label = _text
		_message.font = g_main_font_name
		_message.label_color = RGBAToHex(g_ui_color_black)
		_message.font_size = 80
		_message.refresh()
		WindowSetZOrder(_message.window, -0.925)
		WindowShow(_message.window, false)

		return _message
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
			WindowResetCommandList(_win.window)
			WindowSetCommandList(_win.window, "toalpha 0,0;show;toalpha " + (0.25 * g_clock_scale).tostring() + "," + g_clock_scale.tostring() + " ;")
		}
		else
		{
			HideMessageBackground()
			WindowResetCommandList(_win.window)
			WindowSetCommandList(_win.window, "toalpha 0,1;show;toalpha " + (0.25 / speed_scale * g_clock_scale).tostring() + ",0;hide;")
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
		WindowSetCommandList(_win.window, "toalpha 0,0;show;toalpha " + (0.25 * g_clock_scale).tostring() + "," + g_clock_scale.tostring() + ";nop " + (5 * g_clock_scale).tostring() + ";toalpha 0.25,0;")

		_win.visible = false
	}

	//----------------------------
	function	UpdateStopwatch(t)
	//----------------------------
	{
		WriterWrapper(font_digital, TimeToString(t), stopwatch.x, stopwatch.y, 0.75, g_ui_color_black.Scale(1.0 / 255.0))
	}

	//----------------------------------------
	function	UpdateLifeGauge(v)
	//----------------------------------------
	{		
		WindowSetSize(life_gauge[0], v.tofloat() * 5.0, 64)
	}

	//----------------------------------------
	function	UpdateFuelGauge(v)
	//----------------------------------------
	{	
		WindowSetSize(fuel_gauge[0], v.tofloat() * 5.0, 64)
	}

	//----------------------------------------
	function	UpdateRoomName(name)
	//----------------------------------------
	{		
		//TextSetText(room_name[1], name)	
		room_name[1].label = name
		room_name[1].refresh()
	}

	//----------------------------------------
	function	UpdateArtifactCounter(c)
	//----------------------------------------
	{		
		//TextSetText(artifact_count[1], c)	
		artifact_count[1].label = c
		artifact_count[1].refresh()
	}

	//----------------------------------------
	function	CreateGaugeBar(n, shadow_mode = false)
	//----------------------------------------
	{
		n = n.tointeger()

		local i, str
		str = ""
		if (!shadow_mode)
			str = "~~Color(237, 53, 28, 255)"

		for(i = 0; i < 100; i++)
		{
			str += "|"

			if (!shadow_mode)
			{
				if (i == 15)
					str = str + "~~Color(255, 147, 6, 255)"
				else
				if (i == 30)
					str = str + "~~Color(141, 198, 63, 255)"
			}
		}

		return str
	}
	
	//----------------------------------------
	function	CreateLevelName()
	//----------------------------------------
	{
		print("InGameUI::CreateLevelName()")
		local	_name = LabelWrapper(ui, "Level Name", 0, g_screen_height - 64, 32 * g_hud_font_size, 1024, 64, g_ui_color_black, g_hud_font_name)
		return _name
	}

	//----------------------------------------
	function	CreateStopwatch()
	//----------------------------------------
	{
		print("InGameUI::CreateStopwatch()")
		LabelWrapper(ui, tr("TIME", "hud"), g_screen_width - 400 - 16, 0, 32, 400)
		local	_stopwatch = Vector(g_screen_width - 400 + 32, 7, 0) //LabelWrapper(ui, TimeToString(0.0), g_screen_width - 400 + 130, 0, 32, 400, 64, g_hud_font_color, "profont")
		return _stopwatch
	}

	//----------------------------------------
	function	CreateArtifactCounter()
	//----------------------------------------
	{
		print("InGameUI::CreateArtifactCounter()")
		LabelWrapper(ui, tr("ARTIFACTS", "hud"), g_screen_width - 400 - 16, 40, 32, 380)// g_screen_height - 64, 32, 380)
		local	_counter = LabelWrapper(ui, "0/0", g_screen_width - 400 + 280,  40) //g_screen_height - 64)
		return _counter
	}
	//----------------------------------------
	function	CreateLifeGauge()
	//----------------------------------------
	{
		print("InGameUI::CreateLifeGauge()")

		LabelWrapper(ui, tr("LIFE", "hud"), 0, 0) //310 + 0, 0)
		local	_gauge_rule = LabelWrapper(ui, "~~Color(0,0,0,64)" + CreateGaugeBar(100, true), 160, 0, 32, 680)
		_gauge_rule[1].font_tracking = -5.0
		_gauge_rule[1].refresh()

		local	_gauge	= LabelWrapper(ui, CreateGaugeBar(100), 160, 0, 32, 680)
		_gauge[1].font_tracking = -5.0
		_gauge[1].refresh()

		return _gauge
	}

	//----------------------------------------
	function	CreateFuelGauge()
	//----------------------------------------
	{
		print("InGameUI::CreateFuelGauge()")

		LabelWrapper(ui, tr("FUEL", "hud"), 0, 40)
		local	_gauge_rule = LabelWrapper(ui, "~~Color(0,0,0,64)" + CreateGaugeBar(100, true),  160, 40, 32, 680)
		_gauge_rule[1].font_tracking = -5.0
		_gauge_rule[1].refresh()

		local	_gauge	= LabelWrapper(ui, CreateGaugeBar(100), 160, 40, 32, 680)
		_gauge[1].font_tracking = -5.0
		_gauge[1].refresh()

		return _gauge
	}
}