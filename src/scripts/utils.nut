//	Utils.nut

guid_table <- []

//------------------
class	LinearFilter
//------------------
{

	filter_size		=	0
	values			=	0

	constructor(_size)
	{
		filter_size	=	_size
		values = []
	}

	function	SetNewValue(val)
	{
		values.append(val)
		if (values.len() > filter_size)
			values.remove(0)
	}

	function	GetFilteredValue()
	{
		local	filtered_value
		if ((typeof values[0]) == "float")
			filtered_value = 0.0
		else
			filtered_value = Vector(0,0,0)

		foreach(_v in values)
			filtered_value += _v

		filtered_value /= (values.len().tofloat())

		return	filtered_value
	}

}

//-----------------------------------------
function	CalculateCheckKey(values_array)
//-----------------------------------------
{
	local	_str = ""
	foreach(_value in values_array)
		_str += _value

	_str += GetHashString()

	return SHA1(_str)
}

//-------------------------
function	GetHashString()
//-------------------------
{
	local	t = ["H","E","D","T","H","D","I","O","K","B","G","W","Z","Q","F","O","0","2","4","G","F","4","9","K","L"]
	local	_str = ""
	_str += t[0] + t[2] + t[6] + t[1] + t[8] + t[10] + t[20] + t[12] + t[15] + t[5] + t[1] + t[7] + t[21] + t[0]
	_str += "0" + (47392).tostring() + "H" + (3).tostring()
	_str += t[10] + t[19] + t[1] + t[2] + t[9] + t[1] + t[8] + t[11] + t[13] + t[5] + t[4] + t[22] + t[21] + t[0]
	_str += "X"

	return _str
}

//----------------------------------------------------------------------------------------------------
function	WriterWrapper(font, text, x, y, size, color = Vector(1, 1, 1, 1), align = WriterAlignLeft)
//----------------------------------------------------------------------------------------------------
{
	local	viewport = RendererGetViewport(g_render)
	local	vw = viewport.z, vh = viewport.w
	local	k_ar = vh / vw

	local	sx = (x - (g_screen_width * 0.5)) / (g_screen_width * 0.5) * k_ar + 0.5
	local	sy = y / g_screen_height

	RendererWrite(g_render, font, text, sx, sy, size / 2.6, true, align, color)
}

//------------------------------------
function	GenerateEncodedTimeStamp()
//------------------------------------
{
	local	base_time_stamp = g_clock

	while(base_time_stamp > 999000)
		base_time_stamp -= (ProbabilityOccurence(70)?(10000 + Irand(1000,10000)):(1000 + Irand(100,1000)))

	base_time_stamp = base_time_stamp.tointeger()

	local	base_time_stamp_str = base_time_stamp.tostring()
	local	guid = ""

	for(local n = 0; n < base_time_stamp_str.len(); n++)
	{
		local c = base_time_stamp_str.slice(n, n + 1)
		c = c.tointeger()
		c += (Irand(1,8) * 1000)
		if (ProbabilityOccurence(70))
			c += (Irand(1,9) * 100)
		if (ProbabilityOccurence(70))
			c += (Irand(1,9) * 10)
		if (ProbabilityOccurence(70))
			c -= Irand(1,9)

		c = Abs(c)

		guid += c.tostring()
		if (n < (base_time_stamp_str.len() - 1))
			guid += "-"
	}
/*
	foreach(_guid in guid_table)
		if (_guid == guid)
			print("found duplicate !!! " + guid + " = " + _guid)

	guid_table.append(guid)
*/
	guid = SHA1(guid)

	return guid	
}


//---------------------------
// * Converts an RGB color value to HSL. Conversion formula
// * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
// * Assumes r, g, and b are contained in the set [0, 255] and
// * returns h, s, and l in the set [0, 1].
function	RGBToHSL(rgb_color)
//---------------------------
{
		local	r,g,b
		r = rgb_color.x.tofloat()
		g = rgb_color.y.tofloat()
		b = rgb_color.z.tofloat()
		
    r /= 255.0
    g /= 255.0
    b /= 255.0
    
    local	max = Max(Max(r, g), b)
    local	min = Min(Min(r, g), b)
    local h, s, l = (max + min) / 2.0

    if(max == min)
    {
        h = s = 0.0 // achromatic
    }
    else
    {
        local	d = max - min
        s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
/*
        switch(max){
            case r: h = (g - b) / d + (g < b ? 6.0 : 0)
            break
            case g: h = (b - r) / d + 2.0
            break
            case b: h = (r - g) / d + 4.0
            break
        }
*/
		if (max == r)
			h = (g - b) / d + (g < b ? 6.0 : 0)
		else
		if (max == g)
			h = (b - r) / d + 2.0
		else
			h = (r - g) / d + 4.0

        h /= 6.0;
    }

    return Vector(h, s, l)
}


//-----------------------
function hue2rgb(p, q, t)
//-----------------------
{
    if(t < 0.0) t += 1.0
    if(t > 1.0) t -= 1.0
    if(t < 1.0 / 6.0) return p + (q - p) * 6.0 * t
    if(t < 1.0 / 2.0) return q
    if(t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0
    return p
}

//-------------------------
// * Converts an HSL color value to RGB. Conversion formula
// * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
// * Assumes h, s, and l are contained in the set [0, 1] and
// * returns r, g, and b in the set [0, 255].
function HSLToRGB(hsl_color)
//-------------------------
{
    local r, g, b, h, s, l
	h = hsl_color.x
	s = hsl_color.y
	l = hsl_color.z

    if(s == 0)
    {
        r = g = b = l
    }
    else
    {
        local	q = (l < 0.5) ? (l * (1.0 + s)) : (l + s - (l * s))
        local	p = 2.0 * l - q
        r = hue2rgb(p, q, h + (1.0 / 3.0))
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - (1.0 / 3.0))
    }
    
    return Vector(r * 255.0, g * 255.0, b * 255.0, 255)
}

//------------------------------------------------------------------
function	RGBColorBlend(color_A, color_B, k, HSL_blend_mode = false)
//------------------------------------------------------------------
{
	k = Clamp(k, 0.0, 1.0)
	local	_color, hsl_color_A, hsl_color_B, _hsl_blend

	if (HSL_blend_mode)
	{
		hsl_color_A = RGBToHSL(color_A)
		hsl_color_B = RGBToHSL(color_B)
		_hsl_blend = Vector(0,0,0)
		_hsl_blend.x = Lerp(k, hsl_color_A.x, hsl_color_B.x)
		_hsl_blend.y = Lerp(k, hsl_color_A.y, hsl_color_B.y)
		_hsl_blend.z = Lerp(k, hsl_color_A.z, hsl_color_B.z)
		_color =	HSLToRGB(_hsl_blend)
	}
	else
		_color = color_B.Lerp(k, color_A)

	return _color
}

function	RGBAToTag(_rgba)
{
	return ("~~Color(" + _rgba.x + "," + _rgba.y + "," + _rgba.z + "," + _rgba.w + ")")
}
	
//--------------------------	
function	RGBAToHex(_rgba)
//--------------------------	
{
//	_rgba.Print("RGBAToHex()")

	local	_hex = 0
	_hex = _hex | _rgba.w.tointeger()
	_hex = _hex | (_rgba.z.tointeger() << 8)
	_hex = _hex | (_rgba.y.tointeger() << 16)
	_hex = _hex | (_rgba.x.tointeger() << 24)

	return _hex	
}

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


//--------------------------------
function	AudioLoadSfx(_fname)
//--------------------------------
{
	local	_filename = "audio/sfx/" + _fname
	if (FileExists(_filename))
		return	EngineLoadSound(g_engine, _filename)
	else
	{
		print("AudioLoadSfx() Cannot find file '" + _filename + "'.")
		return	0
	}
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

//-------------------------------------------
function	ProbabilityOccurence(prob_amount)
//-------------------------------------------
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
		angle += 360.0

	while (angle >= 360.0)
		angle -= 360.0

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