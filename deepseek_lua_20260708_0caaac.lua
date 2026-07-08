-- UILib.lua (GameSense стиль, всё рабочее)
local UILib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

function UILib:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Menu"
    local font = cfg.Font or Enum.Font.Gotham
    local accent = cfg.Accent or Color3.fromRGB(65, 130, 255)

    local gui = create("ScreenGui", {Name = title, Parent = cfg.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")})

    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 540, 0, 340),
        Position = UDim2.new(0.5, -270, 0.5, -170),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = gui
    })
    create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = main})

    local topBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Parent = main
    })
    create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = topBar})

    local titleLabel = create("TextLabel", {
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
    local dragActive, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragActive and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = false
        end
    end)

    -- Контейнер вкладок
    local tabBar = create("Frame", {
        Size = UDim2.new(0, 130, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Parent = main
    })
    create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = tabBar})
    create("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = tabBar
    })
    create("UIPadding", {PaddingTop = UDim.new(0, 4), Parent = tabBar})

    -- Область контента
    local contentArea = create("Frame", {
        Size = UDim2.new(1, -130, 1, -36),
        Position = UDim2.new(0, 130, 0, 36),
        BackgroundTransparency = 1,
        Parent = main
    })

    local tabs = {}
    local currentTab = nil

    local function selectTab(tab)
        if currentTab then
            currentTab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            currentTab.content.Visible = false
        end
        currentTab = tab
        tab.button.BackgroundColor3 = accent
        tab.content.Visible = true
    end

    local window = {}

    function window:CreateTab(name, iconId)
        -- Контент вкладки
        local tabContent = create("Frame", {
            Name = name,
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
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = tabContent
        })
        create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = scroll
        })
        create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = scroll})

        -- Кнопка вкладки
        local tabBtn = create("TextButton", {
            Text = "",
            FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
            TextSize = 13,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 28),
            Parent = tabBar
        })
        create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = tabBtn})

        if iconId then
            create("ImageLabel", {
                Image = "rbxassetid://" .. tostring(iconId),
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 6, 0.5, -8),
                BackgroundTransparency = 1,
                Parent = tabBtn
            })
            local txt = create("TextLabel", {
                Text = name,
                FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 26, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabBtn
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = txt})
        else
            local txt = create("TextLabel", {
                Text = name,
                FontFace = Font.new(font.Name, Enum.FontWeight.SemiBold),
                TextSize = 13,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabBtn
            })
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = txt})
        end

        local tabData = {button = tabBtn, content = tabContent}
        table.insert(tabs, tabData)

        tabBtn.MouseButton1Click:Connect(function()
            selectTab(tabData)
        end)

        if #tabs == 1 then
            selectTab(tabData)
        end

        -- Методы добавления элементов
        local tab = {}

        function tab:AddButton(text, callback)
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

        function tab:AddSlider(text, min, max, default, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 44),
                BackgroundTransparency = 1,
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

            local sliderBg = create("Frame", {
                Size = UDim2.new(1, 0, 0, 4),
                Position = UDim2.new(0, 0, 0, 24),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 0,
                Parent = frame
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = sliderBg})

            local fill = create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                Parent = sliderBg
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = fill})

            local knob = create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = sliderBg
            })
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = knob})

            local draggingSlider = false
            local hitbox = create("TextButton", {
                Text = "",
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundTransparency = 1,
                Parent = sliderBg
            })
            hitbox.MouseButton1Down:Connect(function()
                draggingSlider = true
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pos + 0.5)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    knob.Position = UDim2.new(pos, -6, 0.5, -6)
                    label.Text = text .. ": " .. tostring(val)
                    callback(val)
                end
            end)
            return frame
        end

        function tab:AddToggle(text, default, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 30),
                BackgroundTransparency = 1,
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

        function tab:AddDropdown(text, options, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 36),
                BackgroundTransparency = 1,
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
            create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropdownFrame})

            for _, option in ipairs(options) do
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

        function tab:AddBind(text, defaultKey, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, -20, 0, 30),
                BackgroundTransparency = 1,
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

            local bindBtn = create("TextButton", {
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
            create("UIStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = bindBtn})
            create("TextStroke", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Parent = bindBtn})

            local currentKey = defaultKey
            local waiting = false

            bindBtn.MouseButton1Click:Connect(function()
                waiting = true
                bindBtn.Text = "[...]"
            end)

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if waiting and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        bindBtn.Text = "[" .. currentKey.Name .. "]"
                        callback(currentKey)
                        waiting = false
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        waiting = false
                        bindBtn.Text = currentKey and "[" .. currentKey.Name .. "]" or "[None]"
                    end
                end
            end)
            return frame
        end

        return tab
    end

    -- Insert hotkey
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            main.Visible = not main.Visible
        end
    end)

    return window
end

return UILib
