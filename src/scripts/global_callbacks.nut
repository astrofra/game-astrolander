//	Global_callbacks.nut
print("//	Global_callbacks.nut		//")

//-----------------------------------------------------------------------------------------
function	OnRenderContextChanged()
{
	print("Global callback: OnRenderContextChanged().")
		
	local	current_scene_instance
	current_scene_instance = SceneGetScriptInstance(g_scene)
	
	if	("OnRenderContextChanged" in current_scene_instance)
		current_scene_instance.OnRenderContextChanged()
}

function	OnHardwareButtonPressed(button)
{
	print("Global callback: OnHardwareButtonPressed(" + button + ").")
		
	local	current_scene_instance
	current_scene_instance = SceneGetScriptInstance(g_scene)
	
	if	("OnHardwareButtonPressed" in current_scene_instance)
		current_scene_instance.OnHardwareButtonPressed(button)
}

function	OnHttpRequestComplete(uid, data)
{
	print("OnHttpRequestComplete() :  " + uid + " complete.")

	local	current_scene_instance
	current_scene_instance = SceneGetScriptInstance(g_scene)

	if	("HttpRequestComplete" in current_scene_instance)
		current_scene_instance.HttpRequestComplete(uid, data)
}

function	OnHttpRequestError(uid)
{
	print("OnHttpRequestError() :  " + uid + " errored.")

	local	current_scene_instance
	current_scene_instance = SceneGetScriptInstance(g_scene)

	if	("HttpRequestError" in current_scene_instance)
		current_scene_instance.HttpRequestError(uid)
}

function OnSetArcadeName(name)
{
	print("OnSetArcadeName() : Arcade name set to: " + name)
	g_player_name = name
}


function OnCancelArcadeName()
{
	print("OnSetArcadeName() Cancelled")
	g_player_name = -1
}