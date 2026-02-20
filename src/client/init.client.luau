local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
---@field _deltaTime number
---@field _updateInterval number
---@field _gui ScreenGui?
---@field _progressBar Frame?
---@field _progressFill Frame?
---@field _timerLabel TextLabel?
---@field _rewardsScreen Frame?
---@field _spinScreen Frame?
---@field _claimedScreen Frame?
local Client = {}
Client.__index = Client

---@return Client
function Client.New()
	local self = setmetatable({}, Client)
	self.player = Players.LocalPlayer
	self._connections = {}
	self._deltaTime = 0
	self._updateInterval = 1
	self._elapsedTime = 0
	self._gui = script.SpinWheelGui
	return self
end

function Client:_SetupUI()
	local playerGui = self.player.PlayerGui
	self._gui.Parent = playerGui
	self._progressBar = self._gui.ProgressFrame
	self._progressFill = self._progressBar.ProgressFill
	self._timerLabel = self._progressBar.TimerLabel
	self._rewardsScreen = self._gui.RewardsScreen
	self._spinScreen = self._gui.SpinScreen
	self._claimedScreen = self._gui.ClaimedScreen

	self:_SetupRewardsFrame()
end

function Client:Init()
	self:_SetupUI()

	local function _attributeChanged()
		local value = self.player:GetAttribute(Constants.PLAYER_ATTRIBUTE)
		if value == Constants.STATES.TIMER then
			self._elapsedTime = 0
			self:_Update()
		else
			if value == Constants.STATES.CAN_CLAIM then
				self._timerLabel.Text = "Забери награду"
			elseif value == Constants.STATES.CLAIMED then
				self._timerLabel.Text = "Ты забрал награду"
			end
			self:_TurnOffUpdate()
		end
	end

	---@param data RemoteData
	local function _remoteConnect(data)
		if data.eventName == Constants.REMOTE_EVENTS.CLAIM_REWARD and data.eventData then
			self:_StartSpinWheel(data.eventData.rewardName)
		end
	end

	self._connections._attributeChanged = self.player:GetAttributeChangedSignal(Constants.PLAYER_ATTRIBUTE):Connect(
		_attributeChanged)

	self._connections._remoteConnect = remoteEvent.OnClientEvent:Connect(_remoteConnect)
	_attributeChanged()
	self:_SetupButtons()
end

function Client:_Update()
	if self._connections._onRender then
		self._connections._onRender:Disconnect()
	end
	local function _onRender(deltaTime)
		self._elapsedTime += deltaTime
		self:_UpdateProgressBar()
		if self._elapsedTime >= Constants.TIMER_DURATION_SEC then
			remoteEvent:FireServer({ eventName = Constants.REMOTE_EVENTS.TIME_PASSED })
			self:_TurnOffUpdate()
		end
	end
	self._connections._onRender = RunService.RenderStepped:Connect(_onRender)
end

function Client:_TurnOffUpdate()
	if self._connections._onRender then
		self._connections._onRender:Disconnect()
		self._connections._onRender = nil
	end
end

function Client:_UpdateProgressBar()

	local progress = math.clamp(self._elapsedTime / Constants.TIMER_DURATION_SEC, 0, 1)
	self._progressFill.Size = UDim2.fromScale(progress,1)

	local remaining = math.max(0, Constants.TIMER_DURATION_SEC - self._elapsedTime)
	local mins = math.floor(remaining / 60)
	local secs = math.floor(remaining % 60)
	self._timerLabel.Text = string.format("%d:%02d", mins, secs)
end

function Client:_SetupButtons()

	self._progressBar.GiftBtn.MouseButton1Click:Connect(function()
		self:_OpenScreen()
	end)

	local function setupCloseBtn(frame)
		local btn = frame and frame:FindFirstChild("CloseBtn")
		if btn then
			btn.MouseButton1Click:Connect(function()
				frame.Visible = false
			end)
		end
	end

	setupCloseBtn(self._rewardsScreen)
	setupCloseBtn(self._spinScreen)
	setupCloseBtn(self._claimedScreen)

	
	self._spinScreen.SpinBtn.MouseButton1Click:Connect(function()
		self._spinScreen.SpinBtn.Visible = false
		remoteEvent:FireServer({ eventName = Constants.REMOTE_EVENTS.CLAIM_REWARD })
	end)
	
end

function Client:_OpenScreen()
	local value = self.player:GetAttribute(Constants.PLAYER_ATTRIBUTE)
	
	self._rewardsScreen.Visible = (value == Constants.STATES.TIMER)
	self._spinScreen.Visible = (value == Constants.STATES.CAN_CLAIM)
	self._claimedScreen.Visible = (value == Constants.STATES.CLAIMED)

	
	self._spinScreen.SpinBtn.Visible = true
	self._spinScreen.ResultLabel.Text = ""
	
end

function Client:_StartSpinWheel(rewardName)
	local reward = Constants.REWARDS[rewardName]
	
	self._spinScreen.Visible = true
	self._spinScreen.SpinBtn.Visible = false
	self._spinScreen.ResultLabel.Text = "Ты выйграл: " .. (reward and reward.displayName or rewardName)
	
end

function Client:_SetupRewardsFrame()
	local rewardContainer = self._rewardsScreen.Container
	local rewardTemplate = rewardContainer.Template :: Frame & { ImageLabel: ImageLabel, TextLabel: TextLabel }
	local rareRewards = {}

	for i, v in Constants.REWARDS do
		if v.weight <= 2 then
			rareRewards[i] = v
		end
	end

	for _, v in rareRewards do
		local reward = rewardTemplate:Clone()
		reward.Visible = true
		reward.Parent = rewardContainer
		reward.TextLabel.Text = v.displayName
		reward.ImageLabel.Image = v.image
		reward.LayoutOrder = v.weight
	end
end

local client = Client.New()
client:Init()
