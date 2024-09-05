/*
	File: scripts/level_exporter.nut
	Author: Astrofra
*/

/*!
	@short	LevelExporter
	@author	Astrofra
*/
class	LevelExporter
{
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		local	block_list, file_handler

//		file_handler = file("level.txt", "w+")
		block_list = DumpItemsToList(SceneGetBlockList(scene))
		DumpItemListToNML({blocks = block_list}, "c:/level_dump_16")
//		DumpItemListToFile(block_list, file_handler)
	}

	function	DumpItemListToNML(block_list, filename)
	{
		//	NML Format
		local file = MetafileNew()
		serializeObjectToMetatag(block_list, MetafileAddRoot(file, "level"))
		MetafileSave(file, filename + ".nml")

	}

	function	SceneGetBlockList(scene)
	{
		local	block_list, item_list
		block_list = []
		item_list = SceneGetItemList(scene)
		foreach(item in item_list)
		{
			local	item_name = ItemGetName(item)
			if (ItemIsABlock(item))
				block_list.append(item)
		}

		return block_list
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

	function	DumpItemsToList(list)
	{
		local	str_list = []
		foreach(item in list)
		{
			local	str = ""
			str += ItemGetName(item)
			str += ";"
			str += DumpVectorComponents(ItemGetWorldPosition(item))
			str += ";"
			str += DumpVectorComponents(ItemGetRotation(item), "degrees")
			str += ";"
			str += DumpVectorComponents(ItemGetScale(item))
//			str += "\n"

			//file_handler.writeblob(str)
			print(str)
			str_list.append(str)
		}

		return str_list
	}

	function	DumpVectorComponents(v, conversion_mode = "none")
	{
		if (conversion_mode == "degrees")
		{
			v.x = RadianToDegree(v.x)
			v.y = RadianToDegree(v.y)
			v.z = RadianToDegree(v.z)
		}

		local str = ""
		str += "("
		str += QuantizeCoord(v.x).tostring()
		str += ","
		str += QuantizeCoord(v.y).tostring()
		str += ","
		str += QuantizeCoord(v.z).tostring()
		str += ")"

		return str
	}

	function	QuantizeCoord(x)
	{
//return x
		local	sgn = (x < 0.0?-1.0:1.0)

		x = Abs(x)
		if (x < 0.001)
			x = 0.0

		x *= sgn 

		return x
	}
}
