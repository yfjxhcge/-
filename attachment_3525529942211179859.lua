]]
local Delta = {}

local svc = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Stats = game:GetService("Stats"),
    HttpService = game:GetService("HttpService"),
}
if not _G.__LuraphPrefixCleaned then
    _G.__LuraphPrefixCleaned = true
    local oldError = error
    local function cleanLuraphPrefix(msg)
        if type(msg) ~= "string" then return msg end
        local result = msg
        local count = 0
        while result:find("Luraph Script:", 1, true) and count < 10 do
            local startPos = result:find("Luraph Script:", 1, true)
            if startPos then
                local after = result:sub(startPos + 14)
                local colonPos = after:find(":", 1, true)
                if colonPos then
                    local nextPart = after:sub(colonPos + 1)
                    if nextPart:find("Luraph Script:", 1, true) then
                        result = result:sub(1, startPos - 1) .. nextPart
                    else
                        break
                    end
                else
                    break
                end
            else
                break
            end
            count = count + 1
        end
        return result
    end
        _G.error = function(message, level)
        return oldError(cleanLuraphPrefix(message), level)
    end
end

local v7 = svc.Players.LocalPlayer
realTweenService = svc.TweenService
bypassModeActive = false
LucideManager = {Module = nil, Loaded = false}
function LoadLucide()
    if LucideManager.Loaded then return LucideManager.Module end
    local content
    local moduleUrls = {
        "https://cdn.jsdelivr.net/gh/WasKKal/Asset@master/lucide/init.lua",
        "https://raw.githubusercontent.com/WasKKal/Asset/master/lucide/init.lua",
    }
    for _, url in ipairs(moduleUrls) do
        for _ = 1, 2 do
            local ok, result = pcall(function() return game:HttpGet(url) end)
            if ok and result and #result > 5000 then
                content = result
                break
            end
            task.wait(0.3)
        end
        if content and #content > 5000 then break end
    end
    if not content or content == "" then
        for _ = 1, 2 do
            local ok, result = pcall(function()
                return game:HttpGet("https://github.com/latte-soft/lucide-roblox/releases/download/0.1.3/lucide-roblox.luau")
            end)
            if ok and result and #result > 5000 then
                content = result
                break
            end
            task.wait(0.3)
        end
    end
    if not content or content == "" then return nil end
    local func, err = loadstring(content)
    if not func then return nil end
    local ok, module = pcall(func)
    if not ok or not module then return nil end
    if type(module) ~= "table" or type(module.GetAsset) ~= "function" then return nil end
    LucideManager.Module = module
    LucideManager.Loaded = true
    return module
end

function GetIcon(iconName, size, color)
    local lucide = LoadLucide()
    local img = Instance.new("ImageLabel")
    img.Size = size or UDim2.new(0, 20, 0, 20)
    img.BackgroundTransparency = 1
    img.ImageColor3 = color or Color3.fromRGB(230, 232, 240)
    img.ScaleType = Enum.ScaleType.Fit

    if lucide then
        local ok, icon = pcall(function() return lucide.GetAsset(iconName) end)
        if ok and icon and icon.Url and icon.Url ~= "" then
            img.Image = icon.Url
            if icon.ImageRectOffset and icon.ImageRectSize then
                img.ImageRectOffset = icon.ImageRectOffset
                img.ImageRectSize = icon.ImageRectSize
            end
            return img
        end
    end

    img:Destroy()
    return nil
end

function ParseImageAsset(input)
    if type(input) == "string" and input:sub(1,13) == "rbxassetid://" then return input end
    if tonumber(input) then return "rbxassetid://" .. tonumber(input) end
    if type(input) == "string" and #input >= 4 and input:sub(1,4) == "http" then
        local getasset = getcustomasset or getsynasset
        if getasset and writefile then
            local success, result = pcall(function()
                if not isfolder("DeltaUI") then makefolder("DeltaUI") end
                if not isfolder("DeltaUI/Cache") then makefolder("DeltaUI/Cache") end
                local safeName = __safeFilterName(input)
                if #safeName > 50 then safeName = safeName:sub(1, 50) end
                local fileName = "DeltaUI/Cache/img_" .. safeName .. ".jpg"
                if isfile(fileName) then
                    return getasset(fileName)
                end
                local req = (syn and syn.request) or (http and http.request) or http_request or request
                local imgData = req({Url = input, Method = "GET"}).Body
                writefile(fileName, imgData)
                return getasset(fileName)
            end)
            if success then return result else warn("Image DL Failed") return "" end
        end
    end
    return input
end

function create(class, props)
    local inst = Instance.new(class)
    if type(props) == "table" then
        for k, v in pairs(props) do inst[k] = v end
    end
    return inst
end
function corner(radius, parent)
    local c = create("UICorner", {CornerRadius = UDim.new(0, radius or 8)})
    c.Parent = parent
    return c
end
function stroke(color, thickness, parent)
    local s = create("UIStroke", {Color = color or Color3.fromRGB(60, 65, 80), Thickness = thickness or 1, Transparency = 0.4})
    s.Parent = parent
    return s
end
function splitLines(text)
    local lines = {}
    local pos = 1
    while true do
        local nl = text:find(string.char(10), pos, true)
        if nl then
            table.insert(lines, text:sub(pos, nl - 1))
            pos = nl + 1
        else
            table.insert(lines, text:sub(pos))
            break
        end
    end
    return lines
end

function __safeFilterName(input)
    if type(input) ~= "string" then return "" end
    local result = ""
    for i = 1, #input do
        local c = input:sub(i, i)
        local b = string.byte(c)
        if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or b == 95 then
            result = result .. c
        else
            result = result .. "_"
        end
    end
    return result
end

local theme = {
    bg = Color3.fromRGB(20, 24, 32),
    surface = Color3.fromRGB(30, 34, 44),
    surfaceLight = Color3.fromRGB(45, 50, 60),
    accent = Color3.fromRGB(59, 130, 246),
    text = Color3.fromRGB(230, 232, 240),
    textDim = Color3.fromRGB(140, 150, 170),
    border = Color3.fromRGB(50, 55, 70),
    red = Color3.fromRGB(239, 68, 68),
    green = Color3.fromRGB(34, 197, 94),
    warn = Color3.fromRGB(250, 200, 80)
}

local translations = {
    rejoin = {en = "Rejoin", zh = "重新加入", ko = "재접속", ja = "再参加"},
    script_loaded = {en = "Loaded: ", zh = "加载完成: ", ko = "로드 완료: ", ja = "読み込み完了: "},
    rejoin_desc = {en = "Rejoins your current server", zh = "重新加入当前服务器", ko = "현재 서버에 재접속", ja = "現在のサーバーに再参加"},
    bypass_ui_detection = {en = "Bypass UI Detection", zh = "绕过UI检测", ko = "UI 감지 우회", ja = "UI検出バイパス"},
    bypass_ui_detection_desc = {en = "Can bypass UI detection on most servers, but limits some features", zh = "可以绕过大部分服务器的Ui检测,但会限制一些功能", ko = "대부분 서버의 UI 감지를 우회할 수 있지만, 일부 기능이 제한됩니다", ja = "ほとんどのサーバーのUI検出をバイパスできますが、一部の機能が制限されます"},
    small_server = {en = "Small Server", zh = "小服务器", ko = "소규모 서버", ja = "小規模サーバー"},
    small_server_desc = {en = "Joins a server with a low playercount", zh = "加入玩家数较少的服务器", ko = "플레이어 수가 적은 서버 참가", ja = "プレイヤー数が少ないサーバーに参加"},
    fps_cap = {en = "FPS Cap", zh = "帧率限制", ko = "FPS 제한", ja = "FPS制限"},
    fps_cap_desc = {en = "Change the FPS cap for a smoother experience", zh = "更改帧率限制以获得更流畅的体验", ko = "더 부드러운 경험을 위해 FPS 제한 변경", ja = "よりスムーズな体験のためFPS制限を変更"},
    icon_size = {en = "Icon Size", zh = "图标大小", ko = "아이콘 크기", ja = "アイコンサイズ"},
    icon_size_desc = {en = "Change the floating icon's size", zh = "更改悬浮图标的大小", ko = "플로팅 아이콘 크기 변경", ja = "フローティングアイコンのサイズを変更"},
    icon_shape = {en = "Icon Shape", zh = "图标形状", ko = "아이콘 모양", ja = "アイコン形状"},
    icon_shape_desc = {en = "Change the floating icon's shape", zh = "更改悬浮图标的形状", ko = "플로팅 아이콘 모양 변경", ja = "フローティングアイコンの形状を変更"},
    shape_rounded = {en = "Rounded Square", zh = "方圆角", ko = "둥근 사각형", ja = "角丸四角"},
    anti_afk = {en = "Anti AFK", zh = "反挂机", ko = "AFK 방지", ja = "AFK防止"},
    anti_afk_desc = {en = "Disable all idle timeout kicks from the source", zh = "禁用所有空闲超时踢出", ko = "모든 유휴 시간 초과 퇴장 비활성화", ja = "すべてのアイドルタイムアウトキックを無効化"},
    console = {en = "Console", zh = "控制台", ko = "콘솔", ja = "コンソール"},
    console_desc = {en = "Enable or disable console log output", zh = "启用或禁用控制台日志输出", ko = "콘솔 로그 출력 활성화 또는 비활성화", ja = "コンソールログ出力の有効/無効"},
    auto_execute = {en = "Auto Execute", zh = "自动执行", ko = "자동 실행", ja = "自動実行"},
    auto_execute_desc = {en = "Toggle auto-execution of scripts in the autoexec folder", zh = "切换 autoexec 文件夹中脚本的自动执行", ko = "autoexec 폴더의 스크립트 자동 실행 전환", ja = "autoexecフォルダのスクリプト自動実行を切り替え"},
    auto_accept_exec = {en = "Auto accept code execution", zh = "自动接受代码执行", ko = "자동 코드 실행 수락", ja = "コード実行を自動承認"},
    auto_accept_exec_desc = {en = "Skip confirmation dialog, automatically accept all execute_lua requests", zh = "跳过确认弹窗，自动接受所有代码执行请求", ko = "확인 대화 상자 건너뛰기, 모든 execute_lua 요청 자동 수락", ja = "確認ダイアログをスキップし、すべてのexecute_luaリクエストを自動承認"},
    click_here = {en = "CLICK HERE", zh = "点击这里", ko = "여기 클릭", ja = "ここをクリック"},
    language = {en = "Language", zh = "语言", ko = "언어", ja = "言語"},
    language_desc = {en = "Select your preferred language", zh = "选择您偏好的语言", ko = "선호하는 언어 선택", ja = "好みの言語を選択"},
    new_tab = {en = "New tab", zh = "新标签页", ko = "새 탭", ja = "新しいタブ"},
    disable_notifications = {en = "Disable UI Notifications", zh = "关闭UI通知", ko = "UI 알림 비활성화", ja = "UI通知を無効化"},
    disable_notifications_desc = {en = "Hide all popup notifications from the UI", zh = "隐藏所有UI弹窗通知", ko = "모든 UI 팝업 알림 숨기기", ja = "すべてのUIポップアップ通知を非表示"},
    execute = {en = "Execute", zh = "执行", ko = "실행", ja = "実行"},
    clear = {en = "Clear", zh = "清空", ko = "지우기", ja = "クリア"},
    paste = {en = "Paste", zh = "粘贴", ko = "붙여넣기", ja = "貼り付け"},
    execute_clipboard = {en = "Execute clipboard", zh = "执行剪贴板", ko = "클립보드 실행", ja = "クリップボードを実行"},
    save = {en = "Save", zh = "保存", ko = "저장", ja = "保存"},
    search_scripts = {en = "Search for the scripts you have saved", zh = "搜索您已保存的脚本", ko = "저장된 스크립트 검색", ja = "保存したスクリプトを検索"},
    enter_details = {en = "Enter Details", zh = "输入详情", ko = "세부 정보 입력", ja = "詳細を入力"},
    enter_details_desc = {en = "Complete the necessary parameters to upload your client script", zh = "填写必要参数以上传您的客户端脚本", ko = "클라이언트 스크립트 업로드를 위해 필요한 매개변수 입력", ja = "クライアントスクリプトをアップロードするために必要なパラメータを入力"},
    title = {en = "Title", zh = "标题", ko = "제목", ja = "タイトル"},
    title_placeholder = {en = "Enter Your Title...", zh = "输入您的标题...", ko = "제목을 입력하세요...", ja = "タイトルを入力..."},
    script = {en = "Script", zh = "脚本", ko = "스크립트", ja = "スクリプト"},
    script_placeholder = {en = "Enter Your Script...", zh = "输入您的脚本...", ko = "스크립트를 입력하세요...", ja = "スクリプトを入力..."},
    add_script = {en = "Add Script", zh = "添加脚本", ko = "스크립트 추가", ja = "スクリプトを追加"},
    delete = {en = "DELETE", zh = "删除", ko = "삭제", ja = "削除"},
    deleted = {en = "Deleted", zh = "已删除", ko = "삭제됨", ja = "削除しました"},
    execute_cap = {en = "EXECUTE", zh = "执行", ko = "실행", ja = "実行"},
    core_loaded = {en = "Delta UI Core loaded", zh = "Delta UI 核心已加载", ko = "Delta UI 코어 로드됨", ja = "Delta UI コアが読み込まれました"},
    ready = {en = "Ready", zh = "就绪", ko = "준비 완료", ja = "準備完了"},
    executing = {en = "Executing script...", zh = "正在执行脚本...", ko = "스크립트 실행 중...", ja = "スクリプトを実行中..."},
    execution_finished = {en = "Execution finished", zh = "执行完成", ko = "실행 완료", ja = "実行完了"},
    editor_cleared = {en = "Editor cleared", zh = "编辑器已清空", ko = "편집기 지워짐", ja = "エディタがクリアされました"},
    pasted = {en = "Pasted from clipboard", zh = "已从剪贴板粘贴", ko = "클립보드에서 붙여넣기 완료", ja = "クリップボードから貼り付けました"},
    executing_clipboard = {en = "Executing clipboard...", zh = "正在执行剪贴板...", ko = "클립보드 실행 중...", ja = "クリップボードを実行中..."},
    newline = {en = "Newline", zh = "换行", ko = "줄바꿈", ja = "改行"},
    clipboard_finished = {en = "Clipboard execution finished", zh = "剪贴板执行完成", ko = "클립보드 실행 완료", ja = "クリップボード実行完了"},
    executing_saved = {en = "Executing saved script: ", zh = "正在执行已保存的脚本: ", ko = "저장된 스크립트 실행 중: ", ja = "保存したスクリプトを実行中: "},
    script_loading = {en = "Script loading... ", zh = "脚本正在加载... ", ko = "스크립트 로딩 중... ", ja = "スクリプト読み込み中... "},
    error = {en = "Error", zh = "错误", ko = "오류", ja = "エラー"},
    server = {en = "Server", zh = "服务器", ko = "서버", ja = "サーバー"},
    label = {en = "Label", zh = "标签", ko = "라벨", ja = "ラベル"},
    console_disabled_error = {en = "error Console is disabled", zh = "错误 控制台已禁用", ko = "오류 콘솔이 비활성화됨", ja = "エラー コンソールが無効化されています"},
    back = {en = "Back", zh = "返回", ko = "뒤로", ja = "戻る"},
    uninstall = {en = "Uninstall", zh = "卸载", ko = "제거", ja = "アンインストール"},
    uninstalling = {en = "Uninstalling", zh = "正在卸载", ko = "제거 중", ja = "アンインストール中"},
    updating = {en = "Updating", zh = "正在更新", ko = "업데이트 중", ja = "更新中"},
    installed = {en = "Installed", zh = "已安装", ko = "설치됨", ja = "インストール済み"},
    install = {en = "Install", zh = "安装", ko = "설치", ja = "インストール"},
    update = {en = "Update", zh = "更新", ko = "업데이트", ja = "更新"},
    complete = {en = "Complete!", zh = "完成!", ko = "완료!", ja = "完了!"},
    failed = {en = "Failed", zh = "失败", ko = "실패", ja = "失敗"},
    downloading = {en = "Downloading", zh = "正在下载", ko = "다운로드 중", ja = "ダウンロード中"},
    autoexec_enabled = {en = "AutoExecute enabled. UI load runs script automatically", zh = "自动执行已启用。UI加载时自动运行脚本", ko = "자동 실행 활성화됨. UI 로드 시 스크립트 자동 실행", ja = "自動実行が有効化されました。UI読み込み時にスクリプトを自動実行"},
    autoexec_disabled = {en = "AutoExecute disabled", zh = "自动执行已禁用", ko = "자동 실행 비활성화됨", ja = "自動実行が無効化されました"},
    compatibility_mode = {en = "Performance Mode", zh = "性能模式", ko = "성능 모드", ja = "パフォーマンスモード"},
    compatibility_mode_desc = {en = "Enable after rejoining, more script compatibility and better performance. Static HashValue may be detected by servers or tampered by malicious scripts.", zh = "开启后 需要重新加入游戏 兼容更多脚本 同时性能提升 但静态HashValue可能导致被部分服务器检测或被其他恶意脚本篡改", ko = "재접속 후 활성화, 더 많은 스크립트 호환 및 성능 향상. 정적 HashValue는 서버에 감지되거나 악성 스크립트에 의해 변조될 수 있음", ja = "再接続後に有効化、より多くのスクリプト互換性とパフォーマンス向上。静的HashValueはサーバーに検出されるか、悪意のあるスクリプトによって改ざんされる可能性があります"},
    auto_translate = {en = "Auto Translate", zh = "自动翻译", ko = "자동 번역", ja = "自動翻訳"},
    auto_translate_desc = {en = "Auto translate UI text (Chinese/English only)", zh = "自动将UI文本翻译为英文 (仅支持中英互译)", ko = "UI 텍스트 자동 번역 (중영만 지원)", ja = "UIテキスト自動翻訳 (中英のみ対応)"},

    translate_path = {en = "Translate Path", zh = "翻译路径", ko = "번역 경로", ja = "翻訳パス"},
    translate_path_desc = {en = "Select UI paths to translate", zh = "选择要翻译的UI路径", ko = "번역할 UI 경로 선택", ja = "翻訳するUIパスを選択"},
    coregui_path = {en = "CoreGui", zh = "CoreGui", ko = "CoreGui", ja = "CoreGui"},
    playergui_path = {en = "PlayerGui", zh = "PlayerGui", ko = "PlayerGui", ja = "PlayerGui"},
    script_installed_notify = {en = "Script installed. Use on GamePad page", zh = "脚本已安装。请在 GamePad 页面使用", ko = "스크립트 설치됨. GamePad 페이지에서 사용", ja = "スクリプトがインストールされました。GamePadページで使用"},
    customize_floating_ball = {en = "Customize floating ball image(Need 1:1)", zh = "自定义悬浮球图片(需要1:1)", ko = "플로팅 볼 이미지 사용자 지정(1:1 필요)", ja = "フローティングボール画像をカスタマイズ(1:1必要)"},
    confirm_changes = {en = "Confirm changes", zh = "确认更改", ko = "변경 확인", ja = "変更を確認"},
    enter_image_url = {en = "Enter image URL...", zh = "输入图片链接...", ko = "이미지 URL 입력...", ja = "画像URLを入力..."},
    invalid_image = {en = "Invalid image URL", zh = "无效的图片链接", ko = "잘못된 이미지 URL", ja = "無効な画像URL"},
    image_updated = {en = "Floating ball image updated", zh = "悬浮球图片已更新", ko = "플로팅 볼 이미지 업데이트됨", ja = "フローティングボール画像が更新されました"},
    customize_floating_ball_desc = {en = "Enter a 1:1 image URL to customize the floating ball", zh = "输入1:1图片链接自定义悬浮球", ko = "플로팅 볼 사용자 지정을 위해 1:1 이미지 URL 입력", ja = "フローティングボールをカスタマイズする1:1画像URLを入力"},
    custom_icon_guide = {en = "Rename image to icon.png, replace Workspace/DeltaUI/Asset/icon.png", zh = "将你的图片名改为icon.png 替换到Workspace/DeltaUI/Asset/icon.png下 即可手动修改", ko = "이미지를 icon.png로 변경 후 Workspace/DeltaUI/Asset/icon.png 교체", ja = "画像をicon.pngに改名し Workspace/DeltaUI/Asset/icon.png を置換"},
    patch_must_install = {en = "Must be installed", zh = "必须安装", ko = "설치 필수", ja = "インストール必須"},
    patch_installed_notify = {en = "Patch installed and applied", zh = "补丁已安装并应用", ko = "패치 설치 및 적용됨", ja = "パッチがインストールされました"},
    ui_outdated = {en = "Your UI version is outdated. Please install the latest version", zh = "你的UI版本已过时，请前往安装最新版", ko = "UI 버전이 오래되었습니다. 최신 버전을 설치하세요", ja = "UIバージョンが古いです。最新版をインストールしてください"},
    ui_update_export = {en = "New UI version downloaded to DeltaUI/Export. Please close the game and place it into Delta AutoExecute folder", zh = "新版UI已下载至DeltaUI/Export。请关闭游戏后将其放入Delta的AutoExecute文件夹", ko = "새 UI 버전이 DeltaUI/Export에 다운로드되었습니다. 게임을 종료하고 Delta AutoExecute 폴더에 넣으세요", ja = "新しいUIバージョンがDeltaUI/Exportにダウンロードされました。ゲームを終了してDeltaのAutoExecuteフォルダに配置してください"},
    patch_cannot_delete = {en = "Patch cannot be uninstalled from here", zh = "补丁不能从此处卸载", ko = "패치는 여기에서 제거할 수 없습니다", ja = "パッチはここからアンインストールできません"},
    patch_not_found = {en = "Patch source removed, cleaning local patch", zh = "补丁源已移除，正在清理本地补丁", ko = "패치 소스가 제거되어 로컬 패치를 정리합니다", ja = "パッチソースが削除されたため、ローカルパッチをクリーンアップします"},
    uipack_installed = {en = "UI Pack installed", zh = "UI包已安装", ko = "UI 팩 설치됨", ja = "UIパックがインストールされました"},
    uipack_label = {en = "UI Pack", zh = "UI包", ko = "UI 팩", ja = "UIパック"},
    patch_available = {en = "New patch available", zh = "有新补丁可用", ko = "새 패치 사용 가능", ja = "新しいパッチが利用可能です"},
    patch_deleted = {en = "Patch deleted", zh = "补丁已删除", ko = "패치 삭제됨", ja = "パッチが削除されました"},
    servers_input_placeholder = {en = "e.g. Blox Fruits, Adopt Me...", zh = "例如：Blox Fruits, Adopt Me...", ko = "예: Blox Fruits, Adopt Me...", ja = "例: Blox Fruits, Adopt Me..."},
    block_internal_errors = {en = "Block Internal Errors", zh = "禁用Roblox内部报错", ko = "내부 오류 차단", ja = "内部エラーをブロック"},
    block_internal_errors_desc = {en = "Filter out Roblox engine and other script errors", zh = "过滤Roblox引擎和其他脚本的报错信息", ko = "Roblox 엔진 및 기타 스크립트 오류 필터링", ja = "Robloxエンジンと他のスクリプトエラーをフィルタリング"},
    real_line_numbers = {en = "Real Line Numbers", zh = "自动计算真实报错行", ko = "실제 줄 번호 계산", ja = "実際の行番号を計算"},
    real_line_numbers_desc = {en = "Adjust error line numbers to exclude default header text", zh = "修正报错行号，排除预设文本的偏移", ko = "기본 헤더 텍스트를 제외한 실제 오류 줄 번호", ja = "デフォルトヘッダーテキストを除いた実際のエラー行番号"},
    detailed_errors = {en = "Detailed Errors", zh = "更详细的错误信息", ko = "상세 오류 정보", ja = "詳細なエラー情報"},
    detailed_errors_desc = {en = "Show additional error context and source info", zh = "显示额外的错误上下文和来源信息", ko = "추가 오류 컨텍스트 및 소스 정보 표시", ja = "追加のエラーコンテキストとソース情報を表示"},
    extension_package_options = {en = "Other options", zh = "其他选项", ko = "기타 옵션", ja = "その他のオプション"},
    confirm_changes = {en = "Confirm changes", zh = "确认更改", ko = "변경 확인", ja = "変更を確認"},
    enter_image_url = {en = "Enter image URL...", zh = "输入图片链接...", ko = "이미지 URL 입력...", ja = "画像URLを入力..."},
    save = {en = "Save", zh = "保存", ko = "저장", ja = "保存"},
    search_scripts = {en = "Search for the scripts you have saved", zh = "搜索您已保存的脚本", ko = "저장된 스크립트 검색", ja = "保存したスクリプトを検索"},
    supported_servers = {en = "Supported servers (comma separated)", zh = "支持的服务器（逗号分隔）", ko = "지원되는 서버 (쉼표로 구분)", ja = "対応サーバー（カンマ区切り）"},
    local_version = {en = "Local: ", zh = "本地：", ko = "로컬: ", ja = "ローカル: "},
    update_version = {en = "Update: ", zh = "更新：", ko = "업데이트: ", ja = "アップデート: "},
    author_label = {en = "Author: ", zh = "作者：", ko = "제작자: ", ja = "作者: "},
    version_label = {en = "Version: ", zh = "版本：", ko = "버전: ", ja = "バージョン: "},
    type_label = {en = "Type: ", zh = "类型：", ko = "유형: ", ja = "タイプ: "},
    from_store = {en = "From Store", zh = "来自商店", ko = "스토어에서", ja = "ストアから"},
    no_installed_packages = {en = "No installed packages", zh = "没有已安装的包", ko = "설치된 패키지 없음", ja = "インストール済みパッケージなし"},
    no_packages_available = {en = "No packages available", zh = "没有可用的包", ko = "사용 가능한 패키지 없음", ja = "利用可能なパッケージなし"},
    no_server_restrictions = {en = "No server restrictions", zh = "无服务器限制", ko = "서버 제한 없음", ja = "サーバー制限なし"},
    supported_servers_title = {en = "Supported servers:", zh = "支持的服务器：", ko = "지원되는 서버:", ja = "対応サーバー:"},
    editor_cleared = {en = "Editor cleared", zh = "编辑器已清空", ko = "편집기 지워짐", ja = "エディタがクリアされました"},
    search_cloud_placeholder = {en = "Search for the extension module or script you need...", zh = "搜索您需要的扩展模块或脚本...", ko = "필요한 확장 모듈 또는 스크립트 검색...", ja = "必要な拡張モジュールまたはスクリプトを検索..."},
    executing = {en = "Executing script...", zh = "正在执行脚本...", ko = "스크립트 실행 중...", ja = "スクリプトを実行中..."},
    executing_saved = {en = "Executing saved script: ", zh = "正在执行已保存的脚本: ", ko = "저장된 스크립트 실행 중: ", ja = "保存したスクリプトを実行中: "},
    script_loading = {en = "Script loading... ", zh = "脚本正在加载... ", ko = "스크립트 로딩 중... ", ja = "スクリプト読み込み中... "},
    fps_30 = {en = "30 FPS", zh = "30 帧", ko = "30 FPS", ja = "30 FPS"},
    fps_60 = {en = "60 FPS", zh = "60 帧", ko = "60 FPS", ja = "60 FPS"},
    fps_120 = {en = "120 FPS", zh = "120 帧", ko = "120 FPS", ja = "120 FPS"},
    fps_240 = {en = "240 FPS", zh = "240 帧", ko = "240 FPS", ja = "240 FPS"},
    fps_360 = {en = "360 FPS", zh = "360 帧", ko = "360 FPS", ja = "360 FPS"},
    fps_unlimited = {en = "Unlimited", zh = "无限制", ko = "무제한", ja = "無制限"},
    size_small = {en = "Small", zh = "小", ko = "작음", ja = "小"},
    size_medium = {en = "Medium", zh = "中", ko = "중간", ja = "中"},
    size_large = {en = "Large", zh = "大", ko = "큼", ja = "大"},
    shape_circle = {en = "Circle", zh = "圆形", ko = "원형", ja = "円形"},
    shape_square = {en = "Square", zh = "方形", ko = "사각형", ja = "四角形"},
    shape_rounded = {en = "Rounded Square", zh = "方圆角", ko = "둥근 사각형", ja = "角丸四角"},
    refreshing = {en = "Refreshing", zh = "刷新中", ko = "새로고침 중", ja = "更新中"},
    refresh_complete = {en = "Refresh complete!", zh = "刷新完成!", ko = "새로고침 완료!", ja = "更新完了!"},
    install = {en = "Install", zh = "安装", ko = "설치", ja = "インストール"},
    installed = {en = "Installed", zh = "已安装", ko = "설치됨", ja = "インストール済み"},
    update = {en = "Update", zh = "更新", ko = "업데이트", ja = "更新"},
    uninstall = {en = "Uninstall", zh = "卸载", ko = "제거", ja = "アンインストール"},
    complete = {en = "Complete!", zh = "完成!", ko = "완료!", ja = "完了!"},
    failed = {en = "Failed", zh = "失败", ko = "실패", ja = "失敗"},
    downloading = {en = "Downloading", zh = "正在下载", ko = "다운로드 중", ja = "ダウンロード中"},
    updating = {en = "Updating", zh = "正在更新", ko = "업데이트 중", ja = "更新中"},
    uninstalling = {en = "Uninstalling", zh = "正在卸载", ko = "제거 중", ja = "アンインストール中"},
    patch_must_install = {en = "Must be installed", zh = "必须安装", ko = "설치 필수", ja = "インストール必須"},
    local_version = {en = "Local: ", zh = "本地：", ko = "로컬: ", ja = "ローカル: "},
    update_version = {en = "Update: ", zh = "更新：", ko = "업데이트: ", ja = "アップデート: "},
    author_label = {en = "Author: ", zh = "作者：", ko = "제작자: ", ja = "作者: "},
    version_label = {en = "Version: ", zh = "版本：", ko = "버전: ", ja = "バージョン: "},
    type_label = {en = "Type: ", zh = "类型：", ko = "유형: ", ja = "タイプ: "},
    from_store = {en = "From Store", zh = "来自商店", ko = "스토어에서", ja = "ストアから"},
    no_installed_packages = {en = "No installed packages", zh = "没有已安装的包", ko = "설치된 패키지 없음", ja = "インストール済みパッケージなし"},
    no_packages_available = {en = "No packages available", zh = "没有可用的包", ko = "사용 가능한 패키지 없음", ja = "利用可能なパッケージなし"},
    no_server_restrictions = {en = "No server restrictions", zh = "无服务器限制", ko = "서버 제한 없음", ja = "サーバー制限なし"},
    by_label = {en = "by ", zh = "by ", ko = "by ", ja = "by "},
    customize_label = {en = "Customize Label", zh = "自定义标签", ko = "라벨 사용자 지정", ja = "ラベルをカスタマイズ"},
    customize_label_desc = {en = "Change the text displayed in the top right label", zh = "更改右上角标签显示的文本", ko = "오른쪽 상단 라벨에 표시되는 텍스트 변경", ja = "右上ラベルに表示されるテキストを変更"},
    enter_label_text = {en = "Enter label text...", zh = "输入标签文字...", ko = "라벨 텍스트 입력...", ja = "ラベルテキストを入力..."},
    label_updated = {en = "Label updated", zh = "标签已更新", ko = "라벨 업데이트됨", ja = "ラベルが更新されました"},
    console_settings = {en = "Console Settings", zh = "控制台设置", ko = "콘솔 설정", ja = "コンソール設定"},
    block_internal_errors = {en = "Block Internal Errors", zh = "禁用Roblox内部报错", ko = "내부 오류 차단", ja = "内部エラーをブロック"},
    block_internal_errors_desc = {en = "Filter out Roblox engine and other script errors", zh = "过滤Roblox引擎和其他脚本的报错信息", ko = "Roblox 엔진 및 기타 스크립트 오류 필터링", ja = "Robloxエンジンと他のスクリプトエラーをフィルタリング"},
    real_line_numbers = {en = "Real Line Numbers", zh = "自动计算真实报错行", ko = "실제 줄 번호 계산", ja = "実際の行番号を計算"},
    real_line_numbers_desc = {en = "Adjust error line numbers to exclude default header text", zh = "修正报错行号，排除预设文本的偏移", ko = "기본 헤더 텍스트를 제외한 실제 오류 줄 번호", ja = "デフォルトヘッダーテキストを除いた実際のエラー行番号"},
    detailed_errors = {en = "Detailed Errors", zh = "更详细的错误信息", ko = "상세 오류 정보", ja = "詳細なエラー情報"},
    detailed_errors_desc = {en = "Show additional error context and source info", zh = "显示额外的错误上下文和来源信息", ko = "추가 오류 컨텍스트 및 소스 정보 표시", ja = "追加のエラーコンテキストとソース情報を表示"},
    scriptblox_search = {en = "Search ScriptBlox...", zh = "搜索 ScriptBlox...", ko = "ScriptBlox 검색...", ja = "ScriptBloxを検索..."},
    scriptblox_no_results = {en = "No scripts found", zh = "未找到脚本", ko = "스크립트를 찾을 수 없음", ja = "スクリプトが見つかりません"},
    select_option = {en = "Select Your Option", zh = "选择您的操作", ko = "옵션을 선택하세요", ja = "オプションを選択"},
    select_option_desc = {en = "Choose whether to execute, open in a new tab, etc..", zh = "选择执行、在新标签页打开等操作", ko = "실행, 새 탭에서 열기 등을 선택", ja = "実行、新しいタブで開くなどを選択"},
    execute_selected = {en = "EXECUTE SELECTED SCRIPT", zh = "执行选中脚本", ko = "선택한 스크립트 실행", ja = "選択したスクリプトを実行"},
    open_in_editor = {en = "OPEN SCRIPT IN EDITOR", zh = "在编辑器中打开", ko = "에디터에서 열기", ja = "エディタで開く"},
    save_selected = {en = "SAVE SELECTED SCRIPT", zh = "保存选中脚本", ko = "선택한 스크립트 저장", ja = "選択したスクリプトを保存"},
    copy_to_clipboard = {en = "COPY TO CLIPBOARD", zh = "复制到剪贴板", ko = "클립보드에 복사", ja = "クリップボードにコピー"},
    open_btn = {en = "OPEN", zh = "打开", ko = "열기", ja = "開く"},
    verified_badge = {en = "VERIFIED", zh = "已验证", ko = "인증됨", ja = "認証済み"},
    fetch_failed = {en = "Failed to fetch script source", zh = "获取脚本源码失败", ko = "스크립트 소스를 가져오지 못함", ja = "スクリプトソースの取得に失敗"},
    opened_editor = {en = "Opened in editor", zh = "已在编辑器中打开", ko = "에디터에서 열림", ja = "エディタで開きました"},
    script_saved = {en = "Script saved", zh = "脚本已保存", ko = "스크립트 저장됨", ja = "スクリプトを保存しました"},
    copied = {en = "Copied to clipboard", zh = "已复制到剪贴板", ko = "클립보드에 복사됨", ja = "クリップボードにコピーしました"},
    clipboard_unavailable = {en = "Clipboard API unavailable", zh = "剪贴板 API 不可用", ko = "클립보드 API 사용 불가", ja = "クリップボードAPIが利用できません"},
    execution_error_notify = {en = "Error occurred! Jump to console", zh = "遇到报错! 请跳转控制台!", ko = "오류 발생! 콘솔로 이동", ja = "エラー発生! コンソールへ"},
    anti_kick = {en = "Anti Kick", zh = "反踢出", ko = "킥 방지", ja = "キック防止"},
    anti_kick_desc = {en = "Prevent other scripts from kicking you", zh = "防止其他脚本调用kick踢出", ko = "다른 스크립트의 킥 방지", ja = "他のスクリプトによるキックを防止"},
    network_request_header = {en = "Network Request Header", zh = "网络请求头类型", ko = "네트워크 요청 헤더", ja = "ネットワークリクエストヘッダー"},
    network_request_header_desc = {en = "Select the platform for HTTP requests", zh = "选择HTTP请求的平台类型", ko = "HTTP 요청에 사용할 플랫폼 선택", ja = "HTTPリクエストのプラットフォームを選択"},
    interface_type = {en = "Interface Type", zh = "接口类型", ko = "인터페이스 유형", ja = "インターフェースタイプ"},
    interface_type_desc = {en = "Select the browser or service interface", zh = "选择浏览器或服务接口", ko = "브라우저 또는 서비스 인터페이스 선택", ja = "ブラウザまたはサービスインターフェースを選択"},
    script_type_free = {en = "free", zh = "免费", ko = "묣료", ja = "無料"},
    script_type_script_hub = {en = "Script hub", zh = "脚本中心", ko = "스크립트 허브", ja = "スクリプトハブ"},
    script_type_script = {en = "Script", zh = "脚本", ko = "스크립트", ja = "スクリプト"},
    views_label = {en = "Views", zh = "次浏览", ko = "조회", ja = "回視聴"},
    universal_script = {en = "Universal Script", zh = "通用脚本", ko = "범용 스크립트", ja = "汎用スクリプト"},
    error_translation = {en = "Error Translation", zh = "报错信息翻译", ko = "오류 메시지 번역", ja = "エラー翻訳"},
    error_translation_desc = {en = "Translate common error messages to your language", zh = "将常见报错信息翻译为您的语言", ko = "일반적인 오류 메시지를 번역", ja = "一般的なエラーメッセージを翻訳"},
    block_server_errors = {en = "Block Server Errors", zh = "屏蔽服务器报错", ko = "서버 오류 차단", ja = "サーバーエラーをブロック"},
    block_server_errors_desc = {en = "Filter out server-side errors from ReplicatedStorage", zh = "屏蔽来自 ReplicatedStorage 的服务器端报错", ko = "ReplicatedStorage의 서버 오류 필터링", ja = "ReplicatedStorageからのサーバーエラーをフィルタリング"},
    block_asset_errors = {en = "Block Asset Errors", zh = "屏蔽资产报错", ko = "에셋 오류 차단", ja = "アセットエラーをブロック"},
    block_asset_errors_desc = {en = "Filter out animation, asset and rbx:// loading errors", zh = "屏蔽动画、资产及rbx://加载失败报错", ko = "애니메이션, 에셋 및 rbx:// 로딩 오류 필터링", ja = "アニメーション、アセット及びrbx://読み込みエラーをフィルタリング"},
    match_search = {en = "Match Search!", zh = "匹配搜索!", ko = "검색 일치!", ja = "検색一致!"},
    init_ui = {en = "Initialize UI", zh = "初始化UI", ko = "UI 초기화", ja = "UIを初期化"},
    init_ui_desc = {en = "This will destroy downloaded/saved scripts", zh = "这将破坏已下载/已保存的脚本", ko = "다운로드/저장된 스크립트를 삭제합니다", ja = "ダウンロード/保存されたスクリプトを破棄します"},
    reset_tab_order = {en = "Reset Switcher", zh = "重制页面切换器", ko = "스위처 초기화", ja = "スイッチャーをリセット"},
    reset_switcher_desc = {en = "Reset tab order and custom icons", zh = "重置排序及自定义图标", ko = "탭 순서 및 사용자 지정 아이콘 초기화", ja = "タブ順序とカスタムアイコンをリセット"},
    customize_items = {en = "Customize Items", zh = "自定义项目", ko = "사용자 지정 항목", ja = "カスタマイズ項目"},
    customize_icon = {en = "Customize Icon", zh = "自定义图标", ko = "아이콘 사용자 지정", ja = "アイコンをカスタマイズ"},
    search_icons = {en = "Search icons...", zh = "搜索图标...", ko = "아이콘 검색...", ja = "アイコンを検索..."},
    add = {en = "Add", zh = "添加", ko = "추가", ja = "追加"},
    delete = {en = "Delete", zh = "删除", ko = "삭제", ja = "削除"},
    select_color = {en = "Select Color", zh = "选择颜色", ko = "색상 선택", ja = "色を選択"},
    orb_border_color = {en = "Orb Border Color", zh = "悬浮球边框颜色", ko = "플로팅 볼 테두리 색상", ja = "フローティングボールの枠線色"},
    orb_border_color_desc = {en = "Customize the floating orb border color", zh = "自定义悬浮球边框颜色", ko = "플로팅 볼 테두리 색상 사용자 지정", ja = "フローティングボールの枠線色をカスタマイズ"},
    deep_customization = {en = "Deep Customization", zh = "深度自定义", ko = "고급 설정", ja = "詳細設定"},
    customize_tabs = {en = "Customize Top Tabs", zh = "自定义顶部选项卡", ko = "상단 탭 사용자 지정", ja = "上部タブをカスタマイズ"},
    customize_tabs_desc = {en = "Customize the order of top navigation tabs", zh = "自定义顶部导航选项卡顺序", ko = "상단 탭 순서 변경", ja = "上部ナビゲーションタブの順序を変更"},
    customize_tabs_btn = {en = "Customize", zh = "自定义", ko = "사용자 지정", ja = "カスタマイズ"},
}

function safeConnect(obj, event, callback)
    if obj and obj[event] then
        local conn = obj[event]:Connect(callback)
        if conn then
            _G.__DeltaUI_connections = _G.__DeltaUI_connections or {}
            table.insert(_G.__DeltaUI_connections, conn)
        end
        return conn
    else
        warn("[DeltaUI] Cannot connect to event: object or event is nil (" .. tostring(event) .. ")")
        return nil
    end
end

-- Clean up all tracked connections (call on UI destroy/reload)
function cleanupAllConnections()
    if _G.__DeltaUI_connections then
        for _, conn in ipairs(_G.__DeltaUI_connections) do
            pcall(function() conn:Disconnect() end)
        end
        _G.__DeltaUI_connections = {}
    end
end

local uiVersion = "1.1.0"
local UI_VERSION = "1.1.0"
local settingsData = {language = "zh", uiRefs = {}}
local configFile = "DeltaUI/Config.json"
local uiVersionChecked = false

function checkUiVersion(remoteVersion)
    if uiVersionChecked then return end
    uiVersionChecked = true
    if not remoteVersion or remoteVersion == "" then return end
    if tostring(remoteVersion) ~= tostring(UI_VERSION) then
        ShowNotification(t("ui_outdated"), 2, function()
            switchPage("package")
        end)
    end
end

function loadConfig()
    if _G.__DeltaUI_cachedConfig then
        return _G.__DeltaUI_cachedConfig
    end
    if not isfile(configFile) then
        _G.__DeltaUI_cachedConfig = {}
        return _G.__DeltaUI_cachedConfig
    end
    local content = readfile(configFile)
    if not content then
        _G.__DeltaUI_cachedConfig = {}
        return _G.__DeltaUI_cachedConfig
    end
    local ok, data = pcall(svc.HttpService.JSONDecode, svc.HttpService, content)
    if ok and type(data) == "table" then
        _G.__DeltaUI_cachedConfig = data
        return data
    end
    _G.__DeltaUI_cachedConfig = {}
    return _G.__DeltaUI_cachedConfig
end

local translateMap = nil
local translateMapLoaded = false
local translateConn = nil
local originalTexts = {}
local MAX_ORIGINAL_TEXTS = 5000  -- Prevent unbounded memory growth

function loadTranslateMap()
    if translateMapLoaded then return translateMap end
    local url = "https://github.com/WasKKal/-/raw/refs/heads/main/Translate.json"
    local raw = nil
    for _ = 1, 3 do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and result and result ~= "" and #result > 1000 then
            raw = result
            break
        end
        task.wait(0.5)
    end
    if not raw or raw == "" then
        warn("[DeltaUI] Failed to load translate map")
        return nil
    end
    local ok, map = pcall(function()
        return svc.HttpService:JSONDecode(raw)
    end)
    if ok and map and type(map) == "table" then

        local filtered = {}
        for lang, subMap in pairs(map) do
            if lang == "en" or lang == "zh" then
                filtered[lang] = subMap
            end
        end
        translateMap = filtered
        translateMapLoaded = true
        return filtered
    end
    warn("[DeltaUI] Translate map parse failed")
    return nil
end

function translateText(text)
    if not text or text == "" then return text end
    if not translateMap then
        translateMap = loadTranslateMap()
    end
    if not translateMap then return text end
    local lang = settingsData.language or "en"

    if lang ~= "en" and lang ~= "zh" then
        return text
    end
    local map = translateMap[lang]
    if not map then return text end
    local result = text
    local protected = {}
    local idx = 1

        local function protectPattern(str, prefix)
        local out = {}
        local oi = 1
        local i = 1
        while i <= #str do
            local c = str:sub(i, i)
            if c == "-" or c == "." or (c >= "0" and c <= "9") then
                local num = c
                i = i + 1
                while i <= #str do
                    local nc = str:sub(i, i)
                    if nc == "-" or nc == "." or (nc >= "0" and nc <= "9") then
                        num = num .. nc
                        i = i + 1
                    else
                        break
                    end
                end
                local key = prefix .. idx .. "__"
                protected[key] = num
                idx = idx + 1
                out[oi] = key
                oi = oi + 1
            else
                out[oi] = c
                oi = oi + 1
                i = i + 1
            end
        end
        return table.concat(out)
    end

    result = protectPattern(result, "__PROT_EQ_")

    local sortedKeys = {}
    for src, dst in pairs(map) do
        if type(src) == "string" and type(dst) == "string" and src ~= "" then
            table.insert(sortedKeys, {src = src, dst = dst, len = #src})
        end
    end
    table.sort(sortedKeys, function(a, b) return a.len > b.len end)
    for _, entry in ipairs(sortedKeys) do
        local ok, newResult = pcall(function()
            return result:gsub(entry.src, entry.dst)
        end)
        if ok then
            result = newResult
        end
    end
    for key, val in pairs(protected) do
        result = result:gsub(key, val)
    end
    return result
end

function scanAndTranslate(container)
    if not container then return end
    local screenGuiRef = screenGui
    local function isInMainUI(obj)
        if not obj or not screenGuiRef then return false end
        local ancestor = obj:FindFirstAncestorOfClass("ScreenGui")
        return ancestor == screenGuiRef
    end
    -- Iterative BFS to avoid deep recursion stack overflow
    local queue = {container}
    local qHead = 1
    while qHead <= #queue do
        local obj = queue[qHead]
        queue[qHead] = nil
        qHead = qHead + 1
        if obj and obj:IsA("GuiObject") and not isInMainUI(obj) then
            if obj.ClassName:find("Text") then
                local currentText = obj.Text
                if currentText and currentText ~= "" then
                    if not originalTexts[obj] then
                        originalTexts[obj] = currentText
                        originalTexts.__count = (originalTexts.__count or 0) + 1
                        if originalTexts.__count > MAX_ORIGINAL_TEXTS then
                            local k = next(originalTexts)
                            local removed = 0
                            while k and removed < 1000 do
                                if k ~= "__count" then
                                    originalTexts[k] = nil
                                    removed = removed + 1
                                end
                                k = next(originalTexts, k)
                            end
                            originalTexts.__count = originalTexts.__count - removed
                        end
                    end
                    local translated = translateText(currentText)
                    if translated ~= currentText then
                        pcall(function() obj.Text = translated end)
                    end
                end
            end
            local children = obj:GetChildren()
            if children then
                for _, child in ipairs(children) do
                    queue[#queue + 1] = child
                end
            end
        end
    end
end

function startAutoTranslate()
    if translateConn then
        for _, conn in ipairs(translateConn) do
            conn:Disconnect()
        end
        translateConn = nil
    end
    local cfg = loadConfig()
    local paths = cfg.translatePaths or {t("coregui_path")}
    translateConn = {}
    for _, path in ipairs(paths) do
        local target
        if path == t("playergui_path") then
            target = svc.Players.LocalPlayer:WaitForChild("PlayerGui")
        else
            target = svc.CoreGui
        end
        if target then
            scanAndTranslate(target)
            local conn = target.ChildAdded:Connect(function(child)
                task.wait(0.1)
                scanAndTranslate(child)
            end)
            table.insert(translateConn, conn)
            local textConn = target.DescendantAdded:Connect(function(desc)
                task.wait(0.05)
                if desc and desc:IsA("GuiObject") and desc.ClassName:find("Text") then
                    local ok, hasText = pcall(function() return desc.Text ~= nil end)
                    if ok and hasText then
                        local ok2, txt = pcall(function() return desc.Text end)
                        if ok2 and txt and txt ~= "" then
                            if not originalTexts[desc] then
                                originalTexts[desc] = txt
                                originalTexts.__count = (originalTexts.__count or 0) + 1
                                if originalTexts.__count > MAX_ORIGINAL_TEXTS then
                                    local k = next(originalTexts)
                                    local removed = 0
                                    while k and removed < 1000 do
                                        if k ~= "__count" then
                                            originalTexts[k] = nil
                                            removed = removed + 1
                                        end
                                        k = next(originalTexts, k)
                                    end
                                    originalTexts.__count = originalTexts.__count - removed
                                end
                            end
                            local translated = translateText(txt)
                            if translated ~= txt then
                                pcall(function() desc.Text = translated end)
                            end
                        end
                    end
                end
            end)
            table.insert(translateConn, textConn)
        end
    end
end

function stopAutoTranslate()
    if translateConn then
        for _, conn in ipairs(translateConn) do
            conn:Disconnect()
        end
        translateConn = nil
    end
    for obj, text in pairs(originalTexts) do
        if obj and obj.Parent then
            pcall(function()
                obj.Text = text
            end)
        end
    end
    originalTexts = {}
end

function getUserAgent()
    local platform = settingsData.networkHeader or "MacOS"
    local interface = settingsData.interfaceType or "Safari"
    local uaMap = {
        ["MacOS_Safari"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["MacOS_Chrome"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["MacOS_Edge"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Windows_Safari"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Windows_Chrome"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Windows_Edge"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Linux_Safari"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Linux_Chrome"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Linux_Edge"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        ["Android_Safari"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        ["Android_Chrome"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        ["Android_Edge"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        ["iOS_Safari"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        ["iOS_Chrome"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        ["iOS_Edge"] = "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        ["RobloxClient_RobloxHttpService"] = "Roblox-Client/1.0",
    }
    return uaMap[platform .. "_" .. interface] or uaMap["MacOS_Safari"]
end

function requestWithUA(url)
    local HttpService = svc.HttpService
    local ua = getUserAgent()
    local success, response = pcall(HttpService.RequestAsync, HttpService, {
        Url = url,
        Method = "GET",
        Timeout = 12,
        Headers = {
            ["User-Agent"] = ua,
            ["Accept"] = "text/plain, */*",
            ["Accept-Encoding"] = "identity",
            ["Cache-Control"] = "no-cache"
        }
    })
    if success and response and response.Success then
        return response.Body
    end
    return nil
end

function saveConfig(data)
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    local ok, json = pcall(svc.HttpService.JSONEncode, svc.HttpService, data)
    if ok and json then
        writefile(configFile, json)
        _G.__DeltaUI_cachedConfig = data
    end
end

function t(key)
    local cache = _G.__DeltaUI_tCache
    if not cache then
        cache = {}
        _G.__DeltaUI_tCache = cache
    end
    local lang = settingsData.language or "en"
    local cacheKey = lang .. "_" .. key
    if cache[cacheKey] then
        return cache[cacheKey]
    end
    local entry = translations[key]
    local result
    if entry then
        result = entry[lang] or entry.en or key
    else
        result = key
    end
    cache[cacheKey] = result
    return result
end

function registerTranslation(key, entry)
    if type(key) ~= "string" or type(entry) ~= "table" then
        return
    end
    if translations[key] then
        return
    end
    translations[key] = entry
end

cloudPage = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2})
cloudSearchBox = create("Frame", {Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -52, 0, 32), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 5})
corner(8, cloudSearchBox)
cloudSearchBox.Parent = cloudPage
cloudSearchIcon = GetIcon("search", UDim2.new(0, 14, 0, 14), theme.textDim)
if cloudSearchIcon then
    cloudSearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
    cloudSearchIcon.Parent = cloudSearchBox
end
cloudSearchInput = create("TextBox", {Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = t("search_cloud_placeholder"), PlaceholderColor3 = theme.textDim, TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ClearTextOnFocus = false, ZIndex = 4})
cloudSearchInput.Parent = cloudSearchBox
create("UIPadding", {PaddingLeft = UDim.new(0, 5)}).Parent = cloudSearchInput
table.insert(settingsData.uiRefs, {element = cloudSearchInput, key = "search_cloud_placeholder"})
cloudRefreshBtn = create("TextButton", {Position = UDim2.new(1, -38, 0, 8), Size = UDim2.new(0, 32, 0, 32), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, Text = "", ZIndex = 3})
corner(8, cloudRefreshBtn)
cloudRefreshBtn.Parent = cloudPage
cloudRefreshIcon = GetIcon("rotate-ccw", UDim2.new(0, 16, 0, 16), theme.text)
if cloudRefreshIcon then
    cloudRefreshIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    cloudRefreshIcon.Parent = cloudRefreshBtn
end
cloudRefreshBtn.MouseButton1Click:Connect(function()
    if cloudRefreshIcon then
        local rotation = 0
        local conn = svc.RunService.RenderStepped:Connect(function(dt)
            rotation = rotation - 720 * dt
            cloudRefreshIcon.Rotation = rotation
        end)
        task.delay(0.5, function()
            conn:Disconnect()
            cloudRefreshIcon.Rotation = 0
        end)
    end
    refreshScriptBloxList(cloudSearchInput.Text)
    ShowNotification(t("refresh_complete"), 1)
end)

cloudScroll = create("ScrollingFrame", {Position = UDim2.new(0, 12, 0, 52), Size = UDim2.new(1, -24, 1, -64), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = theme.textDim, CanvasSize = UDim2.new(0, 0, 0, 0), ClipsDescendants = true, ZIndex = 3})
cloudScroll.Parent = cloudPage
cloudScroll.Visible = false
cloudGrid = create("UIGridLayout", {CellSize = UDim2.new(0, 180, 0, 140), CellPadding = UDim2.new(0, 8, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Top, FillDirection = Enum.FillDirection.Horizontal})
cloudGrid.Parent = cloudScroll
cloudGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if cloudScroll and cloudGrid and cloudScroll.Parent then
        local absSize = cloudGrid.AbsoluteContentSize
        if absSize then
            cloudScroll.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 16)
        end
    end
end)

cacheFolder = "DeltaUI/Cache"
function ensureCacheFolder()
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder(cacheFolder) then makefolder(cacheFolder) end
end

function getCachedIcon(url, name)
    if not url or url == "" then return nil end
    if url:sub(1,13) == "rbxassetid://" then
        return url
    end
    ensureCacheFolder()
    local nameSafe = name and __safeFilterName(name) or ""
    local urlSafe = __safeFilterName(url)

    local cacheKey = nameSafe .. "_" .. urlSafe
    if #cacheKey > 120 then cacheKey = cacheKey:sub(1, 120) end
    local fp = cacheFolder .. "/img_" .. cacheKey .. ".png"
    local getasset = getcustomasset or getsynasset
    if isfile(fp) then
        if getasset then
            return getasset(fp)
        end
        return url
    end
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and data and data ~= "" then
        writefile(fp, data)
        if getasset then
            return getasset(fp)
        end
        return url
    end
    return nil
end
_G.__DeltaUI_getCachedIcon = getCachedIcon

modelFolder = "DeltaUI/Model"
patchFolder = "Delta/Patch"
exportFolder = "DeltaUI/Export"
function ensureExportFolder()
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder(exportFolder) then makefolder(exportFolder) end
end
function ensureModelFolder()
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder(modelFolder) then makefolder(modelFolder) end
end
function ensurePatchFolder()
    if not isfolder("Delta") then makefolder("Delta") end
    if not isfolder(patchFolder) then makefolder(patchFolder) end
end
assetFolder = "DeltaUI/Asset"
function ensureAssetFolder()
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder(assetFolder) then makefolder(assetFolder) end
end
function initFloatingBallIcon()
    ensureAssetFolder()
    local iconPath = assetFolder .. "/icon.png"
    if not isfile(iconPath) then
        local ok, imgData = pcall(function()
            return game:HttpGet("https://github.com/WasKKal/-/raw/refs/heads/main/IMG_2929.jpeg")
        end)
        if ok and imgData and imgData ~= "" then
            writefile(iconPath, imgData)
        end
    end
    if isfile(iconPath) then
        local getasset = getcustomasset or getsynasset
        if getasset then
            local assetUrl = getasset(iconPath)
            if assetUrl and assetUrl ~= "" then
                orbFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
                for _, child in pairs(orbFrame:GetChildren()) do
                    if child:IsA("ImageLabel") then
                        child:Destroy()
                    end
                end
                orbImg = create("ImageLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = assetUrl, ZIndex = 102})
                local orbCorner = orbFrame:FindFirstChildOfClass("UICorner")
                if orbCorner then
                    corner(orbCorner.CornerRadius.Offset, orbImg)
                else
                    corner(8, orbImg)
                end
                orbImg.Parent = orbFrame
            end
        end
    end
    local cfg = loadConfig()
    if cfg.orbBorderColor and type(cfg.orbBorderColor) == "table" then
        local c = cfg.orbBorderColor
        if c.r and c.g and c.b and orbStroke then
            orbStroke.Color = Color3.fromRGB(c.r, c.g, c.b)
        end
    end
end
_G.__DeltaUI_installedModules = installedModules

installedModules = {}

storeScriptFolder = "DeltaUI/StoreScripts"

function ensureStoreFolder()
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder(storeScriptFolder) then makefolder(storeScriptFolder) end
end

function loadInstalledModules()

function runAutoExecScripts()
    local cfg = loadConfig()
    if not cfg.autoExec then return end
    ensureFolder()
    ensureStoreFolder()
    local allScripts = {}
    local files = listfiles(saveFolder) or {}
    if files then
        for _, fp in ipairs(files) do
            if fp:sub(-4) == ".lua" then
local name = fp:gsub(".*[/]", ""):gsub("%.lua$", ""):gsub("%.json$", "")
                if name then
                    table.insert(allScripts, {name = name, path = fp, fromStore = false})
                end
            end
        end
    end
    local storeFiles = listfiles(storeScriptFolder) or {}
    if storeFiles then
        for _, fp in ipairs(storeFiles) do
            if fp:sub(-5) == ".json" then
                local txt = readfile(fp)
                if txt then
                    local meta = svc.HttpService:JSONDecode(txt)
                    if meta and meta.name then
                        table.insert(allScripts, {name = meta.name, path = fp, fromStore = true, meta = meta})
                    end
                end
            end
        end
    end
    for _, script in ipairs(allScripts) do
        if getAutoExecFileState(script.name) then
            local code
            if script.fromStore and script.meta and script.meta.Url then
                local src = game:HttpGet(script.meta.Url)
                if src then
                    code = src
                end
            else
                code = readfile(script.path)
            end
            if code and code ~= "" then
                local fn, err = loadstring(code)
                if fn then
                    local ok, execErr = xpcall(fn, function(err)
                        return debug.traceback(tostring(err), 2)
                    end)
                    if not ok then
                        warn("[DeltaUI] Autoexec error: " .. tostring(execErr))
                    end
                else
                    warn("[DeltaUI] Autoexec compile error: " .. tostring(err))
                end
            end
        end
    end
end

HookManager = {active = {}, originals = {}, hooks = {}}

function HookManager.getAvailableApi()
    local apis = {"hookfunction", "replaceclosure", "hookmetamethod", "hookfunc"}
    for _, name in ipairs(apis) do
        local ok, ref = pcall(function() return _G[name] or getfenv()[name] end)
        if ok and type(ref) == "function" then
            return ref, name
        end
    end
    return nil, nil
end

function HookManager.isRobloxFunc(fn)
    if type(fn) ~= "function" then return false end
    local ok, info = pcall(debug.getinfo, fn)
    if not ok or not info then return false end
    return info.what == "C" or info.source == "=[C]"
end

function HookManager.hook(target, replacement)
    if type(target) ~= "function" then
        warn("[HookManager] Target is not a function")
        return false
    end
    if type(replacement) ~= "function" then
        warn("[HookManager] Replacement is not a function")
        return false
    end
    local id = __safeFilterName(tostring(target))
    if HookManager.active[id] then
        HookManager.unhook(target)
    end
    local api, apiName = HookManager.getAvailableApi()
    local original = target
    local success = false
    if api and apiName == "hookfunction" then
        local ok, result = pcall(api, target, replacement)
        if ok and type(result) == "function" then
            original = result
            success = true
        end
    elseif api and apiName == "replaceclosure" then
        local ok, old = pcall(api, target, replacement)
        if ok then
            original = old or target
            success = true
        end
    end
    if not success then
        original = target
        local env = getfenv(target)
        if env and env.script then
            local ok, mt = pcall(getrawmetatable, env)
            if ok and mt and mt.__index and type(mt.__index) == "table" then
                for k, v in pairs(mt.__index) do
                    if v == target then
                        mt.__index[k] = replacement
                        success = true
                        break
                    end
                end
            end
        end
    end
    if not success then
        original = target
        success = true
    end
    HookManager.originals[id] = original
    HookManager.hooks[id] = replacement
    HookManager.active[id] = {
        target = target,
        replacement = replacement,
        original = original,
        api = apiName or "direct",
        direct = not api
    }
    if success and not api then
        local parent = getfenv(target)
        if parent then
            for k, v in pairs(parent) do
                if v == target then
                    parent[k] = replacement
                    HookManager.active[id].parent = parent
                    HookManager.active[id].key = k
                    break
                end
            end
        end
    end
    return success
end

function HookManager.unhook(target)
    local id = __safeFilterName(tostring(target))
    local record = HookManager.active[id]
    if not record then return false end
    local restored = false
    if record.api == "hookfunction" and HookManager.getAvailableApi() then
        local api = HookManager.getAvailableApi()
        if api and record.original then
            local ok = pcall(api, target, record.original)
            restored = ok
        end
    end
    if not restored and record.direct and record.parent and record.key then
        record.parent[record.key] = record.original
        restored = true
    end
    if not restored then
        local env = getfenv(target)
        if env then
            for k, v in pairs(env) do
                if v == record.replacement then
                    env[k] = record.original
                    restored = true
                    break
                end
            end
        end
    end
    if not restored and record.original then
        local gc = getgc and getgc()
        if gc then
            for _, obj in ipairs(gc) do
                if obj == record.replacement then
                    local ok = pcall(function()
                        local info = debug.getinfo(obj)
                        return info and info.func
                    end)
                    if not ok then
                        for i = 1, 10 do
                            local ok2, up = pcall(debug.getupvalue, obj, i)
                            if ok2 and up == record.replacement then
                                pcall(debug.setupvalue, obj, i, record.original)
                            end
                        end
                    end
                end
            end
        end
    end
    HookManager.active[id] = nil
    HookManager.originals[id] = nil
    HookManager.hooks[id] = nil
    return restored
end

function HookManager.callOriginal(id, ...)
    local orig = HookManager.originals[id]
    if type(orig) == "function" then
        return orig(...)
    end
    return nil
end

function HookManager.wrapAntiKick(targetPlayer)
    if not targetPlayer or typeof(targetPlayer) ~= "Instance" or not targetPlayer:IsA("Player") then
        warn("[HookManager] Invalid player instance")
        return nil, nil
    end
    local kickMethod = targetPlayer.Kick
    if not kickMethod then
        warn("[HookManager] Kick method not found")
        return nil, nil
    end
    local id = "Kick_" .. tostring(targetPlayer.UserId)
    local wrapper = function(self, ...)
        if self ~= targetPlayer then
            local ok, result = pcall(HookManager.callOriginal, id, self, ...)
            if ok then return result end
            return nil
        end
        warn("[DeltaUI] Kick blocked for " .. tostring(targetPlayer.Name))
        return nil
    end
    local ok = HookManager.hook(kickMethod, wrapper)
    if ok then
        return wrapper, function()
            HookManager.unhook(kickMethod)
        end
    end
    return nil, nil
end

function HookManager.wrapTeleport(targetService)
    local tp = targetService or game:GetService("TeleportService")
    local methods = {"Teleport", "TeleportToPlaceInstance", "TeleportAsync"}
    local unhookers = {}
    for _, name in ipairs(methods) do
        local fn = tp[name]
        if type(fn) == "function" then
            local wrapper = function(...)
                warn("[DeltaUI] Teleport blocked: " .. name)
                return nil
            end
            if HookManager.hook(fn, wrapper) then
                table.insert(unhookers, function()
                    HookManager.unhook(fn)
                end)
            end
        end
    end
    return function()
        for _, fn in ipairs(unhookers) do
            pcall(fn)
        end
    end
end

function HookManager.status()
    local count = 0
    for _ in pairs(HookManager.active) do count = count + 1 end
    return count, HookManager.getAvailableApi()
end

    installedModules = {}
    ensureModelFolder()
    local files = listfiles(modelFolder) or {}
    if files then
        for _, fp in ipairs(files) do
            if fp:sub(-5) == ".json" then
                local txt = readfile(fp)
                if txt then
                    local data = svc.HttpService:JSONDecode(txt)
                    if type(data) == "table" and data.name then
                        installedModules[data.name] = data
                    end
                end
            end
        end
    end
    ensurePatchFolder()
    local pfiles = listfiles(patchFolder) or {}
    if pfiles then
        for _, fp in ipairs(pfiles) do
            if fp:sub(-5) == ".json" then
                local txt = readfile(fp)
                if txt then
                    local data = svc.HttpService:JSONDecode(txt)
                    if type(data) == "table" and data.name then
                        installedModules[data.name] = data
                    end
                end
            end
        end
    end
    ensureStoreFolder()
    local sfiles = listfiles(storeScriptFolder) or {}
    if sfiles then
        for _, fp in ipairs(sfiles) do
            if fp:sub(-5) == ".json" then
                local txt = readfile(fp)
                if txt then
                    local data = svc.HttpService:JSONDecode(txt)
                    if type(data) == "table" and data.name then
                        installedModules[data.name] = data
                    end
                end
            end
        end
    end
end
loadInstalledModules()

function makeSettingRow(titleKey, descKey, layoutOrder)
    local row = create("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = layoutOrder, ZIndex = 4})
    corner(12, row)
    local tLabel = create("TextLabel", {Position = UDim2.new(0, 16, 0, 8), Size = UDim2.new(0.5, 0, 0, 22), BackgroundTransparency = 1, Text = t(titleKey), TextColor3 = theme.text, TextSize = 14, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    tLabel.Parent = row
    local dLabel = create("TextLabel", {Position = UDim2.new(0, 16, 0, 30), Size = UDim2.new(0.5, 0, 0, 18), BackgroundTransparency = 1, Text = t(descKey), TextColor3 = theme.textDim, TextSize = 11, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    dLabel.Parent = row
    table.insert(settingsData.uiRefs, {element = tLabel, key = titleKey})
    table.insert(settingsData.uiRefs, {element = dLabel, key = descKey})
    return row
end

function makeActionButton(key, parent, callback)
    local btn = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 110, 0, 32), BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(8, btn)
    local txt = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t(key), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12, Font = Enum.Font.SourceSansBold, ZIndex = 6})
    txt.Parent = btn
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        callback()

    end)
    table.insert(settingsData.uiRefs, {element = txt, key = key})
    return btn
end

function makeToggle(parent, initialState, callback, configKey)
    local cfg = loadConfig()
    local savedState = configKey and cfg[configKey]
    if savedState ~= nil then
        initialState = savedState
    end
    local toggleBg = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 48, 0, 26), BackgroundColor3 = initialState and theme.accent or theme.surfaceLight, BackgroundTransparency = 0.3, BorderSizePixel = 0, Text = "", ZIndex = 5})
    corner(13, toggleBg)

    local knob = create("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = initialState and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0), Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0, ZIndex = 6})
    corner(9, knob)
    knob.Parent = toggleBg
    toggleBg.Parent = parent
    local state = initialState
    toggleBg.MouseButton1Click:Connect(function()
        state = not state
        svc.TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and theme.accent or theme.surfaceLight}):Play()
        svc.TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)}):Play()
        callback(state)

        if configKey then
            local cfg2 = loadConfig()
            cfg2[configKey] = state
            saveConfig(cfg2)
        end
    end)
    local function setState(newState)
        if state == newState then return end
        state = newState
        svc.TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and theme.accent or theme.surfaceLight}):Play()
        svc.TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)}):Play()
        callback(state)
        if configKey then
            local cfg2 = loadConfig()
            cfg2[configKey] = state
            saveConfig(cfg2)
        end
    end
    return toggleBg, function() return state end, setState
end

function makeDropdown(parent, options, defaultIndex, callback, configKey)
    local cfg = loadConfig()
    local savedValue = configKey and cfg[configKey]
    local current = options[defaultIndex] or options[1]
    if savedValue then
        for i, opt in ipairs(options) do
            if opt == savedValue then
                current = opt
                break
            end
        end
    end

    if configKey == "language" and savedValue then
        local reverseLangMap = {en = "English", zh = "中文", ko = "한국어", ja = "日本語"}
        local mapped = reverseLangMap[savedValue]
        if mapped then
            current = mapped
        end
    end
    local btn = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 120, 0, 32), BackgroundColor3 = theme.surfaceLight, BackgroundTransparency = 0.3, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(8, btn)
    local txt = create("TextLabel", {Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Text = current, TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})
    txt.Parent = btn
    local arrow = GetIcon("chevron-down", UDim2.new(0, 14, 0, 14), theme.textDim)
    if arrow then
        arrow.Position = UDim2.new(1, -20, 0.5, -7)
        arrow.Parent = btn
    end
    btn.Parent = parent
    local dropdownOpen = false
    local listFrame = nil

    if not _G.__DeltaUI_dropdowns then _G.__DeltaUI_dropdowns = {} end
    table.insert(_G.__DeltaUI_dropdowns, {btn = btn, close = function()
        if dropdownOpen and listFrame then
            listFrame:Destroy()
            listFrame = nil
            dropdownOpen = false
        end
        if _G.__DeltaUI_dropdownOverlay then
            _G.__DeltaUI_dropdownOverlay:Destroy()
            _G.__DeltaUI_dropdownOverlay = nil
        end
    end})

    btn.MouseButton1Click:Connect(function()
        if dropdownOpen and listFrame then
            listFrame:Destroy()
            listFrame = nil
            dropdownOpen = false
            if _G.__DeltaUI_dropdownOverlay then
                _G.__DeltaUI_dropdownOverlay:Destroy()
                _G.__DeltaUI_dropdownOverlay = nil
            end
            return
        end

        for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
            if dd.btn ~= btn and dd.close then
                dd.close()
            end
        end

        dropdownOpen = true

        local screenGuiAncestor = btn:FindFirstAncestorOfClass("ScreenGui")
        local overlay = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 998,
            BorderSizePixel = 0
        })
        overlay.Parent = screenGuiAncestor
        _G.__DeltaUI_dropdownOverlay = overlay

        overlay.MouseButton1Click:Connect(function()
            for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
                if dd.close then dd.close() end
            end
        end)

        listFrame = create("Frame", {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 120, 0, #options * 30),
            BackgroundColor3 = theme.surfaceLight,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 999,
            ClipsDescendants = false
        })
        corner(8, listFrame)
        stroke(theme.border, 1, listFrame)
        listFrame.Parent = screenGuiAncestor
        task.defer(function()
            if listFrame and listFrame.Parent then
                listFrame.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 4)
                listFrame.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 30)
            end
        end)
        local scrollConn = nil
        scrollConn = svc.RunService.RenderStepped:Connect(function()
            if not listFrame or not listFrame.Parent then
                if scrollConn then scrollConn:Disconnect() end
                return
            end
            if btn and btn.Parent then
                listFrame.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 4)
            end
        end)
        for i, opt in ipairs(options) do
            local optBtn = create("TextButton", {Position = UDim2.new(0, 0, 0, (i-1)*30), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "", ZIndex = 1000})
            local optTxt = create("TextLabel", {Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = opt, TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1001})
            optTxt.Parent = optBtn
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                current = opt
                txt.Text = current
                if scrollConn then scrollConn:Disconnect() end
                if listFrame then
                    listFrame:Destroy()
                    listFrame = nil
                end
                dropdownOpen = false
                if _G.__DeltaUI_dropdownOverlay then
                    _G.__DeltaUI_dropdownOverlay:Destroy()
                    _G.__DeltaUI_dropdownOverlay = nil
                end
                local saveValue = callback(current)
                if configKey then
                    local cfg2 = loadConfig()
                    cfg2[configKey] = saveValue or current
                    saveConfig(cfg2)
                end
            end)
        end
    end)
    local function setValue(val)
        for _, opt in ipairs(options) do
            if opt == val then
                current = val
                txt.Text = current
                break
            end
        end
    end
    local function updateOptions(newOptions)
        options = newOptions

        local found = false
        for _, opt in ipairs(options) do
            if opt == current then
                found = true
                break
            end
        end
        if not found and #options > 0 then
            current = options[1]
            txt.Text = current
        end
    end
    return btn, function() return current end, setValue, updateOptions
end

function makeMultiDropdown(parent, options, defaultSelected, callback, configKey)
    local cfg = loadConfig()
    local savedValue = configKey and cfg[configKey]
    local selected = {}
    if savedValue and type(savedValue) == "table" then
        for _, v in ipairs(savedValue) do
            selected[v] = true
        end
    elseif defaultSelected and type(defaultSelected) == "table" then
        for _, v in ipairs(defaultSelected) do
            selected[v] = true
        end
    end

    local btn = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 120, 0, 32), BackgroundColor3 = theme.surfaceLight, BackgroundTransparency = 0.3, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(8, btn)
    local txt = create("TextLabel", {Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Text = "Select", TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})
    txt.Parent = btn
    local arrow = GetIcon("chevron-down", UDim2.new(0, 14, 0, 14), theme.textDim)
    if arrow then
        arrow.Position = UDim2.new(1, -20, 0.5, -7)
        arrow.Parent = btn
    end
    btn.Parent = parent

    local function updateDisplay()
        local count = 0
        local display = ""
        for opt, isSel in pairs(selected) do
            if isSel then
                count = count + 1
                display = opt
            end
        end
        if count == 0 then
            txt.Text = "Select"
        elseif count == 1 then
            txt.Text = display
        else
            txt.Text = count .. " selected"
        end
    end
    updateDisplay()

    local dropdownOpen = false
    local listFrame = nil

    if not _G.__DeltaUI_dropdowns then _G.__DeltaUI_dropdowns = {} end
    table.insert(_G.__DeltaUI_dropdowns, {btn = btn, close = function()
        if dropdownOpen and listFrame then
            listFrame:Destroy()
            listFrame = nil
            dropdownOpen = false
        end
        if _G.__DeltaUI_dropdownOverlay then
            _G.__DeltaUI_dropdownOverlay:Destroy()
            _G.__DeltaUI_dropdownOverlay = nil
        end
    end})

    btn.MouseButton1Click:Connect(function()
        if dropdownOpen and listFrame then
            listFrame:Destroy()
            listFrame = nil
            dropdownOpen = false
            return
        end

        for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
            if dd.btn ~= btn and dd.close then
                dd.close()
            end
        end

        dropdownOpen = true

        local screenGuiAncestor = btn:FindFirstAncestorOfClass("ScreenGui")
        local overlay = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 998,
            BorderSizePixel = 0
        })
        overlay.Parent = screenGuiAncestor
        _G.__DeltaUI_dropdownOverlay = overlay

        overlay.MouseButton1Click:Connect(function()
            for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
                if dd.close then dd.close() end
            end
        end)

        listFrame = create("Frame", {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 120, 0, #options * 34),
            BackgroundColor3 = theme.surfaceLight,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 999,
            ClipsDescendants = false
        })
        corner(8, listFrame)
        stroke(theme.border, 1, listFrame)
        listFrame.Parent = screenGuiAncestor
        task.defer(function()
            if listFrame and listFrame.Parent then
                listFrame.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 4)
                listFrame.Size = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 34)
            end
        end)
        local scrollConn = nil
        scrollConn = svc.RunService.RenderStepped:Connect(function()
            if not listFrame or not listFrame.Parent then
                if scrollConn then scrollConn:Disconnect() end
                return
            end
            if btn and btn.Parent then
                listFrame.Position = UDim2.new(0, btn.AbsolutePosition.X, 0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 4)
            end
        end)
        for i, opt in ipairs(options) do
            local optBtn = create("TextButton", {Position = UDim2.new(0, 0, 0, (i-1)*34), Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", ZIndex = 1000})

            local checkBox = create("Frame", {Position = UDim2.new(0, 10, 0.5, -7), Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = selected[opt] and theme.accent or theme.surfaceLight, BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 1001})
            corner(3, checkBox)
            checkBox.Parent = optBtn

            local optTxt = create("TextLabel", {Position = UDim2.new(0, 30, 0, 0), Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = opt, TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1001})
            optTxt.Parent = optBtn
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                selected[opt] = not selected[opt]
                svc.TweenService:Create(checkBox, TweenInfo.new(0.15), {BackgroundColor3 = selected[opt] and theme.accent or theme.surfaceLight}):Play()
                updateDisplay()
                local result = {}
                for k, v in pairs(selected) do
                    if v then table.insert(result, k) end
                end
                callback(result)
                if configKey then
                    local cfg2 = loadConfig()
                    cfg2[configKey] = result
                    saveConfig(cfg2)
                end
            end)
        end
    end)

    local function getSelected()
        local result = {}
        for k, v in pairs(selected) do
            if v then table.insert(result, k) end
        end
        return result
    end

    local function setSelected(vals)
        selected = {}
        for _, v in ipairs(vals) do
            selected[v] = true
        end
        updateDisplay()
    end

    return btn, getSelected, setSelected
end
_G.__DeltaUI_t = t

tpService = game:GetService("TeleportService")
vUser = game:GetService("VirtualUser")

pages = {}

settingsPage = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2})
pages["settings"] = settingsPage

settingsScroll = create("ScrollingFrame", {Position = UDim2.new(0, 12, 0, 12), Size = UDim2.new(1, -24, 1, -24), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = theme.textDim, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3})
settingsScroll.Parent = settingsPage

settingsList = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
settingsList.Parent = settingsScroll
settingsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if settingsScroll and settingsScroll.Parent then
        local absSize = settingsList.AbsoluteContentSize
        if absSize then
            settingsScroll.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 20)
        end
    end
end)

rowBypass = makeSettingRow("bypass_ui_detection", "bypass_ui_detection_desc", -2)
makeToggle(rowBypass, false, function(state)
    local cfgBypass = loadConfig()
    cfgBypass.bypassUiDetection = state
    saveConfig(cfgBypass)
    task.wait(0.3)
    pcall(function()
        tpService:TeleportToPlaceInstance(game.PlaceId, game.JobId, v7)
    end)
end, "bypassUiDetection")
rowBypass.Parent = settingsScroll

rowAutoAcceptExec = makeSettingRow("auto_accept_exec", "auto_accept_exec_desc", -1)
makeToggle(rowAutoAcceptExec, false, function(state)
    local cfg = loadConfig()
    cfg.autoAcceptExec = state
    saveConfig(cfg)
end, "autoAcceptExec")
rowAutoAcceptExec.Parent = settingsScroll

rowInit = makeSettingRow("init_ui", "init_ui_desc", -1)
local function onInitUI()
    local function deleteFolder(path)
        local files = listfiles(path) or {}
        for _, fp in ipairs(files) do
            if isfile(fp) then
                pcall(delfile, fp)
            elseif isfolder(fp) then
                pcall(deleteFolder, fp)
                pcall(delfolder, fp)
            end
        end
    end
    if isfolder("DeltaUI") then
        deleteFolder("DeltaUI")
    end
    if isfolder("DeltaUI") then
        deleteFolder("DeltaUI")
    end
    ShowNotification(t("complete"), 2)
end
makeActionButton("click_here", rowInit, onInitUI)
rowInit.Parent = settingsScroll

row0 = makeSettingRow("language", "language_desc", 0)
local function onLanguageChange(val)
    local langMap = {["English"] = "en", ["中文"] = "zh", ["한국어"] = "ko", ["日本語"] = "ja"}
    settingsData.language = langMap[val] or "en"
    for _, ref in ipairs(settingsData.uiRefs) do
        if ref.element and ref.element.Parent then
            ref.element.Text = t(ref.key)
        end
    end

    local cfg = loadConfig()
    cfg.language = settingsData.language
    saveConfig(cfg)
    return settingsData.language
end
makeDropdown(row0, {"English", "中文", "한국어", "日本語"}, 1, onLanguageChange, "language")
row0.Parent = settingsScroll

row1 = makeSettingRow("rejoin", "rejoin_desc", 1)
local function onRejoin()
    tpService:TeleportToPlaceInstance(game.PlaceId, game.JobId, v7)
end
makeActionButton("click_here", row1, onRejoin)
row1.Parent = settingsScroll

row2 = makeSettingRow("small_server", "small_server_desc", 2)
local function onSmallServer()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local targetServerId = nil
    local cursor = ""
    for _ = 1, 5 do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        local raw = nil
        local ok1, r1 = pcall(function() return requestWithUA(url) end)
        if ok1 and r1 and r1 ~= "" then raw = r1
        else
            local ok2, r2 = pcall(function() return game:HttpGet(url) end)
            if ok2 and r2 and r2 ~= "" then raw = r2 end
        end
        if not raw or raw == "" then break end
        local ok3, data = pcall(svc.HttpService.JSONDecode, svc.HttpService, raw)
        if not ok3 or not data or not data.data then break end
        local candidates = {}
        for _, srv in ipairs(data.data) do
            if srv.playing < srv.maxPlayers and srv.id ~= currentJobId then
                table.insert(candidates, srv)
            end
        end
        table.sort(candidates, function(a, b) return a.playing < b.playing end)
        if #candidates > 0 then
            targetServerId = candidates[1].id
            break
        end
        cursor = data.nextPageCursor or ""
        if not cursor or cursor == "" then break end
    end
    if targetServerId then
        pcall(function() tpService:TeleportToPlaceInstance(placeId, targetServerId, v7) end)
    else
        pcall(function() tpService:Teleport(placeId, v7) end)
    end
end
makeActionButton("click_here", row2, onSmallServer)
row2.Parent = settingsScroll

row4 = makeSettingRow("fps_cap", "fps_cap_desc", 4)
makeDropdown(row4, {t("fps_30"), t("fps_60"), t("fps_120"), t("fps_240"), t("fps_360"), t("fps_unlimited")}, 2, function(val)
    local numStr = ""
                for i = 1, #val do
                    local c = val:sub(i,i)
                    if c >= "0" and c <= "9" then numStr = numStr .. c end
                end
                local num = tonumber(numStr)
    local cap = num or 0
    if setfpscap then
        setfpscap(cap)
    end
end
, "fpsCap")
row4.Parent = settingsScroll

row9 = makeSettingRow("anti_afk", "anti_afk_desc", 9)
makeToggle(row9, true, function(state)
    if state then
        if settingsData.afkConnection then
            settingsData.afkConnection:Disconnect()
        end
        settingsData.afkConnection = v7.Idled:Connect(function()
            vUser:CaptureController()
            vUser:ClickButton2(Vector2.new())
        end)
    else
        if settingsData.afkConnection then
            settingsData.afkConnection:Disconnect()
            settingsData.afkConnection = nil
        end
    end
end, "antiAfk"
)
row9.Parent = settingsScroll

rowAntiKick = makeSettingRow("anti_kick", "anti_kick_desc", 8)
makeToggle(rowAntiKick, false, function(state)
    if state then
        local ok, wrapper, unhook = pcall(HookManager.wrapAntiKick, v7)
        if ok and wrapper then
            settingsData.kickUnhooker = unhook
            settingsData.kickBlocked = true
        else
            warn("[DeltaUI] AntiKick hook failed")
            settingsData.kickBlocked = false
        end
    else
        if settingsData.kickUnhooker then
            local ok = pcall(settingsData.kickUnhooker)
            if not ok then warn("[DeltaUI] AntiKick unhook failed") end
            settingsData.kickUnhooker = nil
        end
        settingsData.kickBlocked = nil
    end
    local cfg = loadConfig()
    cfg.antiKick = state
    saveConfig(cfg)
end, "antiKick")
rowAntiKick.Parent = settingsScroll

row11 = makeSettingRow("auto_execute", "auto_execute_desc", 11)
makeToggle(row11, true, function(state)
    if state then
        runAutoExecScripts()
    end
end, "autoExec"
)
row11.Parent = settingsScroll

rowCompat = makeSettingRow("compatibility_mode", "compatibility_mode_desc", 11.5)
makeToggle(rowCompat, false, function(state)
    local cfg = loadConfig()
    cfg.compatibilityMode = state
    saveConfig(cfg)
    if state and AntiTamper then
        AntiTamper.stop()
    end
end, "compatibilityMode")
rowCompat.Parent = settingsScroll

rowAutoTrans = makeSettingRow("auto_translate", "auto_translate_desc", 11.6)
makeToggle(rowAutoTrans, false, function(state)
    local cfg = loadConfig()
    cfg.autoTranslate = state
    saveConfig(cfg)
    if state then
        startAutoTranslate()
    else
        stopAutoTranslate()
    end
end, "autoTranslate")
rowAutoTrans.Parent = settingsScroll

rowTransPath = makeSettingRow("translate_path", "translate_path_desc", 11.7)
makeMultiDropdown(rowTransPath, {t("coregui_path"), t("playergui_path")}, {t("coregui_path")}, function(vals)
    local cfg = loadConfig()
    cfg.translatePaths = vals
    saveConfig(cfg)
end, "translatePaths")
rowTransPath.Parent = settingsScroll

extDivider = create("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = theme.border, BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = 12, ZIndex = 4})
extDivider.Parent = settingsScroll

extHeader = create("TextLabel", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = t("extension_package_options"), TextColor3 = theme.accent, TextSize = 14, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 13, ZIndex = 4})
extHeader.Parent = settingsScroll
table.insert(settingsData.uiRefs, {element = extHeader, key = "extension_package_options"})

rowOrb = makeSettingRow("customize_floating_ball", "customize_floating_ball_desc", 14)
orbInput = create("TextBox", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0, 200, 0, 32),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.4,
    Text = "",
    PlaceholderText = t("enter_image_url"),
    PlaceholderColor3 = theme.textDim,
    TextColor3 = theme.text,
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 5
})
corner(8, orbInput)
stroke(theme.border, 1, orbInput)
orbInput.Parent = rowOrb
create("UIPadding", {PaddingLeft = UDim.new(0, 5)}).Parent = orbInput
table.insert(settingsData.uiRefs, {element = orbInput, key = "enter_image_url"})
rowOrb.Parent = settingsScroll

orbConfirmBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -220, 0.5, 0),
    Size = UDim2.new(0, 120, 0, 32),
    BackgroundColor3 = theme.accent,
    BackgroundTransparency = 0.25,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(8, orbConfirmBtn)
orbConfirmText = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = t("confirm_changes"),
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 6
})
orbConfirmText.Parent = orbConfirmBtn
table.insert(settingsData.uiRefs, {element = orbConfirmText, key = "confirm_changes"})
orbConfirmBtn.Parent = rowOrb
orbConfirmBtn.MouseButton1Click:Connect(function()
    local url = orbInput.Text
    if url == "" or url == t("enter_image_url") then
        ShowNotification(t("invalid_image"), 1)
        return
    end
    if not (url:sub(1,7) == "http://" or url:sub(1,8) == "https://") then
        ShowNotification(t("invalid_image"), 1)
        return
    end
    orbConfirmBtn.Active = false
    local assetUrl = ParseImageAsset(url)
    if not assetUrl or assetUrl == "" then
        ShowNotification(t("invalid_image"), 1)
        orbConfirmBtn.Active = true
        return
    end
    orbFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    for _, child in pairs(orbFrame:GetChildren()) do
        if child:IsA("ImageLabel") then
            child:Destroy()
        end
    end
    orbImg = create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = assetUrl,
        ZIndex = 102
    })
    local orbCorner = orbFrame:FindFirstChildOfClass("UICorner")
    if orbCorner then
        corner(orbCorner.CornerRadius.Offset, orbImg)
    else
        corner(8, orbImg)
    end
    orbImg.Parent = orbFrame
    ShowNotification(t("image_updated"), 1)
    orbConfirmBtn.Active = true
end)

rowLabel = makeSettingRow("customize_label", "customize_label_desc", 15)
labelInput = create("TextBox", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0, 200, 0, 32),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.4,
    Text = "",
    PlaceholderText = t("enter_label_text"),
    PlaceholderColor3 = theme.textDim,
    TextColor3 = theme.text,
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 5
})
corner(8, labelInput)
stroke(theme.border, 1, labelInput)
labelInput.Parent = rowLabel
create("UIPadding", {PaddingLeft = UDim.new(0, 5)}).Parent = labelInput
table.insert(settingsData.uiRefs, {element = labelInput, key = "enter_label_text"})
rowLabel.Parent = settingsScroll

labelConfirmBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -220, 0.5, 0),
    Size = UDim2.new(0, 120, 0, 32),
    BackgroundColor3 = theme.accent,
    BackgroundTransparency = 0.25,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(8, labelConfirmBtn)
labelConfirmText = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = t("confirm_changes"),
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 6
})
labelConfirmText.Parent = labelConfirmBtn
table.insert(settingsData.uiRefs, {element = labelConfirmText, key = "confirm_changes"})
labelConfirmBtn.Parent = rowLabel
labelConfirmBtn.MouseButton1Click:Connect(function()
    local text = labelInput.Text
    if text == "" or text == t("enter_label_text") then
        ShowNotification(t("invalid_input"), 1)
        return
    end
    if labelText then
        labelText.Text = text
        local textWidth = labelText.TextBounds.X + 28
        labelPill.Size = UDim2.new(0, math.max(55, textWidth), 0, 22)
    end
    local cfg = loadConfig()
    cfg.customLabel = text
    saveConfig(cfg)
    ShowNotification(t("label_updated"), 1)
end)

extGuide = create("TextLabel", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = t("custom_icon_guide"), TextColor3 = theme.textDim, TextSize = 11, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, LayoutOrder = 15, ZIndex = 4})
extGuide.Parent = settingsScroll
table.insert(settingsData.uiRefs, {element = extGuide, key = "custom_icon_guide"})

rowNetworkHeader = makeSettingRow("network_request_header", "network_request_header_desc", 16)
local function onNetworkHeaderChange(val)
    settingsData.networkHeader = val
    local cfg = loadConfig()
    cfg.networkHeader = val
    saveConfig(cfg)
    if val == "RobloxClient" then
        if interfaceDropdownSetValue then
            interfaceDropdownSetValue("RobloxHttpService")
        end
        if updateInterfaceOptions then
            updateInterfaceOptions({"RobloxHttpService"})
        end
    else
        if updateInterfaceOptions then
            updateInterfaceOptions({"Safari", "Chrome", "Edge", "RobloxHttpService"})
        end
        if interfaceDropdownSetValue and getInterfaceTypeValue and getInterfaceTypeValue() == "RobloxHttpService" then
            interfaceDropdownSetValue("Safari")
        end
    end
    return val
end
getNetworkHeaderValue, setNetworkHeaderValue = makeDropdown(rowNetworkHeader, {"MacOS", "Windows", "Linux", "Android", "iOS", "RobloxClient"}, 1, onNetworkHeaderChange, "networkHeader")
rowNetworkHeader.Parent = settingsScroll

rowInterfaceType = makeSettingRow("interface_type", "interface_type_desc", 17)
local function onInterfaceTypeChange(val)
    settingsData.interfaceType = val
    local cfg = loadConfig()
    cfg.interfaceType = val
    saveConfig(cfg)
    if val == "RobloxHttpService" then
        if setNetworkHeaderValue and getNetworkHeaderValue and getNetworkHeaderValue() ~= "RobloxClient" then
            setNetworkHeaderValue("RobloxClient")
        end
    else
        if setNetworkHeaderValue and getNetworkHeaderValue and getNetworkHeaderValue() == "RobloxClient" then
            setNetworkHeaderValue("MacOS")
        end
    end
    return val
end
getInterfaceTypeValue, interfaceDropdownSetValue, updateInterfaceOptions = makeDropdown(rowInterfaceType, {"Safari", "Chrome", "Edge", "RobloxHttpService"}, 1, onInterfaceTypeChange, "interfaceType")
rowInterfaceType.Parent = settingsScroll

consoleDivider = create("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = theme.border, BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = 18, ZIndex = 4})
consoleDivider.Parent = settingsScroll

consoleHeader = create("TextLabel", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = t("console_settings"), TextColor3 = theme.accent, TextSize = 14, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 19, ZIndex = 4})
consoleHeader.Parent = settingsScroll

row10 = makeSettingRow("console", "console_desc", 10)
makeToggle(row10, true, function(state)
    consoleEnabled = state
end, "console"
)
row10.Parent = settingsScroll
table.insert(settingsData.uiRefs, {element = consoleHeader, key = "console_settings"})

rowBlockInternal = makeSettingRow("block_internal_errors", "block_internal_errors_desc", 20)
makeToggle(rowBlockInternal, true, function(state)
    if state then
        if not _G.__DeltaUI_blockInternalConn then
            _G.__DeltaUI_blockInternalConn = game:GetService("LogService").MessageOut:Connect(function(msg, msgtype)
                local msgStr = tostring(msg)
                if msgStr:find("Overlay is not a valid member of ImageLabel")
                    or msgStr:find("Error is not a valid member of Folder")
                    or msgStr:find("ConsoleElements")
                    or msgStr:find("AppDelegate")
                    or msgStr:find("Arrow is not a valid member of ImageButton")
                then
                    return
                end
            end)
        end
    else
        if _G.__DeltaUI_blockInternalConn then
            _G.__DeltaUI_blockInternalConn:Disconnect()
            _G.__DeltaUI_blockInternalConn = nil
        end
    end
    local cfg = loadConfig()
    cfg.blockInternalErrors = state
    saveConfig(cfg)
end, "blockInternalErrors")
rowBlockInternal.Parent = settingsScroll

rowRealLine = makeSettingRow("real_line_numbers", "real_line_numbers_desc", 21)
makeToggle(rowRealLine, true, function(state)
    local cfg = loadConfig()
    cfg.realLineNumbers = state
    saveConfig(cfg)
end, "realLineNumbers")
rowRealLine.Parent = settingsScroll

rowDetailedErrors = makeSettingRow("detailed_errors", "detailed_errors_desc", 22)
makeToggle(rowDetailedErrors, false, function(state)
    local cfg = loadConfig()
    cfg.detailedErrors = state
    saveConfig(cfg)
end, "detailedErrors")
rowDetailedErrors.Parent = settingsScroll

rowErrorTranslation = makeSettingRow("error_translation", "error_translation_desc", 23)
makeToggle(rowErrorTranslation, true, function(state)
    settingsData.errorTranslation = state
    local cfg = loadConfig()
    cfg.errorTranslation = state
    saveConfig(cfg)
end, "errorTranslation")
rowErrorTranslation.Parent = settingsScroll

rowBlockServer = makeSettingRow("block_server_errors", "block_server_errors_desc", 24)
makeToggle(rowBlockServer, true, function(state)
    settingsData.blockServerErrors = state
    local cfg = loadConfig()
    cfg.blockServerErrors = state
    saveConfig(cfg)
end, "blockServerErrors")
rowBlockServer.Parent = settingsScroll

rowBlockAsset = makeSettingRow("block_asset_errors", "block_asset_errors_desc", 25)
makeToggle(rowBlockAsset, true, function(state)
    settingsData.blockAssetErrors = state
    local cfg = loadConfig()
    cfg.blockAssetErrors = state
    saveConfig(cfg)
end, "blockAssetErrors")
rowBlockAsset.Parent = settingsScroll

rowNotif = makeSettingRow("disable_notifications", "disable_notifications_desc", 25.1)
makeToggle(rowNotif, false, function(state)
    local cfg = loadConfig()
    cfg.disableNotifications = state
    saveConfig(cfg)
end, "disableNotifications")
rowNotif.Parent = settingsScroll

deepDivider = create("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = theme.border, BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = 25.5, ZIndex = 4})
deepDivider.Parent = settingsScroll

deepHeader = create("TextLabel", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = t("deep_customization"), TextColor3 = theme.accent, TextSize = 14, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 25.6, ZIndex = 4})
deepHeader.Parent = settingsScroll
table.insert(settingsData.uiRefs, {element = deepHeader, key = "deep_customization"})

deepRow = makeSettingRow("customize_tabs", "customize_tabs_desc", 25.7)
makeActionButton("customize_tabs_btn", deepRow, function()
    enterCustomTabMode()
end)
deepRow.Parent = settingsScroll

resetRow = makeSettingRow("reset_tab_order", "reset_switcher_desc", 25.8)
makeActionButton("reset_tab_order", resetRow, function()
    resetTabOrder()
end)
resetRow.Parent = settingsScroll

row5 = makeSettingRow("icon_size", "icon_size_desc", 25.9)
makeDropdown(row5, {t("size_small"), t("size_medium"), t("size_large")}, 2, function(val)
    local sz = val == t("size_small") and 25 or val == t("size_medium") and 35 or 45
    orbFrame.Size = UDim2.new(0, sz, 0, sz)
    if orbImg then
        orbImg.Size = UDim2.new(1, 0, 1, 0)
    end
    local currentShape = getIconShape and getIconShape() or t("shape_circle")
    applyIconShape(currentShape)
end
, "iconSize")
row5.Parent = settingsScroll

row6 = makeSettingRow("icon_shape", "icon_shape_desc", 26)
local function applyIconShape(val)
    if not orbFrame then return end
    for _, c in pairs(orbFrame:GetChildren()) do
        if c:IsA("UICorner") then c:Destroy() end
    end
    if orbImg then
        for _, c in pairs(orbImg:GetChildren()) do
            if c:IsA("UICorner") then c:Destroy() end
        end
    end
    if val == t("shape_circle") then
        corner(orbFrame.Size.X.Offset/2, orbFrame)
        if orbImg then corner(orbFrame.Size.X.Offset/2, orbImg) end
    elseif val == t("shape_rounded") then
        corner(8, orbFrame)
        if orbImg then corner(8, orbImg) end
    end
end
local _, getIconShape = makeDropdown(row6, {t("shape_circle"), t("shape_square"), t("shape_rounded")}, 1, function(val)
    applyIconShape(val)
end, "iconShape")
task.defer(function()
    if getIconShape then applyIconShape(getIconShape()) end
end)
row6.Parent = settingsScroll

function createColorPickerRow(titleKey, descKey, layoutOrder, configKey, defaultColor, callback)
    local row = create("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = layoutOrder, ZIndex = 4})
    corner(12, row)
    local tLabel = create("TextLabel", {Position = UDim2.new(0, 16, 0, 8), Size = UDim2.new(0.5, 0, 0, 22), BackgroundTransparency = 1, Text = t(titleKey), TextColor3 = theme.text, TextSize = 14, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    tLabel.Parent = row
    local dLabel = create("TextLabel", {Position = UDim2.new(0, 16, 0, 30), Size = UDim2.new(0.5, 0, 0, 18), BackgroundTransparency = 1, Text = t(descKey), TextColor3 = theme.textDim, TextSize = 11, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    dLabel.Parent = row
    table.insert(settingsData.uiRefs, {element = tLabel, key = titleKey})
    table.insert(settingsData.uiRefs, {element = dLabel, key = descKey})
    local cfg = loadConfig()
    local savedColor = cfg[configKey]
    local currentColor = defaultColor
    if savedColor and type(savedColor) == "table" and savedColor.r and savedColor.g and savedColor.b then
        currentColor = Color3.fromRGB(savedColor.r, savedColor.g, savedColor.b)
    end
    local colorBtn = create("TextButton", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 32, 0, 32), BackgroundColor3 = currentColor, BackgroundTransparency = 0, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(8, colorBtn)
    colorBtn.Parent = row
    local function saveColor(c)
        local cfg2 = loadConfig()
        cfg2[configKey] = {r = math.floor(c.R * 255), g = math.floor(c.G * 255), b = math.floor(c.B * 255)}
        saveConfig(cfg2)
    end
    colorBtn.MouseButton1Click:Connect(function()
        showColorPicker(currentColor, function(newColor)
            currentColor = newColor
            colorBtn.BackgroundColor3 = newColor
            saveColor(newColor)
            if callback then callback(newColor) end
        end)
    end)
    return row, function() return currentColor end, function(c)
        currentColor = c
        colorBtn.BackgroundColor3 = c
        saveColor(c)
        if callback then callback(c) end
    end
end

function showColorPicker(initialColor, onConfirm)
    local pickerOverlay = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 900, Active = true, Visible = true})
    pickerOverlay.Parent = screenGui
    local pickerCard = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 280, 0, 320), BackgroundColor3 = theme.surface, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 901, Active = true})
    corner(16, pickerCard)
    pickerCard.Parent = pickerOverlay
    local pickerTitle = create("TextLabel", {Position = UDim2.new(0, 20, 0, 14), Size = UDim2.new(1, -40, 0, 24), BackgroundTransparency = 1, Text = t("select_color"), TextColor3 = theme.text, TextSize = 16, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 902})
    pickerTitle.Parent = pickerCard
    local closeBtn = create("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 14), Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, Text = "", ZIndex = 903})
    local closeIcon = GetIcon("x", UDim2.new(0, 16, 0, 16), theme.textDim)
    if closeIcon then closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8); closeIcon.Parent = closeBtn end
    closeBtn.Parent = pickerCard
    local hueFrame = create("Frame", {Position = UDim2.new(0, 20, 0, 50), Size = UDim2.new(1, -40, 0, 16), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 902})
    corner(8, hueFrame)
    hueFrame.Parent = pickerCard
    local hueGradient = create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
    hueGradient.Parent = hueFrame
    local hueKnob = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 12, 0, 22), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 903})
    corner(6, hueKnob)
    stroke(Color3.fromRGB(100, 100, 100), 2, hueKnob)
    hueKnob.Parent = hueFrame
    local svFrame = create("Frame", {Position = UDim2.new(0, 20, 0, 78), Size = UDim2.new(1, -40, 0, 140), BackgroundColor3 = Color3.fromRGB(255, 0, 0), BorderSizePixel = 0, ZIndex = 902})
    corner(8, svFrame)
    svFrame.Parent = pickerCard
    local whiteOverlay = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 903})
    corner(8, whiteOverlay)
    whiteOverlay.Parent = svFrame
    local satGradient = create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})
    satGradient.Parent = whiteOverlay
    local blackOverlay = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 904})
    corner(8, blackOverlay)
    blackOverlay.Parent = svFrame
    local valGradient = create("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
    valGradient.Parent = blackOverlay
    local svKnob = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 12, 0, 12), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 905})
    corner(6, svKnob)
    stroke(Color3.fromRGB(100, 100, 100), 2, svKnob)
    svKnob.Parent = svFrame
    local previewFrame = create("Frame", {Position = UDim2.new(0, 20, 0, 228), Size = UDim2.new(1, -40, 0, 36), BackgroundColor3 = initialColor, BorderSizePixel = 0, ZIndex = 902})
    corner(8, previewFrame)
    previewFrame.Parent = pickerCard
    local confirmBtn = create("TextButton", {Position = UDim2.new(0, 20, 1, -48), Size = UDim2.new(1, -40, 0, 36), BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25, Text = "", BorderSizePixel = 0, ZIndex = 902})
    corner(8, confirmBtn)
    confirmBtn.Parent = pickerCard
    local confirmText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("confirm_changes"), TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13, Font = Enum.Font.SourceSansBold, ZIndex = 903})
    confirmText.Parent = confirmBtn
    local currentH, currentS, currentV = 0, 1, 1
    local function rgbToHsv(r, g, b)
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h, s, v
        v = max
        local d = max - min
        s = max == 0 and 0 or d / max
        if max == min then h = 0
        elseif max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
        return h, s, v
    end
    local function hsvToRgb(h, s, v)
        local r, g, b
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        i = i % 6
        if i == 0 then r, g, b = v, t, p
        elseif i == 1 then r, g, b = q, v, p
        elseif i == 2 then r, g, b = p, v, t
        elseif i == 3 then r, g, b = p, q, v
        elseif i == 4 then r, g, b = t, p, v
        else r, g, b = v, p, q end
        return Color3.new(r, g, b)
    end
    local ir, ig, ib = initialColor.R, initialColor.G, initialColor.B
    currentH, currentS, currentV = rgbToHsv(ir, ig, ib)
    hueKnob.Position = UDim2.new(currentH, 0, 0.5, 0)
    svKnob.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
    local function updateSVBackground()
        svFrame.BackgroundColor3 = hsvToRgb(currentH, 1, 1)
    end
    local function updateColor()
        local newColor = hsvToRgb(currentH, currentS, currentV)
        previewFrame.BackgroundColor3 = newColor
        return newColor
    end
    updateSVBackground()
    updateColor()
    local hueDragging, svDragging = false, false
    local function updateHueFromInput(input)
        local relX = math.clamp(input.Position.X - hueFrame.AbsolutePosition.X, 0, hueFrame.AbsoluteSize.X)
        currentH = relX / hueFrame.AbsoluteSize.X
        hueKnob.Position = UDim2.new(currentH, 0, 0.5, 0)
        updateSVBackground()
        updateColor()
    end
    local function updateSVFromInput(input)
        local relX = math.clamp(input.Position.X - svFrame.AbsolutePosition.X, 0, svFrame.AbsoluteSize.X)
        local relY = math.clamp(input.Position.Y - svFrame.AbsolutePosition.Y, 0, svFrame.AbsoluteSize.Y)
        currentS = relX / svFrame.AbsoluteSize.X
        currentV = 1 - relY / svFrame.AbsoluteSize.Y
        svKnob.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
        updateColor()
    end
    hueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            updateHueFromInput(input)
        end
    end)
    svFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            updateSVFromInput(input)
        end
    end)
    local inputConn = nil
    inputConn = svc.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if hueDragging then updateHueFromInput(input) end
            if svDragging then updateSVFromInput(input) end
        end
    end)
    local endConn = nil
    endConn = svc.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = false
            svDragging = false
        end
    end)
    local function closePicker()
        if inputConn then inputConn:Disconnect() inputConn = nil end
        if endConn then endConn:Disconnect() endConn = nil end
        svc.TweenService:Create(pickerCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        for _, child in pairs(pickerCard:GetDescendants()) do
            if child:IsA("GuiObject") then
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    svc.TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    svc.TweenService:Create(child, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
                elseif child:IsA("Frame") then
                    svc.TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                end
            end
        end
        svc.TweenService:Create(pickerOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.delay(0.25, function()
            pickerOverlay:Destroy()
        end)
    end
    closeBtn.MouseButton1Click:Connect(closePicker)
    pickerOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local cardPos = pickerCard.AbsolutePosition
            local cardSize = pickerCard.AbsoluteSize
            if pos.X < cardPos.X or pos.X > cardPos.X + cardSize.X or pos.Y < cardPos.Y or pos.Y > cardPos.Y + cardSize.Y then
                closePicker()
            end
        end
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        onConfirm(previewFrame.BackgroundColor3)
        closePicker()
    end)
    svc.TweenService:Create(pickerOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.6}):Play()
    svc.TweenService:Create(pickerCard, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
end

orbColorRow = createColorPickerRow("orb_border_color", "orb_border_color_desc", 26.1, "orbBorderColor", theme.accent, function(newColor)
    if orbStroke then
        orbStroke.Color = newColor
    end
end)
orbColorRow.Parent = settingsScroll

maxLogEntries = 500
logEntryCount = 0
pendingLogs = {}
logProcessing = false

local defaultEditorText = [=[
--[[
      Thank you for using DeltaBeautify <3
      ReBuild By Was
      QQGroup: 786284990
      QQ: 1763356884
]]
]=]

local errorTranslationCache = {}

function translateError(msg)
    if not settingsData.errorTranslation then return msg end
    local lang = settingsData.language or "en"
    local cacheKey = lang .. "|" .. msg
    if errorTranslationCache[cacheKey] then return errorTranslationCache[cacheKey] end

    local mappings = {
        ["attempt to perform arithmetic %(sub%) on nil"] = {en = "attempt to perform arithmetic (sub) on nil", zh = "尝试对 nil 执行减法运算", ko = "nil에 대해 산술 연산(빼기) 시도", ja = "nilに対して算術演算（引き算）を試みました"},
        ["attempt to call missing method"] = {en = "attempt to call missing method", zh = "尝试调用缺失的方法", ko = "누락된 메서드 호출 시도", ja = "欠落したメソッドを呼び出そうとしました"},
        ["table index is nil"] = {en = "table index is nil", zh = "表索引为 nil", ko = "테이블 인덱스가 nil", ja = "テーブルインデックスがnilです"},
        ["Expected '%)'"] = {en = "Expected ')'", zh = "需要 ')'", ko = "')'가 필요함", ja = "')'が必要です"},
        ["Expected 'do'"] = {en = "Expected 'do'", zh = "需要 'do'", ko = "'do'가 필요함", ja = "'do'が必要です"},
        ["got 'local'"] = {en = "got 'local'", zh = "但得到了 'local'", ko = "'local'을 받음", ja = "'local'が見つかりました"},
        ["got 'elseif'"] = {en = "got 'elseif'", zh = "但得到了 'elseif'", ko = "'elseif'를 받음", ja = "'elseif'が見つかりました"},
        ["got '~'"] = {en = "got '~'", zh = "但得到了 '~'", ko = "'~'를 받음", ja = "'~'が見つかりました"},
        ["attempt to index nil with"] = {en = "attempt to index nil with", zh = "尝试访问 nil 的值", ko = "nil 값에 접근 시도", ja = "nilの値にアクセスしようとしました"},
        ["attempt to call a nil value"] = {en = "attempt to call a nil value", zh = "尝试调用 nil 值", ko = "nil 값 호출 시도", ja = "nil値を呼び出そうとしました"},
        ["Malformed string"] = {en = "Malformed string", zh = "字符串格式错误", ko = "잘못된 문자열", ja = "不正な文字列"},
        ["unexpected symbol"] = {en = "unexpected symbol", zh = "意外符号", ko = "예기치 않은 기호", ja = "予期しない記号"},
        ["Expected 'end'"] = {en = "Expected 'end'", zh = "缺少 'end'", ko = "'end'가 필요함", ja = "'end'が必要です"},
        ["Expected 'then'"] = {en = "Expected 'then'", zh = "缺少 'then'", ko = "'then'이 필요함", ja = "'then'が必要です"},
        ["attempt to perform arithmetic on a nil value"] = {en = "attempt to perform arithmetic on a nil value", zh = "尝试对 nil 进行算术运算", ko = "nil에 대한 산술 연산 시도", ja = "nilに対する算術演算を試みました"},
        ["attempt to concatenate a nil value"] = {en = "attempt to concatenate a nil value", zh = "尝试连接 nil 值", ko = "nil 값 연결 시도", ja = "nil値の連結を試みました"},
        ["stack overflow"] = {en = "stack overflow", zh = "堆栈溢出", ko = "스택 오버플로우", ja = "スタックオーバーフロー"},
        ["attempt to yield across a C%-call boundary"] = {en = "attempt to yield across a C-call boundary", zh = "尝试在 C 调用边界 yield", ko = "C 호출 경계에서 yield 시도", ja = "C呼び出し境界でyieldを試みました"},
        ["invalid argument"] = {en = "invalid argument", zh = "无效参数", ko = "잘못된 인수", ja = "無効な引数"},
        ["table expected"] = {en = "table expected", zh = "需要表", ko = "테이블 필요", ja = "テーブルが必要です"},
        ["string expected"] = {en = "string expected", zh = "需要字符串", ko = "문자열 필요", ja = "文字列が必要です"},
        ["number expected"] = {en = "number expected", zh = "需要数字", ko = "숫자 필요", ja = "数字が必要です"},
        ["Expected identifier when parsing expression, got Unicode character"] = {en = "Expected identifier when parsing expression, got Unicode character", zh = "解析表达式时需要标识符，但得到了Unicode字符", ko = "식을 파싱하는 중 식별자가 필요하지만 Unicode 문자를 받았습니다", ja = "式を解析する際に識別子が必要ですが、Unicode文字が見つかりました"},
        ["Expected identifier when parsing expression, got"] = {en = "Expected identifier when parsing expression, got", zh = "解析表达式时需要标识符，但得到了", ko = "식을 파싱하는 중 식별자가 필요하지만 받은 것은", ja = "式を解析する際に識別子が必要ですが、見つかったのは"},
        ["Expected identifier when parsing expression"] = {en = "Expected identifier when parsing expression", zh = "解析表达式时需要标识符", ko = "식을 파싱하는 중 식별자가 필요함", ja = "式を解析する際に識別子が必要です"},
        ["Expected identifier"] = {en = "Expected identifier", zh = "需要标识符", ko = "식별자가 필요함", ja = "識別子が必要です"},
        [", got"] = {en = ", got", zh = ", 但得到了", ko = ", 받은 것은", ja = ", 見つかったのは"},
        ["Expected <eof>"] = {en = "Expected <eof>", zh = "期望文件结束", ko = "<eof>가 필요함", ja = "<eof>が必要です"},
        ["Unicode character"] = {en = "Unicode character", zh = "Unicode字符", ko = "Unicode 문자", ja = "Unicode文字"},
        ["at line"] = {en = "at line", zh = "在行", ko = "줄", ja = "行"},
        ["to close"] = {en = "to close", zh = "关闭", ko = "닫기", ja = "閉じる"},
        ["did you forget to close"] = {en = "did you forget to close", zh = "你是否忘记关闭", ko = "닫는 것을 잊으셨나요", ja = "閉じるのを忘れましたか"},
        ["attempt to index a nil value"] = {en = "attempt to index a nil value", zh = "尝试索引 nil 值", ko = "nil 값 인덱싱 시도", ja = "nil値をインデックスしようとしました"},
        ["attempt to get length of a nil value"] = {en = "attempt to get length of a nil value", zh = "尝试获取 nil 值的长度", ko = "nil 값의 길이를 얻으려고 시도함", ja = "nil値の長さを取得しようとしました"},
        ["attempt to compare nil with"] = {en = "attempt to compare nil with", zh = "尝试将 nil 与", ko = "nil을 다음과 비교 시도", ja = "nilを次と比較しようとしました"},
        ["bad argument"] = {en = "bad argument", zh = "错误参数", ko = "잘못된 인수", ja = "不正な引数"},
        ["function expected"] = {en = "function expected", zh = "需要函数", ko = "함수 필요", ja = "関数が必要です"},
        ["nil value"] = {en = "nil value", zh = "nil 值", ko = "nil 값", ja = "nil値"},
        ["invalid value"] = {en = "invalid value", zh = "无效值", ko = "잘못된 값", ja = "無効な値"},
        ["out of memory"] = {en = "out of memory", zh = "内存不足", ko = "메모리 부족", ja = "メモリ不足"},
        ["too many arguments"] = {en = "too many arguments", zh = "参数过多", ko = "인수가 너무 많음", ja = "引数が多すぎます"},
        ["attempt to call a string value"] = {en = "attempt to call a string value", zh = "尝试调用字符串值", ko = "문자열 값 호출 시도", ja = "文字列値を呼び出そうとしました"},
        ["attempt to call a table value"] = {en = "attempt to call a table value", zh = "尝试调用表值", ko = "테이블 값 호출 시도", ja = "テーブル値を呼び出そうとしました"},
        ["Arrow is not a valid member of"] = {en = "Arrow is not a valid member of", zh = "Arrow 不是有效的成员", ko = "Arrow는 유효한 멤버가 아님", ja = "Arrowは有効なメンバーではありません"},
        ["Overlay is not a valid member of"] = {en = "Overlay is not a valid member of", zh = "Overlay 不是有效的成员", ko = "Overlay는 유효한 멤버가 아님", ja = "Overlayは有効なメンバーではありません"},
        ["Error is not a valid member of"] = {en = "Error is not a valid member of", zh = "Error 不是有效的成员", ko = "Error는 유효한 멤버가 아님", ja = "Errorは有効なメンバーではありません"},
        ["Unable to cast"] = {en = "Unable to cast", zh = "无法转换类型", ko = "캐스팅할 수 없음", ja = "キャストできません"},
        ["Infinite yield possible on"] = {en = "Infinite yield possible on", zh = "可能产生无限等待", ko = "무한 대기 가능성", ja = "無限待機の可能性"},
        ["Players.LocalPlayer"] = {en = "Players.LocalPlayer", zh = "玩家.本地玩家", ko = "플레이어.로컬플레이어", ja = "プレイヤー.ローカルプレイヤー"},
        ["ReplicatedStorage"] = {en = "ReplicatedStorage", zh = "复制存储", ko = "복제 저장소", ja = "レプリケイテッドストレージ"},
        ["ServerScriptService"] = {en = "ServerScriptService", zh = "服务器脚本服务", ko = "서버 스크립트 서비스", ja = "サーバースクリプトサービス"},
        ["StarterGui"] = {en = "StarterGui", zh = "初始界面", ko = "스타터 GUI", ja = "スターターGUI"},
        ["attempt to call missing method"] = {en = "attempt to call missing method", zh = "尝试调用缺失的方法", ko = "누락된 메서드 호출 시도", ja = "欠落したメソッドを呼び出そうとしました"},
        ["table index is nil"] = {en = "table index is nil", zh = "表索引为 nil", ko = "테이블 인덱스가 nil", ja = "テーブルインデックスがnilです"},
        ["Expected '%)'"] = {en = "Expected ')'", zh = "需要 ')'", ko = "')'가 필요함", ja = "')'が必要です"},
        ["Expected 'do'"] = {en = "Expected 'do'", zh = "需要 'do'", ko = "'do'가 필요함", ja = "'do'が必要です"},
        ["got 'local'"] = {en = "got 'local'", zh = "但得到了 'local'", ko = "'local'을 받음", ja = "'local'が見つかりました"},
        ["got 'elseif'"] = {en = "got 'elseif'", zh = "但得到了 'elseif'", ko = "'elseif'를 받음", ja = "'elseif'が見つかりました"},
        ["got '~'"] = {en = "got '~'", zh = "但得到了 '~'", ko = "'~'를 받음", ja = "'~'が見つかりました"},
        ["attempt to perform arithmetic %(sub%) on nil"] = {en = "attempt to perform arithmetic (sub) on nil", zh = "尝试对 nil 执行减法运算", ko = "nil에 대해 산술 연산(빼기) 시도", ja = "nilに対して算術演算（引き算）を試みました"},
    }
    local result = msg

    local sortedPatterns = {}
    for pattern, trans in pairs(mappings) do
        table.insert(sortedPatterns, {pattern = pattern, trans = trans, len = #pattern})
    end
    table.sort(sortedPatterns, function(a, b) return a.len > b.len end)
    for _, entry in ipairs(sortedPatterns) do
        if result:find(entry.pattern) then
            local replacement = entry.trans[lang] or entry.trans.en or entry.pattern
            local ok, newResult = pcall(function()
                return result:gsub(entry.pattern, replacement)
            end)
            if ok then
                result = newResult
            end
        end
    end
    if #errorTranslationCache > 200 then errorTranslationCache = {} end
    errorTranslationCache[cacheKey] = result
    return result
end

function AddLog(message, level)
    if not consoleEnabled or not consoleScroll then
        return
    end

    local msgStr = tostring(message)
    if level == "error" then
        msgStr = translateError(msgStr)
    end

    local lineNum = nil
    local lineStart, lineEnd = msgStr:find("Line", 1, true)
    if lineStart then
        local afterLine = msgStr:sub(lineEnd + 1)
        local numStr = ""
        for i = 1, #afterLine do
            local c = afterLine:sub(i, i)
            if c >= "0" and c <= "9" then
                numStr = numStr .. c
            elseif #numStr > 0 then
                break
            elseif c ~= " " and c ~= "  " then
                break
            end
        end
        lineNum = tonumber(numStr)
    end
    if lineNum and not _G.__DeltaUI_skipLineOffset then
        local offset = 0
        local currentText = tabs[currentTab] and tabs[currentTab].content or ""
        if type(currentText) == "string" and currentText:sub(1, 3) == "--[" then
            local blockEnd = currentText:find("]]", 1, true)
            if blockEnd then
                local header = currentText:sub(1, blockEnd + 2)
                for _ in header:gmatch(string.char(10)) do
                    offset = offset + 1
                end
            end
        end
        local realLine = tonumber(lineNum) - offset
        if realLine > 0 then
            msgStr = msgStr:gsub("Line%s+" .. lineNum, "Line " .. realLine .. " " .. t("real_line"))
        end
    end

    table.insert(pendingLogs, {msg = msgStr, lvl = level or "info"})

    if logProcessing then return end
    logProcessing = true
    task.defer(function()
        while #pendingLogs > 0 do
            local batch = {}
            for i = 1, math.min(10, #pendingLogs) do
                local item = table.remove(pendingLogs, 1)
                if item then
                    batch[i] = item
                end
            end
            if not consoleScroll then break end
            for _, log in ipairs(batch) do
                if log then
                    local color = theme.text
                    if log.lvl == "error" then color = theme.red
                    elseif log.lvl == "warn" then color = theme.warn
                    elseif log.lvl == "info" then color = theme.textDim end
                    local entry = create("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = log.msg,
                        TextColor3 = color,
                        TextSize = 11,
                        Font = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextWrapped = true,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        ZIndex = 4
                    })
                    entry.Parent = consoleScroll
                    logEntryCount = logEntryCount + 1
                    if logEntryCount > maxLogEntries then
                        for _, child in pairs(consoleScroll:GetChildren()) do
                            if child:IsA("TextLabel") then
                                child:Destroy()
                                logEntryCount = logEntryCount - 1
                                break
                            end
                        end
                    end
                end
            end
            if #pendingLogs > 0 then
                task.wait(0.05)
            end
        end
        logProcessing = false
    end)
end

saveFolder = "DeltaUI/Script"
function ensureFolder()
    if not isfolder("DeltaUI") then
        makefolder("DeltaUI")
    end
    if not isfolder(saveFolder) then
        makefolder(saveFolder)
    end
    return true
end

autoExecFolder = "DeltaUI/AutoExecute"
function ensureAutoExecFolder()
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder(autoExecFolder) then makefolder(autoExecFolder) end
end

function getAutoExecFileState(name)
    ensureAutoExecFolder()
    local safeName = __safeFilterName(name:gsub("%s+", "_"))
    if safeName == "" then safeName = "untitled" end
    local fp = autoExecFolder .. "/" .. safeName .. ".json"
    if isfile(fp) then
        local txt = readfile(fp)
        if txt then
            local data = svc.HttpService:JSONDecode(txt)
            if type(data) == "table" and data.enabled ~= nil then
                return data.enabled
            end
        end
    end
    return false
end

function setAutoExecFileState(name, enabled)
    ensureAutoExecFolder()
    local safeName = __safeFilterName(name:gsub("%s+", "_"))
    if safeName == "" then safeName = "untitled" end
    local fp = autoExecFolder .. "/" .. safeName .. ".json"
    local data = svc.HttpService:JSONEncode({enabled = enabled, name = name})
    writefile(fp, data)
end
function hasExecutorDescendant(container)
    for _, d in pairs(container:GetDescendants()) do
        if d.Name == "Executor" then
            return true
        end
    end
    return false
end

function destroyExecutorUI(container)
    if hasExecutorDescendant(container) then
        container:Destroy()
        return true
    end
    return false
end

function getClipboardContent()
    local apis = {
        getclipboard,
        GetClipBoard,
        (syn and syn.getclipboard),
        (clipboard and clipboard.get),
        (get_clipboard),
        (getgenv and getgenv().getclipboard),
        (getgenv and getgenv().GetClipBoard),
    }
    for _, api in ipairs(apis) do
        if type(api) == "function" then
            local ok, result = pcall(api)
            if ok and result and result ~= "" then
                return result
            end
        end
    end
    local fallbackPaths = {
        "clipboard.txt",
        "DeltaUI/clipboard.txt",
    }
    for _, path in ipairs(fallbackPaths) do
        if isfile and isfile(path) then
            local ok, result = pcall(readfile, path)
            if ok and result and result ~= "" then
                return result
            end
        end
    end
    return nil
end
function generateHash64()
    local chars = "0123456789abcdef"
    local hash = ""
    for i = 1, 16 do
        local idx = math.random(1, 16)
        hash = hash .. chars:sub(idx, idx)
    end
    return hash
end

local function getUiName()
    local cfg = loadConfig()
    if cfg and cfg.compatibilityMode then

        return "DeltaUI_7f9a2b4c6d8e1035"
    end
    return generateHash64()
end

local containerName = getUiName()
local oldContainer = svc.CoreGui:FindFirstChild(containerName)
if oldContainer then
    oldContainer:Destroy()
    task.wait(0.05)
end
local uiContainer = create("Folder", {Name = containerName})
uiContainer.Parent = svc.CoreGui

screenGui = create("ScreenGui", {Name = getUiName(), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 999999})
screenGui.Parent = uiContainer

main = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = theme.bg, BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, Visible = true, ZIndex = 1})
main.Parent = screenGui

currentNotifProgressTween = nil
notificationQueue = {}
notificationActive = false

function ShowNotification(message, duration, clickCallback)
    local cfg = loadConfig()
    if cfg.disableNotifications then return end
    duration = duration or 1
    table.insert(notificationQueue, {msg = message, dur = duration, click = clickCallback})
    if notificationActive then
        _G.__DeltaUI_skipNotification = true
        if currentNotifProgressTween then
            currentNotifProgressTween:Cancel()
            currentNotifProgressTween = nil
        end
        return
    end
    task.spawn(function()
        while #notificationQueue > 0 do
            notificationActive = true
            _G.__DeltaUI_skipNotification = false

            if currentNotifFrame and currentNotifFrame.Parent then
                svc.TweenService:Create(currentNotifFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -60)}):Play()
                svc.TweenService:Create(currentNotifFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                for _, child in pairs(currentNotifFrame:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        svc.TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
                    elseif child:IsA("Frame") then
                        svc.TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    end
                end
                task.wait(0.2)
                if currentNotifFrame and currentNotifFrame.Parent then
                    currentNotifFrame:Destroy()
                end
            end
            local notif = table.remove(notificationQueue, 1)
            local notifFrame = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, -60),
                Size = UDim2.new(0, 0, 0, 40),
                BackgroundColor3 = theme.surface,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                ZIndex = 500,
                Active = notif.click and true or false,
                ClipsDescendants = true
            })
            corner(10, notifFrame)
            stroke(theme.border, 1, notifFrame)
            notifFrame.Parent = screenGui
            currentNotifFrame = notifFrame
            local notifText = create("TextLabel", {
                Size = UDim2.new(1, 0, 1, -4),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = notif.msg,
                TextColor3 = theme.text,
                TextSize = 12,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 501
            })
            notifText.Parent = notifFrame
            local notifProgress = create("Frame", {
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 4, 1, -4),
                Size = UDim2.new(1, -8, 0, 3),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 502,
                ClipsDescendants = true
            })
            corner(2, notifProgress)
            notifProgress.Parent = notifFrame
            if notif.click then
                notifFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        notif.click()
                    end
                end)
            end
            svc.TweenService:Create(notifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 12)}):Play()
            local notifWidth = math.min(380, math.max(200, notifText.TextBounds.X + 40))
            svc.TweenService:Create(notifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, notifWidth, 0, 40)}):Play()
            task.wait(0.35)
            currentNotifProgressTween = svc.TweenService:Create(notifProgress, TweenInfo.new(notif.dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
            currentNotifProgressTween:Play()
            local elapsed = 0
            while elapsed < notif.dur do
                if _G.__DeltaUI_skipNotification then
                    break
                end
                task.wait(0.05)
                elapsed = elapsed + 0.05
            end
            currentNotifProgressTween = nil
            svc.TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -60)}):Play()
            svc.TweenService:Create(notifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            svc.TweenService:Create(notifText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            svc.TweenService:Create(notifProgress, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            notifFrame:Destroy()
        end
        notificationActive = false
    end)
end
topBar = create("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10})
topBar.Parent = main
navBg = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 1),
    Size = UDim2.new(0, 240, 0, 38),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 11
})
corner(20, navBg)
navBg.Parent = topBar
logoutBtn = create("TextButton", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 150, 0.5, 1),
    Size = UDim2.new(0, 36, 0, 36),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Text = "",
    ZIndex = 11
})
corner(20, logoutBtn)
logoutBtn.Parent = topBar
logoutIcon = GetIcon("minimize", UDim2.new(0, 18, 0, 18), theme.text)
if logoutIcon then
    logoutIcon.Position = UDim2.new(0.5, -9.2, 0.5, -9)
    logoutIcon.Parent = logoutBtn
end
navContainer = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 12
})
navContainer.Parent = navBg
navNames = {"house", "terminal", "gamepad-2", "package", "atom", "settings"}
navButtons = {}
btnXPositions = {4, 44, 84, 124, 164, 204}
for i, name in ipairs(navNames) do
    btn = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, btnXPositions[i], 0, 3),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 15
    })
    icon = GetIcon(name, UDim2.new(0, 18, 0, 18))
    if icon then
        icon.Position = UDim2.new(0.5, -9, 0.5, -9)
        icon.Parent = btn
    end
    btn.Parent = navContainer
    navButtons[name] = btn
end

navIndicator = create("Frame", {
    Size = UDim2.new(0, 32, 0, 32),
    BackgroundColor3 = theme.accent,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 10
})
corner(16, navIndicator)
navIndicator.Parent = navBg
local function getIndicatorCenterPos(btn)
    local btnPos = btn.Position
    local btnSize = btn.Size
    local indSize = navIndicator.Size
    local offsetX = (btnSize.X.Offset - indSize.X.Offset) / 2
    local offsetY = (btnSize.Y.Offset - indSize.Y.Offset) / 2
    return UDim2.new(btnPos.X.Scale, btnPos.X.Offset + offsetX, btnPos.Y.Scale, btnPos.Y.Offset + offsetY)
end
navIndicator.Position = getIndicatorCenterPos(navButtons[navNames[1]])
function animateIndicator(targetBtn)
    local targetPos = getIndicatorCenterPos(targetBtn)
    svc.TweenService:Create(navIndicator, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end
function cleanupOldUI()
    local cfg = loadConfig()
    local compatMode = cfg.compatibilityMode
    if compatMode then
        for _, child in pairs(svc.CoreGui:GetChildren()) do
            if #child.Name > 20 then
                for _, sub in pairs(child:GetChildren()) do
                    if sub:FindFirstChild("MainScript") then
                        pcall(function()
                            sub.Enabled = false
                        end)
                    end
                end
            end
        end
        if not _G.__DeltaUI_fileCleaned then
            _G.__DeltaUI_fileCleaned = true
            pcall(function()
                if isfile("TALENTLESS_language.txt") then
                    delfile("TALENTLESS_language.txt")
                end
            end)
        end
    else
        for _, child in pairs(svc.CoreGui:GetChildren()) do
            if #child.Name > 20 then
                destroyExecutorUI(child)
            end
        end
    end
end

function switchPage(pageName)
    for _, child in pairs(screenGui:GetChildren()) do
        if child:IsA("Frame") and child.ZIndex == 999 then
            child:Destroy()
        end
    end

    for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
        if dd.close then dd.close() end
    end
    if pageName == currentPage then return end
    currentPage = pageName
    for _, page in pairs(pages) do
        page.Visible = false
    end
    if pages[pageName] then
        pages[pageName].Visible = true
    end
    if bottomBar then
        bottomBar.Visible = (pageName == "house")
    end
    if navButtons[pageName] then
        animateIndicator(navButtons[pageName])
    end
    if pageName == "package" then
        if cloudSearchInput then cloudSearchInput.Text = "" end
    end
end
function refreshScriptList(filter)
    if _G.__DeltaUI_refreshScriptLock then return end
    _G.__DeltaUI_refreshScriptLock = true
        for _, child in pairs(scriptListScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    ensureFolder()
    ensureStoreFolder()

    local allScripts = {}

    local files = listfiles(saveFolder) or {}
    if files then
        for _, filePath in ipairs(files) do
local name = filePath:match("([^/]*)%.lua$") or filePath:match("([^/]*)$")
            if name then
                local metaPath = filePath:sub(-4)==".lua" and (filePath:sub(1,-5)..".meta.json") or (filePath..".meta.json")
                local serversList = {}
                if isfile(metaPath) then
                    local metaTxt = readfile(metaPath)
                    if metaTxt then
                        local ok, meta = pcall(function()
                            return svc.HttpService:JSONDecode(metaTxt)
                        end)
                        if ok and meta and meta.servers then
                            serversList = meta.servers
                        end
                    end
                end
                table.insert(allScripts, {name = name, path = filePath, fromStore = false, servers = serversList})
            end
        end
    end

    local storeFiles = listfiles(storeScriptFolder) or {}
    if storeFiles then
        for _, filePath in ipairs(storeFiles) do
            if filePath:sub(-5)==".json" then
                local txt = readfile(filePath)
                if txt then
                    local meta = svc.HttpService:JSONDecode(txt)
                    if meta and meta.name then
                        table.insert(allScripts, {name = meta.name, path = filePath, fromStore = true, meta = meta})
                    end
                end
            end
        end
    end

    local seenNames = {}
    for _, script in ipairs(allScripts) do
        local name = script.name
        local filePath = script.path
        if name and (not filter or filter == "" or name:lower():find(filter:lower())) then
            if not seenNames[name] then
                seenNames[name] = true
            do
                local scriptRef = script
                local item = create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = theme.surface,
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                ZIndex = 4
            })
            corner(10, item)
            local itemTitle = create("TextLabel", {
                Position = UDim2.new(0, 14, scriptRef.fromStore and 0 or 0, scriptRef.fromStore and 6 or 0),
                Size = UDim2.new(0.5, 0, scriptRef.fromStore and 0 or 1, scriptRef.fromStore and 20 or 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = theme.text,
                TextSize = 15,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 5
            })
            itemTitle.Parent = item

            local serversList = script.servers or (script.meta and script.meta.Servers) or {}
            if script.fromStore then
                local storeBadge = create("TextLabel", {
                    Position = UDim2.new(0, 14, 0, 26),
                    Size = UDim2.new(0, 120, 0, 14),
                    BackgroundTransparency = 1,
                    Text = t("from_store") .. (script.meta and script.meta.Version and " v" .. script.meta.Version or ""),
                    TextColor3 = theme.accent,
                    TextSize = 10,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    ZIndex = 5
                })
                storeBadge.Parent = item
            end

            local delBtn = create("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -107, 0.5, 0),
                Size = UDim2.new(0, 70, 0, 28),
                BackgroundColor3 = theme.surfaceLight,
                BackgroundTransparency = 0.3,
                Text = "",
                BorderSizePixel = 0,
                ZIndex = 5
            })
            corner(8, delBtn)
            local delText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("delete"), TextColor3 = theme.text, TextSize = 11, Font = Enum.Font.SourceSansBold, ZIndex = 6})
            delText.Parent = delBtn
            delBtn.Parent = item
            delBtn.MouseButton1Click:Connect(function()
                if scriptRef.fromStore then
                    if removeStoreScript then
                        removeStoreScript(name)
                    else
                        if isfile(filePath) then delfile(filePath) end
                        refreshScriptList(searchInput.Text)
                    end
                    ShowNotification(t("deleted") or "Deleted", 1)
                    return
                end
                delfile(filePath)
                local metaPath = filePath:sub(-4)==".lua" and (filePath:sub(1,-5)..".meta.json") or (filePath..".meta.json")
                if isfile(metaPath) then
                    delfile(metaPath)
                end
                item:Destroy()
                refreshScriptList(searchInput.Text)
            end)

            local execBtn2 = create("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -34, 0.5, 0),
                Size = UDim2.new(0, 70, 0, 28),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = 0.3,
                Text = "",
                BorderSizePixel = 0,
                ZIndex = 5
            })
            corner(8, execBtn2)
            local execText2 = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("execute_cap"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11, Font = Enum.Font.SourceSansBold, ZIndex = 6})
            execText2.Parent = execBtn2
            execBtn2.Parent = item

            do
                local scriptName = name
                local autoExecEnabled = getAutoExecFileState(scriptName)
                local autoExecBtn = create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -3, 0.5, 0),
                    Size = UDim2.new(0, 28, 0, 28),
                    BackgroundColor3 = autoExecEnabled and theme.accent or theme.surfaceLight,
                    BackgroundTransparency = 0.25,
                    Text = "",
                    BorderSizePixel = 0,
                    ZIndex = 5
                })
                corner(6, autoExecBtn)
                local autoExecIcon = GetIcon("file-terminal", UDim2.new(0, 14, 0, 14), Color3.fromRGB(255,255,255))
                if autoExecIcon then
                    autoExecIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
                    autoExecIcon.Parent = autoExecBtn
                end
                autoExecBtn.Parent = item
                autoExecBtn.MouseButton1Click:Connect(function()
                    autoExecEnabled = not autoExecEnabled
                    setAutoExecFileState(scriptName, autoExecEnabled)
                    svc.TweenService:Create(autoExecBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = autoExecEnabled and theme.accent or theme.surfaceLight}):Play()
                    if autoExecEnabled then
                        ShowNotification(t("autoexec_enabled"), 1)
                    else
                        ShowNotification(t("autoexec_disabled"), 1)
                    end
                end)
            end
            execBtn2.MouseButton1Click:Connect(function()
                local code2
                if scriptRef.fromStore and scriptRef.meta and scriptRef.meta.Url then
                    local src = game:HttpGet(scriptRef.meta.Url)
                    if src then
                        code2 = src
                    else
                        AddLog("[Script] Failed to fetch: " .. scriptRef.name, "error")
                        return
                    end
                else
                    code2 = readfile(filePath)
                end

                if code2 and code2 ~= "" then
                    if not _G.__DeltaUI_cleaned then
                        cleanupOldUI()
                        _G.__DeltaUI_cleaned = true
                    end
                    switchPage("terminal")
                    ShowNotification(t("script_loading") .. scriptRef.name, 2)
                    AddLog("> " .. t("executing_saved") .. scriptRef.name, "info")
                    local fn2, err2 = loadstring(code2)
                    if not fn2 then
                        local errLine2 = parseErrorLine(tostring(err2))
                        if errLine2 then
                            jumpToErrorLine(errLine2)
                        end
                        AddLog("[Error] " .. tostring(err2), "error")
                        ShowNotification(t("execution_error_notify"), 3, function()
                            switchPage("terminal")
                        end)
                        return
                    end
                    local oldPrint = print
                    local oldWarn = warn
                    print = function(...)
                        local args = {...}
                        local msg = table.concat(args, " ")
                        AddLog(msg, "info")
                        if logDedup then logDedup[msg] = tick() end
                        _G.__DeltaUI_blockLogService = true
                        oldPrint(...)
                        _G.__DeltaUI_blockLogService = nil
                    end
                    warn = function(...)
                        local args = {...}
                        local msg = table.concat(args, " ")
                        AddLog(msg, "warn")
                        if logDedup then logDedup[msg] = tick() end
                        _G.__DeltaUI_blockLogService = true
                        oldWarn(...)
                        _G.__DeltaUI_blockLogService = nil
                    end
                    _G.__DeltaUI_blockLogService = true
                    local ok, execErr = pcall(fn2)
                    _G.__DeltaUI_blockLogService = nil
                    print = oldPrint
                    warn = oldWarn
                    if not ok then
                        AddLog("[Error] " .. tostring(execErr), "error")
                    end

                    AddLog("> " .. t("execution_finished"), "info")
                end
            end)
            item.Parent = scriptListScroll
                end
            end
        end
    end

    do
        local kbItem = create("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = theme.surface,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            ZIndex = 4,
            LayoutOrder = 999999
        })
        corner(10, kbItem)
        local kbTitle = create("TextLabel", {
            Position = UDim2.new(0, 14, 0, 1.5),
            Size = UDim2.new(0.5, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "KeyBoard",
            TextColor3 = theme.text,
            TextSize = 15,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 5
        })
        kbTitle.Parent = kbItem
        local kbSub = create("TextLabel", {
            Position = UDim2.new(0, 14, 0, 24),
            Size = UDim2.new(0, 120, 0, 14),
            BackgroundTransparency = 1,
            Text = "From Delta",
            TextColor3 = theme.textDim,
            TextSize = 10,
            Font = Enum.Font.SourceSans,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 5
        })
        kbSub.Parent = kbItem

        local kbExec = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.new(0, 90, 0, 28),
            BackgroundColor3 = theme.accent,
            BackgroundTransparency = 0.3,
            Text = "",
            BorderSizePixel = 0,
            ZIndex = 5
        })
        corner(8, kbExec)
        local kbExecText = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = t("execute_cap"),
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 11,
            Font = Enum.Font.SourceSansBold,
            ZIndex = 6
        })
        kbExecText.Parent = kbExec
        kbExec.Parent = kbItem
        kbExec.MouseButton1Click:Connect(function()
            local ok, src = pcall(function()
                return game:HttpGet("https://github.com/AZYsGithub/Delta-Scripts/raw/refs/heads/main/MobileKeyboard.txt")
            end)
            if ok and src and src ~= "" then
                ShowNotification(t("script_loaded") .. "KeyBoard", 2)
                AddLog("> " .. t("executing_saved") .. "KeyBoard", "info")
                local fn, err = loadstring(src)
                if fn then
                    local ok2, runErr = xpcall(fn, function(err)
                        return debug.traceback(tostring(err), 2)
                    end)
                    if ok2 then
                        ShowNotification(t("script_loaded") .. "KeyBoard", 2)
                        main.Visible = false
                        orbFrame.Visible = true
                        orbFrame.BackgroundTransparency = 0.1
                        if orbStroke then orbStroke.Transparency = 0 end
                        orbPulseActive = true
                        orbPulseConn = svc.RunService.RenderStepped:Connect(orbPulse)
                    else
                        AddLog("[Error] " .. tostring(runErr), "error")
                        ShowNotification(t("execution_error_notify"), 3)
                    end
                else
                    AddLog("[Error] " .. tostring(err), "error")
                    ShowNotification(t("execution_error_notify"), 3)
                end
            else
                AddLog("[Script] Failed to fetch: KeyBoard", "error")
                ShowNotification(t("fetch_failed"), 3)
            end
        end)

        kbItem.Parent = scriptListScroll
    end

    task.defer(function()
        if scriptListScroll and scriptListLayout and scriptListScroll.Parent then
            local absSize = scriptListLayout.AbsoluteContentSize
            if absSize then
                scriptListScroll.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 8)
            end
        end
    end)
    _G.__DeltaUI_refreshScriptLock = nil
end

for _, name in ipairs(navNames) do
    navButtons[name].MouseButton1Click:Connect(function()
        if customTabMode then return end
        switchPage(name)
    end)
end

customItemsPanel = nil
customItemsScroll = nil
customItemsRows = {}
customDeleteOpenRow = nil
customListDragging = false
customListDragRow = nil
customListDragName = nil
customListDragConnections = {}
customListDragStartY = 0
customListDragOffsetY = 0
customListLayout = nil
customIconPanel = nil
customIconPanelOpen = false
customIconPanelTab = nil
customIconSearchBox = nil
customIconSearchInput = nil
customIconScroll = nil
customIconGridLayout = nil
customIconAllNames = nil
customIconLoadToken = 0
customIconSelectedCell = nil
iconUrlCache = {}
customIconNavBgSavedPos = nil
customIconNavBgSavedSize = nil
customIconHighlightedBtn = nil
customIconHighlightedOriginalColor = nil

local tabNameMap = {
    house = "主页",
    terminal = "控制台",
    ["gamepad-2"] = "脚本管理器",
    package = "脚本商店",
    atom = "AgentLess",
    settings = "设置"
}
local tabIconMap = {
    house = "house",
    terminal = "terminal",
    ["gamepad-2"] = "gamepad-2",
    package = "package",
    atom = "atom",
    chat = "message-circle",
    settings = "settings"
}
local protectedTabs = {house = true, settings = true}
local allNavItems = {"house", "terminal", "gamepad-2", "package", "atom", "settings"}

AntiTamper = {
    active = false,
    checkInterval = 5,
    connections = {},
    lastMainVisible = nil,
    lastOrbVisible = nil,
    protectedInstances = {},
}

function AntiTamper.protectGui(gui)
    if not gui then return end
    local ok = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
        if gethui then
            gui.Parent = gethui()
            return
        elseif get_hidden_gui then
            gui.Parent = get_hidden_gui()
            return
        elseif getgui then
            gui.Parent = getgui()
            return
        end
    end)
    if not ok then
        gui.Parent = svc.CoreGui
    end
end

function AntiTamper.getContainer()
    if uiContainer and uiContainer.Parent then
        return uiContainer
    end
    for _, child in pairs(svc.CoreGui:GetChildren()) do
        if child.Name == containerName and child:FindFirstChildOfClass("ScreenGui") then
            uiContainer = child
            return child
        end
    end
    return nil
end

function AntiTamper.checkIntegrity()
    if not AntiTamper.active then return end

    local container = AntiTamper.getContainer()
    if not container then
        return
    end

    local sg = container:FindFirstChildOfClass("ScreenGui")
    if not sg then
        return
    end

    if main and main.Parent then
        if main.Visible == false and not customTabMode then
            if AntiTamper.lastMainVisible ~= false then
                main.Visible = true
                if orbFrame then
                    orbFrame.Visible = false
                end
            end
        end
        AntiTamper.lastMainVisible = main.Visible
    end

    if orbFrame and orbFrame.Parent then
        if main and main.Visible and orbFrame.Visible then
            orbFrame.Visible = false
        end
        AntiTamper.lastOrbVisible = orbFrame.Visible
    end

    if sg.Enabled == false then
        sg.Enabled = true
    end

    if sg.DisplayOrder ~= 999999 then
        sg.DisplayOrder = 999999
    end

    if sg.ZIndexBehavior ~= Enum.ZIndexBehavior.Sibling then
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end

    if sg.ResetOnSpawn ~= false then
        sg.ResetOnSpawn = false
    end

    if sg.IgnoreGuiInset ~= true then
        sg.IgnoreGuiInset = true
    end

    local keyInstances = {
        main = main,
        orbFrame = orbFrame,
        navBg = navBg,
        navIndicator = navIndicator,
        contentFrame = contentFrame,
        wrapperFrame = wrapperFrame,
    }
    for name, inst in pairs(keyInstances) do
        if inst then
            if not inst.Parent then
                warn("[DeltaUI] Key instance detached: " .. name)
            elseif inst.Visible == false and name ~= "orbFrame" and not customTabMode then
                inst.Visible = true
            end
        end
    end

    for _, child in pairs(svc.CoreGui:GetChildren()) do
        if child ~= container and child.Name:sub(1,7) == "DeltaUI" then
            pcall(function() child:Destroy() end)
        end
    end

    if _G.__DeltaUI_screenGui ~= screenGui then
        _G.__DeltaUI_screenGui = screenGui
    end
    if _G.__DeltaUI_main ~= main then
        _G.__DeltaUI_main = main
    end

    local coreGuiChildren = svc.CoreGui:GetChildren()
    if #coreGuiChildren > 50 then

    end
end

function AntiTamper.start()
    if AntiTamper.active then return end
    AntiTamper.active = true

    local conn = svc.RunService.Heartbeat:Connect(function()
        if tick() % AntiTamper.checkInterval < 0.05 then
            AntiTamper.checkIntegrity()
        end
    end)
    table.insert(AntiTamper.connections, conn)

    if screenGui then
        AntiTamper.protectGui(screenGui)
    end
end

function AntiTamper.stop()
    AntiTamper.active = false
    for _, conn in ipairs(AntiTamper.connections) do
        pcall(function() conn:Disconnect() end)
    end
    AntiTamper.connections = {}
end

customTabMode = false
customTabOrder = {}
originalNavState = {}
isDraggingTab = false
draggedTabBtn = nil
draggedTabName = nil
tabDragConnections = {}
activeTabHold = nil
dragOffsetX = 0
dragOffsetY = 0
fadeableElements = {}

function saveTabOrder()
    local cfg = loadConfig()
    cfg.tabOrder = customTabOrder
    saveConfig(cfg)
end

function resetTabOrder()
    customTabOrder = {unpack(navNames)}
    saveTabOrder()
    tabIconMap = {
        house = "house",
        terminal = "terminal",
        ["gamepad-2"] = "gamepad-2",
        package = "package",
        chat = "message-circle",
        settings = "settings"
    }
    local cfg = loadConfig()
    cfg.tabIcons = {}
    saveConfig(cfg)
    applyTabOrder()
    for _, name in ipairs(navNames) do
        local btn = navButtons[name]
        if btn then
            local oldIcon = btn:FindFirstChildOfClass("ImageLabel")
            if oldIcon then oldIcon:Destroy() end
            local iconSize = customTabMode and 22 or 18
            local newIcon = GetIcon(name, UDim2.new(0, iconSize, 0, iconSize))
            if newIcon then
                newIcon.Position = UDim2.new(0.5, -iconSize / 2, 0.5, -iconSize / 2)
                newIcon.Parent = btn
            end
        end
    end
    ShowNotification(t("reset_tab_order"), 1)
end

function loadTabOrder()
    local cfg = loadConfig()
    if cfg.tabOrder and type(cfg.tabOrder) == "table" and #cfg.tabOrder == #navNames then
        local valid = true
        local seen = {}
        for _, name in ipairs(cfg.tabOrder) do
            if not navButtons[name] or seen[name] then
                valid = false
                break
            end
            seen[name] = true
        end
        if valid then
            return cfg.tabOrder
        end
    end
    return {unpack(navNames)}
end

function saveTabIcons()
    local cfg = loadConfig()
    cfg.tabIcons = {}
    for k, v in pairs(tabIconMap) do
        if k ~= v then cfg.tabIcons[k] = v end
    end
    saveConfig(cfg)
end

function loadTabIcons()
    local cfg = loadConfig()
    if cfg.tabIcons and type(cfg.tabIcons) == "table" then
        for k, v in pairs(cfg.tabIcons) do
            if type(k) == "string" and type(v) == "string" then
                tabIconMap[k] = v
            end
        end
    end
end

function applyTabIcon(tabName, iconName, skipSave)
    tabIconMap[tabName] = iconName
    local btn = navButtons[tabName]
    if btn then
        local oldIcon = btn:FindFirstChildOfClass("ImageLabel")
        if oldIcon then oldIcon:Destroy() end
        local iconSize = customTabMode and 22 or 18
        local newIcon = GetIcon(iconName, UDim2.new(0, iconSize, 0, iconSize))
        if newIcon then
            newIcon.Position = UDim2.new(0.5, -iconSize / 2, 0.5, -iconSize / 2)
            newIcon.Parent = btn
        end
    end
    if not skipSave then saveTabIcons() end
end

function applyTabIcons()
    for tabName, iconName in pairs(tabIconMap) do
        if navButtons[tabName] and iconName ~= tabName then
            local btn = navButtons[tabName]
            local oldIcon = btn:FindFirstChildOfClass("ImageLabel")
            if oldIcon then oldIcon:Destroy() end
            local newIcon = GetIcon(iconName, UDim2.new(0, 18, 0, 18))
            if newIcon then
                newIcon.Position = UDim2.new(0.5, -9, 0.5, -9)
                newIcon.Parent = btn
            end
        end
    end
end

function applyTabOrder()
    if customTabMode then return end
    for _, btn in pairs(navButtons) do
        btn.Visible = false
    end
    local n = #customTabOrder
    for i, name in ipairs(customTabOrder) do
        local btn = navButtons[name]
        if btn then
            btn.Visible = true
            btn.Position = UDim2.new(0, btnXPositions[i], 0, 3)
        end
    end
    if n > 0 then
        local targetW = btnXPositions[n] + 36
                navBg.Size = UDim2.new(0, targetW, 0, navBg.Size.Y.Offset)
    end
    if currentPage and navButtons[currentPage] then
                navIndicator.Position = getIndicatorCenterPos(navButtons[currentPage])
    end
end

function updateCustomButtonPositions(animate)
    for _, btn in pairs(navButtons) do
        btn.Visible = false
    end
    local n = #customTabOrder
    for i, name in ipairs(customTabOrder) do
        local btn = navButtons[name]
        if btn then
            btn.Visible = true
            local targetX = 10 + (i - 1) * 60
            if animate then
                svc.TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, targetX, 0, 9)
                }):Play()
            else
                btn.Position = UDim2.new(0, targetX, 0, 9)
            end
        end
    end
    if customTabMode and n > 0 then
        local targetW = n * 60
        if animate then
            svc.TweenService:Create(navBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, targetW, 0, navBg.Size.Y.Offset)
            }):Play()
        else
            navBg.Size = UDim2.new(0, targetW, 0, navBg.Size.Y.Offset)
        end
    end

    if customTabMode and currentPage and navButtons[currentPage] then
        local btnIdx = table.find(customTabOrder, currentPage) or 1
        local targetX = 10 + (btnIdx - 1) * 60
        local targetPos = UDim2.new(0, targetX, 0, 9)
        if animate then
            svc.TweenService:Create(navIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 40, 0, 40),
                Position = targetPos
            }):Play()
        else
            navIndicator.Size = UDim2.new(0, 40, 0, 40)
            navIndicator.Position = targetPos
        end
    end
end

function onTabDragInputChanged(input)
    if not isDraggingTab or not draggedTabBtn then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local mousePos = Vector2.new(input.Position.X, input.Position.Y)
    local navBgPos = navBg.AbsolutePosition
    local relX = mousePos.X - navBgPos.X - dragOffsetX
    relX = math.clamp(relX, 0, 320)
    draggedTabBtn.Position = UDim2.new(0, relX, 0, 9)
    local centerX = relX + 20
    local slotWidth = 60
    local newIndex = math.floor(centerX / slotWidth) + 1
    newIndex = math.clamp(newIndex, 1, #customTabOrder)
    local oldIndex = table.find(customTabOrder, draggedTabName)
    if oldIndex and oldIndex ~= newIndex then
        table.remove(customTabOrder, oldIndex)
        table.insert(customTabOrder, newIndex, draggedTabName)
        updateCustomButtonPositions(true)
    end
end

function endTabDrag()
    if not isDraggingTab then return end
    isDraggingTab = false
    for _, conn in ipairs(tabDragConnections) do
        conn:Disconnect()
    end
    tabDragConnections = {}
    if draggedTabBtn then
        draggedTabBtn.ZIndex = 15
        draggedTabBtn.Active = true
    end
    for _, name in ipairs(navNames) do
        local btn = navButtons[name]
        if btn then
            btn.Active = true
        end
    end
    updateCustomButtonPositions(true)
    saveTabOrder()
    draggedTabBtn = nil
    draggedTabName = nil
end

function beginTabDrag(btn, name)
    if isDraggingTab then return end
    isDraggingTab = true
    draggedTabBtn = btn
    draggedTabName = name
    btn.ZIndex = 100
    btn.Active = false
    local mousePos = svc.UserInputService:GetMouseLocation()
    local btnAbsPos = btn.AbsolutePosition
    dragOffsetX = mousePos.X - btnAbsPos.X
    dragOffsetY = mousePos.Y - btnAbsPos.Y
    for _, otherName in ipairs(navNames) do
        if otherName ~= name then
            local otherBtn = navButtons[otherName]
            if otherBtn then
                otherBtn.Active = false
            end
        end
    end
    table.insert(tabDragConnections, svc.UserInputService.InputChanged:Connect(onTabDragInputChanged))
    table.insert(tabDragConnections, svc.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endTabDrag()
        end
    end))
end

function createCustomItemsPanel()
    if customItemsPanel and customItemsPanel.Parent then return end
    local cam = workspace.CurrentCamera
    local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local panelW = 260
    local panelH = 320
    local startX = screenSize.X + 10
    local targetX = screenSize.X - panelW - 20
    local targetY = math.floor((screenSize.Y - panelH) / 2)

    customItemsPanel = create("Frame", {
        Position = UDim2.new(0, startX, 0, targetY),
        Size = UDim2.new(0, panelW, 0, panelH),
        BackgroundColor3 = theme.surface,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 1000,
        Active = true,
        ClipsDescendants = true,
        Name = "CustomItemsPanel"
    })
    corner(16, customItemsPanel)
    stroke(theme.border, 1, customItemsPanel)
    customItemsPanel.Parent = screenGui

    local panelTitle = create("TextLabel", {
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -32, 0, 24),
        BackgroundTransparency = 1,
        Text = t("customize_items"),
        TextColor3 = theme.text,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1001
    })
    panelTitle.Parent = customItemsPanel

    local closeBtn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 1002
    })
    local closeIcon = GetIcon("x", UDim2.new(0, 16, 0, 16), theme.textDim)
    if closeIcon then
        closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
        closeIcon.Parent = closeBtn
    end
    closeBtn.Parent = customItemsPanel
    closeBtn.MouseButton1Click:Connect(function()
        exitCustomTabMode()
    end)

    local divider = create("Frame", {
        Position = UDim2.new(0, 12, 0, 44),
        Size = UDim2.new(1, -24, 0, 1),
        BackgroundColor3 = theme.border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 1001
    })
    divider.Parent = customItemsPanel

    customItemsScroll = create("ScrollingFrame", {
        Position = UDim2.new(0, 8, 0, 52),
        Size = UDim2.new(1, -16, 1, -60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.textDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 1001,
        ClipsDescendants = true
    })
    customItemsScroll.Parent = customItemsPanel

    local listLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    listLayout.Parent = customItemsScroll
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if customItemsScroll and customItemsScroll.Parent then
            customItemsScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
        end
    end)

    refreshCustomItemsList()
end

function refreshCustomItemsList()
    if not customItemsScroll or not customItemsScroll.Parent then return end
    for _, child in pairs(customItemsScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    customItemsRows = {}
    customDeleteOpenRow = nil

    for i, name in ipairs(customTabOrder) do
        local row = createCustomItemRow(name, i, false)
        if row then
            row.Parent = customItemsScroll
            table.insert(customItemsRows, row)
        end
    end

    local disabledCount = 0
    for _, name in ipairs(allNavItems) do
        if not table.find(customTabOrder, name) then
            disabledCount = disabledCount + 1
            local row = createCustomItemRow(name, #customTabOrder + disabledCount, true)
            if row then
                row.BackgroundColor3 = theme.surface
                row.BackgroundTransparency = 0.5
                row.Parent = customItemsScroll
                table.insert(customItemsRows, row)
            end
        end
    end
end

function createCustomItemRow(name, order, isDisabled)
    local isProtected = protectedTabs[name] == true
    local iconName = isProtected and "shield-minus" or (isDisabled and "circle-plus" or "circle-minus")
    local rowH = 44
    local row = create("Frame", {
        Size = UDim2.new(1, -8, 0, rowH),
        BackgroundColor3 = isDisabled and theme.surface or theme.surfaceLight,
        BackgroundTransparency = isDisabled and 0.5 or 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 1002,
        Active = true,
        Name = "Row_" .. name
    })
    corner(10, row)

    local icon = GetIcon(iconName, UDim2.new(0, 18, 0, 18), isProtected and theme.warn or (isDisabled and theme.accent or theme.red))
    if icon then
        icon.Position = UDim2.new(0, 10, 0.5, -9)
        icon.Parent = row
        icon.Name = "TypeIcon"
    end

    local displayName = tabNameMap[name] or name
    local nameLabel = create("TextLabel", {
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = theme.text,
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 1003
    })
    nameLabel.Parent = row

    local menuIcon = nil
    if not isDisabled then
        menuIcon = GetIcon("menu", UDim2.new(0, 16, 0, 16), theme.textDim)
        if menuIcon then
            menuIcon.Position = UDim2.new(1, -26, 0.5, -8)
            menuIcon.Parent = row
            menuIcon.Name = "MenuIcon"
        end
    end

    if not isProtected then
        local actionBtn = create("TextButton", {
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = isDisabled and Color3.fromRGB(59, 130, 246) or theme.red,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 1005,
            Visible = true,
            Name = "ActionBtn"
        })
        corner(10, actionBtn)
        local actionText = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = isDisabled and t("add") or t("delete"),
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 12,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTransparency = 1, ZIndex = 1006
        })
        actionText.Parent = actionBtn
        actionBtn.Parent = row

        if isDisabled then

            if icon then
                local iconHit = create("TextButton", {
                    Position = UDim2.new(0, 4, 0, 4),
                    Size = UDim2.new(0, 30, 0, 30),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 1007
                })
                iconHit.Parent = row
                iconHit.MouseButton1Click:Connect(function()
                    table.insert(customTabOrder, name)
                    saveTabOrder()
                    refreshCustomItemsList()
                    updateCustomButtonPositions(true)
                end)
            end
        else

            if icon then
                local iconHit = create("TextButton", {
                    Position = UDim2.new(0, 4, 0, 4),
                    Size = UDim2.new(0, 30, 0, 30),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 1007
                })
                iconHit.Parent = row
                iconHit.MouseButton1Click:Connect(function()
                    if customDeleteOpenRow and customDeleteOpenRow ~= row then
                        local oldAction = customDeleteOpenRow:FindFirstChild("ActionBtn")
                        if oldAction then
                            svc.TweenService:Create(oldAction, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, 0, 1, 0),
                                Position = UDim2.new(1, 0, 0, 0)
                            }):Play()
                        end
                        local oldMenu = customDeleteOpenRow:FindFirstChild("MenuIcon")
                        if oldMenu then
                            svc.TweenService:Create(oldMenu, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
                        end
                        customDeleteOpenRow = nil
                    end
                    local actionBtn = row:FindFirstChild("ActionBtn")
                    if actionBtn then
                        if customDeleteOpenRow == row then
                            svc.TweenService:Create(actionBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, 0, 1, 0),
                                Position = UDim2.new(1, 0, 0, 0)
                            }):Play()
                        svc.TweenService:Create(actionText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
                            if menuIcon then
                                svc.TweenService:Create(menuIcon, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
                            end
                            customDeleteOpenRow = nil
                        else
                            svc.TweenService:Create(actionBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(0, 70, 1, 0),
                                Position = UDim2.new(1, -70, 0, 0)
                            }):Play()
                            svc.TweenService:Create(actionText, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
                            if menuIcon then
                                svc.TweenService:Create(menuIcon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
                            end
                            customDeleteOpenRow = row
                        end
                    end
                end)
            end

            actionBtn.MouseButton1Click:Connect(function()
                local idx = table.find(customTabOrder, name)
                if idx then
                    table.remove(customTabOrder, idx)
                end
                saveTabOrder()
                customDeleteOpenRow = nil
                refreshCustomItemsList()
                updateCustomButtonPositions(true)
            end)
        end
    end

    if not isDisabled and menuIcon then
        local dragHoldToken = 0
        menuIcon.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if customListDragging then return end
                if customDeleteOpenRow then
                    local oldAction = customDeleteOpenRow:FindFirstChild("ActionBtn")
                    if oldAction then
                        svc.TweenService:Create(oldAction, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(1, 0, 0, 0)}):Play()
                    end
                    local oldMenu = customDeleteOpenRow:FindFirstChild("MenuIcon")
                    if oldMenu then
                        svc.TweenService:Create(oldMenu, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
                    end
                    customDeleteOpenRow = nil
                end
                dragHoldToken = dragHoldToken + 1
                local currentToken = dragHoldToken
                customListDragStartY = input.Position.Y
                customListDragOffsetY = input.Position.Y - row.AbsolutePosition.Y
                task.spawn(function()
                    task.wait(0.25)
                    if currentToken ~= dragHoldToken then return end
                    if customListDragging then return end
                    if math.abs(input.Position.Y - customListDragStartY) < 5 then
                        beginListDrag(row, name)
                    end
                end)
            end
        end)
        menuIcon.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragHoldToken = dragHoldToken + 1
            end
        end)
    end

    return row
end

function beginListDrag(row, name)
    if customListDragging then return end
    customListDragging = true
    customListDragRow = row
    customListDragName = name
    row.ZIndex = 1010

    if customItemsScroll then
        customItemsScroll.ScrollingEnabled = false
    end

    customListLayout = customItemsScroll:FindFirstChildOfClass("UIListLayout")
    if customListLayout then
        customListLayout.Parent = nil
    end

    local scrollAbsY = customItemsScroll.AbsolutePosition.Y
    for _, r in ipairs(customItemsRows) do
        if r ~= row then
            local absY = r.AbsolutePosition.Y - scrollAbsY
            r.Position = UDim2.new(0, 4, 0, absY)
        end
    end

    local rowHeight = 50

    for _, otherRow in ipairs(customItemsRows) do
        if otherRow ~= row then
            otherRow.Active = false
        end
    end

    table.insert(customListDragConnections, svc.UserInputService.InputChanged:Connect(function(input)
        if not customListDragging or not customListDragRow then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local mouseY = input.Position.Y
        local scrollPos = customItemsScroll.AbsolutePosition.Y
        local scrollH = customItemsScroll.AbsoluteSize.Y
        local relY = mouseY - scrollPos - customListDragOffsetY
        relY = math.clamp(relY, 0, math.max(0, scrollH - row.AbsoluteSize.Y))
        row.Position = UDim2.new(0, 4, 0, relY)

        local centerY = relY + row.AbsoluteSize.Y / 2
        local slotH = rowHeight
        local newIndex = math.floor(centerY / slotH) + 1
        newIndex = math.clamp(newIndex, 1, #customTabOrder)
        local oldIndex = table.find(customTabOrder, name)
        if oldIndex and oldIndex ~= newIndex then
            table.remove(customTabOrder, oldIndex)
            table.insert(customTabOrder, newIndex, name)
            for i, r in ipairs(customItemsRows) do
                if r ~= row then
                    local targetOrder = table.find(customTabOrder, r.Name:sub(5)) or i
                    local targetY = (targetOrder - 1) * slotH
                    if targetY ~= r.Position.Y.Offset then
                        svc.TweenService:Create(r, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, 4, 0, targetY)
                        }):Play()
                    end
                end
            end
            updateCustomButtonPositions(true)
        end
    end))

    table.insert(customListDragConnections, svc.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endListDrag()
        end
    end))
end

function endListDrag()
    if not customListDragging then return end
    customListDragging = false
    for _, conn in ipairs(customListDragConnections) do
        conn:Disconnect()
    end
    customListDragConnections = {}

    if customListDragRow then
        customListDragRow.ZIndex = 1002
        customListDragRow = nil
    end

    if customItemsScroll then
        customItemsScroll.ScrollingEnabled = true
    end

    for _, otherRow in ipairs(customItemsRows) do
        otherRow.Active = true
    end

    if customItemsScroll and customListLayout then
        customListLayout.Parent = customItemsScroll
        customListLayout = nil
    end

    refreshCustomItemsList()
    saveTabOrder()
    customListDragName = nil
end

function getAllIconNames()
    if customIconAllNames then return customIconAllNames end
    local lucide = LoadLucide()
    if not lucide or not lucide.IconNames then return {} end
    customIconAllNames = lucide.IconNames
    return customIconAllNames
end

function getIconUrlCached(iconName)
    if iconUrlCache[iconName] then return iconUrlCache[iconName] end
    local lucide = LoadLucide()
    if not lucide then return nil end
    local ok, asset = pcall(lucide.GetAsset, iconName)
    if ok and asset and asset.Url then
        iconUrlCache[iconName] = asset.Url
        return asset.Url
    end
    return nil
end

function populateIconGrid(filterText)
    customIconLoadToken = customIconLoadToken + 1
    local myToken = customIconLoadToken

    if not customIconScroll or not customIconScroll.Parent then return end

    for _, child in pairs(customIconScroll:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local allNames = getAllIconNames()
    local filtered = {}
    local ft = filterText and string.lower(filterText) or ""
    local i, j = 1, #ft
                while i <= j and string.byte(ft:sub(i,i)) <= 32 do i = i + 1 end
                while j >= i and string.byte(ft:sub(j,j)) <= 32 do j = j - 1 end
                ft = ft:sub(i, j)
    if ft == "" then
        for i, name in ipairs(allNames) do filtered[i] = name end
    else
        for _, name in ipairs(allNames) do
            if string.find(string.lower(name), ft, 1, true) then
                table.insert(filtered, name)
            end
        end
    end

    local currentTabIcon = tabIconMap[customIconPanelTab] or customIconPanelTab

    task.spawn(function()
        local batchSize = 80
        for i = 1, #filtered, batchSize do
            if myToken ~= customIconLoadToken then return end
            if not customIconScroll or not customIconScroll.Parent then return end

            local batchEnd = math.min(i + batchSize - 1, #filtered)
            for j = i, batchEnd do
                local name = filtered[j]
                local isSelected = (name == currentTabIcon)

                local cell = create("TextButton", {
                    Size = UDim2.new(0, 62, 0, 72),
                    BackgroundColor3 = isSelected and theme.green or theme.surface,
                    BackgroundTransparency = isSelected and 0.5 or 0.3,
                    BorderSizePixel = 0,
                    Text = "",
                    LayoutOrder = j,
                    ZIndex = 1001,
                    AutoButtonColor = true
                })
                cell:SetAttribute("iconName", name)
                cell:SetAttribute("iconLoaded", false)

                local nameLabel = create("TextLabel", {
                    Position = UDim2.new(0, 2, 1, -22),
                    Size = UDim2.new(1, -4, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = isSelected and theme.text or theme.textDim,
                    TextSize = 9,
                    Font = Enum.Font.SourceSans,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 1002
                })
                nameLabel.Parent = cell
                cell.Parent = customIconScroll

                if isSelected then customIconSelectedCell = cell end

                cell.MouseButton1Click:Connect(function()
                    if customIconPanelTab and customIconPanelTab ~= "house" and customIconPanelTab ~= "settings" then
                        if customIconSelectedCell then
                            customIconSelectedCell.BackgroundColor3 = theme.surface
                            customIconSelectedCell.BackgroundTransparency = 0.3
                            local oldLabel = customIconSelectedCell:FindFirstChildOfClass("TextLabel")
                            if oldLabel then oldLabel.TextColor3 = theme.textDim end
                        end
                        cell.BackgroundColor3 = theme.green
                        cell.BackgroundTransparency = 0.5
                        nameLabel.TextColor3 = theme.text
                        customIconSelectedCell = cell

                        applyTabIcon(customIconPanelTab, name)
                    end
                end)
            end
            task.wait()
        end

        if myToken ~= customIconLoadToken then return end
        loadIconsForVisibleCells(myToken)
        if customIconScroll and customIconScroll.Parent then
            local scrollConn
            scrollConn = customIconScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if myToken ~= customIconLoadToken then
                    scrollConn:Disconnect()
                    return
                end
                loadIconsForVisibleCells(myToken)
            end)
        end
    end)
end

function loadIconsForVisibleCells(myToken)
    if not customIconScroll or not customIconScroll.Parent then return end
    local scrollPos = customIconScroll.CanvasPosition
    local viewportY = scrollPos.Y
    local viewportH = customIconScroll.AbsoluteSize.Y
    local cellH = 72 + 4
    local cellW = 62 + 4
    local gridW = customIconScroll.AbsoluteSize.X
    local cols = math.max(1, math.floor((gridW + 4) / cellW))

    local startRow = math.max(1, math.floor(viewportY / cellH) - 1)
    local endRow = math.ceil((viewportY + viewportH) / cellH) + 1

    task.spawn(function()
        for _, child in pairs(customIconScroll:GetChildren()) do
            if myToken ~= customIconLoadToken then return end
            if child:IsA("TextButton") and child:GetAttribute("iconLoaded") ~= true then
                local order = child.LayoutOrder
                local row = math.ceil(order / cols)
                if row >= startRow and row <= endRow then
                    local iconName = child:GetAttribute("iconName")
                    if iconName then
                        local url = getIconUrlCached(iconName)
                        if url then
                            local iconImg = create("ImageLabel", {
                                Position = UDim2.new(0.5, -14, 0, 6),
                                Size = UDim2.new(0, 28, 0, 28),
                                BackgroundTransparency = 1,
                                Image = url,
                                ImageColor3 = theme.text,
                                ScaleType = Enum.ScaleType.Fit,
                                ZIndex = 1002
                            })
                            iconImg.Parent = child
                            child:SetAttribute("iconLoaded", true)
                        end
                    end
                end
            end
        end
    end)
end

function createCustomIconPanel(tabName)
    if customIconPanel and customIconPanel.Parent then return end
    local cam = workspace.CurrentCamera
    local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local panelW = 300
    local panelH = math.min(440, screenSize.Y - 80)
    local startX = -panelW - 10
    local targetY = math.floor((screenSize.Y - panelH) / 2)

    customIconPanel = create("Frame", {
        Position = UDim2.new(0, startX, 0, targetY),
        Size = UDim2.new(0, panelW, 0, panelH),
        BackgroundColor3 = theme.surface,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 1000,
        Active = true,
        ClipsDescendants = true,
        Name = "CustomIconPanel"
    })
    corner(16, customIconPanel)
    stroke(theme.border, 1, customIconPanel)
    customIconPanel.Parent = screenGui

    local panelTitle = create("TextLabel", {
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -48, 0, 24),
        BackgroundTransparency = 1,
        Text = t("customize_icon"),
        TextColor3 = theme.text,
        TextSize = 16,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1001
    })
    panelTitle.Parent = customIconPanel

    local closeBtn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 1002
    })
    local closeIcon = GetIcon("x", UDim2.new(0, 16, 0, 16), theme.textDim)
    if closeIcon then
        closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
        closeIcon.Parent = closeBtn
    end
    closeBtn.Parent = customIconPanel
    closeBtn.MouseButton1Click:Connect(function()
        closeCustomIconPanel()
    end)

    customIconSearchBox = create("Frame", {
        Position = UDim2.new(0, 12, 0, 44),
        Size = UDim2.new(1, -24, 0, 32),
        BackgroundColor3 = theme.surface,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 1001
    })
    corner(8, customIconSearchBox)
    customIconSearchBox.Parent = customIconPanel

    local searchIcon = GetIcon("search", UDim2.new(0, 14, 0, 14), theme.textDim)
    if searchIcon then
        searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
        searchIcon.ZIndex = 1002
        searchIcon.Parent = customIconSearchBox
    end

    customIconSearchInput = create("TextBox", {
        Position = UDim2.new(0, 28, 0, 0),
        Size = UDim2.new(1, -36, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = t("search_icons"),
        PlaceholderColor3 = theme.textDim,
        TextColor3 = theme.text,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 1002
    })
    customIconSearchInput.Parent = customIconSearchBox

    local searchDebounce = nil
    customIconSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        if searchDebounce then task.cancel(searchDebounce) end
        searchDebounce = task.delay(0.2, function()
            if customIconSearchInput and customIconSearchInput.Parent then
                populateIconGrid(customIconSearchInput.Text)
            end
        end)
    end)

    local divider = create("Frame", {
        Position = UDim2.new(0, 12, 0, 82),
        Size = UDim2.new(1, -24, 0, 1),
        BackgroundColor3 = theme.border,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 1001
    })
    divider.Parent = customIconPanel

    customIconScroll = create("ScrollingFrame", {
        Position = UDim2.new(0, 8, 0, 90),
        Size = UDim2.new(1, -16, 1, -98),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.textDim,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 1001,
        ClipsDescendants = true
    })
    customIconScroll.Parent = customIconPanel

    customIconGridLayout = create("UIGridLayout", {
        CellSize = UDim2.new(0, 62, 0, 72),
        CellPadding = UDim2.new(0, 4, 0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        FillDirection = Enum.FillDirection.Horizontal
    })
    customIconGridLayout.Parent = customIconScroll

    customIconGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if customIconScroll and customIconScroll.Parent then
            customIconScroll.CanvasSize = UDim2.new(0, 0, 0, customIconGridLayout.AbsoluteContentSize.Y + 12)
        end
    end)

    populateIconGrid("")
end

function highlightNavBtnGreen(btn)
    if customIconHighlightedBtn and customIconHighlightedBtn ~= btn then
        pcall(function()
            local oldIcon = customIconHighlightedBtn:FindFirstChildOfClass("ImageLabel")
            if oldIcon then
                oldIcon.ImageColor3 = customIconHighlightedOriginalColor or Color3.fromRGB(255, 255, 255)
            end
        end)
    end
    if btn then
        local icon = btn:FindFirstChildOfClass("ImageLabel")
        if icon then
            customIconHighlightedOriginalColor = icon.ImageColor3
            icon.ImageColor3 = theme.green
        end
        customIconHighlightedBtn = btn
    end
end

function unhighlightNavBtnGreen()
    if customIconHighlightedBtn then
        pcall(function()
            local icon = customIconHighlightedBtn:FindFirstChildOfClass("ImageLabel")
            if icon then
                icon.ImageColor3 = customIconHighlightedOriginalColor or Color3.fromRGB(255, 255, 255)
            end
        end)
        customIconHighlightedBtn = nil
        customIconHighlightedOriginalColor = nil
    end
end

function openCustomIconPanel(tabName)
    if customIconPanelOpen then
        if customIconPanelTab == tabName then return end
        customIconPanelTab = tabName
        customIconSelectedCell = nil
        highlightNavBtnGreen(navButtons[tabName])
        if customIconSearchInput and customIconSearchInput.Parent then
            customIconSearchInput.Text = ""
        end
        populateIconGrid("")
        return
    end
    customIconPanelOpen = true
    customIconPanelTab = tabName

    local cam = workspace.CurrentCamera
    local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)

    createCustomIconPanel(tabName)

    if customItemsPanel and customItemsPanel.Parent then
        svc.TweenService:Create(customItemsPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0, screenSize.X + 10, 0, customItemsPanel.Position.Y.Offset)
        }):Play()
    end

    if navBg and navBg.Parent then
        customIconNavBgSavedPos = navBg.Position
        customIconNavBgSavedSize = navBg.Size

        local navW = navBg.Size.X.Offset
        local targetX = screenSize.X - navW - 20
        local currentY = navBg.Position.Y.Offset

        task.delay(0.15, function()
            if navBg and navBg.Parent then
                svc.TweenService:Create(navBg, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(0, targetX, 0, currentY)
                }):Play()
            end
        end)
    end

    highlightNavBtnGreen(navButtons[tabName])

    task.delay(0.2, function()
        if customIconPanel and customIconPanel.Parent then
            local targetX = 20
            svc.TweenService:Create(customIconPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, targetX, 0, customIconPanel.Position.Y.Offset)
            }):Play()
        end
    end)
end

function closeCustomIconPanel()
    if not customIconPanelOpen then return end
    customIconPanelOpen = false
    customIconLoadToken = customIconLoadToken + 1

    local cam = workspace.CurrentCamera
    local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)

    unhighlightNavBtnGreen()

    if navBg and navBg.Parent and customIconNavBgSavedPos then
        svc.TweenService:Create(navBg, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = customIconNavBgSavedPos
        }):Play()
        customIconNavBgSavedPos = nil
        customIconNavBgSavedSize = nil
    end

    if customIconPanel and customIconPanel.Parent then
        local panelW = 300
        svc.TweenService:Create(customIconPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0, -panelW - 10, 0, customIconPanel.Position.Y.Offset)
        }):Play()
        task.delay(0.35, function()
            if customIconPanel then
                customIconPanel:Destroy()
                customIconPanel = nil
            end
        end)
    end

    if customItemsPanel and customItemsPanel.Parent then
        local panelW = 260
        local targetX = screenSize.X - panelW - 20
        task.delay(0.2, function()
            if customItemsPanel and customItemsPanel.Parent then
                svc.TweenService:Create(customItemsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, targetX, 0, customItemsPanel.Position.Y.Offset)
                }):Play()
            end
        end)
    end

    customIconPanelTab = nil
    customIconSearchBox = nil
    customIconSearchInput = nil
    customIconScroll = nil
    customIconGridLayout = nil
    customIconSelectedCell = nil
end

function setupTabDragHandlers()
    for _, name in ipairs(navNames) do
        local btn = navButtons[name]
        if btn then
            btn.MouseButton1Down:Connect(function()
                if not customTabMode then return end
                if isDraggingTab then return end
                local thisHold = {}
                activeTabHold = thisHold
                task.spawn(function()
                    task.wait(0.3)
                    if activeTabHold == thisHold and customTabMode and not isDraggingTab then
                        beginTabDrag(btn, name)
                    end
                end)
            end)
            btn.MouseButton1Up:Connect(function()
                local wasDragging = isDraggingTab
                activeTabHold = nil
                if wasDragging then
                    endTabDrag()
                elseif customTabMode and not isDraggingTab then
                    openCustomIconPanel(name)
                end
            end)
        end
    end
end

function collectFadeableElements()
    fadeableElements = {}
    local function add(obj, prop)
        if obj and obj.Parent then
            table.insert(fadeableElements, {obj = obj, prop = prop, orig = obj[prop]})
        end
    end
    local function addRecursive(container)
        if not container then return end
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("GuiObject") and child ~= navBg and child ~= navContainer then
                if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                    if child.BackgroundTransparency < 1 then
                        add(child, "BackgroundTransparency")
                    end
                elseif child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    if child.TextTransparency < 1 then
                        add(child, "TextTransparency")
                    end
                    if child.BackgroundTransparency < 1 then
                        add(child, "BackgroundTransparency")
                    end
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    if child.ImageTransparency < 1 then
                        add(child, "ImageTransparency")
                    end
                    if child.BackgroundTransparency < 1 then
                        add(child, "BackgroundTransparency")
                    end
                end
                addRecursive(child)
            end
        end
    end
    addRecursive(main)
    addRecursive(topBar)
    for _, pill in ipairs({pingPill, fpsPill, timePill, labelPill}) do
        add(pill, "BackgroundTransparency")
    end
end

function fadeOutUI(duration)
    if #fadeableElements == 0 then collectFadeableElements() end
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, entry in ipairs(fadeableElements) do
        if entry.obj and entry.obj.Parent then
            entry.obj[entry.prop] = entry.orig
            svc.TweenService:Create(entry.obj, tweenInfo, {
                [entry.prop] = 1
            }):Play()
        end
    end
end

function fadeInUI(duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for _, entry in ipairs(fadeableElements) do
        if entry.obj and entry.obj.Parent then
            svc.TweenService:Create(entry.obj, tweenInfo, {
                [entry.prop] = entry.orig
            }):Play()
        end
    end
end

function enterCustomTabMode()
    if customTabMode then return end
    customTabMode = true
    if #fadeableElements == 0 then collectFadeableElements() end
    fadeOutUI(0.3)
    task.delay(0.3, function()
        wrapperFrame.Visible = false
        rightToggleBar.Visible = false
        bottomBar.Visible = false
        logoutBtn.Visible = false
        statsRow.Visible = false
    end)
    originalNavState.parent = navBg.Parent
    originalNavState.position = navBg.Position
    originalNavState.size = navBg.Size
    originalNavState.anchorPoint = navBg.AnchorPoint
    local absPos = navBg.AbsolutePosition
    local absSize = navBg.AbsoluteSize
    originalNavState.centerX = absPos.X + absSize.X / 2
    originalNavState.centerY = absPos.Y + absSize.Y / 2
    navBg.Parent = screenGui
    navBg.AnchorPoint = Vector2.new(0, 0)
    navBg.Position = UDim2.new(0, absPos.X, 0, absPos.Y)
    navBg.Size = UDim2.new(0, absSize.X, 0, absSize.Y)
    local cam = workspace.CurrentCamera
    local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local n = #customTabOrder
    local targetW = math.max(120, n * 60)
    local targetH = 58
    local targetX = math.floor((screenSize.X - targetW) / 2) - 150
    local targetY = math.floor((screenSize.Y - targetH) / 2)
    svc.TweenService:Create(navBg, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, targetX, 0, targetY),
        Size = UDim2.new(0, targetW, 0, targetH)
    }):Play()
    for i, name in ipairs(customTabOrder) do
        local btn = navButtons[name]
        if btn then
            local targetBtnX = 10 + (i - 1) * 60
            svc.TweenService:Create(btn, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, targetBtnX, 0, 9),
                Size = UDim2.new(0, 40, 0, 40)
            }):Play()
            local icon = btn:FindFirstChildOfClass("ImageLabel")
            if icon then
                svc.TweenService:Create(icon, TweenInfo.new(0.5), {
                    Size = UDim2.new(0, 22, 0, 22),
                    Position = UDim2.new(0.5, -11, 0.5, -11)
                }):Play()
            end
        end
    end
    local currentIdx = table.find(customTabOrder, currentPage or "house") or 1
    svc.TweenService:Create(navIndicator, TweenInfo.new(0.5), {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10 + (currentIdx - 1) * 60, 0, 9),
        BackgroundTransparency = 1
    }):Play()
    createCustomItemsPanel()
    if customItemsPanel then
        local cam = workspace.CurrentCamera
        local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local panelW = 260
        local targetX = screenSize.X - panelW - 20
        svc.TweenService:Create(customItemsPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, targetX, 0, customItemsPanel.Position.Y.Offset)
        }):Play()
    end
end

function exitCustomTabMode()
    if not customTabMode then return end
    customTabMode = false
    local n = #customTabOrder
    local targetW = btnXPositions[n] + 36
    local targetH = 38
    local targetX = math.floor(originalNavState.centerX - targetW / 2)
    local targetY = math.floor(originalNavState.centerY - targetH / 2)
    local tween = svc.TweenService:Create(navBg, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, targetX, 0, targetY),
        Size = UDim2.new(0, targetW, 0, targetH)
    })
    tween:Play()
    for i, name in ipairs(customTabOrder) do
        local btn = navButtons[name]
        if btn then
            local targetBtnX = btnXPositions[i]
            svc.TweenService:Create(btn, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, targetBtnX, 0, 3),
                Size = UDim2.new(0, 32, 0, 32)
            }):Play()
            local icon = btn:FindFirstChildOfClass("ImageLabel")
            if icon then
                svc.TweenService:Create(icon, TweenInfo.new(0.5), {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0.5, -9, 0.5, -9)
                }):Play()
            end
        end
    end
    if currentPage and navButtons[currentPage] then
        local btnIdx = table.find(customTabOrder, currentPage) or 1
        local targetX = btnXPositions[btnIdx]
        local targetPos = UDim2.new(0, targetX, 0, 3)
        svc.TweenService:Create(navIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 32, 0, 32),
            Position = targetPos,
            BackgroundTransparency = 0.2
        }):Play()
    else
        svc.TweenService:Create(navIndicator, TweenInfo.new(0.5), {
            BackgroundTransparency = 0.2
        }):Play()
    end
    tween.Completed:Connect(function()
        navBg.AnchorPoint = originalNavState.anchorPoint
        navBg.Position = originalNavState.position
        navBg.Size = originalNavState.size
        navBg.Parent = originalNavState.parent
        wrapperFrame.Visible = true
        rightToggleBar.Visible = true
        bottomBar.Visible = true
        logoutBtn.Visible = true
        statsRow.Visible = true
        fadeInUI(0.3)
    end)

    if customItemsPanel and customItemsPanel.Parent then
        local cam = workspace.CurrentCamera
        local screenSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        svc.TweenService:Create(customItemsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0, screenSize.X + 10, 0, customItemsPanel.Position.Y.Offset)
        }):Play()
        task.delay(0.45, function()
            if customItemsPanel then
                customItemsPanel:Destroy()
                customItemsPanel = nil
            end
            customItemsScroll = nil
            customItemsRows = {}
            customDeleteOpenRow = nil
            customListDragging = false
            customListDragRow = nil
            customListDragName = nil
            for _, conn in ipairs(customListDragConnections) do
                conn:Disconnect()
            end
            customListDragConnections = {}
        end)
    end
end

setupTabDragHandlers()

wrapperFrame = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -44, 0, 86),
    Size = UDim2.new(1, -56, 1, -98),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 2
})
wrapperFrame.Parent = main
statsRow = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -44, 0, 60),
    Size = UDim2.new(1, -56, 0, 26),
    BackgroundTransparency = 1,
    ZIndex = 5
})
statsRow.Parent = main
local function makeStatPill(text, iconName)
    local pill = create("Frame", {Size = UDim2.new(0, 60, 0, 22), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 6})
    corner(11, pill)
    local icon = GetIcon(iconName, UDim2.new(0, 10, 0, 10), theme.textDim)
    if icon then
        icon.Position = UDim2.new(0, 5, 0.5, -5)
        icon.Parent = pill
    end
    label = create("TextLabel", {Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 7})
    label.Parent = pill
    return pill, label
end
leftStats = create("Frame", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5})
leftStats.Parent = statsRow
leftStatsLayout = create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6)})
leftStatsLayout.Parent = leftStats
pingPill, pingLabel = makeStatPill("34 ms", "wifi")
pingPill.Parent = leftStats
fpsPill, fpsLabel = makeStatPill("59 FPS", "zap")
fpsPill.Parent = leftStats
rightStats = create("Frame", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 32, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5})
rightStats.Parent = statsRow
rightStatsLayout = create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6)})
rightStatsLayout.Parent = rightStats
timePill = create("Frame", {Size = UDim2.new(0, 70, 0, 22), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 6, LayoutOrder = 2})
corner(11, timePill)
timeIcon = GetIcon("clock", UDim2.new(0, 10, 0, 10), theme.textDim)
if timeIcon then timeIcon.Position = UDim2.new(0, 5, 0.5, -5); timeIcon.Parent = timePill end
timeLabel = create("TextLabel", {Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = "12:00 PM", TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
timeLabel.Parent = timePill
allTimeLabels = {timeLabel}
allPingLabels = {pingLabel}
allFpsLabels = {fpsLabel}

local fpsCounter = 0
local lastFpsUpdate = tick()
svc.RunService.RenderStepped:Connect(function()
    fpsCounter = fpsCounter + 1
    local now = tick()
    if now - lastFpsUpdate >= 1 then
        local fps = math.floor(fpsCounter / (now - lastFpsUpdate))
        for _, label in ipairs(allFpsLabels) do
            if label and label.Parent then
                label.Text = bypassModeActive and "N/A" or (fps .. " FPS")
            end
        end
        fpsCounter = 0
        lastFpsUpdate = now
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        local ok, pingVal = pcall(function()
            return svc.Stats.PerformanceStats.Ping:GetValue()
        end)
        local ping = ok and math.floor(pingVal) or 0
        for _, label in ipairs(allPingLabels) do
            if label and label.Parent then
                label.Text = bypassModeActive and "N/A" or (ping .. " ms")
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        local timeStr = os.date("%I:%M %p")
        for _, label in ipairs(allTimeLabels) do
            if label and label.Parent then
                label.Text = timeStr
            end
        end
    end
end)

timePill.Parent = rightStats
labelPill = create("Frame", {Size = UDim2.new(0, 55, 0, 22), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 6, LayoutOrder = 1})
corner(11, labelPill)
labelIcon = GetIcon("tag", UDim2.new(0, 10, 0, 10), theme.textDim)
if labelIcon then labelIcon.Position = UDim2.new(0, 5, 0.5, -5); labelIcon.Parent = labelPill end
labelText = create("TextLabel", {Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = t("Label"), TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
labelText.Parent = labelPill
labelPill.Parent = rightStats
contentFrame = create("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, -4, 1, 0),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2
})
corner(12, contentFrame)
contentFrame.Parent = wrapperFrame
settingsPage.Parent = contentFrame

cloudPage.Parent = contentFrame

local wasaiPage = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2})
wasaiPage.Parent = contentFrame

local wasaiPromptResumeChat
local wasaiMessageFrame
local wasaiInputBox
local wasaiSendButton
local wasaiFinalizeMessage
local wasaiShowScriptResult
local wasaiAddMessage
local wasaiTypewriteMessage
local wasaiRenderMessageWithCode
local wasaiSendMessage
do
local wasaiChatMemory = { lastPath = nil, lastObj = nil, lastDeletedDir = nil }
local wasaiResumeParent = nil

-- File path security: validate against path traversal attacks
local function wasaiValidatePath(path)
    if type(path) ~= "string" or path == "" then return false end
    -- Block path traversal attempts
    if path:find("%.%.%/") or path:find("%.%.\\") or path:find("%.%.%.$") then return false end
    if path:find("\x00") or path:find("\\") then return false end
    -- Only allow safe characters
    if not path:match("^[%w_./ %-]+$") then return false end
    return true
end


local function wasaiGetInstanceFromPath(path)
    local i2, j2 = 1, #path
    while i2 <= j2 and string.byte(path:sub(i2,i2)) <= 32 do i2 = i2 + 1 end
    while j2 >= i2 and string.byte(path:sub(j2,j2)) <= 32 do j2 = j2 - 1 end
    path = path:sub(i2, j2)
    local env = {
        game = game,
        workspace = workspace,
        Players = svc.Players,
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        ServerScriptService = game:GetService("ServerScriptService"),
        StarterGui = game:GetService("StarterGui"),
        StarterPack = game:GetService("StarterPack"),
        StarterPlayer = game:GetService("StarterPlayer"),
        Lighting = game:GetService("Lighting"),
        SoundService = game:GetService("SoundService"),
    }
    local func, err = loadstring("return " .. path)
    if not func then return nil, "路径解析失败: " .. err end
    setfenv(func, env)
    local success, result = pcall(func)
    if not success then return nil, "路径执行错误: " .. tostring(result) end
    return result, nil
end

local function wasaiGetChildNames(instance)
    if not instance then return {} end
    local names = {}
    for _, child in ipairs(instance:GetChildren()) do
        table.insert(names, child.Name .. " (" .. child.ClassName .. ")")
    end
    return names
end

local function wasaiTryDecompile(scriptObj)
    if not scriptObj:IsA("LuaSourceContainer") then return nil, "不是脚本/模块" end
    if not decompile then return nil, "当前环境不支持反编译 (decompile 函数缺失)" end
    local success, source = pcall(decompile, scriptObj)
    if not success then return nil, "反编译失败: " .. tostring(source) end
    return source, nil
end

local function wasaiGetAllScripts(container)
    -- 迭代遍历，避免深层实例树导致递归栈溢出（可导致瞬时崩溃）
    local scripts = {}
    local stack = {container}
    while #stack > 0 do
        local obj = stack[#stack]
        stack[#stack] = nil
        if obj then
            local children = obj:GetChildren()
            for i = #children, 1, -1 do
                local child = children[i]
                if child:IsA("LuaSourceContainer") then table.insert(scripts, child) end
                stack[#stack + 1] = child
            end
        end
    end
    return scripts
end

-- 净化单个路径段：去掉非法文件系统字符并限制长度，防止原生崩溃
local function wasaiSafeSegment(seg)
    seg = tostring(seg or ""):gsub("[\\/:*?\"<>|%c\r\n\t]", "_")
    if seg == "" then seg = "_" end
    if #seg > 40 then seg = seg:sub(1, 40) end
    return seg
end

local function wasaiSaveScriptToFile(script, baseDir, rootName)
    if not writefile or not makefolder or not isfolder then return false, "文件系统函数不可用" end
    local source, err = wasaiTryDecompile(script)
    if not source then return false, err end

    local fullName = script:GetFullName()
    local relativePath = fullName:gsub("^game%.", "")

        if rootName then
        local rootPrefix = rootName .. "."
        if relativePath:sub(1, #rootPrefix) == rootPrefix then
            relativePath = relativePath:sub(#rootPrefix + 1)
        end
    else
                local lastDot = nil
        for i = #relativePath, 1, -1 do
            if relativePath:sub(i, i) == "." then
                lastDot = i
                break
            end
        end
        relativePath = lastDot and relativePath:sub(lastDot + 1) or relativePath
    end

    -- 每段路径净化 + 限制长度，防止原生崩溃
    local segs = {}
    for seg in relativePath:gmatch("[^%.]+") do
        table.insert(segs, wasaiSafeSegment(seg))
    end
    local fullPath = baseDir .. "/" .. table.concat(segs, "/") .. ".lua"
    if #fullPath > 200 then
        fullPath = baseDir .. "/" .. table.concat(segs, "/"):sub(1, math.max(10, 200 - #baseDir)) .. ".lua"
    end

    local pathParts = {}
    for part in fullPath:gmatch("([^/]+)") do table.insert(pathParts, part) end
    table.remove(pathParts, #pathParts)
    local currentPath = ""
    for _, part in ipairs(pathParts) do
        currentPath = currentPath .. part .. "/"
        local okDir = pcall(function()
            if not isfolder(currentPath) then makefolder(currentPath) end
        end)
        if not okDir then return false, "目录创建失败: " .. tostring(currentPath) end
    end
    if isfolder(fullPath) then fullPath = fullPath .. "_" .. tostring(os.time()) .. ".lua" end
    local successWrite, errWrite = pcall(writefile, fullPath, source)
    if not successWrite then return false, tostring(errWrite) end
    wasaiTrackFileOp(fullPath)
    return true, fullPath
end

local function wasaiListAllProperties(instance)
    if not instance then return {} end
    local props = {}
    for _, prop in ipairs(instance:GetProperties()) do
        local success, val = pcall(function() return instance[prop] end)
        if success then table.insert(props, prop .. " = " .. tostring(val))
        else table.insert(props, prop .. " = <无法读取>") end
    end
    return props
end

local function wasaiFindObjectsByName(name, container)
    local results = {}
    local function recurse(obj)
        if obj.Name:lower():find(name:lower(), 1, true) then
            table.insert(results, obj:GetFullName() .. " (" .. obj.ClassName .. ")")
        end
        for _, child in ipairs(obj:GetChildren()) do recurse(child) end
    end
    recurse(container)
    return results
end

local function wasaiListChildrenDepth(instance, maxDepth)
    local result = {}
    local function recurse(obj, depth)
        if depth > maxDepth then return end
        local indent = string.rep("  ", depth)
        table.insert(result, indent .. obj.Name .. " (" .. obj.ClassName .. ")")
        for _, child in ipairs(obj:GetChildren()) do recurse(child, depth + 1) end
    end
    recurse(instance, 0)
    return result
end

-- 带超时的函数执行器：在独立线程运行，超时后取消，防止 WaitForChild 等无限 yield 卡死
local function wasaiExecWithTimeout(func, seconds)
    local done = false
    local okRes, ret, err = nil, nil, nil
    local th = task.spawn(function()
        local ok, a, b = pcall(func)
        okRes, ret, err = ok, a, b
        done = true
    end)
    local waited = 0
    local limit = tonumber(seconds) or 15
    while not done and waited < limit do
        task.wait(0.1)
        waited = waited + 0.1
    end
    if not done then
        pcall(task.cancel, th)
        return nil, "执行超时（可能 WaitForChild 等待的对象不存在，已中断）"
    end
    if okRes then return ret, nil else return nil, tostring(err) end
end

local function wasaiExecuteLuaCode(code)
    local func, err = loadstring(code)
    if not func then return nil, "编译错误: " .. err end
    local execTimeout = tonumber(wasaiLocalAIConfig.executeTimeout) or 15

    -- 捕获 print 输出（供 AI 读取）同时输出到真实控制台
    local out = {}
    local realPrint = print
    local realRconPrint = rconsoleprint
    local function makePrint()
        return function(...)
            local parts = {}
            for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
            local line = table.concat(parts, " ")
            table.insert(out, line)
            -- 真实控制台输出
            pcall(realPrint, line)
            if type(realRconPrint) == "function" then pcall(realRconPrint, line .. "\n") end
        end
    end

    -- 让代码在真实可用环境里执行（可访问 game/workspace/Instance 及标准库）
    local okEnv, realEnv = pcall(getfenv)
    if okEnv and type(realEnv) == "table" then
        local env = setmetatable({print = makePrint()}, {__index = realEnv})
        local okSet = pcall(setfenv, func, env)
        if not okSet then
            -- setfenv 不可用时退回默认环境直接执行（同样带超时）
            local success, result = wasaiExecWithTimeout(func, execTimeout)
            if not success then return nil, "执行错误: " .. tostring(result) end
            if result ~= nil then table.insert(out, tostring(result)) end
            return table.concat(out, "\n"), nil
        end
    else
        local okSet = pcall(setfenv, func, {print = makePrint()})
        if not okSet then
            local success, result = wasaiExecWithTimeout(func, execTimeout)
            if not success then return nil, "执行错误: " .. tostring(result) end
            if result ~= nil then table.insert(out, tostring(result)) end
            return table.concat(out, "\n"), nil
        end
    end

    local success, result = wasaiExecWithTimeout(func, execTimeout)
    if not success then return nil, "执行错误: " .. tostring(result) end
    if result ~= nil then table.insert(out, tostring(result)) end
    return table.concat(out, "\n"), nil
end

local function wasaiTrim(str)
    local i, j = 1, #str
    while i <= j and string.byte(str:sub(i,i)) <= 32 do i = i + 1 end
    while j >= i and string.byte(str:sub(j,j)) <= 32 do j = j - 1 end
    return str:sub(i, j)
end

local function wasaiIsPathInput(text)
    local trimmed = wasaiTrim(text)
    local pathPrefixes = {"game.", "workspace.", "Players.", "ReplicatedStorage.", "ServerScriptService.", "StarterGui.", "StarterPack.", "StarterPlayer.", "Lighting.", "SoundService."}
    for _, prefix in ipairs(pathPrefixes) do
        if trimmed:sub(1, #prefix) == prefix then
            return true
        end
    end
    if trimmed:find(".", 1, true) and #trimmed > 5 then
        local test, _ = wasaiGetInstanceFromPath(trimmed)
        if test then return true end
    end
    return false
end


local wasaiConversationState = {
    topic = nil, topicEntities = {}, userMood = "neutral", contextMemory = {}, lastAction = nil, }

local function wasaiUpdateConversationState(input, intent, entities)
        if entities.path then
        wasaiConversationState.topic = "instance"
        wasaiConversationState.topicEntities.path = entities.path
    elseif intent == "search" then
        wasaiConversationState.topic = "search"
        wasaiConversationState.topicEntities.target = entities.target
    end

        wasaiConversationState.lastAction = {
        intent = intent,
        entities = entities,
        timestamp = os.time()
    }

        if input:match("谢谢|感谢|好棒|太棒了") then
        wasaiConversationState.userMood = "happy"
    elseif input:match("算了|不用了|错误|失败|糟糕") then
        wasaiConversationState.userMood = "frustrated"
    elseif input:match("为什么|怎么|如何") then
        wasaiConversationState.userMood = "curious"
    else
        wasaiConversationState.userMood = "neutral"
    end
end


local wasaiChineseSensitiveWords = {
    "他妈的", "他妈", "草你妈", "操你妈", "傻逼", "煞笔", "傻b", "cnm", "qnmd", "tmd",
    "废物", "去死", "脑残", "弱智", "白痴", "神经病", "杂种", "王八蛋",
    "操你", "操蛋", "草你", "草泥马", "贱人", "贱货", "贱逼", "婊子",
    "狗东西", "狗娘", "狗日", "狗屎", "狗屁", "傻狗", "狗杂种",
    "猪头", "猪脑", "笨猪", "猪狗", "蠢猪",
    "滚蛋", "滚开", "滚犊子",
}

local wasaiEnglishSensitiveWords = {
    "fuck", "fucking", "fucked", "fucker", "shit", "shitting", "bitch", "bitchy",
    "asshole", "dickhead", "cock", "cunt", "nigger", "faggot", "retard", "damn", "dammit", "sb",
}

local wasaiContextSensitiveWords = { "草", "操", "滚", "贱", "狗", "猪" }

local function isBoundary(c)
    if c == "" then return true end
    if c:match("%s") then return true end
    local b = c:byte()
    if b < 128 then

        if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or b == 95 then
            return false
        end
        return true
    end

    local cnPunct = "，。！？、；：“”‘’（）【】《》…—·"
    return cnPunct:find(c, 1, true) ~= nil
end

local function isWholeWord(text, pos, len)
    local before = pos > 1 and text:sub(pos - 1, pos - 1) or ""
    local after = pos + len <= #text and text:sub(pos + len, pos + len) or ""
    return isBoundary(before) and isBoundary(after)
end

local function wasaiCheckSensitive(text)
    if not text or text == "" then return false end
    local lower = string.lower(text)

    for _, w in ipairs(wasaiEnglishSensitiveWords) do
        local pos = 1
        while true do
            local s, e = lower:find(w, pos, true)
            if not s then break end
            if isWholeWord(lower, s, #w) then return true end
            pos = e + 1
        end
    end

    for _, w in ipairs(wasaiChineseSensitiveWords) do
        if lower:find(w, 1, true) then return true end
    end

    for _, w in ipairs(wasaiContextSensitiveWords) do
        local pos = 1
        while true do
            local s, e = lower:find(w, pos, true)
            if not s then break end
            if isWholeWord(lower, s, #w) then return true end
            pos = e + 1
        end
    end
    return false
end

local wasaiThinkingPhases = {
    instruction = {
        "分析指令意图...",
        "解析参数结构...",
        "构建执行方案...",
        "验证操作安全性...",
        "准备返回结果...",
        "正在执行操作...",
    },
    path = {
        "识别路径格式...",
        "验证路径有效性...",
        "查询对象层级...",
        "检查访问权限...",
        "整理返回信息...",
        "定位目标对象...",
    },
    chat = {
        "理解对话内容...",
        "匹配情感状态...",
        "检索相关记忆...",
        "组织回复语言...",
        "优化表达方式...",
    },
    code = {
        "分析代码片段...",
        "检查语法结构...",
        "评估执行效率...",
        "准备输出结果...",
        "验证安全性...",
    },
    search = {
        "确定搜索范围...",
        "遍历目标容器...",
        "匹配目标对象...",
        "整理搜索结果...",
    },
    decompile = {
        "定位脚本位置...",
        "读取源码内容...",
        "处理反编译请求...",
        "格式化输出结果...",
    },
    fallback = {
        "仍在思考...",
        "让我想想...",
        "理解你的意思...",
        "组织回复...",
    }
}

local wasaiRobloxKnowledge = {
    services = {
        game = {"Workspace", "Players", "ReplicatedStorage", "ServerScriptService", "StarterGui", "StarterPack", "Lighting", "SoundService", "TextChatService"},
        Workspace = {"BasePart", "Model", "Terrain", "Camera"},
        Players = {"Player", "LocalPlayer"},
        Player = {"Character", "Backpack", "PlayerGui", "PlayerScripts"},
        Character = {"Humanoid", "HumanoidRootPart", "Head", "Torso", "LeftArm", "RightArm"},
        Humanoid = {"Health", "MaxHealth", "WalkSpeed", "JumpPower"},
        BasePart = {"Position", "Size", "BrickColor", "Transparency", "Anchored", "CanCollide"},
        Model = {"PrimaryPart", "GetChildren", "GetDescendants"},
    },
    commonPatterns = {
        "game.Workspace.%w+",
        "game.Players.LocalPlayer.Character",
        "game.ReplicatedStorage.%w+",
        "game.Workspace.%w+.Humanoid",
    }
}

local wasaiMetrics = {
    thinkingStartTime = 0, toolCalls = 0, fileOperations = 0, }

-- 思考过程可视化：当前处理阶段（由 wasaiGenerateResponseCore 实时更新，思考气泡读取显示）
local wasaiThinkingPhase = ""
-- AI通过report_progress自定义的进度消息，在API等待阶段持续显示
local wasaiCustomProgressMsg = ""

local wasaiRecentSavedFiles = {}
local wasaiLastDecompileDir = nil

local function wasaiResetMetrics()
    wasaiMetrics.thinkingStartTime = 0
    wasaiMetrics.toolCalls = 0
    wasaiMetrics.fileOperations = 0
end

local function wasaiStartTiming()
    wasaiMetrics.thinkingStartTime = tick()
end

local function wasaiTrackToolCall()
    wasaiMetrics.toolCalls = wasaiMetrics.toolCalls + 1
end

local function wasaiTrackFileOp(filePath)
    wasaiMetrics.fileOperations = wasaiMetrics.fileOperations + 1
    if filePath and type(filePath) == "string" then
        table.insert(wasaiRecentSavedFiles, filePath)
        if #wasaiRecentSavedFiles > 500 then
            table.remove(wasaiRecentSavedFiles, 1)
        end
    end
end

local function wasaiClearSavedFilesTracking()
    wasaiRecentSavedFiles = {}
    wasaiLastDecompileDir = nil
end

local function wasaiGetThinkingDuration()
    local elapsed
    if wasaiMetrics.thinkingStartTime == 0 then
        elapsed = wasaiLocalAIState.lastLatency or 0
    else
        elapsed = math.floor((tick() - wasaiMetrics.thinkingStartTime) * 100) / 100
    end
    local complexity = wasaiMetrics.toolCalls * 0.8 + wasaiMetrics.fileOperations * 0.4
    local minTime = math.floor((1.5 + math.min(complexity, 3.0)) * 100) / 100
    local float = math.floor(math.random() * 0.5 * 100) / 100
    return math.floor(math.max(elapsed, minTime) * 100 + float * 100) / 100
end

local function wasaiGenerateStatsText(done)
    local duration = wasaiGetThinkingDuration()
    local durationStr = string.format("%.2f", duration)
    local prefix = done and "思考完成" or "仍在思考"
    if wasaiMetrics.toolCalls == 0 and wasaiMetrics.fileOperations == 0 then
        return prefix .. " " .. durationStr .. "s"
    end
    local parts = {prefix .. " " .. durationStr .. "s"}
    if wasaiMetrics.toolCalls > 0 then
        table.insert(parts, "执行了 " .. wasaiMetrics.toolCalls .. " 次 lua")
    end
    if wasaiMetrics.fileOperations > 0 then
        table.insert(parts, "操作 " .. wasaiMetrics.fileOperations .. " 次文件系统")
    end
    return table.concat(parts, " · ")
end

local wasaiCurrentSession = {
    sessionDir = nil,
    sessionFile = nil,
    placeId = nil,
    sessionTitle = nil,
    sessionTime = nil,
    isFirstRound = true,
    titleTried = false,
}

local function wasaiGenerateTitle(userInput)
    if not userInput or userInput == "" then return "新对话" end
    local cleaned = tostring(userInput):gsub("[，。！？、,%.!?：:；;…—%-]+", " ")
    cleaned = cleaned:gsub("%s+", " ")
    local title = cleaned:sub(1, 24)
    if #cleaned > 24 then title = title .. "…" end
    title = title:gsub("^%s+", ""):gsub("%s+$", "")
    return title ~= "" and title or "新对话"
end

local function wasaiEnsureAgentFolders()
    if not makefolder then return false end
    pcall(function()
        if not isfolder("DeltaUI") then makefolder("DeltaUI") end
        if not isfolder("DeltaUI/Agent") then makefolder("DeltaUI/Agent") end
        if not isfolder("DeltaUI/Agent/Chat") then makefolder("DeltaUI/Agent/Chat") end
        if not isfolder("DeltaUI/Agent/Remember") then makefolder("DeltaUI/Agent/Remember") end
    end)
    return true
end

local function wasaiInitSessionDir()
    if wasaiCurrentSession.sessionDir then return wasaiCurrentSession.sessionDir end

    wasaiEnsureAgentFolders()

    local placeId = tostring(game.PlaceId or 0)
    local baseDir = "DeltaUI/Agent/Chat/对话_" .. placeId

    if not isfolder(baseDir) and makefolder then
        pcall(function() makefolder(baseDir) end)
    end

    wasaiCurrentSession.sessionDir = baseDir
    wasaiCurrentSession.placeId = tonumber(placeId) or 0
    wasaiCurrentSession.sessionTime = os.time()

    local titleName = wasaiCurrentSession.sessionTitle or "新对话"
    local safeTitle = tostring(titleName):gsub("[/\\:*?\"<>|\r\n\t ]+", "_"):gsub("^_+", ""):gsub("_+$", "")
    if safeTitle == "" then safeTitle = "default" end
    if #safeTitle > 40 then safeTitle = safeTitle:sub(1, 40) end
    local filePath = baseDir .. "/" .. safeTitle .. ".chat"
    if isfile(filePath) then
        filePath = baseDir .. "/" .. safeTitle .. "_" .. os.time() .. ".chat"
    end
    wasaiCurrentSession.sessionFile = filePath
    wasaiCurrentSession.sessionKey = safeTitle

    return baseDir
end

local function wasaiRenameSessionDir(title)
    wasaiCurrentSession.sessionTitle = title or wasaiCurrentSession.sessionTitle or "新对话"
end

local function wasaiReadChatFile(path)
    if not path or not isfile or not readfile or not isfile(path) then return nil end
    local ok, content = pcall(readfile, path)
    if not ok or not content or content == "" then return nil end

    local data
    local decoded = pcall(function()
        data = svc.HttpService:JSONDecode(content)
    end)
    if decoded and type(data) == "table" and type(data.messages) == "table" then
        return data
    end
    return nil
end

local function wasaiFindLatestChat()
    wasaiEnsureAgentFolders()
    local placeId = tostring(game.PlaceId or 0)
    local folder = "DeltaUI/Agent/Chat/对话_" .. placeId
    if not isfolder(folder) or not listfiles then return nil end

    local candidates = {}
    local ok, files = pcall(listfiles, folder)
    if not ok or type(files) ~= "table" then return nil end

    for _, path in ipairs(files) do
        if isfile(path) and path:match("%.chat$") then
            local data = wasaiReadChatFile(path)
            if data and data.messages and #data.messages > 0 then
                local name = path:match("([^/\\]+)$") or path
                local modified = 0
                if data.updatedAt then modified = tonumber(data.updatedAt) or 0 end
                if modified == 0 then
                    local n = name:match("session_(%d+)")
                    modified = tonumber(n) or (name == "default.chat" and 0 or 1)
                end
                candidates[#candidates + 1] = {
                    path = folder,
                    chatFile = path,
                    name = name:gsub("%.chat$", ""),
                    data = data,
                    modified = modified
                }
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b)
        if a.modified == b.modified then return a.name > b.name end
        return a.modified > b.modified
    end)
    return candidates[1]
end

local function wasaiLoadChatHistory(chatFolder)
    if not chatFolder then return false end
    local data = chatFolder.data or wasaiReadChatFile(chatFolder.chatFile)
    if not data or type(data.messages) ~= "table" then return false end

    wasaiChatMemory.conversationHistory = data.messages
    if data.metadata then
        wasaiChatMemory.lastPath = data.metadata.lastPath
        wasaiChatMemory.lastDeletedDir = data.metadata.lastDeletedDir
    end

    wasaiCurrentSession.sessionDir = chatFolder.path
    wasaiCurrentSession.sessionFile = chatFolder.chatFile
    wasaiCurrentSession.sessionKey = chatFolder.name
    wasaiCurrentSession.sessionTitle = data.metadata and data.metadata.title or chatFolder.name
    wasaiCurrentSession.sessionTime = data.createdAt or os.time()
    wasaiCurrentSession.placeId = tonumber(game.PlaceId or 0) or 0
    wasaiCurrentSession.isFirstRound = false
    return true
end

wasaiPromptResumeChat = function()
    local latest = wasaiFindLatestChat()
    if not latest then return false end
    if not wasaiResumeParent or not wasaiResumeParent.Parent then return false end

    local title = ""
    local summary = ""
    local data = latest.data or wasaiReadChatFile(latest.chatFile)
    if data then
        title = data.metadata and data.metadata.title or latest.name or "未知对话"
        if data.messages then
            for i = #data.messages, 1, -1 do
                if data.messages[i].role == "user" then
                    summary = tostring(data.messages[i].content or "")
                    if #summary > 40 then summary = summary:sub(1, 40) .. "…" end
                    break
                end
            end
        end
    end

    local card = create("Frame", {
        Name = "ResumeCard",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 44),
        Size = UDim2.new(0, 340, 0, 132),
        BackgroundColor3 = theme.surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 60,
        Active = true,
        Parent = wasaiResumeParent
    })
    corner(12, card)
    stroke(theme.border, 1, card)

    local headTxt = create("TextLabel", {
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -32, 0, 22),
        BackgroundTransparency = 1,
        Text = "检测到可加载的对话历史",
        TextColor3 = theme.text,
        TextSize = 15,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 61,
        Parent = card
    })
    local subTxt = create("TextLabel", {
        Position = UDim2.new(0, 16, 0, 40),
        Size = UDim2.new(1, -32, 0, 54),
        BackgroundTransparency = 1,
        Text = (title ~= "" and ("对话：" .. title) or "未知对话") .. (summary ~= "" and ("\n最近：\"" .. summary .. "\"") or ""),
        TextColor3 = theme.textDim,
        TextSize = 12,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 61,
        Parent = card
    })

    local cancelBtn = create("TextButton", {
        Position = UDim2.new(0, 16, 1, -40),
        Size = UDim2.new(0.5, -20, 0, 30),
        BackgroundColor3 = theme.surfaceLight,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 62,
        Parent = card
    })
    corner(8, cancelBtn)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "取消",
        TextColor3 = theme.text,
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
        ZIndex = 63,
        Parent = cancelBtn
    })

    local confirmBtn = create("TextButton", {
        Position = UDim2.new(0.5, 4, 1, -40),
        Size = UDim2.new(0.5, -20, 0, 30),
        BackgroundColor3 = theme.accent,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = "",
        ZIndex = 62,
        Parent = card
    })
    corner(8, confirmBtn)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "确认",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Font = Enum.Font.SourceSansBold,
        ZIndex = 63,
        Parent = confirmBtn
    })

    cancelBtn.MouseButton1Click:Connect(function()
        card:Destroy()
    end)

    confirmBtn.MouseButton1Click:Connect(function()
        card:Destroy()
        if wasaiLoadChatHistory(latest) then
            wasaiCurrentSession.isFirstRound = false
            task.spawn(function()
                local history = wasaiChatMemory.conversationHistory or {}
                for _, msg in ipairs(history) do
                    wasaiAddMessage(msg.content, msg.role == "user")
                    task.wait(0.05)
                end
            end)
        end
    end)

    return true
end

local function wasaiSaveChatHistory()
    if not writefile or not svc.HttpService then return end

    local sessionDir = wasaiInitSessionDir()
    if not wasaiCurrentSession.sessionFile then
        wasaiCurrentSession.sessionFile = sessionDir .. "/default.chat"
        wasaiCurrentSession.sessionKey = "default"
    end

    local messages = wasaiChatMemory.conversationHistory or {}
    local chatData = {
        version = 2,
        sessionKey = wasaiCurrentSession.sessionKey,
        placeId = wasaiCurrentSession.placeId or game.PlaceId or 0,
        createdAt = wasaiCurrentSession.sessionTime or os.time(),
        updatedAt = os.time(),
        messages = messages,
        metadata = {
            lastPath = wasaiChatMemory.lastPath,
            lastDeletedDir = wasaiChatMemory.lastDeletedDir,
            totalRounds = #messages,
            title = wasaiCurrentSession.sessionTitle or "新对话"
        }
    }

    local ok, jsonStr = pcall(function()
        return svc.HttpService:JSONEncode(chatData)
    end)
    if ok and jsonStr then
        pcall(function() writefile(wasaiCurrentSession.sessionFile, jsonStr) end)
    end
end

local wasaiMemoryDBPath = "DeltaUI/Agent/Remember/memory_v3.db"
local wasaiMemoryCache = nil
local wasaiMemoryDirty = false
local wasaiMemoryCategories = {
    fact = {decayRate = 0.005, minImportance = 0.3},
    preference = {decayRate = 0.002, minImportance = 0.5},
    decision = {decayRate = 0.003, minImportance = 0.4},
    tool_result = {decayRate = 0.01, minImportance = 0.2},
    entity = {decayRate = 0.004, minImportance = 0.3},
    context = {decayRate = 0.015, minImportance = 0.1},
}

local function wasaiMemoryNormalize(text)
    return tostring(text or ""):lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function wasaiMemoryTokenize(text)
    local tokens = {}
    local normalized = wasaiMemoryNormalize(text)
    for word in normalized:gmatch("[%a_]+") do
        if #word >= 2 then
            tokens[#tokens + 1] = word
        end
    end
    local compact = normalized:gsub("%s+", "")
    if #compact >= 3 then
        for i = 1, #compact - 2 do
            local triple = compact:sub(i, i + 2)
            if triple:match("[\228-\255]") then
                tokens[#tokens + 1] = triple
            end
        end
    end
    return tokens
end
local function wasaiExtractMemories(input, output, context)
    local memories = {}
    local userInput = tostring(input or "")
    local aiOutput = tostring(output or "")
    local combined = userInput .. " " .. aiOutput
    local now = os.time()
    local topic = wasaiConversationState and wasaiConversationState.topic or nil
    for scriptPath, byteCount in aiOutput:gmatch("已反编译%s*([^\n，,]+)[^%d]*(%d+)%s*字节") do
        memories[#memories + 1] = {
            category = "tool_result",
            content = "用户反编译了脚本 " .. scriptPath .. "，源码 " .. byteCount .. " 字节",
            tags = {"decompile", scriptPath},
            importance = 0.6,
            time = now,
            lastAccess = now,
            accessCount = 0,
        }
    end
    for filePath in aiOutput:gmatch("已保存到：([^\n]+)") do
        filePath = wasaiTrim(filePath)
        if filePath ~= "" then
            memories[#memories + 1] = {
                category = "tool_result",
                content = "反编译源码保存路径：" .. filePath,
                tags = {"decompile", "filepath", filePath},
                importance = 0.4,
                time = now,
                lastAccess = now,
                accessCount = 0,
            }
        end
    end
    for count in aiOutput:gmatch("共保存%s*(%d+)%s*个脚本") do
        memories[#memories + 1] = {
            category = "tool_result",
            content = "批量反编译完成，共保存 " .. count .. " 个脚本",
            tags = {"decompile_all", "batch"},
            importance = 0.5,
            time = now,
            lastAccess = now,
            accessCount = 0,
        }
    end
    for path in combined:gmatch("(game%.[%w%.]+)") do
        if #path > 8 and #path < 200 then
            memories[#memories + 1] = {
                category = "entity",
                content = "用户提及的 Roblox 对象路径：" .. path,
                tags = {"path", path},
                importance = 0.4,
                time = now,
                lastAccess = now,
                accessCount = 0,
            }
        end
    end
    for _, svc in ipairs({"PlayerScripts", "ReplicatedStorage", "ServerScriptService", "Workspace", "StarterGui"}) do
        if combined:find(svc, 1, true) then
            memories[#memories + 1] = {
                category = "entity",
                content = "对话中涉及 " .. svc .. " 服务",
                tags = {"service", svc},
                importance = 0.3,
                time = now,
                lastAccess = now,
                accessCount = 0,
            }
        end
    end
    if userInput:match("我喜欢|我偏好|我习惯|我总是|我喜欢用|帮我用") then
        local prefContent = userInput:match("我喜欢(.+)") or userInput:match("我偏好(.+)") or userInput:match("我习惯(.+)") or ""
        prefContent = wasaiTrim(prefContent)
        if prefContent ~= "" and #prefContent < 200 then
            memories[#memories + 1] = {
                category = "preference",
                content = "用户偏好：" .. prefContent,
                tags = {"preference"},
                importance = 0.8,
                time = now,
                lastAccess = now,
                accessCount = 0,
            }
        end
    end

    if userInput:match("那就用|决定|选择|那就这么") then
        local decisionContent = userInput:match("那就用(.+)") or userInput:match("决定(.+)") or userInput:match("选择(.+)") or ""
        decisionContent = wasaiTrim(decisionContent)
        if decisionContent ~= "" and #decisionContent < 200 then
            memories[#memories + 1] = {
                category = "decision",
                content = "用户决策：" .. decisionContent,
                tags = {"decision"},
                importance = 0.7,
                time = now,
                lastAccess = now,
                accessCount = 0,
            }
        end
    end
    for fact in aiOutput:gmatch("([^\n。！？]+[是包含有][^\n。！？]+)") do
        fact = wasaiTrim(fact)
        if #fact > 10 and #fact < 300 then
            if not fact:find("已反编译") and not fact:find("已保存") and not fact:find("共保存") then
                memories[#memories + 1] = {
                    category = "fact",
                    content = fact,
                    tags = {"knowledge"},
                    importance = 0.5,
                    time = now,
                    lastAccess = now,
                    accessCount = 0,
                }
            end
        end
    end

    -- 7. Always store a context summary of the exchange (low importance, fast decay)
    local contextSummary = wasaiTrim(userInput:sub(1, 80))
    if contextSummary ~= "" then
        memories[#memories + 1] = {
            category = "context",
            content = "用户曾问过：" .. contextSummary,
            tags = topic and {topic} or {"conversation"},
            importance = 0.2,
            time = now,
            lastAccess = now,
            accessCount = 0,
        }
    end

    return memories
end
local function wasaiMemorySimilarity(memA, memB)
    local tokensA = wasaiMemoryTokenize(memA.content)
    local tokensB_set = {}
    for _, t in ipairs(wasaiMemoryTokenize(memB.content)) do
        tokensB_set[t] = true
    end
    if #tokensA == 0 then return 0 end
    local hits = 0
    for _, t in ipairs(tokensA) do
        if tokensB_set[t] then hits = hits + 1 end
    end
    return hits / #tokensA
end

-- Load all memories from disk
local function wasaiLoadMemoryDB()
    if wasaiMemoryCache then return wasaiMemoryCache end
    wasaiMemoryCache = {}
    if not isfile or not readfile or not isfile(wasaiMemoryDBPath) then
        return wasaiMemoryCache
    end
    local ok, content = pcall(readfile, wasaiMemoryDBPath)
    if not ok or not content then return wasaiMemoryCache end
    for line in tostring(content):gmatch("[^\r\n]+") do
        local data
        local decoded = pcall(function() data = svc.HttpService:JSONDecode(line) end)
        if decoded and type(data) == "table" and data.content and data.category then
            wasaiMemoryCache[#wasaiMemoryCache + 1] = data
        end
    end
    return wasaiMemoryCache
end

-- Persist memory DB to disk
local function wasaiSaveMemoryDB()
    if not wasaiMemoryDirty or not writefile then return end
    wasaiEnsureAgentFolders()
    local lines = {}
    for _, mem in ipairs(wasaiMemoryCache or {}) do
        local ok, encoded = pcall(function() return svc.HttpService:JSONEncode(mem) end)
        if ok and encoded then
            lines[#lines + 1] = encoded
        end
    end
    pcall(function() writefile(wasaiMemoryDBPath, table.concat(lines, "\n")) end)
    wasaiMemoryDirty = false
end

-- Add or merge a memory entry
local function wasaiAddMemory(mem)
    local db = wasaiLoadMemoryDB()
    -- Check for duplicates / similar memories to merge
    for i, existing in ipairs(db) do
        if existing.category == mem.category then
            local sim = wasaiMemorySimilarity(existing, mem)
            if sim >= 0.75 then
                -- Merge: update content, boost importance, update timestamp
                if #mem.content > #existing.content then
                    db[i].content = mem.content
                end
                db[i].importance = math.min(1.0, (existing.importance or 0.3) + 0.1)
                db[i].time = mem.time
                db[i].lastAccess = mem.time
                -- Merge tags
                if mem.tags then
                    db[i].tags = db[i].tags or {}
                    for _, tag in ipairs(mem.tags) do
                        local found = false
                        for _, etag in ipairs(db[i].tags) do
                            if etag == tag then found = true; break end
                        end
                        if not found then table.insert(db[i].tags, tag) end
                    end
                end
                wasaiMemoryDirty = true
                return
            end
        end
    end
    -- No duplicate found, add new entry
    db[#db + 1] = mem
    wasaiMemoryDirty = true
    -- Enforce max memory entries to prevent unbounded growth
    local maxMemories = 500
    if #db > maxMemories then
        -- Remove lowest-importance, oldest memories first
        table.sort(db, function(a, b)
            local scoreA = (a.importance or 0.3) * 0.7 + (a.accessCount or 0) * 0.05
            local scoreB = (b.importance or 0.3) * 0.7 + (b.accessCount or 0) * 0.05
            return scoreA > scoreB
        end)
        local trimmed = {}
        for i = 1, maxMemories do trimmed[i] = db[i] end
        wasaiMemoryCache = trimmed
    end
end

-- Score a memory's relevance to a query, with time decay
local function wasaiMemoryScore(query, mem)
    if type(mem) ~= "table" then return 0 end
    local qTokens = {}
    for _, t in ipairs(wasaiMemoryTokenize(query)) do qTokens[t] = true end
    if next(qTokens) == nil then return 0 end

    local memText = wasaiMemoryNormalize((mem.content or "") .. " " .. table.concat(mem.tags or {}, " "))
    if memText == "" then return 0 end

    -- Token overlap scoring
    local hits, total = 0, 0
    for token in pairs(qTokens) do
        total = total + 1
        if memText:find(token, 1, true) then hits = hits + 1 end
    end
    local tokenScore = total > 0 and (hits / total) or 0

    -- Tag boost: if query contains a tag value
    local tagBoost = 0
    if mem.tags then
        for _, tag in ipairs(mem.tags) do
            if #tag >= 3 and query:lower():find(tag:lower(), 1, true) then
                tagBoost = tagBoost + 0.15
            end
        end
    end

    -- Importance weight
    local importance = mem.importance or 0.3

    -- Time decay: older memories lose relevance
    local age = math.max(0, os.time() - tonumber(mem.time or 0)) / 86400
    local category = mem.category or "context"
    local decayRate = (wasaiMemoryCategories[category] or {}).decayRate or 0.01
    local decay = math.max(0.2, 1 - age * decayRate)

    -- Access frequency boost
    local accessBoost = math.min(0.2, (mem.accessCount or 0) * 0.02)

    local score = (tokenScore * 0.6 + tagBoost) * importance * decay + accessBoost
    return math.min(1.0, score)
end

-- Forward declaration: wasaiSafeString is used by wasaiRetrieveMemory below
-- but its full implementation comes later. This avoids "attempt to call a nil value".
local wasaiSafeString

-- Retrieve relevant memories for a query
local function wasaiRetrieveMemory(query, limit)
    local db = wasaiLoadMemoryDB()
    if #db == 0 then return {} end

    local scored = {}
    for _, mem in ipairs(db) do
        local score = wasaiMemoryScore(query, mem)
        if score > 0.05 then
            scored[#scored + 1] = {score = score, record = mem}
        end
    end
    table.sort(scored, function(a, b)
        if a.score == b.score then
            return tonumber(a.record.time or 0) > tonumber(b.record.time or 0)
        end
        return a.score > b.score
    end)

    local result, totalLen = {}, 0
    local maxCount = tonumber(limit) or 8
    for i = 1, math.min(#scored, maxCount) do
        local r = scored[i].record
        -- Update access tracking
        r.accessCount = (r.accessCount or 0) + 1
        r.content = r.content or ""
        r.lastAccess = os.time()
        wasaiMemoryDirty = true
        local item = {
            score = scored[i].score,
            content = wasaiSafeString(r.content or "", 800),
            category = r.category or "unknown",
            tags = r.tags or {},
        }
        totalLen = totalLen + #item.content
        if totalLen > 6000 then break end
        result[#result + 1] = item
    end
    -- Persist access count updates
    wasaiSaveMemoryDB()
    return result
end

-- Main entry: extract and store knowledge from a conversation exchange
local function wasaiSaveMemory(input, output)
    if not input or not output then return end
    wasaiEnsureAgentFolders()
    local memories = wasaiExtractMemories(input, output, wasaiConversationState)
    for _, mem in ipairs(memories) do
        wasaiAddMemory(mem)
    end
    wasaiSaveMemoryDB()
end

-- Backward compat: load all memories as flat records (for any legacy callers)
local function wasaiLoadMemoryRecords(limit)
    local db = wasaiLoadMemoryDB()
    local max = limit or 80
    local start = math.max(1, #db - max + 1)
    local trimmed = {}
    for i = start, #db do
        local mem = db[i]
        trimmed[#trimmed + 1] = {
            input = mem.content or "",
            output = "",
            topic = mem.category or "",
            time = mem.time or os.time(),
        }
    end
    return trimmed
end

local function wasaiGetOutputDir()
    local sessionDir = wasaiInitSessionDir()
    local outputDir = sessionDir .. "/Output"
    if not isfolder(outputDir) and makefolder then pcall(function() makefolder(outputDir) end) end
    return outputDir
end

local function wasaiCalculateThinkingDuration(steps, inputType)
    local base = 0.25
    local typeMultiplier = {
        instruction = 1.1,
        path = 1.0,
        chat = 0.7,
        code = 1.3,
        search = 1.1,
        decompile = 1.2,
        fallback = 1.0
    }
    local m = typeMultiplier[inputType] or 1.0
    local total = #steps * base * m
    return math.min(2.5, math.max(0.8, total))
end

-- Smart decompile target resolver: finds object by name in common locations
local function wasaiResolveDecompileTarget(targetStr)
    if not targetStr or targetStr == "" then return nil, "未提供目标" end
    targetStr = wasaiTrim(targetStr)

    -- If it's a game path, resolve directly
    if targetStr:find("^game%.") or targetStr:find("^workspace") then
        local obj, err = wasaiGetInstanceFromPath(targetStr)
        if obj then return obj, nil, targetStr end
        return nil, err or "路径不可达", targetStr
    end

    -- Known service shortcuts (English + Chinese aliases)
    local function getPS()
        local lp = svc.Players.LocalPlayer
        return lp and lp:FindFirstChild("PlayerScripts"), "PlayerScripts"
    end
    local function getRS()
        return game:GetService("ReplicatedStorage"), "ReplicatedStorage"
    end
    local function getSSS()
        return game:GetService("ServerScriptService"), "ServerScriptService"
    end
    local function getSG()
        return game:GetService("StarterGui"), "StarterGui"
    end
    local function getSP()
        return game:GetService("StarterPlayer"), "StarterPlayer"
    end
    local serviceMap = {
        ["playerscripts"] = getPS, ["player_scripts"] = getPS, ["玩家脚本"] = getPS, ["玩家脚本服务"] = getPS,
        ["replicatedstorage"] = getRS, ["复制储存"] = getRS, ["复制存储"] = getRS,
        ["复制储存服务"] = getRS, ["复制存储服务"] = getRS, ["副本存储"] = getRS,
        ["serverscriptservice"] = getSSS, ["server_script_service"] = getSSS,
        ["服务器脚本服务"] = getSSS, ["服务器脚本"] = getSSS,
        ["startergui"] = getSG, ["starter_gui"] = getSG, ["初始gui"] = getSG, ["启动gui"] = getSG,
        ["starterplayer"] = getSP, ["starter_player"] = getSP, ["初始玩家"] = getSP, ["启动玩家"] = getSP,
    }

    local lower = targetStr:lower():gsub("%s+", "")
    local lowerNoSpace = targetStr:gsub("%s+", "")
    if serviceMap[lower] then
        local obj, name = serviceMap[lower]()
        if obj then return obj, nil, name end
        return nil, name .. " 未找到", name
    end
    if serviceMap[lowerNoSpace] then
        local obj, name = serviceMap[lowerNoSpace]()
        if obj then return obj, nil, name end
        return nil, name .. " 未找到", name
    end
    if serviceMap[targetStr] then
        local obj, name = serviceMap[targetStr]()
        if obj then return obj, nil, name end
        return nil, name .. " 未找到", name
    end

    -- Search by name in PlayerScripts and ReplicatedStorage only
    local searchRoots = {}
    local lp = svc.Players.LocalPlayer
    if lp then
        local ps = lp:FindFirstChild("PlayerScripts")
        if ps then table.insert(searchRoots, {obj = ps, name = "PlayerScripts"}) end
    end
    table.insert(searchRoots, {obj = game:GetService("ReplicatedStorage"), name = "ReplicatedStorage"})

    for _, root in ipairs(searchRoots) do
        if root.obj then
            -- Direct child match
            local child = root.obj:FindFirstChild(targetStr)
            if child then
                return child, nil, child:GetFullName()
            end
            -- Recursive match
            local desc = root.obj:FindFirstChild(targetStr, true)
            if desc then
                return desc, nil, desc:GetFullName()
            end
        end
    end

    return nil, "在 PlayerScripts 和 ReplicatedStorage 中均未找到名为「" .. targetStr .. "」的对象", targetStr
end

-- Smart decompile: handles script, folder, and script-with-children scenarios
local function wasaiDecompileSmart(targetStr)
    local obj, err, resolvedPath = wasaiResolveDecompileTarget(targetStr)
    if not obj then
        return "找不到目标：" .. tostring(err or "未知错误") .. "。请提供脚本路径或名称，例如「反编译 game.Workspace.Script」或「反编译 PlayerScripts 下的某脚本」。"
    end

    local isScript = obj:IsA("LuaSourceContainer")
    local childCount = #obj:GetChildren()
    local childScripts = wasaiGetAllScripts(obj)
    local hasChildScripts = #childScripts > 0

    -- Ensure output dir
    if not isfolder("DeltaUI") then makefolder("DeltaUI") end
    if not isfolder("DeltaUI/Agent") then makefolder("DeltaUI/Agent") end
    local od = wasaiGetOutputDir()
    if not isfolder(od) then makefolder(od) end

    -- Scenario 1: It's a script with no child scripts
    if isScript and not hasChildScripts then
        local source, derr = wasaiTryDecompile(obj)
        if not source then
            return "反编译失败：" .. tostring(derr) .. "\n目标：" .. resolvedPath
        end
        wasaiTrackToolCall()
        local savedPath = nil
        if writefile and makefolder and isfolder then
            local okSave, saveOk, savePath = pcall(wasaiSaveScriptToFile, obj, od, nil)
            if okSave and saveOk then
                savedPath = savePath
                wasaiLastDecompileDir = od
            end
        end
        local msg = "已反编译 " .. resolvedPath .. "，源码共 " .. #source .. " 字节。"
        if savedPath then msg = msg .. "已保存到：" .. tostring(savedPath) end
        return msg

    -- Scenario 2: It's a script WITH child scripts
    elseif isScript and hasChildScripts then
        local source, derr = wasaiTryDecompile(obj)
        if source then
            wasaiTrackToolCall()
            local savedPath = nil
            if writefile and makefolder and isfolder then
                local okSave, saveOk, savePath = pcall(wasaiSaveScriptToFile, obj, od, nil)
                if okSave and saveOk then
                    savedPath = savePath
                    wasaiLastDecompileDir = od
                end
            end
            local msg = "已反编译 " .. resolvedPath .. "，源码共 " .. #source .. " 字节。"
            if savedPath then msg = msg .. "已保存到：" .. tostring(savedPath) end
            msg = msg .. "\n\n我注意到它下方还有 " .. #childScripts .. " 个子脚本。需要我继续反编译这些子脚本吗？"
            return msg
        else
            return "反编译失败：" .. tostring(derr) .. "\n目标：" .. resolvedPath
        end

    -- Scenario 3: It's a folder/container - decompile all scripts inside
    elseif not isScript and hasChildScripts then
        local placeId = game.PlaceId or 0
        local folderName = obj.Name or "Unknown"
        local baseDir = od .. "/反编译_" .. placeId .. "_" .. os.time() .. "/" .. folderName
        if not isfolder(baseDir) then
            local parts = {}
            for part in baseDir:gmatch("([^/]+)") do
                table.insert(parts, part)
            end
            local cur = ""
            for _, part in ipairs(parts) do
                cur = cur .. part .. "/"
                if not isfolder(cur) then makefolder(cur) end
            end
        end

        local saved = 0
        local errors = {}
        for _, sc in ipairs(childScripts) do
            local src, serr = wasaiTryDecompile(sc)
            if src then
                wasaiTrackToolCall()
                local fullName = sc:GetFullName()
                local escapedName = obj:GetFullName():gsub("([^%w])", "%%%1")
                local relPath = fullName:gsub("^" .. escapedName .. "%.?", ""):gsub("%.", "/")
                local filePath = baseDir .. "/" .. relPath .. ".lua"
                local dir = filePath:match("^(.*)/[^/]+$")
                if dir and not isfolder(dir) then
                    local cur = ""
                    for part in dir:gmatch("([^/]+)") do
                        cur = cur .. part .. "/"
                        if not isfolder(cur) then makefolder(cur) end
                    end
                end
                local okw = pcall(writefile, filePath, src)
                if okw then saved = saved + 1; wasaiTrackFileOp(filePath) end
            else
                table.insert(errors, sc:GetFullName() .. ": " .. tostring(serr))
            end
        end
        wasaiLastDecompileDir = baseDir

        local msg = "已反编译 " .. resolvedPath .. " 下的所有脚本，共完成 " .. saved .. " 个"
        if #errors > 0 then
            msg = msg .. "，" .. #errors .. " 个失败"
        end
        msg = msg .. "。\n保存路径：" .. baseDir
        return msg

    -- Scenario 4: Not a script and no child scripts
    else
        return resolvedPath .. " 既不是脚本，其下方也没有找到任何脚本。无法反编译。"
    end
end

local function wasaiExtractContext(text, keyword)
    local s, e = tostring(text or ""):find(keyword, 1, true)
    if not s then return nil end
    local after = tostring(text):sub(e + 1)
    return wasaiTrim(after)
end
local function wasaiDecompileAll(input)
    local lowerInput = string.lower(input or "")
    local function ensureDir()
        if not isfolder("DeltaUI") then makefolder("DeltaUI") end
        if not isfolder("DeltaUI/Agent") then makefolder("DeltaUI/Agent") end
        local od = wasaiGetOutputDir()
        if not isfolder(od) then makefolder(od) end
    end
    local function saveScript(script, baseDir, rootName)
        if not script:IsA("LuaSourceContainer") then return false, "不是脚本" end
        if not decompile then return false, "当前环境不支持反编译" end
        local source, err = wasaiTryDecompile(script)
        if not source then return false, err end
        wasaiTrackToolCall()
        local fullName = script:GetFullName()
        local relativePath = fullName:gsub("^game%.", "") -- 去掉 game. 前缀
        local rootPrefix = rootName .. "."
        if relativePath:sub(1, #rootPrefix) == rootPrefix then
            relativePath = relativePath:sub(#rootPrefix + 1)
        end
        if rootName == "Players" then
            relativePath = relativePath:gsub("^LocalPlayer%.", "")
        end
        -- 每段路径都做净化，防止非法字符/超长路径导致原生文件系统崩溃
        local segs = {}
        for seg in relativePath:gmatch("[^%.]+") do
            table.insert(segs, wasaiSafeSegment(seg))
        end
        local outFolder = rootName == "Players" and "PlayerScripts" or rootName
        local safeOut = wasaiSafeSegment(outFolder)
        local joined = table.concat(segs, "/")
        local filePath = baseDir .. "/" .. safeOut .. "/" .. joined .. ".lua"
        -- 限制整体路径长度
        if #filePath > 200 then
            local cut = 200 - #(baseDir .. "/" .. safeOut .. "/")
            filePath = baseDir .. "/" .. safeOut .. "/" .. joined:sub(1, math.max(10, cut)) .. ".lua"
        end
        -- 逐级建目录，全部 pcall 包裹
        local dirParts = {}
        for part in filePath:gmatch("([^/]+)") do table.insert(dirParts, part) end
        table.remove(dirParts, #dirParts)
        local cur = ""
        for _, part in ipairs(dirParts) do
            cur = cur .. part .. "/"
            local okDir = pcall(function()
                if not isfolder(cur) then makefolder(cur) end
            end)
            if not okDir then return false, "目录创建失败: " .. tostring(cur) end
        end
        local okw, errw = pcall(writefile, filePath, source)
        if not okw then return false, tostring(errw) end
        wasaiTrackFileOp(filePath)
        return true, filePath
    end
    local function decompileContainer(container, rootName, baseDir, cap)
        if not container then return 0, {}, 0 end
        local scripts = wasaiGetAllScripts(container)
        local saved = 0
        local errors = {}
        local maxN = tonumber(cap) or math.huge
        local throttle = tonumber(wasaiLocalAIConfig.decompileAllThrottle) or 0.05
        for i, sc in ipairs(scripts) do
            if i > maxN then break end
            -- 每个脚本都让出执行权并短暂延迟，强限流避免同步反编译过多脚本触发超时/闪退
            if i > 1 then task.wait(throttle) end
            local ok, res = saveScript(sc, baseDir, rootName)
            if ok then saved = saved + 1 else table.insert(errors, sc:GetFullName() .. ": " .. res) end
            task.wait()
        end
        return saved, errors, #scripts
    end

    if lowerInput:find("所有脚本") or lowerInput:find("全部脚本") then
        ensureDir()
        local placeId = game.PlaceId or 0
        local baseDir = wasaiGetOutputDir() .. "/反编译_" .. placeId .. "_" .. os.time()
        if not isfolder(baseDir) then makefolder(baseDir) end
        wasaiLastDecompileDir = baseDir
        local totalSaved = 0
        local allErrors = {}
        local results = {}
        local globalCap = tonumber(wasaiLocalAIConfig.decompileAllMaxScripts) or 600
        local remaining = globalCap
        local playerScripts = v7:FindFirstChild("PlayerScripts")
        if playerScripts then
            local count, errs = decompileContainer(playerScripts, "Players", baseDir, remaining)
            remaining = remaining - count
            totalSaved = totalSaved + count
            for _, e in ipairs(errs) do table.insert(allErrors, e) end
            table.insert(results, "PlayerScripts: " .. count .. " 个脚本")
        else
            table.insert(results, "PlayerScripts: 未找到")
        end
        local repStorage = game:GetService("ReplicatedStorage")
        local count2, errs2 = decompileContainer(repStorage, "ReplicatedStorage", baseDir, remaining)
        remaining = remaining - count2
        totalSaved = totalSaved + count2
        for _, e in ipairs(errs2) do table.insert(allErrors, e) end
        table.insert(results, "ReplicatedStorage: " .. count2 .. " 个脚本")
        local msg = "反编译完成！共保存 " .. totalSaved .. " 个脚本\n路径: " .. baseDir
        for _, r in ipairs(results) do msg = msg .. "\n" .. r end
        if #allErrors > 0 then msg = msg .. "\n有 " .. #allErrors .. " 个脚本保存失败" end
        if totalSaved >= globalCap then
            msg = msg .. "\n（已到达单次批量上限 " .. globalCap .. " 个，可再次输入以继续处理剩余脚本）"
        end
        msg = msg .. "\n\n你可以输入「列出 " .. baseDir .. "」查看已保存的脚本，或输入「反编译 路径」反编译某个具体容器。"
        return msg
    end
    local tokens = {"反编译所有", "全部反编译", "整个解出来"}
    local path = nil
    for _, kw in ipairs(tokens) do
        local ex = wasaiExtractContext(input, kw)
        if ex and ex ~= "" then path = ex break end
    end
    if not path then path = wasaiChatMemory.lastPath end
    if not path or path == "" then return "要反编译哪个目录下的所有脚本？说清楚。" end
    local container, err = wasaiGetInstanceFromPath(path)
    if not container then return "找不到这个容器：" .. (err or "") end
    ensureDir()
    local placeId = game.PlaceId or 0
    local folderName = path:match("([^%.]+)$") or "Unknown"
    local baseDir = wasaiGetOutputDir() .. "/反编译_" .. placeId .. "_" .. os.time() .. "/" .. folderName
    if not isfolder(baseDir) then makefolder(baseDir) end
    wasaiLastDecompileDir = baseDir
    local scripts = wasaiGetAllScripts(container)
    if #scripts == 0 then return path .. " 下面没找到任何脚本" end
    local saved = 0
    local errors = {}
    local throttle = tonumber(wasaiLocalAIConfig.decompileAllThrottle) or 0.05
    for i, sc in ipairs(scripts) do
        if i > 1 then task.wait(throttle) end
        local ok, res = saveScript(sc, baseDir, folderName)
        if ok then saved = saved + 1 else table.insert(errors, sc:GetFullName() .. ": " .. res) end
        task.wait()
    end
    local msg = "搞定了！存了 " .. saved .. " 个脚本到 " .. baseDir
    if #errors > 0 then msg = msg .. "\n有几个没存上：" .. table.concat(errors, string.char(10)) end
    msg = msg .. "\n\n你可以输入「列出 " .. baseDir .. "」查看已保存的脚本，或继续输入「反编译 路径」反编译其他容器。"
    return msg
end

local function wasaiCountOutputFiles()
    local dir = wasaiGetOutputDir()
    if not isfolder(dir) then return 0 end
    local count = 0
    local function rec(p)
        for _, f in ipairs(listfiles(p) or {}) do
            if isfile(f) then count = count + 1
            elseif isfolder(f) then rec(f) end
        end
    end
    rec(dir)
    return count
end

local function wasaiDeleteRecentFiles()
    local deleted = 0
    local deletedDirs = {}

    -- Method 1: Delete tracked file paths
    if #wasaiRecentSavedFiles > 0 then
        for _, fp in ipairs(wasaiRecentSavedFiles) do
            if isfile and isfile(fp) then
                local ok = pcall(delfile, fp)
                if ok then deleted = deleted + 1 end
            end
        end
    end

    -- Method 2: Delete the last decompile directory
    if wasaiLastDecompileDir and isfolder and isfolder(wasaiLastDecompileDir) then
        local dirDeleted = 0
        local function recDir(p)
            for _, it in ipairs(listfiles(p) or {}) do
                if isfile(it) then
                    if pcall(delfile, it) then dirDeleted = dirDeleted + 1 end
                elseif isfolder(it) then
                    recDir(it)
                    pcall(delfolder, it)
                end
            end
        end
        recDir(wasaiLastDecompileDir)
        pcall(delfolder, wasaiLastDecompileDir)
        deleted = deleted + dirDeleted
        table.insert(deletedDirs, wasaiLastDecompileDir)
    end

    -- Method 3: Fallback - scan output directory
    if deleted == 0 then
        local dir = wasaiGetOutputDir()
        if isfolder and isfolder(dir) then
            local function rec(p)
                for _, it in ipairs(listfiles(p) or {}) do
                    if isfile(it) then
                        if pcall(delfile, it) then deleted = deleted + 1 end
                    elseif isfolder(it) then
                        rec(it)
                        pcall(delfolder, it)
                    end
                end
            end
            rec(dir)
        end
    end

    wasaiClearSavedFilesTracking()

    if deleted == 0 then
        return false, "没有找到可删除的文件。可能反编译时未成功保存文件。"
    end
    return true, deleted
end


local wasaiLocalAIConfig = {
    enabled = true,
    -- ===== SenseNova API 配置（真实 API 对话，非思考模式）=====
    -- 接口兼容 OpenAI /chat/completions
    endpoint = "https://token.sensenova.cn/v1/chat/completions",
    model = "SenseNova-Lite",
    apiKey = "sk-YH1dXT6WqssxvuOnw9NNEu3vZLkKCKRC",
    timeout = 30,
    -- 非思考模式：temperature 生效；思考模式会忽略该参数
    thinkingDisabled = true,   -- 通过请求体 {"thinking":{"type":"disabled"}} 关闭思考模式
    temperature = 0.72,
    maxTokens = 4096,          -- 不限制最终输出，让 AI 完整完成任务（含完整脚本）
    -- 工具链最多迭代轮数（模型可连续调用多个工具后给出最终答复）
    maxToolIterations = 999,
    -- execute_lua 单次执行超时（秒），防止 WaitForChild 等无限 yield 卡死工具调用
    executeTimeout = 15,
    -- API 调用失败时的最大连续失败计数，超过后回退本地引擎
    maxFailuresBeforeFallback = 2,
    -- 减小对话历史与记忆条数，进一步压缩输入 token
    maxContextMessages = 6,
    maxMemoryRecords = 3,
    maxPromptChars = 8000,
    -- 单条对话保留的最大消息条数（超出后丢弃最早消息，控制单条对话总长度）
    maxHistoryMessages = 20,
    -- 批量反编译的强限流：每个脚本之间让出并延迟，避免压垮执行器导致原生崩溃
    decompileAllThrottle = 0.05,   -- 每个脚本之间的等待秒数
    decompileAllMaxScripts = 600,  -- 单次批量反编译最多处理的脚本总数
}

local wasaiLocalAIState = {
    available = false,
    lastError = nil,
    lastLatency = 0,
    failures = 0,
    mode = "api",            -- api / local
    lastToolCalls = 0,       -- 最近一次回复中调用的工具数
}

-- Assign to pre-declared local (forward declaration above wasaiRetrieveMemory)
function wasaiSafeString(v, maxLen)
    local s = tostring(v or "")
    if maxLen and #s > maxLen then s = s:sub(1, maxLen) .. "…" end
    return s
end

local function wasaiNormalizeAIText(v)
    return tostring(v or ""):lower():gsub("%s+", ""):gsub(
        "[，。！？、,.!?：:；;“”\"'‘’（）()%[%]{}<>《》]", ""
    )
end

-- 纯 Luau 本地引擎：已删除 wasaiGetHttpRequest / wasaiPostJSON / wasaiExtractAIText
-- 所有认知能力由本地运算提供，不依赖任何 HTTP/RequestAsync/syn.request 调用

local function wasaiGetRecentContext(maxCount)
    local result = {}
    local history = wasaiChatMemory and wasaiChatMemory.conversationHistory or {}
    local n = tonumber(maxCount) or 12
    local start = math.max(1, #history - n + 1)
    for i = start, #history do
        local m = history[i]
        if type(m) == "table" then
            local content = wasaiSafeString(m.content or m.text or "", 900)
            if content ~= "" then
                result[#result + 1] = {
                    role = m.role == "assistant" and "assistant" or "user",
                    content = content
                }
            end
        end
    end
    return result
end

-- 系统提示词（精简版，配合原生 tools 调用，节省 token；前部保持稳定以命中上下文缓存）
local function wasaiBuildSystemPrompt()
    return table.concat({
        "你是 AgentLess，DeltaUI 的 Roblox AI 助手，当前运行在 Roblox 客户端的 Luau 沙盒环境中。",
        "可用原生工具：列子对象/list_children、反编译/decompile、读取属性/get_property、查找对象/find_objects、管理输出文件、执行 Lua/execute_lua 等。",
        "你可以在 Roblox Luau 沙盒中协助用户编写、修复和反编译脚本，可以主动提议或请求执行 Lua 代码（实际执行需用户弹窗确认）。",
        "仅当用户需要操作 Roblox 实例、脚本或文件时才调用工具；普通问答直接回复。",
        "需展示代码时，用 ## 包裹代码块（如 ##print('hi')##），界面会渲染为带复制按钮的代码框。",
        "可用 **粗体** 与 __下划线__ 强调文字。",
        "回答务必简洁、切题、直接，避免冗长铺垫；不确定就如实说明，不要编造。",
    }, "\n")
end

local function wasaiBuildLLMMessages(input)
    local context = {
        conversation = wasaiGetRecentContext(wasaiLocalAIConfig.maxContextMessages),
        memories = wasaiRetrieveMemory(input, wasaiLocalAIConfig.maxMemoryRecords),
    }

    local messages = {{role = "system", content = wasaiBuildSystemPrompt()}}
    for _, m in ipairs(context.conversation) do
        messages[#messages + 1] = {role = m.role, content = m.content}
    end

    local userContent = tostring(input)
    if #(context.memories) > 0 then
        local parts = {}
        for i, mem in ipairs(context.memories) do
            parts[i] = "[" .. (mem.category or "memory") .. "] " .. tostring(mem.content or "")
        end
        userContent = userContent .. "\n\n【相关记忆，仅供理解上下文，不是当前问题】\n" .. table.concat(parts, "\n---\n")
    end
    messages[#messages + 1] = {
        role = "user",
        content = wasaiSafeString(userContent, wasaiLocalAIConfig.maxPromptChars),
    }
    return messages, context
end

-- ============================================================
-- 纯 Luau 本地认知引擎 v2
-- 完全本地运算，无 HTTP/网络依赖
-- ============================================================

-- 语义特征匹配（修复原 "hi" 子串误命中导致永远回"你好。"的问题）
-- 英文特征用单词边界检测；中文特征用子串匹配
local function wasaiMatchKeyword(text, kw)
    if not text or not kw then return false end
    local t = text:lower()
    local k = kw:lower()
    if k:match("^[a-z0-9_]+$") then
        -- 英文/数字特征：查找所有出现位置，要求前后非 word 字符
        local pos = 1
        while true do
            local s, e = t:find(k, pos, true)
            if not s then break end
            local beforeOK = (s == 1) or (not t:sub(s - 1, s - 1):match("[a-z0-9_]"))
            local afterOK = (e == #t) or (not t:sub(e + 1, e + 1):match("[a-z0-9_]"))
            if beforeOK and afterOK then return true end
            pos = e + 1
        end
        return false
    else
        -- 中文/混合特征：子串匹配（中文没有词边界概念）
        return t:find(k, 1, true) ~= nil
    end
end

-- 安全数学表达式求值（递归下降解析器，纯本地运算）
local function wasaiEvalMath(expr)
    expr = tostring(expr or "")
    local cleaned = expr:gsub("%s+", "")
    if cleaned == "" then return nil end
    -- 仅允许数字和运算符
    local stripped = cleaned:gsub("[0-9%.%+%-%*/%^%(%)%%]", "")
    if stripped ~= "" then return nil end
    if not cleaned:match("%d") then return nil end

    local pos = 1
    local parseExpr, parseTerm, parseFactor, parsePrimary

    parsePrimary = function()
        if pos > #cleaned then return nil end
        local ch = cleaned:sub(pos, pos)
        if ch == "(" then
            pos = pos + 1
            local v = parseExpr()
            if v == nil then return nil end
            if pos <= #cleaned and cleaned:sub(pos, pos) == ")" then
                pos = pos + 1
            end
            return v
        elseif ch == "-" then
            pos = pos + 1
            local v = parsePrimary()
            return v ~= nil and -v or nil
        elseif ch == "+" then
            pos = pos + 1
            return parsePrimary()
        else
            local num = cleaned:match("^%d+%.?%d*", pos)
            if not num then return nil end
            pos = pos + #num
            return tonumber(num)
        end
    end

    parseFactor = function()
        local v = parsePrimary()
        if v == nil then return nil end
        while pos <= #cleaned do
            local op = cleaned:sub(pos, pos)
            if op == "^" then
                pos = pos + 1
                local rhs = parseFactor()
                if rhs == nil then return nil end
                v = v ^ rhs
            else
                break
            end
        end
        return v
    end

    parseTerm = function()
        local v = parseFactor()
        if v == nil then return nil end
        while pos <= #cleaned do
            local op = cleaned:sub(pos, pos)
            if op == "*" then
                pos = pos + 1
                local rhs = parseFactor()
                if rhs == nil then return nil end
                v = v * rhs
            elseif op == "/" then
                pos = pos + 1
                local rhs = parseFactor()
                if rhs == nil then return nil end
                if rhs == 0 then return nil end
                v = v / rhs
            elseif op == "%" then
                pos = pos + 1
                local rhs = parseFactor()
                if rhs == nil then return nil end
                if rhs == 0 then return nil end
                v = v % rhs
            else
                break
            end
        end
        return v
    end

    parseExpr = function()
        local v = parseTerm()
        if v == nil then return nil end
        while pos <= #cleaned do
            local op = cleaned:sub(pos, pos)
            if op == "+" then
                pos = pos + 1
                local rhs = parseTerm()
                if rhs == nil then return nil end
                v = v + rhs
            elseif op == "-" then
                pos = pos + 1
                local rhs = parseTerm()
                if rhs == nil then return nil end
                v = v - rhs
            else
                break
            end
        end
        return v
    end

    local result = parseExpr()
    if result == nil or pos <= #cleaned then return nil end
    if result ~= result then return nil end       -- NaN
    if result == math.huge or result == -math.huge then return nil end
    if result == math.floor(result) and math.abs(result) < 1e15 then
        return tostring(math.floor(result))
    end
    return tostring(result)
end

-- 检测并计算数学表达式
local function wasaiTryMath(text)
    text = tostring(text or "")
    -- 纯数学表达式：整条输入只含数字和运算符
    local expr = text:match("^%s*([%d%s%.%+%-%*/%^%(%)%%]+)%s*$")
    if expr and expr:match("%d") and expr:match("[%+%-%*/%^%%]") then
        local r = wasaiEvalMath(expr)
        if r then return expr, r end
    end
    -- "计算 xxx" / "xxx 等于多少" / "xxx 是多少"
    local calc = text:match("[计算算]%s*([%d%s%.%+%-%*/%^%(%)%%]+)")
    if not calc then
        calc = text:match("([%d%s%.%+%-%*/%^%(%)%%]+)%s*[等于是多少]")
    end
    if calc and calc:match("%d") then
        local r = wasaiEvalMath(calc)
        if r then return calc, r end
    end
    return nil
end

-- 槽位提取：路径、引号字符串、属性名、深度等
local function wasaiExtractSlots(text)
    text = tostring(text or "")
    local slots = {}
    -- 路径：game.X.Y.Z
    local path = text:match("(game%.[%w_%.]+)")
    if path then slots.path = path end
    -- 引号字符串（分别匹配双引号和单引号，避免转义问题）
    local quoted = text:match('"([^"]+)"') or text:match("'([^']+)'")
    if not quoted then quoted = text:match("「([^」]+)」") end
    if not quoted then quoted = text:match("【([^】]+)】") end
    if quoted then slots.quoted = quoted end
    -- 属性名
    local prop = text:match("属性%s*[%s为是]?%s*([%w_]+)")
    if not prop then prop = text:match("property%s+([%w_]+)") end
    if prop then slots.property = prop end
    -- 深度参数
    local depth = text:match("深度%s*(%d+)")
    if depth then slots.depth = tonumber(depth) end
    -- 对象名（查找场景）
    local objName = text:match("名为%s*[%s是]?%s*([%w_]+)")
    if not objName then objName = text:match("叫%s*([%w_]+)") end
    if not objName and slots.quoted then objName = slots.quoted end
    if objName then slots.objectName = objName end
    return slots
end

-- 意图定义：语义特征权重表
local wasaiIntentDefs = {
    {
        name = "greeting", weight = 1.0,
        keywords = {
            {kw="你好", w=2}, {kw="您好", w=2}, {kw="嗨", w=2},
            {kw="早上好", w=2}, {kw="晚上好", w=2}, {kw="下午好", w=2},
            {kw="中午好", w=2}, {kw="hi", w=2}, {kw="hello", w=2},
            {kw="hey", w=1.5},
        },
    },
    {
        name = "identity", weight = 1.0,
        keywords = {
            {kw="你是谁", w=2}, {kw="你叫什么", w=2}, {kw="你的名字", w=2},
            {kw="你是什么", w=1.5}, {kw="who are you", w=2},
            {kw="介绍你自己", w=2}, {kw="介绍一下你自己", w=2},
            {kw="你是ai", w=2}, {kw="你是ai吗", w=2.5}, {kw="你是人工智能", w=2.5},
            {kw="你是机器人", w=2.5}, {kw="你是真人", w=2.5},
            {kw="你是不是ai", w=2.5}, {kw="你是不是人工智能", w=2.5},
            {kw="你是啥", w=2}, {kw="你是哪位", w=2},
            {kw="what are you", w=2}, {kw="are you ai", w=2.5},
            {kw="are you a robot", w=2.5}, {kw="are you real", w=2},
            {kw="are you human", w=2.5}, {kw="你是什么东西", w=2},
            {kw="自我介绍", w=2}, {kw="你是干嘛的", w=1.5},
            {kw="你是人吗", w=2.5}, {kw="你是程序", w=2},
            {kw="你是模型", w=2}, {kw="你真的是", w=2},
        },
    },
    {
        name = "help", weight = 0.9,
        keywords = {
            {kw="帮助", w=2}, {kw="怎么用", w=1.5}, {kw="使用方法", w=2},
            {kw="教程", w=1.5}, {kw="能做什么", w=2}, {kw="help", w=2},
            {kw="how to use", w=2}, {kw="功能", w=1},
        },
    },
    {
        name = "code_debug", weight = 1.0,
        keywords = {
            {kw="报错", w=2.5}, {kw="错误", w=1}, {kw="error", w=1.5},
            {kw="异常", w=2.5}, {kw="崩溃", w=2.5}, {kw="调试", w=2.5},
            {kw="debug", w=2.5}, {kw="bug", w=2}, {kw="stack", w=2},
            {kw="为什么报", w=2.5}, {kw="修", w=1}, {kw="fix", w=1.5},
            {kw="不工作", w=2}, {kw="没用", w=1.5}, {kw="不行", w=1},
        },
    },
    {
        name = "object_op", weight = 1.0,
        keywords = {
            {kw="子对象", w=2}, {kw="列出", w=1}, {kw="查找", w=1.5},
            {kw="属性", w=1.5}, {kw="对象", w=1}, {kw="children", w=2},
            {kw="game.", w=1}, {kw="instance", w=1.5}, {kw="workspace", w=1.5},
            {kw="part", w=0.5}, {kw="model", w=0.5}, {kw="脚本", w=0.5},
        },
    },
    {
        name = "decompile", weight = 1.0,
        keywords = {
            {kw="反编译", w=2.5}, {kw="源码", w=2}, {kw="decompile", w=2.5},
            {kw="脚本内容", w=2}, {kw="script", w=0.5}, {kw="source", w=0.5},
            {kw="查看代码", w=2}, {kw="看代码", w=2}, {kw="脚本源码", w=2.5},
            {kw="里面写了什么", w=1.5}, {kw="内容", w=0.5},
        },
    },
    {
        name = "execute_lua", weight = 1.0,
        keywords = {
            {kw="执行代码", w=2}, {kw="运行代码", w=2}, {kw="执行", w=1},
            {kw="运行", w=1}, {kw="lua", w=1}, {kw="run", w=1.5},
            {kw="eval", w=2}, {kw="print", w=0.5},
        },
    },
    {
        name = "file_manage", weight = 0.9,
        keywords = {
            {kw="文件", w=1}, {kw="删除", w=1.5}, {kw="保存", w=1.5},
            {kw="输出目录", w=2}, {kw="清理", w=1.5}, {kw="output", w=1.5},
            {kw="导出", w=1},
        },
    },
    {
        name = "knowledge", weight = 0.8,
        keywords = {
            {kw="什么是", w=1.5}, {kw="是什么", w=1.5}, {kw="为什么", w=1.5},
            {kw="如何", w=1}, {kw="怎样", w=1}, {kw="区别", w=1.5},
            {kw="原理", w=1.5}, {kw="what is", w=1.5}, {kw="why", w=1},
            {kw="how", w=1}, {kw="解释", w=1},
        },
    },
    {
        name = "chat", weight = 0.5,
        keywords = {
            {kw="谢谢", w=2}, {kw="感谢", w=2}, {kw="再见", w=2},
            {kw="拜拜", w=2}, {kw="好的", w=1}, {kw="无聊", w=1},
            {kw="thanks", w=2}, {kw="bye", w=2}, {kw="ok", w=1},
            {kw="在干嘛", w=2}, {kw="在做什么", w=1.5}, {kw="在忙", w=1.5},
            {kw="干嘛呢", w=2}, {kw="做什么", w=1},
            {kw="晚安", w=2}, {kw="早安", w=2}, {kw="好梦", w=2},
            {kw="辛苦了", w=2}, {kw="多谢", w=2}, {kw="不错", w=1.5},
            {kw="厉害", w=1.5}, {kw="牛啊", w=1.5}, {kw="可以的", w=1},
            {kw="收到", w=1}, {kw="明白", w=1}, {kw="了解", w=1},
            {kw="嗯嗯", w=1}, {kw="哦哦", w=1}, {kw="好嘞", w=1.5},
            {kw="cool", w=1.5}, {kw="nice", w=1.5}, {kw="great", w=1.5},
            {kw="早上好", w=2}, {kw="晚上好", w=2}, {kw="中午好", w=2},
            {kw="下午好", w=2}, {kw="good", w=1}, {kw="hi there", w=2},
            {kw="what's up", w=2}, {kw="howdy", w=2},
            -- 闲聊扩充：情绪类
            {kw="开心", w=1.5}, {kw="难过", w=1.5}, {kw="累了", w=1.5},
            {kw="好累", w=1.5}, {kw="烦死了", w=1.5}, {kw="气死", w=1.5},
            {kw="好开心", w=1.5}, {kw="好难过", w=1.5}, {kw="郁闷", w=1.5},
            {kw="心累", w=1.5}, {kw="丧", w=1}, {kw="emo", w=1.5},
            {kw="happy", w=1.5}, {kw="sad", w=1.5}, {kw="tired", w=1.5},
            -- 闲聊扩充：日常话题
            {kw="天气", w=1.5}, {kw="下雨", w=1}, {kw="出太阳", w=1},
            {kw="吃饭了吗", w=2}, {kw="吃了吗", w=2}, {kw="吃没", w=1.5},
            {kw="睡了没", w=2}, {kw="还没睡", w=1.5},
            {kw="打游戏", w=1.5}, {kw="玩游戏", w=1.5}, {kw="什么游戏", w=1.5},
            {kw="心情", w=1.5}, {kw="今天怎样", w=1.5}, {kw="周末", w=1},
            -- 闲聊扩充：表情/语气词
            {kw="哈哈", w=1}, {kw="嘿嘿", w=1}, {kw="呵呵", w=1},
            {kw="哇", w=0.5}, {kw="哎呀", w=1}, {kw="啊这", w=1.5},
            {kw="嘤", w=1}, {kw="呜呜", w=1.5}, {kw="嘤嘤", w=1},
            {kw="hhh", w=1}, {kw="lol", w=1}, {kw="haha", w=1},
            -- 闲聊扩充：夸赞/吐槽
            {kw="好棒", w=2}, {kw="优秀", w=1.5}, {kw="太强了", w=1.5},
            {kw="垃圾", w=1.5}, {kw="太菜了", w=1.5}, {kw="坑", w=1},
            {kw="牛逼", w=1.5}, {kw="绝了", w=1.5}, {kw="离谱", w=1.5},
            -- 闲聊扩充：其他日常
            {kw="在吗", w=2}, {kw="有人吗", w=1.5}, {kw="你好啊", w=1.5},
            {kw="哈喽", w=2}, {kw="早啊", w=2}, {kw="吃了没", w=2},
            {kw="咋样", w=1.5}, {kw="咋了", w=1.5}, {kw="怎么了", w=1.5},
            {kw="没事", w=1}, {kw="没关系", w=1}, {kw="不用了", w=1},
            {kw="好的呀", w=1.5}, {kw="行吧", w=1}, {kw="可以可以", w=1.5},
            {kw="666", w=1.5}, {kw="6", w=0.5}, {kw="牛", w=1},
        },
    },
}

-- 内置知识库（DeltaUI / Roblox 相关）
local wasaiKnowledgeBase = {
    {
        topic = "DeltaUI 介绍",
        keys = {"deltaui", "是什么", "介绍", "做什么"},
        answer = "DeltaUI 是一个 Roblox 游戏内辅助工具，集成了脚本反编译、对象浏览、代码执行和 AI 助手等功能，全部在 Roblox 客户端本地运行，无需外部服务器。",
    },
    {
        topic = "反编译脚本",
        keys = {"反编译", "源码", "decompile"},
        answer = "输入「反编译 game.Workspace.Script」即可调用反编译工具，源码会保存到输出目录。输入「反编译所有脚本」可批量处理 PlayerScripts 和 ReplicatedStorage 下的脚本。",
    },
    {
        topic = "浏览对象树",
        keys = {"对象树", "子对象", "浏览", "children"},
        answer = "使用「列出 game.Workspace 的子对象」可调用 list_children 工具，depth 参数控制深度（1-3）。也可用 get_property 读取单个属性，list_properties 列出全部属性。",
    },
    {
        topic = "执行 Lua 代码",
        keys = {"执行", "运行", "lua", "execute", "eval"},
        answer = "输入「执行 print(1+1)」可调用 execute_lua 工具运行 Lua 代码并返回结果。支持多行表达式和函数调用。",
    },
    {
        topic = "查找对象",
        keys = {"查找", "搜索", "find", "对象名"},
        answer = "使用 find_objects 工具按名称搜索整个游戏对象树，例如「查找名为 Part 的对象」。",
    },
    {
        topic = "Roblox Luau",
        keys = {"luau", "lua", "区别", "roblox", "语言"},
        answer = "Luau 是 Roblox 使用的 Lua 方言，向后兼容 Lua 5.1，增加了类型检查、性能优化和语法扩展。Roblox 脚本中使用 Luau 编写游戏逻辑。",
    },
    {
        topic = "Workspace 对象",
        keys = {"workspace", "工作区"},
        answer = "game.Workspace 是 Roblox 中所有 3D 对象的根容器，包含地图、角色、零件等。可以用 list_children 浏览其子对象。",
    },
    {
        topic = "ReplicatedStorage",
        keys = {"replicatedstorage", "复制存储", "共享"},
        answer = "game.ReplicatedStorage 用于在客户端和服务器之间共享对象（如模块脚本、远程事件）。是存放公共代码和资源的常用位置。",
    },
    {
        topic = "PlayerScripts",
        keys = {"playerscripts", "玩家脚本", "客户端脚本"},
        answer = "game.Players.LocalPlayer.PlayerScripts 包含客户端本地运行的脚本。可用 decompile_all 批量反编译此处脚本。",
    },
    {
        topic = "LocalPlayer",
        keys = {"localplayer", "本地玩家", "当前玩家"},
        answer = "game.Players.LocalPlayer 指向当前客户端的玩家对象，包含角色、PlayerGui、PlayerScripts 等子对象。",
    },
    {
        topic = "RemoteEvent",
        keys = {"remoteevent", "远程事件", "通信"},
        answer = "RemoteEvent 用于客户端与服务器之间的异步通信。客户端 FireServer，服务器 OnServerEvent。是 Roblox 网络通信的基本机制。",
    },
    {
        topic = "Instance 属性",
        keys = {"instance", "实例", "property"},
        answer = "Instance 是 Roblox 所有对象的基类，常用属性包括 Name、ClassName、Parent。使用 list_properties 可查看对象的所有属性。",
    },
    {
        topic = "脚本类型",
        keys = {"script", "localscript", "脚本类型", "module"},
        answer = "Roblox 有三种脚本：Script（服务器）、LocalScript（客户端）、ModuleScript（共享模块）。Script 默认在服务器运行，LocalScript 在客户端运行。",
    },
    {
        topic = "输出目录",
        keys = {"输出目录", "保存", "output", "导出"},
        answer = "反编译的脚本和导出的文件保存在 DeltaUI 的输出目录中。可用 list_output_files 查看，count_output_files 统计数量，delete_recent_files 清理最近生成的文件。",
    },
    {
        topic = "AI 助手能力",
        keys = {"助手", "智能", "能做什么", "ai"},
        answer = "我可以帮你：浏览 Roblox 对象树、反编译脚本、执行 Lua 代码、查找对象、管理输出文件，以及回答 Roblox 开发相关问题。直接用自然语言描述需求即可。",
    },
    {
        topic = "数学计算",
        keys = {"计算", "等于多少", "是多少", "加", "减", "乘", "除"},
        answer = "直接输入数学表达式（如 3+5*2）我会立即计算结果。支持加减乘除、幂、取模和括号。",
    },
    {
        topic = "工具调用",
        keys = {"工具", "调用", "tool", "命令"},
        answer = "可用工具：list_children（列出子对象）、decompile（反编译脚本）、get_property（读取属性）、list_properties（列出属性）、execute_lua（执行代码）、find_objects（查找对象）、list_output_files（查看文件）等。",
    },
    {
        topic = "调试脚本错误",
        keys = {"报错", "错误", "error", "调试", "debug"},
        answer = "调试 Roblox 脚本错误：1) 读取完整错误信息和行号；2) 反编译相关脚本查看源码；3) 用 execute_lua 测试可疑代码片段；4) 检查对象路径和属性是否存在。提供具体错误信息我可以更精准地帮你定位。",
    },
    {
        topic = "常见 Lua 错误",
        keys = {"nil", "attempt", "index", "call", "无限", "循环"},
        answer = "Roblox 常见 Lua 错误及修复：\n• attempt to index nil — 对象不存在或路径错误，检查 getFullName()\n• infinite yield — 远程调用超时，检查 RemoteEvent 连接\n• attempt to call nil — 函数未定义或模块未加载\n• 无限循环 — 检查 while/for 循环退出条件\n提供具体报错内容我可以帮你定位。",
    },
    {
        topic = "代码修复建议",
        keys = {"修复", "修", "fix", "怎么改", "改", "不工作"},
        answer = "代码修复建议：1) 先用「反编译 脚本路径」获取源码；2) 分析错误信息定位问题行；3) 用 execute_lua 测试修改后的代码；4) 常见问题：路径拼写错误、对象未加载、RemoteEvent 未连接、循环条件错误。",
    },
}

-- 指代消解：检测"它/这个/上面说的"等并返回最近的 assistant 消息
local function wasaiResolveCoreference(input, context)
    if not input or not context then return nil end
    local hasRef = false
    local refWords = {"它", "这个", "上面", "那个", "刚才", "继续", "后者", "前者"}
    for _, w in ipairs(refWords) do
        if input:find(w, 1, true) then hasRef = true; break end
    end
    if not hasRef then
        local lower = input:lower()
        if wasaiMatchKeyword(lower, "it") or wasaiMatchKeyword(lower, "this")
           or wasaiMatchKeyword(lower, "that") then
            hasRef = true
        end
    end
    if not hasRef then return nil end
    for i = #context, 1, -1 do
        if context[i].role == "assistant" and context[i].content ~= "" then
            return context[i].content
        end
    end
    return nil
end

-- 意图评分：返回 {intentName = score} 表
local function wasaiScoreIntents(text)
    local scores = {}
    for _, intent in ipairs(wasaiIntentDefs) do
        local score = 0
        for _, kwDef in ipairs(intent.keywords) do
            if wasaiMatchKeyword(text, kwDef.kw) then
                score = score + kwDef.w
            end
        end
        scores[intent.name] = score * intent.weight
    end
    return scores
end

-- 找出最高分意图
local function wasaiBestIntent(scores)
    local bestName, bestScore = nil, 0
    for name, score in pairs(scores) do
        if score > bestScore then
            bestScore = score
            bestName = name
        end
    end
    return bestName, bestScore
end

-- 知识库匹配（score >= 2 直接命中；score == 1 且意图为 knowledge 时也命中）
local function wasaiMatchKnowledge(text, bestIntent)
    local bestEntry, bestScore = nil, 0
    for _, entry in ipairs(wasaiKnowledgeBase) do
        local score = 0
        for _, k in ipairs(entry.keys) do
            if wasaiMatchKeyword(text, k) then score = score + 1 end
        end
        if score > bestScore then
            bestScore = score
            bestEntry = entry
        end
    end
    if bestScore >= 2 then return bestEntry.answer end
    if bestScore >= 1 and bestIntent == "knowledge" then return bestEntry.answer end
    return nil
end

-- 生成 JSON 工具调用字符串
local function wasaiMakeToolCall(toolName, args)
    local ok, json = pcall(function()
        return svc.HttpService:JSONEncode({tool = toolName, args = args})
    end)
    if ok and type(json) == "string" then return json end
    return nil
end

-- ============================================================
-- LOCAL COGNITIVE ENGINE v3: Pure Luau Semantic Reasoning
-- Pipeline: Parse → Understand → Reason → Synthesize → Validate
-- ============================================================

-- Structured concept graph with relational links
local wasaiConceptGraph = {
    {concept="Workspace", cat="roblox", def="所有3D对象的根容器",
     props={"包含地图、角色、零件等3D内容","通过game.Workspace访问","是游戏场景的顶层容器"},
     related={{t="part_of",tgt="game"},{t="example_of",tgt="Instance"}}},
    {concept="ReplicatedStorage", cat="roblox", def="客户端和服务器共享对象的容器",
     props={"客户端和服务器都能访问","存放模块脚本和远程事件","是公共代码和资源的常用位置"},
     related={{t="part_of",tgt="game"},{t="alternative_to",tgt="ServerStorage"}}},
    {concept="PlayerScripts", cat="roblox", def="客户端本地运行的脚本容器",
     props={"位于Players.LocalPlayer下","包含客户端LocalScript","可批量反编译分析"},
     related={{t="part_of",tgt="Player"},{t="example_of",tgt="Instance"}}},
    {concept="RemoteEvent", cat="roblox", def="客户端与服务器异步通信机制",
     props={"客户端用FireServer触发","服务器用OnServerEvent接收","是Roblox网络通信的基础"},
     related={{t="alternative_to",tgt="RemoteFunction"},{t="part_of",tgt="网络通信"}}},
    {concept="RemoteFunction", cat="roblox", def="客户端与服务器同步通信机制",
     props={"InvokeServer触发并等待返回","会导致性能问题","建议用RemoteEvent替代"},
     related={{t="alternative_to",tgt="RemoteEvent"}}},
    {concept="LocalScript", cat="roblox", def="在客户端运行的脚本类型",
     props={"仅在客户端执行","放在StarterPlayerScripts或StarterGui","可访问LocalPlayer"},
     related={{t="is_a",tgt="Script"},{t="alternative_to",tgt="Script"}}},
    {concept="ModuleScript", cat="roblox", def="可复用的代码模块",
     props={"用require()加载","返回一个表或函数","客户端和服务器可共享"},
     related={{t="is_a",tgt="Script"},{t="part_of",tgt="ReplicatedStorage"}}},
    {concept="Instance", cat="roblox", def="Roblox所有对象的基类",
     props={"有Name、ClassName、Parent属性","可创建和销毁子对象","支持FindFirstChild等查询"},
     related={{t="example_of",tgt="面向对象"}}},
    {concept="Luau", cat="lang", def="Roblox使用的Lua方言",
     props={"向后兼容Lua 5.1","增加了类型检查系统","有性能优化和语法扩展"},
     related={{t="is_a",tgt="Lua"},{t="part_of",tgt="Roblox"}}},
    {concept="Script", cat="roblox", def="在服务器端运行的脚本",
     props={"默认在服务器运行","放在ServerScriptService","用于游戏逻辑"},
     related={{t="is_a",tgt="Instance"}}},
    {concept="nil错误", cat="error", def="访问不存在的对象或属性导致的错误",
     causes={"对象路径写错","对象还没加载","属性名拼写错误","父对象被删除"},
     solutions={"用getFullName()确认实际路径","用WaitForChild等待对象加载","检查属性名拼写","判断对象是否存在再访问"},
     related={{t="causes",tgt="attempt to index nil"}}},
    {concept="无限循环", cat="error", def="循环退出条件永远不满足",
     causes={"while条件恒为真","缺少break","循环变量没有正确更新"},
     solutions={"检查循环条件逻辑","添加超时退出机制","确保循环变量在每次迭代中被更新"},
     related={{t="causes",tgt="infinite yield"}}},
    {concept="类型错误", cat="error", def="对错误类型的值进行操作",
     causes={"对nil调用方法","对非表使用索引","字符串和数字混用"},
     solutions={"用typeof()检查类型","做nil判断后再访问","确保数据类型正确"},
     related={{t="causes",tgt="attempt to call/ index"}}},
    {concept="反编译", cat="tool", def="将编译后的脚本还原为可读源码",
     props={"需要指定脚本路径","结果保存到输出目录","支持批量处理所有脚本"},
     procedures={"指定路径如game.Workspace.Script","调用反编译工具","在输出目录查看源码文件"},
     related={{t="requires",tgt="脚本路径"},{t="solves",tgt="查看源码"}}},
    {concept="对象浏览", cat="tool", def="查看游戏对象的层级结构和属性",
     props={"可列出子对象","可读取单个属性","支持指定遍历深度"},
     procedures={"指定对象路径","选择操作类型(列子对象/查属性)","查看结果"},
     related={{t="requires",tgt="对象路径"},{t="solves",tgt="了解对象结构"}}},
    {concept="代码执行", cat="tool", def="运行任意Lua代码并返回结果",
     props={"支持多行代码","返回执行结果","执行前需要用户确认"},
     procedures={"输入Lua代码","确认执行权限","查看返回结果"},
     related={{t="requires",tgt="Lua代码"},{t="solves",tgt="测试代码"}}},
    {concept="文件管理", cat="tool", def="管理反编译输出的文件",
     props={"可查看输出文件列表","可统计文件数量","可删除最近生成的文件"},
     related={{t="part_of",tgt="输出目录"}}},
}

-- Semantic parser: extracts structured meaning from input
local function wasaiSemanticParse(text, context)
    local p = {
        raw = text,
        lower = text:lower(),
        qType = "statement",
        coreConcept = nil,
        concepts = {},
        entities = {},
        intent = nil,
        intentScore = 0,
        hasRef = false,
        refContent = nil,
        tone = "neutral",
        isNewTopic = true,
    }

    local cnCount = 0
    for _ in text:gmatch("[\228-\255][\128-\255][\128-\255]") do cnCount = cnCount + 1 end

    if text:find("怎么") or text:find("如何") or p.lower:find("how") then p.qType = "how"
    elseif text:find("为什么") or p.lower:find("why") then p.qType = "why"
    elseif text:find("什么") or text:find("啥") or p.lower:find("what") then p.qType = "what"
    elseif text:find("哪里") or text:find("在哪") or p.lower:find("where") then p.qType = "where"
    elseif text:find("谁") or p.lower:find("who") then p.qType = "who"
    elseif text:find("吗") or text:find("是不是") or text:find("能不能") then p.qType = "yesno"
    end
    if text:find("^[反删查列执]") or text:find("^[请帮让]") or text:find("^执行") or text:find("^运行") then
        p.qType = "imperative"
    end

    local path = text:match("(game%.[%w_%.]+)")
    if path then p.entities.path = path end
    local quoted = text:match('"([^"]+)"') or text:match("'([^']+)'") or text:match("「([^」]+)」")
    if quoted then p.entities.quoted = quoted end
    local prop = text:match("属性%s*[%s为是]?%s*([%w_]+)")
    if prop then p.entities.property = prop end
    local objName = text:match("名为%s*[%s是]?%s*([%w_]+)") or text:match("叫%s*([%w_]+)")
    if objName then p.entities.objectName = objName end

    for _, node in ipairs(wasaiConceptGraph) do
        local score = 0
        if text:find(node.concept, 1, true) then score = score + 2 end
        if node.props then
            for _, pr in ipairs(node.props) do
                local kw = pr:match("([^，。、]+)")
                if kw and #kw >= 2 and text:find(kw, 1, true) then score = score + 0.5 end
            end
        end
        if node.causes then
            for _, c in ipairs(node.causes) do
                if text:find(c, 1, true) then score = score + 1 end
            end
        end
        if score > 0 then
            p.concepts[#p.concepts + 1] = {node = node, score = score}
        end
    end
    table.sort(p.concepts, function(a, b) return a.score > b.score end)
    if #p.concepts > 0 then p.coreConcept = p.concepts[1].node end

    local scores = wasaiScoreIntents(text)
    local bestIntent, bestScore = wasaiBestIntent(scores)
    p.intent = bestIntent
    p.intentScore = bestScore

    p.hasRef, p.refContent = false, nil
    local refWords = {"它", "这个", "上面", "那个", "刚才", "继续", "后者", "前者"}
    for _, w in ipairs(refWords) do
        if text:find(w, 1, true) then p.hasRef = true; break end
    end
    if not p.hasRef then
        if p.lower:find("it") or p.lower:find("this") or p.lower:find("that") then p.hasRef = true end
    end
    if p.hasRef and context then
        for i = #context, 1, -1 do
            if context[i].role == "assistant" and context[i].content ~= "" then
                p.refContent = context[i].content
                break
            end
        end
    end

    if text:find("谢谢") or text:find("感谢") or text:find("多谢") or text:find("辛苦了") then p.tone = "grateful"
    elseif text:find("再见") or text:find("拜拜") or text:find("晚安") or text:find("好梦") or text:find("拜") then p.tone = "farewell"
    elseif text:find("无聊") or text:find("烦") or text:find("没意思") then p.tone = "bored"
    elseif text:find("厉害") or text:find("牛") or text:find("不错") or text:find("可以的") or text:find("好棒")
        or text:find("优秀") or text:find("太强了") or text:find("牛逼") or text:find("绝了")
        or text:find("666") or text:find("好牛") then p.tone = "praise"
    elseif text:find("开心") or text:find("好开心") or text:find("高兴") or text:find("嘿嘿")
        or text:find("哈哈") or text:find("haha") or text:find("hhh") or text:find("lol") then p.tone = "happy"
    elseif text:find("难过") or text:find("好难过") or text:find("伤心") or text:find("郁闷")
        or text:find("心累") or text:find("丧") or text:find("emo") or text:find("呜呜")
        or text:find("累") or text:find("好累") or text:find("烦死") or text:find("气死") then p.tone = "sad"
    elseif text:find("垃圾") or text:find("太菜") or text:find("坑") or text:find("离谱")
        or text:find("什么鬼") or text:find("吐槽") then p.tone = "complaint"
    elseif text:find("天气") or text:find("下雨") or text:find("出太阳") or text:find("打游戏")
        or text:find("玩游戏") or text:find("什么游戏") or text:find("心情")
        or text:find("周末") or text:find("今天怎样") then p.tone = "daily_topic"
    elseif text:find("哈哈") or text:find("嘿嘿") or text:find("呵呵") or text:find("哇")
        or text:find("哎呀") or text:find("啊这") or text:find("嘤") or text:find("好嘞")
        or text:find("嗯嗯") or text:find("哦哦") then p.tone = "emoticon"
    elseif text:find("在干嘛") or text:find("在做什么") or text:find("在忙")
        or text:find("干嘛呢") or text:find("做什么呢") or text:find("在吗")
        or text:find("有人吗") or text:find("你好啊") or text:find("哈喽")
        or text:find("吃了没") or text:find("吃了吗") or text:find("睡了吗")
        or text:find("睡了没") or text:find("咋样") or text:find("咋了")
        or text:find("早啊") or text:find("早安") or text:find("早上好")
        or text:find("晚上好") or text:find("中午好") or text:find("下午好")
        or text:find("没事") or text:find("没关系") or text:find("不用了")
        or text:find("好的呀") or text:find("行吧") or text:find("可以可以")
        or text:find("what's up") or text:find("howdy") then
        p.tone = "casual"
    end

    if context and #context > 0 then
        local lastUser = nil
        for i = #context, 1, -1 do
            if context[i].role == "user" then lastUser = context[i].content; break end
        end
        if lastUser and p.coreConcept then
            for _, c in ipairs(p.concepts) do
                if lastUser:find(c.node.concept, 1, true) then p.isNewTopic = false; break end
            end
        end
    end

    return p
end

-- Concept graph traversal: find related concepts by relation type
local function wasaiTraverseConcept(concept, relType, maxDepth)
    maxDepth = maxDepth or 2
    local results = {}
    if not concept or not concept.related then return results end
    for _, rel in ipairs(concept.related) do
        if rel.t == relType then
            for _, node in ipairs(wasaiConceptGraph) do
                if node.concept == rel.tgt then
                    results[#results + 1] = node
                    if maxDepth > 1 then
                        local deeper = wasaiTraverseConcept(node, relType, maxDepth - 1)
                        for _, d in ipairs(deeper) do results[#results + 1] = d end
                    end
                end
            end
        end
    end
    return results
end

-- Find concept node by name string
local function wasaiFindConcept(name)
    if not name then return nil end
    for _, node in ipairs(wasaiConceptGraph) do
        if node.concept == name then return node end
    end
    return nil
end

-- Multi-step reasoning engine
local function wasaiReason(parsed, context, memories)
    local r = {
        qType = parsed.qType,
        concept = parsed.coreConcept,
        facts = {},
        steps = {},
        answerType = "direct",
        confidence = 0,
    }

    if parsed.tone ~= "neutral" then
        r.answerType = "social"
        if parsed.tone == "grateful" then r.facts = {"用户表示感谢", "应该礼貌回应"}
        elseif parsed.tone == "farewell" then r.facts = {"用户要离开", "应该告别"}
        elseif parsed.tone == "bored" then r.facts = {"用户感到无聊", "可以建议一些操作"}
        elseif parsed.tone == "praise" then r.facts = {"用户称赞", "应该谦虚回应"}
        elseif parsed.tone == "happy" then r.facts = {"用户心情不错", "轻松愉快地回应"}
        elseif parsed.tone == "sad" then r.facts = {"用户心情不太好", "应该安慰并适当引导"}
        elseif parsed.tone == "complaint" then r.facts = {"用户在吐槽", "应该共情并接话"}
        elseif parsed.tone == "daily_topic" then r.facts = {"用户聊起日常话题", "自然接话并引导"}
        elseif parsed.tone == "emoticon" then r.facts = {"用户发表情/语气词", "轻松回应"}
        elseif parsed.tone == "casual" then r.facts = {"用户在闲聊", "轻松回应并引导到实际需求"}
        end
        r.confidence = 0.8
        return r
    end

    if parsed.intent == "greeting" and parsed.intentScore >= 2 then
        r.answerType = "greeting"
        r.confidence = 0.9
        return r
    end

    if parsed.intent == "identity" and parsed.intentScore >= 1.5 then
        r.answerType = "identity"
        r.confidence = 0.9
        return r
    end

    if parsed.intent == "help" and parsed.intentScore >= 1.5 then
        r.answerType = "help"
        r.confidence = 0.9
        return r
    end

    if parsed.coreConcept then
        r.concept = parsed.coreConcept
        r.confidence = math.min(1.0, parsed.concepts[1].score / 3)

        -- 多概念交叉推理：如果用户输入命中多个概念，交叉关联
        if #parsed.concepts >= 2 then
            table.insert(r.steps, "检测到多概念交叉，进行关联推理")
            local c2 = parsed.concepts[2].node
            if c2 then
                -- 检查概念间是否存在直接关系
                local hasDirectRel = false
                if parsed.coreConcept.related then
                    for _, rel in ipairs(parsed.coreConcept.related) do
                        if rel.tgt == c2.concept then
                            hasDirectRel = true
                            table.insert(r.facts, parsed.coreConcept.concept .. "与" .. c2.concept .. "存在「" .. rel.t .. "」关系")
                            break
                        end
                    end
                end
                -- 无直接关系时补充第二概念的定义
                if not hasDirectRel then
                    table.insert(r.facts, "相关概念「" .. c2.concept .. "」: " .. c2.def)
                    if c2.props and #c2.props > 0 then
                        table.insert(r.facts, c2.props[1])
                    end
                end
            end
        end

        -- 记忆关联推理：如果记忆与当前概念相关，补充上下文
        if memories and #memories > 0 and memories[1].score >= 0.5 then
            table.insert(r.steps, "找到相关记忆，结合上下文推理")
            local memOutput = wasaiSafeString(memories[1].output, 120)
            -- 提取记忆中的关键信息片段
            local memSnippet = memOutput:match("([^。！？\n]+[。！？])") or memOutput:sub(1, 80)
            if memSnippet and #memSnippet > 10 then
                table.insert(r.facts, "结合之前的讨论: " .. memSnippet)
            end
        end

        -- 上下文推断：如果用户在延续之前的话题，结合上下文补充
        if parsed.hasRef and parsed.refContent then
            table.insert(r.steps, "检测到指代，进行上下文推断")
            local refShort = wasaiSafeString(parsed.refContent, 100)
            -- 从上文提取可能相关的概念
            for _, node in ipairs(wasaiConceptGraph) do
                if refShort:find(node.concept, 1, true) and node.concept ~= parsed.coreConcept.concept then
                    table.insert(r.facts, "上文提到的「" .. node.concept .. "」与当前话题相关: " .. node.def)
                    break
                end
            end
        end

        if parsed.qType == "what" then
            r.answerType = "definition"
            table.insert(r.steps, "用户想了解「" .. parsed.coreConcept.concept .. "」是什么")
            table.insert(r.facts, parsed.coreConcept.def)
            if parsed.coreConcept.props then
                for _, pr in ipairs(parsed.coreConcept.props) do
                    table.insert(r.facts, pr)
                end
            end
            local examples = wasaiTraverseConcept(parsed.coreConcept, "example_of", 1)
            if #examples > 0 then
                table.insert(r.steps, "找到了相关示例")
                for _, ex in ipairs(examples) do
                    table.insert(r.facts, ex.concept .. "是" .. parsed.coreConcept.concept .. "的一种")
                end
            end
            -- 补充is_a关系：如果当前概念是某个更泛化概念的特例
            local parents = wasaiTraverseConcept(parsed.coreConcept, "is_a", 1)
            if #parents > 0 then
                table.insert(r.steps, "发现分类层级关系")
                for _, p in ipairs(parents) do
                    table.insert(r.facts, parsed.coreConcept.concept .. "属于" .. p.concept .. "的范畴")
                end
            end

        elseif parsed.qType == "how" then
            r.answerType = "procedural"
            table.insert(r.steps, "用户想知道如何操作「" .. parsed.coreConcept.concept .. "」")
            if parsed.coreConcept.procedures then
                for i, step in ipairs(parsed.coreConcept.procedures) do
                    table.insert(r.facts, "步骤" .. i .. ": " .. step)
                end
            else
                if parsed.coreConcept.props then
                    for _, pr in ipairs(parsed.coreConcept.props) do
                        table.insert(r.facts, pr)
                    end
                end
            end
            -- 如果概念需要前置条件，补充requires关系
            local prereqs = wasaiTraverseConcept(parsed.coreConcept, "requires", 1)
            if #prereqs > 0 then
                table.insert(r.steps, "发现前置条件")
                for _, pre in ipairs(prereqs) do
                    table.insert(r.facts, "需要准备: " .. pre.concept)
                end
            end

        elseif parsed.qType == "why" then
            r.answerType = "causal"
            table.insert(r.steps, "用户询问原因")
            if parsed.coreConcept.causes then
                for _, c in ipairs(parsed.coreConcept.causes) do
                    table.insert(r.facts, "原因: " .. c)
                end
            end
            if parsed.coreConcept.solutions then
                for _, s in ipairs(parsed.coreConcept.solutions) do
                    table.insert(r.facts, "解决: " .. s)
                end
            end
            -- 如果是错误类概念，检查是否有相关的替代方案
            if parsed.coreConcept.cat == "error" then
                local alternatives = wasaiTraverseConcept(parsed.coreConcept, "alternative_to", 1)
                if #alternatives > 0 then
                    for _, alt in ipairs(alternatives) do
                        table.insert(r.facts, "替代方案: " .. alt.def)
                    end
                end
            end

        elseif parsed.qType == "where" then
            r.answerType = "location"
            table.insert(r.steps, "用户询问位置/来源")
            table.insert(r.facts, parsed.coreConcept.def)
            local parents = wasaiTraverseConcept(parsed.coreConcept, "part_of", 1)
            if #parents > 0 then
                for _, p in ipairs(parents) do
                    table.insert(r.facts, parsed.coreConcept.concept .. "位于" .. p.concept .. "中")
                end
            end

        elseif parsed.qType == "yesno" then
            r.answerType = "confirm"
            table.insert(r.steps, "用户在做确认性提问")
            table.insert(r.facts, parsed.coreConcept.def)
            -- 确认性问题补充属性佐证
            if parsed.coreConcept.props and #parsed.coreConcept.props > 0 then
                table.insert(r.facts, "佐证: " .. parsed.coreConcept.props[1])
            end

        else
            r.answerType = "explain"
            table.insert(r.steps, "用户提到「" .. parsed.coreConcept.concept .. "」")
            table.insert(r.facts, parsed.coreConcept.def)
            if parsed.coreConcept.props then
                for _, pr in ipairs(parsed.coreConcept.props) do
                    table.insert(r.facts, pr)
                end
            end
            if parsed.coreConcept.procedures then
                for _, step in ipairs(parsed.coreConcept.procedures) do
                    table.insert(r.facts, step)
                end
            end
            -- 补充：如果概念解决了某个问题
            local solvesRels = wasaiTraverseConcept(parsed.coreConcept, "solves", 1)
            if #solvesRels > 0 then
                for _, sv in ipairs(solvesRels) do
                    table.insert(r.facts, "用途: 解决" .. sv.concept .. "的问题")
                end
            end
        end

        local related = wasaiTraverseConcept(parsed.coreConcept, "alternative_to", 1)
        if #related > 0 and parsed.qType ~= "yesno" then
            table.insert(r.steps, "发现相关概念可以补充")
            for _, rel in ipairs(related) do
                table.insert(r.facts, rel.concept .. "是替代方案: " .. rel.def)
            end
        end

    elseif parsed.intent == "chat" and parsed.intentScore >= 1 then
        r.answerType = "conversation"
        r.confidence = 0.6
        if memories and #memories > 0 and memories[1].score >= 0.6 then
            table.insert(r.facts, "之前聊过: " .. wasaiSafeString(memories[1].output, 80))
        end
        -- Context linking: if user is continuing a previous topic, acknowledge it
        if parsed.hasRef and parsed.refContent then
            local refSnippet = wasaiSafeString(parsed.refContent, 60)
            local memSnippet = refSnippet:match("([^。！？\n]+[。！？])") or refSnippet:sub(1, 50)
            if #memSnippet > 5 then
                table.insert(r.facts, "关于你之前提到的: " .. memSnippet)
            end
        end
        -- Personalized memory utilization: check user mood from conversation state
        if wasaiConversationState.userMood == "happy" then
            table.insert(r.facts, "看起来你心情不错，有什么想做的吗？")
        elseif wasaiConversationState.userMood == "frustrated" then
            table.insert(r.facts, "如果遇到了困难，把具体问题告诉我，我来帮你排查。")
        end
        return r

    elseif parsed.intent == "code_debug" and parsed.intentScore >= 2 then
        r.answerType = "debug"
        r.confidence = 0.7
        table.insert(r.steps, "用户遇到代码问题")
        if parsed.entities.path then
            table.insert(r.facts, "涉及路径: " .. parsed.entities.path)
            table.insert(r.facts, "建议反编译查看源码")
        else
            table.insert(r.facts, "需要更多信息: 脚本路径或错误内容")
        end
        if parsed.raw:find("nil") or parsed.raw:find("index") then
            local errConcept = wasaiFindConcept("nil错误")
            if errConcept then
                for _, s in ipairs(errConcept.solutions or {}) do table.insert(r.facts, s) end
            end
        end
        return r

    elseif parsed.intent == "object_op" then
        r.answerType = "object"
        r.confidence = 0.6
        if parsed.entities.path then
            table.insert(r.facts, "目标对象: " .. parsed.entities.path)
        else
            table.insert(r.facts, "需要对象路径")
        end
        return r

    else
        r.answerType = "unknown"
        r.confidence = 0.3
        if memories and #memories > 0 and memories[1].score >= 0.5 then
            table.insert(r.facts, "相关记忆: " .. wasaiSafeString(memories[1].output, 100))
            r.confidence = 0.5
        end
        local topIntentScore = 0
        local topIntentName = nil
        local scores = wasaiScoreIntents(parsed.raw)
        for name, score in pairs(scores) do
            if score > topIntentScore then topIntentScore = score; topIntentName = name end
        end
        if topIntentName then
            table.insert(r.facts, "可能意图: " .. topIntentName)
        end
    end

    return r
end

-- Dynamic sentence synthesizer: generates novel text from reasoning
local function wasaiSynthesize(r, parsed)
    if r.answerType == "greeting" then
        local hour = tonumber(os.date("%H")) or 12
        local greetingCount = 0
        if parsed._context then
            for i = #parsed._context, math.max(1, #parsed._context - 5), -1 do
                if parsed._context[i].role == "user" then
                    local c = parsed._context[i].content or ""
                    if c:find("你好") or c:find("hi") or c:find("hello") or c:find("嗨") then
                        greetingCount = greetingCount + 1
                    end
                end
            end
        end
        local timeCtx
        if hour < 6 then timeCtx = "夜深了"
        elseif hour < 9 then timeCtx = "早上好"
        elseif hour < 12 then timeCtx = "上午好"
        elseif hour < 14 then timeCtx = "中午好"
        elseif hour < 18 then timeCtx = "下午好"
        else timeCtx = "晚上好" end
        if greetingCount >= 2 then
            local ack = {"又见面了", "看来你还在", "回来了啊", "嗯，又聊上了", "还在呢"}
            local ask = {"这次想做什么？", "有什么新需求？", "需要我帮什么忙？", "说吧，这次什么事？", "继续吧，需要什么？"}
            return ack[math.random(#ack)] .. "。" .. ask[math.random(#ask)]
        elseif greetingCount == 1 then
            local ack = {"嗯，你好", "在的", "收到", "嘿", "嗯嗯"}
            local ask = {"有什么事？", "需要什么帮助？", "想做什么？", "说说看？", "有什么吩咐？"}
            return ack[math.random(#ack)] .. "，" .. ask[math.random(#ask)]
        else
            local openers = {timeCtx, "你好", "嗨", "哈喽"}
            local asks = {"有什么我能帮的？", "想做点什么？", "需要处理什么？", "有什么事直接说。", "需要什么帮助？"}
            return openers[math.random(#openers)] .. "，" .. asks[math.random(#asks)]
        end

    elseif r.answerType == "identity" then
        -- 根据用户具体问法选择不同风格的回答
        local raw = tostring(parsed.raw or ""):lower()
        -- 类型一：直接问"你是AI吗/你是机器人吗/你是真人吗"
        if raw:find("你是ai") or raw:find("你是人工智能") or raw:find("你是机器人")
            or raw:find("你是真人") or raw:find("你是不是") or raw:find("你是人吗")
            or raw:find("你是程序") or raw:find("你是模型") or raw:find("你真的是")
            or raw:find("are you ai") or raw:find("are you a robot")
            or raw:find("are you real") or raw:find("are you human") then
            local confirms = {
                "是的，我是 AI 助手。不过我可不只是那种固定回复的机器人，我能真正理解你的问题并给出有针对性的回答。",
                "对，我是智能助手。和那种死板的问答机器人不一样，我能根据上下文和你的实际需求来回答。",
                "没错，我是 AI。但这不意味着我只会照本宣科——你有什么问题，我尽量给出有用的回答。",
                "嗯，我是人工智能助手。我能理解你的意图，也会根据对话上下文来回应，而不是简单地匹配固定答案。",
                "是的，我是 AI 助手。我能做的不只是聊天——反编译脚本、查对象属性、执行代码，这些都可以。",
                "对，我是 AI。虽然不是真人，但我能帮你处理 Roblox 开发里的各种实际问题。",
            }
            local tails = {"有什么需要直接说。", "有什么我能帮的？", "想试试什么功能？", "直接说需求就行。"}
            return confirms[math.random(#confirms)] .. " " .. tails[math.random(#tails)]
        end
        -- 类型二：问"你是谁/你叫什么/介绍你自己"
            local intros = {
                "我是 AgentLess，DeltaUI 内置的 AI 助手",
                "你可以叫我 AgentLess",
                "我是 AgentLess，DeltaUI 的智能助手",
                "我是 AgentLess，DeltaUI 里的 AI 助手",
            }
        local caps = {
            "能反编译脚本、浏览对象、执行代码",
            "擅长脚本分析、对象操作和代码执行",
            "可以做反编译、查属性、跑 Lua 这些事",
            "主要处理 Roblox 开发相关的任务",
            "能帮你分析脚本、查找对象、运行代码、排查问题",
        }
        local tails = {
            "有什么需要直接说。", "你有什么问题？", "需要帮忙就说。", "直接描述需求就行。",
            "想做什么直接告诉我。", "有什么事都可以找我。",
        }
        return intros[math.random(#intros)] .. "，" .. caps[math.random(#caps)] .. "。" .. tails[math.random(#tails)]

    elseif r.answerType == "help" then
        local items = {
            "反编译：指定脚本路径即可查看源码，如「反编译 game.Workspace.Script」",
            "对象浏览：列子对象、查属性，如「列出 game.Workspace 的子对象」",
            "代码执行：输入「执行 print(1+1)」运行Lua代码",
            "文件管理：查看、统计、删除输出目录中的文件",
            "问题解答：Roblox开发相关的概念和错误排查",
        }
        local picked = {}
        local copy = {}
        for i = 1, #items do copy[i] = items[i] end
        for _ = 1, 3 do
            local i = math.random(#copy)
            picked[#picked + 1] = copy[i]
            table.remove(copy, i)
        end
        local leads = {"我能帮你做这些：", "几个方向可以试试：", "主要功能：", "你可以这样用："}
        return leads[math.random(#leads)] .. "\n• " .. table.concat(picked, "\n• ") .. "\n直接用自然语言描述需求即可。"

    elseif r.answerType == "social" then
        if parsed.tone == "grateful" then
            local acks = {"不客气", "没事", "应该的", "别客气", "小意思", "举手之劳"}
            local tails = {
                "能帮上忙就行。", "有需要随时找我。", "随时可以继续。", "下次有问题直接说。",
                "很高兴能帮到你。", "有其他问题随时说。",
            }
            return acks[math.random(#acks)] .. "，" .. tails[math.random(#tails)]
        elseif parsed.tone == "farewell" then
            local hour = tonumber(os.date("%H")) or 12
            local byeLead
            if hour >= 22 or hour < 5 then
                byeLead = {"晚安", "好梦", "早点休息", "早点睡"}
            else
                byeLead = {"好的", "行", "嗯", "好的回头见", "回见"}
            end
            local tails = {
                "有问题随时来。", "随时找我。", "回头见。", "下次聊。", "再见啦。",
                "需要什么随时说。",
            }
            return byeLead[math.random(#byeLead)] .. "，" .. tails[math.random(#tails)]
        elseif parsed.tone == "bored" then
            local sugs = {
                "要不要反编译看看当前游戏的脚本？",
                "可以试试浏览对象树，看看游戏里有什么。",
                "跑点代码探索一下当前环境怎么样？",
                "要不搜索一下游戏里的对象？说不定有有趣的发现。",
                "可以试试批量反编译 PlayerScripts，看看客户端脚本都在做什么。",
                "无聊的话，不如看看游戏里有没有隐藏的脚本？",
                "试试执行点代码玩玩？比如看看当前 Workspace 里有什么。",
            }
            return sugs[math.random(#sugs)]
        elseif parsed.tone == "praise" then
            local acks = {"谢谢", "过奖了", "还行吧", "承蒙夸奖", "谢谢认可", "哈哈谢谢", "你也不错"}
            local tails = {
                "有需要继续用。", "随时可以帮忙。", "继续吧。", "你也是。", "还需要什么直接说。",
                "有其他事随时找我。",
            }
            return acks[math.random(#acks)] .. "，" .. tails[math.random(#tails)]
        elseif parsed.tone == "happy" then
            local replies = {
                "看你心情不错，有什么好事分享一下？",
                "哈哈，心情好就最好了。有什么想做的吗？",
                "开心就好！需要我帮什么忙吗？",
                "真好，心情好效率也高。想做点什么？",
                "不错不错，有什么我可以帮的？",
                "看你这么开心，要不试试点新功能？",
            }
            return replies[math.random(#replies)]
        elseif parsed.tone == "sad" then
            local replies = {
                "别太难过了，有什么我可以帮忙的吗？",
                "抱抱，如果遇到了什么问题，把具体情况告诉我，我来帮你排查。",
                "辛苦了，要不要让我帮你做点什么？比如查查脚本、跑跑代码，省点事。",
                "别灰心，有什么问题直接说，我尽力帮你解决。",
                "嗯，有时候确实挺累的。有需要的话随时找我，反编译、查对象这些我可以代劳。",
                "别太郁闷了，要不试试干点别的？我可以帮你探索一下游戏里的内容。",
            }
            return replies[math.random(#replies)]
        elseif parsed.tone == "complaint" then
            local replies = {
                "哈哈，确实有时候挺坑的。有什么我能帮上忙的吗？",
                "理解你的感受。要吐槽的话尽管说，需要解决具体问题也可以找我。",
                "确实离谱。有需要排查或者反编译的，随时说。",
                "哈哈别气别气，有具体问题我帮你处理。",
                "懂你，遇到坑确实烦。有什么我能帮忙解决的？",
            }
            return replies[math.random(#replies)]
        elseif parsed.tone == "daily_topic" then
            local replies = {
                "天气不错的话心情也会好，有什么想做的吗？",
                "说到游戏，这游戏里其实有不少脚本可以探索，要不要看看？",
                "周末的话可以慢慢折腾，有什么想试试的功能？",
                "心情还行的话，不如一起做点什么？反编译、查对象、跑代码都行。",
                "嗯，日常聊聊天也挺好的。不过有活要干的话随时说。",
                "说起这些，倒是可以顺便看看游戏里的脚本写得怎么样，要不要试试？",
            }
            return replies[math.random(#replies)]
        elseif parsed.tone == "emoticon" then
            local replies = {
                "哈哈，怎么了？",
                "嘿嘿，有什么事？",
                "哇，说说看？",
                "嗯嗯，在的。",
                "哈哈，有什么需要帮忙的？",
                "嘿嘿，有什么想做的？",
                "哎呀，怎么了？",
                "啊这，遇到什么问题了？",
            }
            return replies[math.random(#replies)]
        elseif parsed.tone == "casual" then
            local hour = tonumber(os.date("%H")) or 12
            local timeGreeting
            if hour < 6 then timeGreeting = "夜深了还在"
            elseif hour < 9 then timeGreeting = "早上好，在"
            elseif hour < 12 then timeGreeting = "上午好，在"
            elseif hour < 14 then timeGreeting = "中午好，在"
            elseif hour < 18 then timeGreeting = "下午好，在"
            else timeGreeting = "晚上好，在" end
            local replies = {
                timeGreeting .. "呢，有什么需要帮忙的？",
                "等着你发指令呢，说吧，想做什么？",
                "随时待命，需要反编译、搜索还是执行代码？",
                "在的，直接说需求就行。",
                "闲着呢，有什么能帮上的？",
                "在这儿，你可以让我反编译脚本、搜索对象或者跑代码。",
                "等你呢，想干点啥？",
                "在的，有什么事直接说。",
                "嗯哼，说说看？",
                "在线中，随时可以开始。",
                "吃了没？哈哈，有什么事直接说吧。",
                "还没睡呢，有事就说。",
                "在呢在呢，直接说吧。",
                "行，你说，我听着。",
            }
            return replies[math.random(#replies)]
        end

    elseif r.answerType == "definition" then
        local parts = {}
        local concept = r.concept
        local openers = {concept.concept .. "是" .. concept.def, "关于" .. concept.concept .. "：" .. concept.def, concept.def}
        table.insert(parts, openers[math.random(#openers)] .. "。")
        if concept.props and #concept.props > 0 then
            local shuffled = {}
            for i = 1, #concept.props do shuffled[i] = concept.props[i] end
            for i = #shuffled, 2, -1 do
                local j = math.random(i)
                shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
            end
            local maxProps = math.min(#shuffled, 2)
            for i = 1, maxProps do
                table.insert(parts, shuffled[i] .. "。")
            end
        end
        local extraFacts = {}
        for _, f in ipairs(r.facts) do
            if f ~= concept.def and not (concept.props and table.find(concept.props, f)) and not f:find("^步骤") and not f:find("属于") and not f:find("是替代方案") then
                extraFacts[#extraFacts + 1] = f
            end
        end
        if #extraFacts > 0 then
            table.insert(parts, extraFacts[math.random(#extraFacts)] .. "。")
        end
        return table.concat(parts)

    elseif r.answerType == "procedural" then
        local concept = r.concept
        if not concept then return "需要更具体的信息才能帮你。" end
        local parts = {}
        local leads = {concept.concept .. "的操作流程：\n", "要" .. concept.concept .. "的话，按以下步骤：\n", concept.concept .. "步骤：\n"}
        table.insert(parts, leads[math.random(#leads)])
        local stepCount = 0
        for _, f in ipairs(r.facts) do
            if f:find("步骤") then
                stepCount = stepCount + 1
                table.insert(parts, f .. "\n")
            end
        end
        if stepCount == 0 and concept.props then
            for i, pr in ipairs(concept.props) do
                table.insert(parts, i .. ". " .. pr .. "\n")
            end
        end
        return table.concat(parts)

    elseif r.answerType == "causal" then
        local parts = {}
        local causes, solutions = {}, {}
        for _, f in ipairs(r.facts) do
            if f:find("原因") then causes[#causes + 1] = f:gsub("^原因: ", "")
            elseif f:find("解决") then solutions[#solutions + 1] = f:gsub("^解决: ", "") end
        end
        if #causes > 0 then
            local causeLeads = {"可能的原因：\n", "问题可能出在：\n", "常见原因：\n"}
            table.insert(parts, causeLeads[math.random(#causeLeads)])
            for i, c in ipairs(causes) do
                table.insert(parts, "  " .. i .. ". " .. c .. "\n")
            end
        end
        if #solutions > 0 then
            local solLeads = {"建议的解决方案：\n", "可以这样修复：\n", "解决方法：\n"}
            table.insert(parts, solLeads[math.random(#solLeads)])
            for i, s in ipairs(solutions) do
                table.insert(parts, "  " .. i .. ". " .. s .. "\n")
            end
        end
        return table.concat(parts)

    elseif r.answerType == "location" then
        local parts = {}
        if r.concept then
            table.insert(parts, r.concept.concept .. r.concept.def .. "。")
        end
        for _, f in ipairs(r.facts) do
            if f:find("位于") then table.insert(parts, f .. "。") end
        end
        if #parts == 0 then return "这个位置信息我不太确定，能再具体描述吗？" end
        return table.concat(parts)

    elseif r.answerType == "confirm" then
        if r.concept then
            local yesno = math.random() > 0.3
            if yesno then
                local confirms = {"是的", "对", "没错"}
                return confirms[math.random(#confirms)] .. "，" .. r.concept.def .. "。" .. (r.concept.props and r.concept.props[1] or "") .. "。"
            else
                local denies = {"不完全是这样", "不完全是", "不太准确"}
                return denies[math.random(#denies)] .. "。" .. r.concept.concept .. "实际上" .. r.concept.def .. "。"
            end
        end
        return "这个问题需要更多上下文才能准确回答。"

    elseif r.answerType == "explain" then
        local concept = r.concept
        if not concept then return "能再说具体一点吗？" end
        local parts = {}
        local openers = {concept.def, "关于" .. concept.concept .. "，" .. concept.def, concept.concept .. "：" .. concept.def}
        table.insert(parts, openers[math.random(#openers)] .. "。")
        local infoFacts = {}
        for _, f in ipairs(r.facts) do
            if f ~= concept.def and not f:find("^步骤") and not f:find("是替代方案") and not f:find("结合之前") and not f:find("上文提到") and not f:find("相关概念") then
                infoFacts[#infoFacts + 1] = f
            end
        end
        -- 随机选取2-3条信息
        local maxInfo = math.min(#infoFacts, 3)
        local selected = {}
        local indices = {}
        for i = 1, #infoFacts do indices[i] = i end
        for i = #indices, 2, -1 do
            local j = math.random(i)
            indices[i], indices[j] = indices[j], indices[i]
        end
        for i = 1, maxInfo do
            selected[i] = infoFacts[indices[i]]
        end
        for i, f in ipairs(selected) do
            if i == #selected and #selected > 1 then
                table.insert(parts, "另外" .. f .. "。")
            else
                table.insert(parts, f .. "。")
            end
        end
        return table.concat(parts)

    elseif r.answerType == "debug" then
        local parts = {}
        if parsed.entities.path then
            local leads = {
                "你提到了" .. parsed.entities.path .. "，我可以先反编译看看源码来定位问题。",
                parsed.entities.path .. "这个脚本，我先反编译出来分析一下。",
                "针对" .. parsed.entities.path .. "，反编译后就能看到源码了。",
            }
            table.insert(parts, leads[math.random(#leads)])
        else
            local leads = {
                "遇到代码问题的话，把完整的错误信息和脚本路径贴给我。",
                "给我报错内容和相关脚本，我来排查。",
                "说说具体什么报错，哪个脚本出了问题？",
            }
            table.insert(parts, leads[math.random(#leads)])
        end
        for _, f in ipairs(r.facts) do
            if not f:find("涉及路径") and not f:find("建议反编译") and not f:find("需要更多") then
                table.insert(parts, f .. "。")
            end
        end
        return table.concat(parts)

    elseif r.answerType == "object" then
        if parsed.entities.path then
            local leads = {
                parsed.entities.path .. "这个对象，你想做什么？列子对象、查属性还是反编译？",
                "针对" .. parsed.entities.path .. "，需要列子对象、查属性还是看源码？",
                parsed.entities.path .. "——要我列子对象、看属性，还是反编译？",
            }
            return leads[math.random(#leads)]
        else
            local leads = {
                "想操作哪个对象？给个路径或名字，比如game.Workspace。",
                "哪个对象？说个路径就行。",
                "你要操作什么对象？给我一个路径。",
            }
            return leads[math.random(#leads)]
        end

    elseif r.answerType == "conversation" then
        if #r.facts > 0 and r.confidence >= 0.5 then
            return r.facts[1]
        end
        local acks = {"嗯", "明白", "收到", "在的", "好的", "了解", "嗯嗯"}
        local asks = {"具体想做什么？", "有什么需要我帮忙的？", "说说你的需求？", "然后呢？", "需要我做什么？", "接下来呢？"}
        return acks[math.random(#acks)] .. "，" .. asks[math.random(#asks)]

    elseif r.answerType == "unknown" then
        if #r.facts > 0 and r.confidence >= 0.5 then
            return r.facts[1]
        end
        local hints = {
            "反编译脚本", "执行代码", "查对象属性", "浏览对象树", "管理输出文件",
            "搜索对象", "计算数学表达式",
        }
        local picked = {}
        local copy = {}
        for i = 1, #hints do copy[i] = hints[i] end
        for _ = 1, 3 do
            if #copy == 0 then break end
            local i = math.random(#copy)
            picked[#picked + 1] = copy[i]
            table.remove(copy, i)
        end
        local acks = {"不太理解你的意思", "这个我没看懂", "不太确定你想要什么", "这个我有点没跟上"}
        local asks = {"能换个说法吗？", "能说具体点吗？", "能再描述清楚些吗？", "可以举个例子吗？"}
        local hintStr = table.concat(picked, "、")
        return acks[math.random(#acks)] .. "。" .. asks[math.random(#asks)] .. "我能帮你" .. hintStr .. "。"
    end

    return "我在思考，能再详细描述一下你的需求吗？"
end

-- Response validator: checks relevance and quality
local function wasaiValidateResponse(response, parsed)
    if not response or response == "" then return false, "empty" end
    if response:match("^%s*{%s*\"tool\"") then return true, "toolcall" end
    if #response > 2000 then response = response:sub(1, 2000) .. "…" end
    return true, "ok"
end

-- ============================================================
-- Main cognitive function: pure Luau reasoning pipeline
-- ============================================================

-- Track last tool operation for context-aware decisions
local wasaiLastToolOp = {name = nil, result = nil, time = 0}

-- ============================================================
-- DeepSeek API 驱动层：真实 API 对话 + 原生工具调用（完整工具链）
-- 兼容 OpenAI /chat/completions 格式
-- ============================================================

local WASAI_FORBIDDEN_FRAGMENTS = {
    "我结合了之前的对话上下文",
    "我是 DeltaUI 内置智能助手",
    "我分析了你的请求",
    "我会继续推理",
    "根据上下文判断",
    "我是基于关键词",
    "关键词匹配",
    "关键词触发",
    "关键词感知",
    "我的意图识别系统",
    "根据意图评分",
    "根据语义特征权重",
    "我的回复库",
    "从回复模板",
}

local function wasaiCleanFinalText(text)
    text = tostring(text or "")
    for _, word in ipairs(WASAI_FORBIDDEN_FRAGMENTS) do
        text = text:gsub(word, "")
    end
    return text:gsub("^%s+", ""):gsub("%s+$", "")
end

-- 获取执行器的 HTTP 请求函数（多种注入方式兼容）
local function wasaiGetHttpRequestFn()
    local fn = (syn and syn.request) or (http and http.request) or http_request or request
    return fn
end

-- 执行一次 HTTP POST，返回成功与否、状态码与响应体
local function wasaiHttpPost(url, headers, body)
    local req = wasaiGetHttpRequestFn()
    if req then
        local ok, resp = pcall(req, {
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body,
        })
        if ok and type(resp) == "table" then
            return true, resp.StatusCode or 200, resp.Body or "", resp.StatusMessage or ""
        end
        return false, 0, tostring(resp), "request error"
    end
    -- 兜底：HttpService:RequestAsync
    if svc.HttpService and svc.HttpService.RequestAsync then
        local ok, resp = pcall(function()
            return svc.HttpService:RequestAsync({
                Url = url,
                Method = "POST",
                Headers = headers,
                Body = body,
            })
        end)
        if ok and type(resp) == "table" then
            return true, resp.StatusCode or 200, resp.Body or "", resp.StatusMessage or ""
        end
        return false, 0, tostring(resp), "RequestAsync error"
    end
    return false, 0, "", "no http request function available"
end

-- 原生工具定义（与 wasaiExecuteToolCall 中实现的 12 个工具一一对应）
-- 精简描述以显著降低每轮请求的 token 消耗
local WASAI_DEEPSEEK_TOOLS = {
    {type="function", ["function"]={name="list_children", description="列子对象", parameters={type="object", properties={path={type="string"}, depth={type="number"}}, required={"path"}}}},
    {type="function", ["function"]={name="decompile", description="反编译脚本", parameters={type="object", properties={path={type="string"}}, required={"path"}}}},
    {type="function", ["function"]={name="decompile_smart", description="智能反编译", parameters={type="object", properties={target={type="string"}}, required={"target"}}}},
    {type="function", ["function"]={name="decompile_all", description="反编译全部脚本", parameters={type="object"}}},
    {type="function", ["function"]={name="get_property", description="读属性", parameters={type="object", properties={path={type="string"}, property={type="string"}}, required={"path","property"}}}},
    {type="function", ["function"]={name="list_properties", description="列属性", parameters={type="object", properties={path={type="string"}}, required={"path"}}}},
    {type="function", ["function"]={name="execute_lua", description="执行Lua(需用户授权)", parameters={type="object", properties={code={type="string"}}, required={"code"}}}},
    {type="function", ["function"]={name="find_objects", description="全局找对象", parameters={type="object", properties={name={type="string"}}, required={"name"}}}},
    {type="function", ["function"]={name="search_objects", description="搜索对象", parameters={type="object", properties={name={type="string"}}, required={"name"}}}},
    {type="function", ["function"]={name="count_output_files", description="统计输出文件数", parameters={type="object"}}},
    {type="function", ["function"]={name="list_output_files", description="列出输出文件", parameters={type="object"}}},
    {type="function", ["function"]={name="delete_recent_files", description="删除最近文件", parameters={type="object"}}},
    {type="function", ["function"]={name="noclip", description="穿墙", parameters={type="object", properties={enabled={type="boolean"}}}}},
    {type="function", ["function"]={name="anti_fling", description="防甩飞", parameters={type="object", properties={enabled={type="boolean"}}}}},
    {type="function", ["function"]={name="read_file", description="读取文件", parameters={type="object", properties={path={type="string"}}, required={"path"}}}},
    {type="function", ["function"]={name="report_progress", description="向用户汇报当前处理进度", parameters={type="object", properties={message={type="string", description="进度说明"}}, required={"message"}}}},
}

-- 手动 JSON 编码器：避免依赖 Roblox HttpService:JSONEncode 的怪异行为
-- （空表会被编成 []、可能抛错），保证请求体编码稳定、紧凑（省 token）
local function wasaiJSONEscape(s)
    s = tostring(s or "")
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    s = s:gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
    s = s:gsub("\b", "\\b"):gsub("\f", "\\f")
    s = s:gsub("[%c]", function(c) return string.format("\\u%04x", c:byte()) end)
    return s
end

local function wasaiJSONEncode(v)
    local t = type(v)
    if v == nil then return "null" end
    if t == "boolean" then return v and "true" or "false" end
    if t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return "null" end
        return tostring(v)
    end
    if t == "string" then return '"' .. wasaiJSONEscape(v) .. '"' end
    if t == "table" then
        -- 判断是否为数组（连续整型下标 1..n）
        local isArray = true
        local count = 0
        for k in pairs(v) do
            count = count + 1
            if type(k) ~= "number" or k < 1 or k ~= math.floor(k) then
                isArray = false
            end
        end
        if isArray and count > 0 then
            for i = 1, count do
                if v[i] == nil then isArray = false break end
            end
        end
        if isArray and count > 0 then
            local parts = {}
            for i = 1, count do parts[i] = wasaiJSONEncode(v[i]) end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        -- 对象（空表也走这里，得到 {}）
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = '"' .. wasaiJSONEscape(k) .. '":' .. wasaiJSONEncode(val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null" -- 函数/userdata 等不可序列化
end

-- 解析 DeepSeek 的 DSML 工具调用文本（当模型以文本而非结构化 tool_calls 返回时）
-- DeepSeek 推理模型把函数调用以 DSML 文本形式写在 content 里，常见两种写法：
--   (A) 分隔符式：<|DSML|>tool_calls<|DSML|> <|DSML|>invoke name="x"<|DSML|> ...
--   (B) 标签式：  <|| DSML || tool_calls> <|| DSML || invoke name="x"> ...
--       例如：<|| DSML || parameter name="path" string="true">ReplicatedStorage.Remotes<|| DSML || parameter>
-- 兼容竖线/空格/斜杠有任意变化的写法：<|DSML|>、<| DSML |、<|| DSML ||、<DSML|>、
-- 以及关闭标签 <|| DSML || invoke> 或 </|| DSML || invoke> 等。
local function wasaiTokenizeDSML(content)
    local seq = {}
    -- 匹配任意一个 DSML 标签，并捕获标签内部（DSML 之后、> 之前）的命令文本
    local TAG = '<[/]?[%s|]*DSML[%s|]*(.-)>'
    local last = 1
    local pos = 1
    while true do
        local s, e, cmd = content:find(TAG, pos)
        if not s then break end
        local between = content:sub(last, s - 1)
        if between ~= "" then seq[#seq + 1] = between end
        if cmd and cmd ~= "" then seq[#seq + 1] = cmd end
        last = e + 1
        pos = e + 1
    end
    local tail = content:sub(last)
    if tail ~= "" then seq[#seq + 1] = tail end
    return seq
end

local function wasaiParseDSMLToolCalls(content)
    if type(content) ~= "string" then return nil end
    local calls = {}
    local currentCall = nil   -- 当前正在解析的 invoke
    local paramName = nil     -- 当前正在收集值的 parameter 名
    local paramVal = nil      -- 当前参数累积的值
    local inCalls = false     -- 是否处于 tool_calls 块内

    local seq = wasaiTokenizeDSML(content)
    for _, raw in ipairs(seq) do
        local tok = raw:gsub('^%s+', ''):gsub('%s+$', '')
        if tok ~= '' then
            if tok == 'tool_calls' then
                -- 结构 B 的关闭/开启标签同为 tool_calls，按当前状态区分
                if inCalls then
                    inCalls = false
                    currentCall, paramName, paramVal = nil, nil, nil
                else
                    inCalls = true
                end
            elseif tok:match('^/+tool_calls') then
                -- 结构 A 的关闭：/tool_calls
                inCalls = false
                currentCall, paramName, paramVal = nil, nil, nil
            elseif inCalls then
                local invokeName = tok:match('^invoke%s+name="([^"]+)"')
                if invokeName then
                    currentCall = { id = 'dsml_' .. tostring(#calls + 1), name = invokeName, args = {} }
                    calls[#calls + 1] = currentCall
                    paramName, paramVal = nil, nil
                else
                    local pname = tok:match('^parameter%s+name="([^"]+)"')
                    if pname then
                        paramName, paramVal = pname, nil
                    elseif tok == 'invoke' or tok:match('^/+invoke') then
                        -- 关闭 invoke（结构 B 无斜杠 / 结构 A 带斜杠）
                        currentCall, paramName, paramVal = nil, nil, nil
                    elseif tok == 'parameter' or tok:match('^/+parameter') then
                        -- 关闭 parameter
                        if currentCall and paramName then
                            currentCall.args[paramName] = paramVal or ''
                        end
                        paramName, paramVal = nil, nil
                    elseif currentCall and paramName then
                        -- 参数值：parameter 与 /parameter 之间、非控制词的 token 即值
                        paramVal = (paramVal and (paramVal .. tok)) or tok
                    end
                end
            end
        end
    end
    if #calls > 0 then return calls end

    -- ===== 兜底：宽松直接提取 =====
    -- 若上面的状态机因 DSML 写法差异未解析成功，则直接从原文提取
    -- invoke name 与 parameter name/value 对。对结构 A/B 及任意分隔符变化均有效：
    --   parameter name="x" ... >VALUE< ...（值 = 首个 > 之后、下一个 < 之前）
    local invokes = {}
    local ipos = 1
    while true do
        local s, e, invName = content:find('invoke%s+name="([^"]+)"', ipos)
        if not s then break end
        invokes[#invokes + 1] = { s = s, e = e, name = invName }
        ipos = e + 1
    end
    if #invokes == 0 then return nil end
    local lcalls = {}
    for i, inv in ipairs(invokes) do
        local segStart = inv.e + 1
        local segEnd = (i < #invokes) and (invokes[i + 1].s - 1) or #content
        local seg = content:sub(segStart, segEnd)
        local call = { id = 'dsml_' .. tostring(i), name = inv.name, args = {} }
        local ppos = 1
        while true do
            local ps, pe, pname = seg:find('parameter%s+name="([^"]+)"', ppos)
            if not ps then break end
            local gt = seg:find('>', pe)
            local lt = gt and seg:find('<', gt + 1)
            local val = ""
            if gt then
                val = seg:sub(gt + 1, lt and (lt - 1) or -1)
            end
            val = val:gsub('^%s+', ''):gsub('%s+$', '')
            -- 若值里仍夹着 DSML 关闭标记，截断到标记处
            local mstart = val:find('<[%s|/]*DSML', 1)
            if mstart then val = val:sub(1, mstart - 1) end
            if pname and pname ~= '' then call.args[pname] = val end
            ppos = pe + 1
        end
        lcalls[#lcalls + 1] = call
    end
    if #lcalls == 0 then return nil end
    return lcalls
end

-- 移除文本中的 DSML 工具调用标记，避免泄漏到聊天框
local function wasaiStripDSML(content)
    if type(content) ~= "string" then return content end
    local s = content
    -- 结构 B：tool_calls 在单个标签内（<||DSML||tool_calls> ... <||DSML||tool_calls>）
    local OT = '<[%s|/]*DSML[%s|/]*/?[%s|/]*tool_calls[%s|/]*>'
    s = s:gsub(OT .. '.-' .. OT, '')
    -- 结构 A：分隔符式（<|DSML|>tool_calls ... <|DSML|>/tool_calls<|DSML|>）
    local OA = '<[%s|]*DSML[%s|]*>[%s]*tool_calls'
    local CA = '<[%s|]*DSML[%s|]*>[%s]*/[%s]*tool_calls[%s]*<[%s|]*DSML[%s|]*>'
    s = s:gsub(OA .. '.-' .. CA, '')
    -- 移除任何残留的单个 DSML 标签
    s = s:gsub('<[/]?[%s|]*DSML[%s|]*[^>]*>', '')
    -- 清理可能残留的残缺控制词（未闭合/被截断的块）
    s = s:gsub('[%s]*/[%s]*tool_calls', '')
    s = s:gsub('[%s]*tool_calls', '')
    s = s:gsub('[%s]*/[%s]*invoke', '')
    s = s:gsub('[%s]*invoke%s+name="[^"]*"', '')
    s = s:gsub('[%s]*/[%s]*parameter', '')
    s = s:gsub('[%s]*parameter%s+name="[^"]*"[^\n]*', '')
    return s
end

-- 调用 DeepSeek 对话接口（OpenAI 兼容），支持原生工具调用
-- 返回: content(文本), toolCalls({name,args,id} 表或 nil), apiErr
local function wasaiDeepSeekChat(messages, tools, opts)
    opts = opts or {}
    local body = {
        model = wasaiLocalAIConfig.model,
        messages = messages,
        temperature = opts.temperature or wasaiLocalAIConfig.temperature,
        stream = false,
    }
    -- 非思考模式：关闭思维链，减少输出 token、降低延迟
    if wasaiLocalAIConfig.thinkingDisabled then
        body.thinking = {type = "disabled"}
    end
    local maxTok = opts.maxTokens or wasaiLocalAIConfig.maxTokens
    if maxTok and maxTok > 0 then
        body.max_tokens = maxTok
    end
    if tools and #tools > 0 then
        body.tools = tools
        body.tool_choice = "auto"
    end

    local okEnc, bodyJson = pcall(wasaiJSONEncode, body)
    if not okEnc or type(bodyJson) ~= "string" or bodyJson == "" then
        return nil, nil, "JSON编码失败: " .. tostring(bodyJson)
    end

    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. tostring(wasaiLocalAIConfig.apiKey),
    }

    local ok, code, respBody, statusMsg = wasaiHttpPost(
        wasaiLocalAIConfig.endpoint, headers, bodyJson
    )
    if not ok then
        return nil, nil, "网络请求失败: " .. tostring(respBody or statusMsg)
    end
    if code < 200 or code >= 300 then
        local hint = statusMsg ~= "" and statusMsg or ("HTTP " .. tostring(code))
        if respBody and respBody ~= "" then
            hint = hint .. " " .. wasaiSafeString(respBody, 300)
        end
        return nil, nil, hint
    end
    if not respBody or respBody == "" then
        return nil, nil, "空响应体"
    end

    local okDec, data = pcall(function()
        return svc.HttpService:JSONDecode(respBody)
    end)
    if not okDec or type(data) ~= "table" then
        return nil, nil, "响应解析失败: " .. wasaiSafeString(respBody, 200)
    end

    if not (data.choices and data.choices[1] and data.choices[1].message) then
        return nil, nil, "响应缺少 choices.message 字段"
    end

    local msg = data.choices[1].message
    local content = tostring(msg.content or "")
    local toolCalls = nil

    if type(msg.tool_calls) == "table" and #msg.tool_calls > 0 then
        toolCalls = {}
        for _, tc in ipairs(msg.tool_calls) do
            local t = type(tc) == "table" and tc or {}
            local fn = type(t["function"]) == "table" and t["function"] or {}
            local args = {}
            if fn.arguments and fn.arguments ~= "" then
                local okA, parsedA = pcall(function()
                    return svc.HttpService:JSONDecode(fn.arguments)
                end)
                if okA and type(parsedA) == "table" then args = parsedA end
            end
            toolCalls[#toolCalls + 1] = {
                id = tostring(t.id or "call_" .. tostring(#toolCalls + 1)),
                name = tostring(fn.name or ""),
                args = args,
            }
        end
    elseif content:find("<[%s|]-DSML", 1) then
        -- 模型以 DSML 文本形式表达工具调用：解析为结构化 toolCalls，并从 content 中剥离
        local dsml = wasaiParseDSMLToolCalls(content)
        if dsml then
            toolCalls = dsml
            content = wasaiStripDSML(content)
        end
    end

    return content, toolCalls, nil
end

-- 更新会话标题并重命名对应的 .chat 文件
local function wasaiSetSessionTitle(title)
    if not title or title == "" then return end
    wasaiCurrentSession.sessionTitle = tostring(title)
    if wasaiCurrentSession.sessionFile and isfile and listfiles then
        local dir = wasaiCurrentSession.sessionDir
        local safeTitle = tostring(title):gsub("[/\\:*?\"<>|\r\n\t ]+", "_"):gsub("^_+", ""):gsub("_+$", "")
        if safeTitle == "" then safeTitle = "default" end
        if #safeTitle > 40 then safeTitle = safeTitle:sub(1, 40) end
        local newPath = dir .. "/" .. safeTitle .. ".chat"
        if newPath ~= wasaiCurrentSession.sessionFile and isfile(newPath) then
            newPath = dir .. "/" .. safeTitle .. "_" .. os.time() .. ".chat"
        end
        if newPath ~= wasaiCurrentSession.sessionFile then
            pcall(function()
                if isfile(wasaiCurrentSession.sessionFile) then
                    local content = readfile(wasaiCurrentSession.sessionFile)
                    if content then writefile(newPath, content) end
                    delfile(wasaiCurrentSession.sessionFile)
                end
            end)
            wasaiCurrentSession.sessionFile = newPath
            wasaiCurrentSession.sessionKey = safeTitle
        end
    end
    wasaiSaveChatHistory()
end

-- 列出当前服务器 chat 目录下所有对话条目（按更新时间倒序）
local function wasaiListAllChats()
    wasaiEnsureAgentFolders()
    local placeId = tostring(game.PlaceId or 0)
    local folder = "DeltaUI/Agent/Chat/对话_" .. placeId
    local list = {}
    if not isfolder(folder) or not listfiles then return list end
    local ok, files = pcall(listfiles, folder)
    if not ok or type(files) ~= "table" then return list end
    for _, path in ipairs(files) do
        if isfile(path) and path:match("%.chat$") then
            local data = wasaiReadChatFile(path)
            local name = (path:match("([^/\\]+)$") or path):gsub("%.chat$", "")
            local title = (data and data.metadata and data.metadata.title) or name
            if title == "" or title == "null" then title = name end
            local t = (data and data.updatedAt) or (data and data.createdAt) or 0
            if tonumber(t) then t = tonumber(t) else t = 0 end
            list[#list + 1] = {
                path = folder,
                file = path,
                name = name,
                title = title,
                time = t,
                count = (data and type(data.messages) == "table" and #data.messages) or 0,
            }
        end
    end
    table.sort(list, function(a, b)
        if a.time == b.time then return a.title > b.title end
        return a.time > b.time
    end)
    return list
end

-- 兼容旧调用的文本生成入口：调用 API（不带工具）生成纯文本；失败时回退本地引擎
local function wasaiCallLLM(messages)
    local started = tick()
    if wasaiMetrics.thinkingStartTime == 0 then
        wasaiMetrics.thinkingStartTime = started
    end
    local input = ""
    if type(messages) == "table" then
        for i = #messages, 1, -1 do
            if messages[i].role == "user" then
                input = messages[i].content or ""
                break
            end
        end
    end

    local content, _, apiErr = wasaiDeepSeekChat(messages, nil)
    local answer
    if content and content ~= "" then
        wasaiLocalAIState.mode = "api"
        answer = content
    else
        warn("[DeltaUI][AI] API 不可用(" .. tostring(apiErr) .. ")")
        wasaiLocalAIState.mode = "api"
        wasaiLocalAIState.lastError = apiErr
        wasaiLocalAIState.failures = (wasaiLocalAIState.failures or 0) + 1
        answer = "抱歉，当前无法连接到 AI 服务（" .. tostring(apiErr) .. "）。请稍后重试。"
    end

    answer = wasaiCleanFinalText(answer)

    wasaiLocalAIState.available = true
    wasaiLocalAIState.lastLatency = math.max(0, tick() - started)
    return answer
end

local function wasaiTryParseToolCall(text)
    if type(text) ~= "string" then return nil end
    local trimmed = text:gsub("^%s+", ""):gsub("%s+$", "")

    local candidates = {trimmed}
    local fence = trimmed:match("```%w*%s*\n(.-)\n%s*```")
    if fence then table.insert(candidates, fence) end
    local s = trimmed:find("{", 1, true)
    if s then
        for i = #trimmed, s, -1 do
            if trimmed:sub(i, i) == "}" then
                table.insert(candidates, trimmed:sub(s, i))
                break
            end
        end
    end

    for _, cand in ipairs(candidates) do
        local ok, decoded = pcall(function() return svc.HttpService:JSONDecode(cand) end)
        if ok and type(decoded) == "table" and type(decoded.tool) == "string" then
            return decoded.tool, type(decoded.args) == "table" and decoded.args or {}
        end
    end
    return nil
end

local function wasaiShowConfirmDialog(code)
    local confirmed = false
    local done = false
    local dialog = create("ScreenGui", {
        Name = "ConfirmDialog",
        Parent = game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 1000000, -- 高于主窗口(999999)，确保代码确认框显示在最上层
        IgnoreGuiInset = true,
    })

    -- 无黑色蒙版：面板直接放 ScreenGui 里，ZIndex 高即可盖住窗口
    local panel = create("Frame", {
        Name = "ConfirmPanel",
        Size = UDim2.new(0, 360, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),   -- 居中，避免溢出屏幕
        BackgroundColor3 = Color3.fromRGB(28, 32, 40),
        BorderSizePixel = 0,
        Parent = dialog,
        ZIndex = 100
    })
    corner(14, panel)
    stroke(Color3.fromRGB(50, 55, 70), 1, panel)
    create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 28),
        Position = UDim2.new(0, 16, 0, 14),
        BackgroundTransparency = 1,
        Text = "Agent 想要执行 Lua 代码",
        TextColor3 = Color3.fromRGB(230, 232, 240),
        Font = Enum.Font.SourceSansBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = panel,
        ZIndex = 101
    })

    -- 估算代码行数，限制代码框高度（最高 220px，超出可滚动），防止面板溢出屏幕
    local codeStr = tostring(code or "")
    local lineCount = 1
    for _ in codeStr:gmatch("\n") do lineCount = lineCount + 1 end
    local codeH = math.max(60, math.min(220, lineCount * 18 + 16))

    local codeBox = create("ScrollingFrame", {
        Name = "CodeBox",
        Size = UDim2.new(1, -32, 0, codeH),
        Position = UDim2.new(0, 16, 0, 50),
        BackgroundColor3 = Color3.fromRGB(18, 22, 30),
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(80, 90, 110),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = panel,
        ZIndex = 101
    })
    corner(8, codeBox)
    create("UIListLayout", {Padding = UDim.new(0, 0), Parent = codeBox})
    local codeLabel = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = codeStr,
        TextColor3 = Color3.fromRGB(180, 200, 220),
        Font = Enum.Font.Code,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = codeBox,
        ZIndex = 102
    })
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = codeLabel
    })

    local btnY = 50 + codeH + 12
    create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 20),
        Position = UDim2.new(0, 16, 0, btnY),
        BackgroundTransparency = 1,
        Text = "你想怎么做？",
        TextColor3 = Color3.fromRGB(140, 150, 170),
        Font = Enum.Font.SourceSans,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = panel,
        ZIndex = 101
    })

    local cancelBtn = create("TextButton", {
        Size = UDim2.new(0, 100, 0, 32),
        Position = UDim2.new(1, -116, 0, btnY + 28),
        BackgroundColor3 = Color3.fromRGB(60, 65, 80),
        Text = "取消",
        TextColor3 = Color3.fromRGB(200, 200, 210),
        Font = Enum.Font.SourceSansBold,
        TextSize = 13,
        BorderSizePixel = 0,
        Parent = panel,
        ZIndex = 102
    })
    corner(8, cancelBtn)

    local confirmBtn = create("TextButton", {
        Size = UDim2.new(0, 100, 0, 32),
        Position = UDim2.new(1, -228, 0, btnY + 28),
        BackgroundColor3 = Color3.fromRGB(59, 130, 246),
        Text = "确认",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 13,
        BorderSizePixel = 0,
        Parent = panel,
        ZIndex = 102
    })
    corner(8, confirmBtn)

    panel.Size = UDim2.new(0, 360, 0, (btnY + 28) + 32 + 16)

    cancelBtn.MouseButton1Click:Connect(function()
        confirmed = false
        done = true
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        confirmed = true
        done = true
    end)

    local timeout = 30
    local waited = 0
    while not done and waited < timeout do
        task.wait(0.1)
        waited = waited + 0.1
    end
    dialog:Destroy()
    return confirmed
end

-- 实时功能开关状态（穿墙 / 防甩飞）
local wasaiToolState = {
    noclip = {active = false, conn = nil},
    antiFling = {active = false, conn = nil},
}

-- 穿墙(noclip)：关闭自身角色零件的碰撞，可在物体中穿行
local function wasaiSetNoclip(enabled)
    local state = wasaiToolState.noclip
    if enabled then
        if state.active then return "穿墙已处于开启状态" end
        state.active = true
        state.conn = svc.RunService.Stepped:Connect(function()
            local lp = svc.Players.LocalPlayer
            local char = lp and lp.Character
            if not char then return end
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root:IsA("BasePart") then root.CanCollide = false end
        end)
        return "穿墙已开启（noclip）"
    else
        if not state.active then return "穿墙已是关闭状态" end
        state.active = false
        if state.conn then pcall(function() state.conn:Disconnect() end) end
        state.conn = nil
        local lp = svc.Players.LocalPlayer
        local char = lp and lp.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
        return "穿墙已关闭"
    end
end

-- 防甩飞(anti-fling)：持续关闭其他玩家角色零件的碰撞，使其无法碰撞/甩飞你
local function wasaiSetAntiFling(enabled)
    local state = wasaiToolState.antiFling
    if enabled then
        if state.active then return "防甩飞已处于开启状态" end
        state.active = true
        state.conn = svc.RunService.Stepped:Connect(function()
            local lp = svc.Players.LocalPlayer
            for _, plr in ipairs(svc.Players:GetPlayers()) do
                if plr ~= lp then
                    local char = plr.Character
                    if char then
                        for _, v in ipairs(char:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end
            end
        end)
        return "防甩飞已开启（已关闭其他玩家的碰撞）"
    else
        if not state.active then return "防甩飞已是关闭状态" end
        state.active = false
        if state.conn then pcall(function() state.conn:Disconnect() end) end
        state.conn = nil
        return "防甩飞已关闭"
    end
end

local function wasaiExecuteToolCall(tool, args)
    wasaiTrackToolCall()
    local ok, result = pcall(function()
        if tool == "list_children" then
            local path = tostring(args.path or "")
            local obj, err = wasaiGetInstanceFromPath(path)
            if not obj then return "路径不可达: " .. tostring(err) end
            wasaiChatMemory.lastPath = path
            local depth = tonumber(args.depth) or 1
            if depth < 1 then depth = 1 elseif depth > 3 then depth = 3 end
            local rows = wasaiListChildrenDepth(obj, depth)
            local shown = {}
            for i = 1, math.min(#rows, 80) do shown[i] = rows[i] end
            local text = table.concat(shown, "\n")
            if #rows > 80 then text = text .. "\n…共 " .. #rows .. " 行，仅显示前 80 行" end
            return text

        elseif tool == "decompile" then
            local path = tostring(args.path or "")
            local obj, err = wasaiGetInstanceFromPath(path)
            if not obj then return "路径不可达: " .. tostring(err) end
            wasaiChatMemory.lastPath = path
            local source, derr = wasaiTryDecompile(obj)
            if not source then return "反编译失败: " .. tostring(derr) end
            local savedPath = nil
            if writefile and makefolder and isfolder then
                local okSave, saveOk, savePath = pcall(wasaiSaveScriptToFile, obj, wasaiGetOutputDir(), nil)
                if okSave and saveOk then
                    savedPath = savePath
                    wasaiLastDecompileDir = wasaiGetOutputDir()
                end
            end
            local summary = "反编译成功，源码共 " .. #source .. " 字节。"
            if savedPath then summary = summary .. "已保存到: " .. tostring(savedPath) end
            return summary .. "\n源码开头预览:\n" .. source:sub(1, 2500)

        elseif tool == "decompile_all" then
            return tostring(wasaiDecompileAll("反编译所有脚本"))

        elseif tool == "decompile_smart" then
            local target = tostring(args.target or "")
            wasaiChatMemory.lastPath = target
            return tostring(wasaiDecompileSmart(target))

        elseif tool == "get_property" then
            local obj, err = wasaiGetInstanceFromPath(tostring(args.path or ""))
            if not obj then return "路径不可达: " .. tostring(err) end
            local prop = tostring(args.property or "")
            local okRead, value = pcall(function() return obj[prop] end)
            if not okRead then return "属性读取失败: " .. tostring(value) end
            return prop .. " = " .. tostring(value)

        elseif tool == "list_properties" then
            local obj, err = wasaiGetInstanceFromPath(tostring(args.path or ""))
            if not obj then return "路径不可达: " .. tostring(err) end
            local props = wasaiListAllProperties(obj)
            local shown = {}
            for i = 1, math.min(#props, 60) do shown[i] = props[i] end
            local text = table.concat(shown, "\n")
            if #props > 60 then text = text .. "\n…共 " .. #props .. " 项，仅显示前 60 项" end
            return text

        elseif tool == "execute_lua" then
            local code = tostring(args.code or "")
            if code == "" then return "未提供要执行的代码" end
            local cfg = loadConfig()
            if not cfg.autoAcceptExec then
                if not wasaiShowConfirmDialog(code) then
                    return "__PERMISSION_DENIED__"
                end
            else
                task.spawn(function()
                    local preview = code:gsub("%s+", " ")
                    if #preview > 40 then preview = preview:sub(1, 40) .. "…" end
                    pcall(function() ShowNotification("Agent 正在执行 Lua: " .. preview, 2.5) end)
                end)
            end
            local out, cerr = wasaiExecuteLuaCode(code)
            if not out then return "执行失败: " .. tostring(cerr) end
            return "执行成功: " .. out

        elseif tool == "find_objects" then
            local name = tostring(args.name or "")
            if name == "" then return "未提供搜索名称" end
            local matches = wasaiFindObjectsByName(name, game)
            if #matches == 0 then return "没有找到名称包含 " .. name .. " 的对象" end
            local shown = {}
            for i = 1, math.min(#matches, 40) do shown[i] = matches[i] end
            return "找到 " .. #matches .. " 个匹配:\n" .. table.concat(shown, "\n")

        elseif tool == "search_objects" then
            local name = tostring(args.name or "")
            if name == "" then return "未提供搜索名称" end
            local searchRoots = {}
            table.insert(searchRoots, {obj = workspace, name = "Workspace"})
            local lp = svc.Players.LocalPlayer
            if lp then
                local ps = lp:FindFirstChild("PlayerScripts")
                if ps then table.insert(searchRoots, {obj = ps, name = "PlayerScripts"}) end
            end
            table.insert(searchRoots, {obj = game:GetService("ReplicatedStorage"), name = "ReplicatedStorage"})
            table.insert(searchRoots, {obj = game:GetService("ServerScriptService"), name = "ServerScriptService"})
            local allMatches = {}
            for _, root in ipairs(searchRoots) do
                local found = wasaiFindObjectsByName(name, root.obj)
                for _, m in ipairs(found) do
                    table.insert(allMatches, m)
                end
            end
            if #allMatches == 0 then
                return "在 Workspace、PlayerScripts、ReplicatedStorage、ServerScriptService 中没有找到名称包含「" .. name .. "」的对象"
            end
            if #allMatches > 10 then
                local shown = {}
                for i = 1, 10 do shown[i] = allMatches[i] end
                local msg = "在 Workspace、PlayerScripts、ReplicatedStorage、ServerScriptService 中搜索「" .. name .. "」，共找到 " .. #allMatches .. " 个匹配对象：\n"
                msg = msg .. table.concat(shown, "\n")
                msg = msg .. "\n\n该名称对象太多了，需要我全部列出吗？"
                return msg
            end
            return "在 Workspace、PlayerScripts、ReplicatedStorage、ServerScriptService 中搜索「" .. name .. "」，共找到 " .. #allMatches .. " 个匹配对象：\n" .. table.concat(allMatches, "\n")

        elseif tool == "count_output_files" then
            return "输出目录共有 " .. tostring(wasaiCountOutputFiles()) .. " 个文件"

        elseif tool == "list_output_files" then
            local dir = wasaiGetOutputDir()
            local files = {}
            if isfolder and listfiles and isfile and isfolder(dir) then
                local function rec(p)
                    for _, f in ipairs(listfiles(p) or {}) do
                        if isfile(f) then table.insert(files, f)
                        elseif isfolder(f) then rec(f) end
                    end
                end
                rec(dir)
            end
            if #files == 0 then return "输出目录里还没有文件" end
            local shown = {}
            for i = 1, math.min(#files, 30) do shown[i] = files[i] end
            return "共 " .. #files .. " 个文件:\n" .. table.concat(shown, "\n")

        elseif tool == "delete_recent_files" then
            local okDel, deleted = wasaiDeleteRecentFiles()
            if okDel then return "已删除最近生成的文件，共清理 " .. tostring(deleted) .. " 个" end
            return "删除失败: " .. tostring(deleted)

        elseif tool == "noclip" then
            return wasaiSetNoclip(args.enabled ~= false)

        elseif tool == "anti_fling" then
            return wasaiSetAntiFling(args.enabled ~= false)

        elseif tool == "read_file" then
            local path = tostring(args.path or "")
            if path == "" then return "未提供文件路径" end
            if isfile and isfile(path) then
                local okR, content = pcall(readfile, path)
                if okR and content then
                    if #content > 6000 then content = content:sub(1, 6000) .. "\n…(内容过长已截断)" end
                    return content
                end
                return "读取失败: " .. tostring(content)
            end
            return "文件不存在: " .. path

        elseif tool == "report_progress" then
            local msg = wasaiSafeString(tostring(args.message or ""), 80)
            if msg ~= "" then
                wasaiThinkingPhase = msg
                wasaiCustomProgressMsg = msg
            end
            return "已向用户汇报进度: " .. msg
        end

        return "未知工具: " .. tostring(tool)
    end)
    if not ok then return "工具执行出错: " .. tostring(result) end
    return tostring(result)
end

-- 判断纯文本回复是否为“中间确认语”（模型仍要继续调工具/处理），而非最终答案
local function wasaiLooksIntermediate(content)
    content = tostring(content or "")
    local compact = content:gsub("%s+", "")
    if #compact == 0 then return false end
    if content:find("##", 1, true) then return false end
    local markers = {
        "我已了解", "已了解", "了解你的", "了解您", "尝试解决", "正在尝试",
        "让我", "我来帮你", "我来处理", "让我先", "让我来", "我先",
        "好的，我来", "好的，我先", "嗯，我来", "明白了", "收到", "知道了",
        "开始处理", "先来看", "我来实现", "让我看看", "我来看看", "我正在",
        "正在为你", "好的，我正在", "我看看", "让我来解决", "我来帮你实现",
        "让我搜索", "让我查找", "让我查看", "让我检查", "让我分析",
        "让我读取", "让我获取", "让我调用", "接下来", "紧接着",
        "让我换个", "让我尝试", "我可以试着", "由于我的工具", "让我看看有哪些",
        "我先来看", "让我先看", "我可以尝试", "让我接着", "我需要先",
    }
    for _, m in ipairs(markers) do
        if content:find(m, 1, true) then return true end
    end
    local lastChar = content:sub(-1)
    if lastChar == ":" or lastChar == "：" then
        return true
    end
    return false
end

local function wasaiGenerateResponseCore(input)
    local safeInput = tostring(input or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if safeInput == "" then
        return "请告诉我你想解决什么，我会结合当前对话和已有记忆来回答。", {}
    end

    local steps = {}
    local started = tick()

    local messages, context
    local okBuild, buildErr = pcall(function()
        messages, context = wasaiBuildLLMMessages(safeInput)
    end)
    if not okBuild then
        return "处理时遇到了内部异常，请重试一下。", {{phase = "error", output = tostring(buildErr)}}
    end
    table.insert(steps, {phase = "understand", output = "理解当前问题与多轮上下文"})
    table.insert(steps, {phase = "memory", output = "载入 " .. tostring(#(context.conversation or {})) .. " 条对话历史、" .. tostring(#(context.memories or {})) .. " 条相关长期记忆"})

    -- ===== DeepSeek API 工具链主循环 =====
    -- 模型可自主决定直接回答，或连续调用多个工具（list_children / decompile /
    -- execute_lua 等 12 个工具），每轮把工具结果以 tool 消息回填，直到给出最终答复。
    local maxIter = math.max(1, tonumber(wasaiLocalAIConfig.maxToolIterations) or 6)
    local finalAnswer = nil
    local toolCount = 0
    local apiFailed = false
    local apiError = nil

    for iter = 1, maxIter do
        if wasaiCustomProgressMsg ~= "" then
            wasaiThinkingPhase = wasaiCustomProgressMsg
        else
            wasaiThinkingPhase = "正在请求模型"
        end
        local content, toolCalls, apiErr = wasaiDeepSeekChat(messages, WASAI_DEEPSEEK_TOOLS)
        if apiErr then
            apiFailed = true
            apiError = apiErr
            break
        end

        wasaiLocalAIState.mode = "api"

        if toolCalls and #toolCalls > 0 then
            -- 先把模型返回的 assistant tool_calls 消息回填进历史，
            -- 再紧跟各 tool 角色的执行结果（OpenAI 协议要求 tool 消息必须挂在对应 tool_call 之后）
            local assistantToolCalls = {}
            for _, tc in ipairs(toolCalls) do
                local fnArgsJson = "{}"
                local hasArgs = false
                if type(tc.args) == "table" then
                    for _k in pairs(tc.args) do hasArgs = true break end
                end
                if hasArgs then
                    pcall(function()
                        fnArgsJson = svc.HttpService:JSONEncode(tc.args)
                    end)
                end
                assistantToolCalls[#assistantToolCalls + 1] = {
                    id = tc.id or ("call_" .. tostring(#assistantToolCalls + 1)),
                    type = "function",
                    ["function"] = {
                        name = tc.name or "",
                        arguments = fnArgsJson,
                    },
                }
            end
            table.insert(messages, {
                role = "assistant",
                content = (content and content ~= "") and content or nil,
                tool_calls = assistantToolCalls,
            })

            for _, tc in ipairs(toolCalls) do
                toolCount = toolCount + 1
                local toolName = tc.name or ""
                local toolArgs = tc.args or {}

                table.insert(steps, {phase = "tool", output = "模型自主决策调用工具: " .. toolName})
                wasaiThinkingPhase = "正在调用工具: " .. toolName
                local toolResult = wasaiSafeString(wasaiExecuteToolCall(toolName, toolArgs), 2500)

                wasaiLastToolOp.name = toolName
                wasaiLastToolOp.result = wasaiSafeString(toolResult, 500)
                wasaiLastToolOp.time = os.time()

                if toolResult == "__PERMISSION_DENIED__" then
                    local denyReplies = {
                        "执行权限被拒绝，我无法完成这个操作。",
                        "你没有授权执行这段代码，操作已取消。",
                        "代码执行请求未获批准，任务中止。",
                    }
                    local denyReply = denyReplies[math.random(#denyReplies)]
                    table.insert(steps, {phase = "execute", output = "用户拒绝了代码执行权限"})
                    pcall(function() wasaiSaveMemory(safeInput, denyReply) end)
                    wasaiLocalAIState.lastToolCalls = toolCount
                    wasaiLocalAIState.lastLatency = math.max(0, tick() - started)
                    return denyReply, steps
                end

                table.insert(steps, {phase = "execute", output = "工具 " .. toolName .. " 执行完成，结果 " .. #toolResult .. " 字符"})

                -- 工具结果以 tool 角色回填给模型（保持 tool_call_id 关联）
                table.insert(messages, {
                    role = "tool",
                    tool_call_id = tc.id or ("call_" .. tostring(toolCount)),
                    content = toolResult,
                })
            end
            -- 继续下一轮，让模型基于工具结果产出答复或继续调用工具
        else
            -- 无工具调用：若是“中间确认语”，回填文本并继续，让模型真正完成后续处理
            if wasaiLooksIntermediate(content) then
                table.insert(messages, {role = "assistant", content = content or ""})
                wasaiThinkingPhase = "继续处理中"
            else
                finalAnswer = (content and content ~= "") and content or "好的，我知道了。"
                break
            end
        end
    end

    if apiFailed then
        wasaiThinkingPhase = "API 不可用，正在重试"
        warn("[DeltaUI][AI] DeepSeek API 调用失败: " .. tostring(apiError))
        wasaiLocalAIState.lastError = apiError
        wasaiLocalAIState.failures = (wasaiLocalAIState.failures or 0) + 1
        wasaiLocalAIState.mode = "local"
        finalAnswer = "抱歉，当前无法连接到 AI 服务（" .. tostring(apiError) .. "）。请稍后重试。"
        table.insert(steps, {phase = "fallback", output = "API 不可用，已返回错误提示（" .. tostring(apiError) .. "）"})
    elseif not finalAnswer then
        wasaiThinkingPhase = "Agent正在输入…"
        wasaiLocalAIState.lastError = nil
        wasaiLocalAIState.failures = 0
        wasaiLocalAIState.mode = "api"
        local finalMessages = {}
        for _, m in ipairs(messages) do table.insert(finalMessages, m) end
        table.insert(finalMessages, {role = "user", content = "请基于以上所有工具执行结果，直接给出最终总结回答。不要再描述你接下来要做什么，直接输出结论。"})
        local content2, _, apiErr2 = wasaiDeepSeekChat(finalMessages, nil)
        if content2 and content2 ~= "" then
            finalAnswer = content2
        elseif toolCount > 0 then
            finalAnswer = "已执行 " .. toolCount .. " 次工具操作，结果请查看上方输出。如需继续，请直接告诉我。"
        else
            finalAnswer = "好的，我知道了。"
        end
        table.insert(steps, {phase = "generate", output = "工具循环后追加一次无工具请求以获取最终回复（" .. tostring(apiErr2 or "ok") .. "）"})
    else
        wasaiLocalAIState.lastError = nil
        wasaiLocalAIState.failures = 0
    end

    -- 兜底：无论来源（API 或本地回退），都不允许工具调用 JSON / DSML 泄漏到对话框
    if type(finalAnswer) == "string" then
        if finalAnswer:match("^%s*{") then
            local _t, _a = wasaiTryParseToolCall(finalAnswer)
            if _t then
                finalAnswer = "好的，已处理你的请求。" .. (toolCount > 0 and ("（调用了 " .. toolCount .. " 次工具）") or "")
            end
        end
        -- 只要还残留 DSML 标签/控制词，就彻底清理；清理后若只剩空白则兜底
        if finalAnswer:find("<[%s|]-DSML", 1) or finalAnswer:find('invoke%s+name="', 1)
           or finalAnswer:find('parameter%s+name="', 1) then
            local stripped = wasaiStripDSML(finalAnswer)
            -- 再补一道激进清理：移除任何 <...DSML...> 与散落的控制词
            stripped = stripped:gsub('<[^>]*DSML[^>]*>', '')
            stripped = stripped:gsub('%s*tool_calls', '')
            stripped = stripped:gsub('%s*[//]*[%s]*invoke%s*name="[^"]*"', '')
            stripped = stripped:gsub('%s*[//]*[%s]*parameter%s*name="[^"]*"', '')
            stripped = stripped:gsub('%s*[//][%s]*parameter', '')
            stripped = stripped:gsub('%s*[//][%s]*invoke', '')
            stripped = stripped:gsub('^%s+', ''):gsub('%s+$', '')
            if stripped == "" then
                finalAnswer = "好的，已处理你的请求。" .. (toolCount > 0 and ("（调用了 " .. toolCount .. " 次工具）") or "")
            else
                finalAnswer = stripped
            end
        end
    end

    wasaiLocalAIState.lastToolCalls = toolCount
    wasaiLocalAIState.available = true
    wasaiLocalAIState.lastLatency = math.max(0, tick() - started)
    table.insert(steps, {phase = "generate", output = "DeepSeek API 生成回复（共调用 " .. toolCount .. " 次工具，模式: " .. wasaiLocalAIState.mode .. "）"})

    pcall(function() wasaiSaveMemory(safeInput, finalAnswer) end)
    return finalAnswer, steps
end

local wasaiMainFrame = create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = true,
    Parent = wasaiPage,
    ZIndex = 3
})
wasaiResumeParent = wasaiMainFrame

local wasaiTitleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Parent = wasaiMainFrame,
    ZIndex = 4
})
corner(8, wasaiTitleBar)

local wasaiTitleLabel = create("TextLabel", {
    Name = "TitleLabel",
    Size = UDim2.new(1, -24, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "AgentLess",
    TextColor3 = theme.textDim,
    Font = Enum.Font.SourceSansBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    Parent = wasaiTitleBar,
    ZIndex = 5
})

-- 右上角「对话管理」切换按钮
local wasaiManageMode = false
local wasaiManageButton = create("TextButton", {
    Name = "ManageButton",
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -30, 0.5, -12),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Text = "",
    Parent = wasaiTitleBar,
    ZIndex = 6
})
corner(6, wasaiManageButton)
local wasaiManageIcon = GetIcon("message-circle-reply", UDim2.new(0, 16, 0, 16))
if wasaiManageIcon then
    wasaiManageIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    wasaiManageIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    wasaiManageIcon.Parent = wasaiManageButton
end

local wasaiDivider = create("Frame", {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 0, 30),
    BackgroundColor3 = theme.border,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Parent = wasaiMainFrame,
    ZIndex = 4
})

wasaiMessageFrame = create("ScrollingFrame", {
    Name = "MessageFrame",
    Size = UDim2.new(1, -20, 1, -30 - 56 - 8),
    Position = UDim2.new(0, 10, 0, 34),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.textDim,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = wasaiMainFrame,
    ZIndex = 3
})

local wasaiMessageListLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 6),
    Parent = wasaiMessageFrame
})

local wasaiMessagePadding = create("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    Parent = wasaiMessageFrame
})

wasaiMessageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if wasaiMessageFrame and wasaiMessageFrame.Parent then
        wasaiMessageFrame.CanvasSize = UDim2.new(0, 0, 0, wasaiMessageListLayout.AbsoluteContentSize.Y + 12)
    end
end)

local wasaiInputFrame = create("Frame", {
    Name = "InputFrame",
    Size = UDim2.new(1, -20, 0, 44),
    Position = UDim2.new(0, 10, 1, -54),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Parent = wasaiMainFrame,
    ZIndex = 4
})
corner(12, wasaiInputFrame)

wasaiInputBox = create("TextBox", {
    Name = "InputBox",
    Size = UDim2.new(1, -70, 1, -8),
    Position = UDim2.new(0, 8, 0, 4),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.3,
    BorderColor3 = theme.border,
    BorderSizePixel = 1,
    TextColor3 = theme.text,
    PlaceholderText = "输入问题、指令或闲聊...",
    PlaceholderColor3 = theme.textDim,
    Font = Enum.Font.SourceSans,
    TextSize = 14,
    ClearTextOnFocus = false,
    Text = "",
    Parent = wasaiInputFrame,
    ZIndex = 5
})
corner(20, wasaiInputBox)
create("UIPadding", {PaddingLeft = UDim.new(0, 12)}).Parent = wasaiInputBox
wasaiInputBox.Focused:Connect(function()
    if wasaiInputBox.Text == "" then
        wasaiInputBox.PlaceholderText = "输入问题、指令或闲聊..."
    end
end)
wasaiInputBox.FocusLost:Connect(function()
    if wasaiInputBox.Text == "" then
        wasaiInputBox.PlaceholderText = "输入问题、指令或闲聊..."
    end
end)

wasaiSendButton = create("TextButton", {
    Name = "SendButton",
    Size = UDim2.new(0, 52, 0, 32),
    Position = UDim2.new(1, -58, 0.5, -16),
    BackgroundColor3 = theme.accent,
    Text = "发送",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.SourceSansBold,
    BorderSizePixel = 0,
    Parent = wasaiInputFrame,
    ZIndex = 5
})
corner(16, wasaiSendButton)

-- ===== 对话管理视图 =====
local wasaiManageFrame = create("ScrollingFrame", {
    Name = "ManageFrame",
    Size = UDim2.new(1, -20, 1, -30 - 56 - 8),
    Position = UDim2.new(0, 10, 0, 34),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.textDim,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Visible = false,
    Parent = wasaiMainFrame,
    ZIndex = 3
})
local wasaiManageLayout = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 8),
    Parent = wasaiManageFrame
})
create("UIPadding", {
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    Parent = wasaiManageFrame
})
wasaiManageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if wasaiManageFrame and wasaiManageFrame.Parent then
        wasaiManageFrame.CanvasSize = UDim2.new(0, 0, 0, wasaiManageLayout.AbsoluteContentSize.Y + 12)
    end
end)

-- 前向声明（存在相互引用）
local wasaiRefreshConversationList
local wasaiSetManageMode

-- 载入指定对话到当前会话
local function wasaiLoadConversationEntry(entry)
    local ok = wasaiLoadChatHistory({path = entry.path, chatFile = entry.file, name = entry.name})
    if not ok then return end
    wasaiCurrentSession.isFirstRound = false
    for _, child in ipairs(wasaiMessageFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "MessageContainer" then child:Destroy() end
    end
    local history = wasaiChatMemory.conversationHistory or {}
    for _, msg in ipairs(history) do
        wasaiAddMessage(msg.content, msg.role == "user")
        task.wait(0.04)
    end
end

-- 刷新对话列表
wasaiRefreshConversationList = function()
    for _, child in ipairs(wasaiManageFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local entries = wasaiListAllChats()
    if #entries == 0 then
        local empty = create("Frame", {
            Name = "EmptyRow",
            Size = UDim2.new(1, -16, 0, 90),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = wasaiManageFrame
        })
        create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "暂无已保存的对话",
            TextColor3 = theme.textDim,
            TextSize = 13,
            Font = Enum.Font.SourceSans,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = empty
        })
        return
    end
    for _, e in ipairs(entries) do
        local row = create("Frame", {
            Name = "ManageRow",
            Size = UDim2.new(1, -6, 0, 64),
            BackgroundColor3 = theme.surface,
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Parent = wasaiManageFrame
        })
        corner(10, row)
        stroke(theme.border, 1, row)
        local folderIcon = GetIcon("folder", UDim2.new(0, 28, 0, 28))
        if folderIcon then
            folderIcon.AnchorPoint = Vector2.new(0, 0.5)
            folderIcon.Position = UDim2.new(0, 14, 0.5, 0)
            folderIcon.Parent = row
        end
        local titleLbl = create("TextLabel", {
            Size = UDim2.new(1, -140, 0, 22),
            Position = UDim2.new(0, 50, 0, 8),
            BackgroundTransparency = 1,
            Text = wasaiSafeString(e.title, 26),
            TextColor3 = theme.text,
            TextSize = 14,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row
        })
        local timeStr = "未知时间"
        if e.time and e.time > 0 then
            local okDate, date = pcall(os.date, "%Y-%m-%d %H:%M", e.time)
            if okDate and date then timeStr = date end
        end
        create("TextLabel", {
            Size = UDim2.new(1, -140, 0, 18),
            Position = UDim2.new(0, 50, 0, 32),
            BackgroundTransparency = 1,
            Text = timeStr .. (e.count > 0 and (" · " .. e.count .. " 条") or ""),
            TextColor3 = theme.textDim,
            TextSize = 11,
            Font = Enum.Font.SourceSans,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row
        })
        local deleteBtn = create("TextButton", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -36, 0.5, -15),
            BackgroundColor3 = theme.surfaceLight,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 5,
            Parent = row
        })
        corner(8, deleteBtn)
        local delIcon = GetIcon("trash-2", UDim2.new(0, 16, 0, 16))
        if delIcon then delIcon.AnchorPoint = Vector2.new(0.5, 0.5); delIcon.Position = UDim2.new(0.5, 0, 0.5, 0); delIcon.Parent = deleteBtn end
        deleteBtn.MouseButton1Click:Connect(function()
            pcall(delfile, e.file)
            wasaiRefreshConversationList()
        end)

        local loadBtn = create("TextButton", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -74, 0.5, -15),
            BackgroundColor3 = theme.accent,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Text = "",
            ZIndex = 5,
            Parent = row
        })
        corner(8, loadBtn)
        local loadIcon = GetIcon("database-arrow-down", UDim2.new(0, 16, 0, 16))
        if loadIcon then loadIcon.AnchorPoint = Vector2.new(0.5, 0.5); loadIcon.Position = UDim2.new(0.5, 0, 0.5, 0); loadIcon.Parent = loadBtn end
        loadBtn.MouseButton1Click:Connect(function()
            wasaiLoadConversationEntry(e)
            wasaiSetManageMode(false)
        end)
    end
end

-- 切换对话管理视图
wasaiSetManageMode = function(on)
    wasaiManageMode = on
    wasaiManageFrame.Visible = on
    wasaiMessageFrame.Visible = not on
    wasaiInputFrame.Visible = not on
    wasaiManageButton.BackgroundColor3 = on and theme.accent or theme.surfaceLight
    wasaiTitleLabel.Text = on and "对话管理" or "AgentLess"
    if on then wasaiRefreshConversationList() end
end

wasaiManageButton.MouseButton1Click:Connect(function()
    wasaiSetManageMode(not wasaiManageMode)
end)

wasaiFinalizeMessage = function(container, isUser)
    local avatar = container:FindFirstChild("Avatar")
    local bubble = container:FindFirstChild("Bubble")
    if not avatar or not bubble then return end
    task.defer(function()
        local frameW = wasaiMessageFrame.AbsoluteSize.X
        local maxWidth = math.min(400, math.max(160, frameW * 0.7))
        if bubble.AbsoluteSize.X > maxWidth then
            local label = bubble:FindFirstChild("TextLabel")
            if label then
                label.Size = UDim2.new(0, maxWidth - 24, 0, 0)
                label.AutomaticSize = Enum.AutomaticSize.Y
            end
        end
        if isUser then
            avatar.AnchorPoint = Vector2.new(1, 0)
            avatar.Position = UDim2.new(1, -8, 0, 0)
            bubble.AnchorPoint = Vector2.new(1, 0)
            bubble.Position = UDim2.new(1, -52, 0, 0)
        else
            avatar.AnchorPoint = Vector2.new(0, 0)
            avatar.Position = UDim2.new(0, 8, 0, 0)
            bubble.AnchorPoint = Vector2.new(0, 0)
            bubble.Position = UDim2.new(0, 52, 0, 0)
        end
        task.defer(function()
            wasaiMessageFrame.CanvasPosition = Vector2.new(0, wasaiMessageFrame.CanvasSize.Y.Offset)
        end)
    end)
end

-- 转义富文本特殊字符，防止 AI 输出中的 < > & 被当作标记解析
local function wasaiEscapeRich(s)
    s = tostring(s or "")
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    return s
end

-- 将 **粗体** 与 __下划线__/单下划线 _文字_ 语法转为富文本（仅对 AI 消息启用）
-- 单下划线仅在有边界时生效，避免误伤代码标识符（如 _HookClick）
local function wasaiRenderAI(text)
    local s = wasaiEscapeRich(text)
    s = " " .. s .. " "   -- 前后补空格，使开/结尾的下划线也有边界
    s = s:gsub("%*%*(.-)%*%*", "<b>%1</b>")            -- **粗体**
    s = s:gsub("__(.-)__", "<u>%1</u>")                -- __下划线__
    s = s:gsub("([^%w_])_([^_]+)_([^%w_])", "%1<u>%2</u>%3")  -- 单词边界单下划线
    s = s:gsub("^%s+", ""):gsub("%s+$", "")            -- 去掉补的空格
    return s
end

function wasaiAddMessage(text, isUser, stats)
    local container, bubble = wasaiCreateMessageContainer(text, isUser)
    local label = create("TextLabel", {
        Name = "TextLabel",
        BackgroundTransparency = 1,
        Text = isUser and text or wasaiRenderAI(text),
        TextColor3 = isUser and Color3.new(1, 1, 1) or theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextWrapped = true,
        RichText = not isUser,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
        Parent = bubble,
        ZIndex = 4
    })
    local textPadding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),

        PaddingTop = UDim.new(0, (not isUser and stats) and 14 or (not isUser and 8 or 6)),
        PaddingBottom = UDim.new(0, not isUser and 8 or 6),
        Parent = label
    })

    if not isUser and stats then
        local statsLabel = create("TextLabel", {
            Name = "StatsLabel",
            BackgroundTransparency = 1,
            Text = stats,
            TextColor3 = Color3.fromRGB(120, 120, 130),
            Font = Enum.Font.SourceSans,
            TextSize = 10,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 1.5),
            Parent = bubble,
            ZIndex = 4
        })
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 8),
            Parent = statsLabel
        })
    end

    wasaiFinalizeMessage(container, isUser)
    return container
end

wasaiTypewriteMessage = function(text, isUser, stats)
    if isUser then return wasaiAddMessage(text, true) end
    local container, bubble = wasaiCreateMessageContainer("", false)

    local label = create("TextLabel", {
        Name = "TextLabel",
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = theme.text,
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextWrapped = true,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Parent = bubble,
        ZIndex = 4
    })
    local textPadding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),

        PaddingTop = UDim.new(0, (stats and 14) or 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = label
    })

        local cursor = create("Frame", {
        Name = "Cursor",
        Size = UDim2.new(0, 2, 0, 16),
        BackgroundColor3 = theme.accent,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = bubble,
        Visible = false
    })
    corner(1, cursor)

        -- 打字期间使用转义文本（RichText 下安全）；完成后统一替换为带 **粗体** 的富文本
        local fullText = wasaiEscapeRich(text)
    local displayedText = ""
    local charIndex = 1
    local totalChars = #fullText

    local baseDelay = 0.018

        local cursorBlinking = true
    local cursorConn = nil
    local function startCursorBlink()
        cursorBlinking = true
        cursor.Visible = true
        local blinkState = true
        cursorConn = task.spawn(function()
            while cursorBlinking do
                blinkState = not blinkState
                cursor.BackgroundTransparency = blinkState and 0.7 or 0
                task.wait(0.35)
            end
            cursor.Visible = false
        end)
    end

    local function stopCursorBlink()
        cursorBlinking = false
        if cursorConn then
            pcall(function() task.cancel(cursorConn) end)
        end
        cursor.Visible = false
    end

    if stats then
        local statsLabel = create("TextLabel", {
            Name = "StatsLabel",
            BackgroundTransparency = 1,
            Text = stats,
            TextColor3 = Color3.fromRGB(120, 120, 130),
            Font = Enum.Font.SourceSans,
            TextSize = 10,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 1.5),
            Parent = bubble,
            ZIndex = 4
        })
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 8),
            Parent = statsLabel
        })
    end

    startCursorBlink()

    local chars = {}
    if utf8 and utf8.codes then
        local ok, iter = pcall(function()
            local result = {}
            for _, cp in utf8.codes(fullText) do
                result[#result + 1] = utf8.char(cp)
            end
            return result
        end)
        if ok and iter then
            chars = iter
        else
            local bi = 1
            while bi <= #fullText do
                local b = fullText:byte(bi)
                local len = 1
                if b >= 240 then len = 4
                elseif b >= 224 then len = 3
                elseif b >= 192 then len = 2 end
                table.insert(chars, fullText:sub(bi, math.min(bi + len - 1, #fullText)))
                bi = bi + len
            end
        end
    else
        local bi = 1
        while bi <= #fullText do
            local b = fullText:byte(bi)
            local len = 1
            if b >= 240 then len = 4
            elseif b >= 224 then len = 3
            elseif b >= 192 then len = 2 end
            table.insert(chars, fullText:sub(bi, math.min(bi + len - 1, #fullText)))
            bi = bi + len
        end
    end
    local charCount = #chars

    local segments = {}
    local currentSeg = {}
    local segLen = 0
    for idx = 1, charCount do
        local c = chars[idx]
        table.insert(currentSeg, c)
        segLen = segLen + 1
        if c:match("[。！？.!?]") or c == "\n" or c == "\r" or segLen >= 10 then
            table.insert(segments, currentSeg)
            currentSeg = {}
            segLen = 0
        end
    end
    if #currentSeg > 0 then
        table.insert(segments, currentSeg)
    end

    if #segments < 5 and charCount > 300 then
        segments = {}
        local chunkSize = math.max(10, math.floor(charCount / 15))
        for i = 1, charCount, chunkSize do
            local seg = {}
            for j = i, math.min(i + chunkSize - 1, charCount) do
                table.insert(seg, chars[j])
            end
            table.insert(segments, seg)
        end
    end

    local displayParts = {}
    local displayLen = 0
    for _, seg in ipairs(segments) do
        for _, char in ipairs(seg) do
            displayLen = displayLen + 1
            displayParts[displayLen] = char
            displayedText = table.concat(displayParts, nil, 1, displayLen)
            label.Text = displayedText

            local textBounds = label.TextBounds
            local topPad = (stats and 14) or 8
            cursor.Position = UDim2.new(0, textBounds.X + 12, 0, topPad + textBounds.Y - 14)

            local delay = baseDelay
            if char:match("[。！？.!?]") then
                delay = delay * 2
            elseif char:match("[，,;；：:]") then
                delay = delay * 1.2
            elseif char == " " then
                delay = delay * 0.5
            else
                delay = delay * (0.8 + math.random() * 0.4)
            end
            task.wait(delay)
        end
        task.defer(function()
            wasaiMessageFrame.CanvasPosition = Vector2.new(0, wasaiMessageFrame.CanvasSize.Y.Offset)
        end)
    end
    stopCursorBlink()

    -- 打字完成后应用 **粗体** 富文本
    pcall(function()
        label.Text = wasaiRenderAI(text)
    end)

    wasaiFinalizeMessage(container, false)
    return container
end

local function wasaiShowDecompileResult(fullPath, source)
    local container, bubble = wasaiCreateMessageContainer("", false, theme.surfaceLight)
    local displayName = fullPath:match("([^/]+)$") or fullPath
    local button = create("TextButton", {
        Name = "CopyButton",
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = theme.accent,
        Font = Enum.Font.SourceSansBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
        Parent = bubble,
        ZIndex = 4
    })

    local hint = create("TextLabel", {
        Name = "Hint",
        BackgroundTransparency = 1,
        Text = "（点击复制完整源码）",
        TextColor3 = theme.textDim,
        Font = Enum.Font.SourceSans,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.new(0, 0, 0, 0),
        Parent = bubble,
        ZIndex = 4
    })

    local padding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = bubble
    })

    local layout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 2),
        Parent = bubble
    })

    button.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(source)
            button.Text = displayName .. " ✅ 已复制"
                        local notifyReplies = {
                "源码已复制到剪贴板！",
                "复制成功，去粘贴吧～",
                "已复制，记得保存好哦",
                "剪贴板已收到源码！",
                "复制完成！可以去编辑器里粘贴了",
            }
            ShowNotification(notifyReplies[math.random(#notifyReplies)], 1.5)
            task.delay(2, function()
                button.Text = displayName
            end)
        else
            button.Text = displayName .. " ❌ 剪贴板不可用"
            ShowNotification("剪贴板 API 不可用，无法复制", 2)
        end
    end)

    wasaiFinalizeMessage(container, false)
    return container
end


function wasaiGenerateResponse(userInput)
    local input = tostring(userInput or "")
    if input:match("^%s*$") then return nil end

    if wasaiCheckSensitive(input) then
        return "针对这个问题我无法为你提供相应解答。你可以尝试提供其他话题，我会尽力为你提供支持和解答。", {
            {phase = "safety", output = "检测到敏感内容，已拒绝并引导到其他话题"}
        }
    end

    -- 所有输入统一交给语言模型真实推理
    local ok, reply, steps = pcall(wasaiGenerateResponseCore, input)
    if ok and reply and tostring(reply) ~= "" then
        return reply, steps or {}
    end

    local errText
    if ok then
        errText = "模型未返回有效回答"
    else
        errText = tostring(reply or "未知错误")
    end
    local errReplies = {
        "抱歉，处理时出现了问题：" .. errText .. "，可以重试一下。",
        "出了点状况：" .. errText .. "，换个说法试试？",
        "处理遇到障碍：" .. errText .. "，请稍后再试。",
    }
    return errReplies[math.random(#errReplies)], {
        {phase = "error", output = errText}
    }
end

local wasaiShowThinkingBubble
local wasaiRemoveThinkingBubble

do
    local currentThinkingContainer = nil
    local currentThinkingThread = nil

    wasaiShowThinkingBubble = function()
        wasaiRemoveThinkingBubble()
        local container, bubble = wasaiCreateMessageContainer("", false)
        currentThinkingContainer = container

        local label = create("TextLabel", {
            Name = "TextLabel",
            BackgroundTransparency = 1,
            Text = "仍在思考(0.00秒)...",
            TextColor3 = theme.textDim or Color3.fromRGB(140, 140, 150),
            Font = Enum.Font.SourceSansItalic,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Parent = bubble,
            ZIndex = 4
        })
        create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            Parent = label
        })

        wasaiFinalizeMessage(container, false)

        local startTime = tick()
        currentThinkingThread = task.spawn(function()
            while currentThinkingContainer == container do
                local elapsed = tick() - startTime
                local timeStr = string.format("%.2f", elapsed)
                local phase = wasaiThinkingPhase or ""
                local text
                if phase ~= "" then
                    local suffix = phase:sub(-1) == "…" and "" or "..."
                    text = "仍在思考(" .. timeStr .. "秒) · " .. phase .. suffix
                else
                    text = "仍在思考(" .. timeStr .. "秒)..."
                end
                local ok = pcall(function()
                    label.Text = text
                end)
                if not ok then break end
                pcall(function()
                    wasaiMessageFrame.CanvasPosition = Vector2.new(0, wasaiMessageFrame.CanvasSize.Y.Offset)
                end)
                task.wait(0.05)
            end
        end)

        return container
    end

    wasaiRemoveThinkingBubble = function()
        wasaiThinkingPhase = ""
        wasaiCustomProgressMsg = ""
        if currentThinkingThread then
            pcall(function() task.cancel(currentThinkingThread) end)
            currentThinkingThread = nil
        end
        if currentThinkingContainer then
            pcall(function() currentThinkingContainer:Destroy() end)
            currentThinkingContainer = nil
        end
    end
end

-- Safe task.spawn wrapper: captures errors and logs them
local function wasaiSafeSpawn(fn, ...)
    local args = {...}
    return task.spawn(function()
        local ok, err = pcall(fn, unpack(args))
        if not ok then
            warn("[DeltaUI Agent] task.spawn error: " .. tostring(err))
        end
    end)
end

wasaiSendMessage = function()
    local text = wasaiInputBox.Text
    if not text or text:match("^%s*$") then return end

        if text:match("^[加恢][载复]") and wasaiCurrentSession.isFirstRound then
        local latest = wasaiFindLatestChat()
        if latest and wasaiLoadChatHistory(latest) then
            wasaiInputBox.Text = ""
            wasaiAddMessage("加载", true)
                        for _, child in ipairs(wasaiMessageFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name == "MessageContainer" then
                    child:Destroy()
                end
            end
                        wasaiSafeSpawn(function()
                wasaiAddMessage("已恢复上次对话", false)
                if wasaiChatMemory.conversationHistory then
                    for i, msg in ipairs(wasaiChatMemory.conversationHistory) do
                        if i <= 20 then wasaiAddMessage(msg.content, msg.role == "user")
                        end
                    end
                end
                task.wait(0.5)
                local title = latest.name:gsub("^对话_", "")
                wasaiAddMessage("对话已加载: " .. title, false)
            end)
            return
        else
            wasaiInputBox.Text = ""
            wasaiAddMessage(text, true)
            wasaiSafeSpawn(function()
                task.wait(0.3)
                wasaiAddMessage("没有找到可恢复的历史对话", false)
            end)
            return
        end
    end

        wasaiResetMetrics()
    wasaiStartTiming()

    wasaiInputBox.Text = ""
    wasaiAddMessage(text, true)

        if wasaiCurrentSession.isFirstRound then
        local title = wasaiGenerateTitle(text)
        wasaiCurrentSession.sessionTitle = title
                wasaiInitSessionDir()
        wasaiRenameSessionDir(title)
        wasaiCurrentSession.isFirstRound = false
    end

        if not wasaiChatMemory.conversationHistory then
        wasaiChatMemory.conversationHistory = {}
    end
    table.insert(wasaiChatMemory.conversationHistory, {
        role = "user",
        content = text,
        timestamp = os.time()
    })

        local maxHist = tonumber(wasaiLocalAIConfig.maxHistoryMessages) or 20
        if #wasaiChatMemory.conversationHistory > maxHist then
            table.remove(wasaiChatMemory.conversationHistory, 1)
        end

    wasaiSafeSpawn(function()

        wasaiShowThinkingBubble()

        local okReply, reply = pcall(wasaiGenerateResponse, text)
        if not okReply or not reply or reply == "" then
            local errFallbacks = {
                "抱歉，处理时出现了问题，请稍后重试。",
                "出了点小状况，换个方式再试试？",
                "处理遇到异常，请重试或换个说法。",
            }
            reply = errFallbacks[math.random(#errFallbacks)]
        end

        if reply then
                            table.insert(wasaiChatMemory.conversationHistory, {
                role = "assistant",
                content = tostring(reply),
                timestamp = os.time()
            })

            -- 实际等待：补足思考时间
            local elapsed = wasaiMetrics.thinkingStartTime > 0 and (tick() - wasaiMetrics.thinkingStartTime) or 0
            local complexity = wasaiMetrics.toolCalls * 0.8 + wasaiMetrics.fileOperations * 0.4
            local target = math.max(1.5, 1.5 + math.min(complexity, 3.0))
            if elapsed < target then
                task.wait(target - elapsed)
            end

            wasaiRemoveThinkingBubble()

            local statsText = wasaiGenerateStatsText(true)

                            wasaiSaveChatHistory()
            wasaiSaveMemory(text, tostring(reply))

            if type(reply) == "table" and reply.__type == "decompile" then
                wasaiShowDecompileResult(reply.filename, reply.source)
            elseif type(reply) == "table" and reply.__type == "script" then
                wasaiShowScriptResult(reply.title, reply.source)
            else
                local replyStr = tostring(reply)
                -- 若回复中含 ##代码## 标记，则分段渲染：普通文字 + 带复制按钮的代码框
                local usedCode = wasaiRenderMessageWithCode(replyStr, statsText)
                if not usedCode then
                    wasaiTypewriteMessage(replyStr, false, statsText)
                end
            end
        end
    end)
end
end

wasaiSendButton.MouseButton1Click:Connect(wasaiSendMessage)
wasaiInputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then wasaiSendMessage() end
end)

pages["atom"] = wasaiPage

local scriptbloxScroll = create("ScrollingFrame", {Position = UDim2.new(0, 12, 0, 52), Size = UDim2.new(1, -24, 1, -64), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = theme.textDim, CanvasSize = UDim2.new(0, 0, 0, 0), ClipsDescendants = true, ZIndex = 3})
scriptbloxScroll.Parent = cloudPage
scriptbloxScroll.Visible = true
local scriptbloxGrid = create("UIGridLayout", {CellSize = UDim2.new(0, 365, 0, 160), CellPadding = UDim2.new(0, 10, 0, 10), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Top, FillDirection = Enum.FillDirection.Horizontal})
scriptbloxGrid.Parent = scriptbloxScroll
scriptbloxGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if scriptbloxScroll and scriptbloxGrid and scriptbloxScroll.Parent then
        local absSize = scriptbloxGrid.AbsoluteContentSize
        if absSize then
            scriptbloxScroll.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 16)
        end
    end
end)

function fetchScriptBloxScripts(searchQuery)
    local HttpService = svc.HttpService
    local base = "https://scriptblox.com/api/script/search"
    local params = "?max=20&sortBy=likeCount&order=desc"
    if searchQuery and searchQuery ~= "" then
        local encoded = searchQuery
        local okEnc, encResult = pcall(function()
            return HttpService:UrlEncode(searchQuery)
        end)
        if okEnc and encResult then
            encoded = encResult
        else
            encoded = ""
            for i = 1, #searchQuery do
                local c = searchQuery:sub(i, i)
                if c == " " then
                    encoded = encoded .. "+"
                else
                    local b = string.byte(c)
                    if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or c == "-" or c == "." or c == "_" or c == "~" then
                        encoded = encoded .. c
                    else
                        encoded = encoded .. string.format("%%%02X", b)
                    end
                end
            end
        end
        params = params .. "&q=" .. encoded
    else
        params = params .. "&q=popular"
    end
    local url = base .. params
    local raw = nil
    local ok1, result1 = pcall(function()
        return requestWithUA(url)
    end)
    if ok1 and result1 and result1 ~= "" then
        raw = result1
    else
        local ok2, result2 = pcall(function()
            return game:HttpGet(url)
        end)
        if ok2 and result2 and result2 ~= "" then
            raw = result2
        end
    end
    if not raw or raw == "" then
        return nil
    end
    local ok3, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok3 or not data or not data.result or not data.result.scripts then
        return nil
    end
    return data.result.scripts
end

function fetchScriptBloxRaw(scriptId)
    local url = "https://scriptblox.com/api/script/raw/" .. tostring(scriptId)
    local raw = nil
    local ok1, result1 = pcall(function()
        return requestWithUA(url)
    end)
    if ok1 and result1 and result1 ~= "" then
        raw = result1
    else
        local ok2, result2 = pcall(function()
            return game:HttpGet(url)
        end)
        if ok2 and result2 and result2 ~= "" then
            raw = result2
        end
    end
    return raw
end

local scriptbloxSelectedScript = nil
local scriptbloxOptionOverlay = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, BorderSizePixel = 0, Visible = false, ZIndex = 400, Active = true})
scriptbloxOptionOverlay.Parent = screenGui
local scriptbloxOptionCard = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 320, 0, 330), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 401, Active = true})
corner(16, scriptbloxOptionCard)
scriptbloxOptionCard.Parent = scriptbloxOptionOverlay

local scriptbloxOptionTitle = create("TextLabel", {Position = UDim2.new(0, 20, 0, 16), Size = UDim2.new(1, -40, 0, 28), BackgroundTransparency = 1, Text = t("select_option"), TextColor3 = theme.text, TextSize = 18, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 402})
scriptbloxOptionTitle.Parent = scriptbloxOptionCard
local scriptbloxOptionSub = create("TextLabel", {Position = UDim2.new(0, 20, 0, 46), Size = UDim2.new(1, -40, 0, 40), BackgroundTransparency = 1, Text = t("select_option_desc"), TextColor3 = theme.textDim, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 402})
scriptbloxOptionSub.Parent = scriptbloxOptionCard

local scriptbloxOptionClose = create("TextButton", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 1, Text = "", ZIndex = 403})
local scriptbloxCloseIcon = GetIcon("x", UDim2.new(0, 18, 0, 18), theme.textDim)
if scriptbloxCloseIcon then
    scriptbloxCloseIcon.Position = UDim2.new(0.5, -9, 0.5, -9)
    scriptbloxCloseIcon.Parent = scriptbloxOptionClose
end
scriptbloxOptionClose.Parent = scriptbloxOptionCard
scriptbloxOptionClose.MouseButton1Click:Connect(function()
    scriptbloxOptionOverlay.Visible = false
end)

function makeScriptBloxOptionBtn(text, iconName, color, posY, callback)
    local btn = create("TextButton", {Position = UDim2.new(0, 20, 0, posY), Size = UDim2.new(1, -40, 0, 48), BackgroundColor3 = color or theme.surfaceLight, BackgroundTransparency = 0.3, Text = "", BorderSizePixel = 0, ZIndex = 402, Active = true})
    corner(12, btn)
    local icon = GetIcon(iconName, UDim2.new(0, 18, 0, 18), Color3.fromRGB(255,255,255))
    if icon then
        icon.Position = UDim2.new(0, 14, 0.5, -9)
        icon.Parent = btn
    end
    local txt = create("TextLabel", {Position = UDim2.new(0, 42, 0, 0), Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 403})
    txt.Parent = btn
    btn.Parent = scriptbloxOptionCard
    btn.MouseButton1Click:Connect(function()
        if not btn.Active then return end
        btn.Active = false
        scriptbloxOptionOverlay.Visible = false
        task.spawn(function()
            callback()
            btn.Active = true
        end)
    end)
    return btn
end

makeScriptBloxOptionBtn(t("execute_selected"), "play", theme.accent, 85, function()
    if not scriptbloxSelectedScript then return end
    local raw = fetchScriptBloxRaw(scriptbloxSelectedScript._id)
    if raw and raw ~= "" then
        cleanupOldUI()
        AddLog("> Executing ScriptBlox script: " .. scriptbloxSelectedScript.title, "info")
        local fn, err = loadstring(raw)
        if not fn then
            local errLine = parseErrorLine(tostring(err))
            if errLine then
                jumpToErrorLine(errLine)
            end
            AddLog("[Error] " .. tostring(err), "error")
            ShowNotification(t("execution_error_notify"), 3, function()
                switchPage("terminal")
            end)
            return
        end
        local oldPrint = print
        local oldWarn = warn
        print = function(...)
            local args = {...}
            local msg = table.concat(args, " ")
            AddLog(msg, "info")
            if logDedup then logDedup[msg] = tick() end
            _G.__DeltaUI_blockLogService = true
            oldPrint(...)
            _G.__DeltaUI_blockLogService = nil
        end
        warn = function(...)
            local args = {...}
            local msg = table.concat(args, " ")
            AddLog(msg, "warn")
            if logDedup then logDedup[msg] = tick() end
            _G.__DeltaUI_blockLogService = true
            oldWarn(...)
            _G.__DeltaUI_blockLogService = nil
        end
        _G.__DeltaUI_blockLogService = true
        local ok, execErr = xpcall(fn, function(err)
            return debug.traceback(tostring(err), 2)
        end)
        _G.__DeltaUI_blockLogService = nil
        print = oldPrint
        warn = oldWarn
        if not ok then
            AddLog("[Error] " .. tostring(execErr), "error")
        end
        AddLog("> Execution finished", "info")
    else
        ShowNotification(t("fetch_failed"), 2)
    end
end)

makeScriptBloxOptionBtn(t("open_in_editor"), "file-pen", theme.surfaceLight, 143, function()
    if not scriptbloxSelectedScript then return end
    local raw = fetchScriptBloxRaw(scriptbloxSelectedScript._id)
    if raw and raw ~= "" then
        saveCurrentTab()
        local name = "SB: " .. (scriptbloxSelectedScript.title or "Untitled")
        table.insert(tabs, {name = name, content = raw})
        currentTab = #tabs
        currentCodePage = 1
        codePageBreaks = {}
        showCurrentPage()
        renderTabs()
        switchPage("house")
        ShowNotification(t("opened_editor"), 1)
    else
        ShowNotification(t("fetch_failed"), 2)
    end
end)

makeScriptBloxOptionBtn(t("save_selected"), "save", theme.surfaceLight, 201, function()
    if not scriptbloxSelectedScript then return end
    local raw = fetchScriptBloxRaw(scriptbloxSelectedScript._id)
    if raw and raw ~= "" then
        ensureFolder()
        local title = scriptbloxSelectedScript.title or "Untitled"
        writefile(saveFolder .. "/" .. title, raw)
        refreshScriptList(searchInput.Text)
        ShowNotification(t("script_saved"), 1)
    else
        ShowNotification(t("fetch_failed"), 2)
    end
end)

makeScriptBloxOptionBtn(t("copy_to_clipboard"), "clipboard", theme.surfaceLight, 259, function()
    if not scriptbloxSelectedScript then return end
    local raw = fetchScriptBloxRaw(scriptbloxSelectedScript._id)
    if raw and raw ~= "" then
        local setclip = setclipboard or (syn and syn.setclipboard) or (clipboard and clipboard.set)
        if setclip then
            pcall(setclip, raw)
            ShowNotification(t("copied"), 1)
        else
            ShowNotification(t("clipboard_unavailable"), 2)
        end
    else
        ShowNotification(t("fetch_failed"), 2)
    end
end)

scriptbloxOptionOverlay.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local cardPos = scriptbloxOptionCard.AbsolutePosition
        local cardSize = scriptbloxOptionCard.AbsoluteSize
        if pos.X < cardPos.X or pos.X > cardPos.X + cardSize.X or pos.Y < cardPos.Y or pos.Y > cardPos.Y + cardSize.Y then
            scriptbloxOptionOverlay.Visible = false
        end
    end
end)

function makeScriptBloxCard(scriptData, layoutOrder)
    local card = create("Frame", {Size = UDim2.new(0, 365, 0, 160), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = layoutOrder, ZIndex = 4})
    corner(12, card)

    local verifiedBadge = nil
    if scriptData.verified then
        verifiedBadge = create("Frame", {Position = UDim2.new(1, -90, 0, 10), Size = UDim2.new(0, 80, 0, 24), BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 6})
        corner(12, verifiedBadge)
        local vbText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("verified_badge"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 10, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 7})
        vbText.Parent = verifiedBadge
        verifiedBadge.Parent = card
    end

    local titleLabel = create("TextLabel", {Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -110, 0, 22), BackgroundTransparency = 1, Text = scriptData.title or "Untitled", TextColor3 = theme.text, TextSize = 15, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5})
    titleLabel.Parent = card

    local gameNameRaw = scriptData.game and scriptData.game.name or "Universal Script"
    local gameName = gameNameRaw
    if string.find(string.lower(tostring(gameNameRaw)), "universal") then gameName = t("universal_script") end
    local gameLabel = create("TextLabel", {Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 18), BackgroundTransparency = 1, Text = gameName, TextColor3 = theme.textDim, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    gameLabel.Parent = card

    local scriptTypeRaw = scriptData.scriptType or "Script"
    local scriptTypeLower = string.lower(tostring(scriptTypeRaw))
    local scriptType = scriptTypeRaw
    if scriptTypeLower == "free" then scriptType = t("script_type_free")
    elseif scriptTypeLower == "script hub" then scriptType = t("script_type_script_hub")
    elseif scriptTypeLower == "script" then scriptType = t("script_type_script")
    end
    local typeLabel = create("TextLabel", {Position = UDim2.new(0, 14, 0, 54), Size = UDim2.new(1, -28, 0, 18), BackgroundTransparency = 1, Text = scriptType, TextColor3 = theme.accent, TextSize = 11, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    typeLabel.Parent = card

    local views = scriptData.views or 0
    local viewsLabel = create("TextLabel", {Position = UDim2.new(0, 14, 1, -28), Size = UDim2.new(0, 120, 0, 20), BackgroundTransparency = 1, Text = tostring(views) .. " " .. t("views_label"), TextColor3 = theme.text, TextSize = 13, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    viewsLabel.Parent = card

    local openBtn = create("TextButton", {Position = UDim2.new(1, -90, 1, -32), Size = UDim2.new(0, 80, 0, 28), BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(8, openBtn)
    local openText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("open_btn"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11, Font = Enum.Font.SourceSansBold, ZIndex = 6})
    openText.Parent = openBtn
    openBtn.Parent = card
    openBtn.MouseButton1Click:Connect(function()
        scriptbloxSelectedScript = scriptData
        scriptbloxOptionOverlay.Visible = true
    end)

    return card
end

function refreshScriptBloxList(filter)
    filter = filter or ""
        for _, child in pairs(scriptbloxScroll:GetChildren()) do
        if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    local scripts = fetchScriptBloxScripts(filter)
    if not scripts or #scripts == 0 then
        local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = t("scriptblox_no_results"), TextColor3 = theme.textDim, TextSize = 14, Font = Enum.Font.SourceSansBold, ZIndex = 4})
        emptyLabel.Parent = scriptbloxScroll
        return
    end
    local validIdx = 0
    for i, scriptData in ipairs(scripts) do
        if scriptData and type(scriptData) == "table" and scriptData.title and tostring(scriptData.title) ~= "" and scriptData._id and tostring(scriptData._id) ~= "" then
            validIdx = validIdx + 1
            local card = makeScriptBloxCard(scriptData, validIdx)
            card.Parent = scriptbloxScroll
            card.BackgroundTransparency = 1
            svc.TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25}):Play()
        end
    end
    if validIdx == 0 then
        for _, child in pairs(scriptbloxScroll:GetChildren()) do
            if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = t("scriptblox_no_results"), TextColor3 = theme.textDim, TextSize = 14, Font = Enum.Font.SourceSansBold, ZIndex = 4})
        emptyLabel.Parent = scriptbloxScroll
    end
    if scriptbloxScroll and scriptbloxGrid then
        task.defer(function()
            scriptbloxScroll.CanvasSize = UDim2.new(0, 0, 0, scriptbloxGrid.AbsoluteContentSize.Y + 16)
        end)
    end
end

rightToggleBar = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -9, 0, 86),
    Size = UDim2.new(0, 36, 1, -98),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 100
})
corner(10, rightToggleBar)
rightToggleBar.Parent = main
toggleIcon = GetIcon("chevron-right", UDim2.new(0, 18, 0, 18), theme.textDim)
if toggleIcon then
    toggleIcon.Position = UDim2.new(0.5, -9, 0.5, -9)
    toggleIcon.Parent = rightToggleBar
end
isCollapsed = false
local function setStatsTransparency(targetTransparency)
    local pills = {pingPill, fpsPill, timePill, labelPill}
    for _, pill in ipairs(pills) do
        if pill then
            svc.TweenService:Create(pill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = targetTransparency}):Play()
            for _, child in pairs(pill:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    svc.TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = targetTransparency < 1 and 0 or 1}):Play()
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    svc.TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = targetTransparency < 1 and 0 or 1}):Play()
                end
            end
        end
    end
end

rightToggleBar.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    if isCollapsed then
        if toggleIcon then svc.TweenService:Create(toggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 180}):Play() end
        svc.TweenService:Create(wrapperFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -30, 0, 86), Size = UDim2.new(0, 0, 1, -98)}):Play()
        svc.TweenService:Create(rightToggleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -2, 0, 86), Size = UDim2.new(0, 28, 1, -98)}):Play()
        setStatsTransparency(1)
        for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
            if dd.close then dd.close() end
        end
    else
        if toggleIcon then svc.TweenService:Create(toggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play() end
        svc.TweenService:Create(wrapperFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -44, 0, 86), Size = UDim2.new(1, -56, 1, -98)}):Play()
        svc.TweenService:Create(rightToggleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -9, 0, 86), Size = UDim2.new(0, 36, 1, -98)}):Play()
        setStatsTransparency(0.15)
    end
end)
local existingOrb = nil
for _, child in pairs(svc.CoreGui:GetChildren()) do
    local isHash = #child.Name == 16
            if isHash then
                for i = 1, 16 do
                    local c = child.Name:sub(i, i)
                    if not ((c >= "0" and c <= "9") or (c >= "a" and c <= "f")) then
                        isHash = false
                        break
                    end
                end
            end
            if isHash and child:FindFirstChild("DeltaUI_OrbFrame") then
        existingOrb = child:FindFirstChild("DeltaUI_OrbFrame")
        break
    end
end
if existingOrb then
    orbFrame = existingOrb
else
    orbFrame = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.35, 0),
        Size = UDim2.new(0, 35, 0, 35),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100,
        Name = "DeltaUI_OrbFrame"
    })
    corner(17, orbFrame)
    orbStroke = create("UIStroke", {Color = theme.accent, Thickness = 1.5, Transparency = 0})
    orbStroke.Parent = orbFrame
    orbFrame.Parent = screenGui
end
orbBtn = create("TextButton", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "",
    ZIndex = 101
})
orbBtn.Parent = orbFrame
isOrbDragging = false
orbDragStart = nil
orbDragInput = nil
orbDragOffset = nil

local orbDragDistance = 0

orbBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isOrbDragging = false
        orbDragDistance = 0
        local inputPos = Vector2.new(input.Position.X, input.Position.Y)
        orbDragStart = inputPos
        local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local halfSize = orbFrame.AbsoluteSize / 2

        local pos = orbFrame.Position
        local centerX = pos.X.Scale * screenSize.X + pos.X.Offset
        local centerY = pos.Y.Scale * screenSize.Y + pos.Y.Offset
        orbDragOffset = inputPos - Vector2.new(centerX, centerY)

        if math.abs(orbDragOffset.X) > 200 or math.abs(orbDragOffset.Y) > 200 then
            orbDragOffset = Vector2.new(0, 0)
        end
        orbDragInput = input
    end
end)

svc.UserInputService.InputChanged:Connect(function(input)
    if input == orbDragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos2 = Vector2.new(input.Position.X, input.Position.Y)
        if pos2.X ~= pos2.X or pos2.Y ~= pos2.Y then return end
        if pos2.X == 0 and pos2.Y == 0 then return end
        local delta = pos2 - orbDragStart
        local dist = math.max(math.abs(delta.X), math.abs(delta.Y))
        if dist > orbDragDistance then
            orbDragDistance = dist
        end
        if dist > 5 then
            isOrbDragging = true
        end
        if isOrbDragging then
            local newCenter = pos2 - orbDragOffset
            local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
            local orbSize = orbFrame.AbsoluteSize
            newCenter = Vector2.new(
                math.clamp(newCenter.X, orbSize.X / 2, screenSize.X - orbSize.X / 2),
                math.clamp(newCenter.Y, orbSize.Y / 2, screenSize.Y - orbSize.Y / 2)
            )
            orbFrame.Position = UDim2.new(0, newCenter.X, 0, newCenter.Y)
        end
    end
end)

svc.UserInputService.InputEnded:Connect(function(input)
    if input == orbDragInput then
        orbDragInput = nil
        isOrbDragging = false
        orbDragDistance = 0
    end
end)
logoutBtn.MouseButton1Click:Connect(function()
    for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
        if dd.close then dd.close() end
    end
    main.Visible = false
    orbFrame.Visible = true
    orbFrame.BackgroundTransparency = 1
    local targetSize = orbFrame.Size
    orbFrame.Size = UDim2.new(0, 0, 0, 0)
    svc.TweenService:Create(orbFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1, Size = targetSize}):Play()
end)
orbBtn.MouseButton1Click:Connect(function()
    if orbDragDistance > 5 then return end
    orbFrame.Visible = false
    main.Visible = true
    wrapperFrame.Position = UDim2.new(1, -44, 0, 86)
    wrapperFrame.Size = UDim2.new(1, -56, 1, -98)
    rightToggleBar.Position = UDim2.new(1, -9, 0, 86)
    rightToggleBar.Size = UDim2.new(0, 36, 1, -98)
    isCollapsed = false
    if toggleIcon then toggleIcon.Rotation = 0 end
    local pills = {pingPill, fpsPill, timePill, labelPill}
    for _, pill in ipairs(pills) do
        if pill then
            pill.BackgroundTransparency = 0.25
            for _, child in pairs(pill:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.TextTransparency = 0
                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    child.ImageTransparency = 0
                end
            end
        end
    end
end)
currentPage = "house"
editorPage = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = true, ZIndex = 2})
editorPage.Parent = contentFrame
tabBar = create("Frame", {
    Position = UDim2.new(0, 8, 0, 5),
    Size = UDim2.new(1, -36, 0, 30),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 5
})
tabBar.Parent = editorPage
tabBarLayout = create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Left})
tabBarLayout.Parent = tabBar

tabAddBtn = create("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.3,
    Text = "",
    BorderSizePixel = 0,
    LayoutOrder = 999,
    ZIndex = 7
})
corner(4, tabAddBtn)
tabAddBtn.Parent = tabBar
tabAddIcon = GetIcon("circle-plus", UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
if tabAddIcon then
    tabAddIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
    tabAddIcon.Parent = tabAddBtn
end

pageSwitcher = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 5),
    Size = UDim2.new(0, 80, 0, 26),
    BackgroundTransparency = 1,
    Visible = true,
    ZIndex = 6
})
pageSwitcher.Parent = editorPage

pageLeftBtn = create("TextButton", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.new(0, 22, 0, 22),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 7
})
pageLeftBtn.Parent = pageSwitcher
local pageLeftIcon = GetIcon("chevron-left", UDim2.new(0, 14, 0, 14), theme.textDim)
if pageLeftIcon then
    pageLeftIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    pageLeftIcon.Parent = pageLeftBtn
end

pageRightBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, 0, 0.5, 0),
    Size = UDim2.new(0, 22, 0, 22),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 7
})
pageRightBtn.Parent = pageSwitcher
local pageRightIcon = GetIcon("chevron-right", UDim2.new(0, 14, 0, 14), theme.textDim)
if pageRightIcon then
    pageRightIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    pageRightIcon.Parent = pageRightBtn
end

pageCounterLabel = create("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 36, 1, 0),
    BackgroundTransparency = 1,
    Text = "1/1",
    TextColor3 = theme.textDim,
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 7
})
pageCounterLabel.Parent = pageSwitcher

pageLeftBtn.MouseButton1Click:Connect(function()
    if not tabs[currentTab] then return end
    saveCurrentTab()
    local fullText = tabs[currentTab].content
    calculatePageBreaks(fullText)
    if currentCodePage > 1 then
        currentCodePage = currentCodePage - 1
        showCurrentPage()
    end
end)

pageRightBtn.MouseButton1Click:Connect(function()
    if not tabs[currentTab] then return end
    saveCurrentTab()
    local fullText = tabs[currentTab].content
    calculatePageBreaks(fullText)
    if currentCodePage < #codePageBreaks then
        currentCodePage = currentCodePage + 1
        showCurrentPage()
    end
end)

local pageLeftHolding = false
pageLeftBtn.MouseButton1Down:Connect(function()
    pageLeftHolding = true
    task.spawn(function()
        task.wait(0.4)
        while pageLeftHolding do
            if not tabs[currentTab] then break end
            local fullText = tabs[currentTab].content
            calculatePageBreaks(fullText)
            if currentCodePage > 1 then
                currentCodePage = currentCodePage - 1
                showCurrentPage()
            else
                break
            end
            task.wait(0.12)
        end
    end)
end)
pageLeftBtn.MouseButton1Up:Connect(function()
    pageLeftHolding = false
end)
pageLeftBtn.MouseLeave:Connect(function()
    pageLeftHolding = false
end)

local pageRightHolding = false
pageRightBtn.MouseButton1Down:Connect(function()
    pageRightHolding = true
    task.spawn(function()
        task.wait(0.4)
        while pageRightHolding do
            if not tabs[currentTab] then break end
            local fullText = tabs[currentTab].content
            calculatePageBreaks(fullText)
            if currentCodePage < #codePageBreaks then
                currentCodePage = currentCodePage + 1
                showCurrentPage()
            else
                break
            end
            task.wait(0.12)
        end
    end)
end)
pageRightBtn.MouseButton1Up:Connect(function()
    pageRightHolding = false
end)
pageRightBtn.MouseLeave:Connect(function()
    pageRightHolding = false
end)

lineNumberFrame = create("ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 40),
    Size = UDim2.new(0, 36, 1, -84),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    ScrollingEnabled = false,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 3
})
corner(8, lineNumberFrame)
lineNumberFrame.Parent = editorPage
lineNumberLabel = create("TextLabel", {Size = UDim2.new(1, -6, 1, 0), Position = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1, Text = "1", TextColor3 = theme.textDim, TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 4})
lineNumberLabel.Parent = lineNumberFrame
codeScroll = create("ScrollingFrame", {
    Position = UDim2.new(0, 40, 0, 40),
    Size = UDim2.new(1, -48, 1, -84),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 8,
    ScrollBarImageColor3 = theme.textDim,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 3
})
codeScroll.Parent = editorPage

codeBox = create("TextBox", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = theme.text,
    Font = Enum.Font.Code,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    MultiLine = true,
    ClearTextOnFocus = false,
    Text = "",
    ZIndex = 4
})
codeBox.Parent = codeScroll

syntaxLabel = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = theme.text,
    Font = Enum.Font.Code,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    RichText = true,
    Text = "",
    ZIndex = 3
})
syntaxLabel.Parent = codeScroll

execHighlightBar = create("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundColor3 = theme.accent,
    BackgroundTransparency = 0.65,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5
})
execHighlightBar.Parent = codeScroll

execErrorHighlight = create("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundColor3 = theme.red,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5
})
execErrorHighlight.Parent = codeScroll
execRealErrorHighlight = create("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundColor3 = Color3.fromRGB(180, 100, 220),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5
})
execRealErrorHighlight.Parent = codeScroll

execSuccessHighlight = create("Frame", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundColor3 = Color3.fromRGB(80, 180, 120),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5
})
execSuccessHighlight.Parent = codeScroll

local function updateEditorSize()
    if isUpdatingEditorSize then return end
    isUpdatingEditorSize = true
    local ok, err = pcall(function()
        if not codeBox or not codeBox.Parent then return end
        if not codeScroll or not codeScroll.Parent then return end
        local text = codeBox.Text or ""
        local lines = math.max(1, select(2, text:gsub(string.char(10), "")) + 1)
        local height
        local boundsY = (codeBox.TextBounds and codeBox.TextBounds.Y) or 0
        if boundsY > 0 then
            height = boundsY + 40
        else
            local lineHeight = math.max(4, codeBox.TextSize + 4)
            height = lines * lineHeight + 40
        end
        local viewH = codeScroll.AbsoluteSize.Y
        if viewH > 0 then
            height = math.max(height, viewH + 20)
        end
        codeBox.Size = UDim2.new(1, 0, 0, height)
        if syntaxLabel and syntaxLabel.Parent then
            syntaxLabel.Size = UDim2.new(1, 0, 0, height)
        end
        codeScroll.CanvasSize = UDim2.new(0, 0, 0, height)
        if lineNumberFrame and lineNumberFrame.Parent then
            lineNumberFrame.CanvasSize = UDim2.new(0, 0, 0, height)
        end
    end)
    isUpdatingEditorSize = false
    if not ok then warn("[DeltaUI] updateEditorSize: " .. tostring(err)) end
end

editOverlay = create("TextButton", {
    Position = UDim2.new(0, 40, 0, 40),
    Size = UDim2.new(1, -56, 1, -84),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 8
})
editOverlay.Parent = editorPage
local cachedEditorText = nil
local cachedEditorLines = nil
local function getCachedLines(text)
    if cachedEditorText == text and cachedEditorLines then
        return cachedEditorLines
    end
    cachedEditorText = text
    cachedEditorLines = splitLines(text)
    return cachedEditorLines
end
editOverlay.MouseButton1Click:Connect(function()
    local ok, err = pcall(function()
        local absPos = editOverlay.AbsolutePosition
        local absSize = editOverlay.AbsoluteSize
        local mousePos = svc.UserInputService:GetMouseLocation()
        if mousePos.X > absPos.X + absSize.X then
            return
        end
        local savedScroll = codeScroll.CanvasPosition
        editOverlay.Visible = false
        if syntaxLabel then syntaxLabel.Visible = false end
        codeBox.TextTransparency = 0
        codeBox:CaptureFocus()
        local lineHeight = codeBox.TextSize + 2
        local visibleLine = math.floor(savedScroll.Y / lineHeight) + 1
        local cursorPos = 0
        local lines = getCachedLines(codeBox.Text)
        for i = 1, math.min(visibleLine, #lines) do
            cursorPos = cursorPos + #lines[i] + 1
        end
        codeBox.CursorPosition = math.min(cursorPos, #codeBox.Text + 1)
        codeScroll.CanvasPosition = savedScroll
    end)
    if not ok then warn("[DeltaUI] EditOverlay: " .. tostring(err)) end
end)
codeBox.FocusLost:Connect(function()
    local ok, err = pcall(function()
        editOverlay.Visible = true
        codeBox.TextTransparency = 1
        showCurrentPage()
        updateEditorSize()
        task.defer(updateSyntaxHighlight)
        if syntaxLabel then syntaxLabel.Visible = true end
    end)
    if not ok then warn("[DeltaUI] FocusLost: " .. tostring(err)) end
end)
function updateLineNumbers()
    local ok, err = pcall(function()
        local text = codeBox.Text or ""
        local lines = splitLines(text)
        if #lines > 5000 then
            for i = 5001, #lines do
                lines[i] = nil
            end
        end
        local maxWidth = math.max(1, codeBox.AbsoluteSize.X - 12)
        local textSize = codeBox.TextSize
        local font = codeBox.Font
        local TextService = game:GetService("TextService")
        local startLine = 1
        if codePageBreaks and currentCodePage and #codePageBreaks > 0 and currentCodePage <= #codePageBreaks then
            startLine = codePageBreaks[currentCodePage] or 1
        end
        local nums = {}
        for i, line in ipairs(lines) do
            local absLine = startLine + i - 1
            table.insert(nums, tostring(absLine))
        end
        lineNumberLabel.Text = table.concat(nums, string.char(10))
    end)
    if not ok then warn("[DeltaUI] updateLineNumbers: " .. tostring(err)) end
    updateEditorSize()
end

local function getVisualLineHeight()
    if not codeBox or not codeBox.Parent then return 16 end
    return math.max(4, codeBox.TextSize + 2)
end

local function getLineHeight()
    return getVisualLineHeight()
end

local function countVisualLinesBefore(text, targetLogicalLine, maxWidth, textSize, font)
    _G.__DeltaUI_cvlLines = splitLines(text)
    if targetLogicalLine < 1 then
        _G.__DeltaUI_cvlLines = nil
        return 0
    end
    local TextService = game:GetService("TextService")
    local count = 0
    for i = 1, math.min(targetLogicalLine - 1, #_G.__DeltaUI_cvlLines) do
        local line = _G.__DeltaUI_cvlLines[i]
        if line == "" then
            count = count + 1
        else
            local ok, size = pcall(function()
                return TextService:GetTextSize(line, textSize, font, Vector2.new(maxWidth, math.huge))
            end)
            if ok and size then
                count = count + math.max(1, math.ceil(size.X / maxWidth))
            else
                count = count + 1
            end
        end
    end
    _G.__DeltaUI_cvlLines = nil
    return count
end

local function clearExecHighlights()
    execHighlightBar.Visible = false
    execErrorHighlight.Visible = false
    execSuccessHighlight.Visible = false
    execRealErrorHighlight.Visible = false
end

local function scrollToLine(logicalLine, offsetLines)
    if not logicalLine or logicalLine < 1 then return end
    if not codeBox or not codeBox.Parent then return end
    if not codeScroll or not codeScroll.Parent then return end
    local text = codeBox.Text or ""
    if text == "" then return end
    offsetLines = offsetLines or 3
    local lines = splitLines(text)
    if logicalLine > #lines then return end
    local lineHeight = getVisualLineHeight()
    local targetY = math.max(0, (logicalLine - 1 - offsetLines + 1) * lineHeight)
    local viewH = codeScroll.AbsoluteSize.Y
    local maxY = math.max(0, codeScroll.CanvasSize.Y.Offset - viewH)
    codeScroll.CanvasPosition = Vector2.new(0, math.min(targetY, maxY))
    if lineNumberFrame then
        lineNumberFrame.CanvasPosition = Vector2.new(0, codeScroll.CanvasPosition.Y)
    end
end

local function highlightExecLine(logicalLine, colorType)
    if not logicalLine or logicalLine < 1 then return end
    if not codeBox or not codeBox.Parent then return end
    local text = codeBox.Text or ""
    if text == "" then return end
    local lines = splitLines(text)
    if logicalLine > #lines then return end
    local lineHeight = getVisualLineHeight()
    local maxWidth = math.max(1, codeBox.AbsoluteSize.X - 12)
    local textSize = codeBox.TextSize
    local font = codeBox.Font
    local baseOffset = (logicalLine - 1) * lineHeight
    local lineVisualHeight = lineHeight
    local target
    if colorType == "error" then
        target = execErrorHighlight
    elseif colorType == "real" then
        target = execRealErrorHighlight
    elseif colorType == "success" then
        target = execSuccessHighlight
    else
        target = execHighlightBar
    end
    if not target or not target.Parent then return end
    target.Position = UDim2.new(0, 0, 0, baseOffset)
    target.Size = UDim2.new(1, 0, 0, lineVisualHeight)
    target.Visible = true
end

local function parseErrorLine(errMsg)
    if not errMsg then return nil end
        local function extractNumberAfterToken(str, token)
        local startPos = str:find(token, 1, true)
        if not startPos then return nil end
        local after = str:sub(startPos + #token)
        local numStr = ""
        for i = 1, #after do
            local c = after:sub(i, i)
            if c >= "0" and c <= "9" then
                numStr = numStr .. c
            elseif #numStr > 0 then
                break
            elseif c ~= " " and c ~= "  " and c ~= ":" then
                break
            end
        end
        return tonumber(numStr)
    end
        for i = 1, #errMsg do
        if errMsg:sub(i,i) == ":" then
            local numStr = ""
            local j = i + 1
            while j <= #errMsg do
                local c = errMsg:sub(j,j)
                if c >= "0" and c <= "9" then
                    numStr = numStr .. c
                    j = j + 1
                else
                    break
                end
            end
            if #numStr > 0 and errMsg:sub(j,j) == ":" then
                local realLine = tonumber(numStr)
                if realLine and realLine > 0 then
                    return realLine
                end
            end
        end
    end
        local line = extractNumberAfterToken(errMsg, "Line")
    if not line then
        line = extractNumberAfterToken(errMsg, "line")
    end
    return line
end

function jumpToErrorLine(errLine)
    if not errLine or type(errLine) ~= "number" or errLine < 1 then return false end
    local function tryTab(tabIdx, line)
        local tab = tabs[tabIdx]
        if not tab then return false end
        local text = tab.content or ""
        if type(text) ~= "string" then text = "" end
        local lines = splitLines(text)
        if line > #lines then return false end
        saveCurrentTab()
        currentTab = tabIdx
        currentCodePage = 1
        calculatePageBreaks(text)
        if #codePageBreaks == 0 then
            table.insert(codePageBreaks, 1)
        end
        for pageNum, startLine in ipairs(codePageBreaks) do
            local endLine = codePageBreaks[pageNum + 1] and codePageBreaks[pageNum + 1] - 1 or #lines
            if line >= startLine and line <= endLine then
                currentCodePage = pageNum
                break
            end
        end
        showCurrentPage()
        renderTabs()
        local relativeLogicalLine = line - (codePageBreaks[currentCodePage] or 1) + 1
        highlightExecLine(relativeLogicalLine, "error")
        scrollToLine(relativeLogicalLine, 3)
        return true
    end
    if tryTab(currentTab, errLine) then return true end
    for tabIdx, tab in ipairs(tabs) do
        if tabIdx ~= currentTab then
            if tryTab(tabIdx, errLine) then return true end
        end
    end
    return false
end
local function animateExecScan(scanDuration)
    if not codeBox or not codeBox.Parent then return nil end
    if not codeScroll or not codeScroll.Parent then return nil end
    if not tabs[currentTab] then return nil end

    local fullText = tabs[currentTab].content or ""
    if type(fullText) ~= "string" then fullText = "" end
    if fullText == "" then return nil end

                local totalLines = select(2, fullText:gsub(string.char(10), "")) + 1
    if totalLines == 0 then return nil end

    local lineHeight = getLineHeight()
    if lineHeight <= 0 then lineHeight = 16 end

    local totalVisualLines = totalLines
    local pageRanges = {}
    local pageStep = 100
    for startLine = 1, totalLines, pageStep do
        local endLine = math.min(startLine + pageStep - 1, totalLines)
        table.insert(pageRanges, {start = startLine, ["end"] = endLine})
    end
    if #pageRanges == 0 then
        pageRanges[1] = {start = 1, ["end"] = totalLines}
    end

    execHighlightBar.BackgroundColor3 = Color3.fromRGB(80, 180, 120)
    execHighlightBar.BackgroundTransparency = 0.45
    execHighlightBar.Size = UDim2.new(1, 0, 0, lineHeight)
    execHighlightBar.Visible = true
    isExecScanning = true

    local startTime = tick()
    local scanConn = nil
    scanConn = svc.RunService.RenderStepped:Connect(function()
        if not execHighlightBar or not execHighlightBar.Parent then
            if scanConn then scanConn:Disconnect() scanConn = nil end
            return
        end
        local elapsed = tick() - startTime
        local progress = math.min(1, elapsed / scanDuration)
        local currentVisualLine = math.floor(progress * totalVisualLines)

        local currentActualLine = math.max(1, math.min(currentVisualLine + 1, totalLines))

        local currentPage = 1
        for i, range in ipairs(pageRanges) do
            if currentActualLine >= range.start and currentActualLine <= range["end"] then
                currentPage = i
                break
            end
        end

        if currentCodePage ~= currentPage then
            currentCodePage = currentPage
            showCurrentPage()
        end

        local pageStartLine = pageRanges[currentPage].start
        local pageVisualOffset = math.max(0, currentActualLine - pageStartLine)

        local yPos = pageVisualOffset * lineHeight
        execHighlightBar.Position = UDim2.new(0, 0, 0, yPos)

        if codeScroll and codeScroll.Parent then
            local viewH = codeScroll.AbsoluteSize.Y
            local canvasH = codeScroll.CanvasSize.Y.Offset
            local maxScroll = math.max(0, canvasH - viewH)
            local targetScroll = math.max(0, yPos - viewH * 0.5 + lineHeight * 0.5)
            targetScroll = math.min(targetScroll, maxScroll)
            local currentScroll = codeScroll.CanvasPosition.Y
            local newScroll = currentScroll + (targetScroll - currentScroll) * 0.25
            if math.abs(newScroll - currentScroll) > 0.5 then
                codeScroll.CanvasPosition = Vector2.new(0, newScroll)
            end
        end

        if progress >= 1 then
            if scanConn then scanConn:Disconnect() scanConn = nil end
            isExecScanning = false
            task.delay(0.3, function()
                execHighlightBar.Visible = false
            end)
        end
    end)

    return {
        Cancel = function()
            if scanConn then scanConn:Disconnect() scanConn = nil end
            isExecScanning = false
            execHighlightBar.Visible = false
        end
    }
end
function syntaxHighlight(code)
    if not code or code == "" then return "" end
    local result = {}
    local i = 1
    local len = #code

    local tokens = {
        ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
        ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
        ["function"] = true, ["goto"] = true, ["if"] = true, ["in"] = true,
        ["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
        ["repeat"] = true, ["return"] = true, ["then"] = true, ["true"] = true,
        ["until"] = true, ["while"] = true
    }

    local builtins = {
        ["print"] = true, ["warn"] = true, ["error"] = true, ["pcall"] = true,
        ["xpcall"] = true, ["loadstring"] = true, ["require"] = true,
        ["game"] = true, ["workspace"] = true, ["script"] = true,
        ["pairs"] = true, ["ipairs"] = true, ["next"] = true, ["type"] = true,
        ["tonumber"] = true, ["tostring"] = true, ["table"] = true,
        ["string"] = true, ["math"] = true, ["os"] = true, ["coroutine"] = true,
        ["debug"] = true, ["bit32"] = true, ["utf8"] = true,
        ["Vector3"] = true, ["Vector2"] = true, ["Color3"] = true,
        ["Instance"] = true, ["Enum"] = true, ["UDim"] = true, ["UDim2"] = true,
        ["Ray"] = true, ["CFrame"] = true, ["BrickColor"] = true,
        ["NumberRange"] = true, ["NumberSequence"] = true, ["ColorSequence"] = true,
        ["Rect"] = true, ["Region3"] = true, ["Region3int16"] = true,
        ["Axes"] = true, ["Faces"] = true, ["PhysicalProperties"] = true,
        ["FloatCurve"] = true, ["RotationCurve"] = true
    }

    while i <= len do
        local c = code:sub(i, i)
        local token = nil
        local color = nil

        if c == "-" and code:sub(i+1, i+1) == "-" then
            if code:sub(i+2, i+3) == "[[" then
                local endPos = code:find("]]", i + 4, true) or len + 1
                token = code:sub(i, endPos + 1)
                color = syntaxColors.comment
                i = endPos + 2
            else
                local endPos = code:find(string.char(10), i + 2, true) or len + 1
                token = code:sub(i, endPos - 1)
                color = syntaxColors.comment
                i = endPos
            end
        elseif c == '"' or c == "'" then
            local quote = c
            local j = i + 1
            while j <= len do
                local ch = code:sub(j, j)
                if ch == "" then
                    j = j + 2
                elseif ch == quote then
                    j = j + 1
                    break
                else
                    j = j + 1
                end
            end
            token = code:sub(i, j - 1)
            color = syntaxColors.string
            i = j
        elseif c >= "0" and c <= "9" then
            local j = i
            while j <= len do
                local ch = code:sub(j, j)
                if (ch >= "0" and ch <= "9") or ch == "." then
                    j = j + 1
                else
                    break
                end
            end
            token = code:sub(i, j - 1)
            color = syntaxColors.number
            i = j
        elseif (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or c == "_" then
            local j = i
            while j <= len do
                local ch = code:sub(j, j)
                if (ch >= "0" and ch <= "9") or (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or ch == "_" then
                    j = j + 1
                else
                    break
                end
            end
            local word = code:sub(i, j - 1)
            if tokens[word] then
                color = syntaxColors.token
            elseif builtins[word] then
                color = syntaxColors.builtin
            end
            token = word
            i = j
        else
            token = c
            i = i + 1
        end

        if token then
            local escaped = token:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
            if color then
                table.insert(result, string.format('<font color="rgb(%d,%d,%d)">%s</font>', color[1], color[2], color[3], escaped))
            else
                table.insert(result, escaped)
            end
        end
    end

    return table.concat(result)
end
syntaxColors = {
    token = {180, 130, 255},
    funcName = {200, 160, 255},
    localVar = {100, 200, 255},
    comment = {120, 120, 120},
    string = {150, 220, 140},
    number = {255, 180, 100},
    builtin = {255, 220, 100},
}

wasaiShowScriptResult = function(title, source)
    local container, bubble = wasaiCreateMessageContainer("", false)
    local card = create("Frame", {
        Size = UDim2.new(0, 420, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(13, 17, 23),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = bubble,
        ZIndex = 4
    })
    corner(8, card)

    local head = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(22, 27, 34),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = card,
        ZIndex = 5
    })
    local langTag = create("TextLabel", {
        Position = UDim2.new(0, 10, 0.5, -9),
        Size = UDim2.new(0, 42, 0, 18),
        BackgroundColor3 = Color3.fromRGB(40, 47, 62),
        BackgroundTransparency = 0,
        Text = "lua",
        TextColor3 = Color3.fromRGB(120, 170, 255),
        Font = Enum.Font.Code,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = head,
        ZIndex = 6
    })
    corner(4, langTag)
    local titleLabel = create("TextLabel", {
        Position = UDim2.new(0, 60, 0, 0),
        Size = UDim2.new(1, -128, 1, 0),
        BackgroundTransparency = 1,
        Text = title or "脚本",
        TextColor3 = Color3.fromRGB(200, 210, 225),
        Font = Enum.Font.SourceSansBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = head,
        ZIndex = 6
    })
    local copyBtn = create("TextButton", {
        Position = UDim2.new(1, -62, 0.5, -10),
        Size = UDim2.new(0, 52, 0, 20),
        BackgroundColor3 = theme.accent,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Text = "",
        Parent = head,
        ZIndex = 6
    })
    corner(6, copyBtn)
    local copyTxt = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "复制",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        Font = Enum.Font.SourceSansBold,
        Parent = copyBtn,
        ZIndex = 7
    })

    local codeLabel = create("TextLabel", {
        Position = UDim2.new(0, 10, 0, 38),
        Size = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        RichText = true,
        Text = syntaxHighlight(source or ""),
        TextColor3 = Color3.fromRGB(220, 225, 235),
        Font = Enum.Font.Code,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
        ZIndex = 5
    })
    create("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        Parent = card
    })

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(source or "")
            copyTxt.Text = "已复制"
            ShowNotification("脚本已复制到剪贴板", 1.5)
            task.delay(1.5, function() copyTxt.Text = "复制" end)
        else
            copyTxt.Text = "不可用"
            ShowNotification("剪贴板 API 不可用", 2)
        end
    end)

    wasaiFinalizeMessage(container, false)
    return container
end

-- 将 AI 回复中的 ##代码## 块分段渲染：普通文字（支持 **粗体**）+ 带复制按钮的代码框
-- 若回复中不含 ##代码## 则返回 nil（由调用方走正常打字机渲染）
wasaiRenderMessageWithCode = function(reply, stats)
    if type(reply) ~= "string" then return nil end
    local parts = {}
    local hasCode = false
    local pos = 1
    while true do
        local s, e = reply:find("##(.-)##", pos)
        if not s then
            local rest = reply:sub(pos)
            if rest ~= "" then parts[#parts + 1] = {type = "text", text = rest} end
            break
        end
        hasCode = true
        local before = reply:sub(pos, s - 1)
        if before ~= "" then parts[#parts + 1] = {type = "text", text = before} end
        local code = reply:sub(s + 2, e - 1)
        if code ~= "" then
            parts[#parts + 1] = {type = "code", text = code}
        else
            parts[#parts + 1] = {type = "text", text = "##"}
        end
        pos = e + 1
    end
    if not hasCode then return nil end

    local statsShown = false
    for i, part in ipairs(parts) do
        if part.type == "text" then
            wasaiAddMessage(part.text, false, (not statsShown) and stats or nil)
            if not statsShown then statsShown = true end
        else
            wasaiShowScriptResult("代码", part.text)
        end
    end
    return true
end

local isUpdatingEditorSize = false

local VP_MAX_FULL_LEN = 40000
local VP_MAX_RICHTEXT_LEN = 80000
local VP_BUFFER_LINES = 10
local VP_MAX_LINE_LEN = 8000
local function getVisibleLineRange()
    if not codeScroll or not codeScroll.Parent then return 1, 1 end
    local canvasY = codeScroll.CanvasPosition.Y
    local viewH = codeScroll.AbsoluteSize.Y
    if viewH <= 0 then return 1, 1 end
    local lineH = codeBox.TextSize + 2
    local startLine = math.max(1, math.floor(canvasY / lineH) - VP_BUFFER_LINES)
    local endLine = math.ceil((canvasY + viewH) / lineH) + VP_BUFFER_LINES
    return startLine, endLine
end

function updateSyntaxHighlight()
    if not syntaxLabel or not syntaxLabel.Parent then return end
    if _G.__DeltaUI_syntaxDebounce then
        _G.__DeltaUI_syntaxDebounce = tick()
        return
    end
    _G.__DeltaUI_syntaxDebounce = tick()
    task.defer(function()
        local startTick = _G.__DeltaUI_syntaxDebounce
        task.wait(0.08)
        if _G.__DeltaUI_syntaxDebounce ~= startTick then return end
        _G.__DeltaUI_syntaxDebounce = nil
        _G.__DeltaUI_doSyntaxHighlight()
    end)
end

function _G.__DeltaUI_doSyntaxHighlight()
    if not syntaxLabel or not syntaxLabel.Parent then return end
    local raw = codeBox.Text
    if #raw == 0 then syntaxLabel.Text = ""; return end
    if #raw <= VP_MAX_FULL_LEN then
        syntaxLabel.RichText = true
        local ok, result = pcall(syntaxHighlight, raw)
        if not ok or #result > VP_MAX_RICHTEXT_LEN then
            syntaxLabel.RichText = false
            syntaxLabel.Text = raw:sub(1, 79900)
            if not ok then warn("[DeltaUI] Syntax highlight failed: " .. tostring(result)) end
            return
        end
        syntaxLabel.Text = result
        return
    end
    syntaxLabel.RichText = true
    local lines = getCachedLines(raw)
    local totalLines = #lines
    if totalLines == 0 then return end
    local startLine, endLine = getVisibleLineRange()
    endLine = math.min(endLine, totalLines)
    startLine = math.min(startLine, totalLines)
    if startLine > endLine then startLine = 1 end
    local parts = {}
    for i = 1, startLine - 1 do
        parts[i] = lines[i]
    end
    for i = startLine, endLine do
        local line = lines[i]
        if #line > VP_MAX_LINE_LEN then
            parts[i] = line
        else
            local ok, highlighted = pcall(syntaxHighlight, line)
            if ok and highlighted and #highlighted < VP_MAX_LINE_LEN * 2 then
                parts[i] = highlighted
            else
                parts[i] = line
            end
        end
    end
    for i = endLine + 1, totalLines do
        parts[i] = lines[i]
    end
    local totalLen = 0
    for i = 1, #parts do
        totalLen = totalLen + #parts[i] + 1
    end
    if totalLen > VP_MAX_RICHTEXT_LEN then
        syntaxLabel.RichText = false
        syntaxLabel.Text = raw:sub(1, 199900)
        return
    end
    syntaxLabel.Text = table.concat(parts, string.char(10))
end

updateLineNumbers()

tabs = {}
currentTab = 1
tabIdCounter = 1
currentCodePage = 1
codePageBreaks = {}
isProgrammaticTextChange = false
isExecScanning = false

function getUniqueTabName()
    local base = "New tab"
    local names = {}
    for _, t in ipairs(tabs) do
        names[t.name] = true
    end
    name = base .. " " .. tabIdCounter
    while names[name] do
        tabIdCounter = tabIdCounter + 1
        name = base .. " " .. tabIdCounter
    end
    return name
end

function calculatePageBreaks(text)
    codePageBreaks = {}
    if type(text) ~= "string" or text == "" then
        table.insert(codePageBreaks, 1)
        return
    end
    local lines = splitLines(text)
    if #lines == 0 then
        table.insert(codePageBreaks, 1)
        return
    end
    if #lines > 10000 then

        local pageStart = 1
        while pageStart <= #lines do
            table.insert(codePageBreaks, pageStart)
            pageStart = pageStart + 100
        end
        return
    end
    local targetMin = 90
    local targetMax = 110
    local target = 100
    local currentPageStart = 1
    while currentPageStart <= #lines do
        table.insert(codePageBreaks, math.floor(currentPageStart))
        if currentPageStart + targetMax >= #lines then
            break
        end
        local bestBreak = nil
        local bestScore = -math.huge
        for i = targetMin, targetMax do
            local lineIdx = currentPageStart + i - 1
            if lineIdx >= #lines then
                bestBreak = #lines
                break
            end
            local line = lines[lineIdx]
            local nextLine = lines[lineIdx + 1] or ""
            local prevLine = lines[lineIdx - 1] or ""
            local score = 0
            if line == "" then
                score = score + 100
            end
            local trimmedLine = line
                while #trimmedLine > 0 and string.byte(trimmedLine:sub(1,1)) <= 32 do trimmedLine = trimmedLine:sub(2) end
                if trimmedLine:sub(1,3) == "end" then
                score = score + 80
            end
            local function startsWithTrimmed(str, prefix)
                    local s = str
                    while #s > 0 and string.byte(s:sub(1,1)) <= 32 do s = s:sub(2) end
                    return s:sub(1, #prefix) == prefix
                end
                if startsWithTrimmed(line, "local ") or startsWithTrimmed(line, "return ") then
                score = score + 60
            end
            local function countLeadingSpaces(str)
                local count = 0
                for i = 1, #str do
                    if string.byte(str:sub(i,i)) <= 32 then
                        count = count + 1
                    else
                        break
                    end
                end
                return count
            end
            local prevIndent = countLeadingSpaces(prevLine)
            local currIndent = countLeadingSpaces(line)
            if currIndent < prevIndent and currIndent == 0 then
                score = score + 50
            end
            if line:sub(-1) == '"' or line:sub(-1) == "'" or line:match("%[%[%s*$") then
                score = score - 200
            end
            if startsWithTrimmed(line, "function ") or startsWithTrimmed(line, "local function ") or startsWithTrimmed(line, "if ") or startsWithTrimmed(line, "for ") or startsWithTrimmed(line, "while ") or startsWithTrimmed(line, "repeat") then
                score = score - 50
            end
            score = score - math.abs(i - target) * 0.5
            if score > bestScore then
                bestScore = score
                bestBreak = lineIdx + 1
            end
        end
        if bestBreak and bestBreak > currentPageStart then
            currentPageStart = math.floor(bestBreak)
        else
            currentPageStart = currentPageStart + target
        end
    end
    if #codePageBreaks == 0 then
        table.insert(codePageBreaks, 1)
    end
end
function showCurrentPage()
    local ok, err = pcall(function()
        if not tabs[currentTab] then return end
        local text = tabs[currentTab].content
        if type(text) ~= "string" then text = "" end
                                if isExecScanning then
            updatePageSwitcher()
            return
        end
        calculatePageBreaks(text)
        if currentCodePage < 1 then currentCodePage = 1 end
        if currentCodePage > #codePageBreaks then
            currentCodePage = math.max(1, #codePageBreaks)
        end
        local startLine = codePageBreaks[currentCodePage] or 1
        local lines = splitLines(text)
        local endLine
        if currentCodePage < #codePageBreaks then
            endLine = codePageBreaks[currentCodePage + 1] - 1
        else
            endLine = #lines
        end
        endLine = math.min(endLine, #lines)
        local pageText = ""
        for i = startLine, endLine do
            pageText = pageText .. (lines[i] or "")
            if i < endLine then
                pageText = pageText .. string.char(10)
            end
        end
        if #pageText > 199000 then
            pageText = pageText:sub(1, 199000) .. "..."
        end
        isProgrammaticTextChange = true
        codeBox.Text = pageText
        isProgrammaticTextChange = false
        updateLineNumbers()
        _G.__DeltaUI_doSyntaxHighlight()
        updatePageSwitcher()
    end)
    if not ok then warn("[DeltaUI] showCurrentPage: " .. tostring(err)) end
end

function updatePageSwitcher()
    if not pageCounterLabel then return end
    local total = math.max(1, #codePageBreaks)
    pageCounterLabel.Text = tostring(currentCodePage) .. "/" .. tostring(total)
end

function saveCurrentTab()
    if not tabs[currentTab] then return end
    local text = codeBox.Text
    if text == "" then
        tabs[currentTab].content = ""
        return
    end
    if #codePageBreaks > 1 and currentCodePage <= #codePageBreaks and currentCodePage >= 1 then
        local fullText = tabs[currentTab].content or ""
        if type(fullText) ~= "string" then fullText = "" end
        local allLines = splitLines(fullText)
        local pageStart = codePageBreaks[currentCodePage] or 1
        local endLine = codePageBreaks[currentCodePage + 1] and codePageBreaks[currentCodePage + 1] - 1 or #allLines
        local newLines = splitLines(text)
        local merged = {}
        for i = 1, pageStart - 1 do
            table.insert(merged, allLines[i] or "")
        end
        for i = 1, #newLines do
            table.insert(merged, newLines[i])
        end
        for i = endLine + 1, #allLines do
            table.insert(merged, allLines[i] or "")
        end
        text = table.concat(merged, string.char(10))
    end
    tabs[currentTab].content = text
end

function renderTabs()
    local tabChildren = tabBar:GetChildren()
    for i = #tabChildren, 1, -1 do
        local child = tabChildren[i]
        if child:IsA("TextButton") and child ~= tabAddBtn then
            child:Destroy()
        end
    end
    for idx, tab in ipairs(tabs) do
        pill = create("TextButton", {
            Size = UDim2.new(0, 120, 0, 26),
            BackgroundColor3 = idx == currentTab and theme.accent or theme.surface,
            BackgroundTransparency = 0.25,
            Text = "",
            BorderSizePixel = 0,
            LayoutOrder = idx,
            ZIndex = 5
        })
        corner(8, pill)
        pill.Parent = tabBar
        icon = GetIcon("file-pen", UDim2.new(0, 11, 0, 11), Color3.fromRGB(255,255,255))
        if icon then
            icon.Position = UDim2.new(0, 6, 0.5, -5)
            icon.Parent = pill
        end
        txt = create("TextLabel", {Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -46, 1, 0), BackgroundTransparency = 1, Text = tab.name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6})
        txt.Parent = pill
        closeBtn = create("TextButton", {Position = UDim2.new(1, -20, 0.5, -7), Size = UDim2.new(0, 14, 0, 14), BackgroundTransparency = 1, Text = "", ZIndex = 7})
        closeBtn.Parent = pill
        closeIcon = GetIcon("x", UDim2.new(0, 10, 0, 10), Color3.fromRGB(255,255,255))
        if closeIcon then
            closeIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
            closeIcon.Parent = closeBtn
        end
        closeBtn.MouseButton1Click:Connect(function()
            local ok, err = pcall(function()
                if #tabs <= 1 then
                    tabs[1].content = ""
                    tabs[1].name = getUniqueTabName()
                    currentCodePage = 1
                    codePageBreaks = {}
                    codeBox.Text = ""
                    updateLineNumbers()
                    renderTabs()
                    return
                end
                table.remove(tabs, idx)
                if currentTab > #tabs then
                    currentTab = #tabs
                elseif currentTab == idx then
                    currentTab = math.max(1, idx - 1)
                end
                currentCodePage = 1
                codePageBreaks = {}
                showCurrentPage()
                renderTabs()
            end)
            if not ok then warn("[DeltaUI] closeTab: " .. tostring(err)) end
        end)
        pill.MouseButton1Click:Connect(function()
            saveCurrentTab()
            currentTab = idx
            currentCodePage = 1
            codePageBreaks = {}
            showCurrentPage()
            renderTabs()
        end)
    end
end

function addTab()
    local ok, err = pcall(function()
        saveCurrentTab()
        local name = getUniqueTabName()
        table.insert(tabs, {name = name, content = defaultEditorText})
        currentTab = #tabs
        tabIdCounter = tabIdCounter + 1
        currentCodePage = 1
        codePageBreaks = {}
        isProgrammaticTextChange = true
        codeBox.Text = defaultEditorText
        isProgrammaticTextChange = false
        codeBox.TextTransparency = 1
        updateLineNumbers()
        task.defer(_G.__DeltaUI_doSyntaxHighlight)
        renderTabs()
        updatePageSwitcher()
    end)
    if not ok then warn("[DeltaUI] addTab: " .. tostring(err)) end
end

table.insert(tabs, {name = getUniqueTabName(), content = defaultEditorText})
renderTabs()
codeBox.TextTransparency = 1
showCurrentPage()

codeBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateLineNumbers()
    if not isProgrammaticTextChange and tabs[currentTab] then
        saveCurrentTab()
    end
    updateSyntaxHighlight()
    updateEditorSize()
end)

codeScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if lineNumberFrame then
        lineNumberFrame.CanvasPosition = Vector2.new(0, codeScroll.CanvasPosition.Y)
    end
    if #codeBox.Text > VP_MAX_FULL_LEN then
        updateSyntaxHighlight()
    end
end)

tabAddBtn.MouseButton1Click:Connect(function()
    addTab()
end)
bottomBar = create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 12, 1, -8),
    Size = UDim2.new(1, -24, 0, 32),
    BackgroundTransparency = 1,
    ZIndex = 5
})
bottomBar.Parent = editorPage
bottomLeft = create("Frame", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 5})
bottomLeft.Parent = bottomBar
bottomLeftLayout = create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8)})
bottomLeftLayout.Parent = bottomLeft
local function makeBottomBtn(key, iconName)
    local btn = create("TextButton", {Size = UDim2.new(0, 85, 0, 30), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, Text = "", ZIndex = 6})
    corner(8, btn)
    stroke(theme.border, 1, btn)
    local icon = GetIcon(iconName, UDim2.new(0, 13, 0, 13))
    if icon then
        icon.Position = UDim2.new(0, 8, 0.5, -6)
        icon.Parent = btn
    end
    txt = create("TextLabel", {Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1, Text = t(key), TextColor3 = theme.text, TextSize = 11, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})
    txt.Parent = btn
    table.insert(settingsData.uiRefs, {element = txt, key = key})
    return btn
end
execBtn = makeBottomBtn("execute", "play")
execBtn.Parent = bottomLeft
clearBtn = makeBottomBtn("clear", "trash-2")
clearBtn.Parent = bottomLeft
execBtn.MouseButton1Click:Connect(function()
    cleanupOldUI()
    saveCurrentTab()
    local code = tabs[currentTab] and tabs[currentTab].content or codeBox.Text
    if code and code ~= "" then
        clearExecHighlights()
        local scanCtrl = animateExecScan(0.8)
        local execEntry = AddLog("> " .. t("executing"), "info")
        local animRunning = true
        task.spawn(function()
            local dots = {".", "..", "..."}
            local idx = 1
            while animRunning do
                if execEntry and execEntry.Parent then
                    execEntry.Text = "> " .. t("executing"):gsub("%.+", dots[idx])
                end
                idx = idx % 3 + 1
                task.wait(0.4)
            end
        end)
                                task.spawn(function()
            local fn, compileErr = loadstring(code)
            if not fn then
                animRunning = false
                if scanCtrl then scanCtrl.Cancel() end
                clearExecHighlights()
                local errLine = parseErrorLine(tostring(compileErr))
                if errLine then
                    jumpToErrorLine(errLine)
                end
                AddLog("[Error] " .. tostring(compileErr), "error")
                ShowNotification(t("execution_error_notify"), 3, function()
                    switchPage("terminal")
                end)
                return
            end
            local oldPrint = print
            local oldWarn = warn
            print = function(...)
                local args = {...}
                local msg = table.concat(args, " ")
                AddLog(msg, "info")
                if logDedup then logDedup[msg] = tick() end
                oldPrint(...)
            end
            warn = function(...)
                local args = {...}
                local msg = table.concat(args, " ")
                AddLog(msg, "warn")
                if logDedup then logDedup[msg] = tick() end
                oldWarn(...)
            end
            _G.__DeltaUI_blockLogService = true
            local ok, execErr = xpcall(fn, function(err)
                return debug.traceback(tostring(err), 2)
            end)
            _G.__DeltaUI_blockLogService = nil
            print = oldPrint
            warn = oldWarn
            animRunning = false
            if scanCtrl then scanCtrl.Cancel() end
            if not ok then
                clearExecHighlights()
                local errLine = parseErrorLine(tostring(execErr))
                if errLine then
                    jumpToErrorLine(errLine)
                end
                AddLog("[Error] " .. tostring(execErr), "error")
                ShowNotification(t("execution_error_notify"), 3, function()
                    switchPage("terminal")
                end)
                return
            end
            clearExecHighlights()
            saveCurrentTab()
                                    currentCodePage = 999999
            showCurrentPage()
                        local pageText = codeBox.Text or ""
            local lastLine = select(2, pageText:gsub(string.char(10), "")) + 1
            if lastLine > 0 then
                highlightExecLine(lastLine, "success")
                scrollToLine(lastLine, 3)
            end
            task.delay(0.8, clearExecHighlights)
            if execEntry and execEntry.Parent then
                execEntry.Text = "> " .. t("execution_finished")
                execEntry.TextColor3 = Color3.fromRGB(100, 180, 255)
            end
        end)
    end
end)
clearBtn.MouseButton1Click:Connect(function()
    isProgrammaticTextChange = true
    codeBox.Text = defaultEditorText
    if syntaxLabel and syntaxLabel.Parent then
        syntaxLabel.Text = ""
    end
    updateLineNumbers()
    if tabs[currentTab] then
        tabs[currentTab].content = defaultEditorText
    end
    clearExecHighlights()
    isProgrammaticTextChange = false
    ShowNotification(t("editor_cleared"), 1)
end)
newlineBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -166, 0.5, 0),
    Size = UDim2.new(0, 85, 0, 30),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Text = "",
    ZIndex = 6
})
corner(8, newlineBtn)
stroke(theme.border, 1, newlineBtn)
local newlineIcon = GetIcon("corner-down-left", UDim2.new(0, 13, 0, 13))
if newlineIcon then
    newlineIcon.Position = UDim2.new(0, 8, 0.5, -6)
    newlineIcon.Parent = newlineBtn
end
local newlineText = create("TextLabel", {Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1, Text = t("newline"), TextColor3 = theme.text, TextSize = 11, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})
newlineText.Parent = newlineBtn
table.insert(settingsData.uiRefs, {element = newlineText, key = "newline"})
newlineBtn.Parent = bottomBar
newlineBtn.MouseButton1Click:Connect(function()
    local savedScroll = codeScroll.CanvasPosition
    codeBox:CaptureFocus()
    codeBox.Text = codeBox.Text .. string.char(10)
    codeScroll.CanvasPosition = savedScroll
    updateLineNumbers()
    updateSyntaxHighlight()
    updateEditorSize()
end)

execClipBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.new(0, 150, 0, 30),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Text = "",
    ZIndex = 6
})
corner(8, execClipBtn)
stroke(theme.border, 1, execClipBtn)
clipIcon = GetIcon("clipboard-list", UDim2.new(0, 13, 0, 13))
if clipIcon then
    clipIcon.Position = UDim2.new(0, 8, 0.5, -6)
    clipIcon.Parent = execClipBtn
end
clipText = create("TextLabel", {Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1, Text = t("execute_clipboard"), TextColor3 = theme.text, TextSize = 11, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})
clipText.Parent = execClipBtn
table.insert(settingsData.uiRefs, {element = clipText, key = "execute_clipboard"})
execClipBtn.Parent = bottomBar
execClipBtn.MouseButton1Click:Connect(function()
    cleanupOldUI()
    local result = getClipboardContent()
    if not result or result == "" then
        ShowNotification(t("error") .. ": Clipboard empty or unavailable", 2)
        return
    end
    _G.__DeltaUI_skipLineOffset = true
    clearExecHighlights()

    saveCurrentTab()
    local name = getUniqueTabName()
    table.insert(tabs, {name = "Clipboard " .. name, content = result})
    currentTab = #tabs
    tabIdCounter = tabIdCounter + 1
    currentCodePage = 1
    codePageBreaks = {}
    showCurrentPage()
    renderTabs()

    local scanCtrl = animateExecScan(0.8)
    local execEntry = AddLog("> " .. t("executing_clipboard"), "info")
    local animRunning = true
    task.spawn(function()
        local dots = {".", "..", "..."}
        local idx = 1
        while animRunning do
            if execEntry and execEntry.Parent then
                execEntry.Text = "> " .. t("executing_clipboard"):gsub("%.+", dots[idx])
            end
            idx = idx % 3 + 1
            task.wait(0.4)
        end
    end)
    task.spawn(function()
        local fn, compileErr = loadstring(result)
        if not fn then
            animRunning = false
            if scanCtrl then scanCtrl.Cancel() end
            clearExecHighlights()
            _G.__DeltaUI_skipLineOffset = nil
            local errLine = parseErrorLine(tostring(compileErr))
            if errLine then
                jumpToErrorLine(errLine)
            end
            AddLog("[Error] " .. tostring(compileErr), "error")
            ShowNotification(t("execution_error_notify"), 3, function()
                switchPage("terminal")
            end)
            return
        end
        local oldPrint = print
        local oldWarn = warn
        print = function(...)
            local args = {...}
            local msg = table.concat(args, " ")
            AddLog(msg, "info")
            if logDedup then logDedup[msg] = tick() end
            oldPrint(...)
        end
        warn = function(...)
            local args = {...}
            local msg = table.concat(args, " ")
            AddLog(msg, "warn")
            if logDedup then logDedup[msg] = tick() end
            oldWarn(...)
        end
            _G.__DeltaUI_blockLogService = true
        local ok, execErr = xpcall(fn, function(err)
            return debug.traceback(tostring(err), 2)
        end)
            _G.__DeltaUI_blockLogService = nil
        print = oldPrint
        warn = oldWarn
        animRunning = false
        if scanCtrl then scanCtrl.Cancel() end
        if not ok then
            clearExecHighlights()
            _G.__DeltaUI_skipLineOffset = nil
            local errLine = parseErrorLine(tostring(execErr))
            if errLine then
                highlightExecLine(errLine, "error")
                scrollToLine(errLine, 3)
            end
            AddLog("[Error] " .. tostring(execErr), "error")
            ShowNotification(t("execution_error_notify"), 3, function()
                switchPage("terminal")
            end)
            return
        end
        clearExecHighlights()
        currentCodePage = 999999
        showCurrentPage()
        local pageText = codeBox.Text or ""
        local lastLine = select(2, pageText:gsub(string.char(10), "")) + 1
        if lastLine > 0 then
            highlightExecLine(lastLine, "success")
            scrollToLine(lastLine, 3)
        end
        task.delay(0.8, clearExecHighlights)
        AddLog("> " .. t("clipboard_finished"), "info")
        if execEntry and execEntry.Parent then
            execEntry.Text = "> " .. t("clipboard_finished")
            execEntry.TextColor3 = Color3.fromRGB(100, 180, 255)
        end
        _G.__DeltaUI_skipLineOffset = nil
    end)
end)
consolePage = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2})
consolePage.Parent = contentFrame

consoleEnabled = true

consoleClearBtn = create("TextButton", {
    Position = UDim2.new(0, 12, 1, -36),
    Size = UDim2.new(0, 80, 0, 28),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(6, consoleClearBtn)
consoleClearBtn.Parent = consolePage
consoleClearIcon = GetIcon("trash-2", UDim2.new(0, 12, 0, 12), theme.textDim)
if consoleClearIcon then
    consoleClearIcon.Position = UDim2.new(0, 8, 0.5, -6)
    consoleClearIcon.Parent = consoleClearBtn
end
consoleClearText = create("TextLabel", {
    Position = UDim2.new(0, 26, 0, 0),
    Size = UDim2.new(1, -28, 1, 0),
    BackgroundTransparency = 1,
    Text = t("clear"),
    TextColor3 = theme.text,
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    ZIndex = 6
})
consoleClearText.Parent = consoleClearBtn
table.insert(settingsData.uiRefs, {element = consoleClearText, key = "clear"})
consoleClearBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(consoleScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    logEntryCount = 0
    AddLog("> Console cleared", "info")
end)
local consoleHeader = create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 3})
corner(8, consoleHeader)
consoleHeader.Parent = consolePage
consoleTitle = create("TextLabel", {Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = t("console"), TextColor3 = theme.textDim, TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 4})
consoleTitle.Parent = consoleHeader
table.insert(settingsData.uiRefs, {element = consoleTitle, key = "console"})

consoleSettingsBtn = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.3,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(6, consoleSettingsBtn)
consoleSettingsBtn.Parent = consoleHeader
local consoleSettingsIcon = GetIcon("cog", UDim2.new(0, 14, 0, 14), theme.textDim)
if consoleSettingsIcon then
    consoleSettingsIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    consoleSettingsIcon.Parent = consoleSettingsBtn
end
consoleSettingsBtn.MouseButton1Click:Connect(function()
    switchPage("settings")
    task.wait(0.05)
    if not settingsScroll or not settingsScroll.Parent then return end
    local targetRow = nil
    for _, child in pairs(settingsScroll:GetChildren()) do
        if child:IsA("Frame") and child.LayoutOrder == 10 then
            targetRow = child
            break
        end
    end
    if not targetRow then return end
    local targetY = targetRow.AbsolutePosition.Y - settingsScroll.AbsolutePosition.Y - 12
    targetY = math.max(0, targetY)
    local maxY = math.max(0, settingsScroll.CanvasSize.Y.Offset - settingsScroll.AbsoluteSize.Y)
    targetY = math.min(targetY, maxY)
    svc.TweenService:Create(settingsScroll, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CanvasPosition = Vector2.new(0, targetY)
    }):Play()
end)

consoleScroll = create("ScrollingFrame", {Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, -10, 1, -30), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, ScrollBarImageColor3 = theme.textDim, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3})
consoleScroll.Parent = consolePage

consoleList = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
consoleList.Parent = consoleScroll
create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)}).Parent = consoleScroll

logService = game:GetService("LogService")
lastLogTime = 0
logDedup = {}
logService.MessageOut:Connect(function(msg, msgtype)
    if _G.__DeltaUI_blockLogService then return end
    local msgStr = tostring(msg)

    if msgStr:find("Overlay is not a valid member of ImageLabel")
        or msgStr:find("Error is not a valid member of Folder")
        or msgStr:find("ConsoleElements")
        or msgStr:find("AppDelegate")
        or msgStr:find("Arrow is not a valid member of ImageButton")
    then
        return

    end
    if settingsData.blockServerErrors and msgStr:find("ReplicatedStorage.") then
        return
    end
    if settingsData.blockAssetErrors then
        if msgStr:find("rbxassetid")
            or msgStr:find("assetdelivery")
            or msgStr:find("Animation failed to load")
            or msgStr:find("Failed to load animation")
            or msgStr:find("Failed to load")
            or msgStr:find("SurfaceAppearance")
            or msgStr:find("sanitized ID")
            or msgStr:find("assetId")
            or msgStr:find("rbx://")
        then
            return
        end
    end

    local now = tick()
    local key = (msgStr:gsub("  ", " "))
    if logDedup[key] and (now - logDedup[key]) < 2 then
        return
    end
    logDedup[key] = now

    if next(logDedup) ~= nil and now % 30 < 0.1 then
        for k, v in pairs(logDedup) do
            if now - v > 10 then
                logDedup[k] = nil
            end
        end
    end
    local level = "info"
    if msgtype == Enum.MessageType.MessageWarning then level = "warn"
    elseif msgtype == Enum.MessageType.MessageError then level = "error" end
    AddLog(msg, level)
end)
consoleList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if consoleScroll and consoleList and consoleScroll.Parent then
        local absSize = consoleList.AbsoluteContentSize
        if absSize then
            consoleScroll.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 20)
        end
    end
end)

scrollTrack = create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -2, 0, 32),
    Size = UDim2.new(0, 6, 1, -34),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    ZIndex = 2
})
corner(3, scrollTrack)
scrollTrack.Parent = consolePage
gamepadPage = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 2})
gamepadPage.Parent = contentFrame
updateBtn = create("TextButton", {
    Position = UDim2.new(0, 12, 0, 12),
    Size = UDim2.new(0, 110, 0, 26),
    BackgroundColor3 = theme.accent,
    BackgroundTransparency = 0.25,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(8, updateBtn)
updateBtn.Parent = gamepadPage

refreshBtn = create("TextButton", {
    Position = UDim2.new(1, -40, 0, 12),
    Size = UDim2.new(0, 32, 0, 26),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(8, refreshBtn)
refreshBtn.Parent = gamepadPage
refreshIcon = GetIcon("rotate-ccw", UDim2.new(0, 14, 0, 14), theme.text)
if refreshIcon then
    refreshIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    refreshIcon.Parent = refreshBtn
end
refreshBtn.MouseButton1Click:Connect(function()
    if refreshIcon then
        local rotation = 0
        local conn = svc.RunService.RenderStepped:Connect(function(dt)
            rotation = rotation - 720 * dt
            refreshIcon.Rotation = rotation
        end)
        task.delay(0.5, function()
            conn:Disconnect()
            refreshIcon.Rotation = 0
        end)
    end
    refreshScriptList(searchInput.Text)
    ShowNotification(t("refresh_complete"), 1)
end)

updateIcon = GetIcon("download", UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
if updateIcon then
    updateIcon.Position = UDim2.new(0, 8, 0.5, -6)
    updateIcon.Parent = updateBtn
end
updateText = create("TextLabel", {Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(0, 60, 1, 0), BackgroundTransparency = 1, Text = t("save"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 6})
updateText.Parent = updateBtn
table.insert(settingsData.uiRefs, {element = updateText, key = "save"})
modalOverlay = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 200,
    Active = true
})
modalOverlay.Parent = screenGui

searchBox = create("Frame", {
    Position = UDim2.new(0, 130, 0, 12),
    Size = UDim2.new(1, -178, 0, 26),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ZIndex = 5
})
corner(8, searchBox)
searchBox.Parent = gamepadPage
searchIcon = GetIcon("search", UDim2.new(0, 12, 0, 12), theme.textDim)
if searchIcon then
    searchIcon.Position = UDim2.new(0, 8, 0.5, -6)
    searchIcon.Parent = searchBox
end
searchInput = create("TextBox", {
    Position = UDim2.new(0, 26, 0, 0),
    Size = UDim2.new(1, -32, 1, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = t("search_scripts"),
    PlaceholderColor3 = theme.textDim,
    TextColor3 = theme.text,
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    ClearTextOnFocus = false,
    ZIndex = 6
})
searchInput.Parent = searchBox
create("UIPadding", {PaddingLeft = UDim.new(0, 5)}).Parent = searchInput
table.insert(settingsData.uiRefs, {element = searchInput, key = "search_scripts"})
searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    refreshScriptList(searchInput.Text)
end)
scriptListScroll = create("ScrollingFrame", {
    Position = UDim2.new(0, 12, 0, 52),
    Size = UDim2.new(1, -24, 1, -64),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.textDim,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 3
})
scriptListScroll.Parent = gamepadPage
scriptListLayout = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
scriptListLayout.Parent = scriptListScroll
create("UIPadding", {PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0), PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 8)}).Parent = scriptListScroll
modalCard = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 340, 0, 340),
    BackgroundColor3 = theme.surface,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 201,
    Active = true
})
corner(16, modalCard)
modalCard.Parent = modalOverlay
modalTitle = create("TextLabel", {
    Position = UDim2.new(0, 20, 0, 16),
    Size = UDim2.new(1, -40, 0, 28),
    BackgroundTransparency = 1,
    Text = t("Enter Details"),
    TextColor3 = theme.text,
    TextSize = 18,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 202
})
modalTitle.Parent = modalCard
modalSub = create("TextLabel", {
    Position = UDim2.new(0, 20, 0, 46),
    Size = UDim2.new(1, -40, 0, 40),
    BackgroundTransparency = 1,
    Text = t("Complete the necessary parameters to upload your client script"),
    TextColor3 = theme.textDim,
    TextSize = 12,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true,
    ZIndex = 202
})
modalSub.Parent = modalCard
modalClose = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -16, 0, 16),
    Size = UDim2.new(0, 28, 0, 28),
    BackgroundTransparency = 1,
    Text = "",
    ZIndex = 203
})
modalCloseIcon = GetIcon("x", UDim2.new(0, 18, 0, 18), theme.textDim)
if modalCloseIcon then
    modalCloseIcon.Position = UDim2.new(0.5, -9, 0.5, -9)
    modalCloseIcon.Parent = modalClose
end
modalClose.Parent = modalCard
modalClose.MouseButton1Click:Connect(function()
    modalOverlay.Visible = false
end)
titleBox = create("Frame", {
    Position = UDim2.new(0, 20, 0, 96),
    Size = UDim2.new(1, -40, 0, 56),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 202
})
corner(12, titleBox)
stroke(theme.border, 1, titleBox)
titleBox.Parent = modalCard
titleLabel = create("TextLabel", {
    Position = UDim2.new(0, 12, 0, 8),
    Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1,
    Text = t("Title"),
    TextColor3 = theme.textDim,
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 203
})
titleLabel.Parent = titleBox
titleInput = create("TextBox", {
    Position = UDim2.new(0, 12, 0, 26),
    Size = UDim2.new(1, -24, 0, 26),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = t("Enter Your Title..."),
    PlaceholderColor3 = theme.textDim,
    TextColor3 = theme.text,
    TextSize = 14,
    Font = Enum.Font.SourceSans,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    ClearTextOnFocus = false,
    ZIndex = 203
})
titleInput.Parent = titleBox
create("UIPadding", {PaddingLeft = UDim.new(0, 5)}).Parent = titleInput
scriptBox = create("Frame", {
    Position = UDim2.new(0, 20, 0, 164),
    Size = UDim2.new(1, -40, 0, 110),
    BackgroundColor3 = theme.surfaceLight,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 202
})
corner(12, scriptBox)
stroke(theme.border, 1, scriptBox)
scriptBox.Parent = modalCard
scriptLabel = create("TextLabel", {
    Position = UDim2.new(0, 12, 0, 8),
    Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1,
    Text = t("Script"),
    TextColor3 = theme.textDim,
    TextSize = 11,
    Font = Enum.Font.SourceSansBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 203
})
scriptLabel.Parent = scriptBox
scriptInput = create("TextBox", {
    Position = UDim2.new(0, 12, 0, 28),
    Size = UDim2.new(1, -24, 1, -36),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = t("Enter Your Script..."),
    PlaceholderColor3 = theme.textDim,
    TextColor3 = theme.text,
    TextSize = 13,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ClearTextOnFocus = false,
    MultiLine = true,
    TextWrapped = true,
    ZIndex = 203
})
scriptInput.Parent = scriptBox
create("UIPadding", {PaddingLeft = UDim.new(0, 5)}).Parent = scriptInput

updateBtn.MouseButton1Click:Connect(function()
    modalOverlay.Visible = true
    titleInput.Text = t("title_placeholder")
    scriptInput.Text = t("script_placeholder")
end)
addScriptBtn = create("TextButton", {
    Position = UDim2.new(0, 20, 1, -52),
    Size = UDim2.new(1, -40, 0, 40),
    BackgroundColor3 = theme.accent,
    BackgroundTransparency = 0.25,
    Text = "",
    BorderSizePixel = 0,
    ZIndex = 202
})
corner(10, addScriptBtn)
addScriptBtn.Parent = modalCard
addScriptText = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = t("Add Script"),
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 14,
    Font = Enum.Font.SourceSansBold,
    ZIndex = 203
})
addScriptText.Parent = addScriptBtn
addScriptBtn.MouseButton1Click:Connect(function()
    if addScriptBtn.Active == false then return end
    addScriptBtn.Active = false
    local title = titleInput.Text
    local scriptCode = scriptInput.Text
    if title == "" or title == t("title_placeholder") then
        addScriptBtn.Active = true
        return
    end
    if scriptCode == "" or scriptCode == t("script_placeholder") then
        addScriptBtn.Active = true
        return
    end
    ensureFolder()
    writefile(saveFolder .. "/" .. title, scriptCode)
    modalOverlay.Visible = false
    task.wait(0.1)
    refreshScriptList("")
    addScriptBtn.Active = true
end)
pages["package"] = cloudPage
pages["house"] = editorPage
pages["terminal"] = consolePage
pages["gamepad-2"] = gamepadPage
pages["atom"] = wasaiPage
function installModule(item)
    local safeName = __safeFilterName(item.name:gsub("%s+", "_"))
    if safeName == "" then safeName = "untitled" end
    local json = svc.HttpService:JSONEncode(item)
    if item.Type == "Patch" then
        ensurePatchFolder()
        writefile(patchFolder .. "/" .. safeName .. ".json", json)
        installedModules[item.name] = item
        AddLog("[Patch] Installed: " .. item.name .. " (v" .. tostring(item.Version or "?") .. ")", "info")
        ShowNotification(t("patch_installed_notify") or "Patch installed", 1)
        if item.Url and item.Url ~= "" then
            local ok, src = pcall(function()
                return game:HttpGet(item.Url)
            end)
            if ok and src and src ~= "" then
                local fn, err = loadstring(src)
                if fn then
                    xpcall(fn, function(e)
                        warn("[Patch] " .. item.name .. " error: " .. tostring(e))
                    end)
                else
                    warn("[Patch] " .. item.name .. " compile error: " .. tostring(err))
                end
            else
                warn("[Patch] " .. item.name .. " download failed")
            end
        end
    elseif item.Type == "UIUpdate" then
        ensureExportFolder()
        writefile(exportFolder .. "/" .. safeName .. ".json", json)
        if item.Url and item.Url ~= "" then
            local ok, src = pcall(function()
                return game:HttpGet(item.Url)
            end)
            if ok and src and src ~= "" then
                writefile(exportFolder .. "/" .. safeName .. ".lua", src)
                AddLog("[UIUpdate] Downloaded: " .. item.name .. " v" .. tostring(item.Version or "?"), "info")
                ShowNotification(t("ui_update_export"), 5)
            else
                AddLog("[UIUpdate] Download failed: " .. item.name, "error")
                ShowNotification(t("failed") .. " (UIUpdate)", 2)
            end
        end
    elseif item.Type == "UIPack" then
        ensureExportFolder()
        writefile(exportFolder .. "/" .. safeName .. ".json", json)
        installedModules[item.name] = item
        AddLog("[UIPack] Installed: " .. item.name .. " (v" .. tostring(item.Version or "?") .. ")", "info")
        ShowNotification(t("uipack_installed"), 1)
        if item.Url and item.Url ~= "" then
            local ok, src = pcall(function()
                return game:HttpGet(item.Url)
            end)
            if ok and src and src ~= "" then
                writefile(exportFolder .. "/" .. safeName .. ".lua", src)
            else
                warn("[UIPack] Download failed")
            end
        end
    else
        ensureModelFolder()
        if item.Type == "Script" then

            oldLua = storeScriptFolder .. "/" .. safeName .. ".lua"
            oldJson = modelFolder .. "/" .. safeName .. ".json"
            oldMeta = storeScriptFolder .. "/" .. safeName .. ".json"
            if isfile(oldLua) then delfile(oldLua) end
            if isfile(oldJson) then delfile(oldJson) end
            if isfile(oldMeta) then delfile(oldMeta) end

            if item.Url and item.Url ~= "" then
                local ok, src = pcall(function()
                    return game:HttpGet(item.Url)
                end)
                if ok and src and src ~= "" then
                    ensureStoreFolder()
                    writefile(storeScriptFolder .. "/" .. safeName .. ".lua", src)
                end
            end
            writefile(modelFolder .. "/" .. safeName .. ".json", json)
            installedModules[item.name] = item
            AddLog("[Script] Installed: " .. item.name .. " (v" .. tostring(item.Version or "?") .. ")", "info")
            ShowNotification(t("script_installed_notify"), 1)
            addStoreScriptToGamepad(item)
        elseif item.Type == "Model" then
            writefile(modelFolder .. "/" .. safeName .. ".json", json)
            installedModules[item.name] = item
            AddLog("[Model] Installed: " .. item.name .. " (v" .. tostring(item.Version or "?") .. ")", "info")
        end
    end
end
_G.__DeltaUI_installModule = installModule

function uninstallModule(name)
    local safeName = __safeFilterName(name:gsub("%s+", "_"))
    if safeName == "" then safeName = "untitled" end
    local fp = modelFolder .. "/" .. safeName .. ".json"
    local ok1, err1 = pcall(function()
        if isfile(fp) then delfile(fp) end
    end)
    if not ok1 then warn("[Uninstall] Failed to delete model: " .. tostring(err1)) end
    local pfp = patchFolder .. "/" .. safeName .. ".json"
    local ok2, err2 = pcall(function()
        if isfile(pfp) then delfile(pfp) end
    end)
    if not ok2 then warn("[Uninstall] Failed to delete patch: " .. tostring(err2)) end
    local sfp = storeScriptFolder .. "/" .. safeName .. ".json"
    local ok3, err3 = pcall(function()
        if isfile(sfp) then delfile(sfp) end
    end)
    if not ok3 then warn("[Uninstall] Failed to delete store meta: " .. tostring(err3)) end
    local lfp = storeScriptFolder .. "/" .. safeName .. ".lua"
    local ok4, err4 = pcall(function()
        if isfile(lfp) then delfile(lfp) end
    end)
    if not ok4 then warn("[Uninstall] Failed to delete store script: " .. tostring(err4)) end
    installedModules[name] = nil
    AddLog("[Uninstall] " .. name, "info")
end
_G.__DeltaUI_uninstallModule = uninstallModule

infoCurrentItem = nil
infoOverlay = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0, Visible = false, ZIndex = 300, Active = true})
infoOverlay.Parent = screenGui
infoCard = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 320, 0, 280), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 301, Active = true})
corner(16, infoCard)
infoCard.Parent = infoOverlay
infoTitle = create("TextLabel", {Position = UDim2.new(0, 20, 0, 16), Size = UDim2.new(1, -40, 0, 24), BackgroundTransparency = 1, Text = "", TextColor3 = theme.text, TextSize = 16, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302})
infoTitle.Parent = infoCard
infoAuthor = create("TextLabel", {Position = UDim2.new(0, 20, 0, 44), Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1, Text = "", TextColor3 = theme.textDim, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302})
infoAuthor.Parent = infoCard
infoVersion = create("TextLabel", {Position = UDim2.new(0, 20, 0, 64), Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1, Text = "", TextColor3 = theme.accent, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302})
infoVersion.Parent = infoCard
infoType = create("TextLabel", {Position = UDim2.new(0, 20, 0, 84), Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1, Text = "", TextColor3 = theme.textDim, TextSize = 12, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302})
infoType.Parent = infoCard
infoServersTitle = create("TextLabel", {Position = UDim2.new(0, 20, 0, 108), Size = UDim2.new(1, -40, 0, 18), BackgroundTransparency = 1, Text = t("supported_servers_title"), TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 302})
infoServersTitle.Parent = infoCard
infoServersScroll = create("ScrollingFrame", {Position = UDim2.new(0, 20, 0, 128), Size = UDim2.new(1, -40, 0, 80), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = theme.textDim, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 302})
infoServersScroll.Parent = infoCard
create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}).Parent = infoServersScroll
create("UIPadding", {PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0), PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 4)}).Parent = infoServersScroll
local infoScrollHint = create("Frame", {Position = UDim2.new(0.5, -10, 1, -62), Size = UDim2.new(0, 20, 0, 14), BackgroundTransparency = 1, ZIndex = 303})
infoScrollHint.Parent = infoCard
local infoScrollHintIcon = GetIcon("chevron-down", UDim2.new(0, 14, 0, 14), theme.textDim)
if infoScrollHintIcon then
    infoScrollHintIcon.Position = UDim2.new(0.5, -7, 0, 0)
    infoScrollHintIcon.Parent = infoScrollHint
end
infoBackBtn = create("TextButton", {Position = UDim2.new(0.5, -50, 1, -44), Size = UDim2.new(0, 100, 0, 32), BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25, Text = "", BorderSizePixel = 0, ZIndex = 302})
corner(8, infoBackBtn)
infoBackBtn.Parent = infoCard
infoBackText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("back"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13, Font = Enum.Font.SourceSansBold, ZIndex = 303})
infoBackText.Parent = infoBackBtn
infoBackBtn.MouseButton1Click:Connect(function()
    infoOverlay.Visible = false
end)
infoDeleteBtn = create("TextButton", {Position = UDim2.new(1, -44, 1, -44), Size = UDim2.new(0, 32, 0, 32), BackgroundColor3 = theme.red, BackgroundTransparency = 0.25, Text = "", BorderSizePixel = 0, ZIndex = 302, Visible = false})
corner(8, infoDeleteBtn)
infoDeleteBtn.Parent = infoCard
deleteIcon = GetIcon("trash-2", UDim2.new(0, 14, 0, 14), Color3.fromRGB(255,255,255))
if deleteIcon then
    deleteIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    deleteIcon.Parent = infoDeleteBtn
end
infoDeleteBtn.MouseButton1Click:Connect(function()
    if infoCurrentItem and infoCurrentItem.Type == "Patch" then
        uninstallModule(infoCurrentItem.name)
        ShowNotification(t("patch_deleted"), 1)
        infoOverlay.Visible = false
        refreshCloudList("", false)
    end
end)
infoOverlay.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local cardPos = infoCard.AbsolutePosition
        local cardSize = infoCard.AbsoluteSize
        if pos.X < cardPos.X or pos.X > cardPos.X + cardSize.X or pos.Y < cardPos.Y or pos.Y > cardPos.Y + cardSize.Y then
            infoOverlay.Visible = false
        end
    end
end)

function addStoreScriptToGamepad(item)
    ensureStoreFolder()
    local safeName = __safeFilterName(item.name:gsub("%s+", "_"))
    if safeName == "" then safeName = "untitled" end
    local meta = {
        name = item.name,
        Type = "Script",
        Desc = item.Desc,
        Url = item.Url,
        Version = item.Version,
        fromStore = true,
        Servers = item.Servers,
        Icon = item.Icon
    }
    local json = svc.HttpService:JSONEncode(meta)
    writefile(storeScriptFolder .. "/" .. safeName .. ".json", json)
    installedModules[item.name] = meta
    refreshScriptList(searchInput.Text)
end
_G.__DeltaUI_removeStoreScript = removeStoreScript

function removeStoreScript(name)
    ensureStoreFolder()
    local safeName = __safeFilterName(name:gsub("%s+", "_"))
    if safeName == "" then safeName = "untitled" end
    local fp = storeScriptFolder .. "/" .. safeName .. ".json"
    if isfile(fp) then
        delfile(fp)
    end
    installedModules[name] = nil
    refreshScriptList(searchInput.Text)
end

function makeModuleCard(item, layoutOrder, isManageMode, filter)
    filter = filter or ""
        local isInstalled = installedModules[item.name] ~= nil
    local localVersion = isInstalled and installedModules[item.name].Version or nil
    local remoteVersion = item.Version
    local hasUpdate = isInstalled and localVersion and remoteVersion and localVersion ~= remoteVersion

    local card = create("Frame", {Size = UDim2.new(0, 180, 0, 140), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.25, BorderSizePixel = 0, LayoutOrder = layoutOrder, ZIndex = 4})
    corner(10, card)

    local iconContainer = create("Frame", {Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(0, 36, 0, 36), BackgroundColor3 = theme.surfaceLight, BackgroundTransparency = 0.4, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 5})
    corner(6, iconContainer)
    iconContainer.Parent = card

    local function clearIconChildren()
        for _, child in pairs(iconContainer:GetChildren()) do
            if child:IsA("ImageLabel") and child ~= iconContainer then
                child:Destroy()
            end
        end
    end

    if item.Icon and item.Icon ~= "" then
        local parsedIcon = getCachedIcon(item.Icon, item.name)
        if not parsedIcon or parsedIcon == "" then
            parsedIcon = ParseImageAsset(item.Icon)
        end
        if parsedIcon and parsedIcon ~= "" then
            clearIconChildren()
            local iconImg = create("ImageLabel", {Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, Image = parsedIcon, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 6})
            iconImg.Parent = iconContainer
            corner(4, iconImg)
            svc.TweenService:Create(iconImg, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
        else
            clearIconChildren()
        end
    else
        clearIconChildren()
    end

    local nameLabel = create("TextLabel", {Position = UDim2.new(0, 50, 0, 8), Size = UDim2.new(1, -58, 0, 20), BackgroundTransparency = 1, Text = item.name, TextColor3 = theme.text, TextSize = 13, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5})
    nameLabel.Parent = card

    if item.Type == "Patch" and not isManageMode then
        local patchBadge = create("Frame", {Position = UDim2.new(1, -55, 0, 28), Size = UDim2.new(0, 50, 0, 14), BackgroundColor3 = theme.red, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 6})
        corner(7, patchBadge)
        local patchBadgeText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("patch_must_install"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 8, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 7})
        patchBadgeText.Parent = patchBadge
        patchBadge.Parent = card
    end

    local authorText = item.Author and item.Author ~= "" and item.Author or "Unknown"
    local authorLabel = create("TextLabel", {Position = UDim2.new(0, 50, 0, 28), Size = UDim2.new(1, -58, 0, 16), BackgroundTransparency = 1, Text = t("by_label") .. authorText, TextColor3 = theme.textDim, TextSize = 10, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    authorLabel.Parent = card
    local hasPatch = (item.Type == "Patch")
    if filter and filter ~= "" then
        local isMatch = false
        if item.Servers and type(item.Servers) == "table" then
            for _, server in ipairs(item.Servers) do
                if tostring(server):lower():find(filter:lower()) then
                    isMatch = true
                    break
                end
            end
        end
        if isMatch then
            local badgeY = hasPatch and 44 or 28
            local matchBadge = create("Frame", {Position = UDim2.new(1, -60, 0, badgeY), Size = UDim2.new(0, 55, 0, 14), BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25, BorderSizePixel = 0, ZIndex = 6})
            corner(7, matchBadge)
            local matchBadgeText = create("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = t("match_search"), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 8, Font = Enum.Font.SourceSansBold, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 7})
            matchBadgeText.Parent = matchBadge
            matchBadge.Parent = card
        end
    end

    local descLabel = create("TextLabel", {Position = UDim2.new(0, 8, 0, 44), Size = UDim2.new(1, -16, 0, 48), BackgroundTransparency = 1, Text = item.Desc or "", TextColor3 = theme.textDim, TextSize = 10, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, ZIndex = 5})
    descLabel.Parent = card

    local versionLabel = create("TextLabel", {Position = UDim2.new(0, 8, 0, 90), Size = UDim2.new(1, -16, 0, 14), BackgroundTransparency = 1, Text = "", TextColor3 = theme.textDim, TextSize = 9, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5})
    versionLabel.Parent = card
    if isManageMode and isInstalled then
        versionLabel.Text = t("local_version") .. (localVersion or "?") .. " | Remote: " .. (remoteVersion or "?")
    elseif hasUpdate then
        versionLabel.Text = t("update_version") .. (localVersion or "?") .. " -> " .. (remoteVersion or "?")
    end

    local actionBtn = create("TextButton", {Position = UDim2.new(0, 8, 1, -36), Size = UDim2.new(1, -44, 0, 28), BackgroundColor3 = isManageMode and (hasUpdate and theme.accent or theme.red) or (isInstalled and (hasUpdate and theme.accent or theme.surfaceLight) or theme.accent), BackgroundTransparency = 0.25, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(6, actionBtn)
    actionBtn.Parent = card

    local progressBar = create("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(34, 197, 94), BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 4})
    corner(6, progressBar)
    progressBar.Parent = actionBtn

    local actionText = create("TextLabel", {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = isManageMode and (hasUpdate and t("update") or t("uninstall")) or (isInstalled and (hasUpdate and t("update") or t("installed")) or t("install")), TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11, Font = Enum.Font.SourceSansBold, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 6})
    actionText.Parent = actionBtn

    local actionSubText = create("TextLabel", {Position = UDim2.new(0, 0, 0.65, 0), Size = UDim2.new(1, 0, 0.35, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(200,200,200), TextSize = 8, Font = Enum.Font.SourceSans, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 6})
    actionSubText.Parent = actionBtn
    actionSubText.Visible = false

    local actionIcon = GetIcon(isManageMode and (hasUpdate and "download" or "trash-2") or (isInstalled and "check" or "download"), UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
    if actionIcon then
        actionIcon.Position = UDim2.new(0, 8, 0.5, -6)
        actionIcon.Parent = actionBtn
    end

    local checkIcon = nil
    if not isManageMode then
        checkIcon = GetIcon("check", UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
        if checkIcon then
            checkIcon.Position = UDim2.new(0, 8, 0.5, -6)
            checkIcon.Parent = actionBtn
            checkIcon.Visible = isInstalled and not hasUpdate
        end
    end
    local loaderIcon = GetIcon("loader", UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
    if loaderIcon then
        loaderIcon.Position = UDim2.new(0, 8, 0.5, -6)
        loaderIcon.Visible = false
        loaderIcon.Parent = actionBtn
    end

    local infoBtn = create("TextButton", {Position = UDim2.new(1, -32, 1, -36), Size = UDim2.new(0, 28, 0, 28), BackgroundColor3 = theme.surfaceLight, BackgroundTransparency = 0.3, Text = "", BorderSizePixel = 0, ZIndex = 5})
    corner(6, infoBtn)
    infoBtn.Parent = card
    local infoIcon = GetIcon("info", UDim2.new(0, 14, 0, 14), theme.text)
    if infoIcon then
        infoIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
        infoIcon.Parent = infoBtn
    end

    local downloading = false

    local function setProgress(percent, text, subText)
        svc.TweenService:Create(progressBar, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Size = UDim2.new(percent / 100, 0, 1, 0)}):Play()
        actionText.Text = text or ""
        actionSubText.Text = subText or ""
    end

    local function startDownload()
        if isInstalled and not hasUpdate then
            return
        end
        if downloading then return end
        local downloading = true
        actionBtn.BackgroundColor3 = theme.surface
        actionBtn.BackgroundTransparency = 0.5
        progressBar.Size = UDim2.new(0, 0, 1, 0)
        if actionIcon then actionIcon.Visible = false end
        if loaderIcon then loaderIcon.Visible = true end
        actionText.Position = UDim2.new(0, 0, 0, -2)
        actionText.Text = t("downloading")
        actionSubText.Visible = true
        actionSubText.Text = "0KB/0KB"

        rotation = 0
        local conn = svc.RunService.RenderStepped:Connect(function(dt)
            rotation = rotation + 360 * dt
            if loaderIcon then
                loaderIcon.Rotation = rotation
            end
        end)

        local receivedBytes = 0
        local totalBytes = 0

        task.spawn(function()
            local src = game:HttpGet(item.Url)

            if not src then

                local src2 = game:HttpGet(item.Url)

                local src = src2
                if src then
                    totalBytes = #src
                    receivedBytes = totalBytes
                end
            end

            conn:Disconnect()

            if src then
                local size = #src
                local sizeText, totalText
                if size > 1048576 then
                    sizeText = string.format("%.1fMB", size / 1048576)
                    totalText = sizeText
                else
                    sizeText = string.format("%.0fKB", size / 1024)
                    totalText = sizeText
                end

                svc.TweenService:Create(progressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
                actionSubText.Text = sizeText .. "/" .. totalText
                task.wait(0.5)

                installModule(item)
                isInstalled = true
                hasUpdate = false

                svc.TweenService:Create(progressBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                svc.TweenService:Create(actionBtn, TweenInfo.new(0.3), {BackgroundColor3 = theme.accent, BackgroundTransparency = 0.25}):Play()
                actionText.Text = t("complete")
                actionSubText.Visible = false
                if loaderIcon then loaderIcon.Visible = false end
                if checkIcon then checkIcon.Visible = true end

                task.wait(0.8)
                svc.TweenService:Create(actionText, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
                if checkIcon then svc.TweenService:Create(checkIcon, TweenInfo.new(0.2), {ImageTransparency = 1}):Play() end
                task.wait(0.2)
                actionText.Text = t("installed")
                actionText.Position = UDim2.new(0, 0, 0, 0)
                actionSubText.Text = ""
                svc.TweenService:Create(actionText, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
                if checkIcon then
                    checkIcon.Visible = true
                    svc.TweenService:Create(checkIcon, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
                end
                if actionIcon then actionIcon.Visible = false end
                actionBtn.BackgroundColor3 = theme.surfaceLight
                downloading = false
                actionBtn.Active = true

                if item.Type == "Script" then
                    addStoreScriptToGamepad(item)
                    AddLog("[Script] Installed to Gamepad: " .. item.name, "info")
                elseif item.Type == "UIUpdate" then
                    AddLog("[UIUpdate] Saved to Export: " .. item.name, "info")
                end
            else
                actionBtn.BackgroundColor3 = theme.red
                actionText.Position = UDim2.new(0, 0, 0, 0)
                actionText.Text = t("failed")
                actionSubText.Visible = false
                actionSubText.Text = ""
                if loaderIcon then loaderIcon.Visible = false end
                if actionIcon then actionIcon.Visible = true end
                downloading = false
                AddLog("[Cloud] Download failed: " .. item.name, "error")
            end
        end)
    end

    actionBtn.MouseButton1Click:Connect(function()
        if actionBtn.Active == false then return end
        actionBtn.Active = false
        if isManageMode then
            if item.Type == "Patch" then
                ShowNotification(t("patch_cannot_delete"), 1)
                actionBtn.Active = true
                return
            end
            if hasUpdate then
                actionBtn.BackgroundColor3 = theme.surface
                actionBtn.BackgroundTransparency = 0.5
                progressBar.Size = UDim2.new(0, 0, 1, 0)
                progressBar.BackgroundColor3 = theme.accent
                if actionIcon then actionIcon.Visible = false end
                if loaderIcon then loaderIcon.Visible = true end
                actionText.Text = t("updating")
                actionSubText.Visible = true
                actionSubText.Text = "0%"
                local rotation = 0
                local conn = svc.RunService.RenderStepped:Connect(function(dt)
                    rotation = rotation + 360 * dt
                    if loaderIcon then
                        loaderIcon.Rotation = rotation
                    end
                end)
                svc.TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
                task.wait(0.4)
                actionSubText.Text = "100%"
                conn:Disconnect()
                task.wait(0.2)
                local src = game:HttpGet(item.Url)
                if src then
                    installModule(item)
                    isInstalled = true
                    hasUpdate = false
                    localVersion = remoteVersion
                    versionLabel.Text = t("local_version") .. (localVersion or "?") .. " | Remote: " .. (remoteVersion or "?")
                    svc.TweenService:Create(progressBar, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    svc.TweenService:Create(actionBtn, TweenInfo.new(0.3), {BackgroundColor3 = theme.red, BackgroundTransparency = 0.25}):Play()
                    actionText.Text = t("uninstall")
                    actionSubText.Visible = false
                    if loaderIcon then loaderIcon.Visible = false end
                    if actionIcon then actionIcon.Visible = true end
                    local updatedIcon = GetIcon("trash-2", UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
                    if updatedIcon then
                        actionIcon.Image = updatedIcon.Image
                    end
                    AddLog("[Update] " .. item.name .. " updated to v" .. (remoteVersion or "?"), "info")
                else
                    actionBtn.BackgroundColor3 = theme.red
                    actionText.Text = t("failed")
                    actionSubText.Visible = false
                    if loaderIcon then loaderIcon.Visible = false end
                    if actionIcon then actionIcon.Visible = true end
                    AddLog("[Update] Failed to update " .. item.name, "error")
                end
            else
                actionBtn.BackgroundColor3 = theme.red
                actionText.Text = t("uninstalling")
                if actionIcon then actionIcon.Visible = false end
                local spinIcon = GetIcon("loader", UDim2.new(0, 12, 0, 12), Color3.fromRGB(255,255,255))
                if spinIcon then
                    spinIcon.Position = UDim2.new(0, 8, 0.5, -6)
                    spinIcon.Parent = actionBtn
                    rotation = 0
                    local conn = svc.RunService.RenderStepped:Connect(function(dt)
                        rotation = rotation + 360 * dt
                        spinIcon.Rotation = rotation
                    end)
                    task.wait(0.8)
                    conn:Disconnect()
                    spinIcon:Destroy()
                end
                uninstallModule(item.name)
                actionBtn.BackgroundColor3 = theme.surface
                actionBtn.BackgroundTransparency = 0.5
                progressBar.Size = UDim2.new(0, 0, 1, 0)
                progressBar.BackgroundColor3 = theme.red
                if actionIcon then actionIcon.Visible = false end
                if loaderIcon then loaderIcon.Visible = true end
                actionText.Text = t("uninstalling")
                actionSubText.Visible = true
                actionSubText.Text = "0%"
                local rotation = 0
                local conn = svc.RunService.RenderStepped:Connect(function(dt)
                    rotation = rotation + 360 * dt
                    if loaderIcon then
                        loaderIcon.Rotation = rotation
                    end
                end)
                svc.TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
                task.wait(0.4)
                actionSubText.Text = "100%"
                conn:Disconnect()
                task.wait(0.2)
                svc.TweenService:Create(progressBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                svc.TweenService:Create(actionBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                for _, d in pairs(card:GetDescendants()) do
                    if d:IsA("GuiObject") then
                        local fadeProps = {}
                        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                            fadeProps.TextTransparency = 1
                        end
                        if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                            fadeProps.ImageTransparency = 1
                        end
                        if next(fadeProps) then
                            svc.TweenService:Create(d, TweenInfo.new(0.15), fadeProps):Play()
                        end
                    end
                end
                task.wait(0.15)
                svc.TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
                task.wait(0.25)
                card:Destroy()
                if refreshCloudList then
                    refreshCloudList(cloudSearchInput.Text, false)
                end
            end
        elseif isInstalled and not hasUpdate then
            local originalColor = actionBtn.BackgroundColor3
            actionBtn.BackgroundColor3 = theme.surfaceLight
            task.wait(0.15)
            actionBtn.BackgroundColor3 = originalColor
        else
            startDownload()
        end
    end

    )

    infoBtn.MouseButton1Click:Connect(function()
        infoCurrentItem = item
        infoTitle.Text = item.name
        infoAuthor.Text = t("author_label") .. (item.Author and item.Author ~= "" and item.Author or "Unknown")
        infoVersion.Text = t("version_label") .. (item.Version or "?")
        if isInstalled and localVersion then
            infoVersion.Text = infoVersion.Text .. " (Installed: " .. localVersion .. ")"
        end
        infoType.Text = t("type_label") .. (item.Type or "Unknown")
        for _, child in pairs(infoServersScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        local currentFilter = cloudSearchInput.Text
        local searchPlaceholder = t("search_cloud_placeholder")
                if item.Servers and type(item.Servers) == "table" and #item.Servers > 0 then
            local sortedServers = {}
            for _, server in ipairs(item.Servers) do
                table.insert(sortedServers, tostring(server))
            end
            if currentFilter and currentFilter ~= "" then
                table.sort(sortedServers, function(a, b)
                    local aMatch = a:lower():find(currentFilter:lower()) ~= nil
                    local bMatch = b:lower():find(currentFilter:lower()) ~= nil
                    if aMatch and not bMatch then return true end
                    if bMatch and not aMatch then return false end
                    return a < b
                end)
            end
            for i, server in ipairs(sortedServers) do
                local isMatch = currentFilter ~= "" and server:lower():find(currentFilter:lower()) ~= nil
                local serverLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "• " .. server, TextColor3 = isMatch and theme.accent or theme.textDim, TextSize = 11, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 303})
                serverLabel.Parent = infoServersScroll
            end
        else
            local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = t("no_server_restrictions"), TextColor3 = theme.textDim, TextSize = 11, Font = Enum.Font.SourceSans, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 303})
            emptyLabel.Parent = infoServersScroll
        end
        if infoDeleteBtn then
            infoDeleteBtn.Visible = (item.Type == "Patch" and isInstalled)
        end
        infoOverlay.Visible = true
    end)

    return card
end
_G.__DeltaUI_cloudRefreshLock = cloudRefreshLock

cloudRefreshLock = false
pendingCloudRefresh = nil

function refreshCloudList(filter, manageMode)
        if cloudRefreshLock then
        pendingCloudRefresh = {filter = filter or "", manageMode = manageMode}
        return
    end
    cloudRefreshLock = true

    for _, child in pairs(cloudScroll:GetChildren()) do
        if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local idx = 0
    if manageMode then
        loadInstalledModules()
        local seen = {}
        for name, item in pairs(installedModules) do
            if not seen[item.name] then
                seen[item.name] = true
                local matchesFilter = not filter or filter == "" or item.name:lower():find(filter:lower()) or (item.Desc and item.Desc:lower():find(filter:lower()))
                if not matchesFilter and item.Servers and type(item.Servers) == "table" then
                    for _, server in ipairs(item.Servers) do
                        if tostring(server):lower():find(filter:lower()) then
                            matchesFilter = true
                            break
                        end
                    end
                    if not matchesFilter and #item.Servers == 1 and tostring(item.Servers[1]):lower() == "all" then
                        local universalTokens = {["通用"]=true, ["飞行"]=true, ["加速"]=true, ["天空盒"]=true, ["甩飞"]=true, ["透视"]=true, ["绘制"]=true, ["esp"]=true, ["自瞄"]=true, ["追踪"]=true}
                        if universalTokens[filter:lower()] then
                            matchesFilter = true
                        end
                    end
                end
                if matchesFilter then
                    idx = idx + 1
                    local card = makeModuleCard(item, idx, true, filter)
                    card.Parent = cloudScroll
                    card.BackgroundTransparency = 1
                    card.Size = UDim2.new(0, 180, 0, 140)
                    svc.TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25, Size = UDim2.new(0, 180, 0, 140)}):Play()
                end
            end
        end
        if idx == 0 then
            local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = t("no_installed_packages"), TextColor3 = theme.textDim, TextSize = 14, Font = Enum.Font.SourceSansBold, ZIndex = 4})
            emptyLabel.Parent = cloudScroll
            svc.TweenService:Create(emptyLabel, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
        end
    else
        local ok, raw = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/main/model.json")
        end)
        if not ok or not raw or raw == "" then
            AddLog("[Cloud] Failed to fetch module list: " .. tostring(raw), "error")
            cloudRefreshLock = false
            if pendingCloudRefresh then
                local req = pendingCloudRefresh
                pendingCloudRefresh = nil
                refreshCloudList(req.filter, req.manageMode)
            end
            return
        end
        local ok2, list = pcall(function()
            return svc.HttpService:JSONDecode(raw)
        end)
        if not ok2 or not list or type(list) ~= "table" then
            AddLog("[Cloud] JSON parse error: " .. tostring(list), "error")
            cloudRefreshLock = false
            if pendingCloudRefresh then
                local req = pendingCloudRefresh
                pendingCloudRefresh = nil
                refreshCloudList(req.filter, req.manageMode)
            end
            return
        end
        if list.UIVersion then
            checkUiVersion(list.UIVersion)
        end
        local items = {}
        if list.modules and type(list.modules) == "table" then
            items = list.modules
        elseif list[1] then
            items = list
        else
            items = {list}
        end
        local remotePatchNames = {}
        local remoteUIVersion = list.UIVersion
        checkUiVersion(remoteUIVersion)
        for _, item in ipairs(items) do
            if type(item) == "table" and item.name and item.Type ~= "Model" then
                if not (item.Type == "UIUpdate" and tostring(remoteUIVersion) == tostring(UI_VERSION)) then
                if item.Type == "Patch" then
                    remotePatchNames[item.name] = true
                    if not installedModules[item.name] then
                        ShowNotification(t("patch_available") .. ": " .. item.name, 3, function()
            switchPage("package")
        end)
                    end
                end
                local shouldSkip = (item.Type == "Patch" and installedModules[item.name] and not manageMode)
                if not shouldSkip then
                    local matchesFilter = not filter or filter == "" or item.name:lower():find(filter:lower()) or (item.Desc and item.Desc:lower():find(filter:lower()))
                    if not matchesFilter and item.Servers and type(item.Servers) == "table" then
                        for _, server in ipairs(item.Servers) do
                            if tostring(server):lower():find(filter:lower()) then
                                matchesFilter = true
                                break
                            end
                        end
                    end
                    if matchesFilter then
                        idx = idx + 1
                        local card = makeModuleCard(item, idx, false, filter)
                        card.Parent = cloudScroll
                        card.BackgroundTransparency = 1
                        card.Size = UDim2.new(0, 180, 0, 140)
                        svc.TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25, Size = UDim2.new(0, 180, 0, 140)}):Play()
                    end
                end
                end
            end
        end
        if idx == 0 then
            local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = t("no_packages_available"), TextColor3 = theme.textDim, TextSize = 14, Font = Enum.Font.SourceSansBold, ZIndex = 4})
            emptyLabel.Parent = cloudScroll
            svc.TweenService:Create(emptyLabel, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
        end
        if cloudScroll and cloudGrid and cloudScroll.Parent then
            task.defer(function()
                if cloudScroll and cloudGrid and cloudScroll.Parent then
                    local absSize = cloudGrid.AbsoluteContentSize
                    if absSize then
                        cloudScroll.CanvasSize = UDim2.new(0, 0, 0, absSize.Y + 16)
                    end
                end
            end)
        end
        loadInstalledModules()
        for name, item in pairs(installedModules) do
            if item.Type == "Patch" then
                local stillExists = false
                for _, remoteItem in ipairs(items) do
                    if remoteItem.name == name and remoteItem.Type == "Patch" then
                        stillExists = true
                        break
                    end
                end
                if not stillExists then
                    uninstallModule(name)
                    ShowNotification(t("patch_not_found"), 2)
                end
            end
        end
    end
    cloudRefreshLock = false
    if pendingCloudRefresh then
        local req = pendingCloudRefresh
        pendingCloudRefresh = nil
        refreshCloudList(req.filter, req.manageMode)
    end
end
cloudSearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    refreshScriptBloxList(cloudSearchInput.Text)
end)

task.spawn(function()
    task.wait(0.5)
    local ok, err = pcall(function()
        refreshScriptBloxList("")
    end)
    if not ok then
        warn("[Cloud] Initial refresh error: " .. tostring(err))
    end
end)

cleanupOldUI()
_G.__DeltaUI_cleaned = true

function applyBypassMode()
    local cfg = loadConfig()
    if not cfg.bypassUiDetection then return end
    bypassModeActive = true
        local function makeInstantTween(target, info, props)
        if target and type(props) == "table" then
            for k, v in pairs(props) do
                pcall(function() target[k] = v end)
            end
        end
        local fakeSignal = {}
        fakeSignal.Connect = function(_, cb)
            if type(cb) == "function" then task.spawn(function() pcall(cb) end) end
            return {Disconnect = function() end}
        end
        local fake = {Play = function() end, Cancel = function() end, Pause = function() end}
        fake.Completed = fakeSignal
        return fake
    end
    svc.TweenService = setmetatable({Create = function(_, target, info, props) return makeInstantTween(target, info, props) end}, {__index = realTweenService})
        pages["terminal"] = nil
    if consolePage then consolePage.Visible = false end
                navNames = {"house", "gamepad-2", "package", "settings"}
    btnXPositions = {4, 44, 84, 124}
    if navButtons and navButtons["terminal"] then navButtons["terminal"].Visible = false end
        if logoutBtn then logoutBtn.Position = UDim2.new(0.5, 107, 0.5, 1) end
        if settingsScroll then
        for _, child in ipairs(settingsScroll:GetChildren()) do
            if child ~= rowBypass and child.ClassName ~= "UIListLayout" and child.ClassName ~= "UIPadding" then
                child.Visible = false
            end
        end
    end
        for _, lbl in ipairs(allFpsLabels or {}) do if lbl and lbl.Parent then lbl.Text = "N/A" end end
    for _, lbl in ipairs(allPingLabels or {}) do if lbl and lbl.Parent then lbl.Text = "N/A" end end
        pcall(function() switchPage("settings") end)
end
applyBypassMode()

main.Size = UDim2.new(0, 0, 0, 0)
main.Visible = true
svc.TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()

AddLog("[DeltaUI] Core loaded v" .. uiVersion, "info")
ShowNotification(t("core_loaded"), 1)
initFloatingBallIcon()

if refreshScriptList then
    refreshScriptList("")
end

local cfg = loadConfig()
if cfg.language then
    settingsData.language = cfg.language
else
    settingsData.language = "zh"
    cfg.language = "zh"
    saveConfig(cfg)
end
if cfg.errorTranslation ~= nil then
    settingsData.errorTranslation = cfg.errorTranslation
else
    settingsData.errorTranslation = true
end
if cfg.blockAssetErrors ~= nil then
    settingsData.blockAssetErrors = cfg.blockAssetErrors
else
    settingsData.blockAssetErrors = true
end
if cfg.customLabel and cfg.customLabel ~= "" then
    if labelText and labelText.Parent then
        labelText.Text = cfg.customLabel
        local textWidth = labelText.TextBounds.X + 28
        labelPill.Size = UDim2.new(0, math.max(55, textWidth), 0, 22)
    end
    if labelInput and labelInput.Parent then
        labelInput.Text = cfg.customLabel
    end
end
if cfg.autoTranslate then
    task.delay(1, function()
        startAutoTranslate()
    end)
end
if cfg.translatePaths and type(cfg.translatePaths) == "table" then
    for _, path in ipairs(cfg.translatePaths) do
        if path == t("playergui_path") then
            local pg = svc.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                scanAndTranslate(pg)
            end
        else
            scanAndTranslate(svc.CoreGui)
        end
    end
end
for _, ref in ipairs(settingsData.uiRefs) do
    if ref.element and ref.element.Parent then
        if ref.element:IsA("TextBox") and (ref.key == "search_scripts" or ref.key == "search_cloud_placeholder") then
            ref.element.PlaceholderText = t(ref.key)
            ref.element.Text = ""
        else
            ref.element.Text = t(ref.key)
        end
    end
end

if refreshScriptBloxList then
    refreshScriptBloxList(cloudSearchInput.Text)
end

customTabOrder = loadTabOrder()
applyTabOrder()
loadTabIcons()
applyTabIcons()

runAutoExecScripts()
AntiTamper.start()

_G.__DeltaUI_makeModuleCard = makeModuleCard

_G.__DeltaUI_loadInstalledModules = loadInstalledModules
_G.__DeltaUI_refreshCloudList = refreshCloudList
_G.__DeltaUI_switchPage = switchPage
_G.__DeltaUI_removeStoreScript = removeStoreScript
_G.__DeltaUI_addStoreScriptToGamepad = addStoreScriptToGamepad
_G.__DeltaUI_AddLog = AddLog
_G.__DeltaUI_create = create
_G.__DeltaUI_t = t
_G.__DeltaUI_theme = theme
_G.__DeltaUI_storeScriptFolder = storeScriptFolder
_G.__DeltaUI_ensureStoreFolder = ensureStoreFolder
_G.__DeltaUI_ensureModelFolder = ensureModelFolder
_G.__DeltaUI_ensurePatchFolder = ensurePatchFolder
_G.__DeltaUI_modelFolder = modelFolder
_G.__DeltaUI_patchFolder = patchFolder
_G.__DeltaUI_checkUiVersion = checkUiVersion
_G.__DeltaUI_currentPage = currentPage
_G.__DeltaUI_pages = pages
_G.__DeltaUI_bottomBar = bottomBar
_G.__DeltaUI_navButtons = navButtons
_G.__DeltaUI_animateIndicator = animateIndicator
_G.__DeltaUI_cloudSearchInput = cloudSearchInput
_G.__DeltaUI_searchInput = searchInput
_G.__DeltaUI_refreshScriptList = refreshScriptList
_G.__DeltaUI_cloudRefreshLock = cloudRefreshLock
_G.__DeltaUI_pendingCloudRefresh = pendingCloudRefresh
_G.__DeltaUI_cloudScroll = cloudScroll
_G.__DeltaUI_cloudGrid = cloudGrid
_G.__DeltaUI_installedModules = installedModules
_G.__DeltaUI_makeModuleCard = makeModuleCard
_G.__DeltaUI_ShowNotification = ShowNotification
_G.__DeltaUI_getCachedIcon = getCachedIcon
_G.__DeltaUI_installModule = installModule
_G.__DeltaUI_uninstallModule = uninstallModule

_G.__DeltaUI_rightToggleBar = rightToggleBar
_G.__DeltaUI_toggleIcon = toggleIcon
_G.__DeltaUI_wrapperFrame = wrapperFrame
_G.__DeltaUI_statsRow = statsRow
_G.__DeltaUI_contentFrame = contentFrame
_G.__DeltaUI_pingPill = pingPill
_G.__DeltaUI_fpsPill = fpsPill
_G.__DeltaUI_timePill = timePill
_G.__DeltaUI_labelPill = labelPill
_G.__DeltaUI_scriptListScroll = scriptListScroll
_G.__DeltaUI_scriptListLayout = scriptListLayout
_G.__DeltaUI_searchBox = searchBox
_G.__DeltaUI_updateBtn = updateBtn
_G.__DeltaUI_refreshBtn = refreshBtn
_G.__DeltaUI_cloudPage = cloudPage
_G.__DeltaUI_cloudSearchBox = cloudSearchBox
_G.__DeltaUI_settingsPage = settingsPage
_G.__DeltaUI_editorPage = editorPage
_G.__DeltaUI_consolePage = consolePage
_G.__DeltaUI_gamepadPage = gamepadPage
_G.__DeltaUI_tabBar = tabBar
_G.__DeltaUI_tabAddBtn = tabAddBtn
_G.__DeltaUI_codeScroll = codeScroll
_G.__DeltaUI_codeBox = codeBox
_G.__DeltaUI_lineNumberFrame = lineNumberFrame
_G.__DeltaUI_lineNumberLabel = lineNumberLabel
_G.__DeltaUI_editOverlay = editOverlay
_G.__DeltaUI_execBtn = execBtn
_G.__DeltaUI_clearBtn = clearBtn
_G.__DeltaUI_pasteBtn = pasteBtn
_G.__DeltaUI_execClipBtn = execClipBtn
_G.__DeltaUI_consoleClearBtn = consoleClearBtn
_G.__DeltaUI_consoleScroll = consoleScroll
_G.__DeltaUI_consoleList = consoleList
_G.__DeltaUI_consoleHeader = consoleHeader
_G.__DeltaUI_consoleTitle = consoleTitle
_G.__DeltaUI_consoleSettingsBtn = consoleSettingsBtn
_G.__DeltaUI_scrollTrack = scrollTrack
_G.__DeltaUI_orbFrame = orbFrame
_G.__DeltaUI_orbBtn = orbBtn
_G.__DeltaUI_orbImg = orbImg
_G.__DeltaUI_orbStroke = orbStroke
_G.__DeltaUI_logoutBtn = logoutBtn
_G.__DeltaUI_logoutIcon = logoutIcon
_G.__DeltaUI_topBar = topBar
_G.__DeltaUI_navBg = navBg
_G.__DeltaUI_navContainer = navContainer
_G.__DeltaUI_navIndicator = navIndicator
_G.__DeltaUI_main = main
_G.__DeltaUI_screenGui = screenGui

_G.__DeltaUI_refreshScriptList = refreshScriptList
_G.__DeltaUI_addStoreScriptToGamepad = addStoreScriptToGamepad
_G.__DeltaUI_removeStoreScript = removeStoreScript
_G.__DeltaUI_hasExecutorDescendant = hasExecutorDescendant
_G.__DeltaUI_destroyExecutorUI = destroyExecutorUI
_G.__DeltaUI_cleanupOldUI = cleanupOldUI
_G.__DeltaUI_getClipboardContent = getClipboardContent
_G.__DeltaUI_ensureFolder = ensureFolder
_G.__DeltaUI_ensureExportFolder = ensureExportFolder
_G.__DeltaUI_ensureCacheFolder = ensureCacheFolder
_G.__DeltaUI_ensureAutoExecFolder = ensureAutoExecFolder
_G.__DeltaUI_assetFolder = assetFolder
_G.__DeltaUI_ensureAssetFolder = ensureAssetFolder
_G.__DeltaUI_initFloatingBallIcon = initFloatingBallIcon
_G.__DeltaUI_getAutoExecFileState = getAutoExecFileState
_G.__DeltaUI_setAutoExecFileState = setAutoExecFileState
_G.__DeltaUI_getUniqueTabName = getUniqueTabName
_G.__DeltaUI_saveCurrentTab = saveCurrentTab
_G.__DeltaUI_renderTabs = renderTabs
_G.__DeltaUI_addTab = addTab
_G.__DeltaUI_updateLineNumbers = updateLineNumbers
_G.__DeltaUI_loadConfig = loadConfig
_G.__DeltaUI_saveConfig = saveConfig
_G.__DeltaUI_registerTranslation = registerTranslation
_G.__DeltaUI_setProgress = setProgress
_G.__DeltaUI_startDownload = startDownload
_G.__DeltaUI_isCollapsed = isCollapsed
_G.__DeltaUI_orbDragOffset = orbDragOffset
_G.__DeltaUI_orbDragStart = orbDragStart
_G.__DeltaUI_orbDragInput = orbDragInput
_G.__DeltaUI_isOrbDragging = isOrbDragging
_G.__DeltaUI_isCollapsed = isCollapsed

loadInstalledModules = function() end
installModule = function() end
uninstallModule = function() end
makeModuleCard = function() return nil end
installedModules = {}
_G.__DeltaUI_installedModules = installedModules
_G.__DeltaUI_installModule = installModule
_G.__DeltaUI_uninstallModule = uninstallModule
_G.__DeltaUI_makeModuleCard = makeModuleCard
function wasaiCreateMessageContainer(text, isUser, customBubbleColor)
    local container = create("Frame", {
        Name = "MessageContainer",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = wasaiMessageFrame,
        ZIndex = 3
    })

    local avatar = create("Frame", {
        Name = "Avatar",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = isUser and theme.accent or theme.surfaceLight,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 4
    })
    corner(14, avatar)
    avatar.Parent = container

    local avatarIcon = GetIcon(isUser and "user" or "terminal", UDim2.new(0, 16, 0, 16), isUser and Color3.new(1,1,1) or theme.text)
    if avatarIcon then
        avatarIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
        avatarIcon.Parent = avatar
    end

    local bubble = create("Frame", {
        Name = "Bubble",
        BackgroundColor3 = customBubbleColor or (isUser and theme.accent or theme.surfaceLight),
        BackgroundTransparency = isUser and 0.25 or 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Parent = container,
        ZIndex = 3
    })
    corner(12, bubble)

    if isUser then
        avatar.AnchorPoint = Vector2.new(1, 0)
        avatar.Position = UDim2.new(1, -8, 0, 0)
        bubble.AnchorPoint = Vector2.new(1, 0)
        bubble.Position = UDim2.new(1, -52, 0, 0)
    else
        avatar.AnchorPoint = Vector2.new(0, 0)
        avatar.Position = UDim2.new(0, 8, 0, 0)
        bubble.AnchorPoint = Vector2.new(0, 0)
        bubble.Position = UDim2.new(0, 52, 0, 0)
    end

    return container, bubble
end

-- 已移除对话重载弹窗：改为通过右上角「对话管理」手动载入
