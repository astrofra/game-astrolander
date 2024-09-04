//	Utils.nut
		
//-------------------------------------------------
function	LegacySceneFindItem(_scene, _item_name)
//-------------------------------------------------
{
	local	_item, _current_item
	local	_list = SceneGetItemList(_scene)
	
	foreach(_current_item in _list)
		if (ItemGetName(_current_item) == _item_name)
			return _current_item
			
	return NullItem
}

//-------------------------------------------------
function	SceneDeleteItemHierarchy(_scene, _item)
//-------------------------------------------------
{
	local _list = ItemGetChildList(_item)

	foreach(_child in _list)
		SceneDeleteItemHierarchy(_scene, _child)

	SceneDeleteItem(_scene, _item)
}

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

function	ColorIsEqualToColor(ca, cb)
{
	if (Abs(ca.x - cb.x) > 0.05)
		return false
	if (Abs(ca.y - cb.y) > 0.05)
		return false
	if (Abs(ca.z - cb.z) > 0.05)
		return false

	return true
}

//-----------------------------
function	ProbabilityOccurence(prob_amount)
//-----------------------------
{
	if (prob_amount >= 100)
		return true
	if (prob_amount <= 0)
		return false

	prob_amount = prob_amount.tofloat()
	if (Rand(0.0,100.0) <= prob_amount)
		return true
	
	return false
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

//-----------------
class	PerlinNoise
//-----------------
{
	function Noise(x, y)	// 2 int
	{
    		local n = x.tointeger() + y.tointeger() * 57
	    	n = (n<<13) ^ n;
    		return ( 1.0 - ( (n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);    
	}
 
	function SmoothNoise(x, y)	// 2 float
	{
    		local corners = ( Noise(x-1.0, y-1.0)+Noise(x+1.0, y-1.0)+Noise(x-1.0, y+1.0)+Noise(x+1.0, y+1.0) ) / 16.0
		local sides   = ( Noise(x-1.0, y)  +Noise(x+1.0, y)  +Noise(x, y-1.0)  +Noise(x, y+1.0) ) /  8.0
		local center  =  Noise(x, y) / 4.0
	    	return corners + sides + center
	}
 
	function InterpolateNoise(x, y)	// 2 float
	{
      		local integer_X    = x.tointeger()
      		local fractional_X = x - integer_X
 
      		local integer_Y    = y.tointeger()
      		local fractional_Y = y - integer_Y
 
      		local v1 = SmoothNoise(integer_X,     integer_Y)
      		local v2 = SmoothNoise(integer_X + 1, integer_Y)
     		local v3 = SmoothNoise(integer_X,     integer_Y + 1)
      		local v4 = SmoothNoise(integer_X + 1, integer_Y + 1)
 
      		local i1 = Lerp(fractional_X, v1 , v2 )
      		local i2 = Lerp(fractional_X, v3 , v4 )
 
      		return Lerp(fractional_Y, i1 , i2)
	}
 
	// you have to call this one
	function PerlinNoise_2D(x, y)	// x and y order of 0.01 //2 float	return between -1.0 and 1.0 nearly can be a bit more thought :p
	{
     		local total = 0.0
		local p = 0.5 //persistence		0.25 smooth and 1 high frequency
      		local n = 6-1 //Number_Of_Octaves - 1
 
		for(local i=0; i<n; ++i)
		{
        		local frequency = pow(2, i)
        		local amplitude = pow(p, i)
 
          		total = total + InterpolateNoise(x * frequency, y * frequency) * amplitude
		}
      		return total
	}
}