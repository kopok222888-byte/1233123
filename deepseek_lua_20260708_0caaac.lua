-- UILibrary.lua
local Library = {}
Library.__index = Library

-- Создание главного GUI
function Library.new(title)
    local self = setmetatable({}, Library)
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "MainGUI"
    self.gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 400, 0, 300)
    self.mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.mainFrame.BackgroundTransparency = 0.1
    self.mainFrame.BorderSizePixel = 1
    self.mainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
    self.mainFrame.Parent = self.gui
    
    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleLabel.BackgroundTransparency = 0
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = title or "UI Library"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = self.mainFrame
    
    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = self.mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        self.gui:Destroy()
    end)
    
    -- Контейнер для вкладок и содержимого
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Size = UDim2.new(0, 100, 1, -30)
    self.tabsContainer.Position = UDim2.new(0, 0, 0, 30)
    self.tabsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.tabsContainer.BackgroundTransparency = 0
    self.tabsContainer.BorderSizePixel = 0
    self.tabsContainer.Parent = self.mainFrame
    
    self.contentContainer = Instance.new("ScrollingFrame")
    self.contentContainer.Size = UDim2.new(1, -100, 1, -30)
    self.contentContainer.Position = UDim2.new(0, 100, 0, 30)
    self.contentContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.contentContainer.BackgroundTransparency = 0
    self.contentContainer.BorderSizePixel = 0
    self.contentContainer.Parent = self.mainFrame
    self.contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.contentContainer.ScrollBarThickness = 6
    self.contentContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    
    self.tabs = {}
    self.currentTab = nil
    self.elements = {}
    
    return self
end

-- Добавление вкладки
function Library:AddTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, #self.tabs * 35 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 170, 255)
    btn.Parent = self.tabsContainer
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -10, 1, -10)
    content.Position = UDim2.new(0, 5, 0, 5)
    content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Parent = self.contentContainer
    content.Visible = false
    
    self.tabs[name] = {button = btn, content = content, elements = {}}
    
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    if not self.currentTab then
        self:SelectTab(name)
    end
    
    return self.tabs[name]
end

-- Выбор вкладки
function Library:SelectTab(name)
    if self.currentTab then
        self.tabs[self.currentTab].content.Visible = false
    end
    self.currentTab = name
    self.tabs[name].content.Visible = true
    -- Обновляем CanvasSize
    self:UpdateCanvas()
end

-- Обновление размера прокрутки
function Library:UpdateCanvas()
    local maxY = 0
    for _, tab in pairs(self.tabs) do
        if tab.content.Visible then
            local children = tab.content:GetChildren()
            for _, child in ipairs(children) do
                if child:IsA("GuiObject") and child.Visible then
                    local pos = child.Position.Y.Offset + child.Size.Y.Offset
                    if pos > maxY then maxY = pos end
                end
            end
        end
    end
    self.contentContainer.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
end

-- Добавление кнопки
function Library:AddButton(tabName, text, callback)
    local tab = self.tabs[tabName]
    if not tab then return end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, #tab.elements * 35 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 170, 255)
    btn.Parent = tab.content
    btn.MouseButton1Click:Connect(callback)
    table.insert(tab.elements, btn)
    self:UpdateCanvas()
end

-- Добавление ползунка (Slider)
function Library:AddSlider(tabName, text, min, max, default, callback)
    local tab = self.tabs[tabName]
    if not tab then return end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.Position = UDim2.new(0, 5, 0, #tab.elements * 45 + 5)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(0, 170, 255)
    frame.Parent = tab.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.5, -10, 0, 10)
    slider.Position = UDim2.new(0.5, 5, 0.5, -5)
    slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    slider.BackgroundTransparency = 0
    slider.BorderSizePixel = 1
    slider.BorderColor3 = Color3.fromRGB(0, 170, 255)
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BackgroundTransparency = 0
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local value = default
    local dragging = false
    
    local function updateValue(newValue)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
        if callback then callback(value) end
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local size = slider.AbsoluteSize.X
            local percent = math.clamp(pos / size, 0, 1)
            local val = min + (max - min) * percent
            updateValue(val)
        end
    end)
    
    table.insert(tab.elements, frame)
    self:UpdateCanvas()
end

-- Добавление бинда (Keybind)
function Library:AddKeybind(tabName, text, defaultKey, callback)
    local tab = self.tabs[tabName]
    if not tab then return end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Position = UDim2.new(0, 5, 0, #tab.elements * 40 + 5)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(0, 170, 255)
    frame.Parent = tab.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0.4, -10, 0.8, 0)
    keyBtn.Position = UDim2.new(0.6, 5, 0.1, 0)
    keyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    keyBtn.Text = defaultKey.Name or "None"
    keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBtn.TextScaled = true
    keyBtn.Font = Enum.Font.SourceSans
    keyBtn.BorderSizePixel = 1
    keyBtn.BorderColor3 = Color3.fromRGB(0, 170, 255)
    keyBtn.Parent = frame
    
    local key = defaultKey
    local isListening = false
    
    local function updateKey(newKey)
        key = newKey
        keyBtn.Text = newKey.Name or "None"
        -- Здесь можно сохранить бинд в настройки
    end
    
    keyBtn.MouseButton1Click:Connect(function()
        if isListening then return end
        isListening = true
        keyBtn.Text = "..."
        local connection
        connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                updateKey(input.KeyCode)
                isListening = false
                connection:Disconnect()
            end
        end)
    end)
    
    -- Обработка нажатия бинда (глобально)
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == key and callback then
            callback()
        end
    end)
    
    table.insert(tab.elements, frame)
    self:UpdateCanvas()
end

return Library
