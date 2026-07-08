-- // UILib.lua – UI Library for Roblox Exploits
local UILib = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Внутренние переменные
local activeWindows = {}
local mouse = UserInputService:GetMouseLocation() -- стартовое положение мыши

-- Обновление позиции мыши каждый кадр
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		mouse = input.Position
	end
end)

-- Функция создания окна
function UILib:CreateWindow(config)
	config = config or {}
	local name = config.Name or "Window"
	local pos = config.Position or Vector2.new(200, 200)
	local size = config.Size or Vector2.new(400, 350)

	-- Таблица объектов Drawing
	local objects = {}
	local dragging = false
	local dragStart = nil
	local offset = Vector2.zero

	-- Фон окна
	local bg = Drawing.new("Square")
	bg.Color = Color3.fromRGB(25, 25, 25)
	bg.Size = size
	bg.Position = pos
	bg.Filled = true
	bg.Visible = true
	table.insert(objects, bg)

	-- Заголовок (область перетаскивания)
	local titleBar = Drawing.new("Square")
	titleBar.Color = Color3.fromRGB(45, 45, 45)
	titleBar.Size = Vector2.new(size.X, 30)
	titleBar.Position = pos
	titleBar.Filled = true
	titleBar.Visible = true
	table.insert(objects, titleBar)

	-- Текст заголовка
	local titleText = Drawing.new("Text")
	titleText.Text = name
	titleText.Color = Color3.fromRGB(255, 255, 255)
	titleText.Size = 16
	titleText.Position = pos + Vector2.new(5, 5)
	titleText.Visible = true
	table.insert(objects, titleText)

	-- Кнопка закрытия
	local closeBtn = Drawing.new("Square")
	closeBtn.Color = Color3.fromRGB(180, 40, 40)
	closeBtn.Size = Vector2.new(25, 25)
	closeBtn.Position = pos + Vector2.new(size.X - 25, 0)
	closeBtn.Filled = true
	closeBtn.Visible = true
	table.insert(objects, closeBtn)

	local closeText = Drawing.new("Text")
	closeText.Text = "X"
	closeText.Color = Color3.fromRGB(255, 255, 255)
	closeText.Size = 14
	closeText.Position = pos + Vector2.new(size.X - 20, 3)
	closeText.Visible = true
	table.insert(objects, closeText)

	-- Функция обновления позиции всех элементов
	local function updatePositions(newPos)
		local diff = newPos - pos
		pos = newPos
		for _, obj in ipairs(objects) do
			obj.Position = obj.Position + diff
		end
	end

	-- Обработка перетаскивания
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			offset = pos - dragStart
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- Логика перемещения (в RenderStepped)
	RunService.RenderStepped:Connect(function()
		if dragging then
			local newPos = mouse + offset
			updatePositions(newPos)
		end
	end)

	-- Закрытие окна
	closeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			for _, obj in ipairs(objects) do
				obj:Remove()
			end
			activeWindows[name] = nil
		end
	end)

	-- Сохраняем ссылки
	local windowObj = {
		Objects = objects,
		Name = name,
		Position = pos,
		Size = size,
	}
	activeWindows[name] = windowObj

	-- Метод добавления кнопки
	function windowObj:CreateButton(text, callback)
		local btnSize = Vector2.new(size.X - 20, 30)
		local yOffset = #objects * 35 + 40 -- смещение по вертикали
		local btnPos = pos + Vector2.new(10, yOffset)

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

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local mPos = mouse
				if mPos.X >= btnPos.X and mPos.X <= btnPos.X + btnSize.X and
				   mPos.Y >= btnPos.Y and mPos.Y <= btnPos.Y + btnSize.Y then
					callback()
				end
			end
		end)

		return {Button = btn, Text = btnText}
	end

	-- Метод добавления слайдера
	function windowObj:CreateSlider(min, max, default, callback)
		min = min or 0
		max = max or 100
		default = math.clamp(default or 0, min, max)

		local sliderWidth = size.X - 80
		local yOffset = #objects * 35 + 40
		local labelPos = pos + Vector2.new(10, yOffset)
		local sliderBarPos = labelPos + Vector2.new(50, 10)

		-- Метка значения
		local valText = Drawing.new("Text")
		valText.Text = tostring(default)
		valText.Color = Color3.fromRGB(255, 255, 255)
		valText.Size = 14
		valText.Position = labelPos
		valText.Visible = true
		table.insert(objects, valText)

		-- Полоса слайдера
		local sliderBar = Drawing.new("Square")
		sliderBar.Color = Color3.fromRGB(50, 50, 50)
		sliderBar.Size = Vector2.new(sliderWidth, 10)
		sliderBar.Position = sliderBarPos
		sliderBar.Filled = true
		sliderBar.Visible = true
		table.insert(objects, sliderBar)

		-- Заполнение
		local fill = Drawing.new("Square")
		local fillWidth = ((default - min) / (max - min)) * sliderWidth
		fill.Color = Color3.fromRGB(100, 150, 255)
		fill.Size = Vector2.new(fillWidth, 10)
		fill.Position = sliderBarPos
		fill.Filled = true
		fill.Visible = true
		table.insert(objects, fill)

		local draggingSlider = false

		local function updateValue()
			local mPos = mouse
			local percent = math.clamp((mPos.X - sliderBarPos.X) / sliderWidth, 0, 1)
			local val = min + (max - min) * percent
			val = math.floor(val * 10) / 10 -- округление до десятых
			fill.Size = Vector2.new(percent * sliderWidth, 10)
			valText.Text = tostring(val)
			callback(val)
		end

		sliderBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = true
				updateValue()
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = false
			end
		end)

		RunService.RenderStepped:Connect(function()
			if draggingSlider then
				updateValue()
			end
		end)

		return {Bar = sliderBar, Fill = fill, SetValue = function(v) end} -- можно доработать
	end

	return windowObj
end

return UILib
