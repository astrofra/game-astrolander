/*
	File: scripts/screen_seasons.nut
	Author: Astrofra
*/

Include("scripts/globals.nut")
Include("scripts/seasons_table.nut")
Include("scripts/ui.nut")

/*!
	@short	SeasonsScreen
	@author	Astrofra
*/
class	SeasonsScreenUI	extends	BaseUI
{
	scroll_handler		=	0
	background			=	0
	lock_scale			=	0.65

	back_button		=	0

	position			=	0
	vel					=	0
	old_dt				=	0
	max_x				=	0

	function	OnRenderContextChanged()
	{
//		level_name[1].rebuild()
//		level_name[1].refresh()
	}

	constructor(_ui)
	{
		base.constructor(_ui)

		UICommonSetup(ui)

		local	bg_tex = EngineLoadTexture(g_engine, "ui/seasons/chapter_background.png"), bgw, bgh
		bgw = TextureGetWidth(bg_tex)
		bgh = TextureGetHeight(bg_tex)
		background = UIAddSprite(ui, -1, bg_tex, 0, 0, bgw, bgh)
		SpriteSetPivot(background, bgw * 0.5, bgh * 0.5)
		SpriteSetPosition(background, g_screen_width * 0.5, g_screen_height * 0.5)
		SpriteSetScale(background, 2, 2)
		local bg0, bg1
		bg0 = UIAddSprite(ui, -1, bg_tex, 0, 0, bgw, bgh)
		bg1 = UIAddSprite(ui, -1, bg_tex, 0, 0, bgw, bgh)
		SpriteSetParent(bg0, background)
		SpriteSetParent(bg1, background)
		SpriteSetPosition(bg0, -bgw, 0)
		SpriteSetPosition(bg1, bgw, 0)

		local	tex_lock = EngineLoadTexture(g_engine, "ui/lock.png"), lw, lh
		lw = TextureGetWidth(tex_lock)
		lh = TextureGetHeight(tex_lock)

		local	tex_block_black = EngineLoadTexture(g_engine, "ui/title_navigation_generic_black.png"), bw, bh
		bw = TextureGetWidth(tex_block_black)
		bh = TextureGetHeight(tex_block_black)

		local	x = 0.0,	y = 0.0
		scroll_handler = UIAddWindow(ui, -1, 0,0,0,0)
		position = Vector2(0,0)

		local	idx = 0

		foreach(season in g_seasons)
		{
			//	Season Icon
			local	tex = EngineLoadTexture(g_engine, season.icon)
			local	w = TextureGetWidth(tex),  h = TextureGetHeight(tex)
			if (idx == 0)	x +=  h * 0.5
			y = g_screen_height * 0.5 - h * 0.5
			local	spr = UIAddSprite(ui, -1, tex, x, y, w, h)
			x += h * 1.25
			SpriteSetParent(spr, scroll_handler)

			//	Season Lock
			if ((idx > 0) && (GetSeasonCompletion(idx - 1) < 8))
			{
				local	lock = UIAddSprite(ui, -1, tex_lock, w * 0.5 - lw * 0.5 * lock_scale, h * 0.5 - lh * 0.5 * lock_scale, lw, lh)
				SpriteSetParent(lock, spr)
				SpriteSetScale(lock, lock_scale, lock_scale)
				WindowSetEventHandlerWithContext(spr, EventCursorUp, this, SeasonsScreenUI.SeasonLocked)
				WindowSetEventHandlerWithContext(lock, EventCursorUp, this, SeasonsScreenUI.SeasonLocked)
			}
			else
				WindowSetEventHandlerWithContext(spr, EventCursorUp, this, SeasonsScreenUI["GoToSeasonSelectionScreen" + idx.tostring()])

			//	Season Title
			local	season_name = LabelWrapper(ui, season.title, 0, -64, 60, 512, 128, g_ui_color_blue, g_main_font_name, TextAlignCenter)
			season_name[1].drop_shadow = true
			season_name[1].refresh()
			WindowSetParent(season_name[0], spr)

			//	Progress Block
			local	progres_block = UIAddSprite(ui, -1, tex_block_black, w * 0.5 - bw * 0.5, h * lock_scale * 1.05, bw, bh)
			SpriteSetParent(progres_block, spr)			
			
			//	Progress Text
			local	progres_text = LabelWrapper(ui, GetSeasonCompletion(idx).tostring() + "/8", 0, 0, 32, bw, bh, g_ui_color_white, g_main_font_name, TextAlignCenter)
			progres_text[1].refresh()
			WindowSetParent(progres_text[0], progres_block)

			idx++
		}

		max_x = g_screen_width
		vel = Vector2(0,0)

		//	Back button
		local	back_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_left.png"), 16, 700, 256, 128)
		back_button = LabelWrapper(ui, "Back", 10, 30, 50, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(back_button[0], back_arrow)
		WindowSetEventHandlerWithContext(back_arrow, EventCursorUp, this, SeasonsScreenUI.BackToTitleScreen)
		WindowSetEventHandlerWithContext(back_button[0], EventCursorUp, this, SeasonsScreenUI.BackToTitleScreen)

	}

	//-------------------------------------
	function	GetSeasonCompletion(season)
	//-------------------------------------
	{
		local	season_first_level = season * 8, n, completion = 0
		for(n = 0; n < 8; n++)
			if (!IsLevelLocked(season_first_level + n)) completion++
		return completion
	}

	//-------------------------------
	function	IsLevelLocked(_level)
	//-------------------------------
	{
		local	game = ProjectGetScriptInstance(g_project)
		local	_level_key = "level_" + (Max(0, _level - 1)).tostring()
		
		if ((_level > 0) && (!game.player_data.rawin(_level_key) || !game.player_data[_level_key].complete))
			return	true
		else
			return false
	}

	function	SeasonLocked(event, table)
	{
		if (cursor_swipe)
			return
		PlaySfxUIError()
		ButtonFeedback(table.window)
	}

	function	GoToSeasonSelectionScreen0(event, table)
	{
		if (cursor_swipe)
			return
		print("GoToSeasonSelectionScreen0()")
		PlaySfxUIValidate()
		ButtonFeedback(table.window)
		ProjectGetScriptInstance(g_project).player_data.current_selected_season = 0
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_season_levels.nms")
	}

	function	GoToSeasonSelectionScreen1(event, table)
	{
		if (cursor_swipe)
			return
		print("GoToSeasonSelectionScreen1()")
		PlaySfxUIValidate()
		ButtonFeedback(table.window)
		ProjectGetScriptInstance(g_project).player_data.current_selected_season = 1
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_season_levels.nms")
	}

	function	GoToSeasonSelectionScreen2(event, table)
	{
		if (cursor_swipe)
			return
		print("GoToSeasonSelectionScreen2()")
		PlaySfxUIValidate()
		ButtonFeedback(table.window)
		ProjectGetScriptInstance(g_project).player_data.current_selected_season = 2
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_season_levels.nms")
	}

	function	BackToTitleScreen(event, table)
	{
		if (cursor_swipe)
			return
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")		
	}

	function	ScrollSeasons(x,y)
	{

		vel = Vector2(x,y)

		position.x += x
		position.y += y
	}

	function	InertiaScrollSeasons()
	{
		position.x += vel.x
		position.y += vel.y
	}
	

	function	Update()
	{
		base.Update()
		WindowSetPosition(scroll_handler, position.x, position.y)
		WindowSetPosition(background, g_screen_width * 0.5 + position.x * 0.25, g_screen_height * 0.5 + position.y * 0.1)

		//	Motion inertia
		vel -= vel.Scale(g_dt_frame)

		//	Keep scroll area withing limits
		local	strength = (cursor_click?4:16)

		if (position.x > 0.0)
		{
			position.x = Max(0, position.x - g_dt_frame * strength * Abs(position.x))
			vel = vel.Scale(0.95)
		}

		if (position.x < -max_x)
		{
			position.x = (position.x + g_dt_frame * strength * Abs(position.x + max_x))
			vel = vel.Scale(0.95)
		}

		if (position.y > 0.0)
		{
			position.y = Max(0, position.y - g_dt_frame * strength * 2.0 * Abs(position.y))
			vel = vel.Scale(0.95)
		}
		else
		if (position.y < 0.0)
		{
			position.y = Min(0, position.y + g_dt_frame * strength * 2.0 * Abs(position.y))
			vel = vel.Scale(0.95)
		}
	}
}

class	SeasonsScreen
{
	season_ui				=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		season_ui.Update()

		if (season_ui.cursor_swipe)
			season_ui.ScrollSeasons(season_ui.cursor_dt_x, season_ui.cursor_dt_y)
		else
			season_ui.InertiaScrollSeasons()
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		print("SeasonsScreen::OnSetup()")
		local	ui
		ui = SceneGetUI(scene)
		season_ui = SeasonsScreenUI(ui)
	}
}
