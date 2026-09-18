-- ============================================
-- TEST SPEED MONITOR (KHÔNG HOOK) - DELTA SAFE
-- AUTO COPY CLIPBOARD SAU 25 GIÂY
-- ============================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local buf = {}
local function log(s)
    table.insert(buf, s)
    print(s)
end

-- Danh sách attribute cần theo dõi
local WATCH = {
    "InfiniteTimePlayed",
    "InfiniteWaveCleared",
    "InfiniteBattleActive",
    "Pass_x3BattleSpeed",
    "AchievementSpeedBonus",
}

log("=== TEST SPEED MONITOR (DELTA SAFE) ===")
log("Thời gian: " .. os.date("%H:%M:%S"))
log("")

-- Giá trị ban đầu
for _, attr in ipairs(WATCH) do
    local v = player:GetAttribute(attr)
    log("Ban đầu [" .. attr .. "] = " .. tostring(v))
end

log("")
log(">>> Đợi 5s ở 1x → bấm 2x → đợi 5s → bấm 3x → đợi 5s <<<")
log("")

-- Theo dõi thay đổi attribute
for _, attr in ipairs(WATCH) do
    if player:GetAttribute(attr) ~= nil then
        local last = player:GetAttribute(attr)
        player:GetAttributeChangedSignal(attr):Connect(function()
            local new = player:GetAttribute(attr)
            log("🔔 [" .. attr .. "] " .. tostring(last) .. " → " .. tostring(new))
            last = new
        end)
    end
end

-- Đo tốc độ tăng InfiniteTimePlayed mỗi giây
log("")
log("=== ĐO TỐC ĐỘ InfiniteTimePlayed ===")
log("Format: [giây] TimePlayed | tăng/giây")
log("")

task.spawn(function()
    local lastTime = player:GetAttribute("InfiniteTimePlayed") or 0
    local lastTick = tick()
    local sample = 0
    
    while sample < 22 do
        task.wait(1)
        sample = sample + 1
        
        local curTime = player:GetAttribute("InfiniteTimePlayed") or 0
        local curTick = tick()
        
        local deltaTime = curTime - lastTime
        local deltaTick = curTick - lastTick
        local rate = deltaTime / deltaTick
        
        log(string.format("[%02ds] TimePlayed = %.2f | Tăng %.3f/giây", 
            sample, curTime, rate))
        
        lastTime = curTime
        lastTick = curTick
    end
end)

-- Sau 24 giây, copy clipboard
task.delay(24, function()
    log("")
    log("=== KẾT THÚC ===")
    
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
        print("✅ ĐÃ COPY - Ctrl+V paste cho tôi!")
    else
        print("")
        print("❌ Không copy được, chụp màn hình console.")
    end
end)
