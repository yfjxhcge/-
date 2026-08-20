--[[ 👑 Delta Ultimate 至尊版 v6.0 ]]
-- WasUIPro UI 库 (截图同款超长UI)
local WasUIPro = loadstring(game:HttpGet("https://github.com/WasKKal/WasUI-For-Roblox/raw/refs/heads/main/WasUIPro.lua"))()

local Uis = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local L = game:GetService("Lighting")
local H = game:GetService("HttpService")
local LP = Players.LocalPlayer

WasUIPro:SetDefaultTheme("Dark")
WasUIPro:SetDefaultRainbowMode("流动")
WasUIPro:SetLanguage("中文")

local mainWindow = WasUIPro:CreateWindow({
    Title = "👑 Delta 至尊版 v6.0",
    WelcomeText = "至尊功能全部拉满",
    MinimizedText = "Delta至尊",
    Theme = "Dark",
    RainbowMode = "流动",
    DialogTitle = "确认关闭窗口",
    GroupText = "至尊交流群",
    GroupCopy = "123456789",
    SnowEnabled = true,
    Folder = "Delta至尊版配置",
    FeatureNameColor = {Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 100, 50)}
})

-- ========== 通用 Tab ==========
local MainTab = mainWindow:Tab({ Title = "⚡ 通用" })
local MainCat = MainTab:Category({ Title = "移动与视角", IconName = "zap" })

local speedVal = 16
local jumpVal = 50
local fovVal = 70

MainCat:Slider({
    Title = "移动速度",
    Min = 16, Max = 200, Default = 16, ConfigKey = "walk_speed",
    Callback = function(v)
        speedVal = v
        local c = LP.Character
        if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.WalkSpeed = v end
    end
})
MainCat:Slider({
    Title = "跳跃高度",
    Min = 1, Max = 200, Default = 50, ConfigKey = "jump_power",
    Callback = function(v)
        jumpVal = v
        local c = LP.Character
        if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.JumpPower = v end
    end
})
MainCat:Slider({
    Title = "视野范围",
    Min = 10, Max = 120, Default = 70, ConfigKey = "fov",
    Callback = function(v)
        fovVal = v
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = v end
    end
})

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedVal; hum.JumpPower = jumpVal end
    pcall(function() workspace.CurrentCamera.FieldOfView = fovVal end)
end)

local SpeedCat = MainTab:Category({ Title = "飞行与穿墙", IconName = "feather" })

local flyEnabled = false
local flyBG, flyBV = nil, nil
SpeedCat:Toggle({
    Title = "飞行模式",
    Value = false,
    FeatureName = "Fly",
    Icon = "feather",
    ConfigKey = "fly_mode",
    Callback = function(state)
        flyEnabled = state
        local c = LP.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if state then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.D = 1000; flyBG.P = 9000
            flyBG.cframe = hrp.CFrame
            flyBG.Parent = hrp
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = hrp
            local flyLoop
            flyLoop = RS.RenderStepped:Connect(function()
                if not flyEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
                    if flyLoop then flyLoop:Disconnect() end
                    return
                end
                local h = LP.Character.HumanoidRootPart
                local move = Vector3.new()
                local cam = workspace.CurrentCamera
                if Uis:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if Uis:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if Uis:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if Uis:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if Uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if Uis:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
                if move.Magnitude > 0 then move = move.Unit * 50 end
                flyBV.Velocity = move
                flyBG.cframe = cam.CFrame
            end)
        else
            if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
            if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
        end
    end
})

SpeedCat:Toggle({
    Title = "穿墙模式",
    Value = false,
    FeatureName = "Noclip",
    Icon = "unlock",
    ConfigKey = "noclip",
    Callback = function(state)
        if state then
            local nl
            nl = RS.Stepped:Connect(function()
                local c = LP.Character
                if not c then return end
                for _, v in pairs(c:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = false end
                end
            end)
            _G.DU_NL = nl
        else
            if _G.DU_NL then pcall(function() _G.DU_NL:Disconnect() end); _G.DU_NL = nil end
        end
    end
})

SpeedCat:Toggle({
    Title = "夜视",
    Value = false,
    FeatureName = "NightVision",
    Icon = "moon",
    ConfigKey = "night_vision",
    Callback = function(state)
        if state then L.Ambient = Color3.new(1,1,1); L.OutdoorAmbient = Color3.new(1,1,1)
        else L.Ambient = Color3.new(0,0,0); L.OutdoorAmbient = Color3.new(0,0,0) end
    end
})

SpeedCat:Toggle({
    Title = "全亮模式",
    Value = false,
    FeatureName = "FullBright",
    Icon = "sun",
    ConfigKey = "full_bright",
    Callback = function(state)
        if state then
            L.Brightness = 2; L.ClockTime = 12; L.FogEnd = 100000; L.OutdoorAmbient = Color3.fromRGB(255,255,255)
        else
            L.Brightness = 1; L.ClockTime = 14; L.FogEnd = 500
        end
    end
})

print("✅ 通用页加载完成")

-- ========== 战斗 Tab ==========
local CombatTab = mainWindow:Tab({ Title = "⚔️ 战斗" })
local CombatCat = CombatTab:Category({ Title = "战斗功能", IconName = "swords" })

local aimEnabled = false
CombatCat:Toggle({
    Title = "自瞄",
    Value = false,
    FeatureName = "Aimbot",
    Icon = "crosshair",
    ConfigKey = "aimbot",
    Callback = function(state) aimEnabled = state end
})

RS.RenderStepped:Connect(function()
    if not aimEnabled then return end
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local myPos = c.HumanoidRootPart.Position
    local target, targetDist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (v.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d < targetDist then targetDist = d; target = v end
        end
    end
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local cam = workspace.CurrentCamera
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Character.Head.Position)
    end
end)

local killAuraEnabled = false
CombatCat:Toggle({
    Title = "杀戮光环",
    Value = false,
    FeatureName = "KillAura",
    Icon = "skull",
    ConfigKey = "kill_aura",
    Callback = function(state) killAuraEnabled = state end
})

RS.Heartbeat:Connect(function()
    if not killAuraEnabled then return end
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local myPos = c.HumanoidRootPart.Position
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (v.Character.HumanoidRootPart.Position - myPos).Magnitude
            if d <= 30 then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:TakeDamage(25) end) end
            end
        end
    end
end)

CombatCat:Button({
    Text = "全屏冻结",
    Icon = "snowflake",
    Tooltip = "冻结所有其他玩家",
    Callback = function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then pcall(function() hrp.Anchored = true end) end
            end
        end
        WasUIPro:Notify({ Title = "冻结", Content = "已冻结所有玩家", Duration = 2 })
    end
})

CombatCat:Button({
    Text = "强制踢出所有玩家",
    Icon = "user-x",
    Tooltip = "踢出其他所有玩家",
    Callback = function()
        WasUIPro:ShowConfirmDialog({
            title = "确认踢出",
            description = "将踢出所有其他玩家，是否继续？",
            confirmText = "确定",
            cancelText = "取消",
            onConfirm = function()
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LP then pcall(function() v:Kick("至尊管理员踢出") end) end
                end
                WasUIPro:Notify({ Title = "踢出", Content = "已踢出所有玩家", Duration = 2 })
            end
        })
    end
})

CombatCat:Button({
    Text = "子弹追踪(元表)",
    Icon = "target",
    Tooltip = "通过元表劫持实现子弹追踪",
    Callback = function()
        local Camera = workspace.CurrentCamera
        local function GetClosest()
            local closest, dist = nil, math.huge
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; closest = v end
                end
            end
            return closest
        end
        pcall(function()
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(obj, ...)
                local method = getnamecallmethod()
                local args = {...}
                if tostring(method) == "FindPartOnRayWithIgnoreList" then
                    local target = GetClosest()
                    if target and target.Character then
                        args[1] = Ray.new(Camera.CFrame.Position, (target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
                    end
                end
                return old(obj, unpack(args))
            end)
            setreadonly(mt, true)
        end)
        WasUIPro:Notify({ Title = "子弹追踪", Content = "元表钩子已注入", Duration = 2 })
    end
})

print("✅ 战斗页加载完成")

-- ========== 视觉 Tab ==========
local VisualTab = mainWindow:Tab({ Title = "👁️ 视觉" })
local VisualCat = VisualTab:Category({ Title = "透视与视觉", IconName = "eye" })

local espEnabled = false
local espHighlights = {}
local espLoop
VisualCat:Toggle({
    Title = "ESP透视",
    Value = false,
    FeatureName = "ESP",
    Icon = "eye",
    ConfigKey = "esp",
    Callback = function(state)
        espEnabled = state
        if state then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character then
                    local h = Instance.new("Highlight")
                    h.Adornee = v.Character
                    h.FillColor = Color3.fromRGB(255, 50, 50)
                    h.FillTransparency = 0.5
                    pcall(function() h.Parent = game:GetService("CoreGui") end)
                    table.insert(espHighlights, h)
                end
            end
            espLoop = RS.RenderStepped:Connect(function()
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LP and v.Character then
                        local found = false
                        for _, h in pairs(espHighlights) do
                            if h.Adornee == v.Character then found = true break end
                        end
                        if not found then
                            local h = Instance.new("Highlight")
                            h.Adornee = v.Character
                            h.FillColor = Color3.fromRGB(255, 50, 50)
                            h.FillTransparency = 0.5
                            pcall(function() h.Parent = game:GetService("CoreGui") end)
                            table.insert(espHighlights, h)
                        end
                    end
                end
            end)
        else
            for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
            espHighlights = {}
            if espLoop then espLoop:Disconnect(); espLoop = nil end
        end
    end
})

VisualCat:Toggle({
    Title = "透视物品",
    Value = false,
    FeatureName = "ItemESP",
    Icon = "package",
    ConfigKey = "item_esp",
    Callback = function(state)
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Tool") or (v:IsA("Part") and (v.Name:find("Chest") or v.Name:find("Item") or v.Name:find("Loot") or v.Name:find("Crate"))) then
                    pcall(function()
                        local h = Instance.new("Highlight")
                        h.Adornee = v
                        h.FillColor = Color3.fromRGB(255, 200, 0)
                        h.FillTransparency = 0.3
                        h.Parent = game:GetService("CoreGui")
                    end)
                end
            end
        end
    end
})

-- ========== 玩家 Tab ==========
local PlayerTab = mainWindow:Tab({ Title = "🧍 玩家" })
local PlayerCat = PlayerTab:Category({ Title = "玩家增强", IconName = "user" })

PlayerCat:Button({
    Text = "拉取所有玩家",
    Icon = "users",
    Tooltip = "将所有玩家拉到身边",
    Callback = function()
        local c = LP.Character
        if not c or not c:FindFirstChild("HumanoidRootPart") then
            WasUIPro:Notify({ Title = "错误", Content = "角色未加载", Duration = 2 })
            return
        end
        local myPos = c.HumanoidRootPart.Position
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() v.Character.HumanoidRootPart.CFrame = CFrame.new(myPos + Vector3.new(math.random(-5,5), 3, math.random(-5,5))) end)
            end
        end
        WasUIPro:Notify({ Title = "拉取", Content = "已拉取所有玩家", Duration = 2 })
    end
})

local invisibleEnabled = false
PlayerCat:Toggle({
    Title = "隐身模式",
    Value = false,
    FeatureName = "Invisible",
    Icon = "ghost",
    ConfigKey = "invisible",
    Callback = function(state)
        invisibleEnabled = state
        local c = LP.Character
        if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = state and 1 or 0
                v.CanCollide = state and false or true
            end
        end
    end
})

local godModeEnabled = false
PlayerCat:Toggle({
    Title = "上帝模式",
    Value = false,
    FeatureName = "GodMode",
    Icon = "shield",
    ConfigKey = "god_mode",
    Callback = function(state)
        godModeEnabled = state
        local c = LP.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            if state then
                hum.MaxHealth = 1e9
                hum.Health = 1e9
                hum.WalkSpeed = math.max(hum.WalkSpeed, 60)
            else
                hum.MaxHealth = 100
                hum.Health = math.min(hum.Health, 100)
            end
        end
    end
})

RS.Heartbeat:Connect(function()
    if godModeEnabled then
        local c = LP.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.Health = hum.MaxHealth end) end
        end
    end
end)

PlayerCat:Button({
    Text = "无限子弹",
    Icon = "loader",
    Tooltip = "将弹药设为9999",
    Callback = function()
        local c = LP.Character
        local t = c and c:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChildOfClass("Tool")
        if t then
            for _, v in pairs(t:GetDescendants()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    if v.Name:find("Ammo") or v.Name:find("Ammunition") or v.Name:find("Bullet") or v.Name:find("Mag") then
                        pcall(function() v.Value = 9999 end)
                    end
                end
            end
            WasUIPro:Notify({ Title = "子弹", Content = "弹药已设为9999", Duration = 2 })
        else
            WasUIPro:Notify({ Title = "提示", Content = "未找到武器", Duration = 2 })
        end
    end
})

PlayerCat:Button({
    Text = "无限货币",
    Icon = "coins",
    Tooltip = "将leaderstats货币设为最大值",
    Callback = function()
        local stats = LP:FindFirstChild("leaderstats")
        if stats then
            for _, v in pairs(stats:GetDescendants()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    pcall(function() v.Value = 1e9 end)
                end
            end
            WasUIPro:Notify({ Title = "货币", Content = "货币已设为最大值", Duration = 2 })
        else
            WasUIPro:Notify({ Title = "提示", Content = "未找到leaderstats", Duration = 2 })
        end
    end
})

PlayerCat:Button({
    Text = "获取管理员",
    Icon = "crown",
    Tooltip = "尝试提升权限",
    Callback = function()
        for _, rs in pairs({game:GetService("ReplicatedStorage"), game:GetService("ServerScriptService")}) do
            for _, v in pairs(rs:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:find("Admin") or v.Name:find("Rank") or v.Name:find("Permission")) then
                    pcall(function() v:FireServer("SetRank", LP, 255) end)
                    pcall(function() v:FireServer(LP, 255) end)
                    pcall(function() v:FireServer("Promote", LP) end)
                end
            end
        end
        WasUIPro:Notify({ Title = "管理员", Content = "已尝试获取管理员", Duration = 2 })
    end
})

print("✅ 视觉+玩家页加载完成")

-- ========== 工具 Tab ==========
local ToolTab = mainWindow:Tab({ Title = "🛠️ 工具" })
local ToolCat = ToolTab:Category({ Title = "工具集", IconName = "wrench" })

ToolCat:Button({
    Text = "生成工具箱(15个)",
    Icon = "briefcase",
    Tooltip = "生成15个管理工具",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local tools = {"AdminTool","BanHammer","KickTool","TPTool","FreezeTool","KillTool","FlyTool","SpeedTool","InvisibleTool","GodTool","CopyTool","RemoveTool","RespawnTool","FFTool","ControlTool"}
        for _, tn in ipairs(tools) do
            local t = Instance.new("Tool")
            t.Name = tn
            t.RequiresHandle = false
            t.CanBeDropped = false
            t.Parent = LP.Backpack
            t.Parent = c
        end
        WasUIPro:Notify({ Title = "工具箱", Content = "15个工具已生成", Duration = 2 })
    end
})

ToolCat:Button({
    Text = "钻石皮肤",
    Icon = "gem",
    Tooltip = "身体变为钻石材质",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.Material = Enum.Material.DiamondPlate
                    v.Color = Color3.fromRGB(255, 215, 0)
                end)
            end
        end
        WasUIPro:Notify({ Title = "皮肤", Content = "钻石皮肤已应用", Duration = 2 })
    end
})

ToolCat:Button({
    Text = "火焰效果",
    Icon = "flame",
    Tooltip = "身体燃烧火焰",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    local f = Instance.new("Fire", v)
                    f.Size = 5
                    f.Heat = 10
                end)
            end
        end
        WasUIPro:Notify({ Title = "火焰", Content = "火焰效果已附加", Duration = 2 })
    end
})

ToolCat:Button({
    Text = "生成至尊神器",
    Icon = "sword",
    Tooltip = "生成一把钻石神剑",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local t = Instance.new("Tool")
        t.Name = "🔥 至尊神器"
        t.RequiresHandle = false
        t.CanBeDropped = false
        local d = Instance.new("Part", t)
        d.Name = "Handle"
        d.Size = Vector3.new(1, 1, 1)
        d.BrickColor = BrickColor.new("Bright yellow")
        d.Material = Enum.Material.DiamondPlate
        t.Parent = LP.Backpack
        t.Parent = c
        WasUIPro:Notify({ Title = "神器", Content = "至尊神器已生成", Duration = 2 })
    end
})

ToolCat:Button({
    Text = "水上行走",
    Icon = "waves",
    Tooltip = "在水面行走",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                v:GetPropertyChangedSignal("Position"):Connect(function()
                    if v.Position.Y < 0.5 then
                        pcall(function() v.CFrame = CFrame.new(v.Position.X, 0.5, v.Position.Z) end)
                    end
                end)
            end
        end
        WasUIPro:Notify({ Title = "水上行走", Content = "已开启", Duration = 2 })
    end
})

ToolCat:Button({
    Text = "随机传送",
    Icon = "map-pin",
    Tooltip = "传送到随机位置",
    Callback = function()
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            c.HumanoidRootPart.CFrame = CFrame.new(math.random(-500, 500), math.random(10, 100), math.random(-500, 500))
            WasUIPro:Notify({ Title = "传送", Content = "已随机传送", Duration = 2 })
        end
    end
})

ToolCat:Button({
    Text = "护盾",
    Icon = "shield",
    Tooltip = "添加力场护盾",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        pcall(function()
            local f = Instance.new("ForceField", c)
            f.Visible = true
        end)
        WasUIPro:Notify({ Title = "护盾", Content = "力场护盾已添加", Duration = 2 })
    end
})

ToolCat:Button({
    Text = "传送功能 (T存/Y回/G瞬移)",
    Icon = "send",
    Tooltip = "T记录位置，Y传送回去，G瞬移到鼠标位置",
    Callback = function()
        local savedPos = nil
        local m = LP:GetMouse()
        m.KeyDown:Connect(function(k)
            if k == "t" then
                local c = LP.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    savedPos = c.HumanoidRootPart.Position
                    WasUIPro:Notify({ Title = "传送", Content = "位置已记录", Duration = 1 })
                end
            elseif k == "y" then
                if savedPos and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
                    WasUIPro:Notify({ Title = "传送", Content = "已传送回记录点", Duration = 1 })
                end
            elseif k == "g" then
                if m.Hit and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character.HumanoidRootPart.CFrame = CFrame.new(m.Hit.p + Vector3.new(0, 3, 0))
                    WasUIPro:Notify({ Title = "传送", Content = "已瞬移", Duration = 1 })
                end
            end
        end)
        WasUIPro:Notify({ Title = "传送", Content = "传送功能已启用", Duration = 2 })
    end
})

-- ========== 脚本 Tab ==========
local ScriptTab = mainWindow:Tab({ Title = "📜 脚本" })
local ScriptCat = ScriptTab:Category({ Title = "快捷脚本", IconName = "code" })

ScriptCat:Button({
    Text = "Infinite Yield",
    Icon = "infinity",
    Tooltip = "加载Infinite Yield管理脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

ScriptCat:Button({
    Text = "Dex Explorer",
    Icon = "folder-tree",
    Tooltip = "加载Dex资源管理器",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/InfinityTheVoid/Dex-V4/master/Dex.lua"))()
    end
})

ScriptCat:Button({
    Text = "反作弊绕过",
    Icon = "shield-off",
    Tooltip = "禁用反作弊脚本",
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then pcall(function() v.Disabled = true end) end
        end
        for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
            if v:IsA("Script") and (v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect")) then
                pcall(function() v.Disabled = true end)
            end
        end
        WasUIPro:Notify({ Title = "反作弊", Content = "反作弊已绕过", Duration = 2 })
    end
})

ScriptCat:Button({
    Text = "重新加入服务器",
    Icon = "refresh-cw",
    Tooltip = "重连当前服务器",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end
})

ScriptCat:Button({
    Text = "离开服务器",
    Icon = "log-out",
    Tooltip = "退出游戏",
    Callback = function()
        game:Shutdown()
    end
})

print("✅ 工具+脚本页加载完成")

-- ========== AI生成 Tab ==========
local AITab = mainWindow:Tab({ Title = "🤖 AI生成" })
local AICat = AITab:Category({ Title = "AI脚本生成器", IconName = "brain" })

local aiMode = "普通"
local aiProvider = "离线模板"
local apiKey = ""
local descText = ""

AICat:Paragraph({
    Title = "AI 脚本生成器",
    Desc = "输入功能描述，AI生成并执行Roblox脚本。可离线匹配模板或填API Key联网生成。",
    Icon = "brain"
})

AICat:Dropdown({
    Title = "AI模式",
    Values = {"普通", "中等", "暴力", "至尊"},
    Value = "普通",
    ConfigKey = "ai_mode",
    Callback = function(v) aiMode = v end
})

AICat:Dropdown({
    Title = "AI提供商",
    Values = {"离线模板", "DeepSeek"},
    Value = "离线模板",
    ConfigKey = "ai_provider",
    Callback = function(v) aiProvider = v end
})

AICat:TextInput({
    Title = "API Key (联网模式)",
    Placeholder = "sk-...",
    Value = "",
    ConfigKey = "api_key",
    Callback = function(text) apiKey = text end
})

AICat:TextInput({
    Title = "描述脚本功能",
    Placeholder = "如: 飞行、自瞄、无限金币、透视...",
    Value = "",
    ConfigKey = "ai_desc",
    Callback = function(text) descText = text end
})

AICat:Button({
    Text = "🤖 生成并执行",
    Icon = "sparkles",
    Tooltip = "根据描述生成脚本",
    Callback = function()
        local desc = descText
        if not desc or desc == "" then
            WasUIPro:Notify({ Title = "提示", Content = "请先输入功能描述", Duration = 2 })
            return
        end
        local mode = aiMode or "普通"
        local provider = aiProvider or "离线模板"
        local apikey = apiKey or ""

        local prompts = {
            ["普通"] = "生成一个简单的Roblox Lua脚本，功能: ",
            ["中等"] = "生成一个完整的Roblox Lua脚本，包含功能: ",
            ["暴力"] = "生成高级Roblox Lua脚本，FE兼容防检测，功能: ",
            ["至尊"] = "生成至尊级Roblox Lua脚本，完整UI全功能，功能: ",
        }
        local prompt = (prompts[mode] or prompts["普通"]) .. desc

        if provider == "离线模板" or apikey == "" then
            local lib = {
                ["飞行"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua'))()",
                ["穿墙"] = "local c=game:GetService('Players').LocalPlayer.Character;game:GetService('RunService').Stepped:Connect(function()for _,v in pairs(c:GetDescendants())do if v:IsA('BasePart')and v.Name~='HumanoidRootPart'then v.CanCollide=false end end end)",
                ["自瞄"] = "local LP=game:GetService('Players').LocalPlayer;game:GetService('RunService').RenderStepped:Connect(function()local t,d=nil,math.huge;for _,v in pairs(game:GetService('Players'):GetPlayers())do if v~=LP and v.Character and v.Character:FindFirstChild('Head')and LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')then local dd=(v.Character.Head.Position-LP.Character.HumanoidRootPart.Position).Magnitude;if dd<d then d=dd;t=v end end end;if t and t.Character and t.Character:FindFirstChild('Head')then workspace.CurrentCamera.CFrame=CFrame.lookAt(workspace.CurrentCamera.CFrame.Position,t.Character.Head.Position)end end)",
                ["无限子弹"] = "local c=game:GetService('Players').LocalPlayer.Character;local t=c:FindFirstChildOfClass('Tool')or game:GetService('Players').LocalPlayer.Backpack:FindFirstChildOfClass('Tool');if t then for _,v in pairs(t:GetDescendants())do if v:IsA('IntValue')or v:IsA('NumberValue')then if v.Name:find('Ammo')or v.Name:find('Bullet')or v.Name:find('Mag')then v.Value=9999 end end end end",
                ["上帝模式"] = "local c=game:GetService('Players').LocalPlayer.Character;local h=c:FindFirstChildOfClass('Humanoid');if h then h.MaxHealth=1e9;h.Health=1e9;h.WalkSpeed=200;h.JumpPower=200;for _,v in pairs(c:GetDescendants())do if v:IsA('BasePart')then v.Material=Enum.Material.DiamondPlate end end end",
                ["夜视"] = "game:GetService('Lighting').Ambient=Color3.new(1,1,1);game:GetService('Lighting').OutdoorAmbient=Color3.new(1,1,1)",
                ["全亮"] = "game:GetService('Lighting').Brightness=2;game:GetService('Lighting').Ambient=Color3.fromRGB(255,255,255);game:GetService('Lighting').FogEnd=1e5;game:GetService('Lighting').ClockTime=12",
                ["无限体力"] = "local h=game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid');if h then h:SetAttribute('Stamina',1e9);spawn(function()while wait(1)do pcall(function()h:SetAttribute('Stamina',1e9)end)end end)end",
                ["传送"] = "local m=game:GetService('Players').LocalPlayer:GetMouse();local s;m.KeyDown:Connect(function(k)if k=='t'then local c=game:GetService('Players').LocalPlayer.Character;if c and c:FindFirstChild('HumanoidRootPart')then s=c.HumanoidRootPart.Position end elseif k=='y'then if s then game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(s)end elseif k=='g'then if m.Hit then game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(m.Hit.p+Vector3.new(0,3,0))end end end)",
                ["管理员"] = "for _,rs in pairs({game:GetService('ReplicatedStorage'),game:GetService('ServerScriptService')})do for _,v in pairs(rs:GetDescendants())do if v:IsA('RemoteEvent')and(v.Name:find('Admin')or v.Name:find('Rank'))then v:FireServer('SetRank',game:GetService('Players').LocalPlayer,255)end end end",
                ["无限货币"] = "local d=game:GetService('Players').LocalPlayer:FindFirstChild('leaderstats')or game:GetService('Players').LocalPlayer:FindFirstChildOfClass('Folder');if d then for _,v in pairs(d:GetDescendants())do if v:IsA('NumberValue')or v:IsA('IntValue')then v.Value=1e9 end end end",
                ["杀戮光环"] = "local p=game:GetService('Players').LocalPlayer;local k=false;game:GetService('UserInputService').InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.X then k=not k end end);game:GetService('RunService').Heartbeat:Connect(function()if k then for _,v in pairs(game:GetService('Players'):GetPlayers())do if v~=p and v.Character and v.Character:FindFirstChild('HumanoidRootPart')and p.Character and p.Character:FindFirstChild('HumanoidRootPart')then local d=(v.Character.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude;if d<=30 then pcall(function()v.Character:FindFirstChildOfClass('Humanoid'):TakeDamage(25)end)end end end end end)",
                ["ESP"] = "local e=false;local o={};game:GetService('UserInputService').InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.F then e=not e;if e then for _,v in pairs(game:GetService('Players'):GetPlayers())do if v~=game:GetService('Players').LocalPlayer then local h=Instance.new('Highlight');h.Adornee=v.Character;h.FillColor=Color3.fromRGB(255,50,50);h.FillTransparency=0.5;h.Parent=game:GetService('CoreGui');table.insert(o,h)end end else for _,v in pairs(o)do pcall(function()v:Destroy()end)end;o={}end end end)",
            }
            local code = nil
            for kw, c in pairs(lib) do
                if desc:find(kw) then code = c; break end
            end
            if not code then code = "print('❌ 未匹配到离线模板，请填写API Key联网生成')" end
            local f, err = loadstring(code)
            if f then pcall(f) end
            return
        end

        -- 联网模式: DeepSeek Tool Calls
        local tools = {
            {
                type = "function",
                ["function"] = {
                    name = "execute_lua",
                    description = "在Roblox中执行Lua脚本代码",
                    parameters = {
                        type = "object",
                        properties = {
                            code = { type = "string", description = "要执行的完整Lua代码，必须可独立运行" }
                        },
                        required = {"code"}
                    }
                }
            }
        }

        local success, result = pcall(function()
            local body = H:JSONEncode({
                model = "deepseek-chat",
                messages = {
                    { role = "system", content = "你是一个Roblox Lua脚本生成器。请使用execute_lua工具返回可执行的Lua代码，代码必须完整、可独立运行。" },
                    { role = "user", content = prompt }
                },
                tools = tools,
                tool_choice = "auto",
                temperature = 0.3,
                max_tokens = 2000
            })
            local response = H:PostAsync("https://api.deepseek.com/chat/completions", {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. apikey
            }, body)
            local data = H:JSONDecode(response)
            if data and data.choices and data.choices[1] then
                local msg = data.choices[1].message
                if msg.tool_calls and #msg.tool_calls > 0 then
                    local tc = msg.tool_calls[1]
                    if tc["function"] and tc["function"].arguments then
                        local args = H:JSONDecode(tc["function"].arguments)
                        if args and args.code then return args.code end
                    end
                end
                if msg.content and msg.content ~= "" then return msg.content end
            end
            return nil
        end)

        if success and result then
            local f, err = loadstring(result)
            if f then
                pcall(f)
                WasUIPro:Notify({ Title = "AI", Content = "脚本已生成并执行", Duration = 2 })
            else
                WasUIPro:Notify({ Title = "AI", Content = "代码编译失败: " .. tostring(err), Duration = 3 })
            end
        else
            WasUIPro:Notify({ Title = "AI", Content = "API调用失败，请检查Key", Duration = 3 })
        end
    end
})

-- 完成
WasUIPro:Notify({ Title = "✅ Delta 至尊版 v6.0", Content = "全部加载完成!", Duration = 5 })
print("✅ Delta 至尊版 v6.0 加载完成!")