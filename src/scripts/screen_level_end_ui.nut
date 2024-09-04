//	Level End UI

//--------------
class	LevelEndUI extends	BaseUI
//--------------
{
	scene					=	0

	level_name				=	0
	blue_background			=	0

	skip_arrow				=	0
	skip_button				=	0

	life_window				=	0
	fuel_window				=	0
	score_window			=	0

	life_counter			=	0
	fuel_counter			=	0
	score_counter			=	0

	perfect_message			=	0
	score_bonus_message		=	0

	old_stats				=	0
	
	constructor(_ui)
	{
		print("LevelEndUI::constructor()")

		base.constructor(_ui)

		CreateOpaqueScreen(_ui)

		old_stats	=	{}	

		local	blue_background_texture = EngineLoadTexture(g_engine, "ui/main_menu_back.png")
		blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetPosition(blue_background, g_screen_width / 2.0 - (TextureGetWidth(blue_background_texture) / 2.0 * 1.5), g_screen_height / 2.0 - (TextureGetHeight(blue_background_texture) / 2.0 * 1.5))
		WindowSetZOrder(blue_background, 1.0)

		local	_main_window_handle = UIAddWindow(ui, -1, 0, 200, 1, 1)

		//	Level Name

		level_name = CreateLabel(ui, "Level Name", g_screen_width / 2.0 - 400.0, 0, 80, 800, 120, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)

		//	Skip button
		skip_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		skip_button = CreateLabel(ui, g_locale.skip_screen, -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(skip_button[0], skip_arrow)
//		WindowSetParent(skip_arrow, _main_window_handle)
		WidgetSetEventHandlerWithContext(skip_button[1], EventCursorDown, this, LevelEndUI.SkipEndLevelScreen) //OnTitleUIStartGame)


		//	Scores ...

		life_window = UIAddWindow(ui,-1,0,0,2,2)
		local	_life_title = CreateLabel(ui, g_locale.endlevel_life, 0, 0, 80, 400, 120, Vector(117, 155, 168, 180), g_main_font_name, TextAlignCenter)
		life_counter = CreateLabel(ui, "", 150, 0, 80, 600, 120, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetParent(_life_title[0], life_window)
		WindowSetParent(life_counter[0], life_window)

		fuel_window = UIAddWindow(ui,-1,0,0,2,2)
		local	_fuel_title = CreateLabel(ui, g_locale.endlevel_fuel, 0, 100, 80, 400, 120, Vector(117, 155, 168, 180), g_main_font_name, TextAlignCenter)
		fuel_counter = CreateLabel(ui, "", 150, 100, 80 600, 120, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetParent(_fuel_title[0], fuel_window)
		WindowSetParent(fuel_counter[0], fuel_window)

		score_window = UIAddWindow(ui,-1,0,0,2,2)
		local	_score_title = CreateLabel(ui, g_locale.endlevel_score, 0, 200, 80, 400, 120, Vector(117, 155, 168, 180), g_main_font_name, TextAlignCenter)
		score_counter = CreateLabel(ui, "", 150, 200, 80, 600, 120, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetParent(_score_title[0], score_window)
		WindowSetParent(score_counter[0], score_window)

		WindowSetParent(score_window, _main_window_handle)
		WindowSetParent(life_window, _main_window_handle)
		WindowSetParent(fuel_window, _main_window_handle)

		WindowSetOpacity(life_window, 0.0)
		WindowSetOpacity(fuel_window, 0.0)
		WindowSetOpacity(score_window, 0.0)

		WindowSetCommandList(life_window, "toalpha 0.25, 1.0+toposition 0.25, 300, 0;") 
		WindowSetCommandList(fuel_window, "nop 0.1;toalpha 0.25, 1.0+toposition 0.25, 300, 0;") 
		WindowSetCommandList(score_window, "nop 0.2;toalpha 0.25, 1.0+toposition 0.25, 300, 0;") 

		//	Messages....

		perfect_message = CreateLabel(ui, g_locale.endlevel_perfect, 0, 0, 100, 800, 150, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetPivot(perfect_message[0], 400, 75)
		WindowSetPosition(perfect_message[0], (g_screen_width * 0.5), 380.0)
		WindowSetOpacity(perfect_message[0], 0.0)
		WindowShow(perfect_message[0], false)

		score_bonus_message = CreateLabel(ui, "+ 1000", 0, 0, 70, 800, 150, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetPivot(score_bonus_message[0], 400, 75)
		WindowSetPosition(score_bonus_message[0], (g_screen_width * 0.5), 460.0)
		WindowSetOpacity(score_bonus_message[0], 0.0)
		WindowShow(score_bonus_message[0], false)

		WindowSetParent(perfect_message[0], _main_window_handle)
		WindowSetParent(score_bonus_message[0], _main_window_handle)
	}

	function	SkipEndLevelScreen(event, table)
	{
		PlaySfxUINextPage()
		SceneGetScriptInstance(g_scene).skip = true
		ButtonFeedback(table.window)
	}

	function	UpdateLevelName(_name)
	{
		TextSetText(level_name[1], _name)
	}

	function	FadeOutScoreDebrief()
	{
		print("LevelEndUI::FadeOutScoreDebrief()")
		WindowSetCommandList(life_window,	"toalpha 0.25,0.0;")
		WindowSetCommandList(fuel_window,	"nop 0.1;toalpha 0.25,0.0;")
		WindowSetCommandList(score_window,	"nop 0.2;toalpha 0.25,0.0;")
		WindowSetCommandList(level_name[0],	"toalpha 0.25,0.0;")
		WindowSetCommandList(blue_background,	"toalpha 0.25,0.0;")
		WindowSetCommandList(skip_arrow,	"toalpha 0.25,0.0;")
	}

	function	ShowStoryImage(n)
	{
		print("LevelEndUI::ShowStoryImage() n = " + n)
		local	story_texture, fname
		fname = "ui/story_" + n.tostring() + ".jpg"
		if (FileExists(fname))
		{
			story_texture = EngineLoadTexture(g_engine, fname)
			local	story_image
			story_image = UIAddSprite(ui, -1, story_texture, 0, 0, TextureGetWidth(story_texture), TextureGetHeight(story_texture))
			WindowShow(story_image, false)
			WindowSetPivot(story_image, TextureGetWidth(story_texture) * 0.5, TextureGetHeight(story_texture) * 0.5)
			WindowSetPosition(story_image, g_screen_width * 0.5, g_screen_height * 0.5)
			WindowSetOpacity(story_image, 0.0)
			WindowSetCommandList(story_image, "nop 0.5; show; toalpha 2.0, 1.0+toscale 10.0,1.1,1.1;")
		}
		else
		{
			print("LevelEndUI::ShowStoryImage() : Cannot find file '" + fname + "'.")
		}
	}

	function	ShowMessagePerfect()
	{
		WindowShow(perfect_message[0], false)
		TextSetText(perfect_message[1], g_locale.endlevel_perfect)
		WindowSetCommandList(perfect_message[0], "hide; toalpha 0,0; toscale 0.0, 0.5, 0.5; show; toalpha 0.1, 1.0+toscale 0.1, 1.0, 1.0; nop 1.0; toalpha 1.5, 0.0+toscale 1.5, 0.75, 0.75; hide;")
	}

	function	ShowMessageScoreBonus(_bonus = " + 1000")
	{
		WindowShow(score_bonus_message[0], false)
		TextSetText(score_bonus_message[1], _bonus.tostring())
		WindowSetCommandList(score_bonus_message[0], "hide; toalpha 0,0; toscale 0.0, 0.5, 0.5; show; toalpha 0.1, 1.0+toscale 0.1, 1.0, 1.0; nop 0.5; toalpha 1.0, 0.0+toscale 1.0, 0.75, 0.75; hide;")
	}

	function	ShowNewRecordLife()
	{
		WindowShow(perfect_message[0], false)
		TextSetText(perfect_message[1], g_locale.endlevel_life_record)
		WindowSetCommandList(perfect_message[0], "hide; toalpha 0,0; toscale 0.0, 0.5, 0.5; show; toalpha 0.1, 1.0+toscale 0.1, 1.0, 1.0; nop 1.0; toalpha 1.5, 0.0+toscale 1.5, 0.75, 0.75; hide;")
	}

	function	ShowNewRecordTime()
	{
		WindowShow(perfect_message[0], false)
		TextSetText(perfect_message[1], g_locale.endlevel_time_record)
		WindowSetCommandList(perfect_message[0], "hide; toalpha 0,0; toscale 0.0, 0.5, 0.5; show; toalpha 0.1, 1.0+toscale 0.1, 1.0, 1.0; nop 1.0; toalpha 1.5, 0.0+toscale 1.5, 0.75, 0.75; hide;")
	}

	function	ShowNewRecordFuel()
	{
		WindowShow(perfect_message[0], false)
		TextSetText(perfect_message[1], g_locale.endlevel_fuel_record)
		WindowSetCommandList(perfect_message[0], "hide; toalpha 0,0; toscale 0.0, 0.5, 0.5; show; toalpha 0.1, 1.0+toscale 0.1, 1.0, 1.0; nop 1.0; toalpha 1.5, 0.0+toscale 1.5, 0.75, 0.75; hide;")
	}

	function	UpdateStats(stats)
	{
		if (old_stats != stats)
		{ 
			TextSetText(life_counter[1],stats.life.tostring())
			TextSetText(fuel_counter[1],stats.fuel.tostring())
			TextSetText(score_counter[1], stats.score.tostring())
		}

		old_stats = stats
	}

	function	UpdateCursor()
	{
		base.UpdateCursor()
	}

}