/*
	File: scripts/lunar_lander.nut
	Author: Astrofra
*/

Include("scripts/controller.nut")

/*!
	@short	LunarLander
	@author	Astrofra
*/
class	LunarLander
{
	controller			=	0
	pad					=	0
	thrust				=	25.0
	thrust_item			=	0

	scene				=	0
	camera				=	0

	auto_align_timeout	=	0.0
	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/
	function	OnUpdate(item)
	{
		pad = controller.GetControllerVector()
		UpdateCameraFromPlayerPosition(camera, item)
	}

	function	OnPhysicStep(item, dt)
	{
		RotationTypeControl(item)
	}

	function	UpdateCameraFromPlayerPosition(camera_item, item)
	{
		local	cam_pos = ItemGetWorldPosition(camera_item)
		local	player_pos = ItemGetWorldPosition(item)
		local	cam_pos_z

		cam_pos_z = cam_pos.z

		cam_pos =  cam_pos.Lerp(0.95, player_pos)		//	TODO : Frame independent code.
		cam_pos.z = cam_pos_z
		ItemSetPosition(camera_item, cam_pos)
	}

	function	ThrustTypeControl(item)
	{
		local	_v_thrust = ItemGetRotationMatrix(item).GetRow(1).Normalize().Scale(2.0)


		local	_h_thrust = ItemGetRotationMatrix(item).GetRow(0).Normalize().Scale(pad.x)
		_h_thrust = (_h_thrust + _v_thrust).Normalize()

		_h_thrust = _h_thrust.Scale(Abs(pad.x) * thrust * g_dt_frame * 60.0 * ItemGetMass(item))

	
		local	_l_thrust = Vector(0,0,DegreeToRadian(-15.0))
		_l_thrust = _l_thrust.Scale(pad.x * thrust * g_dt_frame * 60.0 * ItemGetMass(item))

		ItemApplyLinearForce(item, _h_thrust)
		ItemApplyTorque(item, _l_thrust)
		AutoAlign(item)

		if (Abs(pad.x) > 0.0)
			auto_align_timeout = g_clock
	}

	function	RotationTypeControl(item)
	{
		local	_v_thrust = ItemGetRotationMatrix(item).GetRow(1).Normalize()
		_v_thrust = _v_thrust.Scale(pad.y * thrust * ItemGetMass(item))

		local	_l_thrust = Vector(0,0,DegreeToRadian(45.0))
		_l_thrust = _l_thrust.Scale(-pad.x * thrust * ItemGetMass(item))

		ItemApplyLinearForce(item, _v_thrust)
		ItemApplyTorque(item, _l_thrust)

		if (Abs(pad.x) > 0.0)
			auto_align_timeout = g_clock
		else
			AutoAlign(item)
	}

	function	AutoAlign(item)
	{
		local	_timeout = TickToSec(g_clock - auto_align_timeout)
		if (_timeout < Sec(0.125))
			return
		
		local	_rot_z = ItemGetRotation(item).z
		local	_ang_v_z = ItemGetAngularVelocity(item).z

		_timeout = Clamp(_timeout - 0.125, 0.0, 1.0) 
		_timeout *= Clamp(Abs(RadianToDegree(_rot_z)) / 180.0,0.0,1.0)
		//_timeout = MakeTriangleWave(_timeout)
		//if (_timeout > 0.125) _timeout = 0.0
		//_timeout = Pow(_timeout, 0.125)
		_timeout = Pow(_timeout, 0.5)
		_timeout *= 180.0

		
		ItemApplyTorque(item, Vector(0,0,-_rot_z - _ang_v_z).Scale(_timeout * ItemGetMass(item)))
	}

	function	OnCollision(item, with_item)
	{
		//	Cancel auto align
		auto_align_timeout = g_clock
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		controller = GenericController()

		scene = ItemGetScene(item)
		camera = SceneFindItem(scene,"game_close_camera")
		thrust_item = ItemGetChild(item, "thrust_item")

		ItemPhysicSetAngularFactor(item, Vector(0,0,0.250))
		ItemPhysicSetLinearFactor(item,  Vector(1.0,1.0,0.0))
	}
}