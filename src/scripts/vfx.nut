/*
	File: scripts/vfx.nut
	Author: Astrofra
*/

/*!
	@short	AlphaFlicker
	@author	Astrofra
*/

class	AlphaFlicker
{

	alpha	=	0.0

	function	OnUpdate(item)
	{
		alpha = alpha + g_dt_frame * 30.0 * Rand(-1.0, 1.0)
		if (Rand(0,100) > 90)
			alpha += g_dt_frame * 60.0 * 0.5
		alpha = Clamp(alpha, 0.0, 1.0)
		ItemSetOpacity(item, alpha)
	}
}