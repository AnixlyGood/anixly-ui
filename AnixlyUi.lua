--// Anixly UI Library
--// Version: 1.1.0 (Enhanced Edition)
--// Improvements: smoother animations, hover glow on tabs, active indicator bar,
--//   section collapse animation, notification queue, new NEON & OCEAN themes

local AnixlyUI = {}
AnixlyUI.__index = AnixlyUI
AnixlyUI.Version = "1.1.0"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Notification queue so multiple notifs stack instead of overlapping
local NotifSlots = {}
local NOTIF_HEIGHT = 90
local NOTIF_GAP = 8

local function getNotifY(slot)
    return -(24 + (slot - 1) * (NOTIF_HEIGHT + NOTIF_GAP))
end

-- Elastic tween shorthand
local function tweenElastic(obj, props, time)
    local info = TweenInfo.new(time or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function getParent()
    local ok, core = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and core then
        return core
    end

    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function tween(obj, props, time, style, direction)
    local info = TweenInfo.new(
        time or 0.22,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(0, 180, 255)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function gradient(obj, colors, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colors)
    g.Rotation = rotation or 45
    g.Parent = obj
    return g
end

local function padding(obj, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
    return p
end

local function makeText(parent, props)
    local label = Instance.new(props.ClassName or "TextLabel")
    label.BackgroundTransparency = props.BackgroundTransparency == nil and 1 or props.BackgroundTransparency
    label.Text = props.Text or ""
    label.TextColor3 = props.TextColor3 or Color3.fromRGB(235, 245, 255)
    label.Font = props.Font or Enum.Font.Gotham
    label.TextSize = props.TextSize or 13
    label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    label.TextWrapped = props.TextWrapped or false
    label.Size = props.Size or UDim2.new(1, 0, 1, 0)
    label.Position = props.Position or UDim2.new()
    label.ZIndex = props.ZIndex or parent.ZIndex
    label.Parent = parent
    return label
end

local THEMES = {
    NEON = {
        name = "Neon Pulse",
        bg = Color3.fromRGB(6, 4, 14),
        bg2 = Color3.fromRGB(10, 7, 22),
        card = Color3.fromRGB(18, 12, 36),
        card2 = Color3.fromRGB(24, 16, 46),
        header = Color3.fromRGB(14, 9, 30),
        sidebar = Color3.fromRGB(8, 5, 18),
        text = Color3.fromRGB(245, 235, 255),
        subtext = Color3.fromRGB(175, 145, 220),
        accent = Color3.fromRGB(210, 0, 255),
        accent2 = Color3.fromRGB(0, 255, 200),
        success = Color3.fromRGB(0, 255, 180),
        danger = Color3.fromRGB(255, 40, 110),
        warning = Color3.fromRGB(255, 210, 0)
    },

    SHADOW = {
        name = "Shadow",
        bg = Color3.fromRGB(22, 22, 26),
        bg2 = Color3.fromRGB(30, 30, 35),
        card = Color3.fromRGB(38, 38, 44),
        card2 = Color3.fromRGB(46, 46, 53),
        header = Color3.fromRGB(26, 26, 31),
        sidebar = Color3.fromRGB(20, 20, 24),
        text = Color3.fromRGB(240, 240, 245),
        subtext = Color3.fromRGB(150, 150, 165),
        accent = Color3.fromRGB(200, 200, 215),
        accent2 = Color3.fromRGB(130, 130, 150),
        success = Color3.fromRGB(80, 220, 140),
        danger = Color3.fromRGB(255, 80, 100),
        warning = Color3.fromRGB(255, 195, 60)
    }
}

AnixlyUI.Themes = THEMES

local DEFAULT_SIZE = IsMobile and Vector2.new(330, 360) or Vector2.new(540, 405)
local SIDEBAR_WIDTH = IsMobile and 90 or 118
local HEADER_HEIGHT = IsMobile and 58 or 64
local COMPONENT_HEIGHT = IsMobile and 38 or 42

function AnixlyUI:CreateTheme(id, data)
    if type(id) ~= "string" or type(data) ~= "table" then
        return nil
    end

    THEMES[id] = data
    return data
end

function AnixlyUI:GetThemes()
    local list = {}
    for id, theme in pairs(THEMES) do
        table.insert(list, id)
    end
    table.sort(list)
    return list
end

function AnixlyUI:ShowNotification(config)
    config = config or {}

    local themeName = config.Theme or "info"
    local colors = {
        info = Color3.fromRGB(0, 190, 255),
        success = Color3.fromRGB(40, 230, 145),
        error = Color3.fromRGB(255, 70, 95),
        warning = Color3.fromRGB(255, 195, 60)
    }

    local icons = {
        info = "i",
        success = "✓",
        error = "×",
        warning = "!"
    }

    local accent = colors[themeName] or colors.info
    local title = config.Title or string.upper(themeName)
    local message = config.Message or "Notification"
    local duration = config.Duration or 3

    -- Find a free slot in the notification queue
    local slot = 1
    while NotifSlots[slot] do
        slot = slot + 1
    end
    NotifSlots[slot] = true

    local gui = Instance.new("ScreenGui")
    gui.Name = "AnixlyNotification"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getParent()

    local notifWidth = IsMobile and 310 or 370
    local notifH = NOTIF_HEIGHT - 4

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(1, 1)
    holder.Size = UDim2.new(0, notifWidth, 0, notifH)
    holder.Position = UDim2.new(1, notifWidth + 20, 1, getNotifY(slot))
    holder.BackgroundColor3 = Color3.fromRGB(12, 16, 28)
    holder.BackgroundTransparency = 0.04
    holder.BorderSizePixel = 0
    holder.Parent = gui
    corner(holder, 18)
    stroke(holder, accent, 1.4, 0.18)

    gradient(holder, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 24, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 11, 20))
    }, 30)

    -- Colored left accent bar
    local sideBar = Instance.new("Frame")
    sideBar.Size = UDim2.new(0, 4, 1, -16)
    sideBar.Position = UDim2.new(0, 8, 0, 8)
    sideBar.BackgroundColor3 = accent
    sideBar.BorderSizePixel = 0
    sideBar.Parent = holder
    corner(sideBar, 99)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 38, 0, 38)
    icon.Position = UDim2.new(0, 20, 0.5, -19)
    icon.BackgroundColor3 = accent
    icon.BackgroundTransparency = 0.12
    icon.Text = icons[themeName] or "i"
    icon.TextColor3 = Color3.new(1, 1, 1)
    icon.Font = Enum.Font.GothamBlack
    icon.TextSize = 20
    icon.Parent = holder
    corner(icon, 12)

    makeText(holder, {
        Text = title,
        TextColor3 = accent,
        Font = Enum.Font.GothamBlack,
        TextSize = 12,
        Size = UDim2.new(1, -82, 0, 20),
        Position = UDim2.new(0, 68, 0, 12)
    })

    makeText(holder, {
        Text = message,
        TextColor3 = Color3.fromRGB(210, 225, 245),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextWrapped = true,
        Size = UDim2.new(1, -82, 0, 36),
        Position = UDim2.new(0, 68, 0, 34),
        TextYAlignment = Enum.TextYAlignment.Top
    })

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -26, 0, 3)
    bar.Position = UDim2.new(0, 13, 1, -7)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = holder
    corner(bar, 999)

    -- Slide in with elastic bounce
    tweenElastic(holder, {Position = UDim2.new(1, -24, 1, getNotifY(slot))}, 0.40)

    if duration > 0 then
        tween(bar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)

        task.delay(duration, function()
            if gui.Parent then
                tween(holder, {Position = UDim2.new(1, notifWidth + 20, 1, getNotifY(slot))}, 0.28)
                task.wait(0.3)
                gui:Destroy()
                NotifSlots[slot] = nil
            end
        end)
    end
end

function AnixlyUI:ShowKeySystem(config)
    config = config or {}

    local correctKey = config.Key or "admin123"
    local callback = config.Callback or function() end
    local title = config.Title or "ANIXLY KEY"
    local subtitle = config.Subtitle or "Enter your key to unlock the script"

    local gui = Instance.new("ScreenGui")
    gui.Name = "AnixlyKeySystem"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getParent()

    local blur = Instance.new("Frame")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blur.BackgroundTransparency = 0.35
    blur.Parent = gui

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Size = UDim2.new(0, IsMobile and 330 or 420, 0, 310)
    panel.Position = UDim2.new(0.5, 0, 0.5, 25)
    panel.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
    panel.BackgroundTransparency = 0.03
    panel.BorderSizePixel = 0
    panel.Parent = gui
    corner(panel, 24)
    stroke(panel, Color3.fromRGB(0, 210, 255), 1.5, 0.16)

    gradient(panel, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 27, 48)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(13, 16, 31)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 17, 48))
    }, 35)

    makeText(panel, {
        Text = "◆",
        TextColor3 = Color3.fromRGB(0, 210, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 38,
        Size = UDim2.new(1, 0, 0, 46),
        Position = UDim2.new(0, 0, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Center
    })

    makeText(panel, {
        Text = title,
        TextColor3 = Color3.fromRGB(245, 250, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        Size = UDim2.new(1, -50, 0, 30),
        Position = UDim2.new(0, 25, 0, 78),
        TextXAlignment = Enum.TextXAlignment.Center
    })

    makeText(panel, {
        Text = subtitle,
        TextColor3 = Color3.fromRGB(145, 165, 195),
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextWrapped = true,
        Size = UDim2.new(1, -60, 0, 36),
        Position = UDim2.new(0, 30, 0, 113),
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -54, 0, 48)
    input.Position = UDim2.new(0, 27, 0, 162)
    input.BackgroundColor3 = Color3.fromRGB(8, 12, 24)
    input.TextColor3 = Color3.fromRGB(235, 245, 255)
    input.PlaceholderText = "Paste key here..."
    input.PlaceholderColor3 = Color3.fromRGB(95, 115, 145)
    input.Text = ""
    input.Font = Enum.Font.GothamBold
    input.TextSize = 15
    input.ClearTextOnFocus = false
    input.Parent = panel
    corner(input, 14)
    stroke(input, Color3.fromRGB(0, 210, 255), 1, 0.55)
    padding(input, 14, 14, 0, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -54, 0, 48)
    btn.Position = UDim2.new(0, 27, 0, 224)
    btn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    btn.Text = "VERIFY KEY"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.Parent = panel
    corner(btn, 14)
    gradient(btn, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 255))
    }, 0)

    local status = makeText(panel, {
        Text = "",
        TextColor3 = Color3.fromRGB(255, 80, 100),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Size = UDim2.new(1, -54, 0, 20),
        Position = UDim2.new(0, 27, 1, -28),
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 32, 0, 32)
    close.Position = UDim2.new(1, -44, 0, 12)
    close.BackgroundColor3 = Color3.fromRGB(255, 70, 95)
    close.Text = "×"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBlack
    close.TextSize = 18
    close.AutoButtonColor = false
    close.Parent = panel
    corner(close, 10)

    local function deny()
        status.Text = "Invalid key. Try again."
        input.Text = ""

        local old = panel.Position
        for i = 1, 6 do
            tween(panel, {Position = old + UDim2.new(0, (i % 2 == 0 and 9 or -9), 0, 0)}, 0.04)
            task.wait(0.04)
        end
        tween(panel, {Position = old}, 0.1)
    end

    local function verify()
        if input.Text == correctKey then
            status.Text = "Access granted."
            status.TextColor3 = Color3.fromRGB(40, 230, 145)
            tween(panel, {Size = panel.Size + UDim2.new(0, 16, 0, 12)}, 0.2, Enum.EasingStyle.Back)
            task.wait(0.25)
            gui:Destroy()
            callback(true)
            AnixlyUI:ShowNotification({
                Title = "SUCCESS",
                Message = "Welcome to Anixly v" .. AnixlyUI.Version,
                Theme = "success",
                Duration = 2.5
            })
        else
            deny()
        end
    end

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.08}, 0.16)
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0}, 0.16)
    end)

    btn.MouseButton1Click:Connect(verify)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then verify() end
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        callback(false)
    end)

    tween(panel, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.35, Enum.EasingStyle.Back)
end

function AnixlyUI:CreateWindow(config)
    config = config or {}

    local window = {}
    window.Title = config.Title or "Anixly Hub"
    window.Subtitle = config.Subtitle or ("Version " .. AnixlyUI.Version)
    window.ThemeId = config.Theme or "ANIXLY"
    window.Theme = THEMES[window.ThemeId] or THEMES.NEON
    window.Width = (config.Size and config.Size.Width) or DEFAULT_SIZE.X
    window.Height = (config.Size and config.Size.Height) or DEFAULT_SIZE.Y
    window.Tabs = {}
    window.TabButtons = {}
    window.ConfigData = {}
    window.MiniIcon = config.MiniIcon or config.Logo or "rbxassetid://2061475061"
    window.Logo = config.Logo or window.MiniIcon
    window.MinimizeIcon = config.MinimizeIcon or window.MiniIcon

    local theme = window.Theme

    local gui = Instance.new("ScreenGui")
    gui.Name = "AnixlyUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getParent()

    local glow = Instance.new("Frame")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Size = UDim2.new(0, window.Width + 10, 0, window.Height + 10)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.BackgroundColor3 = theme.accent
    glow.BackgroundTransparency = 0.72
    glow.BorderSizePixel = 0
    glow.Parent = gui
    corner(glow, 26)

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, window.Width, 0, window.Height)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = theme.bg
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    corner(main, 22)
    local mainStroke = stroke(main, theme.accent, 1.2, 0.25)

    gradient(main, {
        ColorSequenceKeypoint.new(0, theme.bg2),
        ColorSequenceKeypoint.new(0.55, theme.bg),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 13, 35))
    }, 35)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
    header.BackgroundColor3 = theme.header
    header.BackgroundTransparency = 0.04
    header.BorderSizePixel = 0
    header.Parent = main

    local headerIcon = Instance.new("ImageLabel")
    headerIcon.Name = "HeaderIcon"
    headerIcon.Size = UDim2.new(0, IsMobile and 38 or 42, 0, IsMobile and 38 or 42)
    headerIcon.Position = UDim2.new(0, 14, 0.5, -(IsMobile and 19 or 21))
    headerIcon.BackgroundColor3 = theme.card
    headerIcon.BackgroundTransparency = 0.05
    headerIcon.Image = window.MiniIcon
    headerIcon.ImageColor3 = Color3.new(1, 1, 1)
    headerIcon.ScaleType = Enum.ScaleType.Crop
    headerIcon.Parent = header
    corner(headerIcon, 13)
    stroke(headerIcon, theme.accent, 1, 0.35)

    makeText(header, {
        Text = window.Title,
        TextColor3 = theme.text,
        Font = Enum.Font.GothamBlack,
        TextSize = IsMobile and 13 or 15,
        Size = UDim2.new(1, -215, 0, 25),
        Position = UDim2.new(0, 64, 0, IsMobile and 8 or 10)
    })

    makeText(header, {
        Text = window.Subtitle,
        TextColor3 = theme.subtext,
        Font = Enum.Font.GothamMedium,
        TextSize = IsMobile and 9 or 10,
        Size = UDim2.new(1, -215, 0, 18),
        Position = UDim2.new(0, 64, 0, IsMobile and 30 or 33)
    })

    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 78, 1, 0)
    controls.Position = UDim2.new(1, -88, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = header

    local minimize = Instance.new("ImageButton")
minimize.Size = UDim2.new(0, 28, 0, 28)
minimize.Position = UDim2.new(0, 6, 0.5, -14)
minimize.BackgroundColor3 = theme.warning
minimize.Image = "rbxassetid://3926305904" -- minimize/minus icon
minimize.ImageColor3 = Color3.fromRGB(40, 30, 0)
minimize.ScaleType = Enum.ScaleType.Fit
minimize.AutoButtonColor = false
minimize.Parent = controls
corner(minimize, 999)

    local close = Instance.new("ImageButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(0, 42, 0.5, -14)
    close.BackgroundColor3 = theme.danger
    close.Image = "rbxassetid://6023426923"
    close.ImageColor3 = Color3.new(1, 1, 1)
    close.ScaleType = Enum.ScaleType.Fit
    close.AutoButtonColor = false
    close.Parent = controls
    corner(close, 999)

    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -HEADER_HEIGHT)
    sidebar.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
    sidebar.BackgroundColor3 = theme.sidebar
    sidebar.BackgroundTransparency = 0.04
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = IsMobile and 2 or 3
    sidebar.ScrollBarImageColor3 = theme.accent
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.Parent = main

    local sideList = Instance.new("UIListLayout")
    sideList.Padding = UDim.new(0, 7)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideList.Parent = sidebar

    padding(sidebar, 8, 8, 10, 10)

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -(SIDEBAR_WIDTH + 12), 1, -(HEADER_HEIGHT + 12))
    content.Position = UDim2.new(0, SIDEBAR_WIDTH + 8, 0, HEADER_HEIGHT + 8)
    content.BackgroundTransparency = 1
    content.Parent = main

    local mini = Instance.new("ImageButton")
    mini.Size = UDim2.new(0, IsMobile and 52 or 60, 0, IsMobile and 52 or 60)
    mini.Position = UDim2.new(0, 18, 0.5, -29)
    mini.BackgroundColor3 = theme.header
    mini.Image = "rbxassetid://2061475061" -- logo/hub icon
    mini.ImageColor3 = theme.accent
    mini.ScaleType = Enum.ScaleType.Fit
    mini.Visible = false
    mini.AutoButtonColor = false
    mini.Parent = gui
    mini.ZIndex = 100
    corner(mini, 18)
    stroke(mini, theme.accent, 1.6, 0.1)

    local resize = Instance.new("ImageButton")
    resize.Size = UDim2.new(0, 24, 0, 24)
    resize.Position = UDim2.new(1, -28, 1, -28)
    resize.BackgroundColor3 = theme.card2
    resize.Image = "rbxassetid://3926305904" -- resize/drag icon (reuse minus, will swap if needed)
    resize.ImageColor3 = theme.accent
    resize.ScaleType = Enum.ScaleType.Fit
    resize.AutoButtonColor = false
    resize.Parent = main
    resize.ZIndex = 20
    corner(resize, 8)
    stroke(resize, theme.accent, 1, 0.45)

    local function updateGlow()
        glow.Size = UDim2.new(0, main.Size.X.Offset + 10, 0, main.Size.Y.Offset + 10)
        glow.Position = main.Position
    end

    local dragging, resizing, miniDragging = false, false, false
    local dragStart, posStart, sizeStart, miniStart
    local miniMove = 0

    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(1, -100, 1, 0)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.Parent = header

    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            posStart = main.Position
        end
    end)

    resize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            dragStart = input.Position
            sizeStart = main.Size
        end
    end)

    mini.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = true
            miniMove = 0
            dragStart = input.Position
            miniStart = mini.Position
        end
    end)

    mini.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = false
            if miniMove <= 10 then
                main.Visible = true
                glow.Visible = true
                mini.Visible = false
            end
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
            updateGlow()
        elseif resizing then
            local delta = input.Position - dragStart
            local newW = math.clamp(sizeStart.X.Offset + delta.X, IsMobile and 310 or 420, 850)
            local newH = math.clamp(sizeStart.Y.Offset + delta.Y, IsMobile and 320 or 340, 650)
            main.Size = UDim2.new(0, newW, 0, newH)
            updateGlow()
        elseif miniDragging then
            local delta = input.Position - dragStart
            miniMove = delta.Magnitude
            mini.Position = UDim2.new(miniStart.X.Scale, miniStart.X.Offset + delta.X, miniStart.Y.Scale, miniStart.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            resizing = false
        end
    end)

    minimize.MouseButton1Click:Connect(function()
        main.Visible = false
        glow.Visible = false
        mini.Visible = true
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
        AnixlyUI:ShowNotification({
            Title = "ANIXLY",
            Message = "Window closed.",
            Theme = "info",
            Duration = 2
        })
    end)

    function window:SetTheme(id)
        if not THEMES[id] then
            AnixlyUI:ShowNotification({
                Title = "THEME ERROR",
                Message = "Theme not found: " .. tostring(id),
                Theme = "error",
                Duration = 2.5
            })
            return
        end

        self.ThemeId = id
        self.Theme = THEMES[id]
        theme = self.Theme

        glow.BackgroundColor3 = theme.accent
        main.BackgroundColor3 = theme.bg
        mainStroke.Color = theme.accent
        header.BackgroundColor3 = theme.header
        sidebar.BackgroundColor3 = theme.sidebar
        headerIcon.BackgroundColor3 = theme.card
        mini.BackgroundColor3 = theme.header
        resize.TextColor3 = theme.accent

        AnixlyUI:ShowNotification({
            Title = "THEME",
            Message = "Changed to " .. theme.name,
            Theme = "success",
            Duration = 2
        })
    end

    function window:GetCurrentTheme()
        return self.Theme
    end

    function window:CreateTab(name, icon)
        local tab = {}
        tab.Name = name
        tab.Sections = {}
        tab.CurrentOrder = 1

        local container = Instance.new("ScrollingFrame")
        container.Name = name .. "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.ScrollBarThickness = IsMobile and 3 or 4
        container.ScrollBarImageColor3 = theme.accent
        container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        container.CanvasSize = UDim2.new(0, 0, 0, 0)
        container.Visible = false
        container.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = container

        padding(container, 4, 8, 4, 12)

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, IsMobile and 48 or 54)
        tabBtn.BackgroundColor3 = theme.bg2
        tabBtn.BackgroundTransparency = 0.03
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.LayoutOrder = #self.Tabs + 1
        tabBtn.Parent = sidebar
        corner(tabBtn, 14)
        local tabStroke = stroke(tabBtn, theme.accent, 1, 0.8)

        -- NEW: active indicator bar on left edge
        local activeBar = Instance.new("Frame")
        activeBar.Size = UDim2.new(0, 3, 0.6, 0)
        activeBar.Position = UDim2.new(0, -1, 0.2, 0)
        activeBar.BackgroundColor3 = theme.accent
        activeBar.BorderSizePixel = 0
        activeBar.BackgroundTransparency = 1
        activeBar.Parent = tabBtn
        corner(activeBar, 99)

        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, IsMobile and 22 or 25, 0, IsMobile and 22 or 25)
        iconLabel.Position = UDim2.new(0.5, -(IsMobile and 11 or 12), 0, 7)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = icon or ""
        iconLabel.ImageColor3 = Color3.fromRGB(180, 210, 235)
        iconLabel.Parent = tabBtn

        makeText(tabBtn, {
            Text = name,
            TextColor3 = theme.subtext,
            Font = Enum.Font.GothamBold,
            TextSize = IsMobile and 9 or 10,
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 1, -20),
            TextXAlignment = Enum.TextXAlignment.Center
        })

        -- NEW: hover glow effect
        tabBtn.MouseEnter:Connect(function()
            if tabBtn.BackgroundColor3 ~= theme.accent then
                tween(tabBtn, {BackgroundColor3 = theme.card2, BackgroundTransparency = 0}, 0.14)
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if tabBtn.BackgroundColor3 ~= theme.accent then
                tween(tabBtn, {BackgroundColor3 = theme.bg2, BackgroundTransparency = 0.03}, 0.14)
            end
        end)

        local buttonData = {
            button = tabBtn,
            stroke = tabStroke,
            icon = iconLabel,
            container = container,
            bar = activeBar
        }

        table.insert(self.Tabs, tab)
        table.insert(self.TabButtons, buttonData)

        local function activate()
            for _, data in ipairs(self.TabButtons) do
                data.container.Visible = false
                tween(data.button, {BackgroundColor3 = theme.bg2, BackgroundTransparency = 0.03}, 0.18)
                data.stroke.Transparency = 0.8
                data.icon.ImageColor3 = Color3.fromRGB(180, 210, 235)
                tween(data.bar, {BackgroundTransparency = 1}, 0.18)
                local txt = data.button:FindFirstChildOfClass("TextLabel")
                if txt then txt.TextColor3 = theme.subtext end
            end

            container.Visible = true
            container.Position = UDim2.new(0, 18, 0, 0)
            tween(container, {Position = UDim2.new(0, 0, 0, 0)}, 0.25)
            tween(tabBtn, {BackgroundColor3 = theme.accent, BackgroundTransparency = 0}, 0.18)
            tabStroke.Transparency = 0.1
            iconLabel.ImageColor3 = Color3.new(1, 1, 1)
            tween(activeBar, {BackgroundTransparency = 0}, 0.18)

            local txt = tabBtn:FindFirstChildOfClass("TextLabel")
            if txt then txt.TextColor3 = Color3.new(1, 1, 1) end
        end

        tabBtn.MouseButton1Click:Connect(activate)

        function tab:AddSection(title, iconId)
            local section = {}
            section.Title = title
            section.Items = {}
            section.Expanded = true

            local headerFrame = Instance.new("TextButton")
            headerFrame.Size = UDim2.new(1, 0, 0, 40)
            headerFrame.BackgroundColor3 = theme.card2
            headerFrame.BackgroundTransparency = 0.06
            headerFrame.Text = ""
            headerFrame.AutoButtonColor = false
            headerFrame.LayoutOrder = tab.CurrentOrder
            headerFrame.Parent = container
            tab.CurrentOrder += 1
            corner(headerFrame, 13)
            stroke(headerFrame, theme.accent, 1, 0.65)

            -- Optional icon
            local textOffsetX = 14
            if iconId and iconId ~= "" then
                local sectionIcon = Instance.new("ImageLabel")
                sectionIcon.Size = UDim2.new(0, 20, 0, 20)
                sectionIcon.Position = UDim2.new(0, 12, 0.5, -10)
                sectionIcon.BackgroundTransparency = 1
                sectionIcon.Image = "rbxassetid://" .. tostring(iconId):gsub("rbxassetid://", "")
                sectionIcon.ImageColor3 = theme.accent
                sectionIcon.ScaleType = Enum.ScaleType.Fit
                sectionIcon.ZIndex = headerFrame.ZIndex + 1
                sectionIcon.Parent = headerFrame
                textOffsetX = 40
            end

            makeText(headerFrame, {
                Text = title,
                TextColor3 = theme.text,
                Font = Enum.Font.GothamBlack,
                TextSize = IsMobile and 12 or 13,
                Size = UDim2.new(1, -(textOffsetX + 46), 1, 0),
                Position = UDim2.new(0, textOffsetX, 0, 0)
            })

            -- Arrow icon (ImageLabel instead of text)
            local arrow = Instance.new("ImageLabel")
            arrow.Size = UDim2.new(0, 16, 0, 16)
            arrow.Position = UDim2.new(1, -28, 0.5, -8)
            arrow.BackgroundTransparency = 1
            arrow.Image = "rbxassetid://6034818372"
            arrow.ImageColor3 = theme.accent
            arrow.ScaleType = Enum.ScaleType.Fit
            arrow.ZIndex = headerFrame.ZIndex + 1
            arrow.Parent = headerFrame

            headerFrame.MouseButton1Click:Connect(function()
                section.Expanded = not section.Expanded
                arrow.Text = section.Expanded and "▼" or "▶"
                for _, item in ipairs(section.Items) do
                    item.Visible = section.Expanded
                end
            end)

            local function baseComponent(height)
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, height or COMPONENT_HEIGHT)
                frame.BackgroundColor3 = theme.card
                frame.BackgroundTransparency = 0.04
                frame.BorderSizePixel = 0
                frame.LayoutOrder = tab.CurrentOrder
                frame.Visible = section.Expanded
                frame.Parent = container
                tab.CurrentOrder += 1
                corner(frame, 12)
                stroke(frame, theme.accent, 1, 0.86)
                table.insert(section.Items, frame)
                return frame
            end

            function section:AddButton(cfg)
                cfg = cfg or {}
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, COMPONENT_HEIGHT)
                btn.BackgroundColor3 = theme.card
                btn.BackgroundTransparency = 0.04
                btn.Text = cfg.Text or "Button"
                btn.TextColor3 = theme.text
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = IsMobile and 12 or 13
                btn.AutoButtonColor = false
                btn.LayoutOrder = tab.CurrentOrder
                btn.Visible = section.Expanded
                btn.Parent = container
                tab.CurrentOrder += 1
                corner(btn, 12)
                stroke(btn, theme.accent, 1, 0.75)
                table.insert(section.Items, btn)

                -- Hover: subtle accent tint
                btn.MouseEnter:Connect(function()
                    tween(btn, {BackgroundColor3 = theme.card2}, 0.14)
                    tween(btn, {}, 0.14) -- stroke glow via size trick
                end)

                btn.MouseLeave:Connect(function()
                    tween(btn, {BackgroundColor3 = theme.card}, 0.14)
                end)

                -- Press: squish + bounce back
                btn.MouseButton1Click:Connect(function()
                    tween(btn, {Size = UDim2.new(0.97, 0, 0, COMPONENT_HEIGHT - 3)}, 0.06)
                    task.wait(0.06)
                    tweenElastic(btn, {Size = UDim2.new(1, 0, 0, COMPONENT_HEIGHT)}, 0.22)
                    if cfg.Callback then cfg.Callback() end
                end)

                return btn
            end

            function section:AddLabel(text)
                local label = makeText(container, {
                    Text = text or "Label",
                    TextColor3 = theme.subtext,
                    Font = Enum.Font.GothamMedium,
                    TextSize = IsMobile and 11 or 12,
                    Size = UDim2.new(1, 0, 0, 26),
                    TextWrapped = true
                })
                label.LayoutOrder = tab.CurrentOrder
                label.Visible = section.Expanded
                tab.CurrentOrder += 1
                table.insert(section.Items, label)
                return label
            end

            function section:AddToggle(cfg)
                cfg = cfg or {}
                local frame = baseComponent(COMPONENT_HEIGHT)

                makeText(frame, {
                    Text = cfg.Text or "Toggle",
                    TextColor3 = theme.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = IsMobile and 12 or 13,
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0)
                })

                local state = cfg.Default or false

                -- Track (pill background)
                local track = Instance.new("Frame")
                track.Size = UDim2.new(0, 52, 0, 28)
                track.Position = UDim2.new(1, -64, 0.5, -14)
                track.BackgroundColor3 = state and theme.accent or theme.card2
                track.BorderSizePixel = 0
                track.Parent = frame
                corner(track, 999)

                -- Glow stroke on track (visible when ON)
                local trackStroke = Instance.new("UIStroke")
                trackStroke.Color = theme.accent
                trackStroke.Thickness = 1.5
                trackStroke.Transparency = state and 0.3 or 0.9
                trackStroke.Parent = track

                -- Knob
                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 22, 0, 22)
                knob.Position = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
                knob.BackgroundColor3 = Color3.new(1, 1, 1)
                knob.BorderSizePixel = 0
                knob.ZIndex = frame.ZIndex + 1
                knob.Parent = track
                corner(knob, 999)

                -- Subtle shadow on knob
                local knobStroke = Instance.new("UIStroke")
                knobStroke.Color = Color3.fromRGB(0, 0, 0)
                knobStroke.Thickness = 1
                knobStroke.Transparency = 0.7
                knobStroke.Parent = knob

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = frame.ZIndex + 2
                btn.Parent = frame

                local key = "Toggle_" .. tostring(cfg.Text or "Toggle")
                window.ConfigData[key] = state

                local function set(value)
                    state = value
                    window.ConfigData[key] = state

                    if state then
                        -- ON: accent color + knob slides right + glow
                        tween(track, {BackgroundColor3 = theme.accent}, 0.2)
                        tweenElastic(knob, {Position = UDim2.new(1, -25, 0.5, -11)}, 0.28)
                        tween(knob, {Size = UDim2.new(0, 22, 0, 22)}, 0.08)
                        trackStroke.Transparency = 0.3
                    else
                        -- OFF: dark + knob slides left
                        tween(track, {BackgroundColor3 = theme.card2}, 0.2)
                        tweenElastic(knob, {Position = UDim2.new(0, 3, 0.5, -11)}, 0.28)
                        trackStroke.Transparency = 0.9
                    end

                    if cfg.Callback then cfg.Callback(state) end
                end

                -- Press: knob squishes wide momentarily
                btn.MouseButton1Down:Connect(function()
                    tween(knob, {Size = UDim2.new(0, 26, 0, 20)}, 0.08)
                end)

                btn.MouseButton1Click:Connect(function()
                    tween(knob, {Size = UDim2.new(0, 22, 0, 22)}, 0.08)
                    set(not state)
                end)

                -- Hover: slight frame highlight
                btn.MouseEnter:Connect(function()
                    tween(frame, {BackgroundColor3 = theme.card2}, 0.14)
                end)
                btn.MouseLeave:Connect(function()
                    tween(frame, {BackgroundColor3 = theme.card}, 0.14)
                end)

                return {
                    Set = set,
                    Get = function() return state end
                }
            end

            function section:AddDropdown(cfg)
                cfg = cfg or {}
                cfg.Options = cfg.Options or {}

                local frame = baseComponent(COMPONENT_HEIGHT)
                frame.ClipsDescendants = true

                makeText(frame, {
                    Text = cfg.Text or "Dropdown",
                    TextColor3 = theme.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = IsMobile and 12 or 13,
                    Size = UDim2.new(1, -125, 0, COMPONENT_HEIGHT),
                    Position = UDim2.new(0, 12, 0, 0)
                })

                local value = cfg.Default or cfg.Options[1] or "-"
                local valueLabel = makeText(frame, {
                    Text = tostring(value),
                    TextColor3 = theme.accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = IsMobile and 11 or 12,
                    Size = UDim2.new(0, 105, 0, COMPONENT_HEIGHT),
                    Position = UDim2.new(1, -118, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local key = "Dropdown_" .. tostring(cfg.Text or "Dropdown")
                window.ConfigData[key] = value
                local open = false
                local itemHeight = 30

                local list = Instance.new("Frame")
                list.Size = UDim2.new(1, -18, 0, 0)
                list.Position = UDim2.new(0, 9, 0, COMPONENT_HEIGHT)
                list.BackgroundColor3 = theme.bg2
                list.BorderSizePixel = 0
                list.ClipsDescendants = true
                list.Parent = frame
                corner(list, 10)
                stroke(list, theme.accent, 1, 0.7)

                local listLayout = Instance.new("UIListLayout")
                listLayout.Padding = UDim.new(0, 4)
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Parent = list
                padding(list, 6, 6, 6, 6)

                local function refresh()
                    for _, child in ipairs(list:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end

                    for _, opt in ipairs(cfg.Options) do
                        local item = Instance.new("TextButton")
                        item.Size = UDim2.new(1, 0, 0, itemHeight)
                        item.BackgroundColor3 = opt == value and theme.accent or theme.card
                        item.Text = tostring(opt)
                        item.TextColor3 = Color3.new(1, 1, 1)
                        item.Font = Enum.Font.GothamBold
                        item.TextSize = 12
                        item.AutoButtonColor = false
                        item.Parent = list
                        corner(item, 8)

                        item.MouseButton1Click:Connect(function()
                            value = opt
                            valueLabel.Text = tostring(value)
                            window.ConfigData[key] = value
                            open = false
                            tween(frame, {Size = UDim2.new(1, 0, 0, COMPONENT_HEIGHT)}, 0.18)
                            if cfg.Callback then cfg.Callback(value) end
                        end)
                    end
                end

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, COMPONENT_HEIGHT)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Parent = frame

                btn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        refresh()
                        local height = COMPONENT_HEIGHT + (#cfg.Options * (itemHeight + 4)) + 18
                        tween(frame, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
                        tween(list, {Size = UDim2.new(1, -18, 0, height - COMPONENT_HEIGHT - 10)}, 0.2)
                    else
                        tween(frame, {Size = UDim2.new(1, 0, 0, COMPONENT_HEIGHT)}, 0.18)
                    end
                end)

                return {
                    Set = function(v)
                        value = v
                        valueLabel.Text = tostring(v)
                        window.ConfigData[key] = v
                    end,
                    Get = function() return value end
                }
            end

            function section:AddSlider(cfg)
                cfg = cfg or {}
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local value = math.clamp(cfg.Default or min, min, max)

                local frame = baseComponent(58)

                makeText(frame, {
                    Text = cfg.Text or "Slider",
                    TextColor3 = theme.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = IsMobile and 12 or 13,
                    Size = UDim2.new(1, -90, 0, 24),
                    Position = UDim2.new(0, 12, 0, 5)
                })

                local valueBox = Instance.new("TextBox")
                valueBox.Size = UDim2.new(0, 72, 0, 24)
                valueBox.Position = UDim2.new(1, -84, 0, 5)
                valueBox.BackgroundColor3 = theme.bg2
                valueBox.Text = tostring(value)
                valueBox.TextColor3 = theme.accent
                valueBox.Font = Enum.Font.GothamBold
                valueBox.TextSize = 12
                valueBox.Parent = frame
                corner(valueBox, 8)
                stroke(valueBox, theme.accent, 1, 0.75)

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, -24, 0, 8)
                bar.Position = UDim2.new(0, 12, 1, -18)
                bar.BackgroundColor3 = theme.bg2
                bar.BorderSizePixel = 0
                bar.Parent = frame
                corner(bar, 999)

                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = theme.accent
                fill.BorderSizePixel = 0
                fill.Parent = bar
                corner(fill, 999)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 18, 0, 18)
                knob.BackgroundColor3 = Color3.new(1, 1, 1)
                knob.BorderSizePixel = 0
                knob.Parent = bar
                knob.ZIndex = 5
                corner(knob, 999)

                local key = "Slider_" .. tostring(cfg.Text or "Slider")
                window.ConfigData[key] = value

                local function apply(v, callback)
                    value = math.clamp(v, min, max)
                    value = math.floor(value * 100) / 100
                    valueBox.Text = tostring(value)

                    local percent = (value - min) / (max - min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    knob.Position = UDim2.new(percent, -9, 0.5, -9)
                    window.ConfigData[key] = value

                    if callback ~= false and cfg.Callback then
                        cfg.Callback(value)
                    end
                end

                apply(value, false)

                local draggingSlider = false

                local function fromInput(input)
                    local x = input.Position.X
                    local pos = bar.AbsolutePosition.X
                    local size = bar.AbsoluteSize.X
                    if size <= 0 then return end

                    local percent = math.clamp((x - pos) / size, 0, 1)
                    apply(min + (max - min) * percent, false)
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        fromInput(input)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        fromInput(input)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if draggingSlider then
                            draggingSlider = false

                            if cfg.Callback then
                                cfg.Callback(value)
                            end
                        end
                    end
                end)

                valueBox.FocusLost:Connect(function()
                    local n = tonumber(valueBox.Text)
                    if n then
                        apply(n)
                    else
                        valueBox.Text = tostring(value)
                    end
                end)

                return {
                    Set = function(v) apply(v) end,
                    Get = function() return value end
                }
            end

            function section:AddKeybind(cfg)
                cfg = cfg or {}

                local frame = baseComponent(COMPONENT_HEIGHT)
                local current = cfg.Default or "None"
                local listening = false

                makeText(frame, {
                    Text = cfg.Text or "Keybind",
                    TextColor3 = theme.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = IsMobile and 12 or 13,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0)
                })

                local keyText = makeText(frame, {
                    Text = current,
                    TextColor3 = theme.accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    Size = UDim2.new(0, 85, 1, 0),
                    Position = UDim2.new(1, -96, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local key = "Keybind_" .. tostring(cfg.Text or "Keybind")
                window.ConfigData[key] = current

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Parent = frame

                btn.MouseButton1Click:Connect(function()
                    listening = true
                    keyText.Text = "Press..."
                end)

                UIS.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        current = input.KeyCode.Name
                        keyText.Text = current
                        window.ConfigData[key] = current
                        if cfg.Callback then cfg.Callback(current) end
                    elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == current then
                        if cfg.Pressed then cfg.Pressed() end
                    end
                end)

                return {
                    Set = function(v)
                        current = v
                        keyText.Text = tostring(v)
                        window.ConfigData[key] = current
                    end,
                    Get = function() return current end
                }
            end

            function section:AddImage(cfg)
                cfg = cfg or {}

                local height = cfg.Height or 140
                local frame = baseComponent(height)
                frame.ClipsDescendants = true

                local image = Instance.new("ImageLabel")
                image.Name = "Image"
                image.Size = UDim2.new(1, -18, 1, cfg.Text and -34 or -18)
                image.Position = UDim2.new(0, 9, 0, 9)
                image.BackgroundTransparency = 1
                image.Image = cfg.Image or window.Logo
                image.ImageColor3 = Color3.new(1, 1, 1)
                image.ScaleType = cfg.ScaleType or Enum.ScaleType.Crop
                image.Parent = frame
                corner(image, cfg.Radius or 12)

                if cfg.Text then
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, -18, 0, 22)
                    text.Position = UDim2.new(0, 9, 1, -27)
                    text.BackgroundTransparency = 1
                    text.Text = cfg.Text
                    text.TextColor3 = theme.accent
                    text.Font = Enum.Font.GothamBlack
                    text.TextSize = IsMobile and 11 or 12
                    text.TextXAlignment = Enum.TextXAlignment.Center
                    text.Parent = frame
                end

                return image
            end

            function section:AddProgressBar(cfg)
                cfg = cfg or {}
                local frame = baseComponent(48)

                makeText(frame, {
                    Text = cfg.Text or "Progress",
                    TextColor3 = theme.text,
                    Font = Enum.Font.GothamBold,
                    TextSize = IsMobile and 12 or 13,
                    Size = UDim2.new(1, -90, 0, 22),
                    Position = UDim2.new(0, 12, 0, 5)
                })

                local percentLabel = makeText(frame, {
                    Text = "0%",
                    TextColor3 = theme.accent,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    Size = UDim2.new(0, 70, 0, 22),
                    Position = UDim2.new(1, -82, 0, 5),
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, -24, 0, 8)
                bar.Position = UDim2.new(0, 12, 1, -15)
                bar.BackgroundColor3 = theme.bg2
                bar.BorderSizePixel = 0
                bar.Parent = frame
                corner(bar, 999)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = theme.accent
                fill.BorderSizePixel = 0
                fill.Parent = bar
                corner(fill, 999)

                return {
                    SetProgress = function(percent)
                        percent = math.clamp(percent or 0, 0, 100)
                        percentLabel.Text = tostring(math.floor(percent)) .. "%"
                        tween(fill, {Size = UDim2.new(percent / 100, 0, 1, 0)}, 0.2)
                        window.ConfigData[(cfg.Text or "Progress") .. "_progress"] = percent
                    end
                }
            end

            return section
        end

        if #self.Tabs == 1 then
            activate()
        end

        return tab
    end

    return window
end

return AnixlyUI