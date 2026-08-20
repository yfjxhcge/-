--[[ 👑 Delta Ultimate 至尊版 v5.0 ]]
-- LinoriaLib UI 库 (专业长UI)
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = '👑 Delta 至尊版 v5.0',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local LP  = game:GetService('Players').LocalPlayer
local RS = game:GetService('RunService')
local UIS = game:GetService('UserInputService')
local L = game:GetService('Lighting')
local H = game:GetService('HttpService')

-- ====== 通用 Tab ======
local MainTab = Window:AddTab('通用')
local MainG = MainTab:AddLeftGroupbox('移动')
MainG:AddSlider('WalkSpeed', {
    Text = '移动速度', Default = 16, Min = 16, Max = 200, Rounding = 1,
    Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end
})
MainG:AddSlider('JumpPower', {
    Text = '跳跃高度', Default = 50, Min = 1, Max = 200, Rounding = 1,
    Callback = function(v) LP.Character.Humanoid.JumpPower = v end
})
MainG:AddSlider('FOV', {
    Text = '视野范围', Default = 70, Min = 10, Max = 120, Rounding = 1,
    Callback = function(v) workspace.CurrentCamera.FieldOfView = v end
})

local MainG2 = MainTab:AddLeftGroupbox('开关')
MainG2:AddToggle('Fly', { Text = '飞行', Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua'))() end })
MainG2:AddToggle('Noclip', { Text = '穿墙', Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/TtmScripter/OtherScript/main/Noclip'))() end })
MainG2:AddToggle('NightVision', { Text = '夜视', Callback = function(v) L.Ambient = v and Color3.new(1,1,1) or Color3.new(0,0,0) end })
MainG2:AddToggle('FPSDisplay', { Text = 'FPS显示', Callback = function()
    local sg = Instance.new('ScreenGui'); sg.Name = 'FPSGui'; sg.ResetOnSpawn = false; sg.Parent = LP:WaitForChild('PlayerGui')
    local lb = Instance.new('TextLabel'); lb.Size = UDim2.new(0,100,0,50); lb.Position = UDim2.new(0,10,0,10)
    lb.BackgroundTransparency = 1; lb.Font = Enum.Font.SourceSansBold; lb.Text = 'FPS: 0'; lb.TextSize = 20; lb.TextColor3 = Color3.new(1,1,1); lb.Parent = sg
    RS.RenderStepped:Connect(function() lb.Text = 'FPS: ' .. math.floor(1/RS.RenderStepped:Wait()) end)
end })

-- ====== 战斗 Tab ======
local CombatTab = Window:AddTab('战斗')
local CombatG = CombatTab:AddLeftGroupbox('攻击')
CombatG:AddToggle('Aimbot', { Text = '子弹追踪', Callback = function()
    local Camera = workspace.CurrentCamera; local Players = game:GetService('Players')
    local function GetClosest()
        local closest, dist = nil, math.huge
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild('HumanoidRootPart') then
                local d = (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end return closest
    end
    local mt = getrawmetatable(game); local old = mt.__namecall; setreadonly(mt, false)
    mt.__namecall = newcclosure(function(obj, ...)
        local method = getnamecallmethod(); local args = {...}
        if tostring(method) == 'FindPartOnRayWithIgnoreList' then
            local target = GetClosest()
            if target and target.Character then args[1] = Ray.new(Camera.CFrame.Position, (target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000) end
        end return old(obj, unpack(args))
    end); setreadonly(mt, true)
end })
CombatG:AddToggle('SilentAim', { Text = '自瞄(C键)', Callback = function()
    local a = false; UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.C then a = not a end end)
    RS.RenderStepped:Connect(function()
        if a then
            local target, dist = nil, math.huge
            for _,v in pairs(game:GetService('Players'):GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild('Head') and LP.Character and LP.Character:FindFirstChild('HumanoidRootPart') then
                    local d = (v.Character.Head.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; target = v end
                end
            end
            if target and target.Character and target.Character:FindFirstChild('Head') then LP:GetMouse().Hit = target.Character.Head.CFrame end
        end
    end)
end })
CombatG:AddToggle('KillAura', { Text = '杀戮光环(X键)', Callback = function()
    local k = false; UIS.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.X then k = not k end end)
    RS.Heartbeat:Connect(function()
        if k then
            for _,v in pairs(game:GetService('Players'):GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild('HumanoidRootPart') and LP.Character and LP.Character:FindFirstChild('HumanoidRootPart') then
                    local d = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                    if d <= 30 then pcall(function() v.Character:FindFirstChildOfClass('Humanoid'):TakeDamage(10) end) end
                end
            end
        end
    end)
end })

local CombatG2 = CombatTab:AddLeftGroupbox('控制')
CombatG2:AddToggle('FreezeAll', { Text = '全屏冻结', Callback = function()
    for _,v in pairs(game:GetService('Players'):GetPlayers()) do
        if v ~= LP and v.Character then pcall(function() v.Character.HumanoidRootPart.Anchored = true end) end
    end
end })
CombatG2:AddToggle('KickAll', { Text = '强制踢出', Callback = function()
    for _,v in pairs(game:GetService('Players'):GetPlayers()) do if v ~= LP then pcall(function() v:Kick('至尊管理员踢出') end) end end
end })

-- ====== 视觉 Tab ======
local VisualTab = Window:AddTab('视觉')
local VisG = VisualTab:AddLeftGroupbox('视觉效果')
VisG:AddToggle('ESP', { Text = 'ESP透视(F键)', Callback = function()
    local e, o = false, {}; UIS.InputBegan:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.F then
            e = not e
            if e then
                for _,v in pairs(game:GetService('Players'):GetPlayers()) do
                    if v ~= LP then
                        local h = Instance.new('Highlight'); h.Adornee = v.Character; h.FillColor = Color3.fromRGB(255,50,50); h.FillTransparency = 0.5; h.Parent = game:GetService('CoreGui'); table.insert(o, h)
                    end
                end
            else for _,v in pairs(o) do pcall(function() v:Destroy() end) end; o = {} end
        end
    end)
end })
VisG:AddToggle('FullBright', { Text = '全亮模式', Callback = function()
    L.Brightness = 2; L.Ambient = Color3.fromRGB(255,255,255); L.OutdoorAmbient = Color3.fromRGB(255,255,255); L.FogEnd = 1e5; L.ClockTime = 12
end })
VisG:AddToggle('ItemESP', { Text = '透视物品', Callback = function()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA('Tool') or (v:IsA('Part') and (v.Name:find('Chest') or v.Name:find('Item') or v.Name:find('Loot'))) then
            local h = Instance.new('Highlight'); h.Adornee = v; h.FillColor = Color3.fromRGB(255,200,0); h.FillTransparency = 0.3; h.Parent = game:GetService('CoreGui')
        end
    end
end })

-- ====== 玩家 Tab ======
local PlayerTab = Window:AddTab('玩家')
local PG = PlayerTab:AddLeftGroupbox('增强')
PG:AddToggle('PullAll', { Text = '拉取所有玩家', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait(); local r = c:FindFirstChild('HumanoidRootPart')
    if r then for _,v in pairs(game:GetService('Players'):GetPlayers()) do if v ~= LP and v.Character and v.Character:FindFirstChild('HumanoidRootPart') then v.Character.HumanoidRootPart.CFrame = r.CFrame + Vector3.new(0,5,0) end end end
end })
PG:AddToggle('Invisible', { Text = '隐身', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait()
    for _,v in pairs(c:GetDescendants()) do if v:IsA('BasePart') then v.Transparency = 1; v.CanCollide = false end end
end })
PG:AddToggle('InfiniteStamina', { Text = '无限体力', Callback = function()
    local h = LP.Character:FindFirstChildOfClass('Humanoid')
    if h then h:SetAttribute('Stamina', 1e9); spawn(function() while wait(1) do pcall(function() h:SetAttribute('Stamina', 1e9) end) end end) end
end })
PG:AddToggle('InfiniteAmmo', { Text = '无限子弹', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait(); local t = c:FindFirstChildOfClass('Tool') or LP.Backpack:FindFirstChildOfClass('Tool')
    if t and t:FindFirstChild('Ammo') then t.Ammo.Value = 9999 else for _,v in pairs(c:GetDescendants()) do if v.Name:find('Ammo') or v.Name:find('Bullet') then pcall(function() v.Value = 9999 end) end end end
end })

local PG2 = PlayerTab:AddLeftGroupbox('权限')
PG2:AddToggle('GodMode', { Text = '上帝模式', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait(); local h = c:FindFirstChildOfClass('Humanoid')
    if h then h.MaxHealth = 1e9; h.Health = 1e9; h.WalkSpeed = 200; h.JumpPower = 200
        for _,v in pairs(c:GetDescendants()) do if v:IsA('BasePart') then v.Material = Enum.Material.DiamondPlate; v.Color = Color3.fromRGB(255,215,0) end end end
end })
PG2:AddToggle('Admin', { Text = '获取管理员', Callback = function()
    for _,rs in pairs({game:GetService('ReplicatedStorage'), game:GetService('ServerScriptService')}) do
        for _,v in pairs(rs:GetDescendants()) do if v:IsA('RemoteEvent') and (v.Name:find('Admin') or v.Name:find('Rank')) then v:FireServer('SetRank', LP, 255) end end end
end })
PG2:AddToggle('InfiniteMoney', { Text = '无限货币', Callback = function()
    local d = LP:FindFirstChild('leaderstats') or LP:FindFirstChildOfClass('Folder')
    if d then for _,v in pairs(d:GetDescendants()) do if v:IsA('NumberValue') or v:IsA('IntValue') then pcall(function() v.Value = 1e9 end) end end end
end })
PG2:AddToggle('Teleport', { Text = '传送(T/Y/G)', Callback = function()
    local m = LP:GetMouse(); local s
    m.KeyDown:Connect(function(k)
        if k == 't' then local c = LP.Character; if c and c:FindFirstChild('HumanoidRootPart') then s = c.HumanoidRootPart.Position end
        elseif k == 'y' then if s then LP.Character.HumanoidRootPart.CFrame = CFrame.new(s) end
        elseif k == 'g' then if m.Hit then LP.Character.HumanoidRootPart.CFrame = CFrame.new(m.Hit.p + Vector3.new(0,3,0)) end end
    end)
end })

-- ====== 工具 Tab ======
local ToolTab = Window:AddTab('工具')
local TG = ToolTab:AddLeftGroupbox('工具包')
TG:AddToggle('Toolbox', { Text = '工具箱(15个工具)', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait(); local b = LP.Backpack
    local tools = {'AdminTool','BanHammer','KickTool','TPTool','FreezeTool','KillTool','FlyTool','SpeedTool','InvisibleTool','GodTool','CopyTool','RemoveTool','RespawnTool','FFTool','ControlTool'}
    for _,tn in ipairs(tools) do
        local t = Instance.new('Tool'); t.Name = tn; t.RequiresHandle = false; t.CanBeDropped = false; t.Parent = b; t.Parent = c
    end
end })
TG:AddToggle('DiamondSkin', { Text = '钻石皮肤', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait()
    for _,v in pairs(c:GetDescendants()) do if v:IsA('BasePart') then v.Material = Enum.Material.DiamondPlate; v.Color = Color3.fromRGB(255,215,0) end end
end })
TG:AddToggle('FireEffect', { Text = '火焰效果', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait()
    for _,v in pairs(c:GetDescendants()) do if v:IsA('BasePart') then local f = Instance.new('Fire',v); f.Size = 5; f.Heat = 10 end end
end })
TG:AddToggle('GodSword', { Text = '生成至尊神器', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait()
    local t = Instance.new('Tool'); t.Name = '🔥 至尊神器'; t.RequiresHandle = false; t.CanBeDropped = false
    local d = Instance.new('Part',t); d.Name = 'Handle'; d.Size = Vector3.new(1,1,1); d.BrickColor = BrickColor.new('Bright yellow'); d.Material = Enum.Material.DiamondPlate
    t.Parent = LP.Backpack; t.Parent = c
end })
TG:AddToggle('WaterWalk', { Text = '水上行走', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait()
    for _,v in pairs(c:GetDescendants()) do if v:IsA('BasePart') then v:GetPropertyChangedSignal('Position'):Connect(function() if v.Position.Y < 0 then v.CFrame = CFrame.new(v.Position.X, 0, v.Position.Z) end end) end end
end })
TG:AddToggle('RandomTP', { Text = '随机传送', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait(); local r = c:FindFirstChild('HumanoidRootPart')
    if r then r.CFrame = CFrame.new(math.random(-500,500), math.random(10,100), math.random(-500,500)) end
end })
TG:AddToggle('Shield', { Text = '护盾', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait(); local r = c:FindFirstChild('HumanoidRootPart')
    if r then local f = Instance.new('ForceField',c); f.Visible = true end
end })

-- ====== 脚本 Tab ======
local ScriptTab = Window:AddTab('脚本')
local SG = ScriptTab:AddLeftGroupbox('加载')
SG:AddToggle('InfiniteYield', { Text = 'Infinite Yield', Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end })
SG:AddToggle('DexExplorer', { Text = 'Dex Explorer', Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/InfinityTheVoid/Dex-V4/master/Dex.lua'))() end })
SG:AddToggle('AntiCheat', { Text = '反作弊绕过', Callback = function()
    local c = LP.Character or LP.CharacterAdded:Wait()
    for _,v in pairs(c:GetDescendants()) do if v:IsA('Script') or v:IsA('LocalScript') then v.Disabled = true end end
    for _,v in pairs(game:GetService('CoreGui'):GetDescendants()) do if v:IsA('Script') and (v.Name:find('Anti') or v.Name:find('Cheat') or v.Name:find('Detect')) then v.Disabled = true end end
end })

local SG2 = ScriptTab:AddLeftGroupbox('服务器')
SG2:AddToggle('Rejoin', { Text = '重新加入', Callback = function() game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end })
SG2:AddToggle('Leave', { Text = '离开服务器', Callback = function() game:Shutdown() end })

-- ====== AI生成 Tab (Tool Calls方式) ======
local AITab = Window:AddTab('AI生成')
local AIG = AITab:AddLeftGroupbox('AI生成器 (DeepSeek Tool Calls)')
AIG:AddLabel('填写描述后点生成，AI自动返回可执行代码', true)

local aiMode = '普通'
local aiProvider = 'DeepSeek'
local apiKey = ''
local descInput = ''

AIG:AddDropdown('AIMode', {
    Values = {'普通', '中等', '暴力', '至尊'},
    Default = 1, Text = 'AI模式',
    Callback = function(v) aiMode = v end
})
AIG:AddDropdown('AIProvider', {
    Values = {'DeepSeek'},
    Default = 1, Text = '提供商',
    Callback = function(v) aiProvider = v end
})

-- 输入框 - 单独放在Groupbox里，会显示在下面
AIG:AddInput('APIKeyInput', {
    Text = 'API Key', Default = '', Placeholder = '输入DeepSeek API Key',
    Numeric = false, Finished = false,
    Callback = function(v) apiKey = v end
})
AIG:AddInput('DescInput', {
    Text = '描述脚本功能', Default = '', Placeholder = '如:自动打怪、飞行、透视、无限子弹...',
    Numeric = false, Finished = false,
    Callback = function(v) descInput = v end
})

-- 生成按钮
AIG:AddButton({
    Text = '🤖 生成脚本 (Tool Calls)',
    Func = function()
        local desc = descInput or ''
        if desc == '' then return end
        local mode = aiMode or '普通'
        local apikey = apiKey or ''
        
        -- 模式提示词
        local prompts = {
            ['普通'] = '生成一个简单的Roblox Lua脚本，功能: ',
            ['中等'] = '生成一个完整的Roblox Lua脚本，包含功能: ',
            ['暴力'] = '生成一个高级Roblox Lua脚本，FE兼容、防检测、完整功能: ',
            ['至尊'] = '生成一个至尊级Roblox Lua脚本，FE兼容、反检测、完整UI、全部功能: ',
        }
        local prompt = (prompts[mode] or prompts['普通']) .. desc
        
        if apikey == '' then
            -- 离线模式
            local lib = {
                ['飞行'] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua'))()",
                ['穿墙'] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/TtmScripter/OtherScript/main/Noclip'))()",
                ['自瞄'] = "local LP=game:GetService('Players').LocalPlayer;local a=false;local m=LP:GetMouse();game:GetService('RunService').RenderStepped:Connect(function()if a then local t=nil;local d=math.huge;for _,v in pairs(game:GetService('Players'):GetPlayers())do if v~=LP and v.Character and v.Character:FindFirstChild('Head')and LP.Character and LP.Character:FindFirstChild('HumanoidRootPart')then local dd=(v.Character.Head.Position-LP.Character.HumanoidRootPart.Position).Magnitude;if dd<d then d=dd;t=v end end end;if t and t.Character and t.Character:FindFirstChild('Head')then m.Hit=t.Character.Head.CFrame end end end);game:GetService('UserInputService').InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.C then a=not a end end)",
                ['无限子弹'] = "local c=game:GetService('Players').LocalPlayer.Character or game:GetService('Players').LocalPlayer.CharacterAdded:Wait();local t=c:FindFirstChildOfClass('Tool')or game:GetService('Players').LocalPlayer.Backpack:FindFirstChildOfClass('Tool');if t and t:FindFirstChild('Ammo')then t.Ammo.Value=9999 else for _,v in pairs(c:GetDescendants())do if v.Name:find('Ammo')or v.Name:find('Bullet')then pcall(function()v.Value=9999 end)end end end",
                ['上帝模式'] = "local c=game:GetService('Players').LocalPlayer.Character;local h=c:FindFirstChildOfClass('Humanoid');if h then h.MaxHealth=1e9;h.Health=1e9;h.WalkSpeed=200;h.JumpPower=200;for _,v in pairs(c:GetDescendants())do if v:IsA('BasePart')then v.Material=Enum.Material.DiamondPlate;v.Color=Color3.fromRGB(255,215,0)end end end",
                ['夜视'] = "game:GetService('Lighting').Ambient=Color3.new(1,1,1)",
                ['全亮'] = "game:GetService('Lighting').Brightness=2;game:GetService('Lighting').Ambient=Color3.fromRGB(255,255,255);game:GetService('Lighting').FogEnd=1e5;game:GetService('Lighting').ClockTime=12",
                ['无限体力'] = "local h=game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid');if h then h:SetAttribute('Stamina',1e9);spawn(function()while wait(1)do pcall(function()h:SetAttribute('Stamina',1e9)end)end end)end",
                ['传送'] = "local m=game:GetService('Players').LocalPlayer:GetMouse();local s;m.KeyDown:Connect(function(k)if k=='t'then local c=game:GetService('Players').LocalPlayer.Character;if c and c:FindFirstChild('HumanoidRootPart')then s=c.HumanoidRootPart.Position end elseif k=='y'then if s then game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(s)end elseif k=='g'then if m.Hit then game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(m.Hit.p+Vector3.new(0,3,0))end end end)",
                ['管理员'] = "for _,rs in pairs({game:GetService('ReplicatedStorage'),game:GetService('ServerScriptService')})do for _,v in pairs(rs:GetDescendants())do if v:IsA('RemoteEvent')and(v.Name:find('Admin')or v.Name:find('Rank'))then v:FireServer('SetRank',game:GetService('Players').LocalPlayer,255)end end end",
                ['无限货币'] = "local d=game:GetService('Players').LocalPlayer:FindFirstChild('leaderstats')or game:GetService('Players').LocalPlayer:FindFirstChildOfClass('Folder');if d then for _,v in pairs(d:GetDescendants())do if v:IsA('NumberValue')or v:IsA('IntValue')then pcall(function()v.Value=1e9 end)end end end",
                ['杀戮光环'] = "local p=game:GetService('Players').LocalPlayer;local k=false;game:GetService('UserInputService').InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.X then k=not k end end);game:GetService('RunService').Heartbeat:Connect(function()if k then for _,v in pairs(game:GetService('Players'):GetPlayers())do if v~=p and v.Character and v.Character:FindFirstChild('HumanoidRootPart')and p.Character and p.Character:FindFirstChild('HumanoidRootPart')then local d=(v.Character.HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude;if d<=30 then pcall(function()v.Character:FindFirstChildOfClass('Humanoid'):TakeDamage(10)end)end end end end end)",
                ['ESP'] = "local e=false;local o={};game:GetService('UserInputService').InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.F then e=not e;if e then for _,v in pairs(game:GetService('Players'):GetPlayers())do if v~=game:GetService('Players').LocalPlayer then local h=Instance.new('Highlight');h.Adornee=v.Character;h.FillColor=Color3.fromRGB(255,50,50);h.FillTransparency=0.5;h.Parent=game:GetService('CoreGui');table.insert(o,h)end end else for _,v in pairs(o)do pcall(function()v:Destroy()end)end;o={}end end end)",
            }
            local code = nil
            for kw, c in pairs(lib) do if desc:find(kw) then code = c; break end end
            if not code then code = "print('❌ 未匹配到离线脚本，请填写API Key联网生成')" end
            local f, err = loadstring(code); if f then pcall(f) end
            return
        end
        
        -- 联网模式：使用Tool Calls方式调用DeepSeek API
        -- 定义tools: 让模型调用execute_lua函数返回结构化代码
        local tools = {
            {
                type = 'function',
                function = {
                    name = 'execute_lua',
                    description = '在Roblox中执行Lua脚本代码',
                    parameters = {
                        type = 'object',
                        properties = {
                            code = {
                                type = 'string',
                                description = '要执行的完整Lua代码，必须可独立运行'
                            }
                        },
                        required = {'code'}
                    }
                }
            }
        }
        
        local success, result = pcall(function()
            local url = 'https://api.deepseek.com/chat/completions'
            local body = H:JSONEncode({
                model = 'deepseek-chat',
                messages = {
                    {
                        role = 'system',
                        content = '你是一个Roblox Lua脚本生成器。用户会描述需要的功能，请使用execute_lua工具返回可执行的Lua代码。代码必须完整、可独立运行，使用game:GetService()等标准API。'
                    },
                    {role = 'user', content = prompt}
                },
                tools = tools,
                tool_choice = 'auto',
                temperature = 0.3,
                max_tokens = 2000
            })
            
            local response = H:PostAsync(url, {
                ['Content-Type'] = 'application/json',
                ['Authorization'] = 'Bearer ' .. apikey
            }, body)
            
            local data = H:JSONDecode(response)
            if data and data.choices and data.choices[1] then
                local msg = data.choices[1].message
                -- 检查是否有 tool_calls
                if msg.tool_calls and #msg.tool_calls > 0 then
                    local tool_call = msg.tool_calls[1]
                    if tool_call.function and tool_call.function.name == 'execute_lua' then
                        local args = H:JSONDecode(tool_call.function.arguments)
                        if args and args.code then
                            return args.code
                        end
                    end
                end
                -- 如果模型直接返回文本，也尝试执行
                if msg.content and msg.content ~= '' then
                    return msg.content
                end
            end
            return nil
        end)
        
        if success and result then
            local f, err = loadstring(result)
            if f then
                pcall(f)
            else
                print('❌ 代码编译失败: ' .. tostring(err))
            end
        end
    end,
    DoubleClick = false,
    Tooltip = '点击后AI通过Tool Calls生成并执行脚本'
})

-- ====== UI Settings ======
local UITab = Window:AddTab('UI设置')
local MenuGroup = UITab:AddLeftGroupbox('菜单')
MenuGroup:AddButton({ Text = '卸载菜单', Func = function() Library:Unload() end })
MenuGroup:AddLabel('菜单快捷键'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = '菜单快捷键' })
Library.ToggleKeybind = Options.MenuKeybind

-- Addons
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('DeltaUltimate')
SaveManager:SetFolder('DeltaUltimate/configs')
SaveManager:BuildConfigSection(UITab)
ThemeManager:ApplyToTab(UITab)
SaveManager:LoadAutoloadConfig()

-- ====== 水印 ======
Library:SetWatermarkVisibility(true)
local FrameTimer = tick(); local FrameCounter = 0; local FPS = 60
local WatermarkConnection = RS.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then FPS = FrameCounter; FrameTimer = tick(); FrameCounter = 0 end
    Library:SetWatermark(('👑 Delta 至尊版 v5.0 | %s fps | %s ms'):format(math.floor(FPS), math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())))
end)
Library.KeybindFrame.Visible = true
Library:OnUnload(function() WatermarkConnection:Disconnect(); Library.Unloaded = true end)

print('✅ Delta 至尊版 v5.0 LinoriaLib + Tool Calls 加载完成!')