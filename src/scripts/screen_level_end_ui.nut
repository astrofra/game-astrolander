//	Level End UI

//--------------
class	LevelEndUI extends	BaseUI
//--------------
{
	scene					=	0

	level_name				=	0
	blue_background			=	0

	label_table				=	0

	next_button				=	0

	old_stats				=	0
	
	constructor(_ui)
	{
		print("LevelEndUI::constructor()")

		base.constructor(_ui)

		CreateOpaqueScreen(_ui)

		local	blue_background_texture = EngineLoadTexture(g_engine, "ui/main_menu_back.png")
		blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetPosition(blue_background, g_screen_width / 2.0 - (TextureGetWidth(blue_background_texture) / 2.0 * 1.5), g_screen_height / 2.0 - (TextureGetHeight(blue_background_texture) / 2.0 * 1.5))
		WindowSetZOrder(blue_background, 1.0)

		old_stats	=	{}
		label_table = []
	}
	
	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		print("LevelEndUI::OnRenderContextChanged()")
		next_button[1].rebuild()
		next_button[1].refresh()
		
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
						str += "~~Color(255, 200, 150, 255)" + " [" + line.bonus.tostring() + " " + g_locale.score_points + "]"
				_label.label = str
				_label.font = g_main_font_name
				_label.font_size = (n == 0)?80:((n == debrief_table.len() - 1)?100:60)
				if ("text" in line)
					_label.label_align = "left"
				_label.label_color = RGBAToHex(g_ui_color_yellow)
				_label.refresh()

				label_table.append(_label)
			}

			base_y += g_screen_height * 0.1

			if (n == 0)
				base_y += g_screen_height * 0.07 * 0.75
			if (n == debrief_table.len() - 2)
				base_y += g_screen_height * 0.07 * 0.75
		}
	}

	function	AddNextButton()
	{
		//	Back button
		local	next_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		next_button = LabelWrapper(ui, g_locale.next_level, -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(next_button[0], next_arrow)
		WindowSetEventHandlerWithContext(next_arrow, EventCursorDown, this, LevelEndUI.GotoNextGame)
		WindowSetEventHandlerWithContext(next_button[0], EventCursorDown, this, LevelEndUI.GotoNextGame)
		WindowSetCommandList(next_arrow, "toalpha 0,0;nop 0.5;toalpha 0.25,1;")
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
	function	ShowStoryImage(n)
	//---------------------------
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

	function	UpdateCursor()
	{
		base.UpdateCursor()
	}

}