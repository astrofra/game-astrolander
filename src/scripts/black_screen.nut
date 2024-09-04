/*
	File: scripts/black_screen.nut
	Author: Astrofra
*/

/*!
	@short	levels_black_screen
	@author	Astrofra
*/
class	levels_black_screen
{
	ui		=	0
	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		CreateOpaqueScreen(SceneGetUI(scene))
	}
}
