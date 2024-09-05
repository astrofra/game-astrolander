//	Weather settings


//--------------------------------
function	SetAmbientColor(scene)
//--------------------------------
{
	local	k = ProjectGetScriptInstance(g_project).player_data.current_level
	k = RangeAdjust(k.tofloat(), 0.0, 20.0, 0.0, 1.0)
	k = Clamp(k, 0.0, 1.0)
	local _color = RGBColorBlend(g_ambient_color_warm, g_ambient_color_cold, k)

	_color = RGBColorBlend(_color, g_ambient_color_dawn, MakeTriangleWave(k))

	_color = _color.Scale(1.0 / 255.0)
	_color.Print("SetAmbientColor()")
	SceneSetAmbientColor(scene, _color)
//	_color = SceneGetAmbientColor(scene)

	local	fog_color = Vector(0,200,255,255).Scale(1.0 / 255.0) //SceneGetFogColor(scene)
	local	tinted_fog_color = RGBColorBlend(fog_color, _color, 0.5) //.Scale(1.25)
	SceneSetFog(scene, true, tinted_fog_color, Mtr(75), Mtr(450))
}