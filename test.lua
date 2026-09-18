-- ================================================
-- CÁCH 3: LIỆT KÊ SCRIPT + REMOTE TRONG GAME
-- ================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("")
print("================================================")
print("=== BẮT ĐẦU SCAN ===")
print("================================================")

-- ================================================
-- 1. SCRIPT TRONG PLAYER SCRIPTS
-- ================================================
print("")
print(">>> [1] Scripts trong PlayerScripts:")
local playerScripts = player:FindFirstChild("PlayerScripts")
if playerScripts then
    for _, obj in ipairs(playerScripts:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            print("   ├─", obj:GetFullName())
            pcall(function()
                if obj.Source and #obj.Source > 0 then
                    print("   │   Source (200 chars):")
                    print("   │   " .. string.sub(obj.Source, 1, 200))
                end
            end)
        end
    end
else
    print("   (không tìm thấy PlayerScripts)")
end

-- ================================================
-- 2. SCRIPT TRONG PLAYER GUI
-- ================================================
print("")
print(">>> [2] Scripts trong PlayerGui:")
local pg = player:FindFirstChild("PlayerGui")
if pg then
    local count = 0
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            count = count + 1
            print("   ├─", obj:GetFullName())
            pcall(function()
                if obj.Source and #obj.Source > 0 then
                    print("   │   Source (200 chars):")
                    print("   │   " .. string.sub(obj.Source, 1, 200))
                end
            end)
        end
    end
    if count == 0 then
        print("   (không có script nào)")
    end
else
    print("   (không tìm thấy PlayerGui)")
end

-- ================================================
-- 3. REMOTE EVENTS / FUNCTIONS
-- ================================================
print("")
print(">>> [3] Remotes trong ReplicatedStorage:")
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if remotes then
    for _, r in ipairs(remotes:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") or r:IsA("BindableEvent") then
            print("   ├─", r.Name, "|", r.ClassName, "|", r:GetFullName())
        end
    end
else
    print("   (không tìm thấy folder Remotes)")
    -- Scan toàn bộ ReplicatedStorage
    print("   Quét toàn bộ ReplicatedStorage:")
    for _, r in ipairs(ReplicatedStorage:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
            print("   ├─", r.Name, "|", r.ClassName, "|", r:GetFullName())
        end
    end
end

-- ================================================
-- 4. TÌM SCRIPT CÓ CHỨA TỪ KHÓA "Speed" / "1x" / "2x"
-- ================================================
print("")
print(">>> [4] Tìm script chứa từ khóa 'Speed'/'1x'/'2x'/'3x':")

local function scanSource(obj)
    if not (obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript")) then
        return
    end
    
    local ok, src = pcall(function() return obj.Source end)
    if not ok or not src then return end
    
    local lower = string.lower(src)
    local found = false
    local matched = {}
    
    for _, keyword in ipairs({"speed", "1x", "2x", "3x", "gamespeed", "multiplier", "timescale"}) do
        if string.find(lower, keyword, 1, true) then
            found = true
            table.insert(matched, keyword)
        end
    end
    
    if found then
        print("   ⭐", obj:GetFullName())
        print("      Keywords:", table.concat(matched, ", "))
    end
end

-- Scan trong tất cả nơi có thể
local roots = {
    playerScripts,
    pg,
    ReplicatedStorage,
    game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts"),
    game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts"),
}

for _, root in ipairs(roots) do
    if root then
        for _, obj in ipairs(root:GetDescendants()) do
            pcall(scanSource, obj)
        end
    end
end

-- ================================================
-- 5. HIỂN THỊ GameSpeed UI VÀ SIBLINGS
-- ================================================
print("")
print(">>> [5] Siblings của GameSpeed (InfiniteBattle):")
if pg then
    local ok, infinite = pcall(function()
        return pg.Frames.InfiniteBattle
    end)
    if ok and infinite then
        for _, child in ipairs(infinite:GetChildren()) do
            print("   ├─", child.Name, "|", child.ClassName)
        end
    else
        print("   (không tìm thấy InfiniteBattle)")
    end
end

-- ================================================
-- 6. TÌM MODULESCRIPT CÓ THỂ CHỨA LOGIC
-- ================================================
print("")
print(">>> [6] ModuleScript trong ReplicatedStorage:")
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        print("   ├─", obj:GetFullName())
    end
end

-- ================================================
-- 7. PLAYER ATTRIBUTES HIỆN TẠI
-- ================================================
print("")
print(">>> [7] Player Attributes hiện tại:")
local hasAttr = false
for name, val in pairs(player:GetAttributes()) do
    hasAttr = true
    print("   ├─", name, "=", tostring(val), "(" .. typeof(val) .. ")")
end
if not hasAttr then
    print("   (không có attribute nào)")
end

-- ================================================
-- 8. TÌM BINDABLE FUNCTION CÓ THỂ CHỨA SPEED LOGIC
-- ================================================
print("")
print(">>> [8] BindableEvent/Function trong PlayerGui:")
if pg then
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            print("   ├─", obj:GetFullName())
        end
    end
end

print("")
print("================================================")
print("=== KẾT THÚC SCAN ===")
print("================================================")
