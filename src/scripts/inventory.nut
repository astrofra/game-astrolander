//	Game Inventory Class
//	The items are stored in an array.
//	This class has access to the Hud
//	in order to update the screen

class Inventory
{
	inventory			=	0
	game_ui				=	0

	constructor(_ui = 0)
	{
		inventory = []
		game_ui = _ui
	}

	function	AddItem(item_name)
	{
		print("Inventory::AddItem(" + item_name + ")")

		inventory.append(item_name)
		DumpInventoryInConsole()
		if (game_ui)
			game_ui.UpdateInventory(inventory)
	}

	function	RemoveItem(item_name)
	{
		print("Inventory::RemoveItem(" + item_name + ")")

		local	idx, val
		foreach(idx,val in inventory)
			if (val == item_name)
			{
				inventory.remove(idx)
				DumpInventoryInConsole()
				if (game_ui)
					game_ui.UpdateInventory(inventory)
				return	true
			}

		return false
	}

	function	DumpInventoryInConsole()
	{
		local	str,i
		str = "["
			foreach(i in inventory)
				str += (" " + i)
		str += " ]"
		print(str)
	}

	function	FindItem(item_name)
	{
		local	i
		foreach(i in inventory)
			if (i == item_name)
				return	true

		return false
	}
}