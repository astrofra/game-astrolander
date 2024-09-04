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

function	UICommonSetup()
{
	UILoadFont ("ui/aerial.ttf")
}

function	CreateLabel(ui, name, x, y, size = 32, w = 200, h = 64, font_color = g_hud_font_color)
{
	// Create UI window.
	local	window = UIAddWindow(ui, -1, x, y, w, h)

	// Center window pivot.
	//WindowSetPivot(window, w / 2, h / 2)

	// Create UI text widget and set as window base widget.
	local	widget = UIAddStaticTextWidget(ui, -1, name, "aerial")
	WindowSetBaseWidget(window, widget)

	// Set text attributes.
	TextSetSize(widget, size)
	TextSetColor(widget, font_color.x, font_color.y, font_color.z, font_color.w)
	TextSetAlignment(widget, TextAlignLeft)

	// Return window.
	return [ window, widget ]
}


class	HudUI
{
	ui						= 0
	
	Damage_gauge			= 0
	fuel_gauge				= 0
	room_name				= 0

	inventory_bitmaps		= 0
	
	constructor(_ui)
	{		
		print("HudUI::Setup()")
		ui = _ui
		UICommonSetup()
		Damage_gauge = CreateDamageGauge()
		fuel_gauge = CreateFuelGauge()
		room_name = CreateLevelName()
		inventory_bitmaps = []
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
		print("HudUI::CreateLevelName()")
		local	_name = CreateLabel(ui, "Level Name", 0, 960 - 64, 32, 1024)
		return _name
	}

	function	CreateDamageGauge()
	{
		print("HudUI::CreateDamageGauge()")

		CreateLabel(ui, g_locale.hud_damage, 310 + 0, 0)
		local	_gauge	= CreateLabel(ui, CreateGaugeBar(100), 310 + 200, 0)
		return _gauge
	}

	function	CreateFuelGauge()
	{
		print("HudUI::CreateFuelGauge()")

		CreateLabel(ui, g_locale.hud_fuel, 0, 0)
		local	_gauge	= CreateLabel(ui, CreateGaugeBar(100), 150, 0, 32)
		return _gauge
	}
}