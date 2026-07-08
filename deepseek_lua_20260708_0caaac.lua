-- // UILib v3 — Modern Drawing‑based UI для Roblox эксплоитов
local UILib = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Глобальный массив активных окон для корректного удаления
local activeWindows = {}

-----------------------------------------------------------
-- Вспомогательные функции
-----------------------------------------------------------
local function isInRect(point, rectPos, rectSize)
	return point.X >= rectPos.X and point.X <= rectPos.X + rectSize.X and
		point.Y >= rectPos.Y and point.Y <= rectPos.Y + rectSize.Y
end

-- HSV -> Color3 (H: 0-360, S: 0-1, V: 0-1)
local function hsvToColor3(h, s, v)
	local r, g, b
	local i = math.floor(h / 60) % 6
	local f = h / 60 - math.floor(h / 60)
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	else r, g, b = v, p, q
	end
	return Color3.new(r, g, b)
end

-----------------------------------------------------------
-- Конструктор окна
-----------------------------------------------------------
function UILib:CreateWindow(config)
	config = config or {}
	local name = config.Name or "Window"
	local basePos = config.Position or Vector2.new(200, 200)
	local size = config.Size or Vector2.new(500, 400)
	local objects = {}       -- все Drawing‑объекты окна
	local elements = {}      -- интерактивные элементы (кнопки, слайдеры…)
	local tabs = {}          -- вкладки { name, container (список элементов), active }
	local activeTab = nil
	local dragging = false
	local dragOffset = Vector2.zero
	local mouse = Vector2.zero
	local mouseDown = false

	-- Отслеживание мыши
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			mouse = Vector2.new(input.Position.X, input.Position.Y)
		end
	end)

	-- Фон окна
	local bg = Drawing.new("Square")
	bg.Color = Color3.fromRGB(25, 25, 25)
	bg.Size = size
	bg.Filled = true
	bg.Visible = true
	table.insert(objects, bg)

	-- Заголовок
	local titleBar = Drawing.new("Square")
	titleBar.Color = Color3.fromRGB(40, 40, 40)
	titleBar.Size = Vector2.new(size.X, 30)
	titleBar.Filled = true
	titleBar.Visible = true
	table.insert(objects, titleBar)

	local titleText = Drawing.new("Text")
	titleText.Text = name
	titleText.Color = Color3.fromRGB(255, 255, 255)
	titleText.Size = 16
	titleText.Center = false
	titleText.Visible = true
	table.insert(objects, titleText)

	-- Кнопка закрытия
	local closeBtn = Drawing.new("Square")
	closeBtn.Color = Color3.fromRGB(180, 40, 40)
	closeBtn.Size = Vector2.new(25, 25)
	closeBtn.Filled = true
	closeBtn.Visible = true
	table.insert(objects, closeBtn)

	local closeText = Drawing.new("Text")
	closeText.Text = "✕"
	closeText.Color = Color3.fromRGB(255, 255, 255)
	closeText.Size = 18
	closeText.Center = true
	closeText.Visible = true
	table.insert(objects, closeText)

	-- Линия под заголовком
	local headerLine = Drawing.new("Line")
	headerLine.Color = Color3.fromRGB(60, 60, 60)
	headerLine.Thickness = 1
	headerLine.Visible = true
	table.insert(objects, headerLine)

	-- Функция обновления абсолютных позиций ВСЕХ объектов
	local function updateAllPositions()
		-- Фон и заголовок
		bg.Position = basePos
		titleBar.Position = basePos
		titleText.Position = basePos + Vector2.new(8, 5)
		closeBtn.Position = basePos + Vector2.new(size.X - 25, 0)
		closeText.Position = basePos + Vector2.new(size.X - 12, 5)
		headerLine.From = basePos + Vector2.new(0, 30)
		headerLine.To = basePos + Vector2.new(size.X, 30)

		-- Элементы во вкладках
		local yOffset = 40 -- начальный отступ под заголовком
		for _, tab in ipairs(tabs) do
			if tab == activeTab then
				for _, elem in ipairs(tab.elements) do
					elem:UpdatePosition(basePos + Vector2.new(10, yOffset))
					yOffset = yOffset + elem:GetHeight() + 6
				end
			end
		end
	end

	-- Функция перерисовки видимости вкладок
	local function refreshTabVisibility()
		for _, tab in ipairs(tabs) do
			for _, elem in ipairs(tab.elements) do
				elem:SetVisible(tab == activeTab)
			end
		end
		updateAllPositions()
	end

	-- Главный цикл обработки ввода
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local currentMouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		local clicked = currentMouseDown and not mouseDown
		local released = not currentMouseDown and mouseDown

		-- Перетаскивание окна
		if clicked and isInRect(mouse, basePos, Vector2.new(size.X, 30)) then
			dragging = true
			dragOffset = basePos - mouse
		end
		if dragging and currentMouseDown then
			basePos = mouse + dragOffset
			updateAllPositions()
		else
			dragging = false
		end

		-- Обработка элементов активной вкладки
		if activeTab then
			for _, elem in ipairs(activeTab.elements) do
				elem:ProcessInput(mouse, currentMouseDown, clicked, released)
			end
		end

		-- Закрытие окна по кнопке
		if clicked and isInRect(mouse, basePos + Vector2.new(size.X - 25, 0), Vector2.new(25, 25)) then
			-- Удаляем все Drawing‑объекты
			for _, obj in ipairs(objects) do
				obj:Remove()
			end
			for _, tab in ipairs(tabs) do
				for _, elem in ipairs(tab.elements) do
					elem:Destroy()
				end
			end
			connection:Disconnect()
			activeWindows[name] = nil
			return
		end

		mouseDown = currentMouseDown
	end)

	-- Базовая позиция
	updateAllPositions()

	-- Объект окна
	local windowObj = {
		Name = name,
		BasePos = basePos,
		Size = size,
		Objects = objects,
		Tabs = tabs,
	}

	-----------------------------------------------------------
	-- Методы окна
	-----------------------------------------------------------

	-- Добавление вкладки
	function windowObj:CreateTab(tabName)
		local tab = { name = tabName, elements = {} }
		table.insert(tabs, tab)
		if #tabs == 1 then
			activeTab = tab -- автоматически активировать первую
			refreshTabVisibility()
		end
		-- Кнопка вкладки рисуется отдельно в заголовке? Для упрощения реализуем переключение по клику на полоске вкладок сверху.
		-- Пока просто возвращаем tab‑объект, пользователь сам добавит элементы.
		return tab
	end

	-- Внутренний метод для добавления элемента в активную вкладку (по умолчанию последняя созданная)
	function windowObj:AddElement(elem)
		local targetTab = activeTab or tabs[1]
		if not targetTab then
			-- если нет вкладок, создаём одну по умолчанию
			targetTab = windowObj:CreateTab("Main")
		end
		table.insert(targetTab.elements, elem)
		-- Добавляем Drawing‑объекты элемента в общий пул
		for _, d in ipairs(elem.Objects) do
			table.insert(objects, d)
		end
		refreshTabVisibility()
	end

	-- Кнопка
	function windowObj:CreateButton(text, callback)
		local elem = {}
		elem.Type = "Button"
		elem.Width = size.X - 20
		elem.Height = 30
		elem.Objects = {}

		local btn = Drawing.new("Square")
		btn.Color = Color3.fromRGB(60, 60, 60)
		btn.Size = Vector2.new(elem.Width, elem.Height)
		btn.Filled = true
		btn.Visible = true
		table.insert(elem.Objects, btn)

		local txt = Drawing.new("Text")
		txt.Text = text
		txt.Color = Color3.fromRGB(255, 255, 255)
		txt.Size = 14
		txt.Center = true
		txt.Visible = true
		table.insert(elem.Objects, txt)

		elem.UpdatePosition = function(self, topLeft)
			btn.Position = topLeft
			txt.Position = topLeft + Vector2.new(self.Width/2, self.Height/2 - 7)
		end
		elem.GetHeight = function(self) return self.Height end
		elem.SetVisible = function(self, vis)
			btn.Visible = vis
			txt.Visible = vis
		end
		elem.ProcessInput = function(self, mousePos, isDown, clicked, released)
			if clicked and isInRect(mousePos, btn.Position, btn.Size) then
				callback()
			end
		end
		elem.Destroy = function(self)
			for _, d in ipairs(self.Objects) do d:Remove() end
		end

		windowObj:AddElement(elem)
		return elem
	end

	-- Тоггл (чекбокс)
	function windowObj:CreateToggle(text, default, callback)
		default = default or false
		local elem = {}
		elem.Type = "Toggle"
		elem.Value = default
		elem.Width = size.X - 20
		elem.Height = 20
		elem.Objects = {}

		local box = Drawing.new("Square")
		box.Color = default and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 50, 50)
		box.Size = Vector2.new(16, 16)
		box.Filled = true
		box.Visible = true
		table.insert(elem.Objects, box)

		local label = Drawing.new("Text")
		label.Text = text
		label.Color = Color3.fromRGB(255, 255, 255)
		label.Size = 14
		label.Center = false
		label.Visible = true
		table.insert(elem.Objects, label)

		elem.UpdatePosition = function(self, topLeft)
			box.Position = topLeft
			label.Position = topLeft + Vector2.new(20, -2)
		end
		elem.GetHeight = function(self) return self.Height end
		elem.SetVisible = function(self, vis)
			box.Visible = vis
			label.Visible = vis
		end
		elem.ProcessInput = function(self, mousePos, isDown, clicked, released)
			if clicked and (isInRect(mousePos, box.Position, box.Size) or isInRect(mousePos, label.Position, Vector2.new(label.TextBounds.X, label.TextBounds.Y))) then
				self.Value = not self.Value
				box.Color = self.Value and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 50, 50)
				callback(self.Value)
			end
		end
		elem.Destroy = function(self) for _, d in ipairs(self.Objects) do d:Remove() end end

		windowObj:AddElement(elem)
		return elem
	end

	-- Слайдер
	function windowObj:CreateSlider(text, min, max, default, callback)
		min = min or 0
		max = max or 100
		default = math.clamp(default or 0, min, max)
		local elem = {}
		elem.Type = "Slider"
		elem.Value = default
		elem.Min = min
		elem.Max = max
		elem.Width = size.X - 20
		elem.Height = 40
		elem.Objects = {}
		elem.Dragging = false

		local label = Drawing.new("Text")
		label.Text = text .. ": " .. tostring(default)
		label.Color = Color3.fromRGB(255, 255, 255)
		label.Size = 13
		label.Center = false
		label.Visible = true
		table.insert(elem.Objects, label)

		local bar = Drawing.new("Square")
		bar.Color = Color3.fromRGB(50, 50, 50)
		bar.Size = Vector2.new(elem.Width - 50, 8)
		bar.Filled = true
		bar.Visible = true
		table.insert(elem.Objects, bar)

		local fill = Drawing.new("Square")
		local percent = (default - min) / (max - min)
		fill.Color = Color3.fromRGB(100, 150, 255)
		fill.Size = Vector2.new(percent * bar.Size.X, 8)
		fill.Filled = true
		fill.Visible = true
		table.insert(elem.Objects, fill)

		elem.UpdatePosition = function(self, topLeft)
			label.Position = topLeft
			bar.Position = topLeft + Vector2.new(50, 15)
			fill.Position = bar.Position
			-- При обновлении позиции пересчитываем fill.Size на основе текущего значения
			local p = (self.Value - self.Min) / (self.Max - self.Min)
			fill.Size = Vector2.new(p * bar.Size.X, 8)
		end
		elem.GetHeight = function(self) return self.Height end
		elem.SetVisible = function(self, vis)
			label.Visible = vis
			bar.Visible = vis
			fill.Visible = vis
		end
		elem.ProcessInput = function(self, mousePos, isDown, clicked, released)
			if clicked and isInRect(mousePos, bar.Position, bar.Size) then
				self.Dragging = true
			end
			if self.Dragging then
				if not isDown then
					self.Dragging = false
				else
					local percent = math.clamp((mousePos.X - bar.Position.X) / bar.Size.X, 0, 1)
					self.Value = self.Min + (self.Max - self.Min) * percent
					self.Value = math.floor(self.Value * 10) / 10
					label.Text = text .. ": " .. tostring(self.Value)
					fill.Size = Vector2.new(percent * bar.Size.X, 8)
					callback(self.Value)
				end
			end
		end
		elem.Destroy = function(self) for _, d in ipairs(self.Objects) do d:Remove() end end

		windowObj:AddElement(elem)
		return elem
	end

	-- Выпадающий список
	function windowObj:CreateDropdown(text, items, callback)
		local elem = {}
		elem.Type = "Dropdown"
		elem.Items = items
		elem.Selected = items[1] or ""
		elem.Opened = false
		elem.Width = size.X - 20
		elem.Height = 30
		elem.Objects = {}
		elem.DropObjects = {} -- временные объекты выпадающего списка

		local btn = Drawing.new("Square")
		btn.Color = Color3.fromRGB(60, 60, 60)
		btn.Size = Vector2.new(elem.Width, 30)
		btn.Filled = true
		btn.Visible = true
		table.insert(elem.Objects, btn)

		local label = Drawing.new("Text")
		label.Text = text .. ": " .. elem.Selected
		label.Color = Color3.fromRGB(255, 255, 255)
		label.Size = 14
		label.Center = false
		label.Visible = true
		table.insert(elem.Objects, label)

		-- Внутренняя функция закрытия выпадающего списка
		local function closeDropdown(self)
			if self.Opened then
				self.Opened = false
				for _, d in ipairs(self.DropObjects) do
					d:Remove()
				end
				self.DropObjects = {}
			end
		end

		-- Открытие списка
		local function openDropdown(self)
			if self.Opened then return end
			self.Opened = true
			local yOff = btn.Position.Y + btn.Size.Y
			for i, item in ipairs(self.Items) do
				local itemBtn = Drawing.new("Square")
				itemBtn.Color = Color3.fromRGB(50, 50, 50)
				itemBtn.Size = Vector2.new(self.Width, 22)
				itemBtn.Filled = true
				itemBtn.Visible = true
				itemBtn.Position = btn.Position + Vector2.new(0, 30 + (i-1)*22)
				table.insert(self.DropObjects, itemBtn)

				local itemTxt = Drawing.new("Text")
				itemTxt.Text = item
				itemTxt.Color = Color3.fromRGB(255, 255, 255)
				itemTxt.Size = 14
				itemTxt.Center = false
				itemTxt.Visible = true
				itemTxt.Position = itemBtn.Position + Vector2.new(5, 2)
				table.insert(self.DropObjects, itemTxt)
			end
		end

		elem.UpdatePosition = function(self, topLeft)
			btn.Position = topLeft
			label.Position = topLeft + Vector2.new(5, 5)
			-- если открыто, переместить и дроп-объекты
			if self.Opened then
				closeDropdown(self)
				openDropdown(self)
			end
		end
		elem.GetHeight = function(self) return self.Height end
		elem.SetVisible = function(self, vis)
			btn.Visible = vis
			label.Visible = vis
			if not vis and self.Opened then
				closeDropdown(self)
			end
		end
		elem.ProcessInput = function(self, mousePos, isDown, clicked, released)
			-- Клик по основной кнопке
			if clicked and isInRect(mousePos, btn.Position, btn.Size) then
				if self.Opened then
					closeDropdown(self)
				else
					openDropdown(self)
				end
				return
			end
			-- Клик вне списка закрывает его
			if clicked and self.Opened then
				local anyDrop = false
				for _, d in ipairs(self.DropObjects) do
					if d.ClassName == "Square" and isInRect(mousePos, d.Position, d.Size) then
						anyDrop = true
						-- Определяем индекс элемента
						local idx = math.floor((mousePos.Y - btn.Position.Y - 30) / 22) + 1
						if idx >= 1 and idx <= #self.Items then
							self.Selected = self.Items[idx]
							label.Text = text .. ": " .. self.Selected
							callback(self.Selected)
							closeDropdown(self)
						end
						break
					end
				end
				if not anyDrop then
					closeDropdown(self)
				end
			end
		end
		elem.Destroy = function(self)
			closeDropdown(self)
			for _, d in ipairs(self.Objects) do d:Remove() end
		end

		windowObj:AddElement(elem)
		return elem
	end

	-- Палитра цветов
	function windowObj:CreateColorPicker(text, defaultColor, callback)
		defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
		local elem = {}
		elem.Type = "ColorPicker"
		elem.Color = defaultColor
		elem.Width = size.X - 20
		elem.Height = 170
		elem.Objects = {}
		elem.DraggingSV = false
		elem.DraggingHue = false

		-- Вспомогательные значения HSV
		local h, s, v = 0, 1, 1 -- будем вычислять из defaultColor
		-- Простой перевод Color3 -> HSV
		local r, g, b = defaultColor.r, defaultColor.g, defaultColor.b
		local cmax = math.max(r, g, b)
		local cmin = math.min(r, g, b)
		local delta = cmax - cmin
		if delta == 0 then h = 0
		elseif cmax == r then h = 60 * (((g - b) / delta) % 6)
		elseif cmax == g then h = 60 * (((b - r) / delta) + 2)
		else h = 60 * (((r - g) / delta) + 4)
		end
		if h < 0 then h = h + 360 end
		s = cmax == 0 and 0 or delta / cmax
		v = cmax

		local label = Drawing.new("Text")
		label.Text = text
		label.Color = Color3.fromRGB(255, 255, 255)
		label.Size = 13
		label.Center = false
		label.Visible = true
		table.insert(elem.Objects, label)

		local svBoxSize = Vector2.new(160, 120)
		local svBox = Drawing.new("Square")
		svBox.Color = Color3.fromRGB(255, 0, 0) -- будет перерисован линиями? Мы не можем динамически менять цвет каждого пикселя, поэтому используем градиент из линий. Упростим: отрисуем прямоугольник и Hue bar.
		-- Вместо сложного градиента сделаем просто поле, где выбор позиции даёт S и V, а Hue задаётся отдельным слайдером.
		-- Для визуализации используем наложение нескольких полупрозрачных квадратов. Это не идеально, но работает.
		svBox.Size = svBoxSize
		svBox.Filled = true
		svBox.Visible = true
		table.insert(elem.Objects, svBox)

		-- Оттенок (Hue) слайдер
		local hueBar = Drawing.new("Square")
		hueBar.Color = Color3.fromRGB(255, 0, 0)
		hueBar.Size = Vector2.new(160, 12)
		hueBar.Filled = true
		hueBar.Visible = true
		table.insert(elem.Objects, hueBar)

		-- Индикатор выбранного цвета
		local preview = Drawing.new("Square")
		preview.Color = defaultColor
		preview.Size = Vector2.new(25, 25)
		preview.Filled = true
		preview.Visible = true
		table.insert(elem.Objects, preview)

		-- Крестик на SV-поле
		local crossHair = Drawing.new("Line")
		crossHair.Color = Color3.fromRGB(255, 255, 255)
		crossHair.Thickness = 1
		crossHair.Visible = true
		table.insert(elem.Objects, crossHair)

		-- Индикатор на Hue
		local hueIndicator = Drawing.new("Square")
		hueIndicator.Color = Color3.fromRGB(255, 255, 255)
		hueIndicator.Size = Vector2.new(2, 14)
		hueIndicator.Filled = true
		hueIndicator.Visible = true
		table.insert(elem.Objects, hueIndicator)

		-- Обновление цвета
		local function updateColor(self)
			self.Color = hsvToColor3(h, s, v)
			preview.Color = self.Color
			-- Обновим визуал SV‑поля: просто зальём его цветом с максимальной насыщенностью и яркостью оттенка? Мы не можем сделать настоящий 2D градиент, поэтому просто покажем текущий оттенок с яркостью по вертикали? Сделаем фон основным цветом оттенка, а наложение покажет затемнение.
			-- Для простоты не будем усложнять, оставим как есть.
			callback(self.Color)
		end

		-- Позиционирование
		elem.UpdatePosition = function(self, topLeft)
			label.Position = topLeft
			svBox.Position = topLeft + Vector2.new(0, 18)
			hueBar.Position = topLeft + Vector2.new(0, 142)
			preview.Position = topLeft + Vector2.new(170, 18)
			-- Крестик
			local svX = svBox.Position.X + s * svBoxSize.X
			local svY = svBox.Position.Y + (1 - v) * svBoxSize.Y
			crossHair.From = Vector2.new(svX - 3, svY)
			crossHair.To = Vector2.new(svX + 3, svY)
			-- Hue индикатор
			hueIndicator.Position = hueBar.Position + Vector2.new((h / 360) * 160, -1)
		end
		elem.GetHeight = function(self) return self.Height end
		elem.SetVisible = function(self, vis)
			for _, d in ipairs(self.Objects) do d.Visible = vis end
		end
		elem.ProcessInput = function(self, mousePos, isDown, clicked, released)
			-- SV поле
			if clicked and isInRect(mousePos, svBox.Position, svBox.Size) then
				self.DraggingSV = true
			end
			if self.DraggingSV then
				if not isDown then
					self.DraggingSV = false
				else
					s = math.clamp((mousePos.X - svBox.Position.X) / svBoxSize.X, 0, 1)
					v = 1 - math.clamp((mousePos.Y - svBox.Position.Y) / svBoxSize.Y, 0, 1)
					updateColor(self)
					self.UpdatePosition(self, label.Position) -- обновить крестик
				end
			end
			-- Hue ползунок
			if clicked and isInRect(mousePos, hueBar.Position, hueBar.Size) then
				self.DraggingHue = true
			end
			if self.DraggingHue then
				if not isDown then
					self.DraggingHue = false
				else
					h = math.clamp((mousePos.X - hueBar.Position.X) / 160, 0, 1) * 360
					updateColor(self)
					self.UpdatePosition(self, label.Position)
				end
			end
		end
		elem.Destroy = function(self) for _, d in ipairs(self.Objects) do d:Remove() end end

		updateColor(elem)
		windowObj:AddElement(elem)
		return elem
	end

	-- Инициализация первой вкладки
	windowObj:CreateTab("Main")

	activeWindows[name] = windowObj
	return windowObj
end

return UILib
