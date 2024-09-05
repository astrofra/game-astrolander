/*
	File: scripts/screen_loader.nut
	Author: Astrofra
*/

Include("scripts/globals.nut")
Include("scripts/seasons_table.nut")
Include("scripts/ui.nut")

class	SeasonLevelsScreenUI	extends BaseUI
{

	back_button				=	0
	current_selected_level	=	0
	thumbnail				=	0
	current_world			=	0

	level_buttons			=	0
	selector_hilite			=	0
	best_score				=	0
	best_time				=	0

	constructor(_ui)
	{
		base.constructor(_ui)

		UICommonSetup(ui)

		if ("player_data" in ProjectGetScriptInstance(g_project))
			current_world = ProjectGetScriptInstance(g_project).player_data.current_selected_season
		else
			current_world = 0

		local	season = g_seasons["season_" + current_world]

		local	blue_background_texture = EngineLoadTexture(g_engine, "ui/main_menu_back.png")
		local	blue_background = UIAddSprite(ui, -1, blue_background_texture, 0, 0, TextureGetWidth(blue_background_texture), TextureGetHeight(blue_background_texture))
		WindowSetScale(blue_background, 1.5, 1.5)
		WindowSetPosition(blue_background, g_screen_width / 2.0 - (TextureGetWidth(blue_background_texture) / 2.0 * 1.5), g_screen_height / 2.0 - (TextureGetHeight(blue_background_texture) / 2.0 * 1.5))
		WindowSetZOrder(blue_background, 1.0)

		//	Season Name
		local	season_name = LabelWrapper(ui, season.title, 80, 128, 70, 700, 80, Vector(117, 155, 168, 255), g_main_font_name, TextAlignLeft)
		season_name[1].drop_shadow = true
		season_name[1].refresh()

		//	Level Grid
		CreateLevelButtonGrid()

		//	Level selector
		selector_hilite = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/level_selector_hilite.png"), 0, 0, 256, 256)
		WindowSetZOrder(selector_hilite, 0.7)
		HiliteLevelSelection()

		//	Level Thumbnail
		thumbnail = {	picture = 0, text = 0	}
		local	th_parent
		th_parent = UIAddWindow(ui, -1, g_screen_width - 256.0 + 64.0 + 8.0, 360 / 2.0 * 1.45 + 64.0, 0, 0)
		WindowSetScale(th_parent, 0.8, 0.8)

		local	level_thumbnail_bg = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/level_thumbnail_background.png"), 0, 0, 256, 360)
		WindowSetOpacity(level_thumbnail_bg, 0.25)
		WindowSetPivot(level_thumbnail_bg, 256 / 2.0, 360 / 2.0)
		WindowSetScale(level_thumbnail_bg, 1.45, 1.45)
		WindowSetParent(level_thumbnail_bg, th_parent)

		local	level_thumbnail = LevelSelectorLoadLevelThumbnail(current_selected_level, 0, 64)
		WindowSetParent(level_thumbnail, th_parent)
		thumbnail.picture = level_thumbnail

		//	Level Name
		local	level_name = LabelWrapper(ui, GetLevelName(current_selected_level), -700 * 0.5, (-360 - 55) * 0.5, 55, 700, 80, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
		level_name[1].drop_shadow = true
		level_name[1].refresh()
		WindowSetParent(level_name[0], th_parent)
		thumbnail.text = level_name[1]

		//	Best score/time/stars
		local	play_level_block = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_generic_black_square.png"), -256 / 2.0, (360 + 90) * 0.5 + 40, 240, 200)
		WindowSetParent(play_level_block, th_parent)

		local	level_score = GlobalLevelGetScore(current_selected_level).tostring()
		best_score = LabelWrapper(ui, level_score, 0, 0, 50, 240, 100, g_ui_color_white, g_main_font_name, TextAlignCenter)
		best_score[1].refresh()
		WindowSetParent(best_score[0], play_level_block)

		local	level_time = TimeToString(GlobalLevelGetStopwatch(current_selected_level))
		best_time = LabelWrapper(ui, level_time, 0, 50, 42, 240, 100, g_ui_color_white, g_main_font_name, TextAlignCenter)
		best_time[1].refresh()
		WindowSetParent(best_time[0], play_level_block)


		//	Start level button
		local	play_level_block = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_validate_green.png"), g_screen_width - 256.0 - 64.0, 700, 256, 128)
		local	play_level_button = LabelWrapper(ui, "Start", 5, 25, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(play_level_button[0], play_level_block)
		WindowSetEventHandlerWithContext(play_level_block, EventCursorDown, this, SeasonLevelsScreenUI.OnLevelsUIStartGame)
		WindowSetEventHandlerWithContext(play_level_button[0], EventCursorDown, this, SeasonLevelsScreenUI.OnLevelsUIStartGame)

		//	Back button
		local	back_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_left.png"), 16, 700, 256, 128)
		back_button = LabelWrapper(ui, "Back", 10, 25, 65, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_button[0], back_arrow)
		WindowSetEventHandlerWithContext(back_arrow, EventCursorDown, this, SeasonLevelsScreenUI.BackToSeasonsScreen)
		WindowSetEventHandlerWithContext(back_button[0], EventCursorDown, this, SeasonLevelsScreenUI.BackToSeasonsScreen)
	}

	//--------------------------------
	function	HiliteLevelSelection()
	//--------------------------------
	{
		SpriteSetParent(selector_hilite, level_buttons[current_selected_level])
	}

	//---------------------------------
	function	CreateLevelButtonGrid()
	//---------------------------------
	{
		local	_xoffset = 64.0, _yoffset = 220.0
		local	grid_parent
		grid_parent = UIAddWindow(ui, -1, _xoffset, _yoffset, 0, 0)
		WindowSetScale(grid_parent, 0.7, 0.7)

		level_buttons = []

		local	_x, _y
		local	_button_bg = EngineLoadTexture(g_engine, "ui/level_selector_background.png")

		for (_y = 0; _y < 2; _y++)
			for(_x = 0; _x < 4; _x++)
			{
				local	_level_number = _x + _y * 4
				local	_level_button = UIAddSprite(ui, -1, _button_bg,  _x * 256 * 1.25, _y * 256 * 1.35, 256, 256)
				local	_level_number_button = LabelWrapper(ui, (_level_number + (current_world * 8) + 1).tostring(), 0, 0, 90, 256, 256, Vector(117, 155, 168, 255), g_main_font_name, TextAlignCenter)
				WindowSetParent(_level_number_button[0], _level_button)
				WindowSetParent(_level_button, grid_parent)
				WindowSetEventHandlerWithContext(_level_number_button[0], EventCursorDown, this, SeasonLevelsScreenUI["OnSelectLevel" + _level_number])
				level_buttons.append(_level_button)
			}
	}

	function	OnSelectLevel0(event,table)
	{	OnSelectLevel(0)	}
	function	OnSelectLevel1(event,table)
	{	OnSelectLevel(1)	}
	function	OnSelectLevel2(event,table)
	{	OnSelectLevel(2)	}
	function	OnSelectLevel3(event,table)
	{	OnSelectLevel(3)	}
	function	OnSelectLevel4(event,table)
	{	OnSelectLevel(4)	}
	function	OnSelectLevel5(event,table)
	{	OnSelectLevel(5)	}
	function	OnSelectLevel6(event,table)
	{	OnSelectLevel(6)	}
	function	OnSelectLevel7(event,table)
	{	OnSelectLevel(7)	}

	//-------------------------------
	function	OnSelectLevel(_level)
	//-------------------------------
	{
		current_selected_level = _level + (current_world * 8)

		//	Update Level Name
		thumbnail.text.label = GetLevelName(current_selected_level)
		thumbnail.text.refresh()
		ProjectGetScriptInstance(g_project).player_data.current_level = current_selected_level

		//	Update Level Datas
		best_score[1].label = GlobalLevelGetScore(current_selected_level).tostring()
		best_score[1].refresh()
		best_time[1].label = TimeToString(GlobalLevelGetStopwatch(current_selected_level))
		best_time[1].refresh()

		//	Thumbnail
		local	th_parent = SpriteGetParent(thumbnail.picture)
		local	pos = SpriteGetPosition(thumbnail.picture)
		UIDeleteSprite(ui, thumbnail.picture)
		local	level_thumbnail = LevelSelectorLoadLevelThumbnail(current_selected_level, pos.x, pos.y)
		WindowSetParent(level_thumbnail, th_parent)
		thumbnail.picture = level_thumbnail

		//	Selection hilite
		HiliteLevelSelection()
	}

	//-------------------------------------------
	function	OnLevelsUIStartGame(event, table)
	//-------------------------------------------
	{
		ButtonFeedback(table.window)

		if (true) //(!IsLevelLocked(current_selected_level))
		{
			ProjectGetScriptInstance(g_project).player_data.current_level = current_selected_level
			SceneGetScriptInstance(g_scene).StartGame()
			PlaySfxUIValidate()
		}
		else
			PlaySfxUIError()
	}

	//----------------------------
	function	GetLevelName(_idx)
	//----------------------------
	{
		return	GlobalLevelTableNameFromIndex(_idx).title
	}

	//-------------------------------------------------------
	function	LevelSelectorLoadLevelThumbnail(_idx, _x, _y)
	//-------------------------------------------------------
	{
		local	_id = CreateNewUIID()

		local	_minimap = LoadMinimapTextureFromLevelIndex(_idx)

		local	_w, _h, _window

		if (_minimap == 0)
		{
			_w = 128
			_h = 128
			_window = UIAddWindow(ui, _id, 0.0, 0.0, _w, _h)
		}
		else
		{
			_w = TextureGetWidth(_minimap)
			_h = TextureGetHeight(_minimap)
			_window = UIAddSprite(ui, _id, _minimap, 0.0, 0.0, _w, _h)
		}

		WindowSetPivot(_window, (_w * 0.5), (_h * 0.5))
		WindowSetScale(_window, 0.75, 0.75)
		WindowSetPosition(_window , _x, _y)

		SpriteSetTexture

		return _window
	}

	//------------------------------------------------
	function	LoadMinimapTextureFromLevelIndex(_idx)
	//------------------------------------------------
	{
		local	_fname = "ui/minimaps/level_" + _idx.tostring()

		if (FileExists(_fname + ".png"))
			return EngineLoadTexture(g_engine, _fname + ".png")
		else
		if (FileExists(_fname + ".tga"))
			return EngineLoadTexture(g_engine, _fname + ".tga")
		else
			return 0
	}

	function	BackToSeasonsScreen(event, table)
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_seasons.nms")		
	}

	function	Update()
	{
		base.Update()
	}

}

/*!
	@short	SeasonLevelsScreen
	@author	Astrofra
*/
class	SeasonLevelsScreen
{

	levels_ui			=	0
	/*!
		@short	OnUpdate
		Called each frame.
	*/

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		print("SeasonLevelsScreen::OnSetup()")
		local	ui = SceneGetUI(scene)

		CreateOpaqueScreen(ui)

		levels_ui = SeasonLevelsScreenUI(SceneGetUI(scene))
	}

	function	OnUpdate(scene)
	{
		levels_ui.Update()
	}

	//---------------------
	function	StartGame()
	//---------------------
	{
		print("Title::StartGame()")
//		MixerChannelStop(g_mixer, channel_music)
		ProjectGetScriptInstance(g_project).ProjectStartGame()
	}
}
