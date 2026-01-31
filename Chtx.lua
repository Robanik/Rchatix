-- LocalScript в StarterPlayerScripts
-- Имя: ChatGui

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Ждём RemoteEvents
local ChatEvent = game.ReplicatedStorage:WaitForChild("ChatEvent")
local PrivateChatEvent = game.ReplicatedStorage:WaitForChild("PrivateChatEvent")
local InviteEvent = game.ReplicatedStorage:WaitForChild("InviteEvent")
local InviteResponseEvent = game.ReplicatedStorage:WaitForChild("InviteResponseEvent")

-- Состояние
local currentMode = "global" -- "global" или "private"
local currentPrivateTarget = nil
local invitePopup = nil

-- ============================================================
-- СОЗДАНИЕ UI
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChatGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Фон чата
local chatFrame = Instance.new("Frame")
chatFrame.Name = "ChatFrame"
chatFrame.Size = UDim2.new(0.28, 0, 0.42, 0)
chatFrame.Position = UDim2.new(0, 10, 0.54, 0)
chatFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
chatFrame.BorderSizePixel = 0
chatFrame.Parent = screenGui

Instance.new("UICorner", chatFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(50, 50, 70)
stroke.Thickness = 1
stroke.Parent = chatFrame

-- Заголовок (Global / Private)
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 34)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = chatFrame

Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0, 10)

-- Кнопка "Общий"
local globalBtn = Instance.new("TextButton")
globalBtn.Name = "GlobalBtn"
globalBtn.Size = UDim2.new(0.5, -4, 1, -8)
globalBtn.Position = UDim2.new(0, 4, 0, 4)
globalBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 255)
globalBtn.BorderSizePixel = 0
globalBtn.Text = "Общий"
globalBtn.TextColor3 = Color3.new(1, 1, 1)
globalBtn.TextSize = 13
globalBtn.Font = Enum.Font.GothamBold
globalBtn.Parent = headerFrame

Instance.new("UICorner", globalBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка "Закрытый"
local privateBtn = Instance.new("TextButton")
privateBtn.Name = "PrivateBtn"
privateBtn.Size = UDim2.new(0.5, -4, 1, -8)
privateBtn.Position = UDim2.new(0.5, 0, 0, 4)
privateBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
privateBtn.BorderSizePixel = 0
privateBtn.Text = "Закрытый"
privateBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
privateBtn.TextSize = 13
privateBtn.Font = Enum.Font.GothamBold
privateBtn.Parent = headerFrame

Instance.new("UICorner", privateBtn).CornerRadius = UDim.new(0, 6)

-- Список игроков (появляется когда нажимаешь "Закрытый")
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerList"
playerListFrame.Size = UDim2.new(1, 0, 0.5, 0)
playerListFrame.Position = UDim2.new(0, 0, 0, 0)
playerListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.Visible = false
playerListFrame.Parent = chatFrame

Instance.new("UIListLayout", playerListFrame).Padding = UDim.new(0, 2)

-- Надпись "Выбери игрока"
local pickLabel = Instance.new("TextLabel")
pickLabel.Size = UDim2.new(1, 0, 0, 24)
pickLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
pickLabel.BorderSizePixel = 0
pickLabel.Text = "Выбери игрока:"
pickLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
pickLabel.TextSize = 12
pickLabel.Font = Enum.Font.Gotham
pickLabel.Parent = playerListFrame

-- Скролл для сообщений
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -79)
scrollFrame.Position = UDim2.new(0, 5, 0, 34)
scrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = chatFrame

Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 2)

-- Кто сейчас в приватном чате (надпись)
local privateTargetLabel = Instance.new("TextLabel")
privateTargetLabel.Size = UDim2.new(1, 0, 0, 22)
privateTargetLabel.Position = UDim2.new(0, 0, 0, 0)
privateTargetLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
privateTargetLabel.BorderSizePixel = 0
privateTargetLabel.Text = ""
privateTargetLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
privateTargetLabel.TextSize = 12
privateTargetLabel.Font = Enum.Font.GothamBold
privateTargetLabel.Visible = false
privateTargetLabel.Parent = chatFrame

-- Ввод сообщения
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -10, 0, 36)
inputFrame.Position = UDim2.new(0, 5, 1, -41)
inputFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = chatFrame

Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 6)

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.74, -5, 1, -8)
textBox.Position = UDim2.new(0, 4, 0, 4)
textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
textBox.BorderSizePixel = 0
textBox.Text = ""
textBox.PlaceholderText = "Напиши сообщение..."
textBox.TextColor3 = Color3.fromRGB(210, 210, 210)
textBox.TextSize = 13
textBox.Font = Enum.Font.Gotham
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.Parent = inputFrame

Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 5)

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0.24, -2, 1, -8)
sendButton.Position = UDim2.new(0.76, 2, 0, 4)
sendButton.BackgroundColor3 = Color3.fromRGB(70, 110, 255)
sendButton.BorderSizePixel = 0
sendButton.Text = "Отправить"
sendButton.TextColor3 = Color3.new(1, 1, 1)
sendButton.TextSize = 12
sendButton.Font = Enum.Font.GothamBold
sendButton.Parent = inputFrame

Instance.new("UICorner", sendButton).CornerRadius = UDim.new(0, 5)

-- ============================================================
-- ПОПАП ПРИГЛАШЕНИЯ (появляется у того кому пригласили)
-- ============================================================

local function createInvitePopup(inviterName)
	if invitePopup then
		invitePopup:Destroy()
		invitePopup = nil
	end

	invitePopup = Instance.new("Frame")
	invitePopup.Name = "InvitePopup"
	invitePopup.Size = UDim2.new(0.26, 0, 0, 110)
	invitePopup.Position = UDim2.new(0.37, 0, 0.05, 0)
	invitePopup.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
	invitePopup.BorderSizePixel = 0
	invitePopup.Parent = screenGui

	Instance.new("UICorner", invitePopup).CornerRadius = UDim.new(0, 12)

	local popStroke = Instance.new("UIStroke")
	popStroke.Color = Color3.fromRGB(70, 110, 255)
	popStroke.Thickness = 2
	popStroke.Parent = invitePopup

	-- Анимация появления
	invitePopup.Transparency = 1
	invitePopup.Position = UDim2.new(0.37, 0, 0.02, 0)
	TweenService:Create(invitePopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Transparency = 0,
		Position = UDim2.new(0.37, 0, 0.05, 0)
	}):Play()

	-- Текст приглашения
	local inviteText = Instance.new("TextLabel")
	inviteText.Size = UDim2.new(1, -20, 0, 40)
	inviteText.Position = UDim2.new(0, 10, 0, 10)
	inviteText.BackgroundTransparency = 1
	inviteText.Text = "Вас пригласил игрок:\n" .. inviterName
	inviteText.TextColor3 = Color3.fromRGB(210, 210, 210)
	inviteText.TextSize = 14
	inviteText.Font = Enum.Font.GothamBold
	inviteText.Parent = invitePopup

	-- Кнопки
	local btnFrame = Instance.new("Frame")
	btnFrame.Size = UDim2.new(1, -20, 0, 34)
	btnFrame.Position = UDim2.new(0, 10, 0, 62)
	btnFrame.BackgroundTransparency = 1
	btnFrame.Parent = invitePopup

	local yesBtn = Instance.new("TextButton")
	yesBtn.Size = UDim2.new(0.48, 0, 1, 0)
	yesBtn.Position = UDim2.new(0, 0, 0, 0)
	yesBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
	yesBtn.BorderSizePixel = 0
	yesBtn.Text = "Да"
	yesBtn.TextColor3 = Color3.new(1, 1, 1)
	yesBtn.TextSize = 14
	yesBtn.Font = Enum.Font.GothamBold
	yesBtn.Parent = btnFrame

	Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)

	local noBtn = Instance.new("TextButton")
	noBtn.Size = UDim2.new(0.48, 0, 1, 0)
	noBtn.Position = UDim2.new(0.52, 0, 0, 0)
	noBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	noBtn.BorderSizePixel = 0
	noBtn.Text = "Нет"
	noBtn.TextColor3 = Color3.new(1, 1, 1)
	noBtn.TextSize = 14
	noBtn.Font = Enum.Font.GothamBold
	noBtn.Parent = btnFrame

	Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)

	-- Да
	yesBtn.MouseButton1Down:Connect(function()
		InviteResponseEvent:InvokeServer(inviterName, true)
		if invitePopup then
			invitePopup:Destroy()
			invitePopup = nil
		end
	end)

	-- Нет
	noBtn.MouseButton1Down:Connect(function()
		InviteResponseEvent:InvokeServer(inviterName, false)
		if invitePopup then
			invitePopup:Destroy()
			invitePopup = nil
		end
	end)
end

-- ============================================================
-- ФУНКЦИИ ЧАТА
-- ============================================================

local function addMessage(senderName, text, color, isPrivate)
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, 0, 0, 0)
	msg.BackgroundColor3 = isPrivate and Color3.fromRGB(25, 20, 40) or Color3.fromRGB(0, 0, 0)
	msg.BorderSizePixel = 0
	msg.TextWrapped = true
	msg.TextScaled = false
	msg.TextSize = 13
	msg.Font = Enum.Font.Gotham
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextColor3 = Color3.fromRGB(200, 200, 200)
	msg.Parent = scrollFrame

	local rich = isPrivate and "🔒 " or ""
	msg.Text = rich .. "<font color='rgb(" .. math.floor(color[1]) .. "," .. math.floor(color[2]) .. "," .. math.floor(color[3]) .. ")'>" .. senderName .. "</font>: " .. text
	msg.TextMarkupEnabled = true

	-- Размер по тексту
	Instance.new("UISizeConstraint", msg).MinimumSize = Vector2.new(0, 20)

	task.wait()
	scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y)
end

local function switchMode(mode, targetName)
	currentMode = mode
	currentPrivateTarget = targetName

	-- Скрываем/показываем список игроков
	playerListFrame.Visible = false

	if mode == "global" then
		globalBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 255)
		globalBtn.TextColor3 = Color3.new(1, 1, 1)
		privateBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		privateBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
		privateTargetLabel.Visible = false
		textBox.PlaceholderText = "Напиши сообщение..."
	else
		globalBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		globalBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
		privateBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 180)
		privateBtn.TextColor3 = Color3.new(1, 1, 1)
		if targetName then
			privateTargetLabel.Text = "  Приватный чат с: " .. targetName
			privateTargetLabel.Visible = true
			textBox.PlaceholderText = "Сообщение для " .. targetName .. "..."
		end
	end
end

-- Обновление списка игроков
local function updatePlayerList()
	-- Убираем старые кнопки (кроме pickLabel)
	for _, child in ipairs(playerListFrame:GetChildren()) do
		if child.Name ~= "" and child ~= pickLabel then
			child:Destroy()
		end
	end
	-- pickLabel всегда первый
	pickLabel.LayoutOrder = 0

	local order = 1
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local btn = Instance.new("TextButton")
			btn.Name = "PlayerBtn"
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
			btn.BorderSizePixel = 0
			btn.Text = "  " .. p.Name
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.TextSize = 13
			btn.Font = Enum.Font.Gotham
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.LayoutOrder = order
			btn.Parent = playerListFrame

			btn.MouseButton1Down:Connect(function()
				-- Шлём приглашение
				InviteEvent:InvokeServer(p.Name)
				playerListFrame.Visible = false
				-- Показываем сообщение что приглашение отправлено
				addMessage("Система", 'Приглашение отправлено ' .. p.Name .. '...', {140, 140, 160}, false)
			end)

			btn.MouseEnter:Connect(function()
				btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
			end)
			btn.MouseLeave:Connect(function()
				btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
			end)

			order = order + 1
		end
	end
end

-- ============================================================
-- КНОПКИ ПЕРЕКЛЮЧЕНИЯ
-- ============================================================

globalBtn.MouseButton1Down:Connect(function()
	switchMode("global")
end)

privateBtn.MouseButton1Down:Connect(function()
	if currentMode == "private" and currentPrivateTarget then
		-- Уже в приватном, показываем список для смены
		updatePlayerList()
		playerListFrame.Visible = true
	else
		-- Открываем список игроков
		updatePlayerList()
		playerListFrame.Visible = true
	end
end)

-- ============================================================
-- ОТПРАВКА СООБЩЕНИЯ
-- ============================================================

local function sendMessage()
	local text = textBox.Text
	if #text == 0 or #text > 200 then return end

	if currentMode == "global" then
		ChatEvent:InvokeServer(text)
	elseif currentMode == "private" and currentPrivateTarget then
		PrivateChatEvent:InvokeServer(currentPrivateTarget, text)
		-- Показываем своё сообщение себе
		addMessage("Ты", text, {180, 180, 255}, true)
	end

	textBox.Text = ""
end

sendButton.MouseButton1Down:Connect(sendMessage)

textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		sendMessage()
	end
end)

-- ============================================================
-- СОБЫТИЯ ОТ СЕРВЕРА
-- ============================================================

-- Общий чат
ChatEvent.OnClientEvent:Connect(function(senderName, text, colorData)
	if currentMode == "global" then
		addMessage(senderName, text, colorData, false)
	end
end)

-- Приватный чат
PrivateChatEvent.OnClientEvent:Connect(function(senderName, text, colorData)
	if currentMode == "private" and currentPrivateTarget == senderName then
		addMessage(senderName, text, colorData, true)
	else
		-- Уведомление что есть новое сообщение в приватном
		print("[Приватный чат] " .. senderName .. ": " .. text)
	end
end)

-- Приглашение от кого-то
InviteEvent.OnClientEvent:Connect(function(inviterName)
	createInvitePopup(inviterName)
end)

-- Ответ на приглашение (тот кто пригласил получает это)
InviteResponseEvent.OnClientEvent:Connect(function(responderName, accepted)
	if accepted then
		addMessage("Система", responderName .. " принял приглашение!", {60, 180, 100}, false)
		switchMode("private", responderName)
	else
		addMessage("Система", responderName .. " отклонил приглашение.", {180, 80, 80}, false)
	end
end)

-- Обновление списка при входе/выходе
Players.PlayerAdded:Connect(function()
	if playerListFrame.Visible then updatePlayerList() end
end)

Players.PlayerRemoving:Connect(function(p)
	if currentMode == "private" and currentPrivateTarget == p.Name then
		addMessage("Система", currentPrivateTarget .. " вышел из игры.", {180, 80, 80}, false)
		switchMode("global")
	end
	if playerListFrame.Visible then updatePlayerList() end
end)
