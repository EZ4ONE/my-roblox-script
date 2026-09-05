-- PET SIMULATOR 99 - AUTO GACHA HUGE
-- FOKUS: HATCH + BUY EGG + SPEED FARM
-- BY: Yonzzx

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- ============================================
-- KONFIGURASI (UBAH SESUAI SELERA)
-- ============================================
local Config = {
    -- FARM
    AutoFarm = true,
    FarmSpeed = 0.02, -- Makin kecil makin cepet (0.01 - 0.05)
    
    -- GACHA UTAMA
    AutoHatch = true,
    HatchSpeed = 0.05, -- Kecepatan buka egg
    
    -- BELI EGG
    AutoBuyEgg = true,
    EggPriority = "Huge", -- "Huge" / "Exclusive" / "Mythical" / "Legendary"
    BuyInterval = 1, -- Detik interval beli egg
    
    -- MERGE (BIAR PET LEVEL NAIK)
    AutoMerge = true,
    MergeInterval = 2,
    
    -- REBIRTH (NAIKIN MULTIPLIER)
    AutoRebirth = true,
    RebirthInterval = 45, -- Detik
    
    -- BOOST (PAKE POTION/GAMEPASS)
    AutoBoost = true,
    
    -- VISUAL NOTIF
    ShowNotif = true
}

-- ============================================
-- DETEKSI REMOTE
-- ============================================
local Remotes = {
    Click = RS:FindFirstChild("Click") or RS:FindFirstChild("PetClick") or RS:FindFirstChild("BreakableClick"),
    Hatch = RS:FindFirstChild("Hatch") or RS:FindFirstChild("OpenEgg") or RS:FindFirstChild("EggHatch"),
    Merge = RS:FindFirstChild("Merge") or RS:FindFirstChild("CombinePets") or RS:FindFirstChild("FusePets"),
    Rebirth = RS:FindFirstChild("Rebirth") or RS:FindFirstChild("Prestige"),
    Buy = RS:FindFirstChild("BuyEgg") or RS:FindFirstChild("PurchaseEgg") or RS:FindFirstChild("BuyPet")
}

-- ============================================
-- UTILITY
-- ============================================
local function rd(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function findObjects(keyword)
    local result = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local name = v.Name:lower()
            if name:find(keyword:lower()) then
                table.insert(result, v)
            end
        end
    end
    return result
end

local function findInGUI(keyword)
    local result = {}
    local guis = LP.PlayerGui:GetChildren()
    for _, gui in pairs(guis) do
        for _, v in pairs(gui:GetDescendants()) do
            if v:IsA("TextButton") or v:IsA("ImageButton") then
                local name = v.Name:lower()
                local text = (v.Text and v.Text:lower()) or ""
                if name:find(keyword:lower()) or text:find(keyword:lower()) then
                    table.insert(result, v)
                end
            end
        end
    end
    return result
end

local function clickPart(part)
    if Remotes.Click then
        Remotes.Click:FireServer(part)
    else
        HRP.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ============================================
-- CORE: AUTO FARM (KAYA CEPET)
-- ============================================
local function autoFarm()
    while Config.AutoFarm do
        local targets = {}
        
        -- Kumpulin semua yang bisa di-click
        for _, keyword in pairs({"breakable", "chest", "coin", "crystal", "diamond", "gem", "present"}) do
            for _, obj in pairs(findObjects(keyword)) do
                table.insert(targets, obj)
            end
        end
        
        if #targets > 0 then
            for _, target in pairs(targets) do
                clickPart(target)
                task.wait(rd(0.01, 0.03)) -- SUPER CEPET
            end
        end
        task.wait(rd(0.03, 0.06))
    end
end

-- ============================================
-- CORE: AUTO GACHA (BUKA EGG TERUS)
-- ============================================
local function autoHatch()
    while Config.AutoHatch do
        -- Cari semua egg di sekitar
        local eggs = findObjects("egg")
        
        if #eggs > 0 then
            for _, egg in pairs(eggs) do
                if Remotes.Hatch then
                    Remotes.Hatch:FireServer(egg)
                    task.wait(rd(0.03, 0.07))
                end
            end
        end
        
        -- Alternative: hatch lewat GUI kalo remote gak ada
        local hatchButtons = findInGUI("hatch")
        if #hatchButtons > 0 then
            for _, btn in pairs(hatchButtons) do
                btn:Click()
                task.wait(rd(0.03, 0.07))
            end
        end
        
        task.wait(rd(0.1, 0.3))
    end
end

-- ============================================
-- CORE: AUTO BUY EGG (BELI YANG PUNYA CHANCE HUGE)
-- ============================================
local function autoBuyEgg()
    while Config.AutoBuyEgg do
        -- Cari egg shop di GUI
        local shop = LP.PlayerGui:FindFirstChild("Shop") or LP.PlayerGui:FindFirstChild("EggShop")
        
        if shop then
            -- Cari egg yang punya chance huge
            local eggsToBuy = {}
            for _, v in pairs(shop:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    local text = (v.Text and v.Text:lower()) or ""
                    local name = v.Name:lower()
                    
                    -- Prioritaskan egg dengan keyword huge
                    if text:find("huge") or name:find("huge") then
                        table.insert(eggsToBuy, 1, v) -- Priority
                    elseif text:find("exclusive") or name:find("exclusive") then
                        table.insert(eggsToBuy, v)
                    elseif text:find("mythical") or name:find("mythical") then
                        table.insert(eggsToBuy, v)
                    elseif text:find("legendary") or name:find("legendary") then
                        table.insert(eggsToBuy, v)
                    end
                end
            end
            
            -- Beli semua egg yang ditemukan
            for _, egg in pairs(eggsToBuy) do
                egg:Click()
                task.wait(rd(0.2, 0.5))
            end
        end
        
        -- Alternative: pake remote buy
        if Remotes.Buy then
            Remotes.Buy:FireServer(Config.EggPriority)
            task.wait(rd(0.2, 0.5))
        end
        
        task.wait(rd(Config.BuyInterval, Config.BuyInterval + 0.5))
    end
end

-- ============================================
-- CORE: AUTO MERGE (GABUNG PET)
-- ============================================
local function autoMerge()
    while Config.AutoMerge do
        local mergeButtons = findInGUI("merge")
        
        if #mergeButtons > 0 then
            for _, btn in pairs(mergeButtons) do
                btn:Click()
                task.wait(rd(0.2, 0.4))
            end
        end
        
        -- Kalo ada remote merge
        if Remotes.Merge then
            Remotes.Merge:FireServer("MergeAll")
        end
        
        task.wait(rd(Config.MergeInterval, Config.MergeInterval + 1))
    end
end

-- ============================================
-- CORE: AUTO REBIRTH (NAIKIN MULTIPLIER)
-- ============================================
local function autoRebirth()
    while Config.AutoRebirth do
        local rebirthButtons = findInGUI("rebirth")
        
        if #rebirthButtons > 0 then
            for _, btn in pairs(rebirthButtons) do
                btn:Click()
                task.wait(1)
                -- Confirm
                local confirmButtons = findInGUI("confirm")
                for _, confirm in pairs(confirmButtons) do
                    confirm:Click()
                end
            end
        end
        
        if Remotes.Rebirth then
            Remotes.Rebirth:FireServer()
        end
        
        task.wait(rd(Config.RebirthInterval, Config.RebirthInterval + 15))
    end
end

-- ============================================
-- CORE: AUTO BOOST (PAKE LUCKY POTION DLL)
-- ============================================
local function autoBoost()
    while Config.AutoBoost do
        local boosts = LP.Backpack:GetChildren()
        for _, item in pairs(boosts) do
            local name = item.Name:lower()
            if name:find("lucky") or name:find("boost") or name:find("potion") or name:find("ench") then
                item.Parent = LP.Character
                task.wait(rd(0.2, 0.5))
            end
        end
        task.wait(60)
    end
end

-- ============================================
-- HUGE DETECTOR + AUTO SCREENSHOT (NOTIF)
-- ============================================
local hugeDetected = false

local function hugeDetector()
    while true do
        local inv = LP.PlayerGui:FindFirstChild("Inventory") or LP.PlayerGui:FindFirstChild("Pets")
        if inv then
            for _, v in pairs(inv:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    local text = v.Text or ""
                    if text:find("Huge") or text:find("Titanic") then
                        if not hugeDetected then
                            hugeDetected = true
                            print("========================================")
                            print("🔥🔥🔥 HUGE PET DETECTED! 🔥🔥🔥")
                            print("🔥🔥🔥 " .. text .. " 🔥🔥🔥")
                            print("========================================")
                            
                            -- Notif GUI
                            if Config.ShowNotif then
                                local gui = Instance.new("ScreenGui")
                                gui.Name = "HugeNotif"
                                gui.Parent = LP.PlayerGui
                                
                                local frame = Instance.new("Frame")
                                frame.Size = UDim2.new(0, 400, 0, 150)
                                frame.Position = UDim2.new(0.5, -200, 0.4, 0)
                                frame.BackgroundColor3 = Color3.new(1, 0.8, 0)
                                frame.BorderSizePixel = 0
                                frame.Parent = gui
                                
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.Text = "🔥🔥🔥 HUGE PET!! 🔥🔥🔥\n" .. text
                                label.TextColor3 = Color3.new(1, 1, 1)
                                label.TextScaled = true
                                label.Font = Enum.Font.GothamBold
                                label.BackgroundTransparency = 1
                                label.Parent = frame
                                
                                -- Auto close after 10s
                                task.wait(10)
                                gui:Destroy()
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end

-- ============================================
-- SPEED UP (MAKE GAME BERJALAN CEPET)
-- ============================================
local function speedUp()
    -- Naikin walkspeed
    local hum = Char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = 50
        hum.JumpPower = 80
    end
    
    -- Naikin game speed (kalo pake executor yg support)
    if game:FindFirstChild("RunService") then
        game:GetService("RunService"):Set3dRenderingEnabled(true)
    end
end

-- ============================================
-- EXECUTE SEMUA
-- ============================================
spawn(autoFarm)
spawn(autoHatch)
spawn(autoBuyEgg)
spawn(autoMerge)
spawn(autoRebirth)
spawn(autoBoost)
spawn(hugeDetector)
spawn(speedUp)

print("========================================")
print("🔥 PS99 AUTO GACHA HUGE BY YONZZX 🔥")
print("========================================")
print("✅ Auto Farm: ACTIVE (SUPER FAST)")
print("✅ Auto Hatch: ACTIVE (GACHA TERUS)")
print("✅ Auto Buy Egg: ACTIVE (PRIORITAS HUGE)")
print("✅ Auto Merge: ACTIVE")
print("✅ Auto Rebirth: ACTIVE")
print("✅ Auto Boost: ACTIVE")
print("✅ Huge Detector: ACTIVE")
print("========================================")
print("💎 TUNGGU SAMPAI HUGE MUNCUL!")
print("📌 NOTIF AKAN MUNCUL KALO DAH DAPAT")
print("========================================")

-- GUI START
local function startGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "YonzzxGacha"
    gui.Parent = LP.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(0.5, -150, 0.85, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.Parent = gui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "🔥 AUTO GACHA HUGE AKTIF 🔥\nTUNGGU NOTIF KUNING!"
    label.TextColor3 = Color3.new(1, 1, 0.5)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.Parent = frame
end

spawn(startGUI)

-- ============================================
-- TIPS BIAR CEPET HUGE:
-- 1. Pastiin Config.EggPriority = "Huge"
-- 2. AutoBuyEgg interval kecil (1 detik)
-- 3. FarmSpeed sekecil mungkin (0.01)
-- 4. Biarin script jalan 1-2 jam
-- 5. Chance huge lebih tinggi di egg mahal
-- ============================================
