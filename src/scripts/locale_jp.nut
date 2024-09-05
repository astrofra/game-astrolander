//	Locale
//	locale.nut

g_locale_jp	<-	{
	main_font_name		=	"tabimyou"
	hud_font_name		=	"hw-zen"
	hud_font_size		=	1.25

	//	System
	loading				=	"ロード中"
	language 			=	"日本語",

	//	Title
	game_title			=	"ASTLAN",
	game_subtitle		=	"アストロレンダー",	
	level_easy			=	"イージー",
	level_normal		=	"ノーマル",
	level_hard			=	"ハード",
	start_game			=	"始める"
	play_level			=	"スタート",
	next_level			=	"次",
	skip_screen			=	"スキップ",
	option				=	"オプション"
	back_to_title		=	"戻る",
	copyright			=	"(c) 2011-2012 Astrofra."
	control_reverse		=	"逆操作"
	yes					=	"はい"
	no					=	"いいえ"
	leaderboard			=	"ハイスコア"
	music_volume		=	"音楽"
	sound_fx_volume		=	"音響効果"
	player_nickname		=	"プレイヤーのニックネーム"
	credits_button 		=	"クレジット"

	//	Leaderboard
	leaderboard_title	=	"アスツロリーダーズ"

	//	Credits
	credits 		=	[
			{	desc	=	"プログラミング & 3D CG" ,	name	=	"Astrofra"	}
			{	desc	=	"UI デザイン & 2D CG" ,	name	=	"Pehesse"	}
			{	desc	=	"ゲーム・エンジン & 追加プログラミング",	name	=	"Emmanuel Julien"	}
			{	desc	=	"音楽" ,	name	=	["Alex Khaskin", "William Lamy", "Brandon Morris", "Alexandr Zhelanov", "Ilya Kaplan"], 
									note	=	"Provided by AudioBank.Fm and OpenGameArt.org"		}
			{	desc	=	"Special Thanks",	name	=	["Yann van der Cruyssen", "Cedric Vaniez", "David Ghodsi", "Thomas Simonnet", "Lucas Boulestin", "Marc Planard"]	}
			{	desc	=	"ソフトウェアテスト",	name = ["Florian Belmonte", "Clement Vincent", "Thomas Lechaptois"]	}
			{	desc	=	"Powered by GameStart!"	}
	]

	//	Game End
	end_game_line_0		=	"スタッフ : ",
	//	EndLevel / Debrief
	endlevel_score			=	"スコア",
	endlevel_fuel			=	"燃料",
	endlevel_life			=	"ライフ",
	endlevel_perfect		=	"パーフェクト !!!",
	endlevel_new_record		=	"新記録 !!!",
	endlevel_life_record	=	"生涯記録 !!!",
	endlevel_fuel_record	=	"ベスト燃料記録 !!!",
	endlevel_time_record	=	"ベストタイム !!!",
	endlevel_remain_life	=	"残りのライフ",
	endlevel_remain_fuel	=	"残りの燃料",
	total_score				=	"総合スコア",
	endlevel_time			=	"時間",
	score_points			=	"ポイント",
	story_0					=	"深い底、いくつもの壁を通り抜け\n最初の手を見つける。",
	story_1					=	"レーザー光線から逃れ,\n次の手を見つける。",
	story_2					=	"岩で隠されていた,\n足を見つける。",
	story_3					=	"2つの手と２つの足？\nこのメカニックボディーには合わない。"
	story_4					=	"体と、脳みそ\nあとは頭を見つけなければ！",
	story_5					=	"最後の体のパーツを見つけ,\n君の旅は終了する。"

	//	InGame / Hud
	hud_help			=	"||",
	hud_skip			=	">>",
	hud_damage			=	"LIFE"
	hud_fuel			=	"FUEL"
	hud_artifacts		=	"ARTIFACTS"
	hud_stopwatch		=	"TIME"

	pause_resume_game	=	"RESUME",
	pause_restart_level	=	"RESTART",
	pause_quit_game		=	"QUIT",

	get_ready			=	"Get Ready!"
	game_over			=	"ゲームオーバー"
	no_fuel				=	"燃料切れ!"
	dead_by_damage		=	"脳死!"
	dead_by_poison		=	"毒で死んだ!"
	no_time_left		=	"タイムオーバー"
	return_base			=	"基地に向かえ!\n~~Size(40)すべてのアーチファクトをみつけた."
	mission_complete	=	"レベルクリア!"
	player_time			=	"~~Size(40)時間記録 : "
	level_names			=	{
								level_0		=	"初飛行",
								level_1		=	"アップ&ダウン",
								level_2		=	"昇りつめろ！"
								level_3		= 	"ギアの世界",
								level_4		= 	"庭で",
								level_5		=	"シャッター",
								level_6		=	"スライム",
								level_7		=	"レーザー光線",
								level_8		=	"ウォーター パイプ",
								level_9		=	"迷路",
								level_10	=	"蛇道",
								level_11	=	"四死"
								level_12	=	"ロータリー"
								level_13	=	"核",
								level_14	=	"難破船",
								level_15	=	"浮世",
								level_16	=	"エレベーターアクション",
								level_17	=	"ルカス",
								level_18	=	"失われた遺跡",
								level_19	=	"沈んだガレオン船",
								level_20	=	"正方形のラビリンス",
								level_21	=	"長方形のラビリンス",
								level_22	=	"レーザー洞窟",
								level_23	=	"レーザー煙突",
								default_name	=	"レベルの名前"
							}
}
