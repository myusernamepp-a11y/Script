-- [[ FPS GROUNDS / FFA: ULTRA BOX ESP & AIMBOT ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    AimbotActive = false, -- اضغط E للتفعيل/التعطيل
    ESPColor = Color3.fromRGB(255, 0, 0), -- لون المربع أحمر
    BoxThickness = 1.5
}

local ESPTable = {}

-- دالة لإنشاء مربع الرسم للاعب
local function CreateESP(player)
    if ESPTable[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESPColor
    box.Thickness = Settings.BoxThickness
    box.Filled = false
    
    ESPTable[player] = box
end

-- تنظيف الـ ESP لما اللاعب يطلع
local function RemoveESP(player)
    if ESPTable[player] then
        ESPTable[player]:Remove()
        ESPTable[player] = nil
    end
end

-- تشغيل المراقبة للجميع
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then CreateESP(p) end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- فحص الرؤية للأيم بوت
local function IsPlayerVisible(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then return false end
    local targetHead = targetPlayer.Character.Head
    local ignoreList = {LocalPlayer.Character, targetPlayer.Character, Camera}
    local obscuringParts = Camera:GetPartsObscuringTarget({targetHead.Position}, ignoreList)
    return #obscuringParts == 0
end

-- البحث عن أقرب هدف للأيم بوت
local function GetTarget()
    local target = nil
    local dist = 350
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                if IsPlayerVisible(p) then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < dist then 
                            target = p
                            dist = mag 
                        end
                    end
                end
            end
        end
    end
    return target
end

-- اللوب الرئيسي للتحديث المستمر والأبدي
RunService.RenderStepped:Connect(function()
    -- 1. تحديث الـ ESP لكل اللاعبين العايشين
    for player, box in pairs(ESPTable) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                -- حساب حجم المربع بناءً على بعد اللاعب عنك
                local scale = 1 / (pos.Z * 2) * 1000
                local w, h = 3 * scale, 4 * scale
                
                box.Size = Vector2.new(w, h)
                box.Position = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false -- لو مات أو اختفى مجسمه يختفي المربع مؤقتاً لين يرسبن
        end
    end
    
    -- 2. تشغيل الأيم بوت لو ضغطت E
    if Settings.AimbotActive then
        local t = GetTarget()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
end)

-- زر التفعيل والتعطيل للأيم بوت (E)
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.E then 
        Settings.AimbotActive = not Settings.AimbotActive 
    end
end)

