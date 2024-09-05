class	SlideShow
{
	sprites			=	0
	textures		=	0

	cspr_angle		=	0
	cspr_index		=	0
	cspr_time		=	0
	ctex_index		=	0

	slide_view		=	Sec(6)
	slide_fade		=	Sec(3)

	z				=	0.5

	function	setZOrder(_z)
	{
		z = _z
		WindowSetZOrder(currentSprite(), z)
		WindowSetZOrder(nextSprite(), z + 0.01)
	}

	//-------------------------------------------------------------------------------------
	function	update(dt)
	{
		local view_phase = cspr_time >= slide_fade

		cspr_time -= dt

		local k = 1.0 - cspr_time / (slide_view + slide_fade)

		local s = (g_screen_width / 1024.0) + Pow(k, 1.0) * 0.15,
			  r = Pow(k, 2.0)
		SpriteSetScale(currentSprite(), s, s)
		SpriteSetRotation(currentSprite(), r * cspr_angle)

		if	(cspr_time < slide_fade)
		{
			if	(view_phase)	// entering fade.
			{
				// Activate alpha on foreground sprite.
				WindowSetZOrder(currentSprite(), z)
				WindowRemoveStyle(currentSprite(), StyleNoBlend)

				// Bring up the background sprite, remove alpha.
				setTexture(nextSprite(), nextTexture())
				WindowSetZOrder(nextSprite(), z + 0.01)
				WindowSetOpacity(nextSprite(), 1.0)
				WindowAddStyle(nextSprite(), StyleNoBlend)
				SpriteSetScale(nextSprite(), (g_screen_width / 1024.0), (g_screen_width / 1024.0))
				SpriteSetRotation(nextSprite(), 0)
			}

			// Fade foreground.
			local k = cspr_time / slide_fade
			SpriteSetOpacity(currentSprite(), Max(k, 0.0))

			if	(k <= 0.0)
			{
				cspr_angle = Rand(-0.1, 0.1)
				cspr_time += slide_view + slide_fade
				swapSprite()
				k = 0
			}
		}
	}
	//-------------------------------------------------------------------------------------

	//-------------------------------------------------------------------------------------
	function	nextTexture()
	{
		if	(textures.len() == 0)
			return NullTexture

		local t = textures[ctex_index]
		ctex_index = (ctex_index + 1) % textures.len()
		return t
	}
	//-------------------------------------------------------------------------------------

	//-------------------------------------------------------------------------------------
	function	setTexture(s, t)
	{
		SpriteSetTexture(s, t)
		SpriteSetSize(s, TextureGetWidth(t), TextureGetHeight(t))
		SpriteSetPivot(s, TextureGetWidth(t) / 2.0, TextureGetHeight(t) / 2.0)
	}

	function	currentSprite()
	{	return sprites[cspr_index]	}
	function	nextSprite()
	{	return sprites[(cspr_index + 1) % 2]	}
	function	swapSprite()
	{	cspr_index = (cspr_index + 1) % 2	}
	//-------------------------------------------------------------------------------------

	//-------------------------------------------------------------------------------------
	function	setup(paths)
	{
		textures = []
		foreach (path in paths)
			textures.append(EngineLoadTexture(g_engine, path))

		ctex_index = 0
		cspr_index = 0
		setTexture(currentSprite(), nextTexture())
		cspr_time = slide_view + slide_fade

		WindowSetZOrder(currentSprite(), z)
		WindowSetOpacity(currentSprite(), 1)
		WindowAddStyle(currentSprite(), StyleNoBlend)
		WindowSetOpacity(nextSprite(), 0)
	}
	//-------------------------------------------------------------------------------------

	constructor(ui)
	{
		sprites =
		[
			UIAddSprite(ui, -1, NullTexture, g_screen_width * 0.5, g_screen_height * 0.5, 0, 0),
			UIAddSprite(ui, -1, NullTexture, g_screen_width * 0.5, g_screen_height * 0.5, 0, 0)
		]
	}
}
