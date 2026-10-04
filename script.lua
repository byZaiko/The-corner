-- Zaiko Key System (transparente estilo Zaiko, persistente)
local CORRECT_KEY = "2kllx20m98"
local KEY_FILE = "ZaikoKey.txt"

local function readSavedKey()
    local ok, res = pcall(function()
        if isfile and isfile(KEY_FILE) then
            return readfile(KEY_FILE)
        end
        return nil
    end)
    if ok then return res end
    return nil
end

local function saveKey(k)
    pcall(function()
        if writefile then
            writefile(KEY_FILE, k)
        end
    end)
    getgenv().ZaikoKeySaved = k
end

local savedZaikoKey = readSavedKey()
if getgenv().ZaikoKeySaved == CORRECT_KEY then savedZaikoKey = CORRECT_KEY end

if savedZaikoKey ~= CORRECT_KEY then
    local authorized = false
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZaikoKeyGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not gui.Parent then
        gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.45
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(320, 200)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Zaiko"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 24
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Position = UDim2.new(0, 0, 0, 48)
    sub.BackgroundTransparency = 1
    sub.Text = "The Corner • Key System"
    sub.Font = Enum.Font.Gotham
    sub.TextColor3 = Color3.fromRGB(170, 170, 180)
    sub.TextSize = 13
    sub.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -32, 0, 38)
    box.Position = UDim2.new(0, 16, 0, 78)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    box.BackgroundTransparency = 0.15
    box.PlaceholderText = "Pon tu key..."
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.new(1, 1, 1)
    box.TextSize = 14
    box.Parent = frame
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = box

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -32, 0, 38)
    btn.Position = UDim2.new(0, 16, 0, 126)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.1
    btn.Text = "Confirmar"
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(15, 15, 15)
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if box.Text == CORRECT_KEY then
            saveKey(box.Text)
            authorized = true
            gui:Destroy()
        else
            btn.Text = "Key incorrecta"
            task.delay(1, function()
                if btn and btn.Parent then btn.Text = "Confirmar" end
            end)
        end
    end)

    repeat task.wait() until authorized
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

if getgenv().ZaikoCleanup then
    pcall(getgenv().ZaikoCleanup)
end

-- Limpieza dura de restos de ejecuciones anteriores
pcall(function() RunService:UnbindFromRenderStep("ZaikoAuraLoop") end)
pcall(function() RunService:UnbindFromRenderStep("FlyBinding") end)
pcall(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local hl = char:FindFirstChild("ZaikoAura")
            if hl then hl:Destroy() end
            local head = char:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("ZaikoTag")
                if tag then tag:Destroy() end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bx = hrp:FindFirstChild("ZaikoBox")
                if bx then bx:Destroy() end
            end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function() p.LocalTransparencyModifier = 0 end)
                end
                if p.Name == "ZaikoEar" or p.Name == "ZaikoEarWire" then
                    pcall(function() p:Destroy() end)
                end
            end
        end
    end
end)
getgenv().ZaikoVersion = "2026-10-04-noauto"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
pcall(function()
    Fluent:ToggleAcrylic(false)
    Fluent:ToggleTransparency(false)
end)
getgenv().ZaikoFluent = Fluent

local Window = Fluent:CreateWindow({
    Title = "Zaiko",
    SubTitle = "The Corner",
    TabWidth = 120,
    Size = UDim2.fromOffset(480, 380),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.M,
})

local Tabs = {
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Spectate = Window:AddTab({ Title = "Spectate", Icon = "eye" }),
    Rooms = Window:AddTab({ Title = "Rooms", Icon = "home" }),
    Fly = Window:AddTab({ Title = "Volar", Icon = "plane" }),
    Extra = Window:AddTab({ Title = "Extra", Icon = "plus" }),
}

local Options = Fluent.Options
local connections = {}

local function track(conn)
    connections[#connections + 1] = conn
    return conn
end

local function notify(text, duration)
    Fluent:Notify({ Title = "Zaiko", Content = text, Duration = duration or 2 })
end

local tpSoundOn = true
local clickTpOn = false
local clickConn = nil

local function playTpSound()
    if not tpSoundOn then
        return
    end
    pcall(function()
        local gui = player:FindFirstChildOfClass("PlayerGui")
        if not gui then
            return
        end
        local s = Instance.new("Sound")
        s.Name = "ZaikoTp"
        s.SoundId = "rbxasset://sounds/button.wav"
        s.Volume = 0.5
        s.Parent = gui
        s:Play()
        Debris:AddItem(s, 3)
    end)
end

local function playerLabel(plr)
    local name = plr.Name
    local display = plr.DisplayName
    if display ~= name then
        return display .. " (@" .. name .. ")"
    end
    return name
end

local emptyList = { "(nadie en el server)" }

local function listPlayers()
    local labels = {}
    local i = 0
    local list = Players:GetPlayers()
    for n = 1, #list do
        local plr = list[n]
        if plr ~= player then
            i += 1
            labels[i] = playerLabel(plr)
        end
    end
    if i == 0 then
        return emptyList
    end
    table.sort(labels)
    return labels
end

local function findPlayer(label)
    if type(label) ~= "string" or label == "" or label == emptyList[1] then
        return nil
    end
    local atName = string.match(label, "@([^)]+)%)")
    if atName then
        return Players:FindFirstChild(atName)
    end
    local list = Players:GetPlayers()
    for n = 1, #list do
        local plr = list[n]
        if plr ~= player and (plr.Name == label or plr.DisplayName == label) then
            return plr
        end
    end
    local needle = string.lower(label)
    for n = 1, #list do
        local plr = list[n]
        if plr ~= player then
            if string.find(string.lower(plr.Name), needle, 1, true)
                or string.find(string.lower(plr.DisplayName), needle, 1, true) then
                return plr
            end
        end
    end
    return nil
end

local function rootPart(character)
    if not character then
        return nil
    end
    return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end

-- Back: guarda tu sitio antes del TP y vuelve con el botón (sin loops, costo cero)
local lastPosition = nil
local function savePos()
    local r = rootPart(player.Character)
    if r then
        lastPosition = r.CFrame
    end
end
local function goBack()
    if not lastPosition then
        notify("Sin posición guardada.", 2)
        return
    end
    local r = rootPart(player.Character)
    if r then
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = lastPosition
        playTpSound()
        notify("De vuelta.", 2)
    end
end

local function teleportTo(target)
    local myRoot = rootPart(player.Character)
    local tChar = target and target.Character
    local theirRoot = rootPart(tChar)
    if not (myRoot and theirRoot) then
        return
    end
    myRoot.AssemblyLinearVelocity = Vector3.zero
    local roomName = nil
    pcall(function()
        roomName = tChar:GetAttribute("CurrentPrivateRoom")
    end)
    if type(roomName) == "string" and roomName ~= "" then
        local ok, spawnCF = pcall(function()
            local rooms = workspace:FindFirstChild("PrivateRooms")
            rooms = rooms and rooms:FindFirstChild("Rooms")
            local room = rooms and rooms:FindFirstChild(roomName)
            local spawn = room and room:FindFirstChild("Spawn")
            if spawn and spawn:IsA("BasePart") then
                return spawn.CFrame
            end
            return nil
        end)
        if ok and spawnCF then
            myRoot.CFrame = spawnCF + Vector3.new(math.random(-4, 4), 3, math.random(-4, 4))
            playTpSound()
            return
        end
    end
    myRoot.CFrame = theirRoot.CFrame * CFrame.new(0, 0, 3)
    playTpSound()
end

local function teleportToRoom(roomName)
    if type(roomName) ~= "string" or roomName == "" then
        return false
    end
    local myRoot = rootPart(player.Character)
    if not myRoot then
        return false
    end
    local ok, spawnCF = pcall(function()
        local rooms = workspace:FindFirstChild("PrivateRooms")
        rooms = rooms and rooms:FindFirstChild("Rooms")
        local room = rooms and rooms:FindFirstChild(roomName)
        local spawn = room and room:FindFirstChild("Spawn")
        if spawn and spawn:IsA("BasePart") then
            return spawn.CFrame
        end
        return nil
    end)
    if ok and spawnCF then
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.CFrame = spawnCF + Vector3.new(math.random(-4, 4), 3, math.random(-4, 4))
        playTpSound()
        return true
    end
    return false
end

local function setClickTp(on)
    clickTpOn = on
    if clickConn then
        clickConn:Disconnect()
        clickConn = nil
    end
    if on then
        clickConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1
                and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = player:GetMouse()
                local root = rootPart(player.Character)
                if root and mouse then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    playTpSound()
                end
            end
        end)
        track(clickConn)
        notify("Click-TP on: Ctrl+clic.", 2)
    else
        notify("Click-TP off.", 2)
    end
end

local antiAfkOn = false
local antiAfkConn = nil

local function setAntiAfk(on)
    antiAfkOn = on
    if antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end
    if on then
        antiAfkConn = player.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
        track(antiAfkConn)
        notify("Anti-AFK on.", 2)
    else
        notify("Anti-AFK off.", 2)
    end
end

-- Ver invisibles optimizado: revisa 1x por segundo y solo toca a quien cambió de estado
local seeInvisibleOn = false
local espMarked = {}

local function clearAuras()
    table.clear(espMarked)
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local hl = char:FindFirstChild("ZaikoAura")
                if hl then hl:Destroy() end
                local head = char:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("ZaikoTag")
                    if tag then tag:Destroy() end
                end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bx = hrp:FindFirstChild("ZaikoBox")
                    if bx then bx:Destroy() end
                end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.LocalTransparencyModifier = 0 end)
                    end
                end
            end
        end
    end)
    pcall(function()
        RunService:UnbindFromRenderStep("ZaikoAuraLoop")
    end)
end

local function isInvisibleChar(char)
    if not char then
        return false
    end
    local ok, v = pcall(function() return char:GetAttribute("Invisible") end)
    if ok and v == true then
        return true
    end
    local head = char:FindFirstChild("Head")
    return head and head:IsA("BasePart") and head.Transparency >= 0.7 or false
end

local function prettyTagName(plr)
    if plr.DisplayName ~= plr.Name then
        return plr.DisplayName .. " (@" .. plr.Name .. ")"
    end
    return plr.Name
end

local function unmarkPlayer(plr)
    espMarked[plr] = nil
    local char = plr.Character
    if not char then
        return
    end
    local head = char:FindFirstChild("Head")
    if head then
        local tag = head:FindFirstChild("ZaikoTag")
        if tag then pcall(function() tag:Destroy() end) end
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bx = hrp:FindFirstChild("ZaikoBox")
        if bx then pcall(function() bx:Destroy() end) end
    end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.LocalTransparencyModifier = 0 end)
        end
    end
end

local function setSeeInvisible(on)
    seeInvisibleOn = on
    if not on then
        clearAuras()
        notify("ESP off.", 2)
        return
    end
    notify("ESP on: revela invisibles.", 2)
    pcall(function() RunService:UnbindFromRenderStep("ZaikoAuraLoop") end)
    local acc = 0
    RunService:BindToRenderStep("ZaikoAuraLoop", Enum.RenderPriority.Last.Value, function(dt)
        if not seeInvisibleOn then
            return
        end
        acc += dt
        if acc < 1 then
            return
        end
        acc = 0
        local myRoot = rootPart(player.Character)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                if char and isInvisibleChar(char) then
                    local head = char:FindFirstChild("Head")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not head or not hrp then
                        continue
                    end
                    local dist = 0
                    if myRoot then
                        dist = (myRoot.Position - hrp.Position).Magnitude
                    end
                    local sc = math.clamp(26 / math.max(dist, 9), 0.38, 1)
                    local tag = head:FindFirstChild("ZaikoTag")
                    if not tag then
                        tag = Instance.new("BillboardGui")
                        tag.Name = "ZaikoTag"
                        tag.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
                        tag.AlwaysOnTop = true
                        tag.LightInfluence = 0
                        local bg2 = Instance.new("Frame")
                        bg2.Name = "Bg"
                        bg2.Size = UDim2.fromScale(1, 1)
                        bg2.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                        bg2.BackgroundTransparency = 0.15
                        bg2.BorderSizePixel = 0
                        bg2.Parent = tag
                        local bgC = Instance.new("UICorner")
                        bgC.CornerRadius = UDim.new(0, 8)
                        bgC.Parent = bg2
                        local bgS = Instance.new("UIStroke")
                        bgS.Color = Color3.fromRGB(170, 0, 255)
                        bgS.Transparency = 0.3
                        bgS.Thickness = 1
                        bgS.Parent = bg2
                        local pad = Instance.new("UIPadding")
                        pad.PaddingLeft = UDim.new(0, 8)
                        pad.PaddingRight = UDim.new(0, 8)
                        pad.Parent = bg2
                        local lbl = Instance.new("TextLabel")
                        lbl.Name = "Lbl"
                        lbl.Size = UDim2.fromScale(1, 1)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextColor3 = Color3.new(1, 1, 1)
                        lbl.TextTruncate = Enum.TextTruncate.AtEnd
                        lbl.Parent = bg2
                        tag.Parent = head
                    end
                    tag.Size = UDim2.fromOffset(math.floor(150 * sc), math.floor(30 * sc))
                    local bg2 = tag:FindFirstChild("Bg")
                    local lbl = bg2 and bg2:FindFirstChild("Lbl")
                    if lbl then
                        local want = prettyTagName(plr)
                        if lbl.Text ~= want then
                            lbl.Text = want
                        end
                        lbl.TextSize = math.max(9, math.floor(13 * sc))
                    end
                    if not hrp:FindFirstChild("ZaikoBox") then
                        pcall(function()
                            local bx = Instance.new("BoxHandleAdornment")
                            bx.Name = "ZaikoBox"
                            bx.Adornee = hrp
                            bx.Size = Vector3.new(4, 6, 3)
                            bx.Color3 = Color3.fromRGB(170, 0, 255)
                            bx.Transparency = 0.6
                            bx.AlwaysOnTop = true
                            bx.ZIndex = 5
                            bx.Parent = hrp
                        end)
                    end
                    if not espMarked[plr] then
                        espMarked[plr] = true
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                                pcall(function() p.LocalTransparencyModifier = -p.Transparency end)
                            end
                        end
                    end
                elseif espMarked[plr] then
                    unmarkPlayer(plr)
                end
            end
        end
    end)
end

local spectateTarget = nil
local spectateHum = nil
local spectateToken = 0
local listenInRooms = true
local roomListener = nil
local roomWire = nil

local function getAudioOutput()
    camera = workspace.CurrentCamera
    if not camera then
        return nil
    end
    local out = camera:FindFirstChildOfClass("AudioDeviceOutput")
    if out then
        return out
    end
    for _, c in ipairs(camera:GetChildren()) do
        if c:IsA("AudioDeviceOutput") then
            return c
        end
    end
    return nil
end

local function destroyRoomListener()
    if roomWire then
        pcall(function() roomWire:Destroy() end)
        roomWire = nil
    end
    if roomListener then
        pcall(function() roomListener:Destroy() end)
        roomListener = nil
    end
end

local function attachRoomListener(target)
    if not listenInRooms then
        return
    end
    local out = getAudioOutput()
    if not out then
        return
    end
    local char = target and target.Character
    local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    if not (out and head) then
        return
    end
    if roomListener and roomListener.Parent == head then
        return
    end
    destroyRoomListener()
    pcall(function()
        local lis = Instance.new("AudioListener")
        lis.Name = "ZaikoEar"
        lis.Parent = head
        local w = Instance.new("Wire")
        w.Name = "ZaikoEarWire"
        w.SourceInstance = lis
        w.TargetInstance = out
        w.Parent = lis
        roomListener = lis
        roomWire = w
    end)
end

local function restoreCamera()
    camera = workspace.CurrentCamera
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    camera.CameraType = Enum.CameraType.Custom
    if hum then
        camera.CameraSubject = hum
    end
end

local function stopSpectate(silent)
    spectateToken += 1
    spectateTarget = nil
    spectateHum = nil
    destroyRoomListener()
    restoreCamera()
    if not silent then
        notify("Spectate off.")
    end
end

local function startSpectate(target)
    if not target then
        return
    end
    spectateToken += 1
    local token = spectateToken
    spectateTarget = target
    spectateHum = nil
    destroyRoomListener()

    task.spawn(function()
        while token == spectateToken and spectateTarget == target do
            if not target.Parent then
                stopSpectate(true)
                return
            end
            local tChar = target.Character
            local hum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            if hum then
                camera = workspace.CurrentCamera
                if spectateHum ~= hum or camera.CameraSubject ~= hum then
                    spectateHum = hum
                    camera.CameraType = Enum.CameraType.Custom
                    camera.CameraSubject = hum
                end
                attachRoomListener(target)
                if roomListener and tChar then
                    local head = tChar:FindFirstChild("Head")
                    if head and roomListener.Parent ~= head then
                        attachRoomListener(target)
                    end
                end
            end
            task.wait(0.3)
        end
    end)

    notify("Viendo a " .. playerLabel(target), 2)
end

getgenv().ZaikoStopSpectate = function()
    stopSpectate(true)
end

local roomSpyAuto = false
local roomSpyToken = 0
local noRoomsList = { "(sin cuartos)" }

local function getRoomFolder()
    local pr = workspace:FindFirstChild("PrivateRooms")
    return pr and pr:FindFirstChild("Rooms")
end

local function getOccupants(roomName)
    local out = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, r = pcall(function()
            return plr.Character and plr.Character:GetAttribute("CurrentPrivateRoom")
        end)
        if ok and r == roomName then
            out[#out + 1] = plr
        end
    end
    return out
end

local function roomLabel(room)
    local owner = room.Name
    local topic = ""
    local maxP = 0
    pcall(function()
        topic = tostring(room:GetAttribute("Topic") or "")
        maxP = tonumber(room:GetAttribute("MaxPlayers") or 0) or 0
    end)
    local n = #getOccupants(owner)
    local base = owner .. " (" .. n
    if maxP > 0 then
        base ..= "/" .. maxP
    end
    base ..= ")"
    if topic ~= "" and topic ~= "nil" then
        if #topic > 24 then
            topic = string.sub(topic, 1, 24) .. "…"
        end
        base ..= " - " .. topic
    end
    return base
end

local function listRoomLabels()
    local folder = getRoomFolder()
    if not folder then
        return noRoomsList
    end
    local kids = folder:GetChildren()
    if #kids == 0 then
        return noRoomsList
    end
    local labels = {}
    for i = 1, #kids do
        labels[i] = roomLabel(kids[i])
    end
    table.sort(labels)
    return labels
end

local function findRoomByLabel(label)
    if type(label) ~= "string" or label == "" or label == noRoomsList[1] then
        return nil
    end
    local folder = getRoomFolder()
    if not folder then
        return nil
    end
    local owner = string.match(label, "^([^%s%(]+)")
    if owner then
        local direct = folder:FindFirstChild(owner)
        if direct then
            return direct
        end
    end
    for _, r in ipairs(folder:GetChildren()) do
        if string.find(label, r.Name, 1, true) then
            return r
        end
    end
    return nil
end

local function roomDetails(room)
    if not room then
        return "Sin cuarto."
    end
    local topic, maxP, music = "", 0, 0
    pcall(function()
        topic = tostring(room:GetAttribute("Topic") or "")
        maxP = tonumber(room:GetAttribute("MaxPlayers") or 0) or 0
        music = tonumber(room:GetAttribute("MusicId") or 0) or 0
    end)
    local occ = getOccupants(room.Name)
    local names = {}
    for i = 1, #occ do
        names[i] = occ[i].Name
    end
    local txt = room.Name .. ": " .. #occ
    if maxP > 0 then
        txt ..= "/" .. maxP
    end
    if topic ~= "" and topic ~= "nil" then
        txt ..= " | Topic: " .. topic
    end
    if music ~= 0 then
        txt ..= " | Music: " .. music
    end
    if #names > 0 then
        txt ..= " | " .. table.concat(names, ", ")
    end
    return txt
end

Tabs.Teleport:AddParagraph({
    Title = "The Corner",
    Content = "M abre o cierra. Spectate no mueve tu cuerpo.",
})

local cachedList = listPlayers()

local Dropdown = Tabs.Teleport:AddDropdown("ZaikoPlayer", {
    Title = "Jugador",
    Values = cachedList,
    Multi = false,
    Default = 1,
})

local SpecDropdown = Tabs.Spectate:AddDropdown("ZaikoSpecPlayer", {
    Title = "Jugador",
    Values = cachedList,
    Multi = false,
    Default = 1,
})

local RoomDropdown = Tabs.Rooms:AddDropdown("ZaikoRoom", {
    Title = "Cuarto",
    Values = listRoomLabels(),
    Multi = false,
    Default = 1,
})

local function setDropdownValues(drop, values)
    if drop.SetValues then
        drop:SetValues(values)
    else
        drop.Values = values
        if drop.BuildDropdownList then
            drop:BuildDropdownList()
        end
    end
end

local function refreshDropdown()
    local values = listPlayers()
    setDropdownValues(Dropdown, values)
    setDropdownValues(SpecDropdown, values)
end

local function refreshRooms(silent)
    local values = listRoomLabels()
    setDropdownValues(RoomDropdown, values)
    if not silent then
        notify("Cuartos: " .. tostring(#values), 2)
    end
end

Tabs.Teleport:AddButton({
    Title = "Actualizar lista",
    Callback = refreshDropdown,
})

Tabs.Teleport:AddButton({
    Title = "Teleport",
    Callback = function()
        savePos()
        local target = findPlayer(Options.ZaikoPlayer and Options.ZaikoPlayer.Value)
        if target then
            teleportTo(target)
        end
    end,
})

Tabs.Teleport:AddButton({
    Title = "Volver (Back)",
    Callback = function()
        goBack()
    end,
})

Tabs.Teleport:AddInput("ZaikoSearch", {
    Title = "Buscar y TP",
    Default = "",
    Placeholder = "nombre...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        savePos()
        local target = findPlayer(Value)
        if target then
            teleportTo(target)
        end
    end,
})

Tabs.Teleport:AddToggle("ZaikoClickTp", {
    Title = "Click-TP (Ctrl+clic)",
    Default = false,
    Callback = function(Value)
        setClickTp(Value)
    end,
})

Tabs.Teleport:AddToggle("ZaikoTpSound", {
    Title = "Sonido al TP",
    Default = true,
    Callback = function(Value)
        tpSoundOn = Value
    end,
})

Tabs.Spectate:AddParagraph({
    Title = "Camara",
    Content = "Ver sin TP. Oído en cuartos siempre activo y sigiloso.",
})

Tabs.Spectate:AddButton({
    Title = "Actualizar lista",
    Callback = refreshDropdown,
})

Tabs.Spectate:AddButton({
    Title = "Spectate",
    Callback = function()
        local target = findPlayer(Options.ZaikoSpecPlayer and Options.ZaikoSpecPlayer.Value)
        if target then
            startSpectate(target)
        end
    end,
})

Tabs.Spectate:AddButton({
    Title = "Dejar de spectate",
    Callback = function()
        stopSpectate(false)
    end,
})

Tabs.Spectate:AddInput("ZaikoSpecSearch", {
    Title = "Buscar y spectate",
    Default = "",
    Placeholder = "nombre...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        local target = findPlayer(Value)
        if target then
            startSpectate(target)
        end
    end,
})

Tabs.Rooms:AddParagraph({
    Title = "Room Spy",
    Content = "Solo info pública: dueño, conteo y topic. No graba audio.",
})

Tabs.Rooms:AddButton({
    Title = "Actualizar cuartos",
    Callback = function()
        refreshRooms(false)
    end,
})

Tabs.Rooms:AddButton({
    Title = "Ver info del cuarto",
    Callback = function()
        local room = findRoomByLabel(Options.ZaikoRoom and Options.ZaikoRoom.Value)
        notify(roomDetails(room), 4)
    end,
})

Tabs.Rooms:AddButton({
    Title = "Spectate dueño",
    Callback = function()
        local room = findRoomByLabel(Options.ZaikoRoom and Options.ZaikoRoom.Value)
        if room then
            local owner = Players:FindFirstChild(room.Name)
            if owner then
                startSpectate(owner)
                Window:SelectTab(2)
            else
                notify("Dueño fuera del server.", 2)
            end
        end
    end,
})

Tabs.Rooms:AddButton({
    Title = "TP al cuarto (Spawn)",
    Callback = function()
        local room = findRoomByLabel(Options.ZaikoRoom and Options.ZaikoRoom.Value)
        if room then
            savePos()
            if not teleportToRoom(room.Name) then
                notify("No se pudo entrar al Spawn.", 2)
            end
        end
    end,
})

Tabs.Extra:AddParagraph({
    Title = "Server",
    Content = "Cosas del servidor.",
})

Tabs.Extra:AddToggle("ZaikoAntiAfk", {
    Title = "Anti-AFK",
    Default = false,
    Callback = function(Value)
        setAntiAfk(Value)
    end,
})

Tabs.Extra:AddToggle("ZaikoSeeInvisible", {
    Title = "Ver invisibles (aura)",
    Default = false,
    Callback = function(Value)
        setSeeInvisible(Value)
    end,
})

Tabs.Extra:AddButton({
    Title = "Rejoin",
    Callback = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
    end,
})

local anims = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Jetpack"):WaitForChild("Types"):WaitForChild("Jetpack"):WaitForChild("Animations")

local activeAnim = nil
local flyState = "FlyHover"
local isFlying = false
local attachment, alignOrientation, linearVelocity
local charConnection

local function createJetpack()
    local tool = Instance.new("Tool")
    tool.Name = "Jetpack"
    tool.CanBeDropped = false
    tool.RequiresHandle = false
    tool.TextureId = "rbxassetid://1362932274"

    local scriptItem = Instance.new("LocalScript")
    scriptItem.Name = "ToolClient"
    scriptItem.Disabled = true
    scriptItem.Parent = tool

    local objValue = Instance.new("ObjectValue")
    objValue.Name = "Object"
    objValue.Parent = scriptItem

    return tool
end

local function giveJetpack()
    local backpack = player:WaitForChild("Backpack")
    if not backpack:FindFirstChild("Jetpack") and (not player.Character or not player.Character:FindFirstChild("Jetpack")) then
        local tool = createJetpack()
        tool.Parent = backpack
        return true
    end
    return false
end

local function clearSeatWeld(char)
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:FindFirstChild("SeatWeld") then
        for _, child in pairs(hum.SeatPart:GetChildren()) do
            if child.Name == "SeatWeld" then
                child:Destroy()
            end
        end
    end
end

local function playAnim(animName)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChild("Animator")
    if not animator or player:GetAttribute("VR") then return end

    local animObj = anims:FindFirstChild(animName)
    if not animObj then return end

    if activeAnim then
        if activeAnim.Animation.AnimationId == animObj.AnimationId then return end
        activeAnim:Stop(0.3)
    end

    local track = animator:LoadAnimation(animObj)
    track.Priority = Enum.AnimationPriority.Movement
    track:Play(0.3)
    activeAnim = track
end

local function onFlyStep(dt)
    local char = player.Character
    if not char or not alignOrientation or not linearVelocity then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    local cam = workspace.CurrentCamera
    local moveDir = hum.MoveDirection

    local localMove = cam.CFrame:VectorToObjectSpace(moveDir)
    flyState = localMove.Z < -0.1 and "Flying" or (localMove.Z > 0.1 and "FlyBack" or (localMove.X > 0.1 and "FlyRight" or (localMove.X < -0.1 and "FlyLeft" or "FlyHover")))

    local speed = flyState == "Flying" and 80 or (flyState == "FlyBack" and 60 or 64)
    local targetDir = Vector3.new(0, 0, 0)

    if moveDir.Magnitude >= 0.1 then
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        targetDir = (-localMove.Z * look + localMove.X * right).Unit
    end

    local targetVel = targetDir * speed
    linearVelocity.VectorVelocity = targetVel
    playAnim(flyState)

    local targetCFrame
    if targetVel.Magnitude > 1 then
        if flyState == "Flying" or flyState == "FlyBack" then
            local yaw = math.atan2(localMove.X, math.abs(localMove.Z)) * math.sign(localMove.Z)
            targetCFrame = cam.CFrame * CFrame.Angles(0, yaw, 0)
        else
            targetCFrame = cam.CFrame
        end
    else
        local _, yaw, _ = alignOrientation.CFrame:ToEulerAnglesYXZ()
        targetCFrame = CFrame.Angles(0, yaw, 0)
    end

    alignOrientation.CFrame = alignOrientation.CFrame:Lerp(targetCFrame, dt * 10)
    clearSeatWeld(char)
end

local function stopFlying(char, hum)
    if not isFlying then return end
    isFlying = false

    RunService:UnbindFromRenderStep("FlyBinding")
    if activeAnim then
        activeAnim:Stop()
        activeAnim = nil
    end
    if alignOrientation then alignOrientation:Destroy() end
    if linearVelocity then linearVelocity:Destroy() end
    if attachment then attachment:Destroy() end

    if hum then
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    end
    if char then
        char:SetAttribute("Flying", false)
    end
end

local function startFlying(char, hum, root)
    if isFlying then return end
    isFlying = true

    attachment = Instance.new("Attachment")
    attachment.Name = "JetpackAttachment"
    attachment.Parent = root

    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Name = "FlyOrientation"
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.Attachment0 = attachment
    alignOrientation.Responsiveness = 100
    alignOrientation.Enabled = true
    alignOrientation.RigidityEnabled = true
    alignOrientation.CFrame = root.CFrame
    alignOrientation.Parent = root

    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = "FlyVelocity"
    linearVelocity.MaxForce = 10000000000000
    linearVelocity.Attachment0 = attachment
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.Parent = root

    hum.AutoRotate = false
    hum.PlatformStand = true
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    char:SetAttribute("Flying", true)

    RunService:BindToRenderStep("FlyBinding", Enum.RenderPriority.Camera.Value - 1, onFlyStep)
    playAnim("FlyHover")
end

local function setupCharacter(char)
    if charConnection then charConnection:Disconnect() end
    isFlying = false

    task.wait(0.5)
    giveJetpack()

    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    charConnection = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "Jetpack" then
            task.defer(function()
                hum:UnequipTools()
            end)
            if isFlying then
                stopFlying(char, hum)
            else
                startFlying(char, hum, root)
            end
        end
    end)
end

Tabs.Fly:AddParagraph({
    Title = "Jetpack",
    Content = "Item en inventario. Clic para volar.",
})

Tabs.Fly:AddButton({
    Title = "Dar Jetpack",
    Callback = function()
        giveJetpack()
    end,
})

track(Players.PlayerRemoving:Connect(function(plr)
    if spectateTarget == plr then
        stopSpectate(true)
    end
    espMarked[plr] = nil
end))

getgenv().ZaikoCleanup = function()
    stopSpectate(true)
    destroyRoomListener()
    roomSpyToken += 1
    roomSpyAuto = false
    setSeeInvisible(false)
    setAntiAfk(false)
    setClickTp(false)
    pcall(function()
        if isFlying then
            RunService:UnbindFromRenderStep("FlyBinding")
        end
    end)
    pcall(stopFlying, player.Character, player.Character and player.Character:FindFirstChild("Humanoid"))
    for i = 1, #connections do
        pcall(function()
            connections[i]:Disconnect()
        end)
    end
    table.clear(connections)
    if antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end)
        antiAfkConn = nil
    end
    if charConnection then
        charConnection:Disconnect()
        charConnection = nil
    end
    clickConn = nil
    pcall(function()
        Fluent:Destroy()
    end)
    getgenv().ZaikoFluent = nil
    getgenv().ZaikoCleanup = nil
    getgenv().ZaikoStopSpectate = nil
end

giveJetpack()
if player.Character then
    task.spawn(setupCharacter, player.Character)
end
track(player.CharacterAdded:Connect(function(char)
    destroyRoomListener()
    if not spectateTarget then
        task.defer(restoreCamera)
    end
    setupCharacter(char)
end))

Window:SelectTab(1)
