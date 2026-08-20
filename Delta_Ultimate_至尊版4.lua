--[[ 👑 Delta Ultimate 至尊版 v5.0 ]]
-- 使用 WindUI 库
local uik = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
local wj = "Delta至尊"
local xb = "https://raw.githubusercontent.com/ylt410/Liquid-glass-script/refs/heads/main/A19A17E7-7AF5-4E1D-998B-DA69A7C0CD77.png"
local bj = 'https://raw.githubusercontent.com/ylt410/Liquid-glass-script/refs/heads/main/E7B068E4-0859-420F-A6B1-AF519C804C39.png'

local A = game:GetService("RunService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = game:GetService("Players").LocalPlayer
local L = game:GetService("Lighting")

local F = loadstring(game:HttpGet(uik))()

local Window = F:CreateWindow({
    Title = "<font color='#FFD700'>👑 Delta</font> 至尊版 v5.0",
    Folder = wj,
    Icon = xb,
    IconThemed = false,
    IconSize = 10*2,
    Background = bj,
    Theme = "Dark",
    NewElements = true,
    Size = UDim2.fromOffset(550,450),
    HideSearchBar = false,
    OpenButton = {
        Title = "👑 Delta 至尊版",
        Icon = "https://raw.githubusercontent.com/ParKe001/ParKe/refs/heads/main/picture/SEtm.png",
        CornerRadius = UDim.new(0.3,0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = true,
        Scale = 1,
        Color = ColorSequence.new(Color3.fromHex("#1c1c1c"), Color3.fromHex("#FFD700"))
    },
})

-- 通用Tab
local MainTab = Window:Tab({
    Title = "通用",
    Icon = "crown",
})

MainTab:Slider({
    Title = "移动速度",
    Value = {Min = 16, Max = 200, Default = 16},
    Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end
})

MainTab:Slider({
    Title = "跳跃高度",
    Value = {Min = 1, Max = 200, Default = 50},
    Callback = function(v) LP.Character.Humanoid.JumpPower = v end
})

MainTab:Slider({
    Title = "视野范围",
    Value = {Min = 10, Max = 120, Default = 70},
    Callback = function(v) workspace.CurrentCamera.FieldOfView = v end
})

MainTab:Toggle({
    Title = "飞行",
    Value = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
    end
})

MainTab:Toggle({
    Title = "穿墙",
    Value = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TtmScripter/OtherScript/main/Noclip"))()
    end
})

MainTab:Toggle({
    Title = "夜视",
    Value = false,
    Callback = function(v)
        if v then L.Ambient = Color3.new(1,1,1) else L.Ambient = Color3.new(0,0,0) end
    end
})

MainTab:Toggle({
    Title = "帧率显示",
    Value = false,
    Callback = function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "FPSGui"; sg.ResetOnSpawn = false; sg.Parent = LP:WaitForChild("PlayerGui")
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0,100,0,50); lb.Position = UDim2.new(0,10,0,10)
        lb.BackgroundTransparency = 1; lb.Font = Enum.Font.SourceSansBold
        lb.Text = "FPS: 0"; lb.TextSize = 20; lb.TextColor3 = Color3.new(1,1,1)
        lb.Parent = sg
        RS.RenderStepped:Connect(function()
            lb.Text = "FPS: " .. math.floor(1/RS.RenderStepped:Wait())
        end)
    end
})

-- 战斗Tab
local CombatTab = Window:Tab({
    Title = "战斗",
    Icon = "sword",
})

CombatTab:Toggle({
    Title = "子弹追踪",
    Value = false,
    Callback = function()
        local Camera = workspace.CurrentCamera
        local Players = game:GetService("Players")
        local function GetClosest()
            local closest = nil; local dist = math.huge
            for _,v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; closest = v end
                end
            end
            return closest
        end
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
    end
})

CombatTab:Toggle({
    Title = "自瞄",
    Value = false,
    Callback = function()
        local a = false
        UIS.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.C then a = not a end
        end)
        RS.RenderStepped:Connect(function()
            if a then
                local target = nil; local dist = math.huge
                for _,v in pairs(game:GetService("Players"):GetPlayers()) do
                    if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (v.Character.Head.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then dist = d; target = v end
                    end
                end
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    LP:GetMouse().Hit = target.Character.Head.CFrame
                end
            end
        end)
    end
})

CombatTab:Toggle({
    Title = "杀戮光环",
    Value = false,
    Callback = function()
        local k = false
        UIS.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.X then k = not k end
        end)
        RS.Heartbeat:Connect(function()
            if k then
                for _,v in pairs(game:GetService("Players"):GetPlayers()) do
                    if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                        if d <= 30 then pcall(function() v.Character:FindFirstChildOfClass("Humanoid"):TakeDamage(10) end) end
                    end
                end
            end
        end)
    end
})

CombatTab:Toggle({
    Title = "全屏冻结",
    Value = false,
    Callback = function()
        for _,v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= LP and v.Character then
                pcall(function() v.Character.HumanoidRootPart.Anchored = true end)
            end
        end
    end
})

CombatTab:Toggle({
    Title = "强制踢出",
    Value = false,
    Callback = function()
        for _,v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= LP then pcall(function() v:Kick("至尊管理员踢出") end) end
        end
    end
})

-- 视觉Tab
local VisualTab = Window:Tab({
    Title = "视觉",
    Icon = "eye",
})

VisualTab:Toggle({
    Title = "ESP透视",
    Value = false,
    Callback = function()
        local e = false; local o = {}
        UIS.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.F then
                e = not e
                if e then
                    for _,v in pairs(game:GetService("Players"):GetPlayers()) do
                        if v ~= LP then
                            local h = Instance.new("Highlight")
                            h.Adornee = v.Character; h.FillColor = Color3.fromRGB(255,50,50)
                            h.FillTransparency = 0.5; h.Parent = game:GetService("CoreGui")
                            table.insert(o, h)
                        end
                    end
                else
                    for _,v in pairs(o) do pcall(function() v:Destroy() end) end
                    o = {}
                end
            end
        end)
    end
})

VisualTab:Toggle({
    Title = "全亮模式",
    Value = false,
    Callback = function()
        L.Brightness = 2; L.Ambient = Color3.fromRGB(255,255,255)
        L.OutdoorAmbient = Color3.fromRGB(255,255,255); L.FogEnd = 1e5; L.ClockTime = 12
    end
})

VisualTab:Toggle({
    Title = "透视物品",
    Value = false,
    Callback = function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Tool") or (v:IsA("Part") and (v.Name:find("Chest") or v.Name:find("Item") or v.Name:find("Loot"))) then
                local h = Instance.new("Highlight")
                h.Adornee = v; h.FillColor = Color3.fromRGB(255,200,0)
                h.FillTransparency = 0.3; h.Parent = game:GetService("CoreGui")
            end
        end
    end
})

VisualTab:Toggle({
    Title = "夜视",
    Value = false,
    Callback = function(v)
        if v then L.Ambient = Color3.new(1,1,1) else L.Ambient = Color3.new(0,0,0) end
    end
})

-- 玩家Tab
local PlayerTab = Window:Tab({
    Title = "玩家",
    Icon = "user",
})

PlayerTab:Toggle({
    Title = "拉取所有玩家",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then
            for _,v in pairs(game:GetService("Players"):GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.CFrame = r.CFrame + Vector3.new(0,5,0)
                end
            end
        end
    end
})

PlayerTab:Toggle({
    Title = "隐身",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 1; v.CanCollide = false end
        end
    end
})

PlayerTab:Toggle({
    Title = "无限体力",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h:SetAttribute("Stamina", 1e9)
            spawn(function() while wait(1) do pcall(function() h:SetAttribute("Stamina", 1e9) end) end end)
        end
    end
})

PlayerTab:Toggle({
    Title = "无限子弹",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local t = c:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChildOfClass("Tool")
        if t and t:FindFirstChild("Ammo") then t.Ammo.Value = 9999
        else for _,v in pairs(c:GetDescendants()) do if v.Name:find("Ammo") or v.Name:find("Bullet") then pcall(function() v.Value = 9999 end) end end end
    end
})

PlayerTab:Toggle({
    Title = "上帝模式",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.MaxHealth = 1e9; h.Health = 1e9; h.WalkSpeed = 200; h.JumpPower = 200
            for _,v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.DiamondPlate; v.Color = Color3.fromRGB(255,215,0) end
            end
        end
    end
})

PlayerTab:Toggle({
    Title = "获取管理员",
    Value = false,
    Callback = function()
        for _,rs in pairs({game:GetService("ReplicatedStorage"), game:GetService("ServerScriptService")}) do
            for _,v in pairs(rs:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:find("Admin") or v.Name:find("Rank")) then
                    v:FireServer("SetRank", LP, 255)
                end
            end
        end
    end
})

PlayerTab:Toggle({
    Title = "无限货币",
    Value = false,
    Callback = function()
        local d = LP:FindFirstChild("leaderstats") or LP:FindFirstChildOfClass("Folder")
        if d then
            for _,v in pairs(d:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then pcall(function() v.Value = 1e9 end) end
            end
        end
    end
})

PlayerTab:Toggle({
    Title = "传送功能",
    Value = false,
    Callback = function()
        local m = LP:GetMouse(); local s
        m.KeyDown:Connect(function(k)
            if k == "t" then
                local c = LP.Character
                if c and c:FindFirstChild("HumanoidRootPart") then s = c.HumanoidRootPart.Position end
            elseif k == "y" then
                if s then LP.Character.HumanoidRootPart.CFrame = CFrame.new(s) end
            elseif k == "g" then
                if m.Hit then LP.Character.HumanoidRootPart.CFrame = CFrame.new(m.Hit.p + Vector3.new(0,3,0)) end
            end
        end)
    end
})

-- 工具Tab
local ToolTab = Window:Tab({
    Title = "工具",
    Icon = "tool",
})

ToolTab:Toggle({
    Title = "工具箱(15个工具)",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local b = LP.Backpack
        local tools = {"AdminTool","BanHammer","KickTool","TPTool","FreezeTool","KillTool","FlyTool","SpeedTool","InvisibleTool","GodTool","CopyTool","RemoveTool","RespawnTool","FFTool","ControlTool"}
        for _,tn in ipairs(tools) do
            local t = Instance.new("Tool"); t.Name = tn; t.RequiresHandle = false; t.CanBeDropped = false
            t.Parent = b; t.Parent = c
        end
    end
})

ToolTab:Toggle({
    Title = "钻石皮肤",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.DiamondPlate; v.Color = Color3.fromRGB(255,215,0) end
        end
    end
})

ToolTab:Toggle({
    Title = "火焰效果",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then local f = Instance.new("Fire",v); f.Size = 5; f.Heat = 10 end
        end
    end
})

ToolTab:Toggle({
    Title = "生成至尊神器",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local t = Instance.new("Tool"); t.Name = "🔥 至尊神器"; t.RequiresHandle = false; t.CanBeDropped = false
        local d = Instance.new("Part",t); d.Name = "Handle"; d.Size = Vector3.new(1,1,1)
        d.BrickColor = BrickColor.new("Bright yellow"); d.Material = Enum.Material.DiamondPlate
        t.Parent = LP.Backpack; t.Parent = c
    end
})

ToolTab:Toggle({
    Title = "水上行走",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                v:GetPropertyChangedSignal("Position"):Connect(function()
                    if v.Position.Y < 0 then v.CFrame = CFrame.new(v.Position.X, 0, v.Position.Z) end
                end)
            end
        end
    end
})

ToolTab:Toggle({
    Title = "随机传送",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = CFrame.new(math.random(-500,500), math.random(10,100), math.random(-500,500)) end
    end
})

ToolTab:Toggle({
    Title = "护盾",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then local f = Instance.new("ForceField",c); f.Visible = true end
    end
})

-- 脚本Tab
local ScriptTab = Window:Tab({
    Title = "脚本",
    Icon = "code",
})

ScriptTab:Toggle({
    Title = "Infinite Yield",
    Value = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

ScriptTab:Toggle({
    Title = "Dex Explorer",
    Value = false,
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/InfinityTheVoid/Dex-V4/master/Dex.lua"))()
    end
})

ScriptTab:Toggle({
    Title = "反作弊绕过",
    Value = false,
    Callback = function()
        local c = LP.Character or LP.CharacterAdded:Wait()
        for _,v in pairs(c:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then v.Disabled = true end
        end
        for _,v in pairs(game:GetService("CoreGui"):GetDescendants()) do
            if v:IsA("Script") and (v.Name:find("Anti") or v.Name:find("Cheat") or v.Name:find("Detect")) then v.Disabled = true end
        end
    end
})

ScriptTab:Toggle({
    Title = "重新加入",
    Value = false,
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end
})

ScriptTab:Toggle({
    Title = "离开服务器",
    Value = false,
    Callback = function()
        game:Shutdown()
    end
})

-- AI Tab
local AITab = Window:Tab({
    Title = "AI生成",
    Icon = "star",
})

local aiMode = "普通"
local aiProvider = "DeepSeek"
local apiKey = ""
local descInput = ""

AITab:Dropdown({
    Title = "AI模式",
    Values = {"普通", "中等", "暴力", "至尊"},
    Value = "普通",
    Callback = function(v) aiMode = v end
})

AITab:Dropdown({
    Title = "AI提供商",
    Values = {"OpenAI", "Claude", "Groq", "通义千问", "月之暗面", "智谱", "商汤", "DeepSeek", "Gemini", "Copilot"},
    Value = "DeepSeek",
    Callback = function(v) aiProvider = v end
})

AITab:Input({
    Title = "API Key",
    Value = "",
    Callback = function(v) apiKey = v end
})

AITab:Input({
    Title = "描述脚本功能",
    Value = "",
    Callback = function(v) descInput = v end
})

AITab:Button({
    Title = "🤖 生成脚本",
    Callback = function()
        local desc = descInput or ""
        if desc == "" then return end
        local mode = aiMode or "普通"
        local provider = aiProvider or "DeepSeek"
        local apikey = apiKey or ""
        
        -- 根据模式生成提示词
        local prompts = {
            ["普通"] = "生成一个简单的Roblox Lua脚本，功能: ",
            ["中等"] = "生成一个完整的Roblox Lua脚本，包含功能: ",
            ["暴力"] = "生成一个高级Roblox Lua脚本，包含FE兼容、防检测、完整功能: ",
            ["至尊"] = "生成一个至尊级Roblox Lua脚本，包含FE兼容、反检测、完整UI、全部功能: ",
        }
        local prompt = (prompts[mode] or prompts["普通"]) .. desc
        
        -- 如果是离线模式，直接返回模板
        if apikey == "" then
            local code = "-- " .. mode .. "模式: " .. desc .. "\n"
            code = code .. "local LP = game:GetService('Players').LocalPlayer\n"
            code = code .. "local function main()\n"
            code = code .. "    print('✅ " .. mode .. "模式已执行: " .. desc .. "')\n"
            code = code .. "end\n"
            code = code .. "pcall(main)\n"
            return code
        end
        
        -- 联网生成（简化版）
        local code = "-- " .. mode .. "模式: " .. desc .. "\nprint('✅ 已生成')"
        -- 可以在这里添加API调用
        
        -- 显示结果
        return code
    end
})

-- 完成
print("✅ Delta 至尊版 v5.0 加载完成!")