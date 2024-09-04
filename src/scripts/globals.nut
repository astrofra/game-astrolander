//	Globals.nut

g_device				<-	GetKeyboardDevice()

g_gravity				<-	Vector(0.0, -4.0, 0.0) //.Scale(0.25)
g_bonus_duration		<-	Sec(10.0)
g_reversed_controls		<-	false
g_time_key_order		<-	["hour", "minute", "second", "ms"]