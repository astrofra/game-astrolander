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
		if	(IsTouchPlatform())
			return
		print("SaveGame::SavePlayerData()")

		data_table = SaveDataTableAddGlobals(data_table)

		local	_file = MetafileNew()

		foreach(_key, _val in data_table)
		{
			print("Saving key : '" + _key + "' = " + _val + ".")
			if(typeof _val == "table")
			{
				print("Saving table.")
				local	_key_slice = (_key.tostring()).slice(0,5)
				print("SavePlayerData() _key_slice = " + _key_slice)
				if (_key_slice == "level")
				{
					MetafileAddRoot(_file, _key)
					local	_level_tag
					_level_tag = MetafileGetTag(_file, _key)
					foreach(_level_key, _level_val in _val)
						MetatagAddChildWithValue(_level_tag _level_key, _level_val)
				} 
			}
			else
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
		if	(IsTouchPlatform())
			return data_table

		print("SaveGame::LoadPlayerData()")

		local	_file
		data_table = SaveDataTableAddGlobals(data_table)

		if (FileExists(save_game_filename))
		{
			_file = MetafileNew()

			local	_succes = MetafileLoad(_file, save_game_filename)
			print("SaveGame::LoadPlayerData() : MetafileLoad() returned " + _succes)

			local	_roots_table
			_roots_table = MetafileGetRoots(_file)
//			_roots_table = _roots_table.sort()

			foreach(_root in _roots_table)
			{
//				local	_tag =	MetafileGetTag(_file, _root)
				local	_val = MetatagGetValue(_root)

				if ((MetatagGetName(_root).len() > 5) && (MetatagGetName(_root).slice(0,5) == "level"))
				{
					if (!data_table.rawin(MetatagGetName(_root)))
						data_table.rawset(MetatagGetName(_root), {})

					local	_level_keys = MetatagGetChildren(_root)
					foreach(_level_key in _level_keys)
					{
						local _level_val
						_level_val = MetatagGetValue(_level_key)

						if (!data_table[MetatagGetName(_root)].rawin(MetatagGetName(_level_key)))
							data_table[MetatagGetName(_root)].rawset(MetatagGetName(_level_key), _level_val)
						else
							data_table[MetatagGetName(_root)][MetatagGetName(_level_key)] = _level_val
						
					}
				}
				else
				{
					if (!data_table.rawin(MetatagGetName(_root)))
						data_table.rawset(MetatagGetName(_root), 0)

					data_table[MetatagGetName(_root)] = _val
				}
				
				g_reversed_controls = data_table.reversed_controls
			}
		}

		return	data_table
	}

	//------------------------------------
	function	LoadPlayerDataObsolete(data_table)
	//------------------------------------
	{
		if	(IsTouchPlatform())
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