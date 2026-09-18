local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pg = player:FindFirstChild("PlayerGui")

-- Buffer để gom output
local buf = {}
local function log(s)
    table.insert(buf, s)
    print(s)  -- Vẫn in ra console
end

log("=== SCAN START ===")

-- 1. Script trong PlayerScripts
log("\n[1] PlayerScripts:")
local ps = player:FindFirstChild("PlayerScripts")
if ps then
    for _, o in ipairs(ps:GetDescendants()) do
        if o:IsA("LocalScript") or o:IsA("Script") then
            log("  " .. o:GetFullName())
        end
    end
end

-- 2. Script trong PlayerGui
log("\n[2] PlayerGui Scripts:")
if pg then
    for _, o in ipairs(pg:GetDescendants()) do
        if o:IsA("LocalScript") or o:IsA("Script") then
            log("  " .. o:GetFullName())
        end
    end
end

-- 3. Remotes
log("\n[3] Remotes:")
local rem = RS:FindFirstChild("Remotes")
if rem then
    for _, r in ipairs(rem:GetDescendants()) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
            log("  " .. r.Name .. " | " .. r.ClassName)
        end
    end
end

-- 4. Script chứa keyword speed
log("\n[4] Script chứa 'speed'/'1x'/'2x':")
local function scan(o)
    if not (o:IsA("LocalScript") or o:IsA("Script") or o:IsA("ModuleScript")) then return end
    local ok, src = pcall(function() return o.Source end)
    if not ok or not src then return end
    local low = string.lower(src)
    for _, kw in ipairs({"speed","gamespeed","multiplier","timescale","1x","2x","3x"}) do
        if string.find(low, kw, 1, true) then
            log("  * " .. o:GetFullName() .. " (kw: " .. kw .. ")")
            return
        end
    end
end

for _, root in ipairs({ps, pg, RS, game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")}) do
    if root then
        for _, o in ipairs(root:GetDescendants()) do
            pcall(scan, o)
        end
    end
end

-- 5. Siblings InfiniteBattle
log("\n[5] InfiniteBattle children:")
if pg then
    local ok, inf = pcall(function() return pg.Frames.InfiniteBattle end)
    if ok and inf then
        for _, c in ipairs(inf:GetChildren()) do
            log("  " .. c.Name .. " | " .. c.ClassName)
        end
    end
end

-- 6. Player attributes
log("\n[6] Player Attributes:")
for n, v in pairs(player:GetAttributes()) do
    log("  " .. n .. " = " .. tostring(v))
end

log("\n=== SCAN END ===")

-- ============ AUTO COPY VÀO CLIPBOARD ============
local fullText = table.concat(buf, "\n")

local copied = false

-- Thử setclipboard (chuẩn executor)
if setclipboard then
    pcall(function()
        setclipboard(fullText)
        copied = true
    end)
end

-- Fallback: toclipboard
if not copied and toclipboard then
    pcall(function()
        toclipboard(fullText)
        copied = true
    end)
end

if copied then
    print("✅ ĐÃ COPY KẾT QUẢ VÀO CLIPBOARD - Paste (Ctrl+V) vào chat cho tôi!")
else
    print("❌ Executor không hỗ trợ clipboard. Copy thủ công từ console.")
end
