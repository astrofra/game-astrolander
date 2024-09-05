//	Replay

class	ReplayItemMotion
{
	
	item		=	0
	motion		=	0
	base_clock	=	0
	
	constructor(_item, _clock)
	{
		item = _item
		base_clock = _clock
		motion = []
	}
	
	function	UpdateItemMotionRecord(_clock, _position, _rotation)
	{
		motion.append({clock = (_clock - base_clock), position_x = _position.x, position_y = _position.y, position_z = _position.z, rotation_x = RadianToDegree(_rotation.x), rotation_y = RadianToDegree(_rotation.y), rotation_z = RadianToDegree(_rotation.z)})
	}
	
	function	SaveItemMotion(_filename)
	{
		//	NML Format
		local file = MetafileNew()
		serializeObjectToMetatag(motion, MetafileAddRoot(file, "replay"))
		MetafileSave(file, _filename + ".nml")

		//	TXT Format
		local	pos = "", rot = "", pos_rot = ""
		foreach(knot in motion)
		{
			local	_frame_pos = knot.position_x + " " + knot.position_z + " " + knot.position_y + "\n"
			local	_frame_rot = knot.rotation_x + " " + knot.rotation_z + " " + knot.rotation_y + "\n"
			pos += _frame_pos
			rot += _frame_rot
			pos_rot = pos_rot + _frame_pos + _frame_rot
		}

		pos_rot += "time = " + TickToSec(g_clock - base_clock).tostring()

		file = MetafileNew()
		serializeObjectToMetatag(pos, MetafileAddRoot(file, "replay"))
		MetafileSave(file, _filename + "_position.txt")

		file = MetafileNew()
		serializeObjectToMetatag(rot, MetafileAddRoot(file, "replay"))
		MetafileSave(file, _filename + "_rotation.txt")

		file = MetafileNew()
		serializeObjectToMetatag(pos_rot, MetafileAddRoot(file, "replay"))
		MetafileSave(file, _filename + "_position_rotation.txt")
	}
	
}