if not game:IsLoaded() then game.Loaded:Wait() end

local Players = cloneref(game:GetService("Players"))
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = cloneref(game:GetService("TeleportService"))
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character
local HumanoidRootPart
local Humanoid

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end
Character = LocalPlayer.Character
HumanoidRootPart = Character and (Character.PrimaryPart or Character:WaitForChild("HumanoidRootPart", 10))
Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:FindFirstChildOfClass("Humanoid")
end)

local GizmosFolder = workspace.Local.Gizmos.White

-- 预定义的传送位置列表（备用位置）
local TeleportLocations = {
    Vector3.new(-1137, 78, -1953),
    Vector3.new(-44, 63, -2083),
    Vector3.new(194, 60, -2884),
    Vector3.new(-412, 106, -1301),
    Vector3.new(-377, 410, -741),
    Vector3.new(-985, 380, -1145),
    Vector3.new(-854, 406, -1505)
}

local IsRunning = true  -- 脚本运行状态
local NoATMTime = 0     -- 没有找到ATM的时间计数器
local MaxNoATMTime = 30 -- 最大无ATM时间（秒），超过则切换服务器

-- 自动换服相关变量
local Serverlist = {}
local time = os.time()

-- 函数：获取服务器列表
local function getServers()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        if not response or response == "" then
            return
        end
        
        local success2, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if success2 then
            return data
        end
    end
end

-- 函数：初始化服务器列表
local function initServerList()
    local servers = getServers()
    Serverlist = {}
    
    if servers and servers.data then
        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(Serverlist, server.id)
            end
        end
    end
    
    print("找到 " .. #Serverlist .. " 个可用服务器")
end

-- 函数：切换到其他服务器
local function SwitchToDifferentServer()
    print("正在寻找新服务器...")
    initServerList()
    
    if #Serverlist > 0 then
        local targetServer = Serverlist[math.random(1, #Serverlist)]
        print("切换到服务器: " .. targetServer)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer)
        return true
    else
        print("未找到可用服务器，等待5秒后重试...")
        task.wait(5)
        return false
    end
end

-- 函数：从实例中查找BasePart（基础部件）
local function FindBasePart(instance)
    if instance:IsA("BasePart") then
        return instance
    end
    
    -- 遍历所有子对象查找BasePart
    for _, child in ipairs(instance:GetDescendants()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    
    return nil
end

-- 函数：检查是否为ATM或收银机
local function IsGizmoATMOrRegister(gizmo)
    local gizmoType = gizmo:GetAttribute("gizmoType")
    return gizmoType == "ATM" or gizmoType == "Register"
end

-- 函数：查找最近的ATM或收银机
local function FindNearestATM()
    local nearestDistance = math.huge
    local nearestATM = nil
    
    -- 检查Gizmos文件夹是否存在
    if not GizmosFolder then
        return nil
    end
    
    -- 遍历所有Gizmos
    for _, gizmo in ipairs(GizmosFolder:GetChildren()) do
        if IsGizmoATMOrRegister(gizmo) then
            local basePart = FindBasePart(gizmo)
            if basePart then
                local distance = (HumanoidRootPart.Position - basePart.Position).Magnitude
                if distance < nearestDistance then
                    nearestATM = basePart
                    nearestDistance = distance
                end
            end
        end
    end
    
    return nearestATM
end

-- 函数：传送到指定位置或部件
local function TeleportToTarget(target)
    if typeof(target) ~= "Instance" then
        -- 如果目标是Vector3，直接传送到该位置
        if typeof(target) == "Vector3" then
            HumanoidRootPart.CFrame = CFrame.new(target)
        end
    else
        -- 如果目标是实例，传送到其上方5个单位处
        HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
    end
end

-- 函数：模拟按键E（用于与ATM/收银机交互）
local function PressEForDuration(duration)
    local startTime = tick()
    while tick() - startTime < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.05)
    end
end

-- 函数：收集ATM/收银机
local function CollectATM(atmPart)
    local startTime = tick()
    local timeout = 3  -- 3秒超时
    
    -- 等待ATM被收集（属性改变）或超时
    while tick() - startTime < timeout and (atmPart.Parent and not atmPart:GetAttribute("Collected")) do
        task.wait(0.1)
    end
    
    -- 按下E键1.5秒进行收集
    PressEForDuration(1.5)
end

-- 初始化服务器列表
initServerList()

-- 设置传送后自动重新运行脚本
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        queue_on_teleport([[
            if not game:IsLoaded() then game.Loaded:Wait() end
            
            local Players = cloneref(game:GetService("Players"))
            local LocalPlayer = Players.LocalPlayer
            
            if not LocalPlayer.Character then
                LocalPlayer.CharacterAdded:Wait()
            end
            
            print("自动换服完成，重新运行脚本...")
            
            -- 重新加载脚本
            loadstring(game:HttpGet('https://raw.githubusercontent.com/你的仓库路径/ATM_AutoFarm.lua'))()
        ]])
    end
end)

-- 主循环：自动化收集过程
task.spawn(function()
    local lastATMFoundTime = tick()
    
    while IsRunning do
        if not HumanoidRootPart or not Humanoid then
            task.wait(1)
            continue
        end
        
        local nearestATM = FindNearestATM()
        
        if nearestATM then
            -- 找到ATM，传送到ATM位置
            TeleportToTarget(nearestATM)
            task.wait(0.3)
            
            -- 按下E键进行交互
            PressEForDuration(1.5)
            
            -- 收集ATM
            CollectATM(nearestATM)
            
            -- 重置无ATM时间计数器
            NoATMTime = 0
            lastATMFoundTime = tick()
            
            print("成功收集ATM，重置计时器")
        else
            -- 未找到ATM，增加计数器
            NoATMTime = NoATMTime + 0.7
            
            -- 随机传送到一个备用位置
            local randomLocation = TeleportLocations[math.random(1, #TeleportLocations)]
            TeleportToTarget(randomLocation)
            
            -- 如果超过MaxNoATMTime秒未找到ATM，切换到其他服务器
            if MaxNoATMTime <= NoATMTime then
                print(string.format("%d秒内未找到ATM，正在换服...", MaxNoATMTime))
                task.wait(1)
                
                -- 尝试换服
                local success = SwitchToDifferentServer()
                if success then
                    break  -- 成功发起传送，跳出循环
                else
                    -- 换服失败，重置计时器继续尝试
                    NoATMTime = MaxNoATMTime - 10  -- 重置为稍短的时间，避免立即再次尝试
                    print("换服失败，继续在当前服务器寻找...")
                end
            else
                print(string.format("未找到ATM，已等待%.1f秒（将在%.1f秒后换服）", 
                    NoATMTime, MaxNoATMTime - NoATMTime))
            end
        end
        
        -- 等待0.7秒后继续循环
        task.wait(0.7)
    end
end)

-- 备用换服检测（每5分钟自动换服，避免长时间在同一个服务器）
task.spawn(function()
    while IsRunning do
        task.wait(300)  -- 等待5分钟
        
        if IsRunning then
            print("5分钟已到，自动换服以避免被检测...")
            SwitchToDifferentServer()
            break
        end
    end
end)
