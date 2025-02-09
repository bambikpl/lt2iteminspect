local CoreGui = game:GetService("CoreGui")

CoreGui:WaitForChild("RobloxPromptGui", math.huge):Destroy()
game.Lighting.ChildAdded:Connect(function(child)
    if child:IsA("BlurEffect") then
        child:Destroy()
    end
end)
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Destination
local ClientItemInfo = ReplicatedStorage:WaitForChild("ClientItemInfo")

-- Create the main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ItemImageGrid"
ScreenGui.Parent = CoreGui -- Parent to CoreGui

-- Create a refresh button
local RefreshButton = Instance.new("TextButton")
RefreshButton.Size = UDim2.new(0, 100, 0, 30)
RefreshButton.Position = UDim2.new(0.1, 0, 0, 40) -- Below the save button
RefreshButton.Text = "Refresh"
RefreshButton.TextColor3 = Color3.new(1, 1, 1)
RefreshButton.BackgroundColor3 = Color3.new(0, 0.5, 0.5)
RefreshButton.BorderSizePixel = 0
RefreshButton.Parent = Frame

-- Function to refresh the comparison
RefreshButton.MouseButton1Click:Connect(function()
    local savedItems = loadItems()
    compareItems(savedItems)
end)

-- Create a save button
local SaveButton = Instance.new("TextButton")
SaveButton.Size = UDim2.new(0, 100, 0, 30)
SaveButton.Position = UDim2.new(0.1, 0, 0, 5) -- Top-left corner
SaveButton.Text = "Save Items"
SaveButton.TextColor3 = Color3.new(1, 1, 1)
SaveButton.BackgroundColor3 = Color3.new(0, 0.5, 0)
SaveButton.BorderSizePixel = 0
SaveButton.Parent = Frame

-- Create a frame to hold the grid
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.8, 0, 0.8, 0) -- 80% of the screen size
Frame.Position = UDim2.new(0.1, 0, 0.1, 0) -- Centered
Frame.AnchorPoint = Vector2.new(0.5, 0.5) -- Center the frame
Frame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center the frame
Frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Frame.Parent = ScreenGui

-- Create a close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5) -- Top-right corner
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Frame

-- Function to close the UI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Create a scrolling frame
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(0.6, -20, 1, -80) -- Leave space for padding, close button, and slider
ScrollingFrame.Position = UDim2.new(0, 10, 0, 80) -- Adjust for close button and slider
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Parent = Frame

-- Create a UIGridLayout for the grid
local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellPadding = UDim2.new(0, 10, 0, 10) -- Padding between cells
UIGridLayout.FillDirectionMaxCells = 5 -- Default number of items per row
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.Parent = ScrollingFrame

-- Create a slider to control the number of items per row
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.8, 0, 0, 30)
SliderFrame.Position = UDim2.new(0.1, 0, 0, 40) -- Below the close button
SliderFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SliderFrame.Parent = Frame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(0, 100, 1, 0)
SliderLabel.Position = UDim2.new(0, 0, 0, 0)
SliderLabel.Text = "Items per row:"
SliderLabel.TextColor3 = Color3.new(1, 1, 1)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Parent = SliderFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(0.6, 0, 0, 5)
SliderTrack.Position = UDim2.new(0.4, 0, 0.5, 0)
SliderTrack.AnchorPoint = Vector2.new(0, 0.5)
SliderTrack.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
SliderTrack.Parent = SliderFrame

local SliderHandle = Instance.new("TextButton")
SliderHandle.Size = UDim2.new(0, 20, 0, 20)
SliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
SliderHandle.AnchorPoint = Vector2.new(0, 0.5)
SliderHandle.BackgroundColor3 = Color3.new(1, 1, 1)
SliderHandle.BorderSizePixel = 0
SliderHandle.Text = ""
SliderHandle.Parent = SliderTrack

local SliderValue = Instance.new("TextLabel")
SliderValue.Size = UDim2.new(0, 50, 1, 0)
SliderValue.Position = UDim2.new(1, 10, 0, 0)
SliderValue.Text = "5" -- Default value
SliderValue.TextColor3 = Color3.new(1, 1, 1)
SliderValue.BackgroundTransparency = 1
SliderValue.Parent = SliderFrame

-- Function to save items to a JSON file
SaveButton.MouseButton1Click:Connect(function()
    local itemsTable = {}
    
    for folderName, folder in pairs(ClientItemInfo:GetChildren()) do
        if folder:IsA("Folder") then
            local itemImage = folder:FindFirstChild("ItemImage")
            if itemImage and itemImage:IsA("StringValue") then
                local itemData = {
                    ItemImage = itemImage.Value,
                    Details = {}
                }
                
                for _, value in ipairs(folder:GetChildren()) do
                    if value:IsA("StringValue") or value:IsA("IntValue") then
                        itemData.Details[value.Name] = value.Value
                    end
                end
                
                table.insert(itemsTable, itemData)
            end
        end
    end
    
    -- Convert the table to a JSON string
    local jsonString = game:GetService("HttpService"):JSONEncode(itemsTable)
    
    -- Save the JSON string to a file
    writefile("saved_items.json", jsonString)
    
    print("Items saved to saved_items.json")
end)

-- Function to update the grid layout based on the number of items per row
local function updateGridLayout(itemsPerRow)
    local frameWidth = ScrollingFrame.AbsoluteSize.X
    local padding = 10
    local cellWidth = (frameWidth - (itemsPerRow - 1) * padding) / itemsPerRow
    local cellHeight = cellWidth -- Keep cells square

    UIGridLayout.CellSize = UDim2.new(0, cellWidth, 0, cellHeight)
    UIGridLayout.FillDirectionMaxCells = itemsPerRow
end

-- Function to update the canvas size of the scrolling frame
local function updateCanvasSize()
    local totalImages = #ScrollingFrame:GetChildren() - 1 -- Subtract 1 for UIGridLayout
    local itemsPerRow = UIGridLayout.FillDirectionMaxCells
    local rows = math.ceil(totalImages / itemsPerRow)
    local cellHeight = UIGridLayout.CellSize.Y.Offset
    local padding = UIGridLayout.CellPadding.Y.Offset
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, rows * (cellHeight + padding))
end

-- Function to handle slider dragging
local function onSliderDrag(input)
    local sliderStartX = SliderTrack.AbsolutePosition.X
    local sliderEndX = sliderStartX + SliderTrack.AbsoluteSize.X
    local handleX = math.clamp(input.Position.X, sliderStartX, sliderEndX)
    local percent = (handleX - sliderStartX) / SliderTrack.AbsoluteSize.X

    -- Calculate items per row (range: 2 to 10)
    local itemsPerRow = math.floor(2 + percent * 8)
    itemsPerRow = math.clamp(itemsPerRow, 2, 10)

    -- Update handle position
    SliderHandle.Position = UDim2.new(percent, 0, 0.5, 0)

    -- Update slider value display
    SliderValue.Text = tostring(itemsPerRow)

    -- Update grid layout
    updateGridLayout(itemsPerRow)
    updateCanvasSize()
end

-- Connect slider handle dragging
local isDragging = false
SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
    end
end)

SliderHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        onSliderDrag(input)
    end
end)

-- Create a frame to display the selected item's details
local DetailsFrame = Instance.new("Frame")
DetailsFrame.Size = UDim2.new(0.35, -20, 1, -80) -- 35% of the screen width
DetailsFrame.Position = UDim2.new(0.65, 10, 0, 80) -- Right side of the screen
DetailsFrame.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
DetailsFrame.Parent = Frame

-- Create an ImageLabel to display the selected item's image
local ItemImageLabel = Instance.new("ImageLabel")
ItemImageLabel.Size = UDim2.new(1, 0, 0.3, 0) -- 30% of the DetailsFrame height
ItemImageLabel.Position = UDim2.new(0, 0, 0, 10) -- Top of the DetailsFrame
ItemImageLabel.BackgroundTransparency = 1
ItemImageLabel.Parent = DetailsFrame

-- Create a ScrollingFrame to display the string values
local DetailsScrollingFrame = Instance.new("ScrollingFrame")
DetailsScrollingFrame.Size = UDim2.new(1, -20, 0.65, -20) -- 65% of the DetailsFrame height
DetailsScrollingFrame.Position = UDim2.new(0, 10, 0.35, 10) -- Below the ItemImageLabel
DetailsScrollingFrame.BackgroundTransparency = 1
DetailsScrollingFrame.ScrollBarThickness = 8
DetailsScrollingFrame.Parent = DetailsFrame

-- Create a UIListLayout for the string values
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = DetailsScrollingFrame

-- Function to create image frames
local function createImageFrame(imageId, folder)
    local ImageFrame = Instance.new("ImageButton")
    ImageFrame.Size = UDim2.new(0, 150, 0, 150) -- Initial size, will be updated by UIGridLayout
    ImageFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    ImageFrame.BorderSizePixel = 0
    ImageFrame.Parent = ScrollingFrame

    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Size = UDim2.new(1, 0, 1, 0)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = imageId
    ImageLabel.Parent = ImageFrame

    -- Function to display item details when clicked
    ImageFrame.MouseButton1Click:Connect(function()
        -- Clear previous details
        for _, child in ipairs(DetailsScrollingFrame:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end

        -- Display the selected item's image
        ItemImageLabel.Image = imageId

        -- Display all string/int values in the folder with a copy button
        for _, value in ipairs(folder:GetChildren()) do
            if value:IsA("StringValue") or value:IsA("IntValue") then
                -- Create a frame to hold the label and button
                local ValueFrame = Instance.new("Frame")
                ValueFrame.Size = UDim2.new(1, 0, 0, 20)
                ValueFrame.BackgroundTransparency = 1
                ValueFrame.Parent = DetailsScrollingFrame

                -- Create a TextLabel for the value
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.new(0.8, 0, 1, 0)
                TextLabel.Text = value.Name .. ": " .. value.Value
                TextLabel.TextColor3 = Color3.new(1, 1, 1)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.Parent = ValueFrame

                -- Create a CopyButton
                local CopyButton = Instance.new("TextButton")
                CopyButton.Size = UDim2.new(0.2, 0, 1, 0)
                CopyButton.Position = UDim2.new(0.8, 0, 0, 0)
                CopyButton.Text = "Copy"
                CopyButton.TextColor3 = Color3.new(1, 1, 1)
                CopyButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
                CopyButton.BorderSizePixel = 0
                CopyButton.Parent = ValueFrame

                -- Function to copy the value to the clipboard
                CopyButton.MouseButton1Click:Connect(function()
                    setclipboard(tostring(value.Value))
                end)
            end
        end

        -- Update the canvas size of the details scrolling frame
        DetailsScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end)

    return ImageFrame
end

-- Loop through all folders in ClientItemInfo
for folderName, folder in pairs(ClientItemInfo:GetChildren()) do
    if folder:IsA("Folder") then
        local itemImage = folder:FindFirstChild("ItemImage")
        if itemImage and itemImage:IsA("StringValue") then
            createImageFrame(itemImage.Value, folder)
        end
    end
end

-- Initial setup
updateGridLayout(5) -- Default to 5 items per row
updateCanvasSize()

-- Update grid layout and canvas size when the screen size changes
local function onScreenSizeChanged()
    updateGridLayout(tonumber(SliderValue.Text))
    updateCanvasSize()
end

-- Listen for screen size changes
ScrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(onScreenSizeChanged)

-- Function to load items from a JSON file
local function loadItems()
    if isfile("saved_items.json") then
        local jsonString = readfile("saved_items.json")
        return game:GetService("HttpService"):JSONDecode(jsonString)
    else
        return {}
    end
end

-- Function to compare items
local function compareItems(savedItems)
    for folderName, folder in pairs(ClientItemInfo:GetChildren()) do
        if folder:IsA("Folder") then
            local itemImage = folder:FindFirstChild("ItemImage")
            if itemImage and itemImage:IsA("StringValue") then
                local found = false
                
                for _, savedItem in ipairs(savedItems) do
                    if savedItem.ItemImage == itemImage.Value then
                        found = true
                        break
                    end
                end
                
                -- Change the background color based on whether the item was found
                local ImageFrame = createImageFrame(itemImage.Value, folder)
                if found then
                    ImageFrame.BackgroundColor3 = Color3.new(0, 1, 0) -- Green
                else
                    ImageFrame.BackgroundColor3 = Color3.new(1, 0, 0) -- Red
                end
            end
        end
    end
end

-- Load saved items and compare them when the script runs
local savedItems = loadItems()
compareItems(savedItems)