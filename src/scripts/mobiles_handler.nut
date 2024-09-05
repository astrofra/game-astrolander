/*
	File: scripts/mobiles_handler.nut
	Author: Astrofra
*/

//----------------
class	MobileBase
//----------------
{
	is_culled		=	false
	prev_culled		=	false
	culling_changed	=	true

	check_every		=	0

	scene			=	0
	current_camera	=	0

	function	OnSetup(item)
	{
		is_culled 		=	false
		prev_culled		=	false
		culling_changed	=	true
		check_every		=	Irand(0,8)
	}

	function	OnSetupDone(item)
	{
		scene = ItemGetScene(item)
		current_camera = SceneGetCurrentCamera(scene)
	}

	function	OnUpdate(item)
	{
		check_every++

		if (check_every < 8)
			return

		check_every = 0

		if (CameraCullPosition(current_camera, ItemGetWorldPosition(item)) == VisibilityOutside)
			is_culled = true
		else
			is_culled = false

		if (prev_culled == is_culled)
			culling_changed = false
		else
			culling_changed = true

		prev_culled = is_culled
	}
}

//-----------------------------------
class	HomingMine extends MobileBase
//-----------------------------------
{
	low_dt_compensation		=	1.0
	mass					=	0.0
	vel						=	0
	pos						=	0
	dist					=	0

	wake_timeout			=	0.0
	alive					=	true

	scene					=	0
	mesh_body				=	0
	player_item				=	0
	emitter_item			=	0
	smoke_emitter_item		=	0

	item_collision_mask		=	0
	item_self_mask			=	0

	probe_orientation		=	0

	warning_material		=	0

	physic_step_function	=	0

	current_force			=	0
	ideal_force				=	0

	//-----------------------
	function	OnSetup(item)
	//-----------------------
	{
		base.OnSetup(item)

		print("HomingMine::OnSetup()")

		scene = ItemGetScene(item)
		emitter_item = SceneFindItemChild(scene, item, "explosion_emitter")
		smoke_emitter_item = SceneFindItemChild(scene, item, "explosion_cloud_emitter")
		mesh_body = SceneFindItemChild(scene, item, "mine_mesh")
		ItemPhysicSetLinearFactor(item, Vector(1,1,0))
		ItemPhysicSetAngularFactor(item, Vector(0,0,0.2))
		item_collision_mask = 2
		item_self_mask = 2
		mass = ItemGetMass(item)
		vel = Vector(0,0,0)
		pos = ItemGetPosition(item)
		current_force = Vector(0,0,0)
		ideal_force = Vector(0,0,0)
		probe_orientation = 0.0
		wake_timeout = g_clock
		warning_material = GeometryGetMaterialFromIndex(ItemGetGeometry(mesh_body), 1)
		SetWarningColorGreen()
		ItemSetSelfMask(item, 0)
		ItemSetCollisionMask(item, 0)
	}

	//-----------------------
	function	IdleMode(item)
	//-----------------------
	{
		if (is_culled)
			return

		ItemSetLinearDamping(item, 0.5)

		local	_force = Vector(-vel.x,-vel.y,0)
		local	_force_len = _force.Len()
		if (_force_len > 1.0)
		_force = _force.Scale(1.0 / _force_len)

		ideal_force = _force.Scale(mass * 100.0)
		ideal_force += g_gravity.Scale(mass * -1.0)
		ideal_force += (Vector(Rand(-1,1),Rand(-1,1),0).Normalize().Scale(mass * 5.0))

		current_force = current_force.Lerp(0.95, ideal_force)

		if (player_item == 0)
			return

		local _dist = dist

		if (_dist < Mtr(7.0))
		{
			if (((g_clock - wake_timeout ) * low_dt_compensation) > SecToTick(Sec(1.5)))
			{
				SetWarningColorRed()
				physic_step_function = HuntMode
				print("HomingMine::IdleMode() : going to HuntMode")
			}
			else
				SetWarningColorOrange()
		}
		else
		{
			SetWarningColorGreen()
			wake_timeout = g_clock 
		}
	}

	//-----------------------
	function	HuntMode(item)
	//-----------------------
	{
		if (player_item == 0)
			return

		if (is_culled)
			return

		ItemSetLinearDamping(item, 1.0)

		//	Search for the player
		local _dist = dist
		if (_dist > Mtr(10.0))
		{
			SetWarningColorGreen()
			wake_timeout = g_clock 
			physic_step_function = IdleMode
			return
		}

		local	_target_pos = ItemGetWorldPosition(player_item)

		local	_force = _target_pos - pos
		local	_force_len = _force.Len()
		if (_force_len > 1.0)
		_force = _force.Scale(1.0 / _force_len)

		local _dist_factor = RangeAdjust(_dist, 1.0, 5.0, 0.1, 1.0)
		_dist_factor = Clamp(_dist_factor, 0.1, 1.0)
		ideal_force = _force.Scale(mass * 10.0 * _dist_factor)
		ideal_force += g_gravity.Scale(mass * -1.0)

		//	Avoid any walls in a given range (ex : 5m)

		probe_orientation += DegreeToRadian(50.0)
		local	_probe_dir = vel.Normalize() + Vector(cos(probe_orientation), sin(probe_orientation), 0).Normalize().Scale(0.1)
		local	_hit = SceneCollisionRaytrace(scene, pos, _probe_dir, 1, CollisionTraceAll, Mtr(5.0))

		if ((_hit.hit) && (ItemGetName(_hit.item) != "player"))
			ItemApplyLinearImpulse(item, _hit.n.Normalize().Scale(vel.Len() * 0.25 * low_dt_compensation))

		current_force = current_force.Lerp(0.25, ideal_force)
/*
		local _dist_factor = RangeAdjust(_dist, 10.0, 50.0, 0.0, 1.0)
		_dist_factor = Clamp(_dist_factor, 0.0, 1.0)
		_dist_factor = Pow(_dist_factor, 2.0) * 0.25

		local	_current_impulse = current_force.Scale(low_dt_compensation * _dist_factor)
		if (_current_impulse.Len() > Mtr(5.0))
			_current_impulse = _current_impulse.Scale(_current_impulse.Len() / Mtr(5.0))

		ItemApplyLinearImpulse(item, _current_impulse)
*/
	}

	function	SetWarningColorRed()
	{		MaterialSetDiffuse(warning_material, Vector(1,0,0,1))	}

	function	SetWarningColorOrange()
	{		MaterialSetDiffuse(warning_material, Vector(1,0.5,0,1))	}

	function	SetWarningColorGreen()
	{		MaterialSetDiffuse(warning_material, Vector(0.1,1,0,1))	}

	function	SetWarningColorBlue()
	{		MaterialSetDiffuse(warning_material, Vector(0.0,0.8,1,1))	}

	//---------------------------------
	function	OnLogicUpdate(item, dt)
	//---------------------------------
	{
		if (is_culled)
			return

		if (player_item != 0)
			dist = pos.Dist(ItemGetWorldPosition(player_item))
	}

	//-----------------------
	function	OnUpdate(item)
	//-----------------------
	{
		base.OnUpdate(item)

		if (culling_changed)
		{
			if (is_culled)
			{
				ItemSetPhysicMode(item, PhysicModeNone)
				ItemSetSelfMask(item, 0)
				ItemSetCollisionMask(item, 0)
				physic_step_function = IdleMode
				SetWarningColorGreen()
			}
			else
			{
				ItemSetPhysicMode(item, PhysicModeDynamic)
				ItemSetSelfMask(item, item_self_mask)
				ItemSetCollisionMask(item, item_collision_mask)
				ItemSetup(item)
				ItemWake(item)
			}
		}

		if (!is_culled)
			ItemWake(item)

		if (player_item == 0)
		{
			player_item = LegacySceneFindItem(scene, "player")

			if (player_item == NullItem)
				player_item = 0
			else
				print("HomingMine::OnUpdate() found 'player' item.")
		}
	}


	//---------------------------
	function	OnSetupDone(item)
	//---------------------------
	{
		base.OnSetupDone(item)
		physic_step_function = IdleMode
	}

	//--------------------------------
	function	OnPhysicStep(item, dt)
	//--------------------------------
	{
		low_dt_compensation = Clamp(1.0 / (60.0 * g_dt_frame), 0.0, 1.0)
		vel = ItemGetLinearVelocity(item)
		pos = ItemGetWorldPosition(item)

		physic_step_function(item)

		if (player_item == 0)
			return

		ItemApplyLinearForce(item, current_force.Scale(low_dt_compensation))
	}

	//--------------------------------------
	function	OnCollision(item, with_item)
	//--------------------------------------
	{
		if ((ItemGetName(with_item) == "player") && alive)
		{
			alive = false
			physic_step_function = Explode
		}
	}

	//-----------------------
	function	Explode(item)
	//-----------------------
	{
		ItemGetScriptInstance(player_item).TakeLaserDamage()
		local	_ejection = ItemGetWorldPosition(player_item) - pos
		_ejection = _ejection.Normalize().Scale(5.0)
		ItemApplyLinearImpulse(player_item, _ejection)
		for(local n = 0; n < 15; n++)
			ItemGetScriptInstance(emitter_item).Emit()
		physic_step_function = EmitCloud
	}

	//-----------------------
	function	EmitCloud(item)
	//-----------------------
	{
		for(local n = 0; n < 20; n++)
			ItemGetScriptInstance(smoke_emitter_item).Emit()
		physic_step_function = SelfDelete
	}

	//-----------------------
	function	SelfDelete(item)
	//-----------------------
	{

		if (mesh_body != 0)
		{
			SceneDeleteItem(scene,mesh_body)
			mesh_body = 0
			g_audio_handler.PlaySound("explode")
		}

		if ((emitter_item != 0) && (ItemGetScriptInstance(emitter_item).IsEmitDone()))
		{
			SceneDeleteItem(scene, emitter_item)
			emitter_item = 0
		}

		if ((smoke_emitter_item != 0) && (ItemGetScriptInstance(smoke_emitter_item).IsEmitDone()))
		{
			SceneDeleteItem(scene, smoke_emitter_item)
			smoke_emitter_item = 0
		}

		if ((smoke_emitter_item == 0) && (emitter_item == 0))
			SceneDeleteItem(scene, item)
	}
}

//-----------------------------
class	SpecialArtifactRotation
//-----------------------------
{

	angle			=	0.0
	rpm				=	-0.25
	padding			=	30.0

	function	OnSetup(item)
	{
		angle	=	0.0
	}

	function	OnUpdate(item)
	{
		angle += g_dt_frame * rpm * 360.0
		local	mapped_angle = 0.0

		for(local dt = 0.0; dt < padding; dt += 1.0)
			mapped_angle += Clamp(RangeAdjust(modAngle(angle), 180.0 - padding - dt, 180.0 + padding + dt, 0.0, 360.0),  0.0, 360.0)

		mapped_angle /= padding

		ItemSetRotation(item, Vector(0,0,DegreeToRadian(mapped_angle)))
	}

}

class	SimpleRotation
{
/*<
	<Parameter =
		<rpm = <Name = "RPM"> <Type = "float"> <Default = 0.5>>
	>
	<Parameter =
		<axis_x = <Name = "Axis X"> <Type = "bool"> <Default = 0>>
	>
	<Parameter =
		<axis_y = <Name = "Axis Y"> <Type = "bool"> <Default = 0>>
	>
	<Parameter =
		<axis_z = <Name = "Axis Z"> <Type = "bool"> <Default = 1>>
	>
>*/

	rpm		=	0.5
	axis_x	=	false
	axis_y	=	false
	axis_z	=	true

	angle	=	0.0

	function	OnSetup(item)
	{
		angle	=	Rand(0.0,180.0)
	}

	function	OnUpdate(item)
	{
		angle += g_dt_frame * rpm * 360.0
		local	r = Vector(0,0,0)
		if (axis_x) r.x = DegreeToRadian(angle)
		if (axis_y) r.y = DegreeToRadian(angle)
		if (axis_z) r.z = DegreeToRadian(angle)

		ItemSetRotation(item, r)
	}
	
}

class	MeshSelectBasedOnPlatform
{

	scene				=	0
	parent_item			=	0
	mobile_asset_item	=	0
	pc_asset_item		=	0

	function	OnSetup(item)
	{
		scene = ItemGetScene(item)
		parent_item = ItemGetParent(item)
		mobile_asset_item = item

		try
		{
			pc_asset_item = ItemGetChild(parent_item, ItemGetName(mobile_asset_item) + "_pc")
		}
		catch(e)
		{
			print("MeshSelectBasedOnPlatform::OnSetup() " + e)
			pc_asset_item = SceneFindItem(scene, ItemGetName(mobile_asset_item) + "_pc")	
		}

		try
		{
			if (IsTouchPlatform())
				SceneDeleteItem(scene, pc_asset_item)
			else
				SceneDeleteItem(scene, mobile_asset_item)
		}
		catch (e)
		{
			print("A RIEN VU")
		}
	}
}

//-----------------------
class	MobileDeadlySlime
//-----------------------
{
	bubble_spawn_0_pos	=	0
	bubble_spawn_1_pos	=	0

	emitter_item		=	0
	emitter_script		=	0

	function	OnSetupDone(item)
	{
		emitter_item = ItemGetChild(item, "deadzone_bubble_emitter")
		emitter_script = ItemGetScriptInstance(emitter_item)
		bubble_spawn_0_pos = ItemGetPosition(ItemGetChild(item, "bubble_spawn_0"))
		bubble_spawn_1_pos = ItemGetPosition(ItemGetChild(item, "bubble_spawn_1"))
	}

	function	OnUpdate(item)
	{
		local	_pos = bubble_spawn_0_pos.Lerp(Rand(0.0,1.0), bubble_spawn_1_pos)
		ItemSetPosition(emitter_item, _pos)
		emitter_script.Emit()
	}
}

//--------------------
class	MobileLazerGun
//--------------------
{
	scene				=	0
	parent				=	0
	beam_item			=	0

	player_body			=	0
	player_script		=	0

	min_angle			=	-45.0
	max_angle			=	45.0

	direction			=	1.0

	beam_start			=	0
	beam_dir			=	0

	amplitude			=	1.0
	angle				=	0.0
	angular_speed		=	15.0

	lazer_hit_emitter	=	0
	lazer_hit_script	=	0

	function	OnSetup(item)
	{
		scene = ItemGetScene(item)
		beam_item = ItemGetChild(item, "Beam")
		beam_start = ItemGetChild(beam_item, "beam_start")
		beam_dir = ItemGetChild(beam_item, "beam_dir")

		try
		{
			parent = ItemGetParent(item)
			lazer_hit_emitter = ItemGetChild(parent, "lazer_hit_emitter")
			ItemSetParent(lazer_hit_emitter, NullItem)
		}
		catch(e)
		{
			lazer_hit_emitter = SceneFindItem(scene, "lazer_hit_emitter")
		}

		min_angle *= 1.2
		max_angle *= 1.2
	}

	function	OnSetupDone(item)
	{
		lazer_hit_script = ItemGetScriptInstance(lazer_hit_emitter)
		player_body	= SceneFindItem(scene, "player")
		player_script = ItemGetScriptInstance(player_body)
	}

	function	OnUpdate(item)
	{
		//	Gun
		angle += g_dt_frame * angular_speed * direction
		if (angle > max_angle)
		{
			angle = max_angle
			direction = -1.0
		}
		else
		{
			if (angle < min_angle)
			{
				angle = min_angle
				direction = 1.0
			}
		}

		local	_clamped_angle
		_clamped_angle = Clamp(angle, min_angle * 0.8, max_angle * 0.8) 
		ItemSetRotation(item, Vector(0,0,DegreeToRadian(_clamped_angle)))

		//	Beam
		local	_start, _dir, _hit, _scale
		_start = ItemGetWorldPosition(beam_start)
		_dir = (ItemGetWorldPosition(beam_dir) - _start).Normalize()

		_hit = SceneCollisionRaytrace(scene, _start, _dir, 3, CollisionTraceAll, Mtr(50.0))

		if (_hit.hit)
		{
			local	_dist = _hit.d + Mtr(1.0)
			_scale = Vector(_dist / Mtr(10.0), 1.0, 1.0)

			ItemSetPosition(lazer_hit_emitter, _hit.p)
			lazer_hit_script.Emit()

			//	Laser will block the player & hurt him
			local	_item_hit = _hit.item
			if (ItemGetName(_item_hit) == "player")
			{
				//	Hurt player
				if (ProbabilityOccurence(30.0))
					player_script.TakeLaserDamage()
				
				//	Evaluate repulsion direction
				local	_rep_dir = ItemGetWorldPosition(player_body) - _hit.p
				_rep_dir = _rep_dir.Normalize()
				ItemApplyForce(player_body, _hit.p, _rep_dir.Scale(ItemGetMass(player_body) * 25.0 * player_script.low_dt_compensation))
//				ItemApplyImpulse(player_body, _hit.p, _rep_dir.Scale(Mtrs(1.0)))
			}
		}
		else
			_scale = Vector(1,1,1)
		
		ItemSetScale(beam_item, _scale)
	
	}
}

//--------------------------------------------
class	SeaPlantOscillation extends MobileBase
//--------------------------------------------
{
/*<
	<Parameter =
		<freq = <Name = "Frequency"> <Type = "float"> <Default = 1.0>>
	>
	<Parameter =
		<amplitude = <Name = "Amplitude"> <Type = "float"> <Default = 1.0>>
	>
>*/
		amplitude	=	1.0
		angle		=	0.0
		phase		=	0.0
		freq		=	1.0
		item_list	=	0
		item_scale	=	0

		function	OnSetup(item)
		{
			base.OnSetup(item)

			item_scale = []
			item_list = ItemGetChildList(item)
			foreach(_item in item_list)
				item_scale.append(ItemGetScale(_item))
			
			phase		=	DegreeToRadian(Rand(0, 90) + 15.0)
			freq *= Rand(0.95, 1.05)
		}

		function	OnSetupDone(item)
		{
			base.OnSetupDone(item)
		}

		function	OnUpdate(item)
		{
			base.OnUpdate(item)

			if (is_culled)
				return

			angle += g_dt_frame * freq * DegreeToRadian(360.0)

			foreach(_i, _item in item_list)
			{
				local	_scale
				_scale = item_scale[_i] + Vector(sin(angle + (phase * _i)) * 0.1 * amplitude, 0, cos(angle + (phase * _i)) * 0.025 * amplitude)
				ItemSetScale(_item, _scale)
			}
		}

}

//--------------------
class	MobileElevator
//--------------------
{
/*<
	<Parameter =
		<speed = <Name = "Speed"> <Type = "float"> <Default = 1.0>>
	>
>*/
		speed 				=	Mtrs(1.0)
		course_height		=	Mtr(5.0)
		pos_start			=	0
		pos					=	0
		scene				=	0
		elevator_trigger	=	0

		player_script		=	0
		player_body			=	0

		constraints			=	0
		constraints_created	= false
		constraints_enabled	= false
		player_is_in		=	false
		constraints_timeout	=	0

		enabled			=	false
		going_up		=	true

		function	CreateConstraints(item)
		{
			print("MobileElevator::CreateConstraints(item)")
			constraints = []
			constraints.append(SceneAddPointConstraint(scene, "const0", player_body, item, Vector(0, -1.5, 0), Vector(0, 0.75, 0)))
			constraints.append(SceneAddPointConstraint(scene, "const1", player_body, item, Vector(0, 3, 0), Vector(0, 5.5, 0)))
			constraints_created	= true
			constraints_enabled = true
		}

		function	DisableConstraints(item)
		{
			ConstraintEnable(constraints[0], false)
			ConstraintEnable(constraints[1], false)
			constraints_enabled = false
		}

		function	EnableConstraints(item)
		{
			ConstraintEnable(constraints[0], true)
			ConstraintEnable(constraints[1], true)
			constraints_enabled = true
		}

		function	OnSetup(item)
		{
			pos_start = ItemGetPosition(item) //ItemGetWorldPosition(item)

			scene = ItemGetScene(item)
			elevator_trigger = ItemCastToTrigger(ItemGetChild(item, "elevator_trigger"))

			//	Get height course if possible
			local	_parent = ItemGetParent(item)
			if (ObjectIsValid(_parent))
			{
				_parent = ItemGetChild(_parent, "max_position")
				if (ObjectIsValid(_parent))
					course_height = ItemGetPosition(_parent).y - pos_start.y
			}

			pos = pos_start
			going_up = true
			constraints_created	= false
			constraints_enabled	= false
			constraints_timeout	=	g_clock
			player_is_in	=	false
		}

		function	OnUpdate(item)
		{
			ItemSetPosition(item, pos)
			ItemSetPhysicPosition(item, pos)

			if (player_body == 0)
			{
				try	//	So that the script can work outside a level
				{
					player_script = SceneGetScriptInstance(scene).player_script
					player_body = player_script.body
				}
				catch(e)
				{
					player_body = 0
					enabled = true
				}
			}
			else
			{
				if (TriggerTestItem(elevator_trigger, player_body))
				{
					player_is_in = true
					enabled = true					
				}
				else
					player_is_in = false
					
				if (!constraints_created)
				{
					CreateConstraints(item)
					DisableConstraints(item)
				}
				else
				{
					if ((g_clock - constraints_timeout) > SecToTick(Sec(0.25)))
					{
						if (player_is_in)
						{
							if (!constraints_enabled)
							{
								EnableConstraints(item)
								constraints_timeout = g_clock
							}
						}

						if (player_script.thrusters_active)
						{
							if (constraints_enabled)
							{
								DisableConstraints(item)
								constraints_timeout = g_clock
							}
						}
					}
				}
			}				

			if (!enabled)
				return

			local	_vel = Vector(0,1,0)
			_vel = _vel.Scale(g_dt_frame * (going_up?1.0:-1.0) * speed)

			pos += _vel

			if ((pos.y - pos_start.y) >= course_height)
			{
				pos.y =  pos_start.y + course_height
				going_up = false
			}
			else
			{
				if (pos.y < pos_start.y)
				{
					pos.y = pos_start.y
					going_up = true
				}
			}
		}
}

//----------------------------------------
class	MobileJawGate	extends	MobileBase
//----------------------------------------
{
/*<
	<Parameter =
		<is_gate_top = <Name = "Is Gate Top"> <Type = "bool"> <Default = 0>>
		<strength = <Name = "Strength"> <Type = "float"> <Default = 10.0>>
	>
>*/
	scene					=	0
	is_gate_top				=	false
	dir						=	0
	open					=	false
	pos_closed				=	0
	strength				=	10.0

	trigger_item			=	0
	player_item				=	0

	item_collision_mask		=	0
	item_self_mask			=	0


	timer_table				=	0

	//--------------------------------------------------
	//	Timer generic routine
	//--------------------------------------------------
	function	WaitForTimer(timer_name, timer_duration)
	//--------------------------------------------------
	{
		//	Does this timer already exist?
		if (!timer_table.rawin(timer_name))
			timer_table.rawset(timer_name, g_clock)
		else
		{
			if (g_clock - timer_table[timer_name] >= SecToTick(timer_duration))
				return false
		}
		return true
	}

	//--------------------------------
	function	ResetTimer(timer_name)
	//--------------------------------
	{
		timer_table.rawdelete(timer_name)
	}

	//-----------------------
	function	OnSetup(item)
	//-----------------------
	{
		base.OnSetup(item)

		print("MobileJawGate::OnSetup(" + ItemGetName(item) + ")")
		scene = ItemGetScene(item)
		timer_table = {}
		local	_root
		_root = ItemGetParent(item)
		if (!ObjectIsValid(_root))
			_root = item
		dir = ItemGetMatrix(_root).GetUp().Normalize()
		dir = Vector(Abs(dir.x), Abs(dir.y), Abs(dir.z))
		dir = Vector(dir.x * dir.x, dir.y * dir.y, dir.z * dir.z)
		dir.Print("Gate Direction")
		pos_closed = ItemGetPosition(item)

		item_collision_mask = 2
		item_self_mask = 2
	}

	function	OnSetupDone(item)
	{
		base.OnSetupDone(item)
	}

	//-----------------------
	function	OnUpdate(item)
	//-----------------------
	{
		base.OnUpdate(item)

		if (culling_changed)
		{
			if (is_culled)
			{
				//ItemSetPhysicMode(item, PhysicModeNone)
				ItemSetSelfMask(item, 0)
				ItemSetCollisionMask(item, 0)
			}
			else
			{
				//ItemSetPhysicMode(item, PhysicModeKinematic)
				ItemSetSelfMask(item, item_self_mask)
				ItemSetCollisionMask(item, item_collision_mask)
			}
		}

		if (!WaitForTimer("JawGateOpen", Sec(4.0)))
		{
			ResetTimer("JawGateOpen")
			open = !open
		}

		local	_pos = ItemGetPosition(item)
		if (open)
			_pos = _pos.Lerp(0.95, pos_closed + Vector(0,3 * (is_gate_top?1.0:-1.0),0))
		else
			_pos = _pos.Lerp(0.95, pos_closed)

		ItemSetPosition(item, _pos)
	}

	function	TestCollisionWithPlayer(item)
	{
		if (TriggerTestItem(trigger_item, player_item))
		{
		}
	}
}

/*!
	@short	MobileRotary
	@author	Astrofra
*/
//------------------
class	MobileRotary	extends MobileBase
//------------------
{
/*<
	<Parameter =
		<target_RPM = <Name = "Target RPM"> <Type = "float"> <Default = 1.0>>
		<strength = <Name = "Strength"> <Type = "float"> <Default = 1.0>>
		<is_physic = <Name = "Is Physic"> <Type = "bool"> <Default = 1>>
	>
>*/
	target_RPM				=	1.0
	target_angular_vel		=	0.0
	strength				=	1.0
	is_physic				=	true
	post_collision_brake	=	0.0

	item_collision_mask		=	0
	item_self_mask			=	0

	low_dt_compensation		=	1.0

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/

	function	OnUpdate(item)
	{
		base.OnUpdate(item)

		post_collision_brake -= (g_dt_frame * 0.25)
		post_collision_brake = Clamp(post_collision_brake, 0.0, 1.0)

			if (culling_changed)
			{
				if (is_culled)
				{
					//ItemSetPhysicMode(item, PhysicModeNone)
					ItemSetSelfMask(item, 0)
					ItemSetCollisionMask(item, 0)
				}
				else
				{
					//ItemSetPhysicMode(item, PhysicModeKinematic)
					ItemSetSelfMask(item, item_self_mask)
					ItemSetCollisionMask(item, item_collision_mask)
				}
			}


		if (is_physic)
			ItemWake(item)
		else
		{
			local	_rot = ItemGetRotation(item)
			_rot.z += target_RPM * g_dt_frame * PI * (1.0 - post_collision_brake)
			ItemSetRotation(item, _rot)
		}
	}

	function	OnPhysicStep(item, dt)
	{
		if (!is_physic)
			return

		low_dt_compensation = Clamp(1.0 / (60.0 * g_dt_frame), 0.0, 1.0)

		local	_angular_vel = ItemGetAngularVelocity(item).z
		local	_torque	= Vector(0,0,target_angular_vel - _angular_vel)
		_torque = _torque.Scale(low_dt_compensation * strength * ItemGetMass(item) * (1.0 - post_collision_brake))
		ItemApplyTorque(item, _torque)
	}

	function	OnCollision(item, with_item)
	{
		post_collision_brake += (g_dt_frame * 0.25)
		post_collision_brake = Clamp(post_collision_brake, 0.0, 1.0)
	}

	function	OnSetupDone(item)
	{
		base.OnSetupDone(item)
	}

	function	OnSetup(item)
	{
		base.OnSetup(item)

		post_collision_brake	=	0.0
		item_collision_mask = 1
		item_self_mask = 2

		if (is_physic)
			ItemSetPhysicMode(item, PhysicModeDynamic)
		else
			ItemSetPhysicMode(item, PhysicModeKinematic)

		ItemPhysicSetLinearFactor(item, Vector(0,0,0))
		ItemPhysicSetAngularFactor(item, Vector(0,0,1))
		target_angular_vel = DegreeToRadian(target_RPM * 360.0)
	}
}
