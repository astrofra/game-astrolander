//	Locale (Chinese)
//	locale_cn.nut

g_locale_cn	<-	{
	main_font_name		=	"wt014-simple-nocurve"
	hud_font_name		=	"wt014-simple-nocurve"
	hud_font_size		=	1.25
	
	//	System
	loading				=	"加载中",
	language 			=	"中文",

	//	Title
	game_title			=	"ASTLAN",
	game_subtitle		=	"Astro Lander",	
	level_easy			=	"简单",
	level_normal		=	"普通",
	level_hard			=	"困难",
	start_game			=	"游戏开始"
	play_level			=	"开始",
	next_level			=	"下一个",
	skip_screen			=	"Skip",
	option				=	"选项"
	back_to_title		=	"返回",
	copyright			=	"(c) 2011-2012 Astrofra."
	control_reverse		=	"Reverse Ctrl"
	yes					=	"是"
	no					=	"否"
	leaderboard			=	"主要负责人"
	music_volume		=	"音乐音量"
	sound_fx_volume		=	"音效音量"
	player_nickname		=	"玩家姓名"
	credits_button 		=	"主创人员"

	//	Leaderboard
	leaderboard_title	=	"Astro Leaders"
	guest_nickname		=	"游客"
	
	//	Credits
	credits 		=	[
			{	desc	=	"游戏编码 & 3D 效果" ,	name	=	"Astrofra"	}
			{	desc	=	"2D 效果" ,	name	=	"Pehesse"	}
			{	desc	=	"游戏引擎, 附加编码",	name	=	"Emmanuel Julien"	}
			{	desc	=	"音乐" ,	name	=	["Alex Khaskin", "William Lamy", "Brandon Morris", "Kareem Kenawy", "Alexandr Zhelanov", "Ilya Kaplan"], 
										note	=	"Provided by AudioBank.Fm and OpenGameArt.org"		}
			{	desc	=	"特别感谢",	name	=	["Yann van der Cruyssen", "Cedric Vaniez", "David Ghodsi", "Thomas Simonnet", "Lucas Boulestin", "Marc Planard", "Li Jing"]	}
			{	desc	=	"测试人员",	name = ["Florian Belmonte", "Clement Vincent", "Thomas Lechaptois"]	}
			{	desc	=	"Powered by GameStart!"	}
	]

	//	Game End
	end_game_line_0		=	"工作人员 : ",

	//	EndLevel / Debrief
	endlevel_level_name	=	"等级",
	endlevel_score		=	"得分",
	endlevel_fuel		=	"燃料",
	endlevel_life		=	"生命值",
	endlevel_perfect	=	"完美 !!!",
	endlevel_new_record	=	"新纪录 !!!",
	endlevel_life_record	=	"生命纪录 !!!",
	endlevel_fuel_record	=	"燃料纪录 !!!",
	endlevel_time_record	=	"时间记录 !!!",
	endlevel_remain_life	=	"剩余生命值",
	endlevel_remain_fuel	=	"剩余燃料",
	endlevel_time			=	"时间",
	total_score				=	"总得分",
	score_points			=	"得分",
	story_0					=	"往下沉, 到墙的后面,\n你找到了一只手...",
	story_1					=	"逃离致命的激光,\n你找到了另一只手!",
	story_2					=	"藏在这些石头堆里,\n你只找到了一条腿.",
	story_3					=	"两条腿和两条手臂?\n没有一个符合你的身体构造.",
	story_4					=	"一个身体, 一个大脑,\n现在你需要一个头.",
	story_5					=	"找到了完整的身体,\n你的旅行结束了.",

	//	InGame / Hud
	hud_help			=	"||",
	hud_skip			=	">>",
	hud_damage			=	"生命值"
	hud_fuel			=	"燃料"
	hud_artifacts		=	"收集物"
	hud_stopwatch		=	"计时"

	pause_resume_game	=	"继续",
	pause_restart_level	=	"重新开始",
	pause_quit_game		=	"离开",

	get_ready			=	"准备出发!"
	game_over			=	"游戏结束"
	no_fuel				=	"燃料耗尽!"
	dead_by_damage		=	"脑死亡!"
	dead_by_poison		=	"中毒死亡!"
	no_time_left		=	"没有时间了!"
	return_base			=	"回到基地!\n~~Size(40)你找到了所有搜集物."
	mission_complete	=	"任务完成!"
	player_time			=	"~~Size(40)所花时间 : "
	level_names			=	{
								level_0		=	"首次航行",
								level_1		=	"再次跳跃",
								level_2		=	"三个世界"
								level_3		= 	"齿轮的世界",
								level_4		= 	"花园之下",
								level_5		=	"斜线",
								level_6		=	"毒泥通道",
								level_7		=	"遭遇激光",
								level_8		=	"穿越狭道",
								level_9		=	"上上下下",
								level_10	=	"废弃工厂",
								level_11	=	"四死"
								level_12	=	"旋转"
								level_13	=	"核心",
								level_14	=	"失落的船",
								level_15	=	"溪谷漂流",
								level_16	=	"升降行为",
								level_17	=	"卢卡斯",
								level_18	=	"失落的遗迹",
								level_19	=	"沉船",
								level_20	=	"方形迷宫",
								level_21	=	"矩形迷宫",
								level_22	=	"激光洞穴",
								level_23	=	"激光烟囱",
								default_name	=	"关卡名"
							}
}