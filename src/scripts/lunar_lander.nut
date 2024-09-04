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

	fuel				=	100
	damage				=	0

	consumption			=	2.5	//	Fuel unit per sec.
	max_speed			=	Mtrs(25.0)	//	Max. speed of the ship.
	speed_min_damage	=	Mtrs(3.0)
	speed_max_damage	=	Mtrs(25.0)
	min_damage			=	5
	max_damage			=	20

	flame_item			=	0
	smoke_emitter		=	0
	smoke_emitter_script	=	0

	hit_emitter		=	0
	hit_emitter_script	=	0
	weak_zone_item		=	0


	current_speed		=	0.0

	hit_timeout			=	0.0

	scene				=	0
	scene_script		=	0

	auto_align_timeout	=	0.0

	game_hui					=	0

	sfx_thrust_clean		=	0
	sfx_thrust_dirty		=	0
	channel_thrust_clean	=	0
	channel_thrust_dirty	=	0
	max_thrust_sfx_gain		=	1.0
	sfx_clean_dirty_ratio	=	1.0
	sfx_thrust_volume		=	0.0
	sfx_metal_col			=	0
	channel_metal_col		=	0
	sfx_metal_col_counter	=	0

	_left					=	false
	_right					=	false

	update_function			=	0

	//------------------------
	function	OnUpdate(item)
	//------------------------
	{
		if (update_function != 0)
			update_function(item)
	}

	//--------------------------------
	function	UpdatePlayerIsDead(item)
	//--------------------------------
	{
		FadeThrusters()
		HandleAudioFeedback()
		_left = false
		_right = false
	}

	//------------------------------
	function	UpdatePlayerIsAlive(item)
	//------------------------------
	{
		pad = controller.GetControllerVector()

		_left = KeyboardSeekFunction(DeviceKeyPress, KeyLeftArrow)
		_right = KeyboardSeekFunction(DeviceKeyPress, KeyRightArrow)

		if (_left || _right)
		{
			if (fuel > 0.0)
				sfx_thrust_volume = Clamp(sfx_thrust_volume + 5.0 * g_dt_frame, 0.0, 1.0)
			ConsumeFuel()
		}

		ItemWake(item)
		HandleAudioFeedback()
		CheckPlayerStats()
	}

	//-------------------------------
	function	HandleAudioFeedback()
	//-------------------------------
	{
		local	cross_fade_clean_dirty_ratio
		cross_fade_clean_dirty_ratio = Pow(sfx_clean_dirty_ratio, 0.25)
		cross_fade_clean_dirty_ratio = RangeAdjustClamped(cross_fade_clean_dirty_ratio, 0.0, 0.5, 0.0, 1.0)

		MixerChannelSetGain(g_mixer, channel_thrust_clean, cross_fade_clean_dirty_ratio * max_thrust_sfx_gain * sfx_thrust_volume)
		MixerChannelSetGain(g_mixer, channel_thrust_dirty, (1.0 - cross_fade_clean_dirty_ratio) * max_thrust_sfx_gain * sfx_thrust_volume)

		sfx_clean_dirty_ratio = Clamp(sfx_clean_dirty_ratio + 2.0 * g_dt_frame, 0.0, 1.0)
		sfx_thrust_volume = Clamp(sfx_thrust_volume - 3.5 * g_dt_frame, 0.0, 1.0)
	}

	//--------------------------------
	function	OnPhysicStep(item, dt)
	//--------------------------------
	{
		ThrustTypeControl(item)
		current_speed = ItemGetLinearVelocity(item).Len()
	}

	//---------------------------------
	function	ThrustTypeControl(item)
	//---------------------------------
	{

		local	v_thrust = Vector(0,0,0)

		local	speed_limiter = Max(ItemGetLinearVelocity(item).Len() - max_speed, 0.0)
		if (speed_limiter > 0.0)
			ItemApplyLinearImpulse(item, ItemGetLinearVelocity(item).Scale(-speed_limiter))

		if (fuel > 0.0)
		{
			if (_left && !_right)
			{
				ItemApplyLinearForce(item, ItemGetMatrix(item).GetRow(0).Normalize().Scale(thrust * 0.9 * ItemGetMass(item)))
				ItemApplyForce(item, ItemGetWorldPosition(thrust_item[0]), ItemGetMatrix(thrust_item[0]).GetRow(0).Scale(-thrust * 0.1 * ItemGetMass(item)))
				ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) + 0.35, 0.0, 1.0))
				SmokeFeedBack(flame_item[0])
			}
	
			if (!_left && _right)
			{
				ItemApplyLinearForce(item, ItemGetMatrix(item).GetRow(0).Normalize().Scale(-thrust * 0.9 * ItemGetMass(item)))
				ItemApplyForce(item, ItemGetWorldPosition(thrust_item[1]), ItemGetMatrix(thrust_item[1]).GetRow(0).Scale(-thrust * 0.1 * ItemGetMass(item)))
				ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[2]) + 1.35, 0.0, 1.0))
				SmokeFeedBack(flame_item[2])
			}
	
			if (_left && _right)
			{
				ItemApplyLinearForce(item, ItemGetMatrix(item).GetUp().Scale(thrust * ItemGetMass(item)))
				ItemSetOpacity(flame_item[1], Clamp(ItemGetOpacity(flame_item[1]) + 0.35, 0.0, 1.0))
				ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) * 0.35, 0.0, 1.0))
				ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[0]) * 0.35, 0.0, 1.0))
				SmokeFeedBack(flame_item[1])
			}
		}

		FadeThrusters()
		AutoAlign(item)
	}

	//-------------------------
	function	FadeThrusters()
	//-------------------------
	{
		if (Rand(0,100) > 70)
			ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) * 0.25, 0.0, 1.0))//			ItemActivate(flame_item[0], false)		
		if (Rand(0,100) > 70)
			ItemSetOpacity(flame_item[1], Clamp(ItemGetOpacity(flame_item[1]) * 0.25, 0.0, 1.0))//			ItemActivate(flame_item[1], false)		
		if (Rand(0,100) > 70)
			ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[2]) * 0.25, 0.0, 1.0))//			ItemActivate(flame_item[2], false)		

	}

	//-----------------------
	function	ConsumeFuel()
	//-----------------------
	{
		fuel -= consumption * g_dt_frame
		if (game_hui)
			game_hui.UpdateFuelGauge(fuel)
	}

	//----------------------------
	function	CheckPlayerStats()
	//----------------------------
	{
		if (fuel <= 0.0)
			update_function = UpdatePlayerIsDead
		if (damage >= 100.0)
			update_function = UpdatePlayerIsDead
	}

	//-------------------------------------
	function	SmokeFeedBack(_thrust_item)
	//-------------------------------------
	{
		local	_pos, _dir, _hit

		_pos = ItemGetWorldPosition(_thrust_item)
		_dir = ItemGetMatrix(_thrust_item).GetRow(0).Normalize()

		_hit = SceneCollisionRaytrace(scene, _pos, _dir, 2, CollisionTraceAll, Mtr(5.0))

		if ((_hit.hit) && (_hit.d < Mtr(3.0)))
		{
			sfx_clean_dirty_ratio = Clamp(sfx_clean_dirty_ratio - (10.0 * g_dt_frame), 0.0, 1.0)
			ItemSetPosition(smoke_emitter, _hit.p) 
			smoke_emitter_script.Emit()
		}
	}

	//---------------------------
	function	ImpactFeedBack(p)
	//---------------------------
	{
		ItemSetPosition(hit_emitter, p) 
		hit_emitter_script.Emit()

		MixerChannelStart(g_mixer, channel_metal_col, sfx_metal_col[sfx_metal_col_counter])
		sfx_metal_col_counter += Irand(1,2)
		if (sfx_metal_col_counter >= sfx_metal_col.len())
			sfx_metal_col_counter = 0
	}

	//-------------------------
	function	AutoAlign(item)
	//-------------------------
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

	//------------------------------------------------------
	function	OnCollisionEx(item, with_item, contact, dir)
	//------------------------------------------------------
	{
		//	Cancel auto align
		auto_align_timeout = g_clock + SecToTick(Sec(0.25))

		if (current_speed >= speed_min_damage)
		{
			//foreach(_hit_point in contact.p)
			ImpactFeedBack(contact.p[0])
			TakeDamage(current_speed)
		}
	}

	//-----------------------------------
	function	TakeDamage(impact_speed)
	//-----------------------------------
	{
		if (g_clock - hit_timeout < SecToTick(Sec(1.0)))
			return

		local	damage_amount = Clamp(impact_speed.tofloat(), speed_min_damage, speed_max_damage)
		damage_amount = RangeAdjust(damage_amount, speed_min_damage, speed_max_damage, min_damage, max_damage)
		hit_timeout = g_clock
		damage += damage_amount
		if (game_hui)
			game_hui.UpdateDamageGauge(damage)
		print("LunarLander::TakeDamage() : damage = " + damage_amount.tostring())
	}

	function	LoadSounds()
	{
		//	Thrusters
		sfx_thrust_clean	=	EngineLoadSound(g_engine, "audio/sfx/sfx_thrust.wav")
		sfx_thrust_dirty	=	EngineLoadSound(g_engine, "audio/sfx/sfx_thrust_dirty.wav")

		//	Collisions
		sfx_metal_col		=	[]
		for(local n = 0; n < 6; n++)
			sfx_metal_col.append(EngineLoadSound(g_engine, "audio/sfx/sfx_metal_col_" + n.tostring() + ".wav"))
	}

	function	SetupLanderSounds()
	{
		//	Thrusters
		channel_thrust_clean = MixerSoundStart(g_mixer, sfx_thrust_clean)
		MixerChannelSetGain(g_mixer, channel_thrust_clean, sfx_thrust_volume)
		MixerChannelSetLoopMode(g_mixer, channel_thrust_clean, LoopRepeat)

		channel_thrust_dirty = MixerSoundStart(g_mixer, sfx_thrust_dirty)
		MixerChannelSetGain(g_mixer, channel_thrust_dirty, sfx_thrust_volume)
		MixerChannelSetLoopMode(g_mixer, channel_thrust_dirty, LoopRepeat)

		//	Collisions
		channel_metal_col = MixerChannelLock(g_mixer)
		MixerChannelSetGain(g_mixer, channel_metal_col, 0.25)
		MixerChannelSetLoopMode(g_mixer, channel_metal_col, LoopNone)
	}

	/*!
		@short	OnSetup
		Called when the item is about to be setup.
	*/
	//-----------------------
	function	OnSetup(item)
	//-----------------------
	{
		controller = GenericController()
		pad = controller.GetControllerVector()

		scene = ItemGetScene(item)

		SceneSetGravity(scene, g_gravity);
		ItemPhysicSetAngularFactor(item, Vector(0,0,1.0))
		ItemPhysicSetLinearFactor(item,  Vector(1.0,1.0,0.0))
		ItemSetLinearDamping(item, 0.9)

		LoadSounds()

		update_function = UpdatePlayerIsDead
	}

	//---------------------------
	function	OnSetupDone(item)
	//---------------------------
	{
		try	{	game_hui = SceneGetScriptInstance(scene).game_hui	}
		catch(e)	{	game_hui = 0	}

		if (game_hui)
		{
			game_hui.UpdateDamageGauge(damage)
			game_hui.UpdateFuelGauge(fuel)
		}

		weak_zone_item = ItemGetChild(item, "weak_zone")

		thrust_item = []
		thrust_item.append(ItemGetChild(item, "thrust_item_l"))
		thrust_item.append(ItemGetChild(item, "thrust_item_r"))

		flame_item = []
		flame_item.append(ItemGetChild(item, "flame_item_l"))
		flame_item.append(ItemGetChild(item, "flame_item_m"))
		flame_item.append(ItemGetChild(item, "flame_item_r"))
		ItemSetOpacity(flame_item[0], 0.0)
		ItemSetOpacity(flame_item[1], 0.0)
		ItemSetOpacity(flame_item[2], 0.0)

		smoke_emitter = SceneFindItem(scene, "smoke_emitter")
		smoke_emitter_script = ItemGetScriptInstance(smoke_emitter)

		hit_emitter = SceneFindItem(scene, "hit_emitter")
		hit_emitter_script = ItemGetScriptInstance(hit_emitter)

		local	scene_root = SceneAddObject(scene, "scene_root")
		scene_root = ObjectGetItem(scene_root)	//	'unparent' the smoke emitter
		ItemSetParent(smoke_emitter, scene_root)
		ItemSetParent(hit_emitter, scene_root)

		SetupLanderSounds()
	}

	constructor()
	{
		//update_function = UpdateDoNothing
	}
}