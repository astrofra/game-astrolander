//	Locale (Italian)
//	locale_it.nut

g_locale_it	<-	{
	main_font_name		=	"yanone_kaffeesatz"

	//	System
	loading				=	 "Caricamento",
	language 			=	 "Italiano",

	//	Title
	game_title			=	"ASTLAN"                 
	game_subtitle		=	"Astro Lander"           
	level_easy			=	"Facile",                
	level_normal		=	"Normale",               
	level_hard			=	"Estremo",               
	start_game			=	"Gioca"                  
	play_level			=	"Inizia",                
	next_level			=	"Prossimo",              
	skip_screen			=	"Salta",                 
	option				=	"Opzioni",                
	back_to_title		=	"Titolo",       
	copyright			=	"(c) 2011-2012 Astrofra."
	control_reverse		=	"Inverti Controlli"      
	yes					=	"Sì"                     
	no					=	"No"                     
	leaderboard			=	"Leaders"                
	music_volume		=	"Volume Musica"          
	sound_fx_volume		=	"Volume Effetti"         
	player_nickname		=	"Nome Giocatore"         
	credits_button 		=	"Riconoscimenti"         

	//	Leaderboard
	leaderboard_title	=	"Astro Leaders"
	guest_nickname		=	"Guest"
	
	//	Credits
	credits 		=	[
			{	desc	=	"Game Code & 3D Graphics" ,	name	=	"Astrofra"	}
			{	desc	=	"2D Graphics" ,	name	=	"Pehesse"	}
			{	desc	=	"Game Engine, Additional Code",	name	=	"Emmanuel Julien"	}
			{	desc	=	"Musica" ,	name	=	["Alex Khaskin", "William Lamy", "Brandon Morris", "Alexandr Zhelanov", "Ilya Kaplan"], 
										note	=	"Fornito da AudioBank.Fm e OpenGameArt.org"		}
			{	desc	=	"Special Thanks to",	name	=	["Yann van der Cruyssen", "David Ghodsi", "Thomas Simonnet", "Lucas Boulestin", "Marc Planard"]	}
			{	desc	=	"Testers",	name = ["Florian Belmonte", "Clement Vincent", "Cedric Vaniez", "Thomas Lechaptois"]	}
			{	desc	=	"Powered by GameStart!"	}
	]

	//	Game End
	end_game_line_0		=	"Staff : ",

	//	EndLevel / Debrief
	endlevel_level_name	=	"Livello",
	endlevel_score		=	"Punteggio",
	endlevel_fuel		=	"Fuel",
	endlevel_life		=	"Vita",
	endlevel_perfect	=	"Perfetto !!!",
	endlevel_new_record	=	"Nuovo Record !!!",
	endlevel_life_record	=	"Record Vita!!!",
	endlevel_fuel_record	=	"Record Carburante!!!",
	endlevel_time_record	=	"Tempo Record !!!",
	endlevel_remain_life	=	"Vita Rimasta",
	endlevel_remain_fuel	=	"Carburante Rimasto",
	endlevel_time			=	"Tempo",
	total_score				=	"Punteggio Totale",
	score_points			=	"Punteggi",
	story_0					=	"Nelle profondità, dietro a pareti,\nhai trovato una mano...",
	story_1					=	"Fuggendo dai laser mortali,\nhai trovato un'altra mano!",
	story_2					=	"Nascosta all'interno di queste rocce,\nhai trovato una gamba.",
	story_3					=	"Due gambe e due braccia?\nNiente adatto al tuo corpo meccanico.",
	story_4					=	"Un corpo, un cervello,\nquello di cui hai bisogno ora è una testa.",
	story_5					=	"Hai trovato un corpo completo,\nil tuo viaggio è finito.",

	//	InGame / Hud
	hud_help			=	"||",
	hud_skip			=	">>",
	hud_damage			=	"VITA"
	hud_fuel			=	"FUEL"
	hud_artifacts		=	"MANUFATTI"
	hud_stopwatch		=	"TEMPO"

	pause_resume_game	=	"RIPRENDI",
	pause_restart_level	=	"RICOMINCIA",
	pause_quit_game		=	"ESCI",

	get_ready			=	"Preparati!"
	game_over			=	"Game Over"
	no_fuel				=	"Carburante Esaurito!"
	dead_by_damage		=	"Cervello Danneggiato!"
	dead_by_poison		=	"Avvelenato!"
	no_time_left		=	"Tempo Scaduto!"
	return_base			=	"Torna alla base\n~~Size(40)Hai trovato tutti i manufatti."
	mission_complete	=	"Missione Completa!"
	player_time			=	"~~Size(40)Tempo Impiegato : "
	level_names			=	{
								level_0		=	"Primo Volo",              
								level_1		=	"Salta Ancora",            
								level_2		=	"Tripartito"              
								level_3		= 	"La Via Degli Ingranaggi",   
								level_4		= 	"Sotto Al Giardino",        
								level_5		=	"Diagonali",              
								level_6		=	"Il Viscido Passaggio",     
								level_7		=	"Ti Presentoi Laser",       
								level_8		=	"Sempre Più Stretto",       
								level_9		=	"Su e Giù",                 
								level_10	=	"La Vecchia Fabbrica",      
								level_11	=	"Morte al quadrato"         
								level_12	=	"Rotazione"               
								level_13	=	"Il Nucleo",               
								level_14	=	"La Nave Perduta",          
								level_15	=	"La Valle Fluttuante",      
								level_16	=	"Elevator Action",         
								level_17	=	"Lucas",                  
								level_18	=	"Le Rovine Perdute",        
								level_19	=	"Il Galeone Affondato",     
								level_20	=	"Il Labirinto Quadrato",    
								level_21	=	"Il Labirinto Rettangolare",
								level_22	=	"La Caverna Dei Laser",      
								level_23	=	"La Ciminiera Dei Laser",    
								default_name	=	"Livello"                 
							}
}