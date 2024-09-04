/*
	File: scripts/mobiles_handler.nut
	Author: Astrofra
*/

		Include("scripts/globals.nut")

class	SeaPlantOscillation
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
			item_scale = []
			item_list = ItemGetChildList(item)
			foreach(_item in item_list)
				item_scale.append(ItemGetScale(_item))
			
			phase		=	DegreeToRadian(Rand(0, 90) + 15.0)
			freq *= Rand(0.95, 1.05)
		}

		function	OnUpdate(item)
		{
			angle += g_dt_frame * freq * DegreeToRadian(360.0)

			foreach(_i, _item in item_list)
			{
				local	_scale
				_scale = item_scale[_i] + Vector(sin(angle + (phase * _i)) * 0.1 * amplitude, 0, cos(angle + (phase * _i)) * 0.025 * amplitude)
				ItemSetScale(_item, _scale)
			}
		}

}

class	MobileElevator
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

class	MobileJawGate	//extends	SceneWithThreadHandler
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

		SceneSetGravity(scene, g_gravity);
		ItemPhysicSetLinearFactor(item, dir)
		ItemPhysicSetAngularFactor(item, Vector(0,0,0))
	}

	//-----------------------
	function	OnUpdate(item)
	//-----------------------
	{
		if (!WaitForTimer("JawGateOpen", Sec(4.0)))
		{
			ResetTimer("JawGateOpen")
			open = !open
		}
	}

	//--------------------------------
	function	OnPhysicStep(item, dt)
	//--------------------------------
	{
		ItemApplyLinearForce(item, dir.Scale((open?1.0:-1.0) * (is_gate_top?1.0:-1.0) * ItemGetMass(item) * strength))
		ItemApplyLinearForce(item, g_gravity.Scale(-1.0 * ItemGetMass(item)))
	}

}

/*!
	@short	MobileRotary
	@author	Astrofra
*/
class	MobileRotary
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

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/

	function	OnUpdate(item)
	{
		if (is_physic)
		{
			ItemWake(item)
			return
		}

		local	_rot = ItemGetRotation(item)
		_rot.z += target_RPM * g_dt_frame
		ItemSetRotation(item, _rot)
	}

	function	OnPhysicStep(item, dt)
	{
		if (!is_physic)
			return

		local	_angular_vel = ItemGetAngularVelocity(item).z
		local	_torque	= Vector(0,0,target_angular_vel - _angular_vel)
		_torque = _torque.Scale(strength * ItemGetMass(item))
		ItemApplyTorque(item, _torque)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		ItemPhysicSetLinearFactor(item, Vector(0,0,0))
		ItemPhysicSetAngularFactor(item, Vector(0,0,1))
		target_angular_vel = DegreeToRadian(target_RPM * 360.0)
	}
}
