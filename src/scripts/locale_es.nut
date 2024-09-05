//	Locale (Spanish)
//	locale_es.nut

g_locale_es	<-	{
	main_font_name		=	"yanone_kaffeesatz"

	//	System
	loading				=	"Cargando",
	language 			=	"Español",

	//	Title
	game_title			=	"ASTLAN",
	game_subtitle		=	"Astro Lander",	
	level_easy			=	"Fácil",
	level_normal		=	"Normal",
	level_hard			=	"Difícil",
	start_game			=	"Jugar"
	play_level			=	"Empezar",
	next_level			=	"Siguiente",
	skip_screen			=	"Saltar",
	option				=	"Opciones",
	back_to_title		=	"Volver",
	copyright			=	"(c) 2011-2012 Astrofra.",
	control_reverse		=	"Invertir Controles",
	yes					=	"Si",
	no					=	"No",
	leaderboard			=	"Clasificación",
	music_volume		=	"Volumen música",
	sound_fx_volume		=	"Volumen sonidos",
	player_nickname		=	"Alias",
	credits_button 		=	"Créditos",

	//	Leaderboard
	leaderboard_title	=	"Astro Campeones",
	guest_nickname		=	"Invitado",
	
	//	Credits
	credits 			=	[
			{	desc	=	"Programación del juego & gráficos 3D" ,	name	=	"Astrofra"	}
			{	desc	=	"Gráficos 2D" ,	name	=	"Pehesse"	}
			{	desc	=	"Motor del juego, Programación adicional",	name	=	"Emmanuel Julien"	}
			{	desc	=	"Música" ,	name	=	["Alex Khaskin", "William Lamy", "Brandon Morris", "Kareem Kenawy", "Alexandr Zhelanov", "Ilya Kaplan"], 
				note	=	"proporcionado por AudioBank.Fm y OpenGameArt.org"		}
			{	desc	=	"Agradecimientos especiales para",	name	=	["Yann van der Cruyssen", "Cedric Vaniez", "David Ghodsi", "Thomas Simonnet", "Lucas Boulestin", "Marc Planard"]	}
			{	desc	=	"Testers",	name = ["Florian Belmonte", "Clement Vincent", "Thomas Lechaptois"]	}
			{	desc	=	"Desarrollado por GameStart"	}
	]

	//	Game End
	end_game_line_0			=	"Equipo: ",

	//	EndLevel / Debrief
	endlevel_level_name		=	"Nivel",
	endlevel_score			=	"Puntuación",
	endlevel_fuel			=	"Combustible",
	endlevel_life			=	"Vida",
	endlevel_perfect		=	"¡Perfecto!",
	endlevel_new_record		=	"¡Nuevo record!",
	endlevel_life_record	=	"¡Record de vida!",
	endlevel_fuel_record	=	"Record de Combustible",
	endlevel_time_record	=	"¡Record de tiempo!",
	endlevel_remain_life	=	"Vida restante",
	endlevel_remain_fuel	=	"Combustible restante",
	endlevel_time			=	"Tiempo",
	total_score				=	"Puntuación total"
	score_points			=	"puntos",
	story_0					=	"En lo más profundo, detrás de las paredes,\nencontraste una mano...",
	story_1					=	"Escapando de los mortales láseres,\n¡encontraste otra mano!",
	story_2					=	"Escondido detrás de esas rocas,\nacabas de encontrar una pierna.",
	story_3					=	"¿Dos piernas y dos brazos?\nNinguno se ajusta a tu cuerpo mecánico.",
	story_4					=	"Un cuerpo y un cerebro,\nahora necesitas una cabeza.",
	story_5					=	"Has completado el cuerpo,\ntu viaje se acaba.",

	//	InGame / Hud
	hud_help				=	"||",
	hud_skip				=	">>",
	hud_damage				=	"LIFE"
	hud_fuel				=	"FUEL"
	hud_artifacts			=	"ARTIFACTS"
	hud_stopwatch			=	"TIME"

	pause_resume_game		=	"REANUDAR",
	pause_restart_level		=	"REINICIAR",
	pause_quit_game			=	"QUITAR",

	get_ready				=	"¡Listo!",
	game_over				=	"Fin del juego",
	no_fuel					=	"¡Combustible agotado!",
	dead_by_damage			=	"¡Cerebro dañado!",
	dead_by_poison			=	"¡Envenenado!",
	no_time_left			=	"¡Tiempo agotado!",
	return_base				=	"¡Vuelva a la base!\n~~Size(40)Has encontrado todos los artefactos.",
	mission_complete		=	"¡Misión Completa!",
	player_time				=	"~~Size(40)Tu tiempo : ",
	level_names				=	{
								level_0	=	"Primer vuelo",
								level_1	=	"Salta de nuevo",
								level_2	=	"Tercera parte",
								level_3	= 	"Avenida de los Piños",
								level_4	= 	"Bajo el Jardín",
								level_5	=	"Diagonales",
								level_6	=	"El Pasaje Baboso",
								level_7	=	"Conoce los láseres",
								level_8	=	"Estrechando lazos",
								level_9	=	"Altibajos",
								level_10	=	"La vieja Fábrica",
								level_11	=	"Muerte al cuadrado",
								level_12	=	"La Rotativa",
								level_13	=	"El Corazón",
								level_14	=	"El Barco Perdido",
								level_15	=	"El Valle Flotante",
								level_16	=	"Elevator Action",
								level_17	=	"Lucas",
								level_18	=	"Ruinas Perdidas ",
								level_19	=	"El Galeón Hundido",
								level_20	=	"Laberinto Cuadrado",
								level_21	=	"Laberinto Rect.",
								level_22	=	"La cueva láser",
								level_23	=	"La chimenea láser",
								default_name	=	"Nombre del nivel"
							}
}
