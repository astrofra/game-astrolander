/*
	File: scripts/level_handler.nut
	Author: Astrofra
*/

		Include("scripts/ui.nut")

/*!
	@short	LevelHandler
	@author	Astrofra
*/
class	LevelHandler
{
	player		=	0

	path		=	0
	path_length	=	0.0

	artefact	=	0

	hud_ui		=	0

	/*!
		@short	OnUpdate
		Called each frame.
	*/
	function	OnUpdate(scene)
	{
		SceneCheckArtefacts(scene)
	}

	constructor()
	{
		path		=	[]
		artefact	=	[]
	}

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		hud_ui	=	HudUI(SceneGetUI(scene))
		SceneSetCurrentCamera(scene, ItemCastToCamera(SceneFindItem(scene, "game_camera")))
	}

	function	OnSetupDone(scene)
	{
		print("LevelHandler::OnSetupDone()")
		SceneFindPlayer(scene)
		SceneFindPath(scene)
		SceneFindArtefacts(scene)
	}

	//	=========
	//	Artefacts
	//	=========
	function	SceneCheckArtefacts(scene)
	{
		foreach(_item in artefact)
		{
			local	_item_pos = ItemGetWorldPosition(_item)
			local	_dist = ItemGetWorldPosition(player).Dist(_item_pos)

			if (_dist < Mtr(3.0))
				ScenePlayerGetsArtifact(scene, _item)
		}

		return	0
	}

	function	ScenePlayerGetsArtifact(scene, _item)
	{
		print("LevelHandler::ScenePlayerGetsArtifact() item = " + ItemGetName(_item))
		local	idx, val
		foreach(idx,val in artefact)
			if (ItemCompare(val, _item))
			{
				artefact.remove(idx)
				ItemActivateHierarchy(_item, false)
			}
	}

	function	SceneFindArtefacts(scene)
	{
		local	n = 0
		
		while(true)
		{
			local	_item = SceneFindItem(scene, "artefact_" + n.tostring())
			if (ObjectIsValid(_item))
				artefact.append(_item)
			else
				break

			n++
		}

		print("LevelHandler::SceneFindArtefacts() found " + artefact.len().tostring() + " artefact(s).")	
	}

	//	=====
	//	Paths
	//	=====
	function	SceneFindPath(scene)
	{
		local	n = 0
		
		while(true)
		{
			local	_item = SceneFindItem(scene, "path_" + n.tostring())
			if (ObjectIsValid(_item))
				path.append(_item)
			else
				break

			n++
		}

		if (path.len() > 0)
		{
			local	_prev_path_point = path[0]
			foreach(_path_point in path)
			{
				path_length += ItemGetWorldPosition(_prev_path_point).Dist(ItemGetWorldPosition(_path_point))
			}
		}

		print("LevelHandler::SceneFindPath() found " + path.len().tostring() + " path point(s), total length = " + path_length.tostring() + " m.")	
	}

	//	=======
	//	Players
	//	=======
	function	SceneFindPlayer(scene)
	{
		player = SceneFindItem(scene, "player")
		if (ObjectIsValid(player))
			print("LevelHandler::SceneFindPlayers() found " + ItemGetName(player) + ".")
		else
			print("LevelHandler::SceneFindPlayers() player not found.")
	}
}
