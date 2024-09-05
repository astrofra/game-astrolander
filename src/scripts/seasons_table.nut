//	Seasons
g_seasons	<-	0

g_seasons	=	{
	season_0	=	{
		title	=	tr("Early Quest", "season"),
		icon	=	"ui/seasons/season_0.png",
		levels = [
			{scene = "levels/level_0.nms", title = tr("First Flight", "level"),				music = "audio/music/", intro = "levels/how_to_play.nms"},
			{scene = "levels/level_1.nms", title = tr("Jump Again", "level"),				music = "audio/music/"},
			{scene = "levels/level_2.nms", title = tr("Three Parter", "level"),				music = "audio/music/"},
			{scene = "levels/level_3.nms", title = tr("Cogs Avenue", "level"),				music = "audio/music/", outro = {picture = "ui/story_0.jpg", text = tr("Deep down, behind the walls,\nyou found a hand...")}},
			{scene = "levels/level_4.nms", title = tr("Under the Garden", "level"),			music = "audio/music/"},
			{scene = "levels/level_5.nms", title = tr("Diagonals", "level"),				music = "audio/music/"},
			{scene = "levels/level_6.nms", title = tr("The Slime Passage", "level"),		music = "audio/music/"},
			{scene = "levels/level_7.nms", title = tr("Meet the Lasers", "level"),			music = "audio/music/", outro = {picture = "ui/story_1.jpg", text = tr("Escaping the deadly lasers,\nyou found another hand!")}},
		]
	},
	
	season_1 = {
		title	=	tr("Deep into the Sky", "season"),
		icon	=	"ui/seasons/season_1.png",
		levels = [
			{scene = "levels/level_8.nms",	 title = tr("Going Narrow", "level"),			music = "audio/music/"},
			{scene = "levels/level_9.nms",	 title = tr("Up and Down", "level"),			music = "audio/music/"},
			{scene = "levels/level_10.nms",	 title = tr("The Old Factory", "level"),		music = "audio/music/"},
			{scene = "levels/level_11.nms"	 title = tr("Quad Death", "level"),				music = "audio/music/", outro = {picture = "ui/story_2.jpg", text = tr("Hidden within these rocks,\nyou just found a leg.")}},
			{scene = "levels/level_12.nms",	 title = tr("The Rotary", "level"),				music = "audio/music/"},
			{scene = "levels/level_13.nms",	 title = tr("The Core", "level"),				music = "audio/music/"},
			{scene = "levels/level_14.nms",	 title = tr("The Lost Ship", "level"),			music = "audio/music/"},
			{scene = "levels/level_15.nms",	 title = tr("Floating Valley", "level"),		music = "audio/music/", outro = {picture = "ui/story_3.jpg", text = tr("Two legs and two arms?\nNone fits your mechanic body.")}},
		]
	},

	season_2 = {
		title	=	tr("Wet Planet", "season"),
		icon	=	"ui/seasons/season_2.png",
		levels = [
			{scene = "levels/level_16.nms",	 title = tr("Elevator Action", "level"),		music = "audio/music/"},
			{scene = "levels/level_17.nms",	 title = tr("Lucas", "level"),					music = "audio/music/"},
			{scene = "levels/level_18.nms",	 title = tr("The Lost Ruins", "level"),			music = "audio/music/"},
			{scene = "levels/level_19.nms"	 title = tr("The Sunken Galeon", "level"),		music = "audio/music/", outro = {picture = "ui/story_4.jpg", text = tr("A body, a brain,\nwhat you need now is a head.")}},
			{scene = "levels/level_20.nms",	 title = tr("Square Labyrinth", "level"),		music = "audio/music/"},
			{scene = "levels/level_21.nms",	 title = tr("Rect. Labyrinth", "level"),		music = "audio/music/"},
			{scene = "levels/level_22.nms",	 title = tr("Laser Cave", "level"),				music = "audio/music/"},
			{scene = "levels/level_23.nms",	 title = tr("Laser Chimney", "level"),			music = "audio/music/", outro = {picture = "ui/story_5.jpg", text = tr("Having found a whole body,\nyour journey now ends.")}},
		]
	},
}