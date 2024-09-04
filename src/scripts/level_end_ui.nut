//	Level End UI

//--------------
class	LevelEndUI extends	BaseUI
//--------------
{
	scene					=	0

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

		old_stats	=	{}	

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

		WindowSetOpacity(life_window, 0.0)
		WindowSetOpacity(fuel_window, 0.0)
		WindowSetOpacity(score_window, 0.0)

		WindowSetCommandList(life_window, "toalpha 0.25, 1.0+toposition 0.25, 300, 0;") 
		WindowSetCommandList(fuel_window, "nop 0.1;toalpha 0.25, 1.0+toposition 0.25, 300, 0;") 
		WindowSetCommandList(score_window, "nop 0.2;toalpha 0.25, 1.0+toposition 0.25, 300, 0;") 

		//	Messages....

		perfect_message = CreateLabel(ui, g_locale.endlevel_perfect, 0, 0, 100, 800, 150, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetPivot(perfect_message[0], 400, 75)
		WindowSetPosition(perfect_message[0], 640.0, 380.0)
		WindowSetOpacity(perfect_message[0], 0.0)
		WindowShow(perfect_message[0], false)

		score_bonus_message = CreateLabel(ui, "+ 1000", 0, 0, 70, 800, 150, g_ui_color_yellow, g_main_font_name, TextAlignCenter)
		WindowSetPivot(score_bonus_message[0], 400, 75)
		WindowSetPosition(score_bonus_message[0], 640.0, 460.0)
		WindowSetOpacity(score_bonus_message[0], 0.0)
		WindowShow(score_bonus_message[0], false)
	}

	function	FadeOutScoreDebrief()
	{
		print("LevelEndUI::FadeOutScoreDebrief()")
		WindowSetCommandList(life_window,	"toalpha 0.25,0.0;")
		WindowSetCommandList(fuel_window,	"nop 0.1;toalpha 0.25,0.0;")
		WindowSetCommandList(score_window,	"nop 0.2;toalpha 0.25,0.0;")
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
			WindowSetPosition(story_image, 1280.0 * 0.5, 960.0 * 0.5)
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
		TextSetText(perfect_message[1], g_locale.endlevel_new_record)
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