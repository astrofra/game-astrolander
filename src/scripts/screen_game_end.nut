/*
	File: scripts/screen_credits.nut
	Author: Astrofra
*/

/*!
	@short	CreditsScreen
	@author	Astrofra
*/

Include("scripts/credits.nut")

//--------------------------------
class	GameEndUI	extends	BaseUI
//--------------------------------
{
	background			=	0

	skip_arrow			=	0
	skip_button			=	0

	credit_table		=	0

	scroll_y			=	0
	scroll_height 		=	0

	main_handler		=	0

	photo_table			=	0
	
	function	OnRenderContextChanged()
	{
		print("GameEndUI::OnRenderContextChanged()")

		skip_button[1].rebuild()
		skip_button[1].refresh()

		foreach(_line in credit_table)
		{
			_line.rebuild()
			_line.refresh()
		}
	}

	constructor(_ui)
	{
		base.constructor(_ui)

		CreateOpaqueScreen(ui)

		UICommonSetup(ui)

		main_handler = UIAddWindow(ui, -1, 0, 0, 1, 1)
		scroll_y = g_screen_height * 0.75
		WindowSetPosition(main_handler, 0, scroll_y)

	}

	//--------------------------
	function	DrawQuitButton()
	//--------------------------
	{
		//	Back button
		skip_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		skip_button = LabelWrapper(ui, tr("Skip", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(skip_button[0], skip_arrow)
		WindowSetEventHandlerWithContext(skip_arrow, EventCursorDown, this, GameEndUI.BackToTitleScreen)
		WindowSetEventHandlerWithContext(skip_button[0], EventCursorDown, this, GameEndUI.BackToTitleScreen)
		WindowSetCommandList(skip_arrow, "hide;toalpha 0,0;nop 5.5;show;toalpha 0.25,1;")
	}

	//-----------------------------
	function	DrawCredits(_table)
	//-----------------------------
	{
		local	is_even = true
		local	base_y = 128
		local	line_photo_counter = 0
		local	photo_counter = 0
		credit_table = []

		photo_table	= [	{a = "ui/photo_0_a.jpg", b = "ui/photo_0_b.jpg"}, 
						{a = "ui/photo_1_a.jpg", b = "ui/photo_1_b.jpg"},
						{a = "ui/photo_2_a.jpg", b = "ui/photo_2_b.jpg"}
					]

		foreach(n, _str in _table)
		{
			print("GameEndUI::DrawCredits() : _line = " + _str)

			local	_line
			_line = Label(ui, 1024, 128,  g_screen_width * 0.5, base_y, true, true)
			_line.label = _str 
			_line.font = g_main_font_name
			_line.font_size = (_str.len() < 30)?(is_even?45:60):30

			_line.drop_shadow = true
			_line.label_color = is_even?RGBAToHex(g_ui_color_grey):RGBAToHex(g_ui_color_white)

			_line.refresh()

			credit_table.append(_line)

			WindowSetParent(_line.window, main_handler)

			if (line_photo_counter == 3)
			{
				line_photo_counter = -1
				local	_photo_index = Mod(photo_counter, photo_table.len())
				local	_photo_tex = EngineLoadTexture(g_engine, photo_table[_photo_index].a)
				local	_photo = UIAddSprite(ui, -1, _photo_tex, g_screen_width * 0.5, base_y + (TextureGetHeight(_photo_tex) * 0.5 * 1.4), TextureGetWidth(_photo_tex), TextureGetHeight(_photo_tex))	
				base_y += TextureGetHeight(_photo_tex) * 1.25
				WindowSetPivot(_photo, TextureGetWidth(_photo_tex) * 0.5, TextureGetHeight(_photo_tex) * 0.5)
				WindowSetParent(_photo, main_handler)
				WindowSetRotation(_photo, DegreeToRadian(Irand(-5,5)))

				//
				local	_photo_tex = EngineLoadTexture(g_engine, photo_table[_photo_index].b)
				local	_photo_2 = UIAddSprite(ui, -1, _photo_tex, 0, 0, TextureGetWidth(_photo_tex), TextureGetHeight(_photo_tex))
				WindowSetParent(_photo_2, _photo)
				WindowSetCommandList(_photo_2, "loop;hide;nop 0.125;show;nop 0.125;next;")

				photo_counter++
			}

			base_y += g_screen_height * (is_even?0.08:0.1)

			if (n > 0) 
			{
				is_even = !is_even
				line_photo_counter++
			}

		}

		scroll_height = base_y
		print("GameEndUI::DrawCredits() scroll_height = " + scroll_height)

		{
			local	gradient_sprite = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/black_gradient_alpha.png"), 0, 0, 16, 256)
			WindowSetPivot(gradient_sprite, 16 * 0.5, 256 * 0.5)
			WindowSetPosition(gradient_sprite, g_screen_width * 0.5, g_screen_height - 128.0)
			WindowSetScale(gradient_sprite, 100.0, 1.0)
		}

		DrawQuitButton()
	}

	//------------------
	function	Update()
	//------------------
	{
		base.Update()
		WindowSetPosition(main_handler, 0, scroll_y)
		scroll_y -= (g_dt_frame * 60.0 * 0.8)
//		print("scroll_y = " + scroll_y)

		if (scroll_y < -(scroll_height * 0.975))
		{
			SceneGetScriptInstance(g_scene).GotoTitleScreen()
			if (g_audio_music_channel != -1)
				MixerChannelStop(g_mixer, g_audio_music_channel)
		}
	}

	//-----------------------------------------
	function	BackToTitleScreen(event, table)
	//-----------------------------------------
	{
		if (g_audio_music_channel != -1)
			MixerChannelStop(g_mixer, g_audio_music_channel)

		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		SceneGetScriptInstance(g_scene).GotoTitleScreen()
	}
}

//-------------
class	GameEnd
//-------------
{
	game_end_ui			=	0

	//---------------------	
	function	OnUpdate(scene)
	//---------------------
	{
		game_end_ui.Update()
	}

	//---------------------
	function	GotoTitleScreen()
	//---------------------
	{
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
	}

	//---------------------	
	function	OnSetup(scene)
	//---------------------
	{
		if (EngineGetToolMode(g_engine) != NoTool)
		{
			if (!("g_locale" in getroottable()) || !("game_subtitle" in g_locale))
				LoadLocaleTable()
		}

		print("LeaderboardScreen::OnSetup()")
		game_end_ui = GameEndUI(SceneGetUI(scene))
		game_end_ui.DrawCredits(PrepareCreditsTable())
	}

	//-------------------------------
	function	PrepareCreditsTable()
	//-------------------------------
	{
		local	lines_table = []

		lines_table.append(tr("Staff : ", "credits"))

		foreach(_line in g_credits)
		{
			//	Add Task Description (Coding, 2D, 3D, Music....)
			lines_table.append(_line.desc)

			//	Add Contributors names
			if ("name" in _line)
			{
				if ((typeof _line.name) == "string")
					lines_table.append(_line.name)
				else
				if ((typeof _line.name) == "array")
				{
					local	_names_table = clone(_line.name)
					_names_table.sort()
					local	_names_str = "", _name_index = 0
					foreach(n, _name in _names_table)
					{
						_names_str += _name
						if (_name_index == 3)
						{
							_names_str += "\n"
							_name_index = 0
						}
						else
							if (n < _names_table.len() - 1)
								_names_str += ", "

						_name_index++
					}
					if ("note" in _line)
						_names_str += ("\n" + _line.note)

					lines_table.append(_names_str)
				}
			}
		}

		return lines_table
	}
	
	//-----------------
	//	OS Interactions
	//-----------------

	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		game_end_ui.OnRenderContextChanged()
	}

	//-----------------------------------------
	function	OnHardwareButtonPressed(button)
	//-----------------------------------------
	{
		switch (button)
		{
			case	HardwareButtonBack:
				print("ScreenGame::OnHardwareButtonPressed(HardwareButtonBack)")
				GotoTitleScreen()
				break
		}
	}
}
