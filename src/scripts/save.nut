//	Save

class	SaveGame
{

	save_game_filename	=	"save/save.nml"

	//-----------
	constructor()
	//-----------
	{
		print("SaveGame::constructor()")
	}

	//---------------------------------------------
	function	SaveDataTableAddGlobals(data_table)
	//---------------------------------------------
	{
		//	Add game globals to the table
		data_table.reversed_controls <- 	g_reversed_controls

		return data_table
	}

	//------------------------------------
	function	SavePlayerData(data_table)
	//------------------------------------
	{
		if	(g_is_touch_platform)
			return
		print("SaveGame::SavePlayerData()")

		data_table = SaveDataTableAddGlobals(data_table)

		local	_file = MetafileNew()

		foreach(_key, _val in data_table)
		{
			print("Saving key : '" + _key + "' = " + _val + ".")
			if(typeof _val == "array")
			{
				print("Saving array.")
			}
			else
			{
				MetafileAddRootWithValue(_file,_key,_val)
			}
		}

		MetafileSave(_file, save_game_filename)
		_file = 0
	}
	
	function	FileSavePlayerDataArray(_file, _array)
	{
	}

	//------------------------------------
	function	LoadPlayerData(data_table)
	//------------------------------------
	{
		if	(g_is_touch_platform)
			return data_table
		print("SaveGame::LoadPlayerData()")

		local	_file
		data_table = SaveDataTableAddGlobals(data_table)

		if (FileExists(save_game_filename))
		{
			_file = MetafileNew()

			local	_succes = MetafileLoad(_file, save_game_filename)
			print("SaveGame::LoadPlayerData() : MetafileLoad() returned " + _succes)

			foreach(_key, _val in data_table)
			{
				print("Loading key : '" + _key + "'.")
				local	_tag = MetafileGetTag(_file, _key)
				try
				{
					local	_val = MetatagGetValue(_tag)
					data_table[_key] = _val
					print("_val = " + _val)
				}
				catch(e)
				{
					print(e)
				}
			}

			g_reversed_controls = data_table.reversed_controls
			
		}
		else
		{
			print("SaveGame::LoadPlayerData() : cannot find file '" + _file + "'.")
		}

		return data_table
	}
}