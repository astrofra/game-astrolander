//	Locale (German)
//	locale_de.nut

g_locale_de	<-	{
	main_font_name		=	"yanone_kaffeesatz"

	//	System
	loading				=	"Loading",
	language 			=	"Deutsch",

	//	Title
	game_title			=	"ASTLAN",
	game_subtitle		=	"Astro Lander",	
	level_easy			=	"Easy",
	level_normal		=	"Normal",
	level_hard			=	"Hardcore",
	start_game			=	"Spielen"
	play_level			=	"Starten",
	next_level			=	"Nächste",
	skip_screen			=	"Skip",
	option				=	"Optionen"
	back_to_title		=	"Zurück",
	copyright			=	"(c) 2011-2012 Astrofra."
	control_reverse		=	"Bedienelemente umkehren"
	yes					=	"Ja"
	no					=	"Nein"
	leaderboard			=	"Leaders"
	music_volume		=	"Music Volume"
	sound_fx_volume		=	"Sfx Volume"
	player_nickname		=	"Spieler-Nickname"
	credits_button 		=	"Credits"

	//	Leaderboard
	leaderboard_title	=	"Astro Leaders"
	guest_nickname		=	"Guest"
	
	//	Credits
	credits 		=	[
			{	desc	=	"Programmierung & 3D-Grafik" ,	name	=	"Astrofra"	}
			{	desc	=	"2D-Grafik" ,	name	=	"Pehesse"	}
			{	desc	=	"Game Engine, Zusatzcode",	name	=	"Emmanuel Julien"	}
			{	desc	=	"Musik" ,	name	=	["Alex Khaskin", "William Lamy", "Brandon Morris", "Alexandr Zhelanov", "Ilya Kaplan"], 
										note	=	"Zur Verfügung gestellt von AudioBank.Fm and OpenGameArt.org"		}
			{	desc	=	"Besonderer Dank geht an",	name	=	["Yann van der Cruyssen", "Cedric Vaniez", "David Ghodsi", "Thomas Simonnet", "Lucas Boulestin", "Marc Planard"]	}
			{	desc	=	"Testers",	name = ["Florian Belmonte", "Clement Vincent", "Thomas Lechaptois"]	}
			{	desc	=	"Powered by GameStart!"	}
	]

	//	Game End
	end_game_line_0		=	"Dev Team : ",

	//	EndLevel / Debrief
	endlevel_level_name	=	"Level",
	endlevel_score		=	"Score",
	endlevel_fuel		=	"Fuel",
	endlevel_life		=	"Life",
	endlevel_perfect	=	"Perfekt !!!",
	endlevel_new_record	=	"New Record !!!",
	endlevel_life_record	=	"Life Record !!!",
	endlevel_fuel_record	=	"Fuel Record !!!",
	endlevel_time_record	=	"Time Record !!!",
	endlevel_remain_life	=	"Restlaufzeit",
	endlevel_remain_fuel	=	"Restliche Fuel",
	endlevel_time			=	"Time",
	total_score				=	"Total Score",
	score_points			=	"points",
	story_0					=	"Deep down, behind the walls,\nyou found a hand...",
	story_1					=	"Escaping the deadly lasers,\nyou found another hand!",
	story_2					=	"Hidden within these rocks,\nyou just found a leg.",
	story_3					=	"Two legs and two arms?\nNone fits your mechanic body.",
	story_4					=	"A body, a brain,\nwhat you need now is a head.",
	story_5					=	"Having found a whole body,\nyour journey now ends.",

	//	InGame / Hud
	hud_help			=	"||",
	hud_skip			=	">>",
	hud_damage			=	"LIFE"
	hud_fuel			=	"FUEL"
	hud_artifacts		=	"ARTIFACTS"
	hud_stopwatch		=	"TIME"

	pause_resume_game	=	"WEITER",
	pause_restart_level	=	"NEUSTART",
	pause_quit_game		=	"AUFGEBEN",

	get_ready			=	"Get Ready!"
	game_over			=	"Game Over"
	no_fuel				=	"Out of Fuel!"
	dead_by_damage		=	"Brain Damage!"
	dead_by_poison		=	"Poisoned!"
	no_time_left		=	"No Time Left!"
	return_base			=	"Go to Base!\n~~Size(40)You found all the artifacts."
	mission_complete	=	"Mission Complete!"
	player_time			=	"~~Size(40)Your time : "
	level_names			=	{
								level_0		=	"First Flight",
								level_1		=	"Jump Again",
								level_2		=	"Three Parter"
								level_3		= 	"Cogs Avenue",
								level_4		= 	"Under the Garden",
								level_5		=	"Diagonals",
								level_6		=	"The Slime Passage",
								level_7		=	"Meet the Lasers",
								level_8		=	"Going Narrow",
								level_9		=	"Up and Down",
								level_10	=	"The Old Factory",
								level_11	=	"Quad Death"
								level_12	=	"The Rotary"
								level_13	=	"The Core",
								level_14	=	"The Lost Ship",
								level_15	=	"Floating Valley",
								level_16	=	"Elevator Action",
								level_17	=	"Lucas",
								level_18	=	"The Lost Ruins",
								level_19	=	"The Sunken Galeon",
								level_20	=	"Square Labyrinth",
								level_21	=	"Rect. Labyrinth",
								level_22	=	"Laser Cave",
								level_23	=	"Laser Chimney",
								default_name	=	"Level Name"
							}
}
