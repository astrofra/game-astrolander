/*
	File: scripts/vfx.nut
	Author: Astrofra
*/

class	GodRayOscillation
{
/*<
	<Parameter =
		<freq = <Name = "Frequency"> <Type = "float"> <Default = 1.0>>
	>
	<Parameter =
		<amplitude = <Name = "Amplitude"> <Type = "float"> <Default = 1.0>>
	>
>*/
		amplitude	=	1.0
		angle		=	0.0
		phase		=	0.0
		freq		=	1.0
		item_list	=	0
		item_scale	=	0

		function	OnSetup(item)
		{
			item_scale = []
			item_list = ItemGetChildList(item)
			foreach(_item in item_list)
				item_scale.append(ItemGetScale(_item))
			
			phase		=	DegreeToRadian(Rand(0, 90) + 15.0)
			freq *= Rand(0.95, 1.05)
		}

		function	OnUpdate(item)
		{
			angle += g_dt_frame * freq * DegreeToRadian(360.0)

			foreach(_i, _item in item_list)
			{
				local	_scale
				_scale = item_scale[_i] + Vector(0, 0, sin(angle + (phase * _i)) * amplitude)
				ItemSetScale(_item, _scale)
			}
		}

}

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