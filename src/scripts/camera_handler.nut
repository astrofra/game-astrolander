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

	constructor(_scene)
	{
		scene = _scene
		camera_item = SceneFindItem(scene,"game_camera")
		camera_pos = ItemGetWorldPosition(camera_item)
		SceneSetCurrentCamera(scene, ItemCastToCamera(camera_item))
	}
	
	//------------------------------------
	function	FollowPlayerPosition(player_pos)
	//------------------------------------
	{
			local	v_d = Vector(0,0,0)

			v_d.x = player_pos.x - camera_pos.x
			v_d.y = player_pos.y - camera_pos.y
			v_d.z = 0.0

			camera_pos = camera_pos + v_d.Scale(5.0 * g_dt_frame)
			ItemSetPosition(camera_item, camera_pos)
	}

}
