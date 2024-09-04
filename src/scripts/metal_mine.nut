/*
	File: scripts/metal_mine.nut
	Author: Astrofra
*/

/*!
	@short	MetalMine
	@author	Astrofra
*/
class	MetalMine
{

	scene		=	0
	constraint	=	0
	ship_item	=	0
	ship_hook	=	0
	item_hook	=	0
	force_left	=	0
	force_right	=	0
	mine_item	=	0
	first_update	=	false

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
		if (!dt)
			return

		if (!first_update)
		{
			first_update = true
			ItemPhysicResetTransformation(item, ItemGetWorldPosition(ship_item) + Vector(-5.0, 0, 0), Vector(0,0,0))	
			return
		}

		//	Balance the mine target
		local	_force, _force_item, _factor

		if (ItemGetWorldPosition(item).x < ItemGetWorldPosition(ship_item).x)
			_force_item = force_left
		else
			_force_item = force_right

		_force = (ItemGetWorldPosition(_force_item) - ItemGetWorldPosition(item)).Normalize()

		_factor = ItemGetWorldPosition(item).y - ItemGetWorldPosition(ship_item).y
		_factor = Clamp(_factor, -2.0, 4.0)
		_factor = RangeAdjust(_factor, -2.0, 4.0, 0.0, 1.0)
		_factor = Pow(_factor, 2.0)

//		print("_factor = " + _factor)

		ItemApplyImpulse(item, ItemGetWorldPosition(item), _force * ItemGetMass(item) * _factor)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	function	OnSetup(item)
	{
		local	_parent, _mid_joint

		scene = ItemGetScene(item)

		first_update = false

		ItemPhysicSetLinearFactor(item, Vector(1,1,0))
		ItemPhysicSetAngularFactor(item, Vector(0,0,1))
//		SceneSetGravity(scene, g_gravity.Scale(1.0))

		force_left	=	ItemGetChild(item, "force_left")
		force_right	=	ItemGetChild(item, "force_right")

		try
		{
			_parent = ItemGetParent(item)
			ship_item = ItemGetChild(_parent, "player")
			ship_hook = ItemGetChild(_ship_item, "ship_hook")
		}
		catch(e)
		{
			print(e)
			print("MetalMine::OnSetup() Working in scene mode, instead of project.")
			ship_item = SceneFindItem(scene, "player")
			ship_hook = SceneFindItem(scene, "ship_hook")
		}

		item_hook = ItemGetChild(item, "metal_mine_hook")

		ItemPhysicResetTransformation(item, ItemGetWorldPosition(ship_item) + Vector(-5.0, 0, 0), Vector(0,0,0))

/*
		_mid_joint = ObjectGetItem(SceneAddObject(scene, "mid_joint"))
		local	_shape = ItemAddCollisionShape(_mid_joint)
		ItemSetPhysicMode(_mid_joint, PhysicModeDynamic)
		ShapeSetBox(_shape, Vector(0.1,0.1,0.1))
		ShapeSetMass(_shape, 1.0)
		ItemSetCollisionMask(_mid_joint, 0)
		ItemSetup(_mid_joint)

		SceneAddPointConstraint(scene, "ship_to_metal_mine", item, _mid_joint, ItemGetPosition(item_hook) + Vector(0,1,0), Vector(0,1,0))
		SceneAddPointConstraint(scene, "ship_to_metal_mine", _mid_joint, ship_item, ItemGetPosition(item_hook) + Vector(0,1,0), ItemGetPosition(ship_hook))
*/
	}
}
