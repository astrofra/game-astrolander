//	Globals.nut
print("//	Globals.nut		//")

	force_android_render_settings	<-	false
	g_sound_enabled					<-	false

	function	IsTouchPlatform()
	{
		if ((g_platform == "Android") || (g_platform == "iOS"))
			return true
		else
			return false
	}

	g_supported_languages	<-	["en", "fr", "es", "it", "jp"] // "de", "cn", 
	g_current_language		<-	"en"

	g_title_screen_index	<-	0

	g_screen_width			<-	1280.0
	g_screen_height			<-	960.0

	g_device				<-	GetKeyboardDevice()
	g_gravity				<-	Vector(0.0, -4.0, 0.0)

	g_player_max_speed		<-	Mtrs(25.0)

	g_clock_scale			<-	1.0
	g_clock_scale_easy		<-	0.8
	g_clock_scale_hard		<-	1.35
	g_bonus_duration		<-	Sec(10.0)
	g_reversed_controls		<-	true
	g_time_key_order		<-	["hour", "minute", "second", "ms"]

	g_default_font_name		<-	"banksb20caps"
	g_main_font_name		<-	"banksb20caps" //"banksb20"//g_main_font_name 
	g_default_hud_font_name	<-	"aerial"
	g_hud_font_name			<-	"aerial"
	g_hud_font_size			<-	1.0

	g_ui_color_blue			<-	Vector(117, 155, 168, 180)
	g_ui_color_yellow		<-	Vector(248, 236, 188, 255)
	g_ui_color_white		<-	Vector(255, 255, 255, 255)
	g_ui_color_grey			<-	Vector(128, 128, 128, 255)
	g_ui_color_black		<-	Vector(0, 0, 0, 255)
	g_ui_color_red			<-	Vector(255, 10, 0, 255)
	g_ui_color_green		<-	Vector(0, 180, 5, 255)

	g_ambient_color_warm	<-	Vector(150, 105, 85, 255)
	g_ambient_color_dawn	<-	Vector(190,100,110, 255) //Vector(235, 135, 45, 255)
	g_ambient_color_cold	<-	Vector(85, 130, 150, 255)

	g_leaderboard_max_entry	<-	10

	g_base_url				<-	"http://www.astlan-game.com" //astlan.astrofra.com

	g_player_name			<-	null

	g_audio_handler			<-	0

	g_audio_music_channel	<-	0
