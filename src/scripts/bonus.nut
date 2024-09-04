/*
	File: scripts/bonus.nut
	Author: Astrofra
*/

		Include("scripts/thread_handler.nut")
		Include("scripts/globals.nut")

//--------------------------------
function	ThreadBonusFastClock(scene)
//--------------------------------
{
	print("ThreadBonusFastClock() : begin.")
	EngineSetClockScale(g_engine, 2.0)
	GenericThreadWait(g_bonus_duration * EngineGetClockScale(g_engine))
	EngineSetClockScale(g_engine, 1.0)
	print("ThreadBonusFastClock() : end.")
}

//--------------------------------
function	ThreadBonusSlowClock(scene)
//--------------------------------
{
	print("ThreadBonusSlowClock() : begin.")
	EngineSetClockScale(g_engine, 0.5)
	GenericThreadWait(g_bonus_duration * EngineGetClockScale(g_engine))
	EngineSetClockScale(g_engine, 1.0)
	print("ThreadBonusSlowClock() : end.")
}

//--------------------------------
function	ThreadBonusTime(scene)
//--------------------------------
{
	print("ThreadBonusTime() : begin.")
	local	_scene_script
	_scene_script = SceneGetScriptInstance(scene)
	_scene_script.stopwatch_handler.Stop()
	GenericThreadWait(g_bonus_duration * EngineGetClockScale(g_engine))
	_scene_script.stopwatch_handler.Start()
	print("ThreadBonusTime() : end.")
}

//--------------------------------
function	ThreadBonusShield(scene)
//--------------------------------
{
	print("ThreadBonusShield() : begin.")
	local	_scene_script
	_scene_script = SceneGetScriptInstance(scene)
	_scene_script.player_script.EnableShield()
	GenericThreadWait(g_bonus_duration * EngineGetClockScale(g_engine))
	_scene_script.player_script.DisableShield()
	print("ThreadBonusShield() : end.")
}