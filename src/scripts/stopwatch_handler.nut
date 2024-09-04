/*
	File: scripts/stopwatch_handler.nut
	Author: Astrofra
*/

/*!
	@short	StopwatchHandler
	@author	Astrofra
*/
class	StopwatchHandler
{

	clock				=	0.0
	is_counting			=	false
	prev_clock_count	=	0.0

	constructor()
	{	
		print("StopwatchHandler::constructor()")
	}

	function	Reset()
	{	
		clock 				=	0.0
		prev_clock_count	=	0.0
	}

	function	Start()
	{	is_counting = true	}

	function	Stop()
	{	is_counting = false	}

	function	Update()
	{
		if (is_counting)
			clock += ((g_clock - prev_clock_count) / g_clock_scale)

		prev_clock_count = g_clock
	}
}
