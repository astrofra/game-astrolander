//	Save

//--------------------------
function	GlobalSaveGame()
//--------------------------
{
	local	_game = ProjectGetScriptInstance(g_project)
	_game.save_game.SavePlayerData(_game.player_data)
}

//--------------------------
function	GlobalLoadGame()
//--------------------------
{
	local	_game = ProjectGetScriptInstance(g_project)
	_game.player_data = _game.save_game.LoadPlayerData(_game.player_data)
}

//-------------------------------
function	GlobalSetPlayerGuid()
//-------------------------------
{
	local	_game = ProjectGetScriptInstance(g_project)
	//	Set Player's GUID (if not already node)
	if (!("guid" in _game.player_data))
		_game.player_data.rawset("guid", GenerateEncodedTimeStamp())
}

//-------------------------------------------
function	GlobalLevelGetScore(_level_index)
//-------------------------------------------
{
	local	_player_data = ProjectGetScriptInstance(g_project).player_data
	local	_score, _level_key

	_level_key = "level_" + _level_index.tostring()
	if (_level_key in _player_data)
	{
		local	_level_data = _player_data[_level_key]
		_score = _level_data.score.tointeger()
	}
	else
		_score = 0

	return _score
}

//-------------------------------------------
function	GlobalLevelGetStopwatch(_level_index)
//-------------------------------------------
{
	local	_player_data = ProjectGetScriptInstance(g_project).player_data
	local	_time, _level_key

	_level_key = "level_" + _level_index.tostring()
	if (_level_key in _player_data)
	{
		local	_level_data = _player_data[_level_key]
		_time = _level_data.stopwatch
	}
	else
		_time = 0.0

	return _time
}

//-------------------------------------
function	GlobalCalculateTotalScore()
//-------------------------------------
{
	local	_total_score = 0
	local	_player_data = ProjectGetScriptInstance(g_project).player_data
	local	_level_index = 0, _level_key

	while(_level_index < 1024)
	{
		_level_key = "level_" + _level_index.tostring()
		if (_level_key in _player_data)
		{
			local	_level_data = _player_data[_level_key]
			_total_score += _level_data.score
		}
		else
			break
		_level_index++
	}

	game.player_data.total_score = _total_score
}

//--------------
class	SaveGame
//--------------
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
		data_table.current_language <- 	g_current_language

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
				if	(ObjectIsValid(tag))
				{
					data_table = deserializeObjectFromMetatag(tag)
					if ("reversed_controls" in data_table)
						g_reversed_controls = data_table.reversed_controls
					if ("current_language" in data_table)
						g_current_language = data_table.current_language
				}
			}
		}

		return	data_table
	}
}