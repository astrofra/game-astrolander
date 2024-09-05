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
class	CreditsUI	extends	BaseUI
//--------------------------------
{
	background			=	0

	skip_arrow			=	0
	skip_button			=	0

	credit_table		=	0

	scroll_y			=	0

	main_handler		=	0
	
	function	OnRenderContextChanged()
	{
		print("CreditsUI::OnRenderContextChanged()")

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
	function	DrawBackButton()
	//--------------------------
	{
		//	Back button
		skip_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		skip_button = LabelWrapper(ui, tr("Back", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(skip_button[0], skip_arrow)
		WindowSetEventHandlerWithContext(skip_arrow, EventCursorDown, this, CreditsUI.BackToTitleScreen)
		WindowSetEventHandlerWithContext(skip_button[0], EventCursorDown, this, CreditsUI.BackToTitleScreen)
		WindowSetCommandList(skip_arrow, "toalpha 0,0;nop 0.5;toalpha 0.25,1;")
	}

	//-----------------------------
	function	DrawCredits(_table)
	//-----------------------------
	{
		local	is_even = true
		local	base_y = 128
		credit_table = []

		foreach(n, _str in _table)
		{
			print("CreditsUI::DrawCredits() : _line = " + _str)

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

			base_y += g_screen_height * (is_even?0.08:0.1)
			is_even = !is_even
		}

		DrawBackButton()
	}

	//------------------
	function	Update()
	//------------------
	{
		base.Update()
		WindowSetPosition(main_handler, 0, scroll_y)
		scroll_y -= (g_dt_frame * 60.0)

		if (scroll_y < -(g_screen_height * 0.8))
			SceneGetScriptInstance(g_scene).GotoTitleScreen()
	}

	//-----------------------------------------
	function	BackToTitleScreen(event, table)
	//-----------------------------------------
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		SceneGetScriptInstance(g_scene).GotoTitleScreen()
	}
}

//-------------------
class	CreditsScreen
//-------------------
{
	credits_ui			=	0

	//---------------------	
	function	OnUpdate(scene)
	//---------------------
	{
		credits_ui.Update()
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
		print("LeaderboardScreen::OnSetup()")
		credits_ui = CreditsUI(SceneGetUI(scene))
		credits_ui.DrawCredits(PrepareCreditsTable())
	}

	//-------------------------------
	function	PrepareCreditsTable()
	//-------------------------------
	{
		local	lines_table = []

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
		credits_ui.OnRenderContextChanged()
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
