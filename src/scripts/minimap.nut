/*
	File: minimap.nut
	Author: Astrofra
*/

		Include("scripts/globals.nut")

/*!
	@short	MiniMap
	@author	Astrofra
*/
class	MiniMap
{
		scene				=	0
		bounding_box		=	0
		map_window			=	0

		max_real_width		=	0
		max_real_height		=	0

		map_texture			=	0
		map_picture			=	0
		map_pixel_width		=	0
		map_pixel_height	=	0

		brush				=	0

		map_pixel_size		=	512
		ui_scale			=	0.75
		

		constructor(_scene)
		{
			scene = _scene
			brush = []
			brush.append(TextureGetPicture(EngineLoadTexture(g_engine, "ui/minimap_brush_0.png")))
			brush.append(TextureGetPicture(EngineLoadTexture(g_engine, "ui/minimap_brush_1.png")))
			brush.append(TextureGetPicture(EngineLoadTexture(g_engine, "ui/minimap_brush_2.png")))

			EvaluateLevelBoundingBox()
			CreateMapTexture()
		}

		function	CreateMapTexture()
		{
			//	The texture largest dimension should be around 'map_pixel_size' (256)
			local	pixel_scale_factor
			if (max_real_width > max_real_height)
			{
				pixel_scale_factor = map_pixel_size / max_real_width
				map_pixel_width = map_pixel_size
				map_pixel_height = pixel_scale_factor * max_real_height
			}
			else
			{
				pixel_scale_factor = map_pixel_size / max_real_height
				map_pixel_height = map_pixel_size
				map_pixel_width = pixel_scale_factor * max_real_width
			}

			map_pixel_width = (((map_pixel_width / 16).tointeger()) * 16).tointeger()
			map_pixel_height = (((map_pixel_height / 16).tointeger()) * 16).tointeger()

			print("MiniMap::CreateMapTexture()")
			print("pixel width = " + map_pixel_width.tostring() + ", pixel height = " + map_pixel_height.tostring())

			map_texture = EngineCreateTexture(g_engine, map_pixel_width, map_pixel_height, true)
			map_picture = TextureGetPicture(map_texture)

			local	x,y, world_x, world_y
			for(y = 0; y < map_pixel_height; y+=6)
				for(x = 0; x < map_pixel_width; x+=6)
				{
					world_x = bounding_box.min.x + ((x * max_real_width) / map_pixel_width)
					world_y = bounding_box.max.y - ((y * max_real_height) / map_pixel_height)
					local	hit = SceneCollisionRaytrace(scene, Vector(world_x, world_y, Mtr(-5.0)), Vector(0,0,1), 3, CollisionTraceAll, Mtr(20))
					local	_color
					if (hit.hit)
					{
						if (ItemIsABlock(hit.item))
						{
							local	_rect_src, _rect_dest
							_rect_src = Rect(0,0,11,11)
							_rect_dest = Rect(x - 6, y - 6, x + 5, y + 5)
						//	PictureSetPixel(map_picture, x, y, Vector(1,0,0,1))
							PictureBlitRect(brush[Rand(0,2)], map_picture, _rect_src, _rect_dest, BlendCompose)
						}
					}
				}

			//for(x = 0; x < 50; x++)
			//	PictureSetPixel(map_picture, map_pixel_width / 2.0 + Rand(-10,10), map_pixel_height / 2.0 + Rand(-4,4), Vector(1,0,0,1))

			TextureUpdate(map_texture)

			local	_ui
			_ui = SceneGetUI(scene)
			map_window = UIAddSprite(_ui, -1, map_texture, 0.0, 0.0, map_pixel_width, map_pixel_height)
			WindowSetScale(map_window, ui_scale, ui_scale)
			WindowSetPosition(map_window ,1280.0 - (map_pixel_width * ui_scale), 960.0 - (map_pixel_height * ui_scale) - 64.0)
			WindowSetOpacity(map_window, 0.5)
		}

		function	EvaluateLevelBoundingBox()
		{
			local	_block_list = [], _list
			_list = SceneGetItemList(scene)

			//	Find blocks
			foreach(_item in _list)
				if (ItemIsABlock(_item))
					_block_list.append(_item)

			if (_block_list.len() == 0)
				return
			else
				print("MiniMap::EvaluateLevelBoundingBox() found " + _block_list.len().tostring() + " blocks.")

			//	Compute the global BB of the blocks
			local	minx, miny, maxx, maxy
			minx = ItemGetWorldMinMax(_block_list[0]).min.x
			miny = ItemGetWorldMinMax(_block_list[0]).min.y
			maxx = ItemGetWorldMinMax(_block_list[0]).max.x
			maxy = ItemGetWorldMinMax(_block_list[0]).max.y

			foreach(_item in _block_list)
			{
				local	_itembb = ItemGetWorldMinMax(_item)

				//	Min
				if (_itembb.min.x < minx)
					minx = _itembb.min.x
				if (_itembb.min.y < miny)
					miny = _itembb.min.y
				//	Max
				if (_itembb.max.x > maxx)
					maxx = _itembb.max.x
				if (_itembb.max.y > maxy)
					maxy = _itembb.max.y
			}

			bounding_box = { min = Vector(0,0,0), max = Vector(0,0,0)	}
			bounding_box.min.x = minx - Mtr(5.0)
			bounding_box.min.y = miny - Mtr(5.0)
			bounding_box.max.x = maxx + Mtr(5.0)
			bounding_box.max.y = maxy + Mtr(5.0)

			bounding_box.min.Print("Min")
			bounding_box.max.Print("Max")

			max_real_width		=	bounding_box.max.x - bounding_box.min.x
			max_real_height		=	bounding_box.max.y - bounding_box.min.y

			print("Map width (m) = " + max_real_width.tostring() + ", map height (m) = " + max_real_height.tostring())
		}

		function	ItemIsABlock(_item)
		{
			local	item_name_root = "g_block_"
			local	_name = ItemGetName(_item)
			
			if (_name.len() <=  item_name_root.len())
				return false

			if (_name.slice(0, item_name_root.len()) == item_name_root)
				return true

			return false
		}
}
