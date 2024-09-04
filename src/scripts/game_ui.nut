//	Game UI

//--------------
class	InGameUI extends	BaseUI
//--------------
{
	scene					=	0
//	ui						=	0
	
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

	inventory_bitmaps		=	0

	update_frequency		=	0

	game_window			=	{
		game_over_no_fuel	= { handler = 0, visible = false }
		game_over_damage	= { handler = 0, visible = false }
		game_over_time		= { handler = 0, visible = false }
		get_ready			= { handler = 0, visible = false }
		return_base			= { handler = 0, visible = false }
		mission_complete	= { handler = 0, visible = false }
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

	function	UpdateCursor()
	{
		base.UpdateCursor()
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
				button_help = CreateLabel(ui, g_locale.hud_help, 0, 0, 100, 128, 128, Vector(0, 0, 0, 255), g_main_font_name, TextAlignCenter)
				WindowSetParent(button_help[0], _button_sprite)
				WindowSetOpacity(_button_sprite, 0.35)
				WidgetSetEventHandlerWithContext(button_help[1], EventCursorDown, this, InGameUI.OnGameUIHelp)


				local	_button_sprite = UIAddSprite(ui, -1, _button_texture, 0, 0, 128, 128)
				WindowSetPivot(_button_sprite, 64, 64)
				WindowSetScale(_button_sprite, 0.7, 0.7)
				WindowSetPosition(_button_sprite, -60 - (50 * 2.0), 50)
				button_skip = CreateLabel(ui, g_locale.hud_skip, 0, -10, 100, 128, 128, Vector(0, 0, 0, 255), g_main_font_name, TextAlignCenter)
				WindowSetParent(button_skip[0], _button_sprite)
				WindowSetOpacity(_button_sprite, 0.35)
				WidgetSetEventHandlerWithContext(button_skip[1], EventCursorDown, this, InGameUI.OnGameUISkipLevel)
				WindowSetZOrder(button_skip[0], -0.9)
	}

	//-----------------------------------------
	function	OnGameUIHelp(event, table)
	//-----------------------------------------
	{
		print("InGameUI::OnGameUIHelp()")
		SceneGetScriptInstance(scene).ExitGame(scene)
	}

	//-----------------------------------------
	function	OnGameUISkipLevel(event, table)
	//-----------------------------------------
	{
		print("InGameUI::OnGameUISkipLevel()")
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
		WindowSetPosition(_touch_feedback.left, 640.0 * 0.3, 480.0 + 256.0)
		WindowSetScale(_touch_feedback.left, _touch_scale, _touch_scale)

		_touch_feedback.right = UIAddSprite(ui, CreateNewUIID(), _texture, 0.0, 0.0, 256.0, 256.0)
		WindowCenterPivot(_touch_feedback.right)
		WindowSetPosition(_touch_feedback.right, 1280.0 - 640.0 * 0.3, 480.0 + 256.0)
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
		WindowSetPosition(touch_feedback.left, left_pos.x * 1280.0, left_pos.y * 960.0)
		WindowSetPosition(touch_feedback.right, right_pos.x * 1280.0, right_pos.y * 960.0)
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
		_window = UIAddWindow(ui, -1, 1280.0 / 2.0, 960.0 / 2.0 + 120.0, 800.0, 300.0)
//		WindowSetStyle(_window, StyleMovable)
		WindowSetTitle(_window, "")
		WindowCenterPivot(_window)		
		WindowSetCommandList(_window, "hide;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(ui, -1);
		WindowSetBaseWidget(_window, hsizer);
		
		//local	_title_name = "Game Over"
		_widget = UIAddStaticTextWidget(ui, -1, _text, g_main_font_name)
		TextSetParameters(_widget, { size = 80, align = "center", color = 0xffffffff })
		SizerAddWidget(hsizer, _widget)

		//	window_game_over = _window
		return _window
	}

	//----------------------------------------
	function	GameMessageWindowSetVisible(window_handler, flag = true, speed_scale = 1.0)
	//----------------------------------------
	{
		local	_win = game_window[window_handler]

		if (_win.visible == flag)
			return

		print("InGameUI::GameMessageWindowSetVisible('" + window_handler + "') : flag = " + flag)


		if (flag)
		{
			WindowResetCommandList(_win.handler)
			WindowSetCommandList(_win.handler, "toalpha 0,0;show;toalpha " + (0.75 * g_clock_scale).tostring() + "," + g_clock_scale.tostring() + " ;")
		}
		else
		{
			WindowResetCommandList(_win.handler)
			WindowSetCommandList(_win.handler, "toalpha 0,1;show;toalpha " + (0.75 / speed_scale * g_clock_scale).tostring() + ",0;hide;")
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

		WindowSetCommandList(_win.handler, "toalpha 0,0;show;toalpha " + (0.75 * g_clock_scale).tostring() + "," + g_clock_scale.tostring() + ";nop " + (5 * g_clock_scale).tostring() + ";toalpha 1.5,0;")

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
		local	_name = CreateLabel(ui, "Level Name", 0, 960 - 64, 32, 1024)
		return _name
	}

	//----------------------------------------
	function	CreateStopwatch()
	//----------------------------------------
	{
		print("InGameUI::CreateStopwatch()")
		CreateLabel(ui, g_locale.hud_stopwatch, 1280 - 400, 0, 32, 400)
		local	_stopwatch = CreateLabel(ui, TimeToString(0.0), 1280 - 400 + 130, 0, 32, 400, 64, g_hud_font_color, "profont")
		return _stopwatch
	}

	//----------------------------------------
	function	CreateArtifactCounter()
	//----------------------------------------
	{
		print("InGameUI::CreateArtifactCounter()")
		CreateLabel(ui, g_locale.hud_artifacts, 1280 - 400, 40, 32, 380)// 960 - 64, 32, 380)
		local	_counter = CreateLabel(ui, "0/0", 1280 - 400 + 280,  40) //960 - 64)
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