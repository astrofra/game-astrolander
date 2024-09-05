/*
	File: scripts/screen_leaderboard.nut
	Author: Astrofra
*/

/*!
	@short	LeaderboardScreen
	@author	Astrofra
*/

//------------------------------------
class	LeaderboardUI	extends	BaseUI
//------------------------------------
{
	background			=	0
	background_shadow	=	0
	slideshow			=	0

	skip_arrow			=	0
	skip_button			=	0

	title				=	0

	score_table			=	0
	
	latest_data			=	0
	
	function	OnRenderContextChanged()
	{
		print("LeaderboardUI::OnRenderContextChanged()")
		title.rebuild()
		title.refresh()

		skip_button[1].rebuild()
		skip_button[1].refresh()
		
		foreach(_score_entry in score_table)
		{
				_score_entry.rebuild()
				_score_entry.refresh()
		}
	}

	constructor(_ui)
	{
		base.constructor(_ui)

		CreateOpaqueScreen(ui, Vector(218, 197, 150, 255))

		UICommonSetup(ui)

		//	Slideshow
		CreateBackgroundSlideshow()

		//	Shadow
		local	_tex_back_shadow = EngineLoadTexture(g_engine, "ui/leaderboard_back_shadow.png")
		background_shadow = UIAddSprite(ui, -1, _tex_back_shadow, 0, 0, TextureGetWidth(_tex_back_shadow), TextureGetHeight(_tex_back_shadow))
		WindowSetPivot(background_shadow, TextureGetWidth(_tex_back_shadow) * 0.5, TextureGetHeight(_tex_back_shadow) * 0.5)
		WindowSetPosition(background_shadow, g_screen_width * 0.5, g_screen_height * 0.5)
		WindowSetScale(background_shadow, 2.5, 2.5)

		//	Back
		local	_tex_background = EngineLoadTexture(g_engine, "ui/leaderboard_back.png")
		background = UIAddSprite(ui, -1, _tex_background, 0, 0, TextureGetWidth(_tex_background), TextureGetHeight(_tex_background))
		WindowSetOpacity(background, 0.55)
		WindowSetPivot(background, TextureGetWidth(_tex_background) * 0.5, TextureGetHeight(_tex_background) * 0.5)
		WindowSetPosition(background, g_screen_width * 0.5, g_screen_height * 0.5)
		local	_sc = g_screen_width / TextureGetWidth(_tex_background) * 0.995
		WindowSetScale(background, _sc, _sc)


		//	Decoration wings
		local	_tex_wing = EngineLoadTexture(g_engine, "ui/leader_wing_shadow_left.png")
		local	_wing = UIAddSprite(ui, -1, _tex_wing, 0, 0, TextureGetWidth(_tex_wing), TextureGetHeight(_tex_wing))
		WindowSetPivot(_wing, TextureGetWidth(_tex_wing) * 0.5, TextureGetHeight(_tex_wing) * 0.5)
		WindowSetPosition(_wing, g_screen_width * 0.5 - 410, 140)
		WindowSetOpacity(_wing, 0.5)
		WindowSetScale(_wing, 1.25, 1.25)
		WindowSetCommandList(_wing, "loop;toangle 1,-3;toangle 1,3;next;")

		local	_tex_wing = EngineLoadTexture(g_engine, "ui/leader_wing_left.png")
		local	_wing = UIAddSprite(ui, -1, _tex_wing, 0, 0, TextureGetWidth(_tex_wing), TextureGetHeight(_tex_wing))
		WindowSetPivot(_wing, TextureGetWidth(_tex_wing) * 0.5, TextureGetHeight(_tex_wing) * 0.5)
		WindowSetPosition(_wing, g_screen_width * 0.5 - 410, 128)
		WindowSetScale(_wing, 1.25, 1.25)
		WindowSetCommandList(_wing, "loop;toangle 1,-3;toangle 1,3;next;")	

		local	_tex_wing = EngineLoadTexture(g_engine, "ui/leader_wing_shadow.png")
		local	_wing = UIAddSprite(ui, -1, _tex_wing, 0, 0, TextureGetWidth(_tex_wing), TextureGetHeight(_tex_wing))
		WindowSetPivot(_wing, TextureGetWidth(_tex_wing) * 0.5, TextureGetHeight(_tex_wing) * 0.5)
		WindowSetPosition(_wing, g_screen_width * 0.5 + 410, 140)
		WindowSetOpacity(_wing, 0.5)
		WindowSetScale(_wing, 1.25, 1.25)
		WindowSetCommandList(_wing, "loop;toangle 1,3;toangle 1,-3;next;")

		local	_tex_wing = EngineLoadTexture(g_engine, "ui/leader_wing.png")
		local	_wing = UIAddSprite(ui, -1, _tex_wing, 0, 0, TextureGetWidth(_tex_wing), TextureGetHeight(_tex_wing))
		WindowSetPivot(_wing, TextureGetWidth(_tex_wing) * 0.5, TextureGetHeight(_tex_wing) * 0.5)
		WindowSetPosition(_wing, g_screen_width * 0.5 + 410, 128)
		WindowSetScale(_wing, 1.25, 1.25)
		WindowSetCommandList(_wing, "loop;toangle 1,3;toangle 1,-3;next;")	

		//	Leaderboard title
		title = Label(ui, 1024, 128,  g_screen_width * 0.5, 128, true, true)
		title.label = tr("Astro Leaders", "leaderboard")
		title.font = g_main_font_name
		title.font_size = 90
		title.drop_shadow = true
		title.refresh()

		local	_tex_back_stripe = EngineLoadTexture(g_engine, "ui/leaderboard_back_stripe.png")

		score_table = []
		local	n, _is_even 

		_is_even = true
		for(n = 0; n < g_leaderboard_max_entry; n++)
		{
			if (!_is_even)
			{
				local	_stripe
				_stripe = UIAddSprite(ui, -1, _tex_back_stripe, 0, 0, TextureGetWidth(_tex_back_stripe), TextureGetHeight(_tex_back_stripe))
				WindowSetParent(_stripe, background)
				WindowSetPosition(_stripe, 0, 36 + (0.82 * n * TextureGetHeight(_tex_back_stripe)))
				WindowSetScale(_stripe, 1.0, 0.8)
				WindowSetOpacity(_stripe, 1.0)
			}

			_is_even = (_is_even?false:true)
		}

		_is_even = true
		for(n = 0; n < g_leaderboard_max_entry; n++)
		{	
			local	_score
			_score = Label(ui, 1024, 128,  g_screen_width * 0.5, 128 + 90 + g_screen_height * 0.07 * n, true, true)
			_score.label = (n == 4?"Loading":" ... ") //(n + 1).tostring() + " - " + "Astrofra" + " - " + ((20 - n) * 1000).tostring() 
			_score.font = g_main_font_name
			_score.font_size = 60

			if (_is_even)
			{
				_score.drop_shadow = false
				_score.label_color = RGBAToHex(g_ui_color_black)
			}
			else
			{
				_score.drop_shadow = true
				_score.label_color = RGBAToHex(g_ui_color_yellow)
			}

			_score.refresh()

			score_table.append(_score)

			local _tex_device = EngineLoadTexture(g_engine, "ui/devices/windows.png")
			local _device = UIAddSprite(ui, -1, _tex_device, 0, 0, TextureGetWidth(_tex_device), TextureGetHeight(_tex_device))
			WindowSetPosition(_device, g_screen_width * 0.9, 128 + 90 + g_screen_height * 0.07 * n - TextureGetHeight(_tex_device) * 0.5)

			_is_even = (_is_even?false:true)
		}

		//	Back button
		skip_arrow = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "ui/title_navigation_red_right.png"), g_screen_width - 16 - 256, 700, 256, 128)
		skip_button = LabelWrapper(ui, tr("Back", "screen nav."), -10, 25, 70, 256, 80, Vector(255, 255, 255, 255), g_main_font_name, TextAlignCenter)
		WindowSetParent(skip_button[0], skip_arrow)
		WindowSetEventHandlerWithContext(skip_arrow, EventCursorDown, this, LeaderboardUI.BackToTitleScreen)
		WindowSetEventHandlerWithContext(skip_button[0], EventCursorDown, this, LeaderboardUI.BackToTitleScreen)
		WindowSetCommandList(skip_arrow, "toalpha 0,0;nop 0.5;toalpha 0.25,1;")


	}
	
	function	GetDeviceIconPath(device)
	{
		switch (device)
		{
			case	"Windows":
				return "ui/devices/windows.png"
			case	"Linux":
				return "ui/devices/linux.png"
			case	"OSX":
				return "ui/devices/osx.png"
			case	"Android":
				return "ui/devices/android.png"
			case	"iOS":
				return "ui/devices/ios.png"
		}
		return null
	}

	function	RefreshLeaderboard(_leaders_array)
	{
		foreach(_score_entry in score_table)
		{
				_score_entry.label = "..."
				_score_entry.refresh()
		}

		foreach(i, _entry in _leaders_array)
		{
			if (i < score_table.len())
			{
				score_table[i].label = CreateLeaderboardEntryString(i + 1, _entry.name, _entry.score)
				score_table[i].refresh()
			}
		}
	}

	function	CreateLeaderboardEntryString(_rank, _name, _score)
	{
		return (_rank.tostring() + " - " + _name + " - " + _score.tointeger().tostring())
	}

	function	CreateBackgroundSlideshow()
	{
		slideshow = SlideShow(ui)
		slideshow.setup(["ui/leaderboard_0.jpg", "ui/leaderboard_1.jpg", "ui/leaderboard_2.jpg", "ui/leaderboard_3.jpg", "ui/leaderboard_4.jpg"])
	}

	function	Update()
	{
		base.Update()
		slideshow.update(g_dt_frame)
	}

	function	BackToTitleScreen(event, table)
	{
		PlaySfxUINextPage()
		ButtonFeedback(table.window)
		SceneGetScriptInstance(g_scene).GotoTitleScreen()
	}
}

//---------------------
class	LeaderboardScreen
//---------------------
{
	display_timer		=	0
	sfx_channel			=	-1
	sfx_gain			=	0.0
	leaderboard_ui		=	0

	pending_request		=	-1
	available_request	=	"none"
	leaderboard_content	=	0

	channel_music		=	0

	//---------------------	
	function	OnUpdate(scene)
	//---------------------
	{
		//ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
		leaderboard_ui.Update()
		HttpUpdate()
		FadeInMusicVolume()
	}

	//---------------------
	function	GotoTitleScreen()
	//---------------------
	{
			MixerChannelStop(g_mixer, channel_music)
			ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_title.nms")
	}

	//---------------------
	function	HttpRequestComplete(uid, data)
	//---------------------
	{
		print("LeaderboardScreen::onHttpRequestComplete() uid = " + uid)
		if	(pending_request != uid)		// ignore
			return

		print("Leaderboard request data received.")
		available_request = "data"
		print("leaderboard_content = " + data)
		RefreshLeaderboard(data)

		pending_request = -1
	}

	//---------------------
	function	RefreshLeaderboard(data)
	//---------------------
	{
		if (!(typeof data == "string"))
			data = ""

		local	_leader_array = split(data, "|")

		local	_parm_order = 0, _guid, _name, _device, _score
		foreach(_key in _leader_array)
		{
			switch (_parm_order)
			{
				case 0:
					_guid = _key
					print("_guid = " + _key)
					break

				case 1:
					_name = _key
					print("_name = " + _key)
					break
					
				case 2:
					_device = _key
					print("_device = " + _key)
					break

				case 3:
					_score = _key
					print("_score = " + _key)
					leaderboard_content.append({name = _name, device = _device, score = _score})
					break
			}

			_parm_order++
			if (_parm_order > 2)
				_parm_order = 0
		}

		print("RefreshLeaderboard() : found " + (leaderboard_content.len().tostring()) + " entries.")
		leaderboard_ui.RefreshLeaderboard(leaderboard_content)
		
	}
	
	//---------------------
	function	HttpRequestError(uid)
	//---------------------
	{
		print("LeaderboardScreen::onHttpRequestError() uid = " + uid)
		if	(pending_request != uid)		// ignore
			return

		available_request = "error"
		pending_request = -1
	}

	//---------------------	
	function	OnSetup(scene)
	//---------------------
	{
		print("LeaderboardScreen::OnSetup()")
		leaderboard_ui = LeaderboardUI(SceneGetUI(scene))
		pending_request = RequestLeaderboard()
	}

	//---------------------
	function	OnSetupDone(scene)
	//---------------------
	{
		if (!g_sound_enabled) return
		channel_music = MixerStreamStart(g_mixer, "audio/music/leaderboard.ogg")
		MixerChannelSetGain(g_mixer, channel_music, sfx_gain * GlobalGetMusicVolume())
		MixerChannelSetLoopMode(g_mixer, channel_music, LoopRepeat)
	}

	//---------------------
	function	FadeInMusicVolume()
	//---------------------
	{
		MixerChannelSetGain(g_mixer, channel_music, sfx_gain * GlobalGetMusicVolume())
		sfx_gain += (g_dt_frame * 0.85)
		sfx_gain = Clamp(sfx_gain,0.0,1.0)
	}

	//---------------------
	function	RequestLeaderboard()
	//---------------------
	{
		print("LeaderboardScreen::RequestLeaderboard()")
		local	post = "command=get"
		return HttpPost(g_base_url + "/leaderboard.php", post)
	}

	constructor()
	{
		leaderboard_content = []
	}
	
	//-----------------
	//	OS Interactions
	//-----------------

	//----------------------------------
	function	OnRenderContextChanged()
	//----------------------------------
	{
		leaderboard_ui.OnRenderContextChanged()
		leaderboard_ui.RefreshLeaderboard(leaderboard_content)
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
