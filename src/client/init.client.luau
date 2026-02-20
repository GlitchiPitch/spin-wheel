local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- подписаться на обновление аттрибута SpinWheel
--- загружаем UI в playerGui
--- если аттрибут timer то запускать update
--- настравиаем логику кнопки в прогресс баре
--- если timer то открываем окно с показом какие награды можно выбить
--- если canClaim то рулетку показываем
--- если claimed то оповещение приходи завтра
--- фиксируем нажатия на кнопки в прогресс баре и кнопки закрытия окон и кнопка рулетки
--- фиксируем сигналы через remoteEvent

local Constants = require(ReplicatedStorage.SpinWheelShared.Constants)
local remoteEvent = ReplicatedStorage.SpinWheelShared.RemoteEvent

---@class Client
---@field _connections table<string, RBXScriptConnection>
---@field player Player
local Client = {}
Client.__index = Client

---@return Client
function Client.New()
    local self = setmetatable({}, Client)
    self.player = Players.LocalPlayer
    self._connections = {}
    return self
end

function Client:Init()
    local function _attributeChanged()
        local value = self.player:GetAttribute(Constants.PLAYER_ATTRIBUTE)
    end

    ---@param data RemoteData
    local function _remoteConnect(data)
        
    end

    self._connections._attributeChanged = self.player:GetAttributeChangedSignal(Constants.PLAYER_ATTRIBUTE):Connect(
        _attributeChanged)

    self._connections._remoteConnect = remoteEvent.OnClientEvent:Connect(_remoteConnect)
    _attributeChanged()
    self:_SetupButtons()
end

function Client:Update()

end

function Client:_UpdateProgressBar()

end

function Client:_SetupButtons()

end

function Client:_OpenScreen()
    
end

function Client:_StartSpinWheel()
    
end

local client = Client.New()
client:Init()
