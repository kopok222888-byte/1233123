-- // UILib.lua – Drawing‑based UI для Roblox эксплоитов (v2)
local UILib = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local mouse = Vector2.zero
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mouse = Vector2.new(input.Position.X, input.Position.Y)
	end
end)

-- Проверка попадания точки в прямоугольник
local function isInRect(point, rectPos, rectSize)
	return point.X >= rectPos.X and point.X <= rectPos.X + rectSize.X and
		point.Y >= rectPos.Y and point.Y <= rectPos.Y + rectSize.Y
end

function UILib:CreateWindow(config)
	config = config or {}
	local name = config.Name or "Window"
	local pos = config.Position or Vector2.new(200, 200)
	local size = config.Size or Vector2.new(400, 350)
	local objects = {}
	local children = {} -- храним интерактивные элементы: кнопки, слайдеры
	local dragging = false
	local dragOffset = Vector2.zero
	local mouseDown = false
	local mouseClicked = false
	local lastMouseDown = false

	-- Фон
	local bg = Drawing.new("Square")
	bg.Color = Color3.fromRGB(25, 25, 25)
	bg.Size = size
	bg.Position = pos
	bg.Filled = true
	bg.Visible = true
	table.insert(objects, bg)

	-- Заголовок
	local titleBar = Drawing.new("Square")
	titleBar.Color = Color3.fromRGB(45, 45, 45)
	titleBar.Size = Vector2.new(size.X, 30)
	titleBar.Position = pos
	titleBar.Filled = true
	titleBar.Visible = true
	table.insert(objects, titleBar)

	local titleText = Drawing.new("Text")
	titleText.Text = name
	titleText.Color = Color3.fromRGB(255, 255, 255)
	titleText.Size = 16
	titleText.Position = pos + Vector2.new(5, 5)
	titleText.Visible = true
	table.insert(objects, titleText)

	-- Кнопка закрытия
	local closeBtnPos = pos + Vector2.new(size.X - 25, 0)
	local closeBtnSize = Vector2.new(25, 25)
	local closeBtn = Drawing.new("Square")
	closeBtn.Color = Color3.fromRGB(180, 40, 40)
	closeBtn.Size = closeBtnSize
	closeBtn.Position = closeBtnPos
	closeBtn.Filled = true
	closeBtn.Visible = true
	table.insert(objects, closeBtn)

	local closeText = Drawing.new("Text")
	closeText.Text = "X"
	closeText.Color = Color3.fromRGB(255, 255, 255)
	closeText.Size = 14
	closeText.Position = closeBtnPos + Vector2.new(6, 3)
	closeText.Visible = true
	table.insert(objects, closeText)

	-- Перемещение всех элементов на delta
	local function moveAll(delta)
		pos = pos + delta
		for _, obj in ipairs(objects) do
			obj.Position = obj.Position + delta
		end
		-- Обновляем позиции в children (кнопки, слайдеры)
		for _, child in ipairs(children) do
			if child.Type == "Button" then
				child.Btn.Position = child.Btn.Position + delta
				child.Text.Position = child.Text.Position + delta
			elseif child.Type == "Slider" then
				child.Label.Position = child.Label.Position + delta
				child.Bar.Position = child.Bar.Position + delta
				child.Fill.Position = child.Fill.Position + delta
			end
		end
	end

	-- Главный цикл обработки ввода
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local currentMouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		-- Определяем одиночный клик (переход от не нажатой к нажатой)
		if currentMouseDown and not lastMouseDown then
			mouseClicked = true
		else
			mouseClicked = false
		end

		-- Логика перетаскивания окна
		if mouseClicked and isInRect(mouse, pos, Vector2.new(size.X, 30)) then
			dragging = true
			dragOffset = pos - mouse
		end
		if dragging and currentMouseDown then
			local newPos = mouse + dragOffset
			local delta = newPos - pos
			moveAll(delta)
		else
			dragging = false
		end

		-- Обработка кликов по кнопкам
		if mouseClicked then
			-- Проверка кнопки закрытия
			if isInRect(mouse, closeBtnPos, closeBtnSize) then
				for _, obj in ipairs(objects) do
					obj:Remove()
				end
				connection:Disconnect()
				activeWindows[name] = nil
				return
			end

			-- Проверка пользовательских кнопок и слайдеров
			for _, child in ipairs(children) do
				if child.Type == "Button" then
					if isInRect(mouse, child.Btn.Position, child.Btn.Size) then
						child.Callback()
					end
				elseif child.Type == "Slider" then
					if isInRect(mouse, child.Bar.Position, child.Bar.Size) then
						child.Dragging = true
					end
				end
			end
		end

		-- Обработка перетаскивания слайдера
		for _, child in ipairs(children) do
			if child.Type == "Slider" and child.Dragging then
				if not currentMouseDown then
					child.Dragging = false
				else
					local bar = child.Bar
					local percent = math.clamp((mouse.X - bar.Position.X) / bar.Size.X, 0, 1)
					local val = child.Min + (child.Max - child.Min) * percent
					val = math.floor(val * 10) / 10
					child.Fill.Size = Vector2.new(percent * bar.Size.X, bar.Size.Y)
					child.Label.Text = tostring(val)
					child.Callback(val)
				end
			end
		end

		lastMouseDown = currentMouseDown
	end)

	-- Объект окна
	local windowObj = {
		Objects = objects,
		Children = children,
		Name = name,
	}

	-- Метод: кнопка
	function windowObj:CreateButton(text, callback)
		local yOffset = 40 + #children * 35
		local btnPos = pos + Vector2.new(10, yOffset)
		local btnSize = Vector2.new(size.X - 20, 30)

		local btn = Drawing.new("Square")
		btn.Color = Color3.fromRGB(70, 70, 70)
		btn.Size = btnSize
		btn.Position = btnPos
		btn.Filled = true
		btn.Visible = true
		table.insert(objects, btn)

		local btnText = Drawing.new("Text")
		btnText.Text = text
		btnText.Color = Color3.fromRGB(255, 255, 255)
		btnText.Size = 14
		btnText.Position = btnPos + Vector2.new(5, 5)
		btnText.Visible = true
		table.insert(objects, btnText)

		table.insert(children, {
			Type = "Button",
			Btn = btn,
			Text = btnText,
			Callback = callback or function() end,
		})
	end

	-- Метод: слайдер
	function windowObj:CreateSlider(min, max, default, callback)
		min = min or 0
		max = max or 100
		default = math.clamp(default or 0, min, max)

		local yOffset = 40 + #children * 35
		local labelPos = pos + Vector2.new(10, yOffset)
		local barPos = labelPos + Vector2.new(50, 10)
		local barSize = Vector2.new(size.X - 80, 10)

		-- Метка
		local label = Drawing.new("Text")
		label.Text = tostring(default)
		label.Color = Color3.fromRGB(255, 255, 255)
		label.Size = 14
		label.Position = labelPos
		label.Visible = true
		table.insert(objects, label)

		-- Полоса
		local bar = Drawing.new("Square")
		bar.Color = Color3.fromRGB(50, 50, 50)
		bar.Size = barSize
		bar.Position = barPos
		bar.Filled = true
		bar.Visible = true
		table.insert(objects, bar)

		-- Заполнение
		local fill = Drawing.new("Square")
		local percent = (default - min) / (max - min)
		fill.Color = Color3.fromRGB(100, 150, 255)
		fill.Size = Vector2.new(percent * barSize.X, barSize.Y)
		fill.Position = barPos
		fill.Filled = true
		fill.Visible = true
		table.insert(objects, fill)

		table.insert(children, {
			Type = "Slider",
			Label = label,
			Bar = bar,
			Fill = fill,
			Min = min,
			Max = max,
			Dragging = false,
			Callback = callback or function() end,
		})
	end

	return windowObj
end

return UILib
