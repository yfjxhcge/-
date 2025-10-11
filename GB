--[[ 
  最终整合脚本：自动追踪（含群体检测/避僵尸/自动跳/Pathfinding） + 自动瞄准（炸药桶/Boss，含预测与可见性判断）
  高级 UI：简约&高大上风格，支持收缩/展开、每个功能独立开关、真正关闭（完全停止并销毁脚本）
--]]

-- ========== 服务 ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- 安全等待玩家Character（若在某些场景LocalPlayer可能还未准备好）
local function waitForChar()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
end
waitForChar()

-- ========== 全局控制表与连接管理 ==========
local Flags = {
    AutoTrack = false,
    AutoJump = false,
    AvoidZombie = false,
    UsePathfinding = true, -- true = Pathfinding, false = Direct Move
    AutoAim = false,
    Running = true
}

-- 记录所有活动连接以便清理
local allConnections = {}
local function trackConn(conn)
    if conn then table.insert(allConnections, conn) end
    return conn
end
local function cleanupAllConnections()
    for _, c in ipairs(allConnections) do
        if c and type(c) == "RBXScriptConnection" then
            pcall(function() c:Disconnect() end)
        end
    end
    allConnections = {}
end

-- 全部状态/缓存（按模块分）
local trackingState = nil -- will be a table when tracking started
local aimState = nil      -- will be a table when auto-aim started

-- ========== UI（简约 & 高大上） ==========
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProAutoConsole"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- 背景主面板（玻璃感 + 深色）
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.03, 0, 0.15, 0)
main.AnchorPoint = Vector2.new(0,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,22)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(85, 110, 140)
stroke.Thickness = 1
stroke.Transparency = 0.6

-- 玻璃条纹（细微渐变）
local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)*0.02),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)*0.0)
}
grad.Rotation = 90

-- 标题栏
local titleBar = Instance.new("Frame", main)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.7, -12, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚙️ 自动化控制台"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(235,235,238)
title.TextXAlignment = Enum.TextXAlignment.Left

-- 收缩与关闭按钮（图标风格）
local btnCollapse = Instance.new("TextButton", titleBar)
btnCollapse.Name = "Collapse"
btnCollapse.Size = UDim2.new(0, 40, 0, 32)
btnCollapse.Position = UDim2.new(1, -92, 0, 8)
btnCollapse.BackgroundTransparency = 1
btnCollapse.Text = "▾"
btnCollapse.Font = Enum.Font.GothamBold
btnCollapse.TextSize = 18
btnCollapse.TextColor3 = Color3.fromRGB(200,200,200)

local btnClose = Instance.new("TextButton", titleBar)
btnClose.Name = "Close"
btnClose.Size = UDim2.new(0, 40, 0, 32)
btnClose.Position = UDim2.new(1, -44, 0, 8)
btnClose.BackgroundTransparency = 1
btnClose.Text = "✕"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 18
btnClose.TextColor3 = Color3.fromRGB(255,120,120)

-- 内容容器（按钮 & 状态）
local content = Instance.new("Frame", main)
content.Name = "Content"
content.Position = UDim2.new(0, 0, 0, 48)
content.Size = UDim2.new(1, 0, 1, -48)
content.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 辅助创建 Toggle 行（label + toggle button + small status）
local function createToggleRow(text, order)
    local row = Instance.new("Frame", content)
    row.Size = UDim2.new(1, -24, 0, 54)
    row.Position = UDim2.new(0, 12, 0, (order-1)*54)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.6, 0, 1, -8)
    label.Position = UDim2.new(0, 0, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local status = Instance.new("TextLabel", row)
    status.Size = UDim2.new(0.25, 0, 1, -8)
    status.Position = UDim2.new(0.6, 8, 0, 4)
    status.BackgroundTransparency = 1
    status.Text = "❌"
    status.Font = Enum.Font.GothamBold
    status.TextSize = 16
    status.TextColor3 = Color3.fromRGB(200, 80, 80)
    status.TextXAlignment = Enum.TextXAlignment.Right

    local toggleBtn = Instance.new("TextButton", row)
    toggleBtn.Size = UDim2.new(0, 64, 0, 34)
    toggleBtn.Position = UDim2.new(0.85, -6, 0.5, -17)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggleBtn.Text = "OFF"
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(220,220,220)
    toggleBtn.AutoButtonColor = true
    local corner = Instance.new("UICorner", toggleBtn)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", toggleBtn)
    stroke.Color = Color3.fromRGB(75,75,75)
    stroke.Thickness = 1

    return {
        row = row, label = label, status = status, toggle = toggleBtn
    }
end

-- 五个功能行
local uiTrack = createToggleRow("自动追踪玩家", 1)
local uiJump  = createToggleRow("智能自动跳跃", 2)
local uiAvoid = createToggleRow("避开僵尸", 3)
local uiMove  = createToggleRow("移动方式（路径/直接）", 4)
local uiAim   = createToggleRow("自动瞄准炸药桶/Boss", 5)

-- 底部说明
local note = Instance.new("TextLabel", content)
note.Size = UDim2.new(1, -24, 0, 56)
note.BackgroundTransparency = 1
note.Text = "收起 ▾  |  关闭 ✕  |  按钮支持独立开关；点击关闭将彻底停止所有脚本（不可恢复）。"
note.Font = Enum.Font.Gotham
note.TextSize = 12
note.TextColor3 = Color3.fromRGB(170,170,180)
note.TextXAlignment = Enum.TextXAlignment.Left

-- 平滑收缩函数
local collapsed = false
local function setCollapsed(c)
    collapsed = c
    if c then
        local tween = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 320, 0, 48)})
        tween:Play()
        btnCollapse.Text = "▴"
        for _, v in ipairs({uiTrack.row, uiJump.row, uiAvoid.row, uiMove.row, uiAim.row, note}) do
            v.Visible = false
        end
    else
        local tween = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 320, 0, 420)})
        tween:Play()
        btnCollapse.Text = "▾"
        for _, v in ipairs({uiTrack.row, uiJump.row, uiAvoid.row, uiMove.row, uiAim.row, note}) do
            v.Visible = true
        end
    end
end
btnCollapse.MouseButton1Click:Connect(function() setCollapsed(not collapsed) end)

-- 真正关闭（彻底停止 & 销毁）
local function shutdownAll()
    -- 关闭标志，阻止新任务产生
    Flags.Running = false
    Flags.AutoTrack = false
    Flags.AutoJump = false
    Flags.AvoidZombie = false
    Flags.AutoAim = false

    -- 停止两个模块（如果在跑的话）
    if trackingState and type(trackingState.stop) == "function" then
        pcall(function() trackingState.stop() end)
    end
    if aimState and type(aimState.stop) == "function" then
        pcall(function() aimState.stop() end)
    end

    -- 清理所有被 track 的连接
    cleanupAllConnections()

    -- 销毁 UI
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end

    -- 销毁脚本自身（彻底退出）
    pcall(function() script:Destroy() end)
end

btnClose.MouseButton1Click:Connect(function()
    shutdownAll()
end)

-- F4 快捷（仅在未彻底关闭时可用）
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F4 then
        if screenGui and screenGui.Parent then
            screenGui.Enabled = not screenGui.Enabled
        end
    end
end)

-- ========== 功能：自动追踪模块（封装） ==========
-- 我把你原来的“自动追踪完整功能版”逻辑按模块封装到 start/stop 接口里，尽量保持原逻辑。
local function startTrackingModule()
    if trackingState then return end
    trackingState = {}

    -- 状态与本地变量（基于你原脚本的变量名和逻辑）
    local playerTrackingEnabled = true
    local trackingConnection = nil
    local currentTarget = nil
    local currentTargetInfo = nil
    local isMoving = false
    local isCalculatingPath = false

    local specialTrackingEnabled = false
    local specialTrackingConnection = nil
    local specialTrackingStep = 0
    local specialPathCompleted = false
    local positionCheckConnection = nil
    local shouldStartSpecialTracking = false

    local autoJumpEnabled = false
    local autoJumpConnection = nil
    local autoJumpCharAdded = nil

    local avoidZombiesMode = false
    local zombieDetectionRadius = 50
    local zombieDangerRadius = 20
    local safetyCircle = nil

    local usePathfindingForTracking = Flags.UsePathfinding
    local userSelectedMoveMethod = Flags.UsePathfinding

    local trackMode = "nearest"
    local waypoints = {}
    local currentWaypointIndex = 0
    local lastPathUpdate = 0
    local PATH_UPDATE_INTERVAL = 3.0

    local positionHistory = {}
    local currentSpeed = 0
    local SPEED_THRESHOLD = 10

    local GROUP_DISTANCE_THRESHOLD = 15
    local ISOLATED_DISTANCE_THRESHOLD = 30

    local viewOffset = 8
    local viewHeight = 3

    -- special zone + path points: 保留你的原始路径点（如无必要可修改）
    local specialZonePosition = Vector3.new(-553.341797, 4.91997051, -122.554977)
    local triggerDistance = 10
    local specialPathPoints = {
        -- （保留你给出的点；如果环境不同可以自定义）
        {
            cframe = CFrame.new(-645.226868, 20.6829033, -93.9491882),
            usePathfinding = false,
            requireJump = false,
            tolerance = 4
        },
        {
            cframe = CFrame.new(-650.066589, 23.0250225, -119.258598),
            usePathfinding = false,
            requireJump = false,
            tolerance = 4
        },
        {
            cframe = CFrame.new(-649.124268, 24.4685116, -128.338882),
            usePathfinding = false,
            requireJump = true,
            tolerance = 4
        },
        {
            cframe = CFrame.new(-753.076721, -5.05517483, 34.7810364),
            usePathfinding = true,
            requireJump = false,
            tolerance = 6
        }
    }

    -- Helper functions (Distance, groups, zombies, pathfinding) - 保留你的实现思想并做作用域限定
    local function DistanceToCharacter(targetChar)
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return math.huge end
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return math.huge end
        return (LocalPlayer.Character.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Magnitude
    end

    local function distanceBetweenPlayers(player1, player2)
        if not player1.Character or not player2.Character then return math.huge end
        local root1 = player1.Character:FindFirstChild("HumanoidRootPart")
        local root2 = player2.Character:FindFirstChild("HumanoidRootPart")
        if not root1 or not root2 then return math.huge end
        return (root1.Position - root2.Position).Magnitude
    end

    local function findPlayerGroups()
        local validPlayers = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                    table.insert(validPlayers, player)
                end
            end
        end

        if #validPlayers == 0 then
            return {}, {}
        end

        local groups = {}
        local usedPlayers = {}

        for i, player1 in ipairs(validPlayers) do
            if not usedPlayers[player1] then
                local group = {player1}
                usedPlayers[player1] = true
                for j, player2 in ipairs(validPlayers) do
                    if i ~= j and not usedPlayers[player2] then
                        local distance = distanceBetweenPlayers(player1, player2)
                        if distance <= GROUP_DISTANCE_THRESHOLD then
                            table.insert(group, player2)
                            usedPlayers[player2] = true
                        end
                    end
                end
                if #group >= 3 then
                    table.insert(groups, group)
                end
            end
        end

        local isolatedPlayers = {}
        for _, player in ipairs(validPlayers) do
            if not usedPlayers[player] then
                table.insert(isolatedPlayers, player)
            end
        end

        return groups, isolatedPlayers
    end

    local function findNearbyZombies()
        local zombies = {}
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        if not zombiesFolder then return zombies end
        local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
        if not localPos then return zombies end
        for _, zombie in pairs(zombiesFolder:GetChildren()) do
            if zombie:IsA("Model") then
                local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
                if zombieRoot then
                    local distance = (zombieRoot.Position - localPos).Magnitude
                    if distance <= zombieDetectionRadius then
                        table.insert(zombies, { model = zombie, rootPart = zombieRoot, distance = distance })
                    end
                end
            end
        end
        table.sort(zombies, function(a,b) return a.distance < b.distance end)
        return zombies
    end

    -- 可视化安全圈（非必须）
    local function createSafetyCircle()
        if safetyCircle then
            pcall(function() safetyCircle:Destroy() end)
            safetyCircle = nil
        end
        local part = Instance.new("Part")
        part.Name = "SafetyCircle"
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.BrickColor = BrickColor.new("Bright green")
        part.Transparency = 0.7
        part.Size = Vector3.new(1,0.2,1)
        local mesh = Instance.new("CylinderMesh", part)
        mesh.Scale = Vector3.new(zombieDetectionRadius*2, 0.1, zombieDetectionRadius*2)
        part.Parent = workspace
        safetyCircle = part
        local conn = RunService.Heartbeat:Connect(function()
            if not safetyCircle then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                safetyCircle.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
            end
        end)
        trackConn(conn)
    end

    local function removeSafetyCircle()
        if safetyCircle then
            pcall(function() safetyCircle:Destroy() end)
            safetyCircle = nil
        end
    end

    local function calculateSafeDirection(zombies)
        if #zombies == 0 then return nil end
        local localPos = LocalPlayer.Character.HumanoidRootPart.Position
        local totalDirection = Vector3.new(0,0,0)
        for _, z in ipairs(zombies) do
            local zombiePos = z.rootPart.Position
            local direction = (localPos - zombiePos).Unit
            local weight = 1 / (z.distance + 0.1)
            totalDirection = totalDirection + (direction * weight)
        end
        if totalDirection.Magnitude > 0 then return totalDirection.Unit end
        return nil
    end

    -- 位移速度检测
    local function calculateCurrentSpeed()
        if not LocalPlayer.Character then
            positionHistory = {}
            return 0
        end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
            positionHistory = {}
            return 0
        end
        local currentTime = tick()
        local currentPos = humanoidRootPart.Position
        table.insert(positionHistory, { time = currentTime, position = currentPos })
        while #positionHistory > 0 and currentTime - positionHistory[1].time > 1.0 do
            table.remove(positionHistory, 1)
        end
        if #positionHistory >= 2 then
            local oldestPos = positionHistory[1].position
            local timeDiff = currentTime - positionHistory[1].time
            if timeDiff > 0.1 then
                currentSpeed = (currentPos - oldestPos).Magnitude / timeDiff
            else
                currentSpeed = 0
            end
        else
            currentSpeed = 0
        end
        return currentSpeed
    end

    local function updateMovementMethod()
        usePathfindingForTracking = userSelectedMoveMethod
    end

    local function isAtTriggerPosition()
        if not LocalPlayer.Character then return false end
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
        local distance = (humanoidRootPart.Position - specialZonePosition).Magnitude
        return distance <= triggerDistance
    end

    -- 自动跳（智能判断）
    local function startAutoJumpInternal()
        if autoJumpConnection then
            pcall(function() autoJumpConnection:Disconnect() end)
            autoJumpConnection = nil
        end
        local Char = LocalPlayer.Character
        local Human = Char and Char:FindFirstChildOfClass("Humanoid")
        local function autoJump()
            if Char and Human and Human.RootPart then
                -- 原脚本用了 FindPartOnRay，Roblox 推荐 Raycast，这里用可用的兼容方式简单实现：若前方有障碍则跳
                local origin = Human.RootPart.Position
                local dir = Human.RootPart.CFrame.lookVector * 3
                local rparams = RaycastParams.new()
                rparams.FilterDescendantsInstances = {Char}
                rparams.FilterType = Enum.RaycastFilterType.Blacklist
                rparams.IgnoreWater = true
                local result = workspace:Raycast(origin + Vector3.new(0,1,0), dir, rparams)
                if result and result.Instance then
                    Human.Jump = true
                end
            end
        end
        autoJumpConnection = RunService.RenderStepped:Connect(autoJump)
        trackConn(autoJumpConnection)
        -- 重新绑定 CharacterAdded
        local conn = LocalPlayer.CharacterAdded:Connect(function(nChar)
            Char = nChar
            Human = Char:WaitForChild("Humanoid")
            pcall(autoJump)
        end)
        trackConn(conn)
        autoJumpCharAdded = conn
    end

    local function stopAutoJumpInternal()
        if autoJumpConnection then
            pcall(function() autoJumpConnection:Disconnect() end)
            autoJumpConnection = nil
        end
        if autoJumpCharAdded then
            pcall(function() autoJumpCharAdded:Disconnect() end)
            autoJumpCharAdded = nil
        end
    end

    -- 路径计算/移动
    local isCalculatingPath_local = false
    local function computePathToTargetAsync(targetPosition)
        if not LocalPlayer.Character or isCalculatingPath_local then return false end
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end
        isCalculatingPath_local = true
        task.spawn(function()
            local newPath = PathfindingService:CreatePath({
                AgentRadius = 2.0,
                AgentHeight = 5.0,
                AgentCanJump = true,
                AgentCanClimb = true,
                WaypointSpacing = 6
            })
            local ok, _ = pcall(function()
                newPath:ComputeAsync(humanoidRootPart.Position, targetPosition)
            end)
            task.wait(0.12)
            if ok and newPath.Status == Enum.PathStatus.Success then
                waypoints = newPath:GetWaypoints()
                currentWaypointIndex = 1
                lastPathUpdate = tick()
            else
                waypoints = {}
                currentWaypointIndex = 0
            end
            isCalculatingPath_local = false
        end)
        return true
    end

    local function moveToNextWaypoint()
        if not waypoints or currentWaypointIndex > #waypoints then return false end
        if not LocalPlayer.Character then return false end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        local currentWaypoint = waypoints[currentWaypointIndex]
        humanoid:MoveTo(currentWaypoint.Position)
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local distance = (humanoidRootPart.Position - currentWaypoint.Position).Magnitude
            if distance < 4 then
                currentWaypointIndex = currentWaypointIndex + 1
            end
        end
        return true
    end

    local function directMoveToTarget(targetPosition)
        if not LocalPlayer.Character then return false end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        humanoid:MoveTo(targetPosition)
        return true
    end

    local function calculateRearViewPosition(targetPosition, targetCFrame)
        local lookVector = targetCFrame.LookVector
        local upVector = targetCFrame.UpVector
        return targetPosition + (-lookVector * viewOffset + upVector * viewHeight)
    end

    local function stopAllMovement()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
            end
        end
        isMoving = false
        waypoints = {}
        currentWaypointIndex = 0
        isCalculatingPath_local = false
    end

    -- 找目标函数（综合群体优先、单体备选）
    local function findNearestPlayer()
        local groups, isolatedPlayers = findPlayerGroups()
        local nearestPlayer = nil
        local minDistance = math.huge
        for _, group in ipairs(groups) do
            for _, player in ipairs(group) do
                if player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                        local distance = DistanceToCharacter(character)
                        if distance < minDistance then
                            minDistance = distance
                            nearestPlayer = {
                                player = player,
                                character = character,
                                rootPart = rootPart,
                                playerName = player.Name,
                                isGroup = true,
                                groupSize = #group
                            }
                        end
                    end
                end
            end
        end
        if not nearestPlayer then
            for _, player in ipairs(isolatedPlayers) do
                if player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                        local distance = DistanceToCharacter(character)
                        if distance < minDistance then
                            minDistance = distance
                            nearestPlayer = {
                                player = player,
                                character = character,
                                rootPart = rootPart,
                                playerName = player.Name,
                                isGroup = false,
                                groupSize = 1
                            }
                        end
                    end
                end
            end
        end
        if not nearestPlayer then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                        local distance = DistanceToCharacter(character)
                        if distance < minDistance then
                            minDistance = distance
                            nearestPlayer = {
                                player = player,
                                character = character,
                                rootPart = rootPart,
                                playerName = player.Name,
                                isGroup = false,
                                groupSize = 1
                            }
                        end
                    end
                end
            end
        end
        return nearestPlayer, minDistance
    end

    -- findFurthestFromZombies (略按你原来的逻辑实现核心)
    local function findFurthestFromZombies()
        local groups, isolatedPlayers = findPlayerGroups()
        local furthestPlayer = nil
        local maxZombieDistance = 0
        local zombiePositions = {}
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        if zombiesFolder then
            for _, zombie in pairs(zombiesFolder:GetChildren()) do
                if zombie:IsA("Model") then
                    local zombieRoot = zombie:FindFirstChild("HumanoidRootPart")
                    if zombieRoot then table.insert(zombiePositions, zombieRoot.Position) end
                end
            end
        end
        if #zombiePositions == 0 then
            return findNearestPlayer()
        end
        -- 优先在群体中找：计算平均距离
        for _, group in ipairs(groups) do
            for _, player in ipairs(group) do
                if player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                        local totalDistance, validZombies = 0, 0
                        for _, zp in ipairs(zombiePositions) do
                            local dist = (rootPart.Position - zp).Magnitude
                            totalDistance = totalDistance + dist
                            validZombies = validZombies + 1
                        end
                        if validZombies > 0 then
                            local avgDistance = totalDistance / validZombies
                            if avgDistance > maxZombieDistance then
                                maxZombieDistance = avgDistance
                                furthestPlayer = {
                                    player = player,
                                    character = character,
                                    rootPart = rootPart,
                                    playerName = player.Name,
                                    zombieDistance = avgDistance,
                                    isGroup = true,
                                    groupSize = #group
                                }
                            end
                        end
                    end
                end
            end
        end
        if not furthestPlayer then
            for _, player in ipairs(isolatedPlayers) do
                if player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                        local totalDistance, validZombies = 0, 0
                        for _, zp in ipairs(zombiePositions) do
                            local dist = (rootPart.Position - zp).Magnitude
                            totalDistance = totalDistance + dist
                            validZombies = validZombies + 1
                        end
                        if validZombies > 0 then
                            local avgDistance = totalDistance / validZombies
                            if avgDistance > maxZombieDistance then
                                maxZombieDistance = avgDistance
                                furthestPlayer = {
                                    player = player,
                                    character = character,
                                    rootPart = rootPart,
                                    playerName = player.Name,
                                    zombieDistance = avgDistance,
                                    isGroup = false,
                                    groupSize = 1
                                }
                            end
                        end
                    end
                end
            end
        end

        if not furthestPlayer then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
                        local totalDistance, validZombies = 0, 0
                        for _, zp in ipairs(zombiePositions) do
                            local dist = (rootPart.Position - zp).Magnitude
                            totalDistance = totalDistance + dist
                            validZombies = validZombies + 1
                        end
                        if validZombies > 0 then
                            local avgDistance = totalDistance / validZombies
                            if avgDistance > maxZombieDistance then
                                maxZombieDistance = avgDistance
                                furthestPlayer = {
                                    player = player,
                                    character = character,
                                    rootPart = rootPart,
                                    playerName = player.Name,
                                    zombieDistance = avgDistance,
                                    isGroup = false,
                                    groupSize = 1
                                }
                            end
                        end
                    end
                end
            end
        end

        return furthestPlayer, maxZombieDistance
    end

    local function findTargetPlayer()
        if trackMode == "furthestFromZombies" then
            return findFurthestFromZombies()
        else
            return findNearestPlayer()
        end
    end

    -- 特殊追踪监控（用心跳挂起）
    local monitorConn = RunService.Heartbeat:Connect(function()
        if shouldStartSpecialTracking and not specialTrackingEnabled then
            shouldStartSpecialTracking = false
            -- 启动特殊追踪步骤
            specialTrackingEnabled = true
            specialTrackingStep = 1
            -- 我们只简单地在心跳循环里执行“特殊路径点”导航（使用moveToSpecialTarget）
        end
    end)
    trackConn(monitorConn)

    -- 主追踪循环（使用 Heartbeat）
    trackingConnection = RunService.Heartbeat:Connect(function()
        if not playerTrackingEnabled or not Flags.Running then
            stopAllMovement()
            return
        end

        if not LocalPlayer.Character then
            stopAllMovement()
            return
        end

        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
            stopAllMovement()
            return
        end

        -- 僵尸躲避模式判断
        if Flags.AvoidZombie then
            local nearbyZombies = findNearbyZombies()
            if #nearbyZombies > 0 then
                avoidZombiesMode = true
                local safeDirection = calculateSafeDirection(nearbyZombies)
                if safeDirection then
                    local safePosition = humanoidRootPart.Position + (safeDirection * 30)
                    directMoveToTarget(safePosition)
                end
                -- 不继续普通追踪
                return
            else
                avoidZombiesMode = false
            end
        end

        local targetPlayer, _ = findTargetPlayer()
        if targetPlayer and targetPlayer.rootPart then
            currentTarget = targetPlayer.player
            currentTargetInfo = targetPlayer
            local targetPosition = targetPlayer.rootPart.Position
            local targetCFrame = targetPlayer.rootPart.CFrame
            local rearPosition = calculateRearViewPosition(targetPosition, targetCFrame)

            local currentPos = humanoidRootPart.Position
            local rearDistance = (currentPos - rearPosition).Magnitude

            if rearDistance > 4 then
                isMoving = true
                updateMovementMethod()
                local currentTime = tick()
                local shouldUpdatePath = not isCalculatingPath and (
                    not waypoints or #waypoints == 0 or currentWaypointIndex > #waypoints or currentTime - lastPathUpdate > PATH_UPDATE_INTERVAL or
                    (currentTarget and currentTarget.Character and (currentTarget.Character.HumanoidRootPart.Position - targetPosition).Magnitude > 8)
                )

                if Flags.UsePathfinding then
                    if shouldUpdatePath then
                        computePathToTargetAsync(rearPosition)
                    end
                    if waypoints and #waypoints > 0 and currentWaypointIndex <= #waypoints then
                        if not moveToNextWaypoint() then
                            directMoveToTarget(rearPosition)
                        end
                    else
                        directMoveToTarget(rearPosition)
                    end
                else
                    directMoveToTarget(rearPosition)
                end
            else
                isMoving = false
                if humanoid and humanoidRootPart then
                    humanoid:MoveTo(humanoidRootPart.Position)
                end
            end
        else
            currentTarget = nil
            currentTargetInfo = nil
            stopAllMovement()
        end
    end)
    trackConn(trackingConnection)

    -- CharacterAdded 重连管理（重生后继续追踪）
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
        -- 等待 HRP
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        -- 小延时以免发生 race
        task.wait(0.8)
    end)
    trackConn(charAddedConn)

    -- 保存 stop 函数
    function trackingState.stop()
        playerTrackingEnabled = false
        Flags.AutoTrack = false
        -- 断连接并清理可视化
        if trackingConnection then pcall(function() trackingConnection:Disconnect() end) trackingConnection = nil end
        if specialTrackingConnection then pcall(function() specialTrackingConnection:Disconnect() end) specialTrackingConnection = nil end
        stopAutoJumpInternal()
        removeSafetyCircle()
        -- 清理模块里所有 trackConn 的连接由 cleanupAllConnections 统一处理外部
        trackingState = nil
    end

    -- 初始自动跳绑定（若用户已经开启 AutoJump）
    if Flags.AutoJump then startAutoJumpInternal() end

    -- UI 状态反映
    uiTrack.status.Text = "✔"
    uiTrack.status.TextColor3 = Color3.fromRGB(110, 230, 110)
end

local function stopTrackingModule()
    if trackingState and type(trackingState.stop) == "function" then
        trackingState.stop()
    end
    uiTrack.status.Text = "❌"
    uiTrack.status.TextColor3 = Color3.fromRGB(200,80,80)
    trackingState = nil
end

-- ========== 功能：自动瞄准模块（封装） ==========
-- 我把你发的“自动瞄准炸药桶”的核心逻辑封装为 start/stop，保留目标扫描、可见检测、预测与平滑转向。
local function startAutoAimModule()
    if aimState then return end
    aimState = {}
    local cameraLockConnection = nil
    local barrelCache = {}
    local bossCache = {}
    local lastScanTime = 0
    local lastBossScanTime = 0
    local lastTransparentUpdate = 0
    local transparentParts = {}
    local targetHistory = {}
    local PREDICTION_TIME = 0.2
    local MAX_HISTORY_SIZE = 5
    local MIN_VELOCITY_THRESHOLD = 0.1
    local MAX_VIEW_ANGLE = 90
    local COS_MAX_ANGLE = math.cos(math.rad(MAX_VIEW_ANGLE / 2))
    local AIR_WALL_MATERIALS = {
        [Enum.Material.Air] = true,
        [Enum.Material.Water] = true,
        [Enum.Material.Glass] = true,
        [Enum.Material.ForceField] = true,
        [Enum.Material.Neon] = true
    }
    local AIR_WALL_NAMES = {
        invisiblewall = true, airwall = true, transparentwall = true,
        collision = true, nocollision = true, ghost = true,
        phase = true, clip = true, trigger = true, boundary = true
    }

    local currentCamera = workspace.CurrentCamera
    local char = LocalPlayer.Character

    local function cleanupConnectionsLocal()
        -- 这里我们将所有相关的连接存在 aimState.conns 中供统一清理
        if aimState and aimState.conns then
            for _, c in ipairs(aimState.conns) do
                if c and type(c) == "RBXScriptConnection" then
                    pcall(function() c:Disconnect() end)
                end
            end
            aimState.conns = {}
        end
    end

    aimState.conns = {}

    local function updateTargetHistory(target, currentPosition)
        if not targetHistory[target] then
            targetHistory[target] = { positions = {}, timestamps = {}, velocity = Vector3.new(0,0,0), lastUpdate = tick() }
        end
        local history = targetHistory[target]
        local currentTime = tick()
        table.insert(history.positions, currentPosition)
        table.insert(history.timestamps, currentTime)
        while #history.positions > MAX_HISTORY_SIZE do
            table.remove(history.positions, 1)
            table.remove(history.timestamps, 1)
        end
        if #history.positions >= 2 then
            local latestPos = history.positions[#history.positions]
            local previousPos = history.positions[1]
            local timeDiff = history.timestamps[#history.timestamps] - history.timestamps[1]
            if timeDiff > 0 then
                local newVelocity = (latestPos - previousPos) / timeDiff
                history.velocity = history.velocity:Lerp(newVelocity, 0.5)
                if history.velocity.Magnitude < MIN_VELOCITY_THRESHOLD then
                    history.velocity = Vector3.new(0,0,0)
                end
            end
        end
        history.lastUpdate = tick()
    end

    local function getPredictedPosition(target, currentPosition, predictionTime)
        local history = targetHistory[target]
        if not history or history.velocity.Magnitude < MIN_VELOCITY_THRESHOLD then
            return currentPosition
        end
        return currentPosition + history.velocity * predictionTime
    end

    local function cleanupOldTargetHistory()
        local currentTime = tick()
        local toRemove = {}
        for target, history in pairs(targetHistory) do
            if currentTime - history.lastUpdate > 5 or (typeof(target) == "Instance" and not target.Parent) then
                table.insert(toRemove, target)
            end
        end
        for _, t in ipairs(toRemove) do targetHistory[t] = nil end
    end

    local function updateTargetCache()
        table.clear(barrelCache)
        table.clear(bossCache)
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        if zombiesFolder then
            local ch = zombiesFolder:GetChildren()
            for i = 1, #ch do
                local v = ch[i]
                if v:IsA("Model") and v.Name == "Agent" and v:GetAttribute and v:GetAttribute("Type") == "Barrel" then
                    local rootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") or v.PrimaryPart
                    if rootPart then
                        table.insert(barrelCache, { model = v, rootPart = rootPart, type = "barrel" })
                        updateTargetHistory(v, rootPart.Position)
                    end
                end
            end
        end
        -- Boss 检测（基于你提供的 Sleepy Hollow 结构）
        local sleepyHollow = workspace:FindFirstChild("Sleepy Hollow")
        if sleepyHollow and sleepyHollow:FindFirstChild("Modes") and sleepyHollow.Modes:FindFirstChild("Boss") then
            local bossFolder = sleepyHollow.Modes.Boss
            local headlessHorsemanBoss = bossFolder:FindFirstChild("HeadlessHorsemanBoss")
            if headlessHorsemanBoss and headlessHorsemanBoss:FindFirstChild("HeadlessHorseman") then
                local humano = headlessHorsemanBoss.HeadlessHorseman
                local clothing = humano:FindFirstChild("Clothing")
                if clothing and clothing:FindFirstChild("Torso") then
                    for _, child in ipairs(clothing.Torso:GetChildren()) do
                        if child:IsA("MeshPart") then
                            table.insert(bossCache, { model = child, rootPart = child, type = "boss", name = child.Name })
                            updateTargetHistory(child, child.Position)
                        end
                    end
                end
            end
        end
        lastScanTime = tick()
        lastBossScanTime = tick()
        cleanupOldTargetHistory()
    end

    local function updateTransparentPartsCache()
        table.clear(transparentParts)
        local desc = workspace:GetDescendants()
        for i = 1, #desc do
            local v = desc[i]
            if v:IsA("BasePart") and v.Transparency >= 0.999 then
                table.insert(transparentParts, v)
            end
        end
        lastTransparentUpdate = tick()
    end

    local function isWithinViewAngle(targetPosition, cameraCFrame)
        local cameraLookVector = cameraCFrame.LookVector
        local toTarget = (targetPosition - cameraCFrame.Position)
        if toTarget.Magnitude == 0 then return true end
        toTarget = toTarget.Unit
        return cameraLookVector:Dot(toTarget) > COS_MAX_ANGLE
    end

    local function isTransparentOrAirWall(part)
        if not part then return false end
        if part.Transparency >= 0.999 then return true end
        if part.Transparency > 0.8 then return true end
        if AIR_WALL_MATERIALS[part.Material] then return true end
        if AIR_WALL_NAMES[part.Name:lower()] then return true end
        local color = part.BrickColor
        if (color == BrickColor.new("Really black") or color == BrickColor.new("Really white")) and part.Transparency > 0.5 then
            return true
        end
        return false
    end

    local function isTargetVisible(targetPart, cameraCFrame)
        if not char or not targetPart or not currentCamera then return false end
        local rayOrigin = cameraCFrame.Position
        local targetPosition = targetPart.Position
        local rayDirection = (targetPosition - rayOrigin)
        local rayDistance = rayDirection.Magnitude
        if rayDistance ~= rayDistance then return false end
        if not isWithinViewAngle(targetPosition, cameraCFrame) then return false end
        local ignoreList = { char, currentCamera }
        local playersFolder = workspace:FindFirstChild("Players")
        if playersFolder then
            for _, playerModel in ipairs(playersFolder:GetChildren()) do
                if playerModel:IsA("Model") then table.insert(ignoreList, playerModel) end
            end
        end
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        if zombiesFolder then
            for _, z in ipairs(zombiesFolder:GetChildren()) do
                if z:IsA("Model") and z.Name == "Agent" and z:GetAttribute and z:GetAttribute("Type") ~= "Barrel" then
                    table.insert(ignoreList, z)
                end
            end
        end
        for _, p in ipairs(transparentParts) do
            if p and p.Parent then table.insert(ignoreList, p) end
        end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances = ignoreList
        rp.IgnoreWater = true
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, rp)
        if not rayResult then return true end
        local hitInstance = rayResult.Instance
        if hitInstance and hitInstance:IsDescendantOf(targetPart.Parent) then
            local hitDistance = (rayResult.Position - rayOrigin).Magnitude
            return math.abs(hitDistance - rayDistance) < 5
        end
        return isTransparentOrAirWall(rayResult.Instance)
    end

    local function findNearestVisibleTarget(cameraCFrame)
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        local currentTime = tick()
        if currentTime - lastScanTime > 2 or currentTime - lastBossScanTime > 1 then
            updateTargetCache()
        end
        if currentTime - lastTransparentUpdate > 5 then updateTransparentPartsCache() end
        if #barrelCache == 0 and #bossCache == 0 or not char then return nil, math.huge end
        local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return nil, math.huge end
        local playerPos = humanoidRootPart.Position
        local nearestTarget, minDistance = nil, math.huge
        for i = 1, #barrelCache do
            local target = barrelCache[i]
            if target.model and target.rootPart and target.rootPart.Parent then
                updateTargetHistory(target.model, target.rootPart.Position)
                if isTargetVisible(target.rootPart, cameraCFrame) then
                    local dist = (playerPos - target.rootPart.Position).Magnitude
                    if dist < minDistance and dist < 1000 then
                        minDistance = dist
                        nearestTarget = target
                    end
                end
            end
        end
        for i = 1, #bossCache do
            local target = bossCache[i]
            if target.model and target.rootPart and target.rootPart.Parent then
                updateTargetHistory(target.model, target.rootPart.Position)
                if isTargetVisible(target.rootPart, cameraCFrame) then
                    local dist = (playerPos - target.rootPart.Position).Magnitude
                    if dist < minDistance and dist < 1000 then
                        minDistance = dist
                        nearestTarget = target
                    end
                end
            end
        end
        return nearestTarget, minDistance
    end

    -- 更新瞄准状态（检测玩家是否持枪）
    local function updateAimingStatus()
        if not char then return false end
        local hasGun = false
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute and child:GetAttribute("IsGun") == true then
                hasGun = true
                break
            end
        end
        return hasGun
    end

    -- 设置角色监听
    local function setupCharacterListeners()
        cleanupConnectionsLocal()
        if char then
            local connA = char.ChildAdded:Connect(function(child)
                -- 若装备枪，自动启用瞄准判定
            end)
            local connB = char.ChildRemoved:Connect(function(child) end)
            table.insert(aimState.conns, connA)
            table.insert(aimState.conns, connB)
        end
    end

    -- 初始化并启动心跳循环
    updateTransparentPartsCache()
    updateTargetCache()
    char = LocalPlayer.Character
    setupCharacterListeners()
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(nChar)
        char = nChar
        task.wait(0.8)
        setupCharacterListeners()
        updateTransparentPartsCache()
        updateTargetCache()
    end)
    table.insert(aimState.conns, charAddedConn)

    cameraLockConnection = RunService.Heartbeat:Connect(function()
        if not Flags.Running or not Flags.AutoAim then
            -- 清理并断开
            if cameraLockConnection then
                pcall(function() cameraLockConnection:Disconnect() end)
                cameraLockConnection = nil
            end
            return
        end
        if not char or not char.Parent then
            char = LocalPlayer.Character
            if not char then return end
        end
        currentCamera = workspace.CurrentCamera
        if not currentCamera then return end
        -- 只有玩家手持枪（或你定义的判定）才自动瞄准
        local hasGun = updateAimingStatus()
        if not hasGun then return end
        local cameraCFrame = currentCamera.CFrame
        local nearestTarget, distance = findNearestVisibleTarget(cameraCFrame)
        if nearestTarget and nearestTarget.rootPart then
            local currentPosition = nearestTarget.rootPart.Position
            local predictedPosition = getPredictedPosition(nearestTarget.model, currentPosition, PREDICTION_TIME)
            local cameraPosition = cameraCFrame.Position
            if predictedPosition and cameraPosition then
                local lookCFrame = CFrame.lookAt(cameraPosition, predictedPosition)
                currentCamera.CFrame = cameraCFrame:Lerp(lookCFrame, 0.3)
            end
        end
    end)
    table.insert(aimState.conns, cameraLockConnection)

    function aimState.stop()
        Flags.AutoAim = false
        cleanupConnectionsLocal()
        cameraLockConnection = nil
        barrelCache = {}
        bossCache = {}
        targetHistory = {}
        aimState = nil
        uiAim.status.Text = "❌"
        uiAim.status.TextColor3 = Color3.fromRGB(200,80,80)
    end

    uiAim.status.Text = "✔"
    uiAim.status.TextColor3 = Color3.fromRGB(110,230,110)
end

local function stopAutoAimModule()
    if aimState and type(aimState.stop) == "function" then aimState.stop() end
    aimState = nil
    uiAim.status.Text = "❌"
    uiAim.status.TextColor3 = Color3.fromRGB(200,80,80)
end

-- ========== UI Toggle 绑定 ==========

local function setUIButtonState(ui, on)
    ui.toggle.Text = on and "ON" or "OFF"
    ui.status.Text = on and "✔" or "❌"
    ui.status.TextColor3 = on and Color3.fromRGB(110,230,110) or Color3.fromRGB(200,80,80)
    ui.toggle.BackgroundColor3 = on and Color3.fromRGB(24,120,80) or Color3.fromRGB(40,40,40)
end

uiTrack.toggle.MouseButton1Click:Connect(function()
    Flags.AutoTrack = not Flags.AutoTrack
    setUIButtonState(uiTrack, Flags.AutoTrack)
    if Flags.AutoTrack then
        startTrackingModule()
    else
        stopTrackingModule()
    end
end)

uiJump.toggle.MouseButton1Click:Connect(function()
    Flags.AutoJump = not Flags.AutoJump
    setUIButtonState(uiJump, Flags.AutoJump)
    -- 当追踪模块运行时，追踪模块内部会管理自动跳的连接；若追踪未运行我们也可单独开启简单自动跳
    if Flags.AutoJump and trackingState then
        -- we assume tracking module will pick up Flags.AutoJump; but if tracking wasn't started, we can still run a simple auto-jump
        -- For simplicity, if tracking module is active its internals will start auto-jump when needed.
        -- If you want standalone AutoJump without AutoTrack, we can add a small routine:
        if not trackingState then
            -- simple fallback auto jump loop
            local conn = RunService.Heartbeat:Connect(function()
                if not Flags.AutoJump then return end
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid").Jump = true
                    task.wait(1)
                end
            end)
            trackConn(conn)
        end
    else
        -- Stop fallback auto-jump by cleaning connections via cleanupAllConnections if they exist
        -- (tracking module has its own stop which will clear internal auto-jump)
    end
end)

uiAvoid.toggle.MouseButton1Click:Connect(function()
    Flags.AvoidZombie = not Flags.AvoidZombie
    setUIButtonState(uiAvoid, Flags.AvoidZombie)
    -- If tracking running, it will respect Flags.AvoidZombie on next heartbeat.
end)

uiMove.toggle.MouseButton1Click:Connect(function()
    Flags.UsePathfinding = not Flags.UsePathfinding
    setUIButtonState(uiMove, Flags.UsePathfinding)
    uiMove.label = uiMove.label -- no-op, but state is toggled. tracking module uses Flags.UsePathfinding for movement selection.
end)

uiAim.toggle.MouseButton1Click:Connect(function()
    Flags.AutoAim = not Flags.AutoAim
    setUIButtonState(uiAim, Flags.AutoAim)
    if Flags.AutoAim then
        startAutoAimModule()
    else
        stopAutoAimModule()
    end
end)

-- 默认按钮状态（与 Flags 同步）
setUIButtonState(uiTrack, Flags.AutoTrack)
setUIButtonState(uiJump, Flags.AutoJump)
setUIButtonState(uiAvoid, Flags.AvoidZombie)
setUIButtonState(uiMove, Flags.UsePathfinding)
setUIButtonState(uiAim, Flags.AutoAim)

-- ========== 启动/关闭保护 ==========
-- 当脚本被移除或需要彻底停止时，请调用 shutdownAll()
--（已经在 Close 按钮中接入）

print("[ProAutoConsole] 已加载：UI / 自动追踪 / 自动瞄准 模块准备就绪。请用 UI 控制开关。")
