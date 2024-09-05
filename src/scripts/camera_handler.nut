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
	camera 			=	0
	camera_pos		=	0
	camera_rot		=	0
	camera_rot_z	=	0
	camera_rot_z_table	=	0
	camera_offset_z_table	=	0
	target_vel		=	0
	max_sneak_speed	=	1.5		//	max speed when evaluating the camera unzoom
	sneak_radius	=	Mtr(40.0)

	constructor(_scene)
	{
		scene = _scene
		camera_item = LegacySceneFindItem(scene,"game_camera")
		camera_pos = ItemGetWorldPosition(camera_item)
		camera_rot = Vector(0,0,0)
		camera_rot_z = 0.0
		camera_rot_z_table = [0.0]
		camera_offset_z_table = [0.0]
		camera = ItemCastToCamera(camera_item)
		SceneSetCurrentCamera(scene, camera)
		CameraSetFov(ItemCastToCamera(camera_item), DegreeToRadian(22.5))
		CameraSetClipping(ItemCastToCamera(camera_item), Mtr(20.0), Mtr(1500.0))
		target_vel = Vector(0,0,0)
	}

	function	SetMaxSneakSpeed(_s)
	{	max_sneak_speed = _s	}

	//------------------------------------
	function	StickToPlayerPosition(player_pos)
	//------------------------------------
	{
		local	_z_save = camera_pos.z
		camera_pos = player_pos
		camera_pos.z = _z_save
		ItemSetPosition(camera_item, camera_pos)
	}
	
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

			//	Filter z offset
			camera_offset_z_table.append(clamp_vel.z)
			if (camera_offset_z_table.len() > 15)
				camera_offset_z_table.remove(0)

			clamp_vel.z = 0.0
			foreach(_z in camera_offset_z_table)
				clamp_vel.z += _z
			clamp_vel.z /= (camera_offset_z_table.len().tofloat())

			//	--------------------------------------------------
			//	Camera rotation along the player lateral velocity
			//	--------------------------------------------------
			local	_clamp_x_vel = Abs(player_vel.x)
			_clamp_x_vel = Clamp(_clamp_x_vel, 0.0, g_player_max_speed)
			_clamp_x_vel = RangeAdjust(_clamp_x_vel, g_player_max_speed * 0.125, g_player_max_speed * 0.75, 0.0, 1.0)
			_clamp_x_vel = Clamp(_clamp_x_vel, 0.0, 1.0)
			if (player_vel.x < 0.0)
				_clamp_x_vel *= -1

			camera_rot_z = _clamp_x_vel * -2.5
			camera_rot_z = Clamp(camera_rot_z, -2.5, 2.5)
				
			//	Filter the camera rotation on 15 iterations
			//	FIXME : make the filter framerate independent
			camera_rot_z_table.append(camera_rot_z)
			if (camera_rot_z_table.len() > 25)
				camera_rot_z_table.remove(0)

			camera_rot_z = 0.0
			foreach(_z in camera_rot_z_table)
				camera_rot_z += _z

			camera_rot_z /= (camera_rot_z_table.len().tofloat())
			camera_rot.z = DegreeToRadian(camera_rot_z)

//			print("player_vel.x = " + player_vel.x)
//			print("camera_rot_z = " + camera_rot_z)

			ItemSetPosition(camera_item, camera_pos + clamp_vel)
			ItemSetRotation(camera_item, camera_rot)
	}

}
