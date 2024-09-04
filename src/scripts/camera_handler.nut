/*
	File: scripts/camera_handler.nut
	Author: Astrofra
*/

/*!
	@short	CameraHandler
	@author	Astrofra
*/
class	CameraHandler
{
	scene			=	0
	camera_item		=	0
	camera_pos		=	0
	target_vel		=	0
	max_sneak_speed	=	10.0		//	max speed when evaluating the camera unzoom
	sneak_radius	=	Mtr(15.0)

	constructor(_scene)
	{
		scene = _scene
		camera_item = SceneFindItem(scene,"game_camera")
		camera_pos = ItemGetWorldPosition(camera_item)
		SceneSetCurrentCamera(scene, ItemCastToCamera(camera_item))
		CameraSetFov(ItemCastToCamera(camera_item), DegreeToRadian(22.5))
		target_vel = Vector(0,0,0)
	}

	function	SetMaxSneakSpeed(_s)
	{	max_sneak_speed = _s	}
	
	//------------------------------------
	function	FollowPlayerPosition(player_pos = Vector(0,0,0), player_vel = Vector(0,0,0))
	//------------------------------------
	{
			local	v_d = Vector(0,0,0)

			//	Compute the delta between the actual player position
			//	and the last computed camera position
			//	Z remains untouched.
			v_d.x = player_pos.x - camera_pos.x
			v_d.y = player_pos.y - camera_pos.y
			v_d.z = 0.0

			//	Apply this delta to the camera position,
			//	modulated by the framerated.
			camera_pos = camera_pos + v_d.Scale(5.0 * g_dt_frame)

			//	Compute the delta between the actual "unzoom offset"
			//	and the last computed optimal offset
			//	Z remains untouched
			v_d.x = player_vel.x - target_vel.x
			v_d.y = player_vel.y - target_vel.y
			v_d.z = 0.0

			//	Scale & Clamp this offset, based on the player max speed,
			//	modulate it by the framerated.
			local	clamp_vel, speed
			target_vel = target_vel + v_d.Scale(0.25 * g_dt_frame)
			speed = RangeAdjust(target_vel.Len(), 0.0, max_sneak_speed, 0.0, sneak_radius)
			speed = Clamp(speed, 0.0, sneak_radius)
			//	Finally converts the offset length into the unzoom distance.
			clamp_vel = Vector(0,0, -speed)

			ItemSetPosition(camera_item, camera_pos + clamp_vel)
	}

}
