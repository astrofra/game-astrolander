/*
	File: scripts/preloader.nut
	Author: Astrofra
*/

/*!
	@short	Preload
	@author	Astrofra
*/
class	Preload
{
	
	object_list = [
	"background_hills_0.nmg",
	"black_box.nmg",
	"blue_sparkle.nmg",
	"bonus_fast_clock.nmg",
	"bonus_fuel.nmg",
	"bonus_heal.nmg",
	"bonus_shield.nmg",
	"bonus_slow_clock.nmg",
	"bonus_time.nmg",
	"fx_plane.nmg",
	"gear_0.nmg",
	"gear_1.nmg",
	"gear_2.nmg",
	"helper_range.nmg",
	"item_taken_feedback.nmg",
	"jawgate_bottom.nmg",
	"jawgate_top.nmg",
	"lamp_0.nmg",
	"lamp_1.nmg",
	"level_background.nmg",
	"metal_mine.nmg",
	"MobileLazerBeam.nmg",
	"MobileLazerGun.nmg",
	"mountain_back_element.tga.nmg",
	"particle_bubble.nmg",
	"particle_deadzone.nmg",
	"particle_glow.nmg",
	"particle_lazer_hit.nmg",
	"particle_smoke.nmg",
	"pod_body.nmg",
	"pod_body_slimed.nmg",
	"pod_body_wounded.nmg",
	"pod_brain.nmg",
	"pod_canopy.nmg",
	"pod_edge.nmg",
	"pod_shield.nmg",
	"PropBush0_mobile.nmg",
	"PropBush1_mobile.nmg",
	"PropBush2_mobile.nmg",
	"PropEgyptBrokenColumn1.nmg",
	"PropEgyptBrokenColumn2.nmg",
	"PropEgyptColumn.nmg",
	"PropEgyptObelisk.nmg",
	"PropGreeceColumn.nmg",
	"PropGreeceColumnBroken1.nmg",
	"PropGreeceColumnBroken2.nmg",
	"reservoir.nmg",
	"rotary_gate_0.nmg",
	"rotary_gate_slot.nmg",
	"target.nmg",
	"thrust_flame.nmg",
	"tree_0_mobile.nmg"
	]

	current_object		=	0
	progress			=	0
	ui					=	0
	bar					=	0

	toggle				=	false

//object_list = []

	function	OnSetup(scene)
	{
		print("Preload::OnSetup()")
		current_object	=	0
		ui	=	SceneGetUI(scene)
		
		local	_preloader_back_texture, _preloader_bar_texture, _w, _h, _wb, _hb
		_preloader_back_texture = EngineLoadTexture(g_engine, "ui/loader_back.png")
		_preloader_bar_texture = EngineLoadTexture(g_engine, "ui/loader_bar.png")

		_w = TextureGetWidth(_preloader_back_texture)
		_h = TextureGetHeight(_preloader_back_texture)
		_wb = TextureGetWidth(_preloader_bar_texture)
		_hb = TextureGetHeight(_preloader_bar_texture)

		local	_back = UIAddSprite(ui, -1, _preloader_back_texture, g_screen_width * 0.5 - _w * 0.5, g_screen_height - _h * 2.0, _w, _h)
		bar = UIAddSprite(ui, -1, _preloader_bar_texture, 16, 32, 481, 21)
		WindowSetParent(bar, _back)
	}

	function	OnUpdate(scene)
	{
		if (object_list.len() > 0)
			progress	=	(((object_list.len() - current_object) * 100.0) / object_list.len()).tointeger()

		progress = Clamp(100 - progress, 0.0, 100)
		//progress = (Pow(progress / 100.0, 2.0) * 100.0).tointeger()

		WindowSetScale(bar, Clamp((progress / 100.0), 0.01, 1.0), 1.0)

		print("Preload::OnUpdate() progress = " + progress)

		toggle != toggle

		if (toggle)
			return

		if (UIIsCommandListDone(ui))
		{
			if (current_object < object_list.len())
			{
				EngineLoadGeometry(g_engine, "graphics/" + object_list[current_object])
			}
			else
				ProjectGetScriptInstance(g_project).ProjectGotoScene("levels/screen_logo.nms")

			current_object++
		}
	}

}
