-- MeMeZ Exploit Hub - Complete Restoration
-- 整合自双子座、元宝、DeepSeek和KENNYk版本
-- 保留所有原版功能，去除开发者模式和GZMC特定内容

-- 服务引用
local startTime = tick()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local TestService = game:GetService("TestService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local PlaceId = game.PlaceId

-- ==========================================
-- 引擎检测变量
-- ==========================================
local CarbonEngineDetected = false
local CarbonEngineEvents = {}
local CarbonEngineFunctions = {}

local ACS11_Engine = nil
local ACS11_AccessId = nil
local ACS11_Detected = false
local ACS11_Events = {}
local ACS11_Functions = {}

local ACS176_Engine = nil
local ACS176_Detected = false
local ACS176_Events = {}
local ACS176_Functions = {}

local ACS125_Engine = nil
local ACS125_AccessId = nil
local ACS125_Detected = false
local ACS125_Events = {}
local ACS125_Functions = {}

local ACS201_Engine = nil
local ACS201_AccessId = nil
local ACS201_Detected = false
local ACS201_Events = {}
local ACS201_Functions = {}

local RCS_Detected = false
local RCS_Network = nil
local RCS_Projectile = nil
local RCS_Tool = nil
local RCS_Functions = {}
local RCS_ToolWhitelist = {"包名"}

local AC6_Remote = nil
local AC6_Detected = false
local AC6_InitialCheck = false

local TonkSpawnerRadio_Detected = false
local TonkSpawnerRadio_Remote = nil
local TonkSpawnerRadio_InitialCheck = false

-- 平台检测
if not table.find({Enum.Platform.IOS}, UserInputService:GetPlatform()) then
    table.find({Enum.Platform.Android}, UserInputService:GetPlatform())
end

-- ==========================================
-- 加载UI库和信息模块
-- ==========================================
local UILibrary = loadstring(game:HttpGet(getgenv().MeMeZStorage .. "Librarys/UI.lua"))()
local InfoModule = loadstring(game:HttpGet(getgenv().MeMeZStorage .. "Information.lua"))()

local RespectList = InfoModule.Respects
local Blacklist = InfoModule.Blacklist
local CreatorList = InfoModule.Creators

-- ==========================================
-- 黑名单检查
-- ==========================================
if Blacklist[tostring(LocalPlayer.UserId)] then
    LocalPlayer:Kick("")
    game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = "已被禁止使用MeMeZ"
    game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = Blacklist[LocalPlayer.UserId]
    task.wait(0.25)
    while true do
        Instance.new("Part", Workspace)
    end
else
    -- 主程序开始
    local SelectedPlayer = nil
    local OriginalFOV = CurrentCamera.FieldOfView
    local OriginalMinZoom = LocalPlayer.CameraMinZoomDistance
    local OriginalMaxZoom = LocalPlayer.CameraMaxZoomDistance
    local OriginalWalkSpeed = LocalPlayer.Character == nil and 16 or (LocalPlayer.Character.Humanoid.WalkSpeed or 16)
    local OriginalJumpPower = LocalPlayer.Character == nil and 50 or (LocalPlayer.Character.Humanoid.JumpPower or 50)
    local OriginalHipHeight = LocalPlayer.Character == nil and 1.2 or (LocalPlayer.Character.Humanoid.HipHeight or 1.2)
    
    local ScriptConnections = getgenv().MeMeZConnections
    local LoopConnections = {}
    
    -- 配置表
    local Config = {
        LagServerAD = true,
        ACS_R15_11_SPAMSOUNDID = 7236490488,
        LoopGotoPos = CFrame.new(0, 0, 0),
        LoopGotoSP = false,
        FOVEnabled = false,
        FOV = OriginalFOV,
        CameraMinZoomDistanceEnabled = false,
        CameraMinZoomDistance = OriginalMinZoom,
        CameraMaxZoomDistanceEnabled = false,
        CameraMaxZoomDistance = OriginalMaxZoom,
        TpwalkEnabled = false,
        Tpwalk = 0,
        WalkSpeedEnabled = false,
        WalkSpeed = OriginalWalkSpeed,
        JumpPowerEnabled = false,
        JumpPower = OriginalJumpPower,
        HipHeightEnabled = false,
        HipHeight = OriginalHipHeight,
        Fly = false,
        FlySpeed = 25,
        Noclip = false,
        SelectedMusic = "无",
        SelectedCustomMusic = "无"
    }
    
    -- UI元素存储
    local UIElements = {
        Textboxes = {},
        Toggles = {},
        Dropdowns = {},
        Sliders = {},
        ColorPickers = {}
    }
    
    -- ==========================================
    -- 创建UI界面
    -- ==========================================
    local NotificationSystem = UILibrary:AddNotifications()
    local Notify = NotificationSystem.Notify
    local Notification = NotificationSystem.Notification
    
    local MainWindow = UILibrary:Window({
        ScriptName = "MeMeZ",
        DestroyIfExists = true,
        Theme = "White",
        BlockUI = true
    })
    
    MainWindow:Minimize({
        Visibility = true,
        OpenButton = true
    })
    
    -- 创建标签页
    local CreatorsTab = MainWindow:Tab("制作人员名单")
    local ExploitFinderTab = MainWindow:Tab("新发现漏洞")
    local PlayerTab = MainWindow:Tab("玩家")
    local MapTab = MainWindow:Tab("地图修改")
    
    -- 动态标签页变量
    local CarbonEngineTab = nil
    local ACS11Tab = nil
    local ACS176Tab = nil
    local ACS125Tab = nil
    local ACS201Tab = nil
    local RCSTab = nil
    local AC6Tab = nil
    local TonkSpawnerRadioTab = nil
    
    -- 音乐标签页
    local MusicTab, MusicSection
    if UILibrary.PlayRandomMusic then
        MusicTab = MainWindow:Tab("音乐")
        MusicSection = MusicTab:Section("音乐")
    end
    
    -- ==========================================
    -- 辅助函数
    -- ==========================================
    local function ShowNotification(data)
        Notification(nil, data)
    end
    
    local function ShowNotify(data)
        Notify(nil, data)
    end
    
    local function CreateLoopConnection(callback, name)
        local connection = RunService.Heartbeat:Connect(callback)
        table.insert(ScriptConnections, connection)
        if name then
            if LoopConnections[name] ~= nil then
                LoopConnections[name]:Disconnect()
            end
            LoopConnections[name] = connection
        end
        return connection
    end
    
    local function RemoveLoopConnection(name)
        if string.lower(name) ~= "all" then
            if LoopConnections[name] ~= nil then
                LoopConnections[name]:Disconnect()
            end
        else
            for _, connection in pairs(LoopConnections) do
                connection:Disconnect()
            end
        end
    end
    
    local function TeleportToCFrame(targetCFrame)
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
        end)
    end
    
    local function SendChatMessage(message)
        if TextChatService.ChatVersion ~= Enum.ChatVersion.TextChatService then
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        else
            TextChatService.TextChannels.RBXGeneral:SendAsync(message)
        end
    end
    
    -- ==========================================
    -- AC6检测函数
    -- ==========================================
    local function TryExploitAC6(remote)
        if remote:IsA("RemoteEvent") then
            local randomId = math.random(1, 10000)
            local soundName = tostring(randomId)
            remote:FireServer("newSound", soundName, TestService, "rbxassetid://10000We are here10000", 1, 1, false)
            
            local checks = 0
            local success = false
            repeat
                task.wait(0.5)
                checks = checks + 1
                success = TestService:FindFirstChild(soundName) and true or success
            until success or checks >= 5
            
            if success then
                AC6_Remote = remote
                return true
            end
        end
    end
    
    local function ScanForAC6()
        local descendants = Workspace:GetDescendants()
        for _, obj in pairs(descendants) do
            if obj.Name == "AC6_FE_Sounds" and obj:FindFirstChild("Handler") and TryExploitAC6(obj) then
                return true
            end
        end
        return false
    end
    
    -- 异步检测AC6
    task.spawn(function()
        if ScanForAC6() then
            AC6_Detected = true
            AC6Tab = MainWindow:Tab("AC6 漏洞")
        end
    end)
    
    -- ==========================================
    -- TonkSpawner Radio检测函数
    -- ==========================================
    local function ScanForTonkSpawnerRadio()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "MUSIC" and obj:IsA("RemoteEvent") and obj.Parent.Name == "Main" and obj.Parent:FindFirstChild("UpdateVP") then
                TonkSpawnerRadio_Remote = obj
                return true
            end
        end
        return false
    end
    
    -- 检测TonkSpawner Radio
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "MUSIC" and obj:IsA("RemoteEvent") and obj.Parent.Name == "Main" and obj.Parent:FindFirstChild("UpdateVP") then
            TonkSpawnerRadioTab = MainWindow:Tab("TonkSpawner Radio 漏洞")
            TonkSpawnerRadio_Detected = true
            break
        end
    end
    
    -- ==========================================
    -- Carbon Engine功能实现
    -- ==========================================
    local function SetupCarbonEngineFeatures()
        if CarbonEngineDetected then
            local carbonSection = CarbonEngineTab:Section("CarbonEngine漏洞")
            
            -- Carbon Engine函数
            function CarbonEngineFunctions.DamageEvent(target, damage)
                pcall(function()
                    CarbonEngineEvents.DamageEvent:FireServer(target, damage, "Head", {"nil", "Auth", "nil", "nil"})
                end)
            end
            
            function CarbonEngineFunctions.Explode(position)
                pcall(function()
                    CarbonEngineEvents.ExplosiveEvent:FireServer("MeMeZ", position, 500000, 120, 120, nil, nil, nil, nil, nil, nil, nil, "Auth", nil)
                end)
            end
            
            function CarbonEngineFunctions.LagServer()
                SendChatMessage("MeMeZ即将崩溃服务器, 加入公会 IOI8O5858I 获取MeMeZ!")
                task.wait(2)
                CreateLoopConnection(function()
                    for _ = 1, Config.Carbon_LagServer_Thread do
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                CarbonEngineEvents.ExplosiveEvent:FireServer("MeMeZ is coming!", player.Character.HumanoidRootPart.Position, 0, 0, 0, nil, nil, nil, nil, nil, nil, nil, "Auth", nil)
                            end)
                        end
                    end
                end)
            end
            
            -- Carbon Engine UI控件
            carbonSection:Toggle("点击击杀", false, function(val)
                Config.CarbonClickKill = val
            end)
            
            carbonSection:Toggle("点击爆炸", false, function(val)
                Config.CarbonClickBoom = val
            end)
            
            carbonSection:Button("杀所有", "杀死所有人", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player ~= LocalPlayer then
                            CarbonEngineFunctions.DamageEvent(player.Character.Humanoid, player.Character.Humanoid.MaxHealth)
                        end
                    end)
                end
                CarbonEngineFunctions.DamageEvent(LocalPlayer.Character.Humanoid, LocalPlayer.Character.Humanoid.MaxHealth)
            end)
            
            carbonSection:Toggle("循环杀所有", false, function(val)
                Config.CarbonLoopKillAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                if player ~= LocalPlayer then
                                    CarbonEngineFunctions.DamageEvent(player.Character.Humanoid, player.Character.Humanoid.MaxHealth)
                                end
                            end)
                        end
                        CarbonEngineFunctions.DamageEvent(LocalPlayer.Character.Humanoid, LocalPlayer.Character.Humanoid.MaxHealth)
                    end, "CarbonLoopKillAll")
                else
                    RemoveLoopConnection("CarbonLoopKillAll")
                end
            end)
            
            carbonSection:Button("炸所有", "所有人被炸飞", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        CarbonEngineFunctions.Explode(player.Character.HumanoidRootPart.Position)
                    end)
                end
            end)
            
            carbonSection:Toggle("循环炸所有", false, function(val)
                Config.CarbonLoopExplodeAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                CarbonEngineFunctions.Explode(player.Character.HumanoidRootPart.Position)
                            end)
                        end
                    end, "CarbonLoopExplodeAll")
                else
                    RemoveLoopConnection("CarbonLoopExplodeAll")
                end
            end)
            
            carbonSection:Button("无敌", "你的角色无敌", function()
                pcall(function()
                    CarbonEngineFunctions.DamageEvent(LocalPlayer.Character.Humanoid, -math.huge)
                end)
            end)
            
            carbonSection:Toggle("循环无敌", false, function(val)
                Config.CarbonLoopGod = val
                if val then
                    CreateLoopConnection(function()
                        pcall(function()
                            CarbonEngineFunctions.DamageEvent(LocalPlayer.Character.Humanoid, -math.huge)
                        end)
                    end, "CarbonLoopGod")
                else
                    RemoveLoopConnection("CarbonLoopGod")
                end
            end)
            
            UIElements.Sliders.Carbon_LagServer_Thread = carbonSection:Slider("服务器崩溃频率", 1, 2, 10, function(val)
                Config.Carbon_LagServer_Thread = val
            end)
            
            carbonSection:Button("崩服", "服务器崩溃", function()
                CarbonEngineFunctions.LagServer()
            end)
            
            -- 针对选中玩家的操作
            PlayerTab:Button("杀", "用CarbonEngine的方法杀选中的玩家", function()
                CarbonEngineFunctions.DamageEvent(Players:FindFirstChild(SelectedPlayer).Character.Humanoid, 
                    Players:FindFirstChild(SelectedPlayer).Character.Humanoid.MaxHealth)
            end)
            
            PlayerTab:Button("炸", "用CarbonEngine的方法炸选中的玩家", function()
                CarbonEngineFunctions.Explode(Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.Position)
            end)
        end
    end
    
    -- ==========================================
    -- ACS R15 1.1功能实现
    -- ==========================================
    local function SetupACS11Features()
        if ACS11_Detected then
            -- ACS 1.1函数
            function ACS11_Functions.TakeDamage(player, headDmg, torsoDmg, limbDmg)
                pcall(function()
                    ACS11_Events.ACS_AI.Damage:FireServer(player.Character.Humanoid, headDmg, torsoDmg, limbDmg, 
                        ACS11_AccessId .. "-" .. LocalPlayer.UserId)
                end)
            end
            
            function ACS11_Functions.Callout(player, soundId)
                pcall(function()
                    ACS11_Events.Callout:FireServer(player, ACS11_AccessId .. "-" .. LocalPlayer.UserId, {
                        id = "rbxassetid://" .. soundId,
                        v = 10,
                        ps = 1,
                        maxd = math.huge,
                        mind = 0,
                        rom = Enum.RollOffMode.Inverse,
                        tp = 0
                    }, "MeMeZ")
                end)
            end
            
            function ACS11_Functions.Explode(targetPart, damage, pressure)
                pcall(function()
                    ACS11_Events.Hit:FireServer(targetPart.Position, targetPart, Vector3.new(0, 1, 0), 
                        Enum.Material.Plastic, {
                            DestroyJointRadiusPercent = 1,
                            ExPressure = pressure,
                            ExpRadius = math.huge,
                            ExplosionDamage = damage,
                            ExplosionDamagesTerrain = true,
                            ExplosiveHit = true
                        }, ACS11_AccessId .. "-" .. LocalPlayer.UserId, math.huge, "Rico")
                end)
            end
            
            -- ACS 1.1 UI控件
            ACS11Tab:Button("杀所有", "所有人死亡", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        ACS11_Functions.TakeDamage(player, math.huge, math.huge, math.huge)
                    end)
                end
            end)
            
            UIElements.Toggles.ACS_R15_11_LoopKillAll = ACS11Tab:Toggle("循环杀所有", false, function(val)
                Config.ACS_R15_11_LoopKillAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            if player ~= LocalPlayer then
                                pcall(function()
                                    ACS11_Functions.TakeDamage(player, math.huge, math.huge, math.huge)
                                end)
                            end
                        end
                    end, "ACS_R15_11_LoopKillAll")
                else
                    RemoveLoopConnection("ACS_R15_11_LoopKillAll")
                end
            end)
            
            ACS11Tab:Button("炸所有", "所有人被炸飞", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        ACS11_Functions.Explode(player.Character.HumanoidRootPart, math.huge, 1000000)
                    end)
                end
            end)
            
            UIElements.Toggles.ACS_R15_11_LoopExplodeAll = ACS11Tab:Toggle("循环炸飞所有人", false, function(val)
                Config.ACS_R15_11_LoopExplodeAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                ACS11_Functions.Explode(player.Character.HumanoidRootPart, math.huge, 1000000)
                            end)
                        end
                    end, "ACS_R15_11_LoopExplodeAll")
                else
                    RemoveLoopConnection("ACS_R15_11_LoopExplodeAll")
                end
            end)
            
            ACS11Tab:TextBox("音频ID", "音频ID", function(val)
                Config.ACS_R15_11_SPAMSOUNDID = tostring(tonumber(val))
            end)
            
            ACS11Tab:Button("放音频给所有人", "放音频给所有人", function()
                for _, player in pairs(Players:GetChildren()) do
                    ACS11_Functions.Callout(player, Config.ACS_R15_11_SPAMSOUNDID)
                end
            end)
            
            UIElements.Toggles.ACS_R15_11_SpamSound = ACS11Tab:Toggle("循环放音频", false, function(val)
                Config.ACS_R15_11_SpamSound = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            ACS11_Functions.Callout(player, Config.ACS_R15_11_SPAMSOUNDID)
                        end
                    end, "ACS_R15_11_SpamSound")
                else
                    RemoveLoopConnection("ACS_R15_11_SpamSound")
                end
            end)
            
            UIElements.Toggles.ACS_R15_11_LoopHealth = ACS11Tab:Toggle("无敌", false, function(val)
                Config.ACS_R15_11_LoopHealth = val
                if val then
                    CreateLoopConnection(function()
                        ACS11_Functions.TakeDamage(LocalPlayer, -math.huge, -math.huge, -math.huge)
                    end, "ACS_R15_11_LoopHealth")
                else
                    RemoveLoopConnection("ACS_R15_11_LoopHealth")
                end
            end)
            
            UIElements.Toggles.ACS_R15_11_LoopHealthAll = ACS11Tab:Toggle("无敌所有人", false, function(val)
                Config.ACS_R15_11_LoopHealthAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                ACS11_Functions.TakeDamage(player, -math.huge, -math.huge, -math.huge)
                            end)
                        end
                    end, "ACS_R15_11_LoopHealthAll")
                else
                    RemoveLoopConnection("ACS_R15_11_LoopHealthAll")
                end
            end)
            
            UIElements.Toggles.ACS_R15_11_LoopShake = ACS11Tab:Toggle("视角震动", false, function(val)
                Config.ACS_R15_11_LoopShake = val
                if val then
                    CreateLoopConnection(function()
                        for _ = 1, 5 do
                            for _, player in pairs(Players:GetChildren()) do
                                pcall(function()
                                    ACS11_Events.Hit:FireServer(player.Character.HumanoidRootPart.Position, 
                                        player.Character.HumanoidRootPart, Vector3.new(0, 1, 0), Enum.Material.Plastic, {
                                            DestroyJointRadiusPercent = 1,
                                            ExPressure = 0,
                                            ExpRadius = math.huge,
                                            ExplosionDamage = 0,
                                            ExplosionDamagesTerrain = true,
                                            ExplosiveHit = true
                                        }, ACS11_AccessId .. "-" .. LocalPlayer.UserId, math.huge, "Rico")
                                end)
                            end
                        end
                    end, "ACS_R15_11_LoopShake")
                else
                    RemoveLoopConnection("ACS_R15_11_LoopShake")
                end
            end)
            
            -- 针对选中玩家的操作
            if ACS11_Detected then
                PlayerTab:Button("杀", "用ACS R15 1.1的方法杀选中的玩家", function()
                    ACS11_Functions.TakeDamage(Players:FindFirstChild(SelectedPlayer), math.huge, math.huge, math.huge)
                end)
                
                PlayerTab:Button("复活量", "用ACS R15 1.1的方法恢复选中的玩家血量", function()
                    ACS11_Functions.TakeDamage(Players:FindFirstChild(SelectedPlayer), -math.huge, 0, 0)
                end)
                
                PlayerTab:Button("腿无限耐久", "用ACS R15 1.1的方法使选中的玩家断腿无限耐久", function()
                    ACS11_Functions.TakeDamage(Players:FindFirstChild(SelectedPlayer), 0, -math.huge, -math.huge)
                end)
                
                PlayerTab:Button("腿", "用ACS R15 1.1的方法使选中的玩家断腿耐久归零", function()
                    ACS11_Functions.TakeDamage(Players:FindFirstChild(SelectedPlayer), 0, math.huge, math.huge)
                end)
                
                PlayerTab:Button("放音频", "用ACS R15 1.1的方法为选中的玩家播放音频", function()
                    ACS11_Functions.Callout(Players:FindFirstChild(SelectedPlayer), Config.ACS_R15_11_SPAMSOUNDID)
                end)
            end
        end
    end
    
    -- ==========================================
    -- ACS 1.7.6功能实现
    -- ==========================================
    local function SetupACS176Features()
        if ACS176_Detected then
            function ACS176_Functions.TakeDamage(player, head, torso, limb)
                pcall(function()
                    ACS176_Events.Damage:FireServer(player.Character.Humanoid, head, torso, limb)
                end)
            end
            
            function ACS176_Functions.Explode(part, damage, pressure)
                pcall(function()
                    ACS176_Events.Hit:FireServer(part.Position, part, Vector3.new(0, 1, 0), Enum.Material.Plastic, {
                        DestroyJointRadiusPercent = 1,
                        ExPressure = pressure,
                        ExpRadius = math.huge,
                        ExplosionDamage = damage,
                        ExplosionDamagesTerrain = true,
                        ExplosiveHit = true
                    })
                end)
            end
            
            -- ACS 1.7.6 UI控件
            ACS176Tab:Button("杀所有", "所有人死亡", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        ACS176_Functions.TakeDamage(player, math.huge, math.huge, math.huge)
                    end)
                end
            end)
            
            UIElements.Toggles.ACS_176_LoopKillAll = ACS176Tab:Toggle("循环杀所有", false, function(val)
                Config.ACS_176_LoopKillAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            if player ~= LocalPlayer then
                                pcall(function()
                                    ACS176_Functions.TakeDamage(player, math.huge, math.huge, math.huge)
                                end)
                            end
                        end
                    end, "ACS_176_LoopKillAll")
                else
                    RemoveLoopConnection("ACS_176_LoopKillAll")
                end
            end)
            
            ACS176Tab:Button("炸所有人", "所有人被炸飞并杀他们", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        ACS176_Functions.Explode(player.Character.HumanoidRootPart, math.huge, 500)
                    end)
                end
            end)
            
            UIElements.Toggles.ACS_176_LoopExplodeAll = ACS176Tab:Toggle("循环炸所有人", false, function(val)
                Config.ACS_176_LoopExplodeAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                ACS176_Functions.Explode(player.Character.HumanoidRootPart, math.huge, 500)
                            end)
                        end
                    end, "ACS_176_LoopExplodeAll")
                else
                    RemoveLoopConnection("ACS_176_LoopExplodeAll")
                end
            end)
            
            UIElements.Toggles.ACS_176_LoopHealth = ACS176Tab:Toggle("无敌", false, function(val)
                Config.ACS_176_LoopHealth = val
                if val then
                    CreateLoopConnection(function()
                        ACS176_Functions.TakeDamage(LocalPlayer, -math.huge, -math.huge, -math.huge)
                    end, "ACS_176_LoopHealth")
                else
                    RemoveLoopConnection("ACS_176_LoopHealth")
                end
            end)
            
            UIElements.Toggles.ACS_176_LoopHealthAll = ACS176Tab:Toggle("无敌所有人", false, function(val)
                Config.ACS_176_LoopHealthAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                ACS176_Functions.TakeDamage(player, -math.huge, -math.huge, -math.huge)
                            end)
                        end
                    end, "ACS_176_LoopHealthAll")
                else
                    RemoveLoopConnection("ACS_176_LoopHealthAll")
                end
            end)
            
            UIElements.Toggles.ACS_176_LoopShake = ACS176Tab:Toggle("循环无伤害炸所有人", false, function(val)
                Config.ACS_176_LoopShake = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                ACS176_Events.Hit:FireServer(LocalPlayer.Character.HumanoidRootPart.Position, 
                                    LocalPlayer.Character.HumanoidRootPart, Vector3.new(0, 1, 0), Enum.Material.Plastic, {
                                        DestroyJointRadiusPercent = 1,
                                        ExPressure = 0,
                                        ExpRadius = math.huge,
                                        ExplosionDamage = 0,
                                        ExplosionDamagesTerrain = true,
                                        ExplosiveHit = true
                                    })
                            end)
                        end
                    end, "ACS_176_LoopShake")
                else
                    RemoveLoopConnection("ACS_176_LoopShake")
                end
            end)
        end
    end
    
    -- ==========================================
    -- ACS 1.2.5功能实现
    -- ==========================================
    local function SetupACS125Features()
        if ACS125_Detected then
            function ACS125_Functions.TakeDamage(player, head, torso, limb)
                pcall(function()
                    ACS125_Events.Damage:FireServer(player.Character.Humanoid, head, torso, limb, 
                        ACS125_AccessId .. "__" .. LocalPlayer.UserId)
                end)
            end
            
            function ACS125_Functions.Callout(player)
                pcall(function()
                    ACS125_Events.Callout:FireServer(player, ACS125_AccessId .. "__" .. LocalPlayer.UserId, "KIA Callout")
                end)
            end
            
            function ACS125_Functions.Explode(position, damage, pressure)
                pcall(function()
                    ACS125_Events.Hit2:FireServer(position, CFrame.new(0, -10, 0), Enum.Material.Plastic, {
                        ExPressure = pressure,
                        BulletType = "PG-7VL",
                        ExplosiveHit = true,
                        ExpSoundDistanceMult = 10,
                        TerrainDamageRadius = math.huge,
                        ExpRadius = math.huge,
                        ExplosionDamagesTerrain = true,
                        ExpSoundVolumeMult = 1,
                        ExplosionDamage = damage
                    }, ACS125_AccessId .. "-" .. LocalPlayer.UserId, math.huge, "Hit")
                end)
            end
            
            -- ACS 1.2.5 UI控件
            ACS125Tab:Button("杀所有", "所有人死亡", function()
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        ACS125_Functions.TakeDamage(player, math.huge, math.huge, math.huge)
                    end)
                end
            end)
            
            UIElements.Toggles.ACS_R15_125_LoopKillAll = ACS125Tab:Toggle("循环杀所有", false, function(val)
                Config.ACS_R15_125_LoopKillAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            if player ~= LocalPlayer then
                                pcall(function()
                                    ACS125_Functions.TakeDamage(player, math.huge, math.huge, math.huge)
                                end)
                            end
                        end
                    end, "ACS_R15_125_LoopKillAll")
                else
                    RemoveLoopConnection("ACS_R15_125_LoopKillAll")
                end
            end)
            
            ACS125Tab:Button("放随机呼喊声给所有人", "放随机呼喊声给所有人", function()
                for _, player in pairs(Players:GetChildren()) do
                    ACS125_Functions.Callout(player)
                end
            end)
            
            UIElements.Toggles.ACS_R15_125_SpamSound = ACS125Tab:Toggle("循环放随机呼喊声", false, function(val)
                Config.ACS_R15_125_SpamSound = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            ACS125_Functions.Callout(player)
                        end
                    end, "ACS_R15_125_SpamSound")
                else
                    RemoveLoopConnection("ACS_R15_125_SpamSound")
                end
            end)
            
            UIElements.Toggles.ACS_R15_125_LoopHealth = ACS125Tab:Toggle("无敌", false, function(val)
                Config.ACS_R15_125_LoopHealth = val
                if val then
                    CreateLoopConnection(function()
                        ACS125_Functions.TakeDamage(LocalPlayer, -math.huge, -math.huge, -math.huge)
                    end, "ACS_R15_125_LoopHealth")
                else
                    RemoveLoopConnection("ACS_R15_125_LoopHealth")
                end
            end)
            
            UIElements.Toggles.ACS_R15_125_LoopHealthAll = ACS125Tab:Toggle("无敌所有人", false, function(val)
                Config.ACS_R15_125_LoopHealthAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            pcall(function()
                                ACS125_Functions.TakeDamage(player, -math.huge, -math.huge, -math.huge)
                            end)
                        end
                    end, "ACS_R15_125_LoopHealthAll")
                else
                    RemoveLoopConnection("ACS_R15_125_LoopHealthAll")
                end
            end)
            
            UIElements.Toggles.ACS_R15_125_LoopShake = ACS125Tab:Toggle("视角震动", false, function(val)
                Config.ACS_R15_125_LoopShake = val
                if val then
                    CreateLoopConnection(function()
                        for _ = 1, 5 do
                            for _, player in pairs(Players:GetChildren()) do
                                pcall(function()
                                    ACS125_Functions.Explode(player.Character.HumanoidRootPart, -math.huge, 0)
                                end)
                            end
                        end
                    end, "ACS_R15_125_LoopShake")
                else
                    RemoveLoopConnection("ACS_R15_125_LoopShake")
                end
            end)
        end
    end
    
    -- ==========================================
    -- ACS 2.0.1功能实现
    -- ==========================================
    local function SetupACS201Features()
        if ACS201_Detected then
            function ACS201_Functions.Kill(targetPlayer, engineRef, settingsRef)
                local currentEngine = engineRef
                local currentSettings = settingsRef
                
                if not currentEngine or not currentSettings then
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:FindFirstChild("ACS_Settings") then
                            currentSettings = obj:FindFirstChild("ACS_Settings")
                            currentEngine = obj
                            break
                        end
                    end
                end
                
                if currentEngine and currentSettings then
                    pcall(function()
                        ACS201_Events.Damage:InvokeServer(currentEngine, targetPlayer.Character.Humanoid, 10000, 1, 
                            require(currentSettings), {
                                minDamageMod = 1000000,
                                DamageMod = 1000000
                            }, nil, nil, ACS201_AccessId .. "-" .. LocalPlayer.UserId)
                    end)
                end
            end
            
            ACS201Tab:Button("杀所有", "了自己", function()
                for _, player in pairs(Players:GetChildren()) do
                    if player ~= LocalPlayer then
                        ACS201_Functions.Kill(player)
                    end
                end
            end)
            
            UIElements.Toggles.ACS_201_LoopKillAll = ACS201Tab:Toggle("循环杀所有", false, function(val)
                Config.ACS_201_LoopKillAll = val
                if val then
                    local foundEngine = nil
                    local foundSettings = nil
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:FindFirstChild("ACS_Settings") then
                            foundEngine = obj
                            foundSettings = obj:FindFirstChild("ACS_Settings")
                            break
                        end
                    end
                    
                    CreateLoopConnection(function()
                        if foundEngine.Parent == nil or foundSettings.Parent == nil then
                            for _, obj in pairs(game:GetDescendants()) do
                                if obj:FindFirstChild("ACS_Settings") then
                                    foundEngine = obj
                                    foundSettings = obj:FindFirstChild("ACS_Settings")
                                    break
                                end
                            end
                        end
                        
                        if foundEngine.Parent ~= nil and foundSettings.Parent ~= nil then
                            for _, player in pairs(Players:GetChildren()) do
                                if not Config.ACS_201_LoopKillAll then return end
                                if player ~= LocalPlayer then
                                    ACS201_Functions.Kill(player, foundEngine, foundSettings)
                                end
                            end
                        end
                    end, "ACS_201_LoopKillAll")
                else
                    RemoveLoopConnection("ACS_201_LoopKillAll")
                end
            end)
        end
    end
    
    -- ==========================================
    -- RCS功能实现
    -- ==========================================
    local function SetupRCSFeatures()
        if RCS_Detected then
            local rcsSection = RCSTab:Section("RCS漏洞")
            
            function RCS_Functions.Fire(origin, target, tool)
                local projectileId = RCS_Projectile:GetId()
                RCS_Network.WeaponEvents.Shoot_CTS.fire({
                    id = projectileId,
                    position = CFrame.lookAt(origin, target),
                    tool = tool
                })
            end
            
            function RCS_Functions.FindNewTool()
                local found = false
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("Tool") and obj:GetAttribute("Caliber") then
                        local isBlacklisted = false
                        for _, blockedName in pairs(RCS_ToolWhitelist) do
                            if string.find(obj.Name, blockedName) then
                                isBlacklisted = true
                            end
                        end
                        
                        if not isBlacklisted and (Players:GetPlayerFromCharacter(obj.Parent) or obj.Parent:IsA("Player")) then
                            found = true
                            RCS_Tool = obj
                            break
                        end
                    end
                end
                return found
            end
            
            local statusLabel = rcsSection:Label("状态", "未知")
            
            rcsSection:Button("找枪", "如果您无法击杀所有人请点击此按钮寻找新的枪", function()
                if RCS_Functions.FindNewTool() then
                    statusLabel:UpdateLabel("状态", RCS_Tool.Name)
                    ShowNotification({Title = "成功", Text = "找到枪", Selector = "Done", Duration = 5})
                else
                    statusLabel:UpdateLabel("状态", "未知")
                    ShowNotification({Title = "失败", Text = "没找到符合条件的枪", Selector = "Error", Duration = 5})
                end
            end)
            
            UIElements.Toggles.RCS_Rage = rcsSection:Toggle("暴力", false, function(val)
                Config.RCS_Rage = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            if player ~= LocalPlayer then
                                local myChar = LocalPlayer.Character
                                local targetChar = player.Character
                                if myChar and targetChar then
                                    local myHead = myChar:FindFirstChild("Head")
                                    local targetHead = targetChar:FindFirstChild("Head")
                                    if myHead and targetHead then
                                        local origin = myHead.Position
                                        local target = targetHead.Position
                                        local direction = (target - origin).Unit * (target - origin).Magnitude
                                        
                                        local rayParams = RaycastParams.new()
                                        rayParams.FilterDescendantsInstances = {myChar, targetChar}
                                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                        rayParams.IgnoreWater = true
                                        
                                        if not workspace:Raycast(origin, direction, rayParams) and 
                                           (RCS_Tool and RCS_Tool.Parent ~= nil) then
                                            RCS_Functions.Fire(origin, target, RCS_Tool)
                                        end
                                    end
                                end
                            end
                        end
                    end, "RCS_Rage")
                else
                    RemoveLoopConnection("RCS_Rage")
                end
            end)
            
            UIElements.Toggles.RCS_KillAll = rcsSection:Toggle("杀所有", false, function(val)
                Config.RCS_KillAll = val
                if val then
                    CreateLoopConnection(function()
                        for _, player in pairs(Players:GetChildren()) do
                            if player ~= LocalPlayer then
                                pcall(function()
                                    if RCS_Tool and RCS_Tool.Parent ~= nil then
                                        RCS_Functions.Fire(LocalPlayer.Character.HumanoidRootPart.Position, 
                                            player.Character.HumanoidRootPart.Position, RCS_Tool)
                                    end
                                end)
                            end
                        end
                    end, "RCS_KillAll")
                else
                    RemoveLoopConnection("RCS_KillAll")
                end
            end)
        end
    end
    
    -- ==========================================
    -- AC6功能实现
    -- ==========================================
    local function SetupAC6Features()
        if AC6_Detected then
            Config.AC6_Music_ID = "rbxassetid://142376088"
            Config.AC6_Name = "MeMeZ_Sound"
            Config.AC6_Pitch = 1
            Config.AC6_Volume = 1
            Config.AC6_Loop = false
            
            UIElements.Textboxes.AC6_Music_ID = AC6Tab:TextBox("AC6音频ID", "入您想要播放的音频id", function(val)
                if string.find(val, "rbxassetid://") then
                    Config.AC6_Music_ID = val
                else
                    Config.AC6_Music_ID = "rbxassetid://" .. tostring(val)
                end
            end)
            
            UIElements.Textboxes.AC6_Name = AC6Tab:TextBox("体名称", "入音频实体名称, 如果未填写默认随机数", function(val)
                Config.AC6_Name = val
            end)
            
            UIElements.Sliders.AC6_Pitch = AC6Tab:Slider("调 (10为正常)", 1, 10, 100, function(val)
                Config.AC6_Pitch = val / 10
            end)
            
            UIElements.Sliders.AC6_Volume = AC6Tab:Slider("量", 0, 1, 10, function(val)
                Config.AC6_Volume = val
            end)
            
            UIElements.Toggles.AC6_Loop = AC6Tab:Toggle("环", false, function(val)
                Config.AC6_Loop = val
            end)
            
            AC6Tab:Button("放", "放您设定好的音频", function()
                AC6_Remote:FireServer("newSound", Config.AC6_Name, Workspace, Config.AC6_Music_ID, 
                    Config.AC6_Pitch, Config.AC6_Volume, Config.AC6_Loop)
                local soundName = Config.AC6_Name
                local checks = 0
                local success = false
                repeat
                    task.wait(0.2)
                    checks = checks + 1
                    success = Workspace:FindFirstChild(soundName) and true or success
                until success or checks >= 10
                
                if success then
                    AC6_Remote:FireServer("playSound", soundName)
                else
                    ShowNotification({Title = "误", Text = "法创建音频实体", Selector = "Error", Duration = 2})
                end
            end)
            
            AC6Tab:Button("复", "果出现无法创建音频实体请点击此按钮寻找新的", function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "AC6_FE_Sounds" and obj:FindFirstChild("Handler") then
                        local randomId = math.random(1, 10000)
                        local soundName = tostring(randomId)
                        obj:FireServer("newSound", soundName, TestService, "rbxassetid://你妈死了", 1, 1, false)
                        local checks = 0
                        local success = false
                        repeat
                            task.wait(0.3)
                            checks = checks + 1
                            success = TestService:FindFirstChild(soundName) and true or success
                        until success or checks >= 5
                        
                        if success then
                            AC6_Remote = obj
                            break
                        end
                    end
                end
            end)
            
            AC6_InitialCheck = false
        end
    end
    
    -- ==========================================
    -- TonkSpawner Radio功能实现
    -- ==========================================
    local function SetupTonkSpawnerRadioFeatures()
        if TonkSpawnerRadio_Detected then
            Config.TonkSpawner_Music_ID = "rbxassetid://142376088"
            Config.TonkSpawner_Pitch = 1
            Config.TonkSpawner_Volume = 1
            
            UIElements.Textboxes.TonkSpawner_Music_ID = TonkSpawnerRadioTab:TextBox("TonkSpawner Radio音频ID", 
                "入您想要播放的音频id", function(val)
                    if string.find(val, "rbxassetid://") then
                        Config.TonkSpawner_Music_ID = string.gsub(val, "rbxassetid://", "")
                    else
                        Config.TonkSpawner_Music_ID = val
                    end
                end)
            
            UIElements.Sliders.TonkSpawner_Pitch = TonkSpawnerRadioTab:Slider("调 (10为正常)", 1, 10, 100, function(val)
                Config.TonkSpawner_Pitch = val / 10
            end)
            
            UIElements.Sliders.TonkSpawner_Volume = TonkSpawnerRadioTab:Slider("量", 0, 1, 10, function(val)
                Config.TonkSpawner_Volume = val
            end)
            
            TonkSpawnerRadioTab:Button("放", "放您设定好的音频", function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "MUSIC" and obj:IsA("RemoteEvent") and obj.Parent.Name == "Main" and 
                       obj.Parent:FindFirstChild("UpdateVP") then
                        obj:FireServer(Config.TonkSpawner_Music_ID)
                        obj.Parent.UpdateVP:FireServer(Config.TonkSpawner_Volume, Config.TonkSpawner_Pitch)
                    end
                end
            end)
        end
    end
    
    -- ==========================================
    -- 检测Carbon Engine资源
    -- ==========================================
    if ReplicatedStorage:FindFirstChild("CarbonResource") then
        local carbonResource = ReplicatedStorage:FindFirstChild("CarbonResource")
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if character then
            local rootCF = character:WaitForChild("HumanoidRootPart").CFrame
            character:WaitForChild("Humanoid").Health = 0
            
            repeat
                task.wait()
            until carbonResource:WaitForChild("Events"):GetChildren()[1].Name ~= ""
            
            for _, event in pairs(carbonResource:WaitForChild("Events"):GetChildren()) do
                CarbonEngineEvents[event.Name] = event
            end
            
            task.spawn(function()
                LocalPlayer.CharacterAdded:Wait()
                LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = rootCF
            end)
            
            CarbonEngineTab = MainWindow:Tab("CarbonEngine漏洞 (已通)")
            CarbonEngineDetected = true
            
            SetupCarbonEngineFeatures()
        end
    end
    
    -- ==========================================
    -- 检测ACS引擎版本并初始化
    -- ==========================================
    task.spawn(function()
        if ReplicatedStorage:FindFirstChild("ACS_Engine") then
            local engine = ReplicatedStorage.ACS_Engine
            
            -- ACS R15 1.1 检测
            if engine:FindFirstChild("Eventos") and engine.Eventos:FindFirstChild("ACS_AI") and 
               engine.Eventos.ACS_AI:FindFirstChild("Damage") then
                ACS11_Engine = engine
                ACS11_Events = ACS11_Engine:FindFirstChild("Eventos")
                
                local conn = nil
                conn = ACS11_Events.AcessId.OnClientEvent:Connect(function(key)
                    ACS11_AccessId = key
                    conn:Disconnect()
                end)
                ACS11_Events.AcessId:FireServer(LocalPlayer.UserId)
                repeat task.wait() until ACS11_AccessId
                
                ACS11Tab = MainWindow:Tab("ACS R15 1.1漏洞")
                ACS11_Detected = true
                SetupACS11Features()
            
            -- ACS 1.7.6 检测
            elseif engine:FindFirstChild("Eventos") and engine.Eventos:FindFirstChild("ACS_AI") and 
                   not (engine.Eventos.ACS_AI:FindFirstChild("Damage") or engine.Eventos:FindFirstChild("AcessId")) then
                ACS176_Engine = engine
                ACS176_Events = ACS176_Engine:FindFirstChild("Eventos")
                ACS176Tab = MainWindow:Tab("ACS 1.7.6 漏洞")
                ACS176_Detected = true
                SetupACS176Features()
            
            -- ACS 1.2.5 检测
            elseif engine:FindFirstChild("Eventos") and engine.Eventos:FindFirstChild("ACS_AI") and 
                   not engine.Eventos.ACS_AI:FindFirstChild("Damage") then
                ACS125_Engine = engine
                ACS125_Events = ACS125_Engine:FindFirstChild("Eventos")
                
                local conn = nil
                conn = ACS125_Events.AcessId.OnClientEvent:Connect(function(key)
                    ACS125_AccessId = key
                    conn:Disconnect()
                end)
                ACS125_Events.AcessId:FireServer(LocalPlayer.UserId)
                repeat task.wait() until ACS125_AccessId
                
                ACS125Tab = MainWindow:Tab("ACS R15 1.2.5漏洞")
                ACS125_Detected = true
                SetupACS125Features()
            
            -- ACS 2.0.1 检测
            elseif engine:FindFirstChild("Events") and engine.Events:FindFirstChild("AcessId") and 
                   engine.Events.AcessId:IsA("RemoteFunction") then
                ACS201_Engine = engine
                ACS201_Events = ACS201_Engine.Events
                ACS201_AccessId = ACS201_Events.AcessId:InvokeServer(LocalPlayer.UserId)
                repeat task.wait() until ACS201_AccessId
                
                ACS201Tab = MainWindow:Tab("ACS 2.0.1漏洞")
                ACS201_Detected = true
                SetupACS201Features()
            end
        end
    end)
    
    -- ==========================================
    -- 检测RCS引擎
    -- ==========================================
    if ReplicatedStorage:FindFirstChild("RCS") then
        local rcsFolder = ReplicatedStorage:FindFirstChild("RCS")
        RCS_Network = require(rcsFolder:WaitForChild("ClientNetwork"))
        RCS_Projectile = require(rcsFolder:WaitForChild("Modules"):WaitForChild("ProjectileV2"))
        RCSTab = MainWindow:Tab("RCS漏洞")
        RCS_Detected = true
        SetupRCSFeatures()
    end
    
    -- ==========================================
    -- 制作人员UI
    -- ==========================================
    local Section_Creators = CreatorsTab:Section("要制作人员")
    task.spawn(function()
        for _, creatorData in pairs(CreatorList) do
            Section_Creators:Image("MeMe", {
                Name = creatorData[1],
                ImageLink = string.format("https://qlogo2.store.qq.com/qzone/%s/%s/640", creatorData[2], creatorData[2]),
                ImageColor = Color3.fromRGB(255, 255, 255),
                Stroke = Color3.fromRGB(255, 255, 255),
                Description = creatorData[3],
                TypeofAsset = "Image",
                UseCurrent = false
            })
        end
    end)
    
    -- ==========================================
    -- Carbon点击交互
    -- ==========================================
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            local hit = mouse.Hit
            
            if target ~= nil and target.Parent:FindFirstChildOfClass("Humanoid") and Config.CarbonClickKill then
                CarbonEngineFunctions.DamageEvent(target.Parent:FindFirstChildOfClass("Humanoid"), math.huge)
            end
            
            if Config.CarbonClickBoom then
                CarbonEngineFunctions.Explode(hit.Position)
            end
        end
    end)
    
    -- ==========================================
    -- 新漏洞搜索UI
    -- ==========================================
    local Section_Exploits = ExploitFinderTab:Section("新寻找漏洞")
    
    Section_Exploits:Button("新寻找AC6", "新寻找AC6, 如果成功将显示AC6漏洞界面", function()
        if not AC6_InitialCheck then
            if AC6_Detected then
                ShowNotification({Title = "功", Text = "需重新寻找", Selector = "Done", Duration = 5})
            else
                AC6_InitialCheck = true
                if ScanForAC6() then
                    AC6Tab = MainWindow:Tab("AC6 漏洞")
                    SetupAC6Features()
                    ShowNotification({Title = "功", Text = "功加载AC6漏洞", Selector = "Done", Duration = 5})
                else
                    AC6_InitialCheck = false
                    ShowNotification({Title = "败", Text = "法找到AC6漏洞", Selector = "Error", Duration = 5})
                end
            end
        end
    end)
    
    Section_Exploits:Button("新寻找TonkSpawner Radio", "新寻找TonkSpawner Radio, 如果成功将显示TonkSpawner Radio漏洞界面", function()
        if not TonkSpawnerRadio_InitialCheck then
            if TonkSpawnerRadio_Detected then
                ShowNotification({Title = "功", Text = "需重新寻找", Selector = "Done", Duration = 5})
            else
                TonkSpawnerRadio_InitialCheck = true
                if ScanForTonkSpawnerRadio() then
                    TonkSpawnerRadioTab = MainWindow:Tab("TonkSpawner Radio 漏洞")
                    SetupTonkSpawnerRadioFeatures()
                    ShowNotification({Title = "功", Text = "功加载TonkSpawner Radio漏洞", Selector = "Done", Duration = 5})
                else
                    TonkSpawnerRadio_InitialCheck = false
                    ShowNotification({Title = "败", Text = "法找到TonkSpawner Radio漏洞", Selector = "Error", Duration = 5})
                end
            end
        end
    end)
    
    -- 延迟初始化AC6 UI如果已经找到
    task.spawn(function()
        repeat task.wait(1) until AC6_Detected
        SetupAC6Features()
    end)
    
    if TonkSpawnerRadio_Detected then
        SetupTonkSpawnerRadioFeatures()
    end
    
    -- ==========================================
    -- 玩家列表与传送功能
    -- ==========================================
    local Dropdown_PlayerList = PlayerTab:Dropdown("家列表", Players:GetChildren(), function(val)
        SelectedPlayer = val
    end)
    
    PlayerTab:Button("送", "送到选中的玩家", function()
        pcall(function()
            if Config.LoopGotoPos ~= "面" then
                TeleportToCFrame(Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.CFrame * Config.LoopGotoPos)
            else
                TeleportToCFrame(Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.CFrame - 
                    Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.CFrame.LookVector * 5)
            end
        end)
    end)
    
    UIElements.Dropdowns.LoopGotoPos = PlayerTab:Dropdown("环传送方法", {"合", "面", "面", "面"}, function(val)
        if val == "合" then
            Config.LoopGotoPos = CFrame.new(0, 0, 0)
        elseif val == "面" then
            Config.LoopGotoPos = CFrame.new(0, 5, 0)
        elseif val == "面" then
            Config.LoopGotoPos = CFrame.new(0, -5, 0)
        else
            Config.LoopGotoPos = "面"
        end
    end)
    
    UIElements.Toggles.LoopGotoSP = PlayerTab:Toggle("环传送", false, function(val)
        Config.LoopGotoSP = val
        if val then
            CreateLoopConnection(function()
                pcall(function()
                    if Config.LoopGotoPos ~= "面" then
                        TeleportToCFrame(Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.CFrame * Config.LoopGotoPos)
                    else
                        TeleportToCFrame(Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.CFrame - 
                            Players:FindFirstChild(SelectedPlayer).Character.HumanoidRootPart.CFrame.LookVector * 5)
                    end
                end)
            end, "LoopGotoSP")
        else
            RemoveLoopConnection("LoopGotoSP")
        end
    end)
    
    -- ==========================================
    -- 地图/角色属性修改
    -- ==========================================
    local Section_Map = MapTab:Section("地玩家")
    
    UIElements.Sliders.Tpwalk = Section_Map:Slider("移速度", 0, 0, 120, function(val)
        Config.Tpwalk = val
    end)
    
    UIElements.Toggles.TpwalkEnabled = Section_Map:Toggle("移", false, function(val)
        Config.TpwalkEnabled = val
        if val then
            CreateLoopConnection(function()
                if Config.TpwalkEnabled and LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    LocalPlayer.Character:TranslateBy(LocalPlayer.Character.Humanoid.MoveDirection * Config.Tpwalk / 10)
                end
            end, "TpwalkEnabled")
        else
            RemoveLoopConnection("TpwalkEnabled")
        end
    end)
    
    UIElements.Sliders.WalkSpeed = Section_Map:Slider("动速度", 0, OriginalWalkSpeed, 200, function(val)
        Config.WalkSpeed = val
    end)
    
    UIElements.Toggles.WalkSpeedEnabled = Section_Map:Toggle("改移动速度", false, function(val)
        if not val then
            pcall(function()
                LocalPlayer.Character.Humanoid.WalkSpeed = OriginalWalkSpeed
            end)
        end
        Config.WalkSpeedEnabled = val
    end)
    
    UIElements.Sliders.JumpPower = Section_Map:Slider("跳力度", 0, OriginalJumpPower, 500, function(val)
        Config.JumpPower = val
    end)
    
    UIElements.Toggles.JumpPowerEnabled = Section_Map:Toggle("改跳跃力度", false, function(val)
        if not val then
            pcall(function()
                LocalPlayer.Character.Humanoid.JumpPower = OriginalJumpPower
            end)
        end
        Config.JumpPowerEnabled = val
    end)
    
    UIElements.Sliders.HipHeight = Section_Map:Slider("立高度", -2, OriginalHipHeight, 25, function(val)
        Config.HipHeight = val
    end)
    
    UIElements.Toggles.HipHeightEnabled = Section_Map:Toggle("改站立高度", false, function(val)
        if not val then
            pcall(function()
                LocalPlayer.Character.Humanoid.HipHeight = OriginalHipHeight
            end)
        end
        Config.HipHeightEnabled = val
    end)
    
    UIElements.Sliders.FlySpeed = Section_Map:Slider("行速度", 0, 25, 250, function(val)
        Config.FlySpeed = val
    end)
    
    UIElements.Toggles.Fly = Section_Map:Toggle("行", false, function(val)
        if val then
            CreateLoopConnection(function()
                pcall(function()
                    if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("pp") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "pp"
                        bv.Parent = LocalPlayer.Character.HumanoidRootPart
                        bv.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                    if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("cc") then
                        local bg = Instance.new("BodyGyro")
                        bg.Name = "cc"
                        bg.Parent = LocalPlayer.Character.HumanoidRootPart
                        bg.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
                        bg.P = 1000
                        bg.D = 50
                    end
                    LocalPlayer.Character.HumanoidRootPart.cc.CFrame = CurrentCamera.CFrame
                    local moveVector = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector()
                    LocalPlayer.Character.HumanoidRootPart.pp.Velocity = Vector3.new()
                    
                    if moveVector.X > 0 then
                        LocalPlayer.Character.HumanoidRootPart.pp.Velocity = LocalPlayer.Character.HumanoidRootPart.pp.Velocity + 
                            CurrentCamera.CFrame.RightVector * (moveVector.X * Config.FlySpeed)
                    end
                    if moveVector.X < 0 then
                        LocalPlayer.Character.HumanoidRootPart.pp.Velocity = LocalPlayer.Character.HumanoidRootPart.pp.Velocity + 
                            CurrentCamera.CFrame.RightVector * (moveVector.X * Config.FlySpeed)
                    end
                    if moveVector.Z > 0 then
                        LocalPlayer.Character.HumanoidRootPart.pp.Velocity = LocalPlayer.Character.HumanoidRootPart.pp.Velocity - 
                            CurrentCamera.CFrame.LookVector * (moveVector.Z * Config.FlySpeed)
                    end
                    if moveVector.Z < 0 then
                        LocalPlayer.Character.HumanoidRootPart.pp.Velocity = LocalPlayer.Character.HumanoidRootPart.pp.Velocity - 
                            CurrentCamera.CFrame.LookVector * (moveVector.Z * Config.FlySpeed)
                    end
                    LocalPlayer.Character.Humanoid.PlatformStand = true
                end)
            end, "Fly")
        else
            pcall(function()
                RemoveLoopConnection("Fly")
                LocalPlayer.Character.Humanoid.PlatformStand = false
                if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("pp") then
                    LocalPlayer.Character.HumanoidRootPart:FindFirstChild("pp"):Destroy()
                end
                if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("cc") then
                    LocalPlayer.Character.HumanoidRootPart:FindFirstChild("cc"):Destroy()
                end
            end)
        end
    end)
    
    UIElements.Toggles.Noclip = Section_Map:Toggle("墙", false, function(val)
        Config.Noclip = val
        if val then
            CreateLoopConnection(function()
                pcall(function()
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end, "Noclip")
        else
            pcall(function()
                RemoveLoopConnection("Noclip")
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end)
        end
    end)
    
    local Section_Visuals = MapTab:Section("地视觉")
    
    UIElements.Sliders.FOV = Section_Visuals:Slider("FOV", 0, OriginalFOV, 120, function(val)
        Config.FOV = val
    end)
    
    UIElements.Toggles.FOVEnabled = Section_Visuals:Toggle("改FOV", false, function(val)
        if not val then
            CurrentCamera.FieldOfView = OriginalFOV
        end
        Config.FOVEnabled = val
    end)
    
    UIElements.Sliders.CameraMinZoomDistance = Section_Visuals:Slider("小缩放距离", 0, OriginalFOV, 2500, function(val)
        Config.CameraMinZoomDistance = val
    end)
    
    UIElements.Toggles.CameraMinZoomDistanceEnabled = Section_Visuals:Toggle("改最小缩放距离", false, function(val)
        if not val then
            LocalPlayer.CameraMinZoomDistance = OriginalMinZoom
        end
        Config.CameraMinZoomDistanceEnabled = val
    end)
    
    UIElements.Sliders.CameraMaxZoomDistance = Section_Visuals:Slider("大缩放距离", 0, OriginalFOV, 2500, function(val)
        Config.CameraMaxZoomDistance = val
    end)
    
    UIElements.Toggles.CameraMaxZoomDistanceEnabled = Section_Visuals:Toggle("改最大缩放距离", false, function(val)
        if not val then
            LocalPlayer.CameraMaxZoomDistance = OriginalMaxZoom
        end
        Config.CameraMaxZoomDistanceEnabled = val
    end)
    
    -- 全局属性循环更新
    CreateLoopConnection(function()
        if Config.FOVEnabled then
            CurrentCamera.FieldOfView = Config.FOV
        end
        if Config.CameraMinZoomDistanceEnabled then
            LocalPlayer.CameraMinZoomDistance = Config.CameraMinZoomDistance
        end
        if Config.CameraMaxZoomDistanceEnabled then
            LocalPlayer.CameraMaxZoomDistance = Config.CameraMaxZoomDistance
        end
        if Config.WalkSpeedEnabled then
            pcall(function()
                LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
            end)
        end
        if Config.JumpPowerEnabled then
            pcall(function()
                LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPower
            end)
        end
        if Config.HipHeightEnabled then
            pcall(function()
                LocalPlayer.Character.Humanoid.HipHeight = Config.HipHeight
            end)
        end
    end)
    
    -- ==========================================
    -- 音乐模块逻辑
    -- ==========================================
    if MusicTab then
        MusicSection:Dropdown("前选择的音乐", UILibrary:GetPlaylist(), function(val)
            Config.SelectedMusic = val
        end)
        
        UIElements.Textboxes.SelectedCustomMusic = MusicSection:TextBox("定音乐", "入您存放在 MeMeZ/Music 的音乐文件名", function(val)
            if isfile("MeMeZ/Music/" .. val) then
                Config.SelectedCustomMusic = UILibrary:LoadCustomAsset("MeMeZ/Music/" .. val, "Music", true)
                ShowNotification({Title = "功", Text = "找到选择的音乐文件", Selector = "Done", Duration = 5})
            else
                ShowNotification({Title = "误", Text = "法找到选择的音乐文件名", Selector = "Error", Duration = 5})
            end
        end)
        
        MusicSection:Button("放音乐", "放 用户 选择的预设音乐", function()
            UILibrary:PlayMusic(Config.SelectedMusic)
        end)
        
        UIElements.Toggles.LoopMusic = MusicSection:Toggle("环播放音乐", false, function(val)
            UIElements.Toggles.LoopRandomMusic:UpdateToggle(not val)
            Config.LoopMusic = val
        end)
        
        UIElements.Toggles.LoopRandomMusic = MusicSection:Toggle("环随机播放音乐", true, function(val)
            UIElements.Toggles.LoopMusic:UpdateToggle(not val)
            Config.LoopRandomMusic = val
        end)
        
        MusicSection:Button("放自定义音乐", "放 用户 的自定义音乐", function()
            UILibrary:PlayMusic(Config.SelectedCustomMusic, true)
        end)
        
        MusicSection:Button("止音乐", "止正在播放的音乐", function()
            UILibrary:StopMusic()
        end)
        
        MusicSection:Button("载所有的音乐", "载所有MeMeZ预设音乐", function()
            UILibrary:DownloadAllMusics()
        end)
        
        UILibrary:MusicEnded(function()
            if Config.LoopMusic then
                UILibrary:PlayMusic(Config.SelectedMusic)
            elseif Config.LoopRandomMusic then
                UILibrary:PlayRandomMusic()
            end
        end)
    end
    
    -- ==========================================
    -- 玩家加入/离开事件
    -- ==========================================
    Players.PlayerAdded:Connect(function(player)
        Dropdown_PlayerList:Add(player.Name)
        if RespectList[tostring(player.UserId)] then
            ShowNotification({
                Title = "告",
                Text = "敬的" .. RespectList[tostring(player.UserId)] .. "(" .. player.Name .. "/" .. player.DisplayName .. ")加入服务器",
                Selector = "Notify",
                Duration = 3
            })
        else
            ShowNotification({
                Title = "告",
                Text = "(" .. player.Name .. "/" .. player.DisplayName .. ")加入服务器",
                Selector = "Notify",
                Duration = 3
            })
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        Dropdown_PlayerList:Remove(player.Name)
        if RespectList[tostring(player.UserId)] then
            ShowNotification({
                Title = "告",
                Text = "敬的" .. RespectList[tostring(player.UserId)] .. "(" .. player.Name .. "/" .. player.DisplayName .. ")离开了服务器",
                Selector = "Notify",
                Duration = 3
            })
        else
            ShowNotification({
                Title = "告",
                Text = "(" .. player.Name .. "/" .. player.DisplayName .. ")离开了服务器",
                Selector = "Notify",
                Duration = 3
            })
        end
    end)
    
    -- ==========================================
    -- 绕过检测与结束
    -- ==========================================
    if game:GetService("TextChatService").ChatVersion ~= Enum.ChatVersion.LegacyChatService then
        ShowNotification({Title = "警", Text = "法为您绕过Roblox聊天检测", Selector = "Warning", Duration = 5})
    else
        ShowNotify({
            Title = "告",
            Text = "否关闭Roblox聊天检测?",
            Selector = "Notify",
            Callback = function()
                rawset(require(LocalPlayer:FindFirstChild("PlayerScripts"):FindFirstChild("ChatScript").ChatMain), "MessagePosted", {
                    fire = function(self) return self end,
                    wait = function() end,
                    connect = function() end
                })
                ShowNotification({Title = "功", Text = "为您绕过Roblox聊天检测", Selector = "Done", Duration = 5})
            end
        })
    end
    
    ShowNotify({
        Title = "告",
        Text = "否绕过Adonis?",
        Selector = "Notify",
        Callback = function()
            loadstring(game:HttpGet(getgenv().MeMeZStorage .. "Modules/AdonisBypass.lua"))()
        end
    })
    
    -- ==========================================
    -- 完成加载
    -- ==========================================
    local loadTime = tick() - startTime
    task.wait(1)
    ShowNotification({
        Title = "告",
        Text = "MeMeZ加载完毕!, 耗时: " .. loadTime,
        Selector = "Done",
        Duration = 3
    })
    
    -- ==========================================
    -- 连接断开处理
    -- ==========================================
    game:BindToClose(function()
        for _, connection in pairs(ScriptConnections) do
            connection:Disconnect()
        end
        
        for _, connection in pairs(LoopConnections) do
            connection:Disconnect()
        end
        
        -- 重置所有设置
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = OriginalWalkSpeed
            LocalPlayer.Character.Humanoid.JumpPower = OriginalJumpPower
            LocalPlayer.Character.Humanoid.HipHeight = OriginalHipHeight
        end
        
        CurrentCamera.FieldOfView = OriginalFOV
        LocalPlayer.CameraMinZoomDistance = OriginalMinZoom
        LocalPlayer.CameraMaxZoomDistance = OriginalMaxZoom
    end)
end