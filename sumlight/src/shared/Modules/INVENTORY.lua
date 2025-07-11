local InventoryModule = {}

local PlayerInventory = {}

function InventoryModule.add(Player: Player, Item: Instance)
	local PlayerGui = Player.PlayerGui
	local InventoryGui = PlayerGui:FindFirstChild("Inventory") or PlayerGui:WaitForChild("Inventory")
	local InventoryFrame = InventoryGui:FindFirstChildOfClass("Frame") or InventoryGui:WaitForChild("Frame")
	
	local InventoryIndex = table.maxn(PlayerInventory[Player])
	
	PlayerInventory[Player[InventoryIndex]] = Item
end

return InventoryModule