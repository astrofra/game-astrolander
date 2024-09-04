
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

class	GenericController
{
// Controller

	pad			=	0
	device_list	=	0
	
	jx			=	0
	jy			=	0
	shoot0		=	0

	constructor()
	{
		device_list = GetDeviceList(DeviceTypeGame)
		if (device_list.len())
		{
			pad = DeviceNew(device_list[0].id)
			print("GenericController::constructor() Joypad mode.")
		}
			else
				print("GenericController::constructor() Keyboard mode.")
	}
		
	//------------------------------
	function	GetControllerVector()
	{
		local	_direction = {x = 0.0, y = 0.0, shoot0 = false}
		
		if	(pad != 0)
		{
			DeviceUpdate(pad)
	
			// Get pad throttle
			jy = DevicePoolFunction(pad, DeviceAxisZ)
			jy = (jy - 32767.0) / -32767.0
	
			// Get pad direction
			jx = DevicePoolFunction(pad, DeviceAxisX)
			jx = (jx - 32767.0) / 32767.0;
		}
		else
		{
			KeyboardUpdate()
	
			// Get keyboard throttle
			if (KeyboardSeekFunction(DeviceKeyPress, KeyUpArrow))
				jy = 1.0
			else
			{
				if (KeyboardSeekFunction(DeviceKeyPress, KeyDownArrow))
					jy = -1.0
				else
					jy = 0.0
			}
	
			// Get keyboard direction
			if (KeyboardSeekFunction(DeviceKeyPress, KeyLeftArrow))
				jx = -1.0
			else
			{
				if (KeyboardSeekFunction(DeviceKeyPress, KeyRightArrow))
					jx = 1.0
				else
					jx = 0.0
			}
		}
		
		_direction.x = jx
		_direction.y = jy
		
		return (_direction)
	}
}