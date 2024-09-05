//	Save

class	SaveGame
{

	//-----------
	constructor()
	//-----------
	{
		print("SaveGame::constructor()")
	}

	function	GetSaveFilename()
	{
		local	save_game_filename

		if (IsTouchPlatform())
			save_game_filename = "@app/save.nml"
		else
		{
			if (EngineGetToolMode(g_engine) == NoTool)
				save_game_filename = "@root/save/save.nml"
			else
				save_game_filename = "c:/save.nml"
		}

		return	save_game_filename
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
		data_table = SaveDataTableAddGlobals(data_table)

		local file = MetafileNew()
		serializeObjectToMetatag(data_table, MetafileAddRoot(file, "save"))
	
		MetafileSave(file, GetSaveFilename())
	}
	
	//------------------------------------
	function	LoadPlayerData(data_table)
	//------------------------------------
	{
		print("SaveGame::LoadPlayerData()")

		local	_file
//		data_table = SaveDataTableAddGlobals(data_table)

		if (FileExists(GetSaveFilename()))
		{
			_file = MetafileNew()

			if	(MetafileLoad(_file, GetSaveFilename()))
			{
				local tag = MetafileGetTag(_file, "save;")
				data_table = deserializeObjectFromMetatag(tag)
				g_reversed_controls = data_table.reversed_controls
			}	
		}

		return	data_table
	}
}