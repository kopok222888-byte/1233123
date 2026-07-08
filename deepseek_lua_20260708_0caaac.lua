-- Исправленная UILib (GameSense стиль, перетаскивание, бинды, обводка)
local UILib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local function create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local Window = {}
Window.__index = Window

function UILib:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Menu"
    local font = config.Font or Enum.Font.Gotham
    local accent = config.Accent or Color3.fromRGB(65, 130, 255)

    local gui = create("ScreenGui", {
        Name = title,
        Parent = config.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    })

    local mainFrame = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 540, 0, 340),
        Position = UDim2.new(0.5, -270, 0.5, -170),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = gui
    })
    create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = mainFrame})

    local topBar = create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = topBar})

    local titleLabel = create("TextLabel", {
        Name = "Title",
        Text = title,
        FontFace = Font.new(font.Name, Enum.FontWeight.Bold),
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = titleLabel})

    -- Перетаскивание
    local dragging = false
    local dragStart, startPos

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local tabContainer = create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 130, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = tabContainer})
    local tabList = create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabContainer
    })
    create("UIPadding", {PaddingTop = UDim.new(0, 4), Parent = tabContainer})

    local contentArea = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -130, 1, -36),
        Position = UDim2.new(0, 130, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = mainFrame
    })

    local tabs = {}
    local currentTab = nil

    local function switchTab(tab)
        if currentTab then
            currentTab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            currentTab.frame.Visible = false
        end
        currentTab = tab
        tab.button.BackgroundColor3 = accent
        tab.frame.Visible = true
    end

    local windowObject = setmetatable({}, Window)
    windowObject.MainFrame = mainFrame
    windowObject.Tabs = tabs

    function windowObject:CreateTab(name, iconId)
        local tabFrame = create("Frame", {
            Name = name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = contentArea
        })
        local scroll = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = accent,
            BorderSizePixel = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,  -- исправлено!
            Parent = tabFrame
        })
        local list = create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = scroll
        })
        create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = scroll})

        local tabButton = create("TextButton", {
            Name = name,
            Text = "",
            FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
            TextSize = 13,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 28),
            Parent = tabContainer
        })
        create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = tabButton})

        if iconId then
            local icon = create("ImageLabel", {
                Image = "rbxassetid://" .. tostring(iconId),
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 6, 0.5, -8),
                BackgroundTransparency = 1,
                Parent = tabButton
            })
            local textLabel = create("TextLabel", {
                Text = name,
                FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 26, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabButton
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = textLabel})
        else
            local textOnly = create("TextLabel", {
                Text = name,
                FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabButton
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = textOnly})
        end

        local tabData = {button = tabButton, frame = tabFrame, scroll = scroll}
        table.insert(tabs, tabData)

        tabButton.MouseButton1Click:Connect(function()
            switchTab(tabData)
        end)

        if #tabs == 1 then
            switchTab(tabData)
        end

        -- Методы для вкладки
        local tabMethods = {}

        function tabMethods:AddButton(text, callback)
            local btn = create("TextButton", {
                Text = text,
                FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -20, 0, 30),
                Parent = scroll
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = btn})
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = btn})
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function tabMethods:AddSlider(text, min, max, default, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 44),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = scroll
            })
            local label = create("TextLabel", {
                Text = text .. ": " .. tostring(default),
                FontFace = Font.new(font.Name, Enum.FontWeight.Regular),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = label})

            local sliderFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 0, 24),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 0,
                Parent = frame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = sliderFrame})

            local fill = create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                Parent = sliderFrame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = fill})

            local knob = create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = sliderFrame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = knob})

            local draggingSlider = false
            local button = create("TextButton", {
                Text = "",
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = sliderFrame
            })

            button.MouseButton1Down:Connect(function()
                draggingSlider = true
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos + 0.5)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    knob.Position = UDim2.new(pos, -6, 0.5, -6)
                    label.Text = text .. ": " .. tostring(val)
                    callback(val)
                end
            end)
            return frame
        end

        function tabMethods:AddToggle(text, default, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 30),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = scroll
            })
            local label = create("TextLabel", {
                Text = text,
                FontFace = Font.new(font.Name, Enum.FontWeight.Regular),
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = label})

            local toggleFrame = create("Frame", {
                Size = UDim2.new(0, 32, 0, 18),
                Position = UDim2.new(1, -32, 0.5, -9),
                BackgroundColor3 = default and accent or Color3.fromRGB(80, 80, 80),
                BorderSizePixel = 0,
                Parent = frame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = toggleFrame})

            local dot = create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = toggleFrame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = dot})

            local state = default
            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    TweenService:Create(dot, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                    toggleFrame.BackgroundColor3 = state and accent or Color3.fromRGB(80, 80, 80)
                    callback(state)
                end
            end)
            return frame
        end

        function tabMethods:AddDropdown(text, options, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 36),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = scroll
            })
            local label = create("TextButton", {
                Text = text .. ": " .. (options[1] or ""),
                FontFace = Font.new(font.Name, Enum.FontWeight.Regular),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = label})
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = label})

            local expanded = false
            local dropdownFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, #options * 28),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0,
                Visible = false,
                Parent = frame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = dropdownFrame})
            local dropList = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdownFrame})
            for i, option in ipairs(options) do
                local optBtn = create("TextButton", {
                    Text = option,
                    FontFace = Font.new(font.Name, Enum.FontWeight.Regular),
                    TextSize = 13,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Parent = dropdownFrame
                })
                create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = optBtn})
                create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = optBtn})
                optBtn.MouseButton1Click:Connect(function()
                    label.Text = text .. ": " .. option
                    dropdownFrame.Visible = false
                    expanded = false
                    callback(option)
                end)
            end
            label.MouseButton1Click:Connect(function()
                expanded = not expanded
                dropdownFrame.Visible = expanded
            end)
            return frame
        end

        function tabMethods:AddBind(text, defaultKey, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 30),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = scroll
            })
            local label = create("TextLabel", {
                Text = text,
                FontFace = Font.new(font.Name, Enum.FontWeight.Regular),
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 100, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = label})

            local bindButton = create("TextButton", {
                Text = defaultKey and "[" .. defaultKey.Name .. "]" or "[None]",
                FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 90, 1, 0),
                Position = UDim2.new(1, -90, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = frame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = bindButton})
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = bindButton})

            local currentKey = defaultKey
            local waiting = false

            bindButton.MouseButton1Click:Connect(function()
                waiting = true
                bindButton.Text = "[...]"
            end)

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if waiting and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        bindButton.Text = "[" .. currentKey.Name .. "]"
                        callback(currentKey)
                        waiting = false
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        waiting = false
                        bindButton.Text = currentKey and "[" .. currentKey.Name .. "]" or "[None]"
                    end
                end
            end)
            return frame
        end

        return tabMethods
    end

    -- Горячая клавиша Insert
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    return windowObject
end

return UILib