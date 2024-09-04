/*
	File: scripts/level_generator.nut
	Author: Astrofra
*/

/*!
	@short	LevelGenerator
	@author	Astrofra
*/
class	LevelGenerator	extends	LevelHandler
{
/*<
	<Parameter =
		<bitmap_filename = <Name = "Bitmap Filename"> <Type = "String"> <Default = "levels/level_0.psd">>
	>
>*/

	bitmap_filename	=	0
	bitmap			=	0
	bitmap_sx		=	0
	bitmap_sy		=	0

	map 			=	0

	level_bbox		=	0

	block			=	0

	color_code		=	{	wall = Vector(1.0, 0.5, 0.0, 1.0),	
							start = Vector(1.0, 0.0, 0.0, 1.0), 
							end = Vector(1.0, 1.0, 0.0, 1.0),
							artifact = Vector(0.0, 1.0, 0.0, 1.0)	
						}

	constructor()
	{
		base.constructor()
		level_bbox = { min = Vector(0,0,0), max = Vector(0,0,0) }
	}

	function	GroupSquareBlock(scene, block_size_meter, block_index, grouping_probability = 90, rotation_probability = 0	)
	{
		//	8 x 8 blocks
		local	x,y, _step
		local	offset_vector = Vector((block_size_meter * 0.5) - 1, -((block_size_meter * 0.5) - 1), 0)

		_step = Min(1, block_size_meter * 0.5)

		for (y = 0; y < bitmap_sy; y+=_step)
			for (x = 0; x < bitmap_sx; x+=_step)
			{
				local	block_count = 0

				local	xx,yy
				for(yy = y; yy < y + block_size_meter; yy++)
					for(xx = x; xx < x + block_size_meter; xx++)
						if ((xx < bitmap_sx) && (yy < bitmap_sy))
							if (map[xx][yy] == 1)
								block_count++

				if (block_count == block_size_meter*block_size_meter)
				{	
					local	_new_block = SceneDuplicateItem(scene, block[block_index])

					if ((block_size_meter > 2) && (ProbabilityOccurence(25))) 
						offset_vector.z = Mtr(-1.0)
					else
					if ((block_size_meter > 1) && (ProbabilityOccurence(5)))
						offset_vector.z = Mtr(-0.5)
					else
					if (ProbabilityOccurence(5))
						offset_vector.z = Mtr(-0.25)
					else
						offset_vector.z = 0.0

					ItemSetPosition(_new_block, Vector(level_bbox.min.x + x, level_bbox.max.y - y, 0) + offset_vector)
					if (ProbabilityOccurence(rotation_probability))	ItemSetRotation(_new_block, Vector(0,0,DegreeToRadian(90.0)))
					ItemSetFlags(_new_block, ItemFlagStatic, true)

					local	xx,yy
					for(yy = y; yy < y + block_size_meter; yy++)
						for(xx = x; xx < x + block_size_meter; xx++)
							if ((xx < bitmap_sx) && (yy < bitmap_sy))
								map[xx][yy] = 0
	
					//map[x][y] = 3
				}
			}
	}

	function	GroupLongBlock(scene, block_size_meter, block_index, grouping_probability = 90)
	{
		//	8 x 8 blocks
		local	x,y
		local	offset_vector = Vector(block_size_meter * -0.5 , -((1 * 0.5) - 1), 0)

		for (y = 0; y < bitmap_sy; y++)
		{
			local	block_count = 0

			for (x = 0; x < bitmap_sx; x++)
			{
				if (map[x][y] == 1)
					block_count++
				else
					block_count = 0

				if (block_count == block_size_meter)
				{
					local	_new_block = SceneDuplicateItem(scene, block[block_index])
					ItemSetPosition(_new_block, Vector(level_bbox.min.x + x, level_bbox.max.y - y, 0) + offset_vector)
					ItemSetRotation(_new_block, Vector(0,0,DegreeToRadian(90.0)))
					ItemSetFlags(_new_block, ItemFlagStatic, true)

					local	xx,yy = y
					for(xx = x - (block_size_meter - 1); xx <= x; xx++)
						if ((xx < bitmap_sx) && (yy < bitmap_sy))
								map[xx][yy] = 0

					block_count = 0	
				}
			}
		}

		//	8 x 8 blocks
		local	x,y
		local	offset_vector = Vector((1 * 0.5) - 1, block_size_meter * 0.5, 0)

		for (x = 0; x < bitmap_sx; x++)
		{
			local	block_count = 0
	
			for (y = 0; y < bitmap_sy; y++)
			{
				if (map[x][y] == 1)
					block_count++
				else
					block_count = 0

				if (block_count == block_size_meter)
				{
					local	_new_block = SceneDuplicateItem(scene, block[block_index])
					ItemSetPosition(_new_block, Vector(level_bbox.min.x + x, level_bbox.max.y - y, 0) + offset_vector)
//					ItemSetRotation(_new_block, Vector(0,0,DegreeToRadian(90.0)))
					ItemSetFlags(_new_block, ItemFlagStatic, true)

					local	xx = x, yy
					for(yy = y - (block_size_meter - 1); yy <= y; yy++)
						if ((xx < bitmap_sx) && (yy < bitmap_sy))
								map[xx][yy] = 0

					block_count = 0	
				}
			}
		}
	}

	function	OnSetup(scene)
	{
		block = []
		block.append(LegacySceneFindItem(scene, "g_block_1x1"))
		block.append(LegacySceneFindItem(scene, "g_block_2x2"))
		block.append(LegacySceneFindItem(scene, "g_block_4x4"))
		block.append(LegacySceneFindItem(scene, "g_block_8x8"))
		block.append(LegacySceneFindItem(scene, "g_block_1x4"))
		block.append(LegacySceneFindItem(scene, "g_block_1x8"))

		block.append(LegacySceneFindItem(scene, "g_block_tr_1x1"))
		block.append(LegacySceneFindItem(scene, "g_block_tr_2x2"))
		block.append(LegacySceneFindItem(scene, "g_block_tr_4x4"))
		//block.append(LegacySceneFindItem(scene, "g_block_8x16"))

		bitmap = EngineLoadPicture(g_engine, bitmap_filename)
		bitmap_sx = PictureGetRect(bitmap).GetWidth()
		bitmap_sy = PictureGetRect(bitmap).GetHeight()

		print("LevelGenerator::OnSetup() size = " + bitmap_sx + ", " + bitmap_sy + ".")

		level_bbox.min.x = bitmap_sx * -0.5
		level_bbox.min.y = bitmap_sy * -0.5
		level_bbox.max.x = bitmap_sx * 0.5
		level_bbox.max.y = bitmap_sy * 0.5

		map = array(bitmap_sx, 0)
		for (local n = 0; n < bitmap_sx; n++)
			map[n] = array(bitmap_sy, 0)

		local	x,y, _start_pos = Vector(0,0,0), _found_end_pos = false, _end_pos = Vector(0,0,0), _artifact_pos = []
		for (y = 0; y < bitmap_sy; y+=1)
			for (x = 0; x < bitmap_sx; x+=1)
			{
				local	_pixel = PictureGetPixel(bitmap, x, y)
//				_pixel.Print("Pixel")
				if (ColorIsEqualToColor(_pixel, color_code.wall))	//(_pixel.x  > 0.5)
					map[x][y] = 1
				else
				if (ColorIsEqualToColor(_pixel, color_code.start))
					_start_pos = Vector(level_bbox.min.x + x,level_bbox.max.y - y,0)
				else
				if (ColorIsEqualToColor(_pixel, color_code.end))
				{
					_end_pos = Vector(level_bbox.min.x + x,level_bbox.max.y - y,0)
					_found_end_pos = true
				}
				else
				if (ColorIsEqualToColor(_pixel, color_code.artifact))
					_artifact_pos.append(Vector(level_bbox.min.x + x,level_bbox.max.y - y,0))
			}

		//	Start & End slots
//		_start_pos.x = level_bbox.min.x + _start_pos.x
//		_start_pos.y = level_bbox.max.y - _start_pos.y
//		_start_pos.Print("LevelGenerator::OnSetup() : _start_pos")

		local	_item_start = LegacySceneFindItem(scene, "start"),
				_item_homebase = LegacySceneFindItem(scene, "homebase")

		if (!_found_end_pos)
		{
			ItemActivate(_item_start, false)
			ItemSetInvisible(_item_start, true)
			ItemSetPosition(_item_homebase, _start_pos)
		}
		else
		{
			ItemSetPosition(_item_start, _start_pos)
			ItemSetPosition(_item_homebase, _end_pos)
		}

		//	Lander				
		SceneFindPlayer(scene)
		local	_parent_item = ItemGetParent(player)
		if (ObjectIsValid(_parent_item))
			_start_pos -= ItemGetPosition(_parent_item)
		_start_pos.y += Mtr(2.25)
		ItemSetPosition(player, _start_pos)

		//	Artifacts
		local	_original_artifact = LegacySceneFindItem(scene, "Artifact")

		if (_artifact_pos.len() > 0)
		{
			local	_artifact
			foreach(_artifact in _artifact_pos)
			{
				local	_new_artifact = SceneDuplicateItem(scene, _original_artifact)
				ItemSetPosition(_new_artifact, _artifact)
			}
		}

		ItemActivate(_original_artifact, false)
		ItemActivateHierarchy(_original_artifact, false)

		//	8 x 8 blocks
		GroupSquareBlock(scene, 8, 3, 95, 90)	//	g_block_8x8

		//	4 x 4 blocks
		GroupSquareBlock(scene, 4, 2, 80, 0)	//	g_block_4x4

		//	2 x 2 blocks
		GroupSquareBlock(scene, 2, 1, 80, 0)	//	g_block_2x2

		GroupLongBlock(scene, 8, 5, 90)

		GroupLongBlock(scene, 4, 4, 90)

		//	1 x 1 blocks
		GroupSquareBlock(scene, 1, 0, 90, 0)

		//	Destroy the original blocks
		foreach(_item in block)
		{
			ItemSetPhysicMode(_item, PhysicModeNone)
			ItemActivate(_item, false)
			ItemSetName(_item, "none")
			SceneDeleteItem(scene, _item)
		}

		SceneSave(scene, "levels/tmp.nms")

		//	Last step, setup the built level.
		base.OnSetup(scene)
	}
	
	function	OnSetupDone(scene)
	{
			base.OnSetupDone(scene)
	}

	function	OnUpdate(scene)
	{
		base.OnUpdate(scene)
	}
}
