
function	GlobalGetCurrentLevel()
{
	return	(ProjectGetScriptInstance(g_project).player_data.current_level)
}

function	GlobalLevelTableNameFromIndex(level_idx)
{
	local	season_idx = (level_idx / 8).tointeger()
	local	current_season_table = g_seasons["season_" + season_idx.tostring()]
	local	current_level_table = current_season_table.levels[level_idx - season_idx * 8]
	return	current_level_table
}