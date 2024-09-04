//

	Include("scripts/ace_deleter.nut")

class	FeedbackEmitter
{

	scene				=	0
	feedback_mesh		=	"graphics/item_taken_feedback.nmg"
	geo 				=	0

	ace_deleter			=	0

	constructor(_scene)
	{
		scene = _scene
		geo = EngineLoadGeometry(g_engine, feedback_mesh)
		ace_deleter = AceDeleter()
	}

	//------------------------
	function	Update()
	//------------------------
	{
		ace_deleter.Update()
	}

	function	Emit(pos = Vector(0,0,0))
	{

		local	new_part
		local	f = Vector(-0.75, 0.75, 0.2)
		local	fs = f.Scale(0.8)
		new_part = SceneAddObject(scene, "feedback")
		ObjectSetGeometry(new_part, geo)
		new_part = ObjectGetItem(new_part)
		//ItemActivate(new_part, false)
		ItemSetPosition(new_part, pos)
		ItemSetScale(new_part, Vector(0,0,0))
		ItemSetCommandList(new_part, "toscale 0,0,0,0;toscale 0.005," + f.x + "," + f.y + "," + f.z + ";nop 0.5;toscale 0.1," + fs.x + "," + fs.y + "," + fs.z + ";toscale 0.25,0,0,0;")
		ace_deleter.RegisterItem(new_part)
	}
	
}