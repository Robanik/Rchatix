-- Script в ServerScriptService
-- Имя: ChatServer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================================
-- СОЗДАЁМ REMOTE EVENTS
-- ============================================================

local ChatEvent = Instance.new("RemoteEvent")
ChatEvent.Name = "ChatEvent"
ChatEvent.Parent = ReplicatedStorage

local PrivateChatEvent = Instance.new("RemoteEvent")
PrivateChatEvent.Name = "PrivateChatEvent"
PrivateChatEvent.Parent = ReplicatedStorage

local InviteEvent = Instance.new("RemoteEvent")
InviteEvent.Name = "InviteEvent"
InviteEvent.Parent = ReplicatedStorage

local InviteResponseEvent = Instance.new("RemoteEvent")
InviteResponseEvent.Name = "InviteResponseEvent"
InviteResponseEvent.Parent = ReplicatedStorage

-- ============================================================
-- ЦВЕТА ИГРОКОВ
-- ============================================================

local playerColors = {}

local function getPlayerColor(player)
	if not playerColors[player.UserId] then
		playerColors[player.UserId] = {
			math.random(100, 255),
			math.random(100, 255),
			math.random(100, 255)
		}
	end
	return playerColors[player.UserId]
end

-- Функция найти игрока по имени
local function getPlayerByName(name)
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name == name then
			return p
		end
	end
	return nil
end

-- ============================================================
-- ОЧИСТКА
-- ============================================================

Players.PlayerRemoving:Connect(function(player)
	playerColors[player.UserId] = nil
end)

-- ============================================================
-- ОБЩИЙ ЧАТ
-- ============================================================

ChatEvent.OnServerEvent:Connect(function(sender, text)
	-- Валидация
	if type(text) ~= "string" then return end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if #text == 0 or #text > 200 then return end

	local color = getPlayerColor(sender)

	-- Шлём всем
	ChatEvent:FireAllClients(sender.Name, text, color)
end)

-- ============================================================
-- ПРИГЛАШЕНИЕ В ПРИВАТНЫЙ ЧАТ
-- ============================================================

InviteEvent.OnServerEvent:Connect(function(sender, targetName)
	-- Проверяем что такой игрок существует
	local target = getPlayerByName(targetName)
	if not target then return end
	if target == sender then return end -- нельзя пригласить себя

	-- Шлём приглашение целевому игроку
	InviteEvent:FireClient(target, sender.Name)
end)

-- ============================================================
-- ОТВЕТ НА ПРИГЛАШЕНИЕ
-- ============================================================

InviteResponseEvent.OnServerEvent:Connect(function(responder, inviterName, accepted)
	-- Валидация
	if type(inviterName) ~= "string" then return end
	if type(accepted) ~= "boolean" then return end

	-- Находим того кто пригласил
	local inviter = getPlayerByName(inviterName)
	if not inviter then return end

	-- Шлём ответ тому кто пригласил
	InviteResponseEvent:FireClient(inviter, responder.Name, accepted)

	-- Если принял — оба переходят в приватный режим
	-- Клиенты сами переключаются через событие
end)

-- ============================================================
-- ПРИВАТНЫЙ ЧАТ
-- ============================================================

PrivateChatEvent.OnServerEvent:Connect(function(sender, targetName, text)
	-- Валидация
	if type(text) ~= "string" then return end
	if type(targetName) ~= "string" then return end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if #text == 0 or #text > 200 then return end

	local target = getPlayerByName(targetName)
	if not target then return end
	if target == sender then return end

	local color = getPlayerColor(sender)

	-- Шлём только целевому игроку
	PrivateChatEvent:FireClient(target, sender.Name, text, color)

	-- И сам отправитель тоже видит своё сообщение (для синхронизации)
	-- Это делается на клиентской стороне, не нужно отправлять обратно
end)
