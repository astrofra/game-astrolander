/*
	File: scripts/mobiles_handler.nut
	Author: Astrofra
*/

		Include("scripts/globals.nut")

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
	>
>*/
	target_RPM				=	1.0
	target_angular_vel		=	0.0
	strength				=	1.0

	/*!
		@short	OnUpdate
		Called during the scene update, each frame.
	*/

	function	OnUpdate(item)
	{
		ItemWake(item)
	}

	function	OnPhysicStep(item, dt)
	{
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
