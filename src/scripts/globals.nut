//	Globals.nut
print("//	Globals.nut		//")

	g_device				<-	GetKeyboardDevice()
	g_is_touch_platform		<-	(g_platform == "Android"?true:false)

	g_gravity				<-	Vector(0.0, -4.0, 0.0)
	g_clock_scale			<-	1.0
	g_clock_scale_easy		<-	0.8
	g_clock_scale_hard		<-	1.35
	g_bonus_duration		<-	Sec(10.0)
	g_reversed_controls		<-	false
	g_time_key_order		<-	["hour", "minute", "second", "ms"]

	g_main_font_name		<-	"banksb20caps" //"banksb20"//g_main_font_name

	g_ui_color_blue			<-	Vector(117, 155, 168, 180)
	g_ui_color_yellow		<-	Vector(248, 236, 188, 255)

	