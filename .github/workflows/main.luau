--[[
    Blackhawk Rescue Mission - Zombies Inventory Viewer
    This script displays player inventory with weapons, ammo, and items
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.I -- Press 'I' to toggle inventory
local INVENTORY_WIDTH = 300
local INVENTORY_HEIGHT = 400
local ITEM_SLOT_HEIGHT = 40
local BORDER_COLOR = Color3.fromRGB(0, 0, 0)
local HEADER_COLOR = Color3.fromRGB(30, 30, 30)
local BACKGROUND_COLOR = Color3.fromRGB(50, 50, 50)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local ITEM_COLOR = Color3.fromRGB(80, 80, 80)

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryViewer"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, INVENTORY_WIDTH, 0, INVENTORY_HEIGHT)
mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
mainFrame.BackgroundColor3 = BACKGROUND_COLOR
mainFrame.BorderColor3 = BORDER_COLOR
mainFrame.BorderSizePixel = 2
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- Create header
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 35)
headerFrame.BackgroundColor3 = HEADER_COLOR
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerText = Instance.new("TextLabel")
headerText.Name = "HeaderText"
headerText.Size = UDim2.new(1, 0, 1, 0)
headerText.BackgroundTransparency = 1
headerText.TextColor3 = TEXT_COLOR
headerText.TextSize = 18
headerText.Font = Enum.Font.GothamBold
headerText.Text = "INVENTORY"
headerText.Parent = headerFrame

-- Create close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = TEXT_COLOR
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.Parent = headerFrame

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Create ScrollingFrame for inventory items
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -4, 1, -40)
scrollFrame.Position = UDim2.new(0, 2, 0, 38)
scrollFrame.BackgroundColor3 = BACKGROUND_COLOR
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

-- Create UIListLayout for auto-positioning items
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 4)
uiListLayout.Parent = scrollFrame

-- Inventory item template function
local function createInventoryItem(itemName, quantity, itemType)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = itemName
    itemFrame.Size = UDim2.new(1, -8, 0, ITEM_SLOT_HEIGHT)
    itemFrame.BackgroundColor3 = ITEM_COLOR
    itemFrame.BorderColor3 = BORDER_COLOR
    itemFrame.BorderSizePixel = 1
    
    -- Item name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = TEXT_COLOR
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.Text = itemName
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = itemFrame
    
    -- Quantity label
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "QuantityLabel"
    quantityLabel.Size = UDim2.new(0.4, 0, 1, 0)
    quantityLabel.Position = UDim2.new(0.6, 0, 0, 0)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.TextColor3 = TEXT_COLOR
    quantityLabel.TextSize = 14
    quantityLabel.Font = Enum.Font.Gotham
    quantityLabel.Text = "x" .. tostring(quantity)
    quantityLabel.TextXAlignment = Enum.TextXAlignment.Right
    quantityLabel.Parent = itemFrame
    
    return itemFrame
end

-- Function to update inventory display
local function updateInventory()
    -- Clear existing items
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Get backpack or inventory system
    local backpack = player:FindFirstChild("Backpack")
    local inventory = {}
    
    if backpack then
        -- Get weapons from backpack
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local ammo = 0
                -- Try to find ammo value
                local ammoValue = tool:FindFirstChild("Ammo")
                if ammoValue then
                    ammo = ammoValue.Value
                end
                
                local magSize = 0
                local magValue = tool:FindFirstChild("MaxAmmo")
                if magValue then
                    magSize = magValue.Value
                end
                
                table.insert(inventory, {
                    name = tool.Name,
                    quantity = ammo .. "/" .. magSize,
                    type = "Weapon"
                })
            end
        end
    end
    
    -- Get equipped weapon
    local character = player.Character
    if character then
        for _, child in pairs(character:GetChildren()) do
            if child:IsA("Tool") then
                local ammo = 0
                local ammoValue = child:FindFirstChild("Ammo")
                if ammoValue then
                    ammo = ammoValue.Value
                end
                
                local magSize = 0
                local magValue = child:FindFirstChild("MaxAmmo")
                if magValue then
                    magSize = magValue.Value
                end
                
                table.insert(inventory, {
                    name = "[EQUIPPED] " .. child.Name,
                    quantity = ammo .. "/" .. magSize,
                    type = "Weapon"
                })
            end
        end
    end
    
    -- Add sample items (customize based on your game)
    if #inventory == 0 then
        table.insert(inventory, {name = "No items", quantity = 0, type = "Empty"})
    end
    
    -- Create item frames
    for _, item in ipairs(inventory) do
        local itemFrame = createInventoryItem(item.name, item.quantity, item.type)
        itemFrame.Parent = scrollFrame
    end
    
    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end

-- Toggle inventory visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == TOGGLE_KEY then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Update inventory when items change
player.CharacterAdded:Connect(function(character)
    wait(0.5)
    updateInventory()
end)

-- Initial inventory load
wait(1)
updateInventory()

-- Periodically update inventory (every 0.5 seconds)
RunService.RenderStepped:Connect(function()
    if mainFrame.Visible then
        updateInventory()
    end
end)

-- Handle tool acquisitions in real-time
local backpack = player:WaitForChild("Backpack")
backpack.ChildAdded:Connect(function()
    updateInventory()
end)

backpack.ChildRemoved:Connect(function()
    updateInventory()
end)

print("Inventory Viewer loaded! Press 'I' to toggle.")
