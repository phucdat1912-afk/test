-- ============================================
-- THEO DÕI SPEED + AUTO COPY CLIPBOARD
-- ============================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local buf = {}
local function log(s)
    table.insert(buf, s)
    print(s)
end

-- Hook FireServer để bắt remote
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
        local args = {...}
        log("")
        log("📤 FireServer: " .. self:GetFullName())
        for i, v in ipairs(args) do
            log("   ["..i.."] " .. typeof(v) .. " " .. tostring(v))
        end
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- Danh sách attribute cần theo dõi
local ATTRS = {
    "Pass_x3BattleSpeed",
    "InfiniteBattleActive",
    "AchievementSpeedBonus",
    "GameSpeed",
    "SpeedMultiplier",
    "Speed",
    "BattleSpeed",
    "TimeScale",
}

for _, attr in ipairs(ATTRS) do
    local cur = player:GetAttribute(attr)
    if cur ~= nil then
        log("👀 Theo dõi: " .. attr .. " = " .. tostring(cur))
        player:GetAttributeChangedSignal(attr):Connect(function()
            local newVal = player:GetAttribute(attr)
            log("")
            log("🔔 [" .. attr .. "] " .. tostring(cur) .. " → " .. tostring(newVal))
            log("   Thời gian: " .. os.date("%H:%M:%S"))
            cur = newVal
        end)
    end
end

log("")
log(">>> BẤM Speed1x → Speed2x → Speed3x <<<")
log(">>> Đợi 3 giây sau khi bấm nút cuối để copy clipboard <<<")

-- Đợi 15 giây, sau đó copy vào clipboard
task.delay(15, function()
    local full = table.concat(buf, "\n")
    
    local copied = false
    if setclipboard then
        pcall(function() setclipboard(full); copied = true end)
    end
    if not copied and toclipboard then
        pcall(function() toclipboard(full); copied = true end)
    end
    
    if copied then
        print("")
        print("✅ ĐÃ COPY KẾT QUẢ VÀO CLIPBOARD - Ctrl+V vào chat!")
    else
        print("")
        print("❌ Executor không hỗ trợ clipboard. Copy thủ công từ console.")
    end
end)
