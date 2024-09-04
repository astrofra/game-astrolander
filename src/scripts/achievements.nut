/*
	File: scripts/bonus.nut
	Author: Astrofra
*/

class	AchievementsHandler
{

	achievements	=	[]
	player_script	=	0

	//	Internal variables
	ingame_iteration_counter	=	0
	rush_mode_passed_counter	=	0

	//	Perfect : Finished the level without hitting any of the walls
	//	Eco Drive : Finished the level with more than 90% of fuel left
	//	Fuel Close Call : Finished the level with less than 2% of fuel left
	//	Rush Mode : Did 90% of the level at 90% of the maximum velocity.
	//	One take : completes all levels without retry
	//	Like a fish in water : spent more than [minutes] in the underwater levels
	//	No respect for the ancients : knocked at least 5 columns
	//	Finished the whole game in less than [X] minutes 

	constructor(_player_script)
	{
		player_script = _player_script
		achievements.append({evaluate = Perfect, ingame_evaluate = false, passed = false})
		achievements.append({evaluate = EcoDrive, ingame_evaluate = false, passed = false})
		achievements.append({evaluate = FuelCloseCall, ingame_evaluate = false, passed = false})

		ingame_iteration_counter	=	0
		rush_mode_passed_counter	=	0

	}

	function	Update()
	{
		EvaluateInGame()
		EvaluateOnEndGame()
	}

	function	EvaluateInGame()
	{
		local	_achievement
		foreach(_achievement in achievements)
			if (_achievement.ingame_evaluate)
				_achievement.passed = _achievement.evaluate()
	}

	function	EvaluateOnEndGame()
	{
		local	_achievement
		foreach(_achievement in achievements)
			if (!_achievement.ingame_evaluate)
				_achievement.passed = _achievement.evaluate()
	}

	function	Perfect()
	{
		if (player_script.hit_counter <= 0)
			return true

		return false
	}

	function	EcoDrive()
	{
		if (player_script.fuel >= 90)
			return true

		return false
	}

	function	FuelCloseCall()
	{
		if (player_script.fuel <= 2)
			return true

		return false
	}

	function	RushMode()
	{
		local	_current_speed
		_current_speed = player_script.current_velocity.Len()

		if (_current_speed >= 0.9 * max_speed)
			rush_mode_passed_counter++

		if (rush_mode_passed_counter.tofloat() >= ingame_iteration_counter * 0.9)
			return true
		else
			return false
	}

}