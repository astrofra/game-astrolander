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
		ui = SceneGetUI(scene)
		local	_black_screen
		_black_screen = UIAddSprite(ui, -1, EngineLoadTexture(g_engine, "graphics/black.jpg"), 1280.0 / 2.0, 960.0 / 2.0, 16.0, 16.0)
		WindowSetPivot(_black_screen, 8, 8)
		WindowCentre(_black_screen)
		WindowSetScale(_black_screen, 2048.0 / 16.0 * 1.5, 2048 / 16.0 * 1.5)
	}
}
