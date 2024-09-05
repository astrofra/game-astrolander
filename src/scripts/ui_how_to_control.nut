/*
	"How To Control the Ship"
*/

//---------------------------------------
function	ThreadHideHowToControl(scene)
//---------------------------------------
{
	print("ThreadHideHowToControl()")
	local	_this = SceneGetScriptInstance(scene).game_ui.how_to_control
	HowToControlFadeSprite(_this.skip_arrow, Sec(0.1), "fade_out")
	HowToControlFadeSprite([_this.how_to_device,_this.how_to_touch_left, _this.how_to_touch_right, _this.how_to_use_ship_up, _this.how_to_use_ship_left, _this.how_to_use_ship_right]
, Sec(0.25), "fade_out")
	HowToControlFadeSprite(_this.focus_layer, Sec(0.1), "fade_out")

	SpriteShow(_this.how_to_touch_left, false)
	SpriteShow(_this.how_to_touch_right, false)
	SpriteShow(_this.how_to_use_ship_nop, false)
	SpriteShow(_this.how_to_use_ship_left, false)
	SpriteShow(_this.how_to_use_ship_right, false)
	SpriteShow(_this.how_to_use_ship_up, false)
	WindowShow(_this.skip_arrow, false)
	WindowShow(_this.focus_layer, false)
}

//---------------------------------------
function	ThreadShowHowToControl(scene)
//---------------------------------------
{
	print("ThreadShowHowToControl()")
	local	_this = SceneGetScriptInstance(scene).game_ui.how_to_control

	//	Ship alone
	HowToControlFadeSprite(_this.focus_layer, Sec(0.1), "fade_in")
	HowToControlFadeSprite([_this.how_to_device, _this.how_to_use_ship_nop], Sec(0.5), "fade_in")
	RawClockThreadWait(Sec(0.1))
	HowToControlFadeSprite(_this.skip_arrow, Sec(0.25), "fade_in")

	RawClockThreadWait(Sec(0.5))

	//	Going left
	HowToControlFadeSprite([_this.how_to_touch_left, _this.how_to_use_ship_left], Sec(0.5), "fade_in")
	RawClockThreadWait(Sec(2.0))
	HowToControlFadeSprite([_this.how_to_touch_left, _this.how_to_use_ship_left], Sec(0.25), "fade_out")

	RawClockThreadWait(Sec(0.25))

	//	Going right
	HowToControlFadeSprite([_this.how_to_touch_right, _this.how_to_use_ship_right], Sec(0.5), "fade_in")
	RawClockThreadWait(Sec(2.0))
	HowToControlFadeSprite([_this.how_to_touch_right, _this.how_to_use_ship_right], Sec(0.25), "fade_out")

	RawClockThreadWait(Sec(0.25))

	//	Going up
	HowToControlFadeSprite([_this.how_to_touch_left, _this.how_to_touch_right, _this.how_to_use_ship_up], Sec(0.5), "fade_in")
	RawClockThreadWait(Sec(2.0))
	HowToControlFadeSprite([_this.how_to_touch_left, _this.how_to_touch_right, _this.how_to_use_ship_up], Sec(0.25), "fade_out")

	RawClockThreadWait(Sec(1.0))
	HowToControlFadeSprite(_this.how_to_device, Sec(0.5), "fade_out")
	HowToControlFadeSprite(_this.focus_layer, Sec(0.1), "fade_out")

	SpriteShow(_this.how_to_touch_left, false)
	SpriteShow(_this.how_to_touch_right, false)
	SpriteShow(_this.how_to_use_ship_nop, false)
	SpriteShow(_this.how_to_use_ship_left, false)
	SpriteShow(_this.how_to_use_ship_right, false)
	SpriteShow(_this.how_to_use_ship_up, false)
	WindowShow(_this.skip_arrow, false)
}

//---------------------------------------
function	HowToControlFadeSprite(spr, time_span = Sec(0.5), mode = "fade_in")
//---------------------------------------
{
	local	_clock = 0, _in, _out
	local	spr_array

	if (!(typeof spr == "array"))
		spr_array = [spr]
	else
		spr_array = spr

	if (mode == "fade_in")
	{
		foreach(spr in spr_array)
		{
			SpriteSetOpacity(spr, 0.0)
			SpriteShow(spr, true)
		}
		_in = 0.0
		_out = 1.0
	}
	else
	if (mode == "fade_out")
	{
		_in = 1.0
		_out = 0.0
	}

	while(_clock < time_span)
	{
		_clock += g_raw_dt_frame
		foreach(spr in spr_array)
			SpriteSetOpacity(spr, RangeAdjust(_clock, 0.0, time_span, _in, _out))
		suspend()
	}

	if (mode == "fade_out")
	{
		foreach(spr in spr_array)
		{
			SpriteSetOpacity(spr, 0.0)
			SpriteShow(spr, false)
		}
	}
}

//----------------------------------------------------
class	HowToControl	extends	SceneWithThreadHandler
//----------------------------------------------------
{

	ui						=	0
	game_ui					=	0

	focus_layer				=	"focus_layer.tga"
	how_to_device			=	"how_to_device.png"
	how_to_touch_left		=	"how_to_touch_left.png"
	how_to_touch_right		=	"how_to_touch_right.png"
	how_to_use_ship_left	=	"how_to_use_ship_left.png"
	how_to_use_ship_right	=	"how_to_use_ship_right.png"
	how_to_use_ship_up		=	"how_to_use_ship_up.png"
	how_to_use_ship_nop		=	"how_to_use_ship_nop.png"

	skip_arrow			=	0
	skip_button			=	0

	constructor(_ui)
	{
		ui = _ui
		game_ui = SceneGetScriptInstance(g_scene).game_ui

		//	Transparent layer to slightly fade the main display
		focus_layer = CreateFocusLayer()

		//	Visual elements showing how to control the ship
		how_to_device = CreateUISprite(how_to_device, "center_pivot", g_screen_width * 0.5, g_screen_height * 0.5)
		how_to_touch_left = CreateUISprite(how_to_touch_left)
		how_to_touch_right = CreateUISprite(how_to_touch_right)
		how_to_use_ship_left = CreateUISprite(how_to_use_ship_left, "center_pivot")
		how_to_use_ship_right = CreateUISprite(how_to_use_ship_right, "center_pivot")
		how_to_use_ship_up = CreateUISprite(how_to_use_ship_up, "center_pivot")
		how_to_use_ship_nop = CreateUISprite(how_to_use_ship_nop, "center_pivot")

		SpriteSetParent(how_to_use_ship_nop, how_to_device)
		SpriteSetParent(how_to_use_ship_left, how_to_device)
		SpriteSetParent(how_to_use_ship_right, how_to_device)
		SpriteSetParent(how_to_use_ship_up, how_to_device)
		SpriteSetParent(how_to_touch_left, how_to_device)
		SpriteSetParent(how_to_touch_right, how_to_device)

		SpriteSetPosition(how_to_use_ship_nop, SpriteGetRect(how_to_device).GetWidth() * 0.475, SpriteGetRect(how_to_device).GetHeight() * 0.35)
		SpriteSetPosition(how_to_use_ship_left, SpriteGetRect(how_to_device).GetWidth() * 0.475, SpriteGetRect(how_to_device).GetHeight() * 0.35)
		SpriteSetPosition(how_to_use_ship_right, SpriteGetRect(how_to_device).GetWidth() * 0.475, SpriteGetRect(how_to_device).GetHeight() * 0.35)
		SpriteSetPosition(how_to_use_ship_up, SpriteGetRect(how_to_device).GetWidth() * 0.475, SpriteGetRect(how_to_device).GetHeight() * 0.35)

		SpriteSetPosition(how_to_touch_left, 199, 163)
		SpriteSetPosition(how_to_touch_right, 499, 173)

		SpriteSetScale(how_to_device, 1.5, 1.5)
		SpriteShow(how_to_device, false)
		SpriteShow(focus_layer, false)

		SpriteShow(how_to_touch_left, false)
		SpriteShow(how_to_touch_right, false)
		SpriteShow(how_to_use_ship_nop, false)
		SpriteShow(how_to_use_ship_left, false)
		SpriteShow(how_to_use_ship_right, false)
		SpriteShow(how_to_use_ship_up, false)

		//	Skip button
		skip_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700 - 32, 256, 128)
		skip_button = LabelWrapper(ui, tr("Skip", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(skip_button[0], skip_arrow)
		SpriteSetZOrder(skip_arrow, -0.99)
		SpriteSetZOrder(skip_button[0], -0.99)
		WindowShow(skip_arrow, false)
		WindowSetEventHandlerWithContext(skip_arrow, EventCursorDown, this, HowToControl.CloseHowToControl)
		WindowSetEventHandlerWithContext(skip_button[0], EventCursorDown, this, HowToControl.CloseHowToControl)

		base.Setup(g_scene)
	}

	function	CreateFocusLayer()
	{
		local	dr = RendererGetViewport(g_render)
		local spr = CreateUISprite(focus_layer, "center_pivot", g_screen_width * 0.5, g_screen_height * 0.5)
		SpriteSetScale(spr, 0, 0)
		return spr
	}

	function	UpdateFocusLayer()
	{
		local	dr = RendererGetViewport(g_render)
		local	s = (dr.z > dr.w)?dr.z:dr.w

		SpriteSetScale(focus_layer, s / 256 * 2.5, s / 256 * 2.5)
	}

	function	OpenHowToControl()
	{
		CreateThread(ThreadShowHowToControl)
	}

	function	CloseHowToControl(event, table)
	{
		DestroyThread(ThreadShowHowToControl)
		CreateThread(ThreadHideHowToControl)
		game_ui.PlaySfxUIValidate()
	}

	function	CreateUISprite(spr_name, center_pivot = 0, x = 0.0, y = 0.0)
	{
		local	tex = EngineLoadTexture(g_engine, "ui/" + spr_name)
		local	spr = UIAddSprite(ui, -1, tex, x, y, TextureGetWidth(tex), TextureGetHeight(tex))
		SpriteSetZOrder(spr, -0.99)
		if (center_pivot == "center_pivot")
			SpriteSetPivot(spr,  TextureGetWidth(tex) * 0.5, TextureGetHeight(tex) * 0.5)
		return spr
	}

	function	Update()
	{
		HandleThreadList()
		UpdateFocusLayer()
	}
}