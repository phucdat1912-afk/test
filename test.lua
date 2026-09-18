--// Infiniti Tower 3x Debug - Auto Copy

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Results = {}

local function Log(...)
    local msg = table.concat({...}, " ")
    print(msg)
    table.insert(Results, msg)
end

Log("========== INFINITI TOWER 3X DEBUG ==========")

--// Scan Remotes
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local name = obj.Name:lower()

        if name:find("speed")
        or name:find("gamepass")
        or name:find("pass")
        or name:find("tower")
        or name:find("infinite")
        or name:find("infinity")
        or name:find("mult")
        or name:find("boost")
        or name:find("3x")
        or name:find("2x") then

            Log(
                "[REMOTE]",
                obj:GetFullName(),
                "|",
                obj.ClassName
            )
        end
    end
end

--// Scan PlayerGui
for _, obj in ipairs(Player.PlayerGui:GetDescendants()) do
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then

        local text = ""

        if obj:IsA("TextButton") then
            text = obj.Text or ""
        end

        local combined = (
            tostring(obj.Name) ..
            " " ..
            tostring(text)
        ):lower()

        if combined:find("3x")
        or combined:find("2x")
        or combined:find("speed")
        or combined:find("gamepass")
        or combined:find("pass")
        or combined:find("infinite")
        or combined:find("tower") then

            Log(
                "[BUTTON]",
                obj:GetFullName(),
                "| Text=" .. tostring(text)
            )
        end
    end
end

--// Scan ReplicatedStorage values
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("StringValue")
    or obj:IsA("NumberValue")
    or obj:IsA("IntValue")
    or obj:IsA("BoolValue") then

        local name = obj.Name:lower()

        if name:find("speed")
        or name:find("mult")
        or name:find("tower")
        or name:find("3x")
        or name:find("2x")
        or name:find("gamepass")
        or name:find("pass") then

            Log(
                "[VALUE]",
                obj:GetFullName(),
                "| Value=" .. tostring(obj.Value)
            )
        end
    end
end

Log("========== END ==========")

--// Auto copy
local Output = table.concat(Results, "\n")

if setclipboard then
    setclipboard(Output)
    print("✅ LOG ĐÃ ĐƯỢC COPY VÀO CLIPBOARD")
elseif toclipboard then
    toclipboard(Output)
    print("✅ LOG ĐÃ ĐƯỢC COPY VÀO CLIPBOARD")
else
    warn("❌ Executor không hỗ trợ setclipboard/toclipboard")
end
