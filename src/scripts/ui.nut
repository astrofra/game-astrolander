/* UI
*/

		Include("scripts/locale.nut")

g_ui_IDs			<-	0
g_hud_font_color	<-	Vector(0,0,0,255)

function	CreateNewUIID()
{
	return g_ui_IDs
	g_ui_IDs++
}

function	UICommonSetup(ui)
{
	UILoadFont("ui/anna.ttf")
	UILoadFont("ui/aerial.ttf")
	UILoadFont("ui/creative_block.ttf")

/*	
	//	Will crash if un-commented
    UISetSkin    (
                    ui, "ui/skin/t.tga", "ui/skin/l.tga", "ui/skin/r.tga", "ui/skin/b.tga",
                    "ui/skin/tl.tga", "ui/skin/tr.tga", "ui/skin/bl.tga", "ui/skin/br.tga", 0xff9ebc24,
                    0xffffffff, 30, 20, 10, "anna"
                )
*/

}

function	CreateLabel(ui, name, x, y, size = 32, w = 200, h = 64, font_color = g_hud_font_color, font_name = "aerial")
{
	// Create UI window.
	local	window = UIAddWindow(ui, -1, x, y, w, h)

	// Center window pivot.
	//WindowSetPivot(window, w / 2, h / 2)

	// Create UI text widget and set as window base widget.
	local	widget = UIAddStaticTextWidget(ui, -1, name, font_name)
	WindowSetBaseWidget(window, widget)

	// Set text attributes.
	TextSetSize(widget, size)
	TextSetColor(widget, font_color.x, font_color.y, font_color.z, font_color.w)
	TextSetAlignment(widget, TextAlignLeft)

	// Return window.
	return [ window, widget ]
}


class	InGameUI
{
	ui						=	0
	
	Damage_gauge			=	0
	fuel_gauge				=	0
	room_name				=	0

	inventory_bitmaps		=	0

	game_window			=	{
		game_over_no_fuel	= { handler = 0, visible = false }
		game_over_damage	= { handler = 0, visible = false }
		game_over_time		= { handler = 0, visible = false }
		get_ready			= { handler = 0, visible = false }
		return_base			= { handler = 0, visible = false }
	}
	
	constructor(_ui)
	{		
		print("InGameUI::Setup()")
		ui = _ui
		UICommonSetup(ui)
		Damage_gauge = CreateDamageGauge()
		fuel_gauge = CreateFuelGauge()
		room_name = CreateLevelName()
		inventory_bitmaps = []
		game_window.game_over_no_fuel.handler	= CreateGameMessageWindow(g_locale.game_over + "\n" + "~~Size(60)" + g_locale.no_fuel)
		game_window.game_over_damage.handler	= CreateGameMessageWindow(g_locale.game_over + "\n" + "~~Size(60)" + g_locale.dead_by_damage)
		game_window.game_over_time.handler		= CreateGameMessageWindow(g_locale.game_over + "\n" + "~~Size(60)" + g_locale.no_time_left)
		game_window.get_ready.handler			= CreateGameMessageWindow(g_locale.get_ready)
		game_window.return_base.handler			= CreateGameMessageWindow(g_locale.return_base)
	}

	function	CreateGameMessageWindow(_text)
	{
		local	_window, _widget
		//	Start menu window
		_window = UIAddWindow(ui, -1, 1280.0 / 2.0, 960.0 / 2.0, 800.0, 300.0)
		WindowSetStyle(_window, StyleMovable)
		WindowSetTitle(_window, "")
		WindowCenterPivot(_window)		
		WindowSetCommandList(_window, "hide;")
		
		//	Start menu widget
		local	hsizer = UIAddHorizontalSizerWidget(ui, -1);
		WindowSetBaseWidget(_window, hsizer);
		
		//local	_title_name = "Game Over"
		_widget = UIAddStaticTextWidget(ui, -1, _text, "creative_block")
		TextSetParameters(_widget, { size = 80, align = "center", color = 0xffffffff })
		SizerAddWidget(hsizer, _widget)

		//	window_game_over = _window
		return _window
	}

	function	GameMessageWindowSetVisible(window_handler, flag = true)
	{
		local	_win = game_window[window_handler]
		if (_win.visible == flag)
			return

		if (flag)
			WindowSetCommandList(_win.handler, "toalpha 0,0;show;toalpha 0.75,1;")
		else
			WindowSetCommandList(_win.handler, "toalpha 0,1;toalpha 0.75,0;hide;")

		_win.visible = flag
	}

	function	GameMessageWindowShowOnce(window_handler)
	{
		local	_win = game_window[window_handler]
		if (_win.visible == true)
			return

		WindowSetCommandList(_win.handler, "toalpha 0,0;show;toalpha 0.75,1;nop 5;toalpha 1.5,0;")

		_win.visible = true
	}

	function	UpdateInventory(inventory)
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

	function	UpdateDamageGauge(v)
	{		TextSetText(Damage_gauge[1], CreateGaugeBar(v))	}

	function	UpdateFuelGauge(v)
	{		TextSetText(fuel_gauge[1], CreateGaugeBar(v))	}

	function	UpdateRoomName(name)
	{		TextSetText(room_name[1], name)	}

	function	CreateGaugeBar(n)
	{
		n = (n.tofloat() / 10.0).tointeger()
		local i, str
		str = ""
		for(i = 0; i < n; i++)
			str += "|"

		return str
	}
	
	function	CreateLevelName()
	{
		print("InGameUI::CreateLevelName()")
		local	_name = CreateLabel(ui, "Level Name", 0, 960 - 64, 32, 1024)
		return _name
	}

	function	CreateDamageGauge()
	{
		print("InGameUI::CreateDamageGauge()")

		CreateLabel(ui, g_locale.hud_damage, 310 + 0, 0)
		local	_gauge	= CreateLabel(ui, CreateGaugeBar(100), 310 + 200, 0)
		return _gauge
	}

	function	CreateFuelGauge()
	{
		print("InGameUI::CreateFuelGauge()")

		CreateLabel(ui, g_locale.hud_fuel, 0, 0)
		local	_gauge	= CreateLabel(ui, CreateGaugeBar(100), 150, 0, 32)
		return _gauge
	}
}