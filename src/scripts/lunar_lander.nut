/*
	File: scripts/lunar_lander.nut
	Author: Astrofra
*/

Include("scripts/controller.nut")

g_gravity	<-	Vector(0.0, -4.0, 0.0)

/*!
	@short	LunarLander
	@author	Astrofra
*/
class	LunarLander
{
	controller			=	0
	pad					=	0
	thrust				=	15.0
	thrust_item			=	0
	thrust_script		=	0

	flame_item			=	0
	smoke_emitter		=	0
	smoke_emitter_script	=	0

	current_speed		=	0.0

	fuel				=	100
	damage				=	0

	hit_timeout			=	0.0

	scene				=	0
	scene_script		=	0
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
		ItemWake(item);
	}

	function	OnPhysicStep(item, dt)
	{
		ThrustTypeControl(item)
		current_speed = ItemGetLinearVelocity(item).Len()
	}

	function	UpdateCameraFromPlayerPosition(camera_item, item)
	{
		try
		{
			local	cam_pos = ItemGetWorldPosition(camera_item)
			local	player_pos = ItemGetWorldPosition(item)
			local	cam_pos_z

			cam_pos_z = cam_pos.z

			cam_pos =  cam_pos.Lerp(0.95, player_pos)		//	TODO : Frame independent code.
			cam_pos.z = cam_pos_z
			ItemSetPosition(camera_item, cam_pos)
		}
		catch (e)
		{}
	}

	function	ThrustTypeControl(item)
	{

		local	v_thrust = Vector(0,0,0),
				_left, _right

		_left = KeyboardSeekFunction(DeviceKeyPress, KeyLeftArrow)
		_right = KeyboardSeekFunction(DeviceKeyPress, KeyRightArrow)

		if (_left && !_right)
		{
			ItemApplyLinearForce(item, Vector(-0.75,0,0).Scale(-thrust * ItemGetMass(item)))
			ItemApplyForce(item, ItemGetWorldPosition(thrust_item[0]), ItemGetMatrix(thrust_item[0]).GetRow(0).Scale(-thrust * 0.25 * ItemGetMass(item)))
			ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) + 0.35, 0.0, 1.0))
			SmokeFeedBack(flame_item[0])
		}

		if (!_left && _right)
		{
			ItemApplyLinearForce(item, Vector(0.75,0,0).Scale(-thrust * ItemGetMass(item)))
			ItemApplyForce(item, ItemGetWorldPosition(thrust_item[1]), ItemGetMatrix(thrust_item[1]).GetRow(0).Scale(-thrust * 0.25 * ItemGetMass(item)))
			ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[2]) + 1.35, 0.0, 1.0))
			SmokeFeedBack(flame_item[2])
		}

		if (_left && _right)
		{
			ItemApplyLinearForce(item, Vector(0,-1,0).Scale(-thrust * ItemGetMass(item)))
			ItemSetOpacity(flame_item[1], Clamp(ItemGetOpacity(flame_item[1]) + 0.35, 0.0, 1.0))
			SmokeFeedBack(flame_item[1])
		}

		AutoAlign(item)

		if (Rand(0,100) > 70)
			ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) * 0.25, 0.0, 1.0))//			ItemActivate(flame_item[0], false)		
		if (Rand(0,100) > 70)
			ItemSetOpacity(flame_item[1], Clamp(ItemGetOpacity(flame_item[1]) * 0.25, 0.0, 1.0))//			ItemActivate(flame_item[1], false)		
		if (Rand(0,100) > 70)
			ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[2]) * 0.25, 0.0, 1.0))//			ItemActivate(flame_item[2], false)		
	}

	function	SmokeFeedBack(_thrust_item)
	{
		local	_pos, _dir, _hit

		_pos = ItemGetWorldPosition(_thrust_item)
		_dir = ItemGetMatrix(_thrust_item).GetRow(0).Normalize()

//ItemSetPosition(smoke_emitter, _pos) 

		_hit = SceneCollisionRaytrace(scene, _pos, _dir, 2, CollisionTraceAll, Mtr(5.0))
		if (_hit.hit)
			print("d = " + _hit.d)
		if ((_hit.hit) && (_hit.d < Mtr(3.0)))
		{
			ItemSetPosition(smoke_emitter, _hit.p) 
			smoke_emitter_script.Emit()
		}
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
		_timeout *= 100.0

		
		ItemApplyTorque(item, Vector(0,0,-_rot_z - _ang_v_z).Scale(_timeout * ItemGetMass(item)))
	}

	function	OnCollision(item, with_item)
	{
		//	Cancel auto align
		auto_align_timeout = g_clock + SecToTick(Sec(0.25))
		local	impact_strength
		impact_strength = (Clamp(current_speed - 2.5, 0.0, 50.0) / 10.0).tointeger().tofloat()

		if (impact_strength >= 1.0)
			TakeDamage(impact_strength)
	}

	function	TakeDamage(damage_amount)
	{
		if (g_clock - hit_timeout < SecToTick(Sec(0.1)))
			return

		damage_amount = damage_amount.tofloat()
		hit_timeout = g_clock
		damage += damage_amount

		print("LunarLander::TakeDamage() : damage = " + damage_amount.tostring())
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		controller = GenericController()
		pad = controller.GetControllerVector()

		scene = ItemGetScene(item)
		camera = SceneFindItem(scene,"game_camera")

		SceneSetGravity(scene, g_gravity);
		ItemPhysicSetAngularFactor(item, Vector(0,0,1.0))
		ItemPhysicSetLinearFactor(item,  Vector(1.0,1.0,0.0))
		ItemSetLinearDamping(item, 0.9)
	}

	function	OnSetupDone(item)
	{
		thrust_item = []
		thrust_item.append(ItemGetChild(item, "thrust_item_l"))
		thrust_item.append(ItemGetChild(item, "thrust_item_r"))
		//thrust_script = []
		//thrust_script.append(ItemGetScriptInstance(thrust_item[0]))
		//thrust_script.append(ItemGetScriptInstance(thrust_item[1]))
		flame_item = []
		flame_item.append(ItemGetChild(item, "flame_item_l"))
		flame_item.append(ItemGetChild(item, "flame_item_m"))
		flame_item.append(ItemGetChild(item, "flame_item_r"))
		ItemSetOpacity(flame_item[0], 0.0)
		ItemSetOpacity(flame_item[1], 0.0)
		ItemSetOpacity(flame_item[2], 0.0)

		smoke_emitter = SceneFindItem(scene, "smoke_emitter")
		smoke_emitter_script = ItemGetScriptInstance(smoke_emitter)
		local	scene_root = SceneAddObject(scene, "scene_root")
		scene_root = ObjectGetItem(scene_root)
		ItemSetParent(smoke_emitter, scene_root)
	}
}