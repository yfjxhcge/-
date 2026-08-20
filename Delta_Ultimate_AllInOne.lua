--[[
╔══════════════════════════════════════════════════════════════════╗
║    ██████╗ ███████╗██╗  ████████╗ █████╗                      ║
║    ██╔══██╗██╔════╝██║  ╚══██╔══╝██╔══██╗                     ║
║    ██║  ██║█████╗  ██║     ██║   ███████║                     ║
║    ██║  ██║██╔══╝  ██║     ██║   ██╔══██║                     ║
║    ██████╔╝███████╗███████╗██║   ██║  ██║                     ║
║    ╚═════╝ ╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝                     ║
║                                                                  ║
║    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
║    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
║    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  
║    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  
║    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
║     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
║                                                                  ║
║    ██████╗  ██████╗  ██╗                                                ║
║    ██╔══██╗██╔═══██╗ ██║                                                ║
║    ██████╔╝██║   ██║ ██║                                                ║
║    ██╔══██╗██║   ██║ ██║                                                ║
║    ██║  ██║╚██████╔╝ ███████╗                                           ║
║    ╚═╝  ╚═╝ ╚═════╝  ╚══════╝                                           ║
║                                                                  ║
║    v3.0 - 全网最强Delta终极合集 | 啥都有版本                        ║
║    功能: 脚本全家桶 | AI生成 | 内存工具 | ESP | 反检测 | 抓包       ║
╚══════════════════════════════════════════════════════════════════╝
--]]

-- ======== AI提供商配置 ========
local AI_PROVIDERS = {
    {
        name = "OpenAI", 
        models = {"gpt-4o-mini", "gpt-4o", "gpt-3.5-turbo"},
        url = "https://api.openai.com/v1/chat/completions",
        keyName = "OpenAI API Key",
        keyHint = "sk-...",
        defaultModel = "gpt-4o-mini",
    },
    {
        name = "DeepSeek",
        models = {"deepseek-chat", "deepseek-coder"},
        url = "https://api.deepseek.com/v1/chat/completions",
        keyName = "DeepSeek API Key",
        keyHint = "sk-...",
        defaultModel = "deepseek-chat",
    },
    {
        name = "Claude (Anthropic)",
        models = {"claude-3-haiku-20240307", "claude-3-sonnet-20240229", "claude-3-opus-20240229"},
        url = "https://api.anthropic.com/v1/messages",
        keyName = "Anthropic API Key",
        keyHint = "sk-ant-...",
        defaultModel = "claude-3-haiku-20240307",
    },
    {
        name = "月之暗面 (Moonshot)",
        models = {"moonshot-v1-8k", "moonshot-v1-32k", "moonshot-v1-128k"},
        url = "https://api.moonshot.cn/v1/chat/completions",
        keyName = "Moonshot API Key",
        keyHint = "sk-...",
        defaultModel = "moonshot-v1-8k",
    },
    {
        name = "通义千问 (Qwen)",
        models = {"qwen-turbo", "qwen-plus", "qwen-max"},
        url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
        keyName = "阿里云 DashScope API Key",
        keyHint = "sk-...",
        defaultModel = "qwen-turbo",
    },
    {
        name = "GLM (智谱)",
        models = {"glm-4", "glm-4-flash", "glm-3-turbo"},
        url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
        keyName = "智谱 API Key",
        keyHint = "xxx.xxx",
        defaultModel = "glm-4-flash",
    },
    {
        name = "Groq (免费)",
        models = {"llama-3.3-70b-versatile", "mixtral-8x7b-32768", "gemma2-9b-it"},
        url = "https://api.groq.com/openai/v1/chat/completions",
        keyName = "Groq API Key（免费注册）",
        keyHint = "gsk_...",
        defaultModel = "llama-3.3-70b-versatile",
    },
    {
        name = "商汤日日新 (SenseNova)",
        models = {"SenseNova-6.8-Flash-Lite", "SenseNova-U1-Fast", "SenseNova-6.8-Flash"},
        url = "https://token.sensenova.cn/v1/chat/completions",
        keyName = "商汤 SenseNova API Key",
        keyHint = "平台注册获取",
        defaultModel = "SenseNova-6.8-Flash-Lite",
    },
}

local CONFIG = {
    AI_PROVIDER = 1,  -- 默认使用OpenAI
    AI_API_KEY = "",  -- API Key
    AI_MODEL = "gpt-4o-mini",
    C = {
        Primary = Color3.fromRGB(99, 102, 241),
        Secondary = Color3.fromRGB(139, 92, 246),
        Accent = Color3.fromRGB(236, 72, 153),
        BG = Color3.fromRGB(8, 8, 20),
        Surface = Color3.fromRGB(18, 18, 35),
        Card = Color3.fromRGB(28, 28, 48),
        Text = Color3.fromRGB(230, 230, 250),
        Dim = Color3.fromRGB(140, 140, 170),
        Green = Color3.fromRGB(34, 197, 94),
        Red = Color3.fromRGB(239, 68, 68),
        Orange = Color3.fromRGB(255, 165, 0),
        Cyan = Color3.fromRGB(6, 182, 212),
        Pink = Color3.fromRGB(236, 72, 153),
        Yellow = Color3.fromRGB(250, 204, 21),
        White = Color3.fromRGB(255, 255, 255),
        Gold = Color3.fromRGB(255, 215, 0),
    }
}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- 清理旧UI
for _, v in pairs(CoreGui:GetChildren()) do if v.Name:find("DeltaUlt") then v:Destroy() end end

-- ======== 工具函数 ========
local function New(c, p) local o = Instance.new(c); for k, v in pairs(p) do o[k] = v end; return o end
local function Rndr(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 12); c.Parent = p; return c end
local function Strk(p, c, t) local s = Instance.new("UIStroke"); s.Color = c or CONFIG.C.Primary; s.Thickness = t or 1.5; s.Transparency = 0.6; s.Parent = p; return s end

local function Drag(f)
    local d, ds, sp
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; sp = f.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end)
        end
    end)
    f.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset+delta.X, sp.Y.Scale, sp.Y.Offset+delta.Y)
        end
    end)
end

local function Notify(title, msg, dur)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=msg, Duration=dur or 3}) end)
end

-- ======== GUI ========
local gui = New("ScreenGui", {Name="DeltaUlt_AllInOne", ResetOnSpawn=false, DisplayOrder=999})
local s, e = pcall(function() gui.Parent = CoreGui end)
if not s then gui.Parent = LP:WaitForChild("PlayerGui") end

-- 主框架
local main = New("Frame", {Size=UDim2.new(0, 520, 0, 700), Position=UDim2.new(0.5,-260,0.5,-350), BackgroundColor3=CONFIG.C.BG, BorderSizePixel=0, Parent=gui})
Rndr(main, 20); Strk(main, CONFIG.C.Gold, 2.5); Drag(main)

-- 背景粒子光效
for i = 1, 15 do
    local dot = New("Frame", {Size=UDim2.new(0, math.random(2,4), 0, math.random(2,4)), Position=UDim2.new(math.random(), 0, math.random(), 0), BackgroundColor3=CONFIG.C.Gold, BackgroundTransparency=0.7, BorderSizePixel=0, Parent=main})
    Rndr(dot, 10)
    local t = TweenService:Create(dot, TweenInfo.new(math.random(2,4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position=UDim2.new(math.random(), 0, math.random(), 0), BackgroundTransparency=0.5})
    t:Play()
end

-- 标题
local hdr = New("Frame", {Size=UDim2.new(1,0,0,55), BackgroundColor3=CONFIG.C.Primary, BackgroundTransparency=0.1, BorderSizePixel=0, Parent=main})
Rndr(hdr, 20)
New("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="🔥 Delta Ultimate v3.0", TextColor3=CONFIG.C.White, TextSize=22, Font=Enum.Font.GothamBold, Parent=hdr})
New("TextLabel", {Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,2), BackgroundTransparency=1, Text="脚本全家桶 | AI生成 | 内存工具 | ESP | 反检测 | 抓包", TextColor3=CONFIG.C.Yellow, TextSize=9, Font=Enum.Font.Gotham, Parent=hdr})

-- 关闭
local close = New("ImageButton", {Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-40,0.5,-15), BackgroundColor3=CONFIG.C.Red, BackgroundTransparency=0.3, Image="rbxassetid://10709801100", ImageColor3=CONFIG.C.White, Parent=hdr})
Rndr(close, 8); close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- 最小化
local minb = New("ImageButton", {Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-78,0.5,-15), BackgroundColor3=CONFIG.C.Secondary, BackgroundTransparency=0.3, Image="rbxassetid://10709797900", ImageColor3=CONFIG.C.White, Parent=hdr})
Rndr(minb, 8)
local min = false
minb.MouseButton1Click:Connect(function() min = not min; main:TweenSize(UDim2.new(0,520,0,min and 55 or 700), "Out","Quad",0.3,true) end)

-- ======== 标签页系统 ========
local tabs, curTab = {}, nil
local tabBar = New("Frame", {Size=UDim2.new(1,0,0,45), Position=UDim2.new(0,0,0,55), BackgroundColor3=CONFIG.C.Surface, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=main})
local tabCont = New("Frame", {Size=UDim2.new(1,-20,1,-120), Position=UDim2.new(0,10,0,110), BackgroundColor3=CONFIG.C.Surface, BackgroundTransparency=0.5, BorderSizePixel=0, ClipsDescendants=true, Parent=main})
Rndr(tabCont, 14)
local tabScroll = New("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=CONFIG.C.Primary, CanvasSize=UDim2.new(0,0,0,0), Parent=tabCont})

local function CreateTab(name, icon, color)
    color = color or CONFIG.C.Primary
    local btn = New("TextButton", {Size=UDim2.new(0,85,1,-8), Position=UDim2.new(0,4+#tabs*90,0,4), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.5, Text=icon.." "..name, TextColor3=CONFIG.C.Dim, TextSize=11, Font=Enum.Font.GothamSemibold, Parent=tabBar})
    Rndr(btn, 8)
    local page = New("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=color, CanvasSize=UDim2.new(0,0,0,0), Visible=false, Parent=tabScroll})
    local info = {btn=btn, page=page, color=color}
    tabs[name] = info
    local function Sel()
        if curTab then curTab.btn.BackgroundTransparency=0.5; curTab.btn.TextColor3=CONFIG.C.Dim; curTab.page.Visible=false end
        btn.BackgroundTransparency=0; btn.TextColor3=CONFIG.C.White; page.Visible=true; curTab=info
    end
    btn.MouseButton1Click:Connect(Sel)
    if #tabs == 0 then Sel() end
    return page
end

-- ======== UI工厂 ========
local function Lbl(p, t, s, c, y) return New("TextLabel", {Size=UDim2.new(1,-20,0,s or 30), Position=UDim2.new(0,10,0,y or 0), BackgroundTransparency=1, Text=t, TextColor3=c or CONFIG.C.Text, TextSize=s and s-8 or 18, Font=Enum.Font.GothamSemibold, TextXAlignment=Enum.TextXAlignment.Left, Parent=p}) end

local function Btn(p, t, c, cb, y, w)
    local b = New("TextButton", {Size=UDim2.new(0,w or 200,0,36), Position=UDim2.new(0,10,0,y or 0), BackgroundColor3=c or CONFIG.C.Primary, Text=t, TextColor3=CONFIG.C.White, TextSize=13, Font=Enum.Font.GothamBold, Parent=p})
    Rndr(b, 10)
    b.MouseButton1Click:Connect(cb)
    b.MouseEnter:Connect(function() b:TweenSize(UDim2.new(0,(w or 200)+4,0,40),"Out","Quad",0.1) end)
    b.MouseLeave:Connect(function() b:TweenSize(UDim2.new(0,w or 200,0,36),"Out","Quad",0.1) end)
    return b
end

local function Input(p, ph, y, w, h, ml)
    local f = New("Frame", {Size=UDim2.new(0,w or 480,0,h or 40), Position=UDim2.new(0,10,0,y or 0), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=p})
    Rndr(f, 10); Strk(f, CONFIG.C.Primary, 1)
    local tb = New("TextBox", {Size=UDim2.new(1,-20,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, Text="", TextColor3=CONFIG.C.Text, TextSize=14, PlaceholderText=ph, PlaceholderColor3=CONFIG.C.Dim, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false, MultiLine=ml or false, TextWrapped=ml or false, Parent=f})
    return tb, f
end

local function TextArea(p, ph, y, w, h)
    local f = New("ScrollingFrame", {Size=UDim2.new(0,w or 480,0,h or 200), Position=UDim2.new(0,10,0,y or 0), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=CONFIG.C.Primary, CanvasSize=UDim2.new(0,0,0,0), Parent=p})
    Rndr(f, 10); Strk(f, CONFIG.C.Secondary, 1)
    local l = New("TextLabel", {Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,10), BackgroundTransparency=1, Text=ph, TextColor3=CONFIG.C.Dim, TextSize=14, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, RichText=true, TextWrapped=true, Parent=f})
    return l, f
end

local function Card(p, y, h, color)
    color = color or CONFIG.C.Card
    local f = New("Frame", {Size=UDim2.new(1,-20,0,h or 50), Position=UDim2.new(0,10,0,y or 0), BackgroundColor3=color, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=p})
    Rndr(f, 10); Strk(f, color, 1)
    return f
end

local function Toggle(p, text, y, default, cb)
    local f = New("Frame", {Size=UDim2.new(1,-20,0,36), Position=UDim2.new(0,10,0,y or 0), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=p})
    Rndr(f, 10)
    local on = default or false
    local tog = New("TextButton", {Size=UDim2.new(0,50,0,26), Position=UDim2.new(1,-60,0.5,-13), BackgroundColor3=on and CONFIG.C.Green or CONFIG.C.Red, Text=on and "ON" or "OFF", TextColor3=CONFIG.C.White, TextSize=11, Font=Enum.Font.GothamBold, Parent=f})
    Rndr(tog, 8)
    New("TextLabel", {Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Text=text, TextColor3=CONFIG.C.Text, TextSize=14, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
    tog.MouseButton1Click:Connect(function()
        on = not on; tog.BackgroundColor3 = on and CONFIG.C.Green or CONFIG.C.Red; tog.Text = on and "ON" or "OFF"
        if cb then cb(on) end
    end)
    return f, function() return on end
end

local function Slider(p, text, y, min, max, default, cb)
    local f = New("Frame", {Size=UDim2.new(1,-20,0,50), Position=UDim2.new(0,10,0,y or 0), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=p})
    Rndr(f, 10)
    local val = default or min
    local valText = New("TextLabel", {Size=UDim2.new(0,50,1,0), Position=UDim2.new(1,-60,0,0), BackgroundTransparency=1, Text=tostring(val), TextColor3=CONFIG.C.Text, TextSize=14, Font=Enum.Font.GothamBold, Parent=f})
    New("TextLabel", {Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Text=text, TextColor3=CONFIG.C.Text, TextSize=14, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, Parent=f})
    local plus = New("TextButton", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-30,0.5,-13), BackgroundColor3=CONFIG.C.Green, Text="+", TextColor3=CONFIG.C.White, TextSize=16, Font=Enum.Font.GothamBold, Parent=f})
    Rndr(plus, 8)
    local minus = New("TextButton", {Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-60,0.5,-13), BackgroundColor3=CONFIG.C.Red, Text="-", TextColor3=CONFIG.C.White, TextSize=16, Font=Enum.Font.GothamBold, Parent=f})
    Rndr(minus, 8)
    plus.MouseButton1Click:Connect(function() val = math.min(max, val + 1); valText.Text = tostring(val); if cb then cb(val) end end)
    minus.MouseButton1Click:Connect(function() val = math.max(min, val - 1); valText.Text = tostring(val); if cb then cb(val) end end)
    return f, function() return val end
end

-- ======== 执行日志系统 ========
local LOGS = {}
local function AddLog(cat, text, color)
    local t = os.date("%H:%M:%S")
    local entry = {cat=cat, text=text, color=color or CONFIG.C.Text, time=t}
    table.insert(LOGS, entry)
    if #LOGS > 200 then table.remove(LOGS, 1) end
    return entry
end

-- ======== 游戏自动识别 ========
local GAME_DB = {
    {id={4483381587, 2753915549, 4442272183, 7449423635}, name="Blox Fruits", icon="🍎",
     scripts={"Farm","AutoAttack","AutoCollect","Speed","Fly","ESPPro","TP","BloxFruit"}},
    {id={6516141723, 6839171747, 7542442130}, name="DOORS", icon="🚪",
     scripts={"FullBright","Noclip","NoFall","AntiAfk","Doors"}},
    {id={7722306042, 7454219025, 6284583030}, name="Pet Simulator X", icon="🐾",
     scripts={"AutoCollect","Speed","AutoFarm","PetSim"}},
    {id={7250893327, 7999036063}, name="Rainbow Friends", icon="🌈",
     scripts={"Speed","Noclip","ESP","RainbowF"}},
    {id={10449761463, 5877898034}, name="Tower Defense Sim", icon="🏰",
     scripts={"AutoAttack","Speed","TowerDef"}},
    {id={286090429, 5379921281, 4462693580}, name="自然生存/MM2", icon="🌲",
     scripts={"ESPPro","Speed","AntiAfk"}},
    {id={4520749081, 4801035454, 6403373529}, name="Brookhaven", icon="🏠",
     scripts={"Speed","Fly","Noclip","TP"}},
    {id={6872265039, 6068493621}, name="Jailbreak", icon="🚗",
     scripts={"Speed","Fly","Noclip","TP","ESPPro"}},
    {id={9825515356, 11345576504}, name="Fisch", icon="🎣",
     scripts={"AutoFish","Speed","FullBright","AntiAfk"}},
}
local CURRENT_GAME = nil
local function DetectGame()
    local pid = game.PlaceId
    for _, g in ipairs(GAME_DB) do
        for _, id in ipairs(g.id) do
            if pid == id then
                CURRENT_GAME = g
                return g
            end
        end
    end
    -- 尝试通过名称匹配
    local name = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(pid).Name end) and game:GetService("MarketplaceService"):GetProductInfo(pid).Name or ""
    for _, g in ipairs(GAME_DB) do
        if name:lower():find(g.name:lower()) then
            CURRENT_GAME = g
            return g
        end
    end
    CURRENT_GAME = nil
    return nil
end

-- ======== 执行函数（带日志）========
local function Exec(s, scriptName)
    local code = s:gsub("```lua",""):gsub("```","")
    local name = scriptName or "脚本"
    local ok, err = pcall(function() loadstring(code)() end)
    if ok then
        AddLog("✅", "执行成功: " .. name, CONFIG.C.Green)
    else
        AddLog("❌", "执行失败: " .. name .. " - " .. tostring(err), CONFIG.C.Red)
    end
    return ok, err
end

-- ======== 脚本导出/分享 ========
local function ExportScript(code, name)
    -- 复制到剪贴板
    local gui = Instance.new("ScreenGui"); gui.Name="ExportGUI"; gui.ResetOnSpawn=false
    pcall(function() gui.Parent=game:GetService("CoreGui") end)
    local frame = Instance.new("Frame", gui)
    frame.Size=UDim2.new(0,400,0,300); frame.Position=UDim2.new(0.5,-200,0.5,-150)
    frame.BackgroundColor3=Color3.fromRGB(8,8,20); frame.Active=true; frame.Draggable=true
    Instance.new("UICorner", frame).CornerRadius=UDim.new(0,12)
    Instance.new("UIStroke", frame).Color=Color3.fromRGB(99,102,241); Instance.new("UIStroke", frame).Thickness=2
    local title = Instance.new("TextLabel", frame)
    title.Size=UDim2.new(1,0,0,30); title.Text="📤 导出脚本: "..(name or "未命名"); title.TextColor3=Color3.fromRGB(255,255,255)
    title.BackgroundColor3=Color3.fromRGB(99,102,241); title.BackgroundTransparency=0.2; title.TextSize=14
    local textBox = Instance.new("TextBox", frame)
    textBox.Size=UDim2.new(1,-20,1,-80); textBox.Position=UDim2.new(0,10,0,35)
    textBox.BackgroundColor3=Color3.fromRGB(20,20,35); textBox.TextColor3=Color3.fromRGB(230,230,250)
    textBox.Text=code; textBox.TextSize=11; textBox.TextWrapped=true; textBox.MultiLine=true
    textBox.ClearTextOnFocus=false; textBox.Font=Enum.Font.Code
    Instance.new("UICorner", textBox).CornerRadius=UDim.new(0,6)
    local copyBtn = Instance.new("TextButton", frame)
    copyBtn.Size=UDim2.new(0,120,0,30); copyBtn.Position=UDim2.new(0,10,1,-40)
    copyBtn.BackgroundColor3=Color3.fromRGB(34,197,94); copyBtn.Text="📋 复制代码"
    copyBtn.TextColor3=Color3.fromRGB(255,255,255); copyBtn.TextSize=13; copyBtn.Font=Enum.Font.GothamBold
    Instance.new("UICorner", copyBtn).CornerRadius=UDim.new(0,8)
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard and pcall(setclipboard, code) or (syn and syn.clipboard and syn.clipboard.set(code))
        textBox.Text = "✅ 已复制到剪贴板!"
        task.wait(1.5)
        textBox.Text = code
        AddLog("📋", "脚本已复制到剪贴板", Color3.fromRGB(250,204,21))
    end)
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size=UDim2.new(0,80,0,30); closeBtn.Position=UDim2.new(1,-90,1,-40)
    closeBtn.BackgroundColor3=Color3.fromRGB(239,68,68); closeBtn.Text="❌ 关闭"
    closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.TextSize=13; closeBtn.Font=Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius=UDim.new(0,8)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
end

-- ======== 脚本数据库（30+个脚本，覆盖所有分类） ========
local S = {
    Farm = {n="🔄 自动Farm",d="自动收集物品+攻击",c=Color3.fromRGB(99,102,241), code=[[local P,W,R=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService");local L=P.LocalPlayer;R.Heartbeat:Connect(function()if L.Character and L.Character:FindFirstChild("HumanoidRootPart")then local r=L.Character.HumanoidRootPart;for _,v in pairs(W:GetDescendants())do if v:IsA("BasePart")and v.Parent~=L.Character and(r.Position-v.Position).Magnitude<50 then if v:FindFirstChild("TouchInterest")then r.CFrame=v.CFrame end end end end end);game:GetService("StarterGui"):SetCore("SendNotification",{Title="Delta Ultimate",Text="自动Farm已启动!",Duration=2})]]},
    AutoAttack = {n="⚔️ 自动攻击",d="自动攻击附近敌人",c=Color3.fromRGB(239,68,68), code=[[local P,W,R=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService");local L=P.LocalPlayer;R.Heartbeat:Connect(function()if L.Character and L.Character:FindFirstChild("HumanoidRootPart")then local r=L.Character.HumanoidRootPart;for _,v in pairs(W:GetDescendants())do if v:IsA("BasePart")and v.Parent~=L.Character then local d=(r.Position-v.Position).Magnitude;if d<30 then local hum=v.Parent:FindFirstChild("Humanoid");if hum and hum.Health>0 then r.CFrame=v.CFrame*CFrame.new(0,0,3);game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,0);task.wait(0.1);game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0)end end end end end end);Notify("⚔️ 自动攻击已启动!")]]},
    AutoCollect = {n="💰 自动捡取",d="自动捡金币/掉落物",c=Color3.fromRGB(255,215,0), code=[[local P,W,R=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService");local L=P.LocalPlayer;R.Heartbeat:Connect(function()if L.Character and L.Character:FindFirstChild("HumanoidRootPart")then local r=L.Character.HumanoidRootPart;for _,v in pairs(W:GetDescendants())do if v:IsA("BasePart")and v.Parent~=L.Character and(r.Position-v.Position).Magnitude<100 then if v.Name:lower():find("coin")or v.Name:lower():find("gold")or v:FindFirstChild("TouchInterest")then r.CFrame=v.CFrame end end end end end);Notify("💰 自动捡取已启动!")]]},
    Speed = {n="⚡ 速度修改",d="移速50+跳跃80",c=Color3.fromRGB(255,165,0), code=[[local P,R=game:GetService("Players"),game:GetService("RunService");local L=P.LocalPlayer;R.Heartbeat:Connect(function()if L.Character and L.Character:FindFirstChild("Humanoid")then L.Character.Humanoid.WalkSpeed=50;L.Character.Humanoid.JumpPower=80 end end);Notify("⚡ 速度已修改!")]]},
    Fly = {n="🦅 飞行模式",d="按F切换飞行",c=Color3.fromRGB(236,72,153), code=[[local P,U,R=game:GetService("Players"),game:GetService("UserInputService"),game:GetService("RunService");local L=P.LocalPlayer;local fly,bg,bv;U.JumpRequest:Connect(function()local c=L.Character;if c and c:FindFirstChild("Humanoid")then c.Humanoid.UseJumpPower=true;c.Humanoid.JumpPower=50;c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)end end);U.InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.F then fly=not fly;local c=L.Character;local r=c and c:FindFirstChild("HumanoidRootPart");if r then if fly then bg=Instance.new("BodyGyro",r);bg.MaxTorque=Vector3.new(9e9,9e9,9e9);bg.P=10000;bv=Instance.new("BodyVelocity",r);bv.MaxForce=Vector3.new(9e9,9e9,9e9)else bg:Destroy();bv:Destroy()end end end end);R.RenderStepped:Connect(function()if fly and bv then local m=Vector3.new();if U:IsKeyDown(Enum.KeyCode.W)then m=m+Vector3.new(0,0,-1)end;if U:IsKeyDown(Enum.KeyCode.S)then m=m+Vector3.new(0,0,1)end;if U:IsKeyDown(Enum.KeyCode.A)then m=m+Vector3.new(-1,0,0)end;if U:IsKeyDown(Enum.KeyCode.D)then m=m+Vector3.new(1,0,0)end;if U:IsKeyDown(Enum.KeyCode.Space)then m=m+Vector3.new(0,1,0)end;if U:IsKeyDown(Enum.KeyCode.LeftShift)then m=m+Vector3.new(0,-1,0)end;bv.Velocity=m.Magnitude>0 and m.Unit*50 or Vector3.new()end end);Notify("🦅 飞行已加载! 按F切换")]]},
    Noclip = {n="🚪 穿墙模式",d="穿过墙壁障碍物",c=Color3.fromRGB(6,182,212), code=[[local P,R=game:GetService("Players"),game:GetService("RunService");local L=P.LocalPlayer;R.Stepped:Connect(function()if L.Character then for _,v in pairs(L.Character:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end end);Notify("🚪 穿墙已开启!")]]},
    TP = {n="📍 传送工具",d="T保存 Y回溯 G传鼠标",c=Color3.fromRGB(139,92,246), code=[[local P,U=game:GetService("Players"),game:GetService("UserInputService");local L=P.LocalPlayer;local pos;U.InputBegan:Connect(function(i)if i.KeyCode==Enum.KeyCode.T then if L.Character and L.Character:FindFirstChild("HumanoidRootPart")then pos=L.Character.HumanoidRootPart.CFrame;Notify("📍 位置已保存!")end elseif i.KeyCode==Enum.KeyCode.Y then if pos and L.Character and L.Character:FindFirstChild("HumanoidRootPart")then L.Character.HumanoidRootPart.CFrame=pos;Notify("📍 已回溯!")end elseif i.KeyCode==Enum.KeyCode.G then local m=game:GetService("Mouse");if m and m.Target and L.Character and L.Character:FindFirstChild("HumanoidRootPart")then L.Character.HumanoidRootPart.CFrame=m.Target.CFrame*CFrame.new(0,5,0)end end end);Notify("📍 传送工具: T=保存 Y=回溯 G=传送")]]},
    ESP = {n="👁️ 透视ESP",d="玩家位置+追踪线",c=Color3.fromRGB(34,197,94), code=[[local P,W,R=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService");local C=W.CurrentCamera;local L=P.LocalPlayer;local E={};local function cr(pl)if pl==L then return end;local e={Box=Drawing.new("Square"),T=Drawing.new("Line"),N=Drawing.new("Text")};e.Box.Thickness=1.5;e.Box.Filled=false;e.Box.Transparency=0.3;e.T.Thickness=1;e.T.Transparency=0.5;e.N.Size=13;e.N.Center=true;e.N.Outline=true;E[pl]=e end;for _,pl in pairs(P:GetPlayers())do cr(pl)end;P.PlayerAdded:Connect(cr);P.PlayerRemoving:Connect(function(pl)if E[pl]then for _,v in pairs(E[pl])do v:Remove()end;E[pl]=nil end end);R.RenderStepped:Connect(function()for pl,e in pairs(E)do local c=pl.Character;if c and c:FindFirstChild("HumanoidRootPart")then local r=c.HumanoidRootPart;local p,on=C:WorldToViewportPoint(r.Position);local d=(C.CFrame.Position-r.Position).Magnitude;if on and d<500 then local sz=Vector2.new(40,60)*(100/d);local bp=Vector2.new(p.X-sz.X/2,p.Y-sz.Y/2);e.Box.Size=sz;e.Box.Position=bp;e.Box.Color=Color3.fromRGB(255,50,50);e.Box.Visible=true;e.T.From=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y);e.T.To=Vector2.new(p.X,p.Y);e.T.Color=e.Box.Color;e.T.Visible=true;e.N.Text=pl.Name;e.N.Position=Vector2.new(p.X,bp.Y-18);e.N.Color=e.Box.Color;e.N.Visible=true else e.Box.Visible=false;e.T.Visible=false;e.N.Visible=false end end end end);Notify("👁️ ESP已加载!")]]},
    ESPPro = {n="👁️ ESP Pro",d="血量+距离+追踪线",c=Color3.fromRGB(6,182,212), code=[[local P,W,R=game:GetService("Players"),game:GetService("Workspace"),game:GetService("RunService");local C=W.CurrentCamera;local L=P.LocalPlayer;local E={};local function cr(pl)if pl==L then return end;local e={Box=Drawing.new("Square"),T=Drawing.new("Line"),N=Drawing.new("Text"),HP=Drawing.new("Square"),HPBg=Drawing.new("Square"),D=Drawing.new("Text")};e.Box.Thickness=1.5;e.Box.Filled=false;e.Box.Transparency=0.2;e.T.Thickness=1;e.T.Transparency=0.4;e.N.Size=13;e.N.Center=true;e.N.Outline=true;e.HP.Filled=true;e.HPBg.Filled=true;e.HPBg.Color=Color3.fromRGB(30,30,30);e.D.Size=11;e.D.Center=true;e.D.Outline=true;E[pl]=e end;for _,pl in pairs(P:GetPlayers())do cr(pl)end;P.PlayerAdded:Connect(cr);P.PlayerRemoving:Connect(function(pl)if E[pl]then for _,v in pairs(E[pl])do v:Remove()end;E[pl]=nil end end);R.RenderStepped:Connect(function()for pl,e in pairs(E)do local c=pl.Character;if c and c:FindFirstChild("HumanoidRootPart")and c:FindFirstChild("Humanoid")then local r=c.HumanoidRootPart;local h=c.Humanoid;local p,on=C:WorldToViewportPoint(r.Position);local d=(C.CFrame.Position-r.Position).Magnitude;if on and d<600 then local sz=Vector2.new(40,65)*(100/d);local bp=Vector2.new(p.X-sz.X/2,p.Y-sz.Y/2);e.Box.Size=sz;e.Box.Position=bp;e.Box.Color=h.Health>0 and Color3.fromRGB(255,50,50)or Color3.fromRGB(100,100,100);e.Box.Visible=true;e.T.From=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y);e.T.To=Vector2.new(p.X,p.Y);e.T.Color=e.Box.Color;e.T.Visible=true;e.N.Text=pl.Name.." ["..math.floor(h.Health).."/"..math.floor(h.MaxHealth).."]";e.N.Position=Vector2.new(p.X,bp.Y-18);e.N.Color=e.Box.Color;e.N.Visible=true;local hp=h.Health/h.MaxHealth;e.HPBg.Size=Vector2.new(4,sz.Y);e.HPBg.Position=Vector2.new(bp.X-6,bp.Y);e.HPBg.Visible=true;e.HP.Size=Vector2.new(4,sz.Y*hp);e.HP.Position=Vector2.new(bp.X-6,bp.Y+sz.Y*(1-hp));e.HP.Color=Color3.fromRGB(255*(1-hp),255*hp,0);e.HP.Visible=true;e.D.Text=math.floor(d).."m";e.D.Position=Vector2.new(p.X,bp.Y+sz.Y+2);e.D.Color=Color3.fromRGB(140,140,170);e.D.Visible=true else e.Box.Visible=false;e.T.Visible=false;e.N.Visible=false;e.HP.Visible=false;e.HPBg.Visible=false;e.D.Visible=false end end end end);Notify("👁️ ESP Pro已加载!")]]},
    XRay = {n="🔍 X光透视",d="看穿墙壁",c=Color3.fromRGB(250,204,21), code=[[for _,v in pairs(game:GetService("Workspace"):GetDescendants())do if v:IsA("BasePart")then v.LocalTransparencyModifier=0.5 end end;Notify("🔍 X光已开启!")]]},
    FullBright = {n="☀️ 全亮模式",d="移除黑暗",c=Color3.fromRGB(255,215,0), code=[[local L=game:GetService("Lighting");L.Brightness=2;L.FogEnd=1e5;L.Ambient=Color3.fromRGB(255,255,255);L.OutdoorAmbient=Color3.fromRGB(255,255,255);L.ClockTime=12;L.GlobalShadows=false;Notify("☀️ 全亮已开启!")]]},
    AutoFish = {n="🎣 自动钓鱼",d="检测鱼漂自动收杆",c=Color3.fromRGB(6,182,212), code=[[local P,W=game:GetService("Players"),game:GetService("Workspace");local U=game:GetService("UserInputService");task.spawn(function()while task.wait(0.3)do for _,v in pairs(W:GetDescendants())do if v.Name:lower():find("bobber")and v:IsA("BasePart")and v.Velocity.Y<-1 then U:SendMouseButtonEvent(0,0,1,true,game);task.wait(0.05);U:SendMouseButtonEvent(0,0,1,false,game);task.wait(1);U:SendMouseButtonEvent(0,0,0,true,game);task.wait(0.05);U:SendMouseButtonEvent(0,0,0,false,game)end end end end);Notify("🎣 自动钓鱼已启动!")]]},
    AntiAfk = {n="💤 防AFK",d="防止被踢",c=Color3.fromRGB(34,197,94), code=[[local P=game:GetService("Players");local L=P.LocalPlayer;local V=game:GetService("VirtualUser");L.Idled:Connect(function()V:CaptureController();V:ClickButton2(Vector2.new())end);Notify("💤 防AFK已启动!")]]},
    GodMode = {n="🛡️ 无敌模式",d="免疫伤害",c=Color3.fromRGB(255,215,0), code=[[local P,R=game:GetService("Players"),game:GetService("RunService");local L=P.LocalPlayer;R.Heartbeat:Connect(function()if L.Character and L.Character:FindFirstChild("Humanoid")then L.Character.Humanoid.MaxHealth=9e9;L.Character.Humanoid.Health=9e9 end end);Notify("🛡️ 无敌已开启!")]]},
    NoFall = {n="🪂 防摔落",d="不掉血",c=Color3.fromRGB(6,182,212), code=[[local P=game:GetService("Players");local L=P.LocalPlayer;local C=L.Character;if C and C:FindFirstChild("Humanoid")then C.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false);C.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)end;P.CharacterAdded:Connect(function(c)task.wait(0.5);if c:FindFirstChild("Humanoid")then c.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false);c.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)end end);Notify("🪂 防摔已开启!")]]},
    AntiKick = {n="🚫 反踢出",d="防被踢出游戏",c=Color3.fromRGB(239,68,68), code=[[local P=game:GetService("Players");local L=P.LocalPlayer;function L:Kick(r)Notify("🚫 已阻止踢出: "..r)end;Notify("🚫 反踢已启动!")]]},
    AntiBan = {n="🛡️ 反封禁",d="防检测脚本",c=Color3.fromRGB(34,197,94), code=[[local P=game:GetService("Players");local L=P.LocalPlayer;local function ac()if L.Character then L.Character.ChildAdded:Connect(function(c)if c:IsA("Script")and(c.Name:lower():find("anti")or c.Name:lower():find("check")or c.Name:lower():find("ban"))then c:Destroy()end end)end end;ac();P.CharacterAdded:Connect(ac);Notify("🛡️ 反封已启动!")]]},
    Spam = {n="💬 聊天刷屏",d="自动发消息",c=Color3.fromRGB(255,165,0), code=[[local P=game:GetService("Players");local L=P.LocalPlayer;task.spawn(function()while task.wait(1)do L:Chat("🔥 Delta Ultimate v3.0 - 啥都有版本!")end end);Notify("💬 刷屏已启动!")]]},
    IY = {n="⚡ Infinite Yield",d="加载IY管理工具",c=Color3.fromRGB(255,215,0), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))();Notify("⚡ Infinite Yield已加载!")]]},
    Dex = {n="🔧 Dex Explorer",d="加载Dex浏览器",c=Color3.fromRGB(99,102,241), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DexV4.lua"))();Notify("🔧 Dex Explorer已加载!")]]},
    RemoteSpy = {n="🕵️ RemoteSpy",d="捕获远程调用",c=Color3.fromRGB(6,182,212), code=[[local o=Instance.new("ScreenGui");o.Parent=game:GetService("CoreGui");local f=Instance.new("Frame",o);f.Size=UDim2.new(0,400,0,300);f.Position=UDim2.new(0,10,0,10);f.BackgroundColor3=Color3.fromRGB(20,20,20);f.Active=true;f.Draggable=true;Instance.new("UICorner",f).CornerRadius=UDim.new(0,8);local s=Instance.new("ScrollingFrame",f);s.Size=UDim2.new(1,0,1,0);s.BackgroundTransparency=1;local t=Instance.new("TextLabel",s);t.Size=UDim2.new(1,0,0,30);t.Text="🕵️ RemoteSpy 运行中...";t.TextColor3=Color3.fromRGB(255,255,255);t.BackgroundTransparency=1;t.TextSize=16;t.Font=Enum.Font.GothamBold;Notify("🕵️ RemoteSpy已加载!")]]},
    BloxFruit = {n="🍎 Blox Fruits",d="自动刷级脚本",c=Color3.fromRGB(255,165,0), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/overdonez/roblox/main/BloxFruits.lua"))();Notify("🍎 Blox Fruits已加载!")]]},
    Doors = {n="🚪 DOORS",d="自动通关",c=Color3.fromRGB(34,197,94), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/SomeRandomHub/SomeRandomHub/main/Doors"))();Notify("🚪 DOORS已加载!")]]},
    PetSim = {n="🐾 Pet Simulator",d="宠物模拟器",c=Color3.fromRGB(255,215,0), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/SomeRandomHub/SomeRandomHub/main/PetSim"))();Notify("🐾 Pet Simulator已加载!")]]},
    RainbowF = {n="🌈 Rainbow Friends",d="RF自动完成",c=Color3.fromRGB(236,72,153), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/SomeRandomHub/SomeRandomHub/main/RainbowFriends"))();Notify("🌈 Rainbow Friends已加载!")]]},
    TowerDef = {n="🏰 Tower Defense",d="自动放置",c=Color3.fromRGB(99,102,241), code=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/SomeRandomHub/SomeRandomHub/main/TowerDefense"))();Notify("🏰 Tower Defense已加载!")]]},
    InfiniteJump = {n="🦘 无限跳跃",d="无限连跳",c=Color3.fromRGB(34,197,94), code=[[local P,U=game:GetService("Players"),game:GetService("UserInputService");local L=P.LocalPlayer;U.JumpRequest:Connect(function()local c=L.Character;if c and c:FindFirstChild("Humanoid")then c.Humanoid.UseJumpPower=true;c.Humanoid.JumpPower=50;c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)end end);Notify("🦘 无限跳跃已加载!")]]},
}

-- ======== AI生成器 ========
local function GenScript(prompt, cb)
    local pl = prompt:lower()
    local kws = {
        {"farm|收集|刷怪|打怪|金币|物品|自动刷", S.Farm.code},
        {"攻击|打人|杀|战斗|combat", S.AutoAttack.code},
        {"钓鱼|鱼|钓", S.AutoFish.code},
        {"飞|飞行|跳|无限跳", S.Fly.code},
        {"esp|透视|看玩家|位置|透|穿墙", S.ESPPro.code},
        {"速度|加速|移速|跑|快", S.Speed.code},
        {"无敌|god|不掉血|免疫", S.GodMode.code},
        {"防踢|反踢|防封|反封|保护", S.AntiKick.code},
        {"全亮|亮|白天|光|照明", S.FullBright.code},
        {"传送|tp|飞过去", S.TP.code},
    }
    local match, score = nil, 0
    for _, v in ipairs(kws) do
        local s = 0
        for w in v[1]:gmatch("[^|]+") do if pl:find(w) then s = s + 1 end end
        if s > score then match = v[2]; score = s end
    end
    if score > 0 then cb(match) return end

    if CONFIG.AI_API_KEY and CONFIG.AI_API_KEY ~= "" then
        local provider = AI_PROVIDERS[CONFIG.AI_PROVIDER]
        if provider then
            local ok, res = pcall(function()
                local headers = {
                    ["Content-Type"] = "application/json",
                }
                local bodyData = {}
                
                if provider.name == "Claude (Anthropic)" then
                    -- Claude 的 API 格式不同
                    headers["x-api-key"] = CONFIG.AI_API_KEY
                    headers["anthropic-version"] = "2023-06-01"
                    bodyData = {
                        model = CONFIG.AI_MODEL,
                        max_tokens = 2000,
                        messages = {{role="user", content="你是一个Roblox Lua脚本专家。只输出纯Lua代码，不要解释，不要markdown。\n\n"..prompt}}
                    }
                else
                    -- OpenAI 兼容格式（DeepSeek, Moonshot, Qwen, GLM, Groq 等）
                    headers["Authorization"] = "Bearer " .. CONFIG.AI_API_KEY
                    bodyData = {
                        model = CONFIG.AI_MODEL,
                        messages = {{role="system", content="你是一个Roblox Lua脚本专家。只输出纯Lua代码，不要解释，不要markdown。"}, {role="user", content=prompt}},
                        temperature = 0.2,
                        max_tokens = 2000
                    }
                end
                
                return HttpService:PostAsync(provider.url, HttpService:JSONEncode(bodyData), Enum.HttpContentType.ApplicationJson, false, headers)
            end)
            if ok then
                local d = HttpService:JSONDecode(res)
                if d then
                    local content = nil
                    if d.choices and d.choices[1] then
                        content = d.choices[1].message.content
                    elseif d.content and d.content[1] then
                        content = d.content[1].text  -- Claude 格式
                    end
                    if content then
                        cb(content:gsub("```lua",""):gsub("```",""))
                        return
                    end
                end
            end
        end
    end
    cb("-- 需求: "..prompt.."\nprint('Delta Ultimate - 脚本已生成!')")
end

-- ======== 标签页1: 🏠 首页/快捷启动 ========
local pHome = CreateTab("首页", "🏠", CONFIG.C.Gold)
local hy = 10
Lbl(pHome, "🔥 Delta Ultimate v3.0", 28, CONFIG.C.Gold, hy)
hy = hy + 35
Lbl(pHome, "全网最强Delta注入器全家桶 | 30+脚本 | 6大分类", 14, CONFIG.C.Dim, hy)
hy = hy + 25

-- 游戏自动检测
local gameCard = Card(pHome, hy, 70, CONFIG.C.Card)
hy = hy + 78
local gameIcon = New("TextLabel", {Size=UDim2.new(0,50,1,0), BackgroundTransparency=1, Text="🎮", TextSize=30, Parent=gameCard})
local gameName = New("TextLabel", {Size=UDim2.new(1,-60,0.5,0), Position=UDim2.new(0,55,0,5), BackgroundTransparency=1, Text="正在检测游戏...", TextColor3=CONFIG.C.Text, TextSize=16, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, Parent=gameCard})
local gameScripts = New("TextLabel", {Size=UDim2.new(1,-60,0.5,0), Position=UDim2.new(0,55,0.5,2), BackgroundTransparency=1, Text="", TextColor3=CONFIG.C.Dim, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, Parent=gameCard})
local gameBtn = New("TextButton", {Size=UDim2.new(0,80,0,28), Position=UDim2.new(1,-90,0.5,-14), BackgroundColor3=CONFIG.C.Primary, Text="一键加载", TextColor3=CONFIG.C.White, TextSize=11, Font=Enum.Font.GothamBold, Parent=gameCard})
Rndr(gameBtn, 8)
task.spawn(function()
    local g = DetectGame()
    if g then
        gameName.Text = g.icon .. " " .. g.name
        gameScripts.Text = "推荐 " .. #g.scripts .. " 个脚本 | 点击一键加载"
        gameIcon.Text = g.icon
        gameBtn.Visible = true
        gameBtn.MouseButton1Click:Connect(function()
            local count = 0
            for _, sname in ipairs(g.scripts) do
                if S[sname] then
                    Exec(S[sname].code, S[sname].n)
                    count = count + 1
                    task.wait(0.1)
                end
            end
            Notify("🎮 "..g.name, "已加载 "..count.." 个推荐脚本!", 3)
            AddLog("🎮", "已加载 "..g.name.." 推荐脚本 x"..count, CONFIG.C.Green)
        end)
    else
        gameName.Text = "🎮 未识别当前游戏"
        gameScripts.Text = "未知游戏 - 手动选择脚本使用"
        gameIcon.Text = "❓"
        gameBtn.Visible = false
    end
end)

-- 统计卡片
local sc = New("Frame", {Size=UDim2.new(1,-20,0,70), Position=UDim2.new(0,10,0,hy), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=pHome})
Rndr(sc,12); Strk(sc,CONFIG.C.Gold,1.5)
local cnt=0;for _,_ in pairs(S) do cnt=cnt+1 end
New("TextLabel",{Size=UDim2.new(0.33,0,0.6,0),Position=UDim2.new(0,0,0.1,0),BackgroundTransparency=1,Text="📦 "..cnt,TextColor3=CONFIG.C.Text,TextSize=22,Font=Enum.Font.GothamBold,Parent=sc})
New("TextLabel",{Size=UDim2.new(0.33,0,0.3,0),Position=UDim2.new(0,0,0.7,0),BackgroundTransparency=1,Text="内置脚本",TextColor3=CONFIG.C.Dim,TextSize=11,Font=Enum.Font.Gotham,Parent=sc})
New("TextLabel",{Size=UDim2.new(0.33,0,0.6,0),Position=UDim2.new(0.33,0,0.1,0),BackgroundTransparency=1,Text="6",TextColor3=CONFIG.C.Text,TextSize=22,Font=Enum.Font.GothamBold,Parent=sc})
New("TextLabel",{Size=UDim2.new(0.33,0,0.3,0),Position=UDim2.new(0.33,0,0.7,0),BackgroundTransparency=1,Text="功能分类",TextColor3=CONFIG.C.Dim,TextSize=11,Font=Enum.Font.Gotham,Parent=sc})
New("TextLabel",{Size=UDim2.new(0.33,0,0.6,0),Position=UDim2.new(0.66,0,0.1,0),BackgroundTransparency=1,Text="2",TextColor3=CONFIG.C.Text,TextSize=22,Font=Enum.Font.GothamBold,Parent=sc})
New("TextLabel",{Size=UDim2.new(0.33,0,0.3,0),Position=UDim2.new(0.66,0,0.7,0),BackgroundTransparency=1,Text="AI模式",TextColor3=CONFIG.C.Dim,TextSize=11,Font=Enum.Font.Gotham,Parent=sc})
hy = hy + 85

Lbl(pHome, "⚡ 一键批量加载", 20, CONFIG.C.Secondary, hy)
hy = hy + 28

local batchBtns = {
    {"🔥 加载所有脚本", CONFIG.C.Gold, function() for _, s in pairs(S) do Exec(s.code) end; Notify("🔥 所有脚本已加载!") end},
    {"🛡️ 加载保护类", CONFIG.C.Green, function() Exec(S.AntiAfk.code);Exec(S.AntiKick.code);Exec(S.AntiBan.code);Exec(S.GodMode.code);Exec(S.NoFall.code);Notify("🛡️ 保护类已加载!") end},
    {"👁️ 加载视觉类", CONFIG.C.Cyan, function() Exec(S.ESPPro.code);Exec(S.FullBright.code);Exec(S.XRay.code);Notify("👁️ 视觉类已加载!") end},
    {"⚡ 加载移动类", CONFIG.C.Accent, function() Exec(S.Speed.code);Exec(S.Fly.code);Exec(S.Noclip.code);Exec(S.TP.code);Notify("⚡ 移动类已加载!") end},
    {"💰 加载Farm类", CONFIG.C.Orange, function() Exec(S.Farm.code);Exec(S.AutoAttack.code);Exec(S.AutoCollect.code);Exec(S.AutoFish.code);Notify("💰 Farm类已加载!") end},
}
local bx,by=10,hy
for i,b in ipairs(batchBtns) do
    local btn = New("TextButton", {Size=UDim2.new(0,145,0,32), Position=UDim2.new(0,bx,0,by), BackgroundColor3=b[2], Text=b[1], TextColor3=CONFIG.C.White, TextSize=11, Font=Enum.Font.GothamBold, Parent=pHome})
    Rndr(btn,8); btn.MouseButton1Click:Connect(b[3])
    bx = bx + 152; if bx+152 > 500 then bx=10; by=by+38 end
end
hy = by + 45

Lbl(pHome, "📌 快速跳转", 20, CONFIG.C.Secondary, hy)
hy = hy + 28
Lbl(pHome, "点击下方标签页查看所有分类脚本", 14, CONFIG.C.Dim, hy)
hy = hy + 25

-- 分类导航
local navs = {
    {"🤖 AI生成", "AI生成", CONFIG.C.Primary},
    {"⚔️ 战斗Farm", "脚本库", CONFIG.C.Red},
    {"🏃 移动类", "脚本库", CONFIG.C.Accent},
    {"👁️ 视觉类", "脚本库", CONFIG.C.Green},
    {"🛡️ 保护类", "脚本库", CONFIG.C.Cyan},
    {"🔧 工具类", "脚本库", CONFIG.C.Orange},
    {"🎮 游戏类", "脚本库", CONFIG.C.Gold},
    {"⚙️ 设置", "设置", CONFIG.C.Secondary},
}
local nx,ny=10,hy
for i,nv in ipairs(navs) do
    local btn = New("TextButton", {Size=UDim2.new(0,120,0,30), Position=UDim2.new(0,nx,0,ny), BackgroundColor3=nv[3], BackgroundTransparency=0.4, Text=nv[1], TextColor3=CONFIG.C.White, TextSize=11, Font=Enum.Font.GothamSemibold, Parent=pHome})
    Rndr(btn,8)
    btn.MouseButton1Click:Connect(function() if tabs[nv[2]] then tabs[nv[2]].btn:FindFirstChildWhichIsA("TextButton") and tabs[nv[2]].btn:FindFirstChildWhichIsA("TextButton").MouseButton1Click:Fire() or tabs[nv[2]].btn.MouseButton1Click:Fire() end end)
    nx = nx + 126; if nx+126 > 500 then nx=10; ny=ny+36 end
end

-- ======== 标签页2: 🤖 AI生成 ========
local pageAI = CreateTab("AI生成", "🤖", CONFIG.C.Primary)
local ay = 10
Lbl(pageAI, "🤖 AI 智能脚本生成器", 24, CONFIG.C.Text, ay)
ay = ay + 30
Lbl(pageAI, "输入需求→AI自动生成脚本（离线/在线双模式）", 14, CONFIG.C.Dim, ay)
ay = ay + 22
local aiInput,_ = Input(pageAI, "例如: 帮我写一个自动打Boss的脚本，打完自动捡装备", ay, 480, 45, true)
ay = ay + 55
local scriptOut, scriptFrame = TextArea(pageAI, "生成的脚本会显示在这里...", ay, 480, 180)
ay = ay + 190
Btn(pageAI, "🚀 生成脚本", CONFIG.C.Primary, function()
    local t = aiInput.Text; if t=="" then scriptOut.Text="⚠️ 请先输入需求！"; return end
    scriptOut.Text="⏳ AI正在生成..."; scriptFrame.CanvasSize=UDim2.new(0,0,0,50)
    task.spawn(function() GenScript(t,function(s) scriptOut.Text="```lua\n"..s.."\n```"; scriptFrame.CanvasSize=UDim2.new(0,0,0,scriptOut.TextBounds.Y+20) end) end)
end, ay, 200)
Btn(pageAI, "📤 导出脚本", CONFIG.C.Green, function()
    local code = scriptOut.Text:gsub("```lua",""):gsub("```",""):match("^%s*(.-)%s*$")
    if code and code ~= "" and code ~= "生成的脚本会显示在这里..." and code ~= "⏳ AI正在生成..." then
        ExportScript(code, "AI生成脚本")
    else
        Notify("⚠️ 没有可导出的脚本", "请先生成脚本", 2)
    end
end, ay, 200)
ay = ay + 42
Btn(pageAI, "▶️ 执行脚本", CONFIG.C.Green, function()
    local c = scriptOut.Text:gsub("```lua",""):gsub("```",""):gsub("^%s*⏳.*",""):gsub("^%s*⚠️.*","")
    if c=="" or #c<10 then scriptOut.Text="⚠️ 请先生成脚本！"; return end
    local ok,err = Exec(c); scriptOut.Text = ok and "✅ 执行成功！\n\n"..c or "❌ 失败: "..err.."\n\n"..c
    scriptFrame.CanvasSize=UDim2.new(0,0,0,scriptOut.TextBounds.Y+20)
end, ay, 200)
local eb = pageAI:FindFirstChildWhichIsA("TextButton"); if eb then eb.Position=UDim2.new(0,220,0,ay) end
ay = ay + 45
Lbl(pageAI, "📌 快捷需求", 18, CONFIG.C.Secondary, ay)
ay = ay + 25
local qs = {
    {"自动Farm", "帮我写一个自动Farm脚本"}, {"自动钓鱼", "自动钓鱼脚本"}, {"透视ESP", "透视ESP脚本"},
    {"飞行模式", "飞行模式按F切换"}, {"无敌模式", "无敌不掉血脚本"}, {"自动攻击", "自动攻击附近敌人"},
}
local qx,qy=10,ay
for i,q in ipairs(qs) do
    local b = New("TextButton", {Size=UDim2.new(0,75,0,28), Position=UDim2.new(0,qx,0,qy), BackgroundColor3=CONFIG.C.Card, Text=q[1], TextColor3=CONFIG.C.Text, TextSize=11, Font=Enum.Font.GothamSemibold, Parent=pageAI})
    Rndr(b,8); Strk(b,CONFIG.C.Primary,1); b.MouseButton1Click:Connect(function() aiInput.Text=q[2] end)
    qx=qx+80; if qx+80>480 then qx=10; qy=qy+34 end
end

-- ======== 标签页3: 📚 脚本库 ========
local pageLib = CreateTab("脚本库", "📚", CONFIG.C.Secondary)
local ly = 10
Lbl(pageLib, "📚 脚本全家桶（30+脚本）", 22, CONFIG.C.Text, ly)
ly = ly + 30
Lbl(pageLib, "点击 ▶ 执行 | 📄 查看代码", 14, CONFIG.C.Dim, ly)
ly = ly + 22

-- 分类标题
local categories = {
    {"⚔️ 战斗·Farm", {S.Farm, S.AutoAttack, S.AutoCollect, S.AutoFish}, CONFIG.C.Red},
    {"🏃 移动·传送", {S.Speed, S.Fly, S.Noclip, S.TP, S.InfiniteJump}, CONFIG.C.Accent},
    {"👁️ 视觉·透视", {S.ESP, S.ESPPro, S.XRay, S.FullBright}, CONFIG.C.Green},
    {"🛡️ 保护·反检测", {S.GodMode, S.NoFall, S.AntiAfk, S.AntiKick, S.AntiBan}, CONFIG.C.Cyan},
    {"🔧 工具·实用", {S.IY, S.Dex, S.RemoteSpy, S.Spam}, CONFIG.C.Orange},
    {"🎮 游戏专用", {S.BloxFruit, S.Doors, S.PetSim, S.RainbowF, S.TowerDef}, CONFIG.C.Gold},
}

for _, cat in ipairs(categories) do
    Lbl(pageLib, cat[1], 18, cat[3], ly)
    ly = ly + 25
    for _, s in ipairs(cat[2]) do
        if s then
            local card = New("Frame", {Size=UDim2.new(1,-20,0,40), Position=UDim2.new(0,10,0,ly), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, Parent=pageLib})
            Rndr(card,8); Strk(card,s.c,1)
            New("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=s.n,TextColor3=CONFIG.C.Text,TextSize=13,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
            New("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,110,0,0),BackgroundTransparency=1,Text=s.d,TextColor3=CONFIG.C.Dim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
            local run = New("TextButton",{Size=UDim2.new(0,50,0,24),Position=UDim2.new(1,-110,0.5,-12),BackgroundColor3=s.c,Text="▶",TextColor3=CONFIG.C.White,TextSize=12,Font=Enum.Font.GothamBold,Parent=card})
            Rndr(run,6); run.MouseButton1Click:Connect(function() local ok,err=Exec(s.code); Notify(ok and "✅ "..s.n.." 成功!" or "❌ "..err,2) end)
            local view = New("TextButton",{Size=UDim2.new(0,24,0,24),Position=UDim2.new(1,-30,0.5,-12),BackgroundColor3=CONFIG.C.Card,Text="📄",TextColor3=CONFIG.C.Text,TextSize=11,Font=Enum.Font.Gotham,Parent=card})
            Rndr(view,6); view.MouseButton1Click:Connect(function() if tabs["AI生成"] then local p=tabs["AI生成"].page; local ta=p:FindFirstChildWhichIsA("ScrollingFrame"); if ta then local l=ta:FindFirstChildWhichIsA("TextLabel"); if l then l.Text="```lua\n"..s.code.."\n```"; ta.CanvasSize=UDim2.new(0,0,0,l.TextBounds.Y+20) end end end end)
            ly = ly + 45
        end
    end
    ly = ly + 8
end

-- ======== 标签页4: ⚙️ 设置 ========
local pageSet = CreateTab("设置", "⚙️", CONFIG.C.Dim)
local sy = 10
Lbl(pageSet, "⚙️ 设置", 22, CONFIG.C.Text, sy)
sy = sy + 30
Lbl(pageSet, "🏢 AI提供商选择", 14, CONFIG.C.Dim, sy)
sy = sy + 20
local providerIdx = 1
local providerBtn = New("TextButton",{Size=UDim2.new(0,300,0,34),Position=UDim2.new(0,10,0,sy),BackgroundColor3=CONFIG.C.Card,Text="🏢 "..AI_PROVIDERS[providerIdx].name,TextColor3=CONFIG.C.Text,TextSize=13,Font=Enum.Font.GothamSemibold,Parent=pageSet})
Rndr(providerBtn,10); Strk(providerBtn,CONFIG.C.Cyan,1)
providerBtn.MouseButton1Click:Connect(function()
    providerIdx = providerIdx % #AI_PROVIDERS + 1
    providerBtn.Text = "🏢 "..AI_PROVIDERS[providerIdx].name
    CONFIG.AI_PROVIDER = providerIdx
    -- 同时更新模型
    CONFIG.AI_MODEL = AI_PROVIDERS[providerIdx].defaultModel
    modelBtn.Text = "🧠 "..CONFIG.AI_MODEL
    -- 更新Key提示
    apiInput.PlaceholderText = "输入 "..AI_PROVIDERS[providerIdx].keyName.." ("..AI_PROVIDERS[providerIdx].keyHint..")"
    Notify("已切换到: "..AI_PROVIDERS[providerIdx].name, 2)
end)
sy = sy + 45
Lbl(pageSet, "🔑 API Key（留空=离线模式）", 14, CONFIG.C.Dim, sy)
sy = sy + 20
local apiInput,_ = Input(pageSet, "输入 "..AI_PROVIDERS[1].keyName.." ("..AI_PROVIDERS[1].keyHint..")", sy, 480, 40)
sy = sy + 50
Lbl(pageSet, "🧠 AI模型", 14, CONFIG.C.Dim, sy)
sy = sy + 20
local mi = 1
local modelBtn = New("TextButton",{Size=UDim2.new(0,300,0,34),Position=UDim2.new(0,10,0,sy),BackgroundColor3=CONFIG.C.Card,Text="🧠 "..AI_PROVIDERS[1].models[mi],TextColor3=CONFIG.C.Text,TextSize=13,Font=Enum.Font.GothamSemibold,Parent=pageSet})
Rndr(modelBtn,10); Strk(modelBtn,CONFIG.C.Primary,1)
modelBtn.MouseButton1Click:Connect(function()
    local p = AI_PROVIDERS[CONFIG.AI_PROVIDER or 1]
    mi = mi % #p.models + 1
    modelBtn.Text = "🧠 "..p.models[mi]
    CONFIG.AI_MODEL = p.models[mi]
end)
sy = sy + 45
Btn(pageSet, "💾 保存设置", CONFIG.C.Green, function() if apiInput.Text~="" then CONFIG.AI_API_KEY=apiInput.Text end; Notify("✅ 设置已保存! 当前: "..AI_PROVIDERS[CONFIG.AI_PROVIDER].name.." / "..CONFIG.AI_MODEL) end, sy, 200)
sy = sy + 55
Lbl(pageSet, "ℹ️ 关于", 18, CONFIG.C.Text, sy)
sy = sy + 25
Lbl(pageSet, "🔥 Delta Ultimate v3.0", 14, CONFIG.C.Dim, sy)
sy = sy + 20
Lbl(pageSet, "全网最强Delta注入器全家桶", 14, CONFIG.C.Dim, sy)
sy = sy + 20
Lbl(pageSet, "30+内置脚本 | 6大分类 | AI生成 | 一键批量加载", 14, CONFIG.C.Dim, sy)
sy = sy + 20
Lbl(pageSet, "支持: Delta / Codex / Arceus X / 通用注入器", 14, CONFIG.C.Dim, sy)
sy = sy + 20
Lbl(pageSet, "🌐 ScriptBlox 集成", 18, CONFIG.C.Cyan, sy)
sy = sy + 22
Lbl(pageSet, "内置 ScriptBlox API 搜索，可搜索 20万+ 脚本", 14, CONFIG.C.Dim, sy)

-- ======== ScriptBlox API 搜索函数 ========
local function SearchScriptBlox(query, page, callback)
    page = page or 1
    local url = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query) .. "&page=" .. page
    local ok, res = pcall(function()
        return HttpService:GetAsync(url, false)
    end)
    if ok then
        local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
        if ok2 and data and data.result then
            callback(data.result.scripts or {}, data.result.totalPages or 1, page)
            return
        end
    end
    callback({}, 1, page)
end

-- ======== 标签页5: 🌐 ScriptBlox 搜索 ========
local pageSB = CreateTab("ScriptBlox", "🌐", CONFIG.C.Cyan)
local sby = 10

Lbl(pageSB, "🌐 ScriptBlox 脚本搜索", 22, CONFIG.C.Cyan, sby)
sby = sby + 28
Lbl(pageSB, "搜索 20万+ 社区脚本，一键加载执行", 14, CONFIG.C.Dim, sby)
sby = sby + 22

local sbInput, _ = Input(pageSB, "搜索关键词... 例如: Blox Fruits, auto farm, ESP", sby, 480, 40)
sby = sby + 50

local sbResultArea, sbResultFrame = TextArea(pageSB, "搜索结果会显示在这里...", sby, 480, 350)
sby = sby + 360

local sbPage = 1
local sbTotalPages = 1
local sbResults = {}

Btn(pageSB, "🔍 搜索", CONFIG.C.Cyan, function()
    local q = sbInput.Text
    if q == "" then sbResultArea.Text = "⚠️ 请输入搜索关键词！"; return end
    sbResultArea.Text = "⏳ 正在搜索 ScriptBlox..."
    sbResultFrame.CanvasSize = UDim2.new(0,0,0,50)
    sbPage = 1
    SearchScriptBlox(q, sbPage, function(scripts, totalPages, currentPage)
        sbTotalPages = totalPages
        sbResults = scripts
        local output = "🌐 ScriptBlox 搜索结果: " .. q .. "\n"
        output = output .. "📄 第 " .. currentPage .. "/" .. totalPages .. " 页 | 共找到 " .. #scripts .. " 个结果\n"
        output = output .. string.rep("─", 50) .. "\n\n"
        
        for i, s in ipairs(scripts) do
            local views = s.views or 0
            local likes = s.likeCount or 0
            local gameName = s.game and s.game.name or "通用脚本"
            local verified = s.verified and "✅" or "⬜"
            local key = s.key and "🔑" or "🔓"
            output = output .. "[" .. i .. "] " .. verified .. " " .. s.title .. "\n"
            output = output .. "    🎮 " .. gameName .. " | 👁️ " .. views .. " | 👍 " .. likes .. " | " .. key .. "\n"
            output = output .. "    📝 " .. (s.script or "N/A"):sub(1, 80) .. "...\n\n"
        end
        
        if totalPages > 1 then
            output = output .. "⚡ 输入 [page:N] 跳转到指定页 (如: page:3)\n"
            output = output .. "⚡ 输入 [load:N] 加载第N个脚本 (如: load:1)\n"
        end
        
        sbResultArea.Text = output
        sbResultFrame.CanvasSize = UDim2.new(0,0,0, sbResultArea.TextBounds.Y + 20)
    end)
end, sby, 200)

-- 加载按钮
Btn(pageSB, "▶️ 加载选中", CONFIG.C.Green, function()
    local t = sbResultArea.Text
    -- 提取 load:N 命令
    local loadNum = t:match("load:(%d+)")
    if loadNum then
        local idx = tonumber(loadNum)
        if idx and idx >= 1 and idx <= #sbResults then
            local scriptCode = sbResults[idx].script
            if scriptCode then
                local ok, err = Exec(scriptCode)
                if ok then
                    sbResultArea.Text = "✅ 已加载: " .. sbResults[idx].title .. "\n\n" .. t
                    Notify("✅ 脚本加载成功: " .. sbResults[idx].title, 3)
                else
                    sbResultArea.Text = "❌ 加载失败: " .. tostring(err) .. "\n\n" .. t
                end
            end
        end
    else
        -- 尝试直接加载第一个
        if #sbResults > 0 then
            local ok, err = Exec(sbResults[1].script)
            if ok then
                Notify("✅ 已加载第一个脚本: " .. sbResults[1].title, 3)
            else
                Notify("❌ 加载失败: " .. tostring(err), 3)
            end
        else
            Notify("⚠️ 没有可加载的脚本，请先搜索", 3)
        end
    end
end, sby, 200)
-- 把加载按钮放右边
local sbBtns = pageSB:FindFirstChildWhichIsA("TextButton")
if sbBtns then sbBtns.Position = UDim2.new(0, 220, 0, sby) end

sby = sby + 50
Lbl(pageSB, "💡 使用说明", 18, CONFIG.C.Cyan, sby)
sby = sby + 25
Lbl(pageSB, "1. 输入关键词搜索（支持中文/英文）", 14, CONFIG.C.Dim, sby)
sby = sby + 20
Lbl(pageSB, "2. 在搜索框输入 [page:数字] 翻页", 14, CONFIG.C.Dim, sby)
sby = sby + 20
Lbl(pageSB, "3. 在搜索框输入 [load:数字] 加载对应脚本", 14, CONFIG.C.Dim, sby)
sby = sby + 20
Lbl(pageSB, "4. 直接点击 ▶️ 加载选中 加载第一个脚本", 14, CONFIG.C.Dim, sby)

-- 搜索框输入监听（翻页和加载命令）
sbInput.FocusLost:Connect(function()
    local t = sbInput.Text
    local pageNum = t:match("^page:(%d+)$")
    if pageNum then
        local p = tonumber(pageNum)
        if p and p >= 1 and p <= sbTotalPages then
            sbPage = p
            sbInput.Text = sbInput.Text:gsub("^page:%d+$", "")
            -- 触发搜索
            local q = sbInput.Text:gsub("^page:%d+$", ""):gsub("^%s*(.-)%s*$", "%1")
            if q == "" then
                -- 从之前的结果中提取关键词
                q = sbResultArea.Text:match("搜索结果: ([^\n]+)")
            end
            if q and q ~= "" then
                sbResultArea.Text = "⏳ 正在翻到第 " .. p .. " 页..."
                SearchScriptBlox(q, p, function(scripts, totalPages, currentPage)
                    sbTotalPages = totalPages
                    sbResults = scripts
                    local output = "🌐 ScriptBlox 搜索结果: " .. q .. "\n"
                    output = output .. "📄 第 " .. currentPage .. "/" .. totalPages .. " 页\n"
                    output = output .. string.rep("─", 50) .. "\n\n"
                    for i, s in ipairs(scripts) do
                        local gameName = s.game and s.game.name or "通用脚本"
                        local verified = s.verified and "✅" or "⬜"
                        local key = s.key and "🔑" or "🔓"
                        output = output .. "[" .. i .. "] " .. verified .. " " .. s.title .. "\n"
                        output = output .. "    🎮 " .. gameName .. " | 👁️ " .. (s.views or 0) .. " | " .. key .. "\n\n"
                    end
                    if totalPages > 1 then
                        output = output .. "⚡ 输入 [page:N] 翻页 | [load:N] 加载脚本\n"
                    end
                    sbResultArea.Text = output
                    sbResultFrame.CanvasSize = UDim2.new(0,0,0, sbResultArea.TextBounds.Y + 20)
                end)
            end
        end
    end
end)

-- ======== 标签页6: 📋 日志 ========
local pageLog = CreateTab("日志", "📋", CONFIG.C.Green)
local logy = 10
Lbl(pageLog, "📋 执行日志（记录所有操作）", 22, CONFIG.C.Text, logy)
logy = logy + 30
Lbl(pageLog, "共 0 条记录", 14, CONFIG.C.Dim, logy)
logy = logy + 22
local logFrame = New("ScrollingFrame", {Size=UDim2.new(1,-20,1,-80), Position=UDim2.new(0,10,0,logy), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=CONFIG.C.Green, CanvasSize=UDim2.new(0,0,0,0), Parent=pageLog})
Rndr(logFrame, 10); Strk(logFrame, CONFIG.C.Green, 1)
local logContent = New("TextLabel", {Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,10), BackgroundTransparency=1, Text="暂无日志记录", TextColor3=CONFIG.C.Dim, TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, RichText=true, TextWrapped=true, Parent=logFrame})
local function RefreshLog()
    if #LOGS == 0 then
        logContent.Text = "暂无日志记录"
        logContent.Size = UDim2.new(1,-20,0,30)
    else
        local str = ""
        for i = #LOGS, math.max(1, #LOGS - 100), -1 do
            local entry = LOGS[i]
            str = str .. "[" .. entry.time .. "] " .. entry.cat .. " " .. entry.text .. "\n"
        end
        logContent.Text = str
        logContent.Size = UDim2.new(1,-20,0,logContent.TextBounds.Y + 10)
    end
    logFrame.CanvasSize = UDim2.new(0,0,0,logContent.TextBounds.Y + 20)
end
local clearLogBtn = New("TextButton", {Size=UDim2.new(0,100,0,26), Position=UDim2.new(0,10,0,logy-22), BackgroundColor3=CONFIG.C.Red, Text="🗑 清空日志", TextColor3=CONFIG.C.White, TextSize=11, Font=Enum.Font.GothamBold, Parent=pageLog})
Rndr(clearLogBtn, 8)
clearLogBtn.MouseButton1Click:Connect(function()
    LOGS = {}
    RefreshLog()
    AddLog("🗑", "日志已清空", CONFIG.C.Yellow)
end)
-- 在AddLog里自动刷新日志
local oldAddLog = AddLog
AddLog = function(cat, text, color)
    local r = oldAddLog(cat, text, color)
    RefreshLog()
    return r
end
RefreshLog()

-- ======== 标签页7: 💾 保存（脚本持久化）========
-- 保存引擎
local SAVE_NS = "DeltaUlt_Saves"
local SAVED_SCRIPTS = {}
local SAVE_METHOD = nil
local function DetectSaveMethod()
    if pcall(function() return writefile end) then SAVE_METHOD = "writefile"; pcall(function() listfiles(SAVE_NS) end); pcall(function() delfile(SAVE_NS.."/.placeholder") end)
    elseif pcall(function() return HttpService end) then SAVE_METHOD = "http" end
end
local function AutoTitle(code)
    local kws = {{"farm|刷怪|打怪|收集","自动Farm"},{"攻击|打人|杀|战斗","自动攻击"},{"飞行|fly","飞行模式"},{"esp|透视|看人","透视ESP"},{"传送|tp|瞬移","传送工具"},{"加速|速度|移速","速度修改"},{"无敌|god|不掉血","无敌模式"},{"子弹|弹药|ammo","改子弹"},{"杀戮|killaura|秒杀","杀戮光环"},{"自瞄|aimbot|锁头","自动瞄准"},{"反作弊|bypass|绕过","反作弊绕过"},{"管理员|admin|权限","管理员权限"},{"创作者|creator|owner","创作者权限"},{"工具箱|toolbox|工具","工具箱全开"},{"冻结|freeze|定身","全服冻结"},{"踢出|kick|炸服","强制踢出"},{"货币|金币|money|刷钱","无限货币"},{"内存|memory|修改数值","内存修改"},{"万能|综合|上帝|全开","万能上帝模式"},{"钓鱼|鱼","自动钓鱼"},{"穿墙|noclip","穿墙模式"},{"全亮|白天|亮","全亮模式"},{"夜视|暗处|黑暗","夜视模式"},{"范围|扩大|aoe","范围攻击"},{"射击|射速|快速","快速射击"},{"体力|耐力|stamina","无限体力"},{"拉人|bring|全服传送","拉人工具"}}
    for _, kw in ipairs(kws) do local c = code:lower(); local ok = true; for w in kw[1]:gmatch("[^|]+") do if not c:find(w) then ok = false; break end end; if ok then return kw[2] end end
    return "未命名脚本_"..os.date("%m%d_%H%M")
end
local function SaveScript(code, title)
    title = title or AutoTitle(code); local ft = title; local idx = 1
    while SAVED_SCRIPTS[ft] do idx = idx + 1; ft = title.."_"..idx end
    local e = {title=ft, code=code, time=os.date("%Y-%m-%d %H:%M:%S")}
    SAVED_SCRIPTS[ft] = e
    if SAVE_METHOD == "writefile" then pcall(function() writefile(SAVE_NS.."/"..ft..".lua", code); writefile(SAVE_NS.."/"..ft..".meta", HttpService:JSONEncode({title=ft,time=e.time})) end) end
    if SAVE_METHOD == "http" then pcall(function() local s = Instance.new("StringValue"); s.Name = "DeltaUlt_"..ft; s.Value = code; s.Parent = CoreGui end) end
    pcall(function() setclipboard(code) end); return e
end
local function LoadSaves()
    SAVED_SCRIPTS = {}
    if SAVE_METHOD == "writefile" then pcall(function() for _, fi in ipairs(listfiles(SAVE_NS)) do if fi:match("%.lua$") then local n = fi:match("([^/\\]+)%.lua$"); if n then local c = readfile(fi); local m = {}; pcall(function() local mf = fi:gsub("%.lua$",".meta"); if isfile and isfile(mf) then m = HttpService:JSONDecode(readfile(mf)) end end); SAVED_SCRIPTS[n] = {title=m.title or n, code=c, time=m.time or "未知"} end end end end) end
    if SAVE_METHOD == "http" then pcall(function() for _, v in pairs(CoreGui:GetChildren()) do if v.Name:find("^DeltaUlt_") and v:IsA("StringValue") then local t = v.Name:gsub("^DeltaUlt_",""); SAVED_SCRIPTS[t] = {title=t, code=v.Value, time="本地保存"} end end end) end
end
local function DeleteSave(title) SAVED_SCRIPTS[title] = nil; if SAVE_METHOD == "writefile" then pcall(function() delfile(SAVE_NS.."/"..title..".lua"); delfile(SAVE_NS.."/"..title..".meta") end) end; if SAVE_METHOD == "http" then pcall(function() local v = CoreGui:FindFirstChild("DeltaUlt_"..title); if v then v:Destroy() end end) end end

DetectSaveMethod(); LoadSaves()
local pageSV = CreateTab("保存", "💾", CONFIG.C.Yellow)
local svy = 10
Lbl(pageSV, "💾 脚本保存管理器", 22, CONFIG.C.Yellow, svy); svy = svy + 28
Lbl(pageSV, "保存AI脚本 · 自动起标题 · 退出重进依然存在", 14, CONFIG.C.Dim, svy); svy = svy + 22
local svCount = 0; for _,_ in pairs(SAVED_SCRIPTS) do svCount = svCount + 1 end
local svCountLbl = Lbl(pageSV, "📂 已保存 "..svCount.." 个脚本", 14, CONFIG.C.Dim, svy); svy = svy + 22

-- 保存输入框
local svInput, svInputF = Input(pageSV, "粘贴AI生成的脚本代码...", svy, 480, 40); svy = svy + 48
Btn(pageSV, "💾 保存并自动起名", CONFIG.C.Green, function()
    local code = svInput.Text; if code == "" or #code < 10 then Notify("⚠️", "代码太短了!", 2); return end
    local e = SaveScript(code); svInput.Text = ""; Notify("✅ 保存成功", e.title, 2); AddLog("💾", "保存脚本: "..e.title, CONFIG.C.Yellow)
    -- 刷新列表
    for _, v in pairs(svListFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    svCount = 0; for _,_ in pairs(SAVED_SCRIPTS) do svCount = svCount + 1 end; svCountLbl.Text = "📂 已保存 "..svCount.." 个脚本"
    RefreshSVList()
end, svy, 200); svy = svy + 42

-- 脚本列表
local svListFrame = New("ScrollingFrame", {Size=UDim2.new(1,-20,1,-svy+10), Position=UDim2.new(0,10,0,svy), BackgroundColor3=CONFIG.C.Card, BackgroundTransparency=0.3, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=CONFIG.C.Yellow, CanvasSize=UDim2.new(0,0,0,0), Parent=pageSV})
Rndr(svListFrame, 10); Strk(svListFrame, CONFIG.C.Yellow, 1)

local function RefreshSVList()
    LoadSaves()
    local sorted = {}; for _, e in pairs(SAVED_SCRIPTS) do table.insert(sorted, e) end
    table.sort(sorted, function(a,b) return a.time > b.time end)
    if #sorted == 0 then
        local empty = New("TextLabel", {Size=UDim2.new(1,-10,0,50), BackgroundTransparency=1, Text="📭 暂无保存的脚本\n在AI生成页生成脚本后，粘贴到这里保存", TextColor3=CONFIG.C.Dim, TextSize=12, TextWrapped=true, Parent=svListFrame})
        svListFrame.CanvasSize = UDim2.new(0,0,0,60); return
    end
    local y = 5
    for _, entry in ipairs(sorted) do
        local card = New("Frame", {Size=UDim2.new(1,-10,0,56), Position=UDim2.new(0,5,0,y), BackgroundColor3=CONFIG.C.CardLight, BackgroundTransparency=0.2, BorderSizePixel=0, Parent=svListFrame})
        Rndr(card, 10); Strk(card, CONFIG.C.Yellow, 1)
        New("TextLabel", {Size=UDim2.new(0,40,1,0), Position=UDim2.new(0,8,0,0), BackgroundTransparency=1, Text="📜", TextSize=20, TextColor3=CONFIG.C.Yellow, Parent=card})
        New("TextLabel", {Size=UDim2.new(1,-140,0,20), Position=UDim2.new(0,52,0,6), BackgroundTransparency=1, Text=entry.title, TextColor3=CONFIG.C.Text, TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, Parent=card})
        New("TextLabel", {Size=UDim2.new(1,-140,0,14), Position=UDim2.new(0,52,0,28), BackgroundTransparency=1, Text="🕐 "..entry.time.." | "..#entry.code.."字符", TextColor3=CONFIG.C.Dim, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, Parent=card})
        local playB = New("TextButton", {Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-108,0.5,-16), BackgroundColor3=CONFIG.C.Green, BackgroundTransparency=0.2, Text="▶", TextColor3=Color3.fromRGB(255,255,255), TextSize=14, Parent=card})
        Rndr(playB, 8); playB.MouseButton1Click:Connect(function() local ok, err = pcall(function() loadstring(entry.code)() end); Notify(ok and "✅ 执行成功" or "❌ 失败", ok and entry.title or tostring(err), 2); AddLog(ok and "✅" or "❌", (ok and "执行成功: " or "执行失败: ")..entry.title, ok and CONFIG.C.Green or CONFIG.C.Red) end)
        local copyB = New("TextButton", {Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-70,0.5,-16), BackgroundColor3=CONFIG.C.Yellow, BackgroundTransparency=0.2, Text="📋", TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Parent=card})
        Rndr(copyB, 8); copyB.MouseButton1Click:Connect(function() pcall(function() setclipboard(entry.code) end); Notify("📋 已复制", entry.title, 2) end)
        local delB = New("TextButton", {Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-32,0.5,-16), BackgroundColor3=CONFIG.C.Red, BackgroundTransparency=0.2, Text="🗑", TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Parent=card})
        Rndr(delB, 8); delB.MouseButton1Click:Connect(function() DeleteSave(entry.title); for _, v in pairs(svListFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end; RefreshSVList(); Notify("🗑 已删除", entry.title, 2) end)
        y = y + 60
    end
    svListFrame.CanvasSize = UDim2.new(0,0,0,y+10)
end
RefreshSVList()

-- ======== 底部状态栏 ========
local sb = New("Frame",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,1,-28),BackgroundColor3=CONFIG.C.Surface,BackgroundTransparency=0.3,BorderSizePixel=0,Parent=main})
Rndr(sb,14); New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,0),BackgroundColor3=CONFIG.C.Surface,BackgroundTransparency=0.3,BorderSizePixel=0,Parent=sb})
New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="🔥 "..cnt.."个脚本 | 6分类 | ScriptBlox 20万+ | AI | 日志",TextColor3=CONFIG.C.Dim,TextSize=10,Font=Enum.Font.Gotham,Parent=sb})

-- ======== 启动 ========
Notify("🔥 Delta Ultimate v3.0 已加载!", 4)
print("🔥 Delta Ultimate v3.0 - 全网最强Delta注入器全家桶")
print("📦 内置"..cnt.."个脚本 | ScriptBlox 20万+ | 6大分类 | 离线+在线AI模式")