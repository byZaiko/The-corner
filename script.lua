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

-- Anti-AFK
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

-- Spectate sigiloso con audio en cuartos privados (siempre activo, no mueve tu cuerpo)
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
            task.wait(0.2)
        end
    end)

    notify("Viendo a " .. playerLabel(target), 2)
end

getgenv().ZaikoStopSpectate = function()
    stopSpectate(true)
end

-- Room Spy (solo metadata pública, sin grabar audio)
local roomSpyAuto = false
local roomSpyToken = 0
local noRoomsList = { "(sin cuartos)" }

local function getRoomFolder()
    local ok, rooms = pcall(function()
        local pr = workspace:FindFirstChild("PrivateRooms")
        return pr and pr:FindFirstChild("Rooms")
    end)
    if ok then
        return rooms
    end
    return nil
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
        local target = findPlayer(Options.ZaikoPlayer and Options.ZaikoPlayer.Value)
        if target then
            teleportTo(target)
        end
    end,
})

Tabs.Teleport:AddInput("ZaikoSearch", {
    Title = "Buscar y TP",
    Default = "",
    Placeholder = "nombre...",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
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
            if not teleportToRoom(room.Name) then
                notify("No se pudo entrar al Spawn.", 2)
            end
        end
    end,
})

Tabs.Rooms:AddToggle("ZaikoRoomAuto", {
    Title = "Auto-actualizar cuartos",
    Default = false,
    Callback = function(Value)
        roomSpyAuto = Value
        roomSpyToken += 1
        if Value then
            local token = roomSpyToken
            task.spawn(function()
                while token == roomSpyToken and roomSpyAuto do
                    pcall(refreshRooms, true)
                    task.wait(4)
                end
            end)
            notify("Room auto on.", 2)
        else
            notify("Room auto off.", 2)
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
end))

getgenv().ZaikoCleanup = function()
    stopSpectate(true)
    destroyRoomListener()
    roomSpyToken += 1
    roomSpyAuto = false
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
