local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--- зафиксировать вход игрока
--- получить данные из базы
--- загрузить в кэш
--- сделать валидацию (проверить наличие полей canClaim: boolean, claimed: number)
--- если есть поле claimed то проверить сколько времени прошло (time() - playerData.claimed >= 12h)
--- если прошло то устанавливаем аттрибут SpinWheel в состояние timer на игрока
--- если нет или время не прошло и есть canClaim устанавливаем его
--- если вермя прошло то очищаем кэш, playerData = {}
--- установить аттрибут по данным из базы (если есть поля canClaim, claimed то их, если нет то timer)
--- если аттрибут timer то фиксируем время захода в кэше

--- подписываемся на remoteEvent
--- фиксируем сигналы TIME_PASSED и CLAIM_REWARD
--- делаем валидацию
--- если TIME_PASSED проверяем прошедшее время (time() - playerData.startTime >= 5m)
--- если ок меняем аттрибут игрока на canClaim, и записываем в кэш canClaim = true, удаляем startTime
--- далее ждем CLAIM_REWARD
--- делаем валидацию аттрибута (SpinWheel == CAN_CLAIM)
--- если ок, то калькулируем награду, отправляем сигнал игроку CLAIM_REWARD с наградой (data = {rewardName = rewardName})
--- меняем аттрибут на claimed и записываем в кэш время взятия, и удаляем canClaim

--- фиксируем выход игрока, записываем данные из кэша

local Constants = require(ReplicatedStorage.SpinWheelShared.Constants)
local remoteEvent = ReplicatedStorage.SpinWheelShared.RemoteEvent

---@class PlayerCache
---@field startTime number?
---@field canClaim boolean?
---@field claimed number?

---@class Server
---@field _connections table<string, RBXScriptConnection>
---@field _dataStore DataStore
---@field _playerCache table<string, PlayerCache>
local Server = {}
Server.__index = Server

---@return Server
function Server.New()
    local self = setmetatable({}, Server)
    self._connections = {}
    self._dataStore = DataStoreService:GetDataStore(Constants.DATA_STORE_NAME)
    self._playerCache = {}
    return self
end

function Server:Init()
    ---@param player Player
    local function _onPlayerAdded(player)

    end

    ---@param player Player
    local function _onPlayerRemoving(player)

    end

    ---@param player Player
    ---@param data RemoteData
    local function _remoteConnect(player, data)

    end

    self._connections._onPlayerAdded = Players.PlayerAdded:Connect(_onPlayerAdded)
    self._connections._onPlayerRemoving = Players.PlayerRemoving:Connect(_onPlayerRemoving)
    self._connections._remoteConnect = remoteEvent.OnServerEvent:Connect(_remoteConnect)
end

---@param player Player
---@return PlayerCache
function Server:GetData(player)
    --- получить данные из базы
end

---@param player Player
---@return PlayerCache
function Server:GetCache(player)
    --- получить кэш
end

---@param player Player
---@param playerCache PlayerCache
function Server:UpdateCache(player, playerCache)
    local userId = tostring(player.UserId)
    self._playerCache[userId] = playerCache
end

---@param player Player
---@return boolean
function Server:CheckTimePassed(player)
    return false
end

---@param player Player
---@return ClaimRewardRemoteData
function Server:ClaimReward(player)

end

---@return string
function Server:_CalculateReward()
    
end

local server = Server.New()
server:Init()
