local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		local playerData = self:_GetData(player)
		self:_UpdateCache(player, playerData)

		local now = os.time()
		if playerData.claimed then
			if now - playerData.claimed >= Constants.CLAIMED_COOLDOWN_SEC then
				playerData = { startTime = now }
				self:_UpdateCache(player, playerData)
				player:SetAttribute(Constants.PLAYER_ATTRIBUTE, Constants.STATES.TIMER)
			else
				player:SetAttribute(Constants.PLAYER_ATTRIBUTE, Constants.STATES.CLAIMED)
			end
		elseif playerData.canClaim then
			player:SetAttribute(Constants.PLAYER_ATTRIBUTE, Constants.STATES.CAN_CLAIM)
		else
			playerData.startTime = now
			self:_UpdateCache(player, playerData)
			player:SetAttribute(Constants.PLAYER_ATTRIBUTE, Constants.STATES.TIMER)
		end
	end

	---@param player Player
	local function _onPlayerRemoving(player)
		local cache = self:_GetCache(player)
		self:_SaveData(player, cache)
		self._playerCache[tostring(player.UserId)] = nil
	end

	---@param player Player
	---@param data RemoteData
	local function _remoteConnect(player, data)
		self:_OnRemoteConnect(player, data)
	end

	self._connections._onPlayerAdded = Players.PlayerAdded:Connect(_onPlayerAdded)
	self._connections._onPlayerRemoving = Players.PlayerRemoving:Connect(_onPlayerRemoving)
	self._connections._remoteConnect = remoteEvent.OnServerEvent:Connect(_remoteConnect)

	for _, player in Players:GetPlayers() do
		_onPlayerAdded(player)
	end

end

---@param player Player
---@return PlayerCache
function Server:_GetData(player)
	local success, data = pcall(function()
		return self._dataStore:GetAsync("player_" .. player.UserId)
	end)
	if success and data then
		return data
	end
	
	return {}
end

---@param player Player
---@return PlayerCache
function Server:_GetCache(player)
	local userId = tostring(player.UserId)
	return self._playerCache[userId] or {}
end

---@param player Player
---@param playerCache PlayerCache
function Server:_SaveData(player, playerCache)
	local s, r = pcall(function()
		self._dataStore:SetAsync("player_" .. player.UserId, {
			canClaim = playerCache.canClaim,
			claimed = playerCache.claimed,
		})
	end)

	print(s, r, playerCache)
end

---@param player Player
---@param playerCache PlayerCache
function Server:_UpdateCache(player, playerCache)
    local userId = tostring(player.UserId)
    self._playerCache[userId] = playerCache
end

---@param player Player
---@return boolean
function Server:_CheckTimePassed(player)
	local cache = self:_GetCache(player)
	if not cache.startTime then
		return false
	end
	return os.time() - cache.startTime >= Constants.TIMER_DURATION_SEC
end

---@return ClaimRewardRemoteData
function Server:_ClaimReward()
	local rewardName = self:_CalculateReward()
	return { rewardName = rewardName }
end

---@return string
function Server:_CalculateReward()
	local totalWeight = 0
	for _, reward in Constants.REWARDS do
		totalWeight += reward.weight or 1
	end
	local roll = math.random() * totalWeight
	for name, reward in Constants.REWARDS do
		roll -= reward.weight or 1
		if roll <= 0 then
			return name
		end
	end
	return (next(Constants.REWARDS))
end

---@param player Player
---@param data RemoteData
function Server:_OnRemoteConnect(player, data)
	if not data or type(data.eventName) ~= "string" then
		return
	end

	if data.eventName == Constants.REMOTE_EVENTS.TIME_PASSED then
		local cache = self:_GetCache(player)
		if player:GetAttribute(Constants.PLAYER_ATTRIBUTE) ~= Constants.STATES.TIMER then
			return
		end
		if not self:_CheckTimePassed(player) then
			return
		end

		cache.canClaim = true
		cache.startTime = nil
		self:_UpdateCache(player, cache)
		player:SetAttribute(Constants.PLAYER_ATTRIBUTE, Constants.STATES.CAN_CLAIM)
	elseif data.eventName == Constants.REMOTE_EVENTS.CLAIM_REWARD then
		if player:GetAttribute(Constants.PLAYER_ATTRIBUTE) ~= Constants.STATES.CAN_CLAIM then
			return
		end
		local result = self:_ClaimReward()
		local cache = self:_GetCache(player)

		remoteEvent:FireClient(player, {
			eventName = Constants.REMOTE_EVENTS.CLAIM_REWARD,
			eventData = result,
		})

		cache.canClaim = nil
		cache.claimed = os.time()
		self:_UpdateCache(player, cache)

		player:SetAttribute(Constants.PLAYER_ATTRIBUTE, Constants.STATES.CLAIMED)
	end
end

local server = Server.New()
server:Init()
