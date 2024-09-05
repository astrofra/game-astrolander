//	Weather settings


//--------------------------------
function	SetAmbientColor(scene)
//--------------------------------
{
	local	k = GlobalGetCurrentLevel()
	local	_color
/*
	k = RangeAdjust(k.tofloat(), 0.0, 20.0, 0.0, 1.0)
	k = Clamp(k, 0.0, 1.0)
	_color = RGBColorBlend(g_ambient_color_warm, g_ambient_color_cold, k)

	_color = RGBColorBlend(_color, g_ambient_color_dawn, MakeTriangleWave(k))

	_color = _color.Scale(1.0 / 255.0)

	_color.Print("SetAmbientColor()")
	SceneSetAmbientColor(scene, _color)
*/
//	_color = SceneGetAmbientColor(scene)

//	local	fog_color = Vector(90,220,255,255).Scale(1.0 / 255.0) //SceneGetFogColor(scene)
//	local	tinted_fog_color = RGBColorBlend(fog_color, _color, 0.25) //.Scale(1.25)
	SceneSetFog(scene, true, SceneGetFogColor(scene), Mtr(100), Mtr(250))

	if	(IsTouchPlatform() || force_android_render_settings)
	{
		print("LevelHandler::OnSetup() Deleting lights, mobile platform.")
		SceneDeleteItem(scene, SceneFindItem(scene, "sun"))
//		SceneDeleteAllLights(scene)			
		SceneSetAmbientIntensity(scene, 2.0)
		local	_amb_color = SceneGetAmbientColor(scene)
		_amb_color = _amb_color.Lerp(0.75, Vector(0.5, 0.5, 0.5, 1.0))
		SceneSetAmbientColor(scene, _amb_color)
	}
}