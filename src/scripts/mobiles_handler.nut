/*
	File: scripts/mobiles_handler.nut
	Author: Astrofra
*/

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
