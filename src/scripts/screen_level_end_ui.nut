//	Level End UI

//--------------
class	LevelEndUI extends	BaseUI
//--------------
{
	scene					=	0

	level_name				=	0
	blue_background			=	0

	label_table				=	0

	next_arrow				=	0
	next_button				=	0

	story_image				=	0
	story_line				=	0

	old_stats				=	0
	
	//--------------
	constructor(_ui)
	//--------------
	{
		print("LevelEndUI::constructor()")

		base.constructor(_ui)
		CreateOpaqueScreen(_ui)

		old_stats	=	{}
		label_table = []
	}

	//--------------------------------
	function	CreateBlueBackground()
	//--------------------------------
	{
		local	blue_background_texture = EngineLoadTexture(g_engine, "ui/main_menu_back.png")
		blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetPosition(blue_background, g_screen_width / 2.0 - (TextureGetWidth(blue_background_texture) / 2.0 * 1.5), g_screen_height / 2.0 - (TextureGetHeight(blue_background_texture) / 2.0 * 1.5))
		WindowSetZOrder(blue_background, 1.0)
	}
	
	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		print("LevelEndUI::OnRenderContextChanged()")
		next_button[1].rebuild()
		next_button[1].refresh()

		story_line.rebuild()
		story_line.refresh()
		
		foreach(_label in label_table)
		{
			_label.rebuild()
			_label.refresh()
		}
	}

	//---------------------------------------
	function	DisplayDebrief(debrief_table)
	//---------------------------------------
	{
		print("LevelEndUI::DisplayDebrief()")

		CreateBlueBackground()

		local	base_y = 170

		foreach(n, line in debrief_table)
		{
			local	_label

			if ("text" in line)
			{
				_label = Label(ui, g_screen_width * 0.5, 128,  g_screen_width * 0.5 - g_screen_width * 0.25 - 16, base_y, true, true)
				_label.label = line.text // + " :"
				_label.font = g_main_font_name
				_label.font_size = (n == 0)?80:60
				_label.label_align = "right"
				_label.label_color = RGBAToHex(g_ui_color_blue)
				_label.refresh()

				label_table.append(_label)

				if (n == debrief_table.len() - 1)
					WindowSetCommandList(_label.window, "hide;toalpha 0,0;nop 0.5;show;toalpha 0.15,1;")
			}

			if ("value" in line)
			{
				if ("text" in line)
					_label = Label(ui, g_screen_width * 0.5, 128,  g_screen_width * 0.5 + g_screen_width * 0.25 + 16, base_y, true, true)
				else
					_label = Label(ui, g_screen_width, 128, g_screen_width * 0.5, base_y, true, true)

				local	str = line.value.tostring()
				if ("bonus" in line)
					if (line.bonus > 0)
						str += "~~Color(255, 200, 150, 255)" + " [" + line.bonus.tostring() + " " + tr("points", "end level") + "]"
				_label.label = str
				_label.font = g_main_font_name
				_label.font_size = (n == 0)?80:((n == debrief_table.len() - 1)?100:60)
				if ("text" in line)
					_label.label_align = "left"
				_label.label_color = RGBAToHex(g_ui_color_yellow)
				_label.refresh()

				label_table.append(_label)

				if (n == debrief_table.len() - 1)
					WindowSetCommandList(_label.window, "hide;toalpha 0,0;nop 0.5;show;toalpha 0.25,1;")
			}

			base_y += g_screen_height * 0.1

			if (n == 0)
				base_y += g_screen_height * 0.07 * 0.75
			if (n == debrief_table.len() - 2)
				base_y += g_screen_height * 0.07 * 0.75
		}
	}

	//-----------------------------------
	function	AddNextStoryImageButton()
	//-----------------------------------
	{
		//	Back button
		next_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		next_button = LabelWrapper(ui, tr("Next", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(next_button[0], next_arrow)
		WindowSetEventHandlerWithContext(next_arrow, EventCursorDown, this, LevelEndUI.GotoScoreBrief)
		WindowSetEventHandlerWithContext(next_button[0], EventCursorDown, this, LevelEndUI.GotoScoreBrief)
		WindowSetCommandList(next_arrow, "toalpha 0,0;nop 4.5;toalpha 0.25,1;")
	}

	//------------------------------------
	function	GotoScoreBrief(event, table)
	//------------------------------------
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		SceneGetScriptInstance(g_scene).EndStoryImage(g_scene)
	}

	//-------------------------
	function	AddNextButton()
	//-------------------------
	{
		//	Back button
		next_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		next_button = LabelWrapper(ui, tr("Next", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(next_button[0], next_arrow)
		WindowSetEventHandlerWithContext(next_arrow, EventCursorDown, this, LevelEndUI.GotoNextGame)
		WindowSetEventHandlerWithContext(next_button[0], EventCursorDown, this, LevelEndUI.GotoNextGame)
		WindowSetCommandList(next_arrow, "toalpha 0,0;nop 1.5;toalpha 0.25,1;")
	}

	//------------------------------------
	function	GotoNextGame(event, table)
	//------------------------------------
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		SceneGetScriptInstance(g_scene).GotoNextLevel(g_scene)
	}

	//---------------------------
	function	LoadStoryImage(n)
	//---------------------------
	{
		print("LevelEndUI::ShowStoryImage() n = " + n)
		local	story_texture, fname
		fname = "ui/story_" + n.tostring() + ".jpg"

		//	Image
		if (FileExists(fname))
		{
			story_texture = EngineLoadTexture(g_engine, fname)
			story_image = UIAddSprite(ui, -1, story_texture, 0, 0, TextureGetWidth(story_texture), TextureGetHeight(story_texture))
			WindowShow(story_image, false)
			WindowSetPivot(story_image, TextureGetWidth(story_texture) * 0.5, TextureGetHeight(story_texture) * 0.5)
			WindowSetPosition(story_image, g_screen_width * 0.5, g_screen_height * 0.5)
			WindowSetOpacity(story_image, 0.0)
			WindowSetCommandList(story_image, "nop 2.0; show;toalpha 3.0,0.2+toscale 3.0,1.02,1.02;toalpha 2.5,1.0+toscale 9.0,1.1,1.1;")
		}
		else
		{
			print("LevelEndUI::ShowStoryImage() : Cannot find file '" + fname + "'.")
		}

		//	Text
		local	story_line_locale = "story_" + n.tostring()
		if (story_line_locale in g_locale)
		{
			local	gradient_sprite = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/black_gradient_alpha.png"), 0, 0, 16, 256)
			WindowSetPivot(gradient_sprite, 16 * 0.5, 256 * 0.5)
			WindowSetPosition(gradient_sprite, g_screen_width * 0.5, g_screen_height * 0.65)
			WindowSetScale(gradient_sprite, 100.0, 3.5)
//			WindowSetOpacity(gradient_sprite, 0.0)
			WindowSetCommandList(gradient_sprite, "nop 0.25; nop 4.0;toalpha 1.5,0.0;")

			story_line = Label(ui, g_screen_width * 0.75, 256,  g_screen_width * 0.5, g_screen_height * 0.65, true, true)
			story_line.label = g_locale[story_line_locale]
			story_line.font = g_main_font_name
			story_line.font_size = 60
			story_line.label_align = "right"
			story_line.label_color = RGBAToHex(g_ui_color_white)
			story_line.glow = true
			story_line.glow_radius = 5.0
			story_line.refresh()
			WindowSetScale(story_line.window, 1.1, 1.1)
			WindowSetCommandList(story_line.window, "nop 0.25; show; toalpha 1.0,1.0+toscale 4.5,0.995,0.995;toalpha 0.5,0.0+toscale 4.75,0.95,0.95;")
		}
	}

	//--------------------------
	function	HideStoryImage()
	//--------------------------
	{
		WindowSetCommandList(story_image, "show;toalpha 0.75,0.0;hide;")
		WindowSetCommandList(next_arrow, "show;toalpha 0.15,0.0;hide;")
	}

	//----------------------------
	function	StoryImageIsGone()
	//----------------------------
	{
		if (story_image == 0)
			return true

		if (WindowIsCommandListDone(story_image))
			return true

		return false
	}

	function	UpdateCursor()
	{
		base.Update()
	}

}