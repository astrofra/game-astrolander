/*
	File: scripts/lunar_lander.nut
	Author: Astrofra
*/

	Include("scripts/globals.nut")
	Include("scripts/utils.nut")

/*!
	@short	LunarLander
	@author	Astrofra
*/
class	LunarLander
{
	body				=	0
	mesh_body			=	0
	mesh_wounded		=	0
	thrust				=	15.0
	thrust_item			=	0
	thrust_script		=	0

	fuel				=	100
	damage				=	0

	thrusters_active	=	false
	consumption			=	2.5			//	Fuel unit per sec.
	max_speed			=	Mtrs(25.0)	//	Max. speed of the ship.
	speed_min_damage	=	Mtrs(5.0)
	speed_max_damage	=	Mtrs(25.0)
	min_damage			=	10
	max_damage			=	20
	shield_enabled		=	false

	flame_item			=	0
	smoke_emitter		=	0
	smoke_emitter_script	=	0

	shield_item			=	0
	shield_col_item		=	0

	hit_emitter			=	0
	hit_emitter_script	=	0
	weak_zone_item		=	0


	current_velocity	=	0
	current_speed		=	0.0

	hit_timeout			=	0.0

	scene				=	0
	scene_script		=	0

	auto_align_timeout	=	0.0

	game_ui					=	0

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

	_c						=	0
	_t						=	0
	_prev_c					=	0

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
		if	(g_platform == "Android")
		{
			_left = _right = false
			for	(local n = 0; n < 4; ++n)
			{
				local	touch_device =	GetInputDevice("touch" + n)
				if	(DeviceIsKeyDown(touch_device, KeyButton0))
					if	(DeviceInputValue(touch_device, DeviceAxisX) > 0.5)
						_right = true
					else
						_left = true
			}
		}
		else
		{
			_left = DeviceIsKeyDown(g_device, KeyLeftArrow)
			_right = DeviceIsKeyDown(g_device, KeyRightArrow)
		}

		if (!g_reversed_controls)
		{	local tmp = _right; _right = _left; _left = tmp;	}

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
		//	CountThePhysicSteps()
		if (!dt)
		{
			print("Physic Step skipped")
			return
		}

		local	_vel = ItemGetLinearVelocity(item)
		current_velocity = _vel.Normalize()
		current_speed = _vel.Len()
		
		ThrustTypeControl(item)
	}

	//-------------------------------
	function	CountThePhysicSteps()
	//-------------------------------
	{
		if (g_clock - _t > SecToTick(Sec(1.0)))
		{
			if (_c != _prev_c)
				print("Physic Steps during the last second = " + _c)
			_t = g_clock
			_prev_c = _c
			_c = 0
		}

		_c++
	}

	//---------------------------------
	function	ThrustTypeControl(item)
	//---------------------------------
	{

		local	v_thrust = Vector(0,0,0)

		local	speed_limiter = Max(ItemGetLinearVelocity(item).Len() - max_speed, 0.0)
		if (speed_limiter > 0.0)
			ItemApplyLinearImpulse(item, ItemGetLinearVelocity(item).Scale(-speed_limiter))

		thrusters_active	=	false

		if (fuel > 0.0)
		{
			if (_left && !_right)
			{
				ItemApplyLinearForce(item, ItemGetMatrix(item).GetRow(0).Normalize().Scale(thrust * 0.9 * ItemGetMass(item) / g_clock_scale))
				ItemApplyForce(item, ItemGetWorldPosition(thrust_item[0]), ItemGetMatrix(thrust_item[0]).GetRow(0).Scale(-thrust * 0.1 * ItemGetMass(item) / g_clock_scale))
				ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) + 0.35, 0.0, 1.0))
				SmokeFeedBack(flame_item[0])
				thrusters_active = true
			}
	
			if (!_left && _right)
			{
				ItemApplyLinearForce(item, ItemGetMatrix(item).GetRow(0).Normalize().Scale(-thrust * 0.9 * ItemGetMass(item) / g_clock_scale))
				ItemApplyForce(item, ItemGetWorldPosition(thrust_item[1]), ItemGetMatrix(thrust_item[1]).GetRow(0).Scale(-thrust * 0.1 * ItemGetMass(item) / g_clock_scale))
				ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[2]) + 1.35, 0.0, 1.0))
				SmokeFeedBack(flame_item[2])
				thrusters_active = true
			}
	
			if (_left && _right)
			{
				ItemApplyLinearForce(item, ItemGetMatrix(item).GetUp().Scale(thrust * ItemGetMass(item) / g_clock_scale))
				ItemSetOpacity(flame_item[1], Clamp(ItemGetOpacity(flame_item[1]) + 0.35, 0.0, 1.0))
				ItemSetOpacity(flame_item[0], Clamp(ItemGetOpacity(flame_item[0]) * 0.35, 0.0, 1.0))
				ItemSetOpacity(flame_item[2], Clamp(ItemGetOpacity(flame_item[0]) * 0.35, 0.0, 1.0))
				SmokeFeedBack(flame_item[1])
				thrusters_active = true
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
		fuel -= consumption * (g_dt_frame / g_clock_scale)
		if (game_ui)
			game_ui.UpdateFuelGauge(fuel)
	}

	//------------------
	function	Refuel()
	//------------------
	{
		fuel = 100.0
		if (game_ui)
			game_ui.UpdateFuelGauge(fuel)
	}

	//------------------
	function	Heal()
	//------------------
	{
		damage = 0.0
		if (game_ui)
			game_ui.UpdateDamageGauge(damage)
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
		local	_pos, _dir, _hit,
				_feedback_distance

		_feedback_distance = Mtr(5.0)

		_pos = ItemGetWorldPosition(_thrust_item)
		_dir = ItemGetMatrix(_thrust_item).GetRow(0).Normalize()

		_hit = SceneCollisionRaytrace(scene, _pos, _dir, 2, CollisionTraceAll, Mtr(_feedback_distance * 1.1))

		if ((_hit.hit) && (_hit.d < Mtr(_feedback_distance)))
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
		local	_align, _speed
		
		local	_rot_z = ItemGetRotation(item).z
		local	_ang_v_z = ItemGetAngularVelocity(item).z

		_align = Clamp(Abs(RadianToDegree(_rot_z)) / 180.0,0.0,1.0)
		_align *= 250.0

		_speed = ItemGetLinearVelocity(item).Len()
		_speed = RangeAdjust(_speed, 0.25, 0.5, 0.0, 1.0)
		_speed = Clamp(_speed, 0.0, 1.0)
		_align *= _speed

		ItemApplyTorque(item, Vector(0,0,-_rot_z - _ang_v_z).Scale(_align * ItemGetMass(item)))
	}

	//------------------------------------------------------
	function	OnCollisionEx(item, with_item, contact, dir)
	//------------------------------------------------------
	{
		if (current_speed >= speed_min_damage)
		{
			if (!shield_enabled)
			{
//				print("Col. ->")
//				contact.n[0].Print("OnCollisionEx() n")
//				current_velocity.Print("current_velocity")
				local	k_damage = Max(-contact.n[0].Dot(current_velocity), 0.0)
//				print("k_damage = " + k_damage)
				TakeDamage(current_speed, k_damage)
				foreach(_p in contact.p)
					ImpactFeedBack(_p)
			}
		}
	}

	//-----------------------------------
	function	TakeDamage(impact_speed, angle_incidence = 1.0)
	//-----------------------------------
	{
		//print("LunarLander::TakeDamage() : hit_timeout           = " + hit_timeout)
		//print("LunarLander::TakeDamage() : g_clock - hit_timeout = " + TickToSec(g_clock - hit_timeout))
		if (g_clock - hit_timeout < SecToTick(Sec(1.0)))
			return

		local	damage_amount = Clamp(impact_speed.tofloat(), speed_min_damage, speed_max_damage)
		damage_amount = RangeAdjust(damage_amount, speed_min_damage, speed_max_damage, min_damage, max_damage)
		damage_amount = damage_amount * angle_incidence
		if (damage_amount > 0.0)
		{
			print("LunarLander::TakeDamage() : impact_speed  = " + impact_speed)
			BodyImpactFeedback()
			hit_timeout = g_clock
			damage += damage_amount
			if (game_ui)
				game_ui.UpdateDamageGauge(damage)
			print("LunarLander::TakeDamage() : damage = " + damage_amount.tostring())
		}
	}

	//------------------------------
	function	BodyImpactFeedback()
	//------------------------------
	{
		ItemSetCommandList(mesh_body, "toscale 0,0,0,0; nop 0.1; toscale 0,1,1,1;")
		ItemSetCommandList(mesh_wounded, "toscale 0,1,1,1; nop 0.1; toscale 0,0,0,0;")
	}

	//----------------------
	function	LoadSounds()
	//----------------------
	{
		//	Thrusters
		sfx_thrust_clean	=	EngineLoadSound(g_engine, "audio/sfx/sfx_thrust.wav")
		sfx_thrust_dirty	=	EngineLoadSound(g_engine, "audio/sfx/sfx_thrust_dirty.wav")

		//	Collisions
		sfx_metal_col		=	[]
		for(local n = 0; n < 6; n++)
			sfx_metal_col.append(EngineLoadSound(g_engine, "audio/sfx/sfx_metal_col_" + n.tostring() + ".wav"))
	}

	//-----------------------------
	function	SetupLanderSounds()
	//-----------------------------
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
		print("LunarLander::OnSetup()")

		scene = ItemGetScene(item)
		body = item
		mesh_body = ItemGetChild(item, "pod_body_mesh")
		mesh_wounded = ItemGetChild(item, "pod_body_wounded")
		ItemSetScale(mesh_body, Vector(1,1,1))
		ItemSetScale(mesh_wounded, Vector(0,0,0))

		SceneSetGravity(scene, g_gravity.Scale(1.0 / g_clock_scale));
		ItemPhysicSetAngularFactor(item, Vector(0,0,1.0))
		ItemPhysicSetLinearFactor(item,  Vector(1.0,1.0,0.0))
		ItemSetLinearDamping(item, 0.9)
		current_velocity = Vector(0,0,0)
		thrusters_active	=	false

		LoadSounds()

		update_function = UpdatePlayerIsDead

		SceneSetPhysicFrequency(scene, 60.0)
		_t = g_clock
	}

	//---------------------------
	function	OnSetupDone(item)
	//---------------------------
	{
		print("LunarLander::OnSetupDone()")

		try	{	game_ui = SceneGetScriptInstance(scene).game_ui	}
		catch(e)	{	game_ui = 0	}

		if (game_ui)
		{
			game_ui.UpdateDamageGauge(damage)
			game_ui.UpdateFuelGauge(fuel)
		}

		weak_zone_item = ItemGetChild(item, "weak_zone")
		hit_timeout = g_clock

		thrust_item = []
		thrust_item.append(ItemGetChild(item, "thrust_item_l"))
		thrust_item.append(ItemGetChild(item, "thrust_item_r"))

		shield_item = ItemGetChild(item, "shield_mesh")
		shield_col_item = ItemGetChild(ItemGetParent(item), "shield_col")
		DisableShield()

		flame_item = []
		flame_item.append(ItemGetChild(item, "flame_item_l"))
		flame_item.append(ItemGetChild(item, "flame_item_m"))
		flame_item.append(ItemGetChild(item, "flame_item_r"))
		ItemSetOpacity(flame_item[0], 0.0)
		ItemSetOpacity(flame_item[1], 0.0)
		ItemSetOpacity(flame_item[2], 0.0)

		smoke_emitter = LegacySceneFindItem(scene, "smoke_emitter")
		smoke_emitter_script = ItemGetScriptInstance(smoke_emitter)

		hit_emitter = LegacySceneFindItem(scene, "hit_emitter")
		hit_emitter_script = ItemGetScriptInstance(hit_emitter)

		local	scene_root = SceneAddObject(scene, "scene_root")
		scene_root = ObjectGetItem(scene_root)	//	'unparent' the smoke emitter
		ItemSetParent(smoke_emitter, scene_root)
		ItemSetParent(hit_emitter, scene_root)

		SetupLanderSounds()
	}

	function	EnableShield()
	{	
		print("LunarLander::EnableShield()")
		shield_enabled = true
		ItemActivate(shield_item, true)
		ItemSetCollisionMask(shield_col_item, 2)
	}

	function	DisableShield()
	{	
		print("LunarLander::DisableShield()")
		shield_enabled = false
		ItemActivate(shield_item, false)
		ItemSetCollisionMask(shield_col_item, 0)
	}

	constructor()
	{
		//update_function = UpdateDoNothing
	}
}
