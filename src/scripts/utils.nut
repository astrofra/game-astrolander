//	Utils.nut

		Include("scripts/globals.nut")

//-----------------------------
function	MakeTriangleWave(i)
//-----------------------------
// 1 ^   ^
//   |  / \
//   | /   \
//   |/     \
//   +-------->
// 0    0.5    1
{
	local 	s = Sign(i);
	i = Abs(i);

	if (i < 0.5)
		return (s * i * 2.0);
	else
		return (s * (1.0 - (2.0 * (i - 0.5))));
}

//-----------------------------------------------------------------------------------------
function TimeToString(time, separators = { minute	= "'", second	= "\"", ms		= "" })
//-----------------------------------------------------------------------------------------
{
	time = time / 10000.0
	local ftime = {
		hour	= floor(time / 3600)
		minute	= floor((time / 60) % 60)
		second	= floor(time % 60)
		ms		= floor((time * 100) % 100)
	}

	local result = ""
	foreach (key in g_time_key_order)
		if (key in separators)
			result += (ftime[key] < 10 ? "0" + ftime[key] : ftime[key]) + separators[key]

	return result
}

//----------------------
function modAngle(angle)
//---------------------- 
{
	while (angle < 0.0)
		angle += g_2_pi

	while (angle >= g_2_pi)
		angle -= g_2_pi

	return angle
}