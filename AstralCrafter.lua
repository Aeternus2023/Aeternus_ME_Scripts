local API = require("api")
local startTime = os.time()
local startXp = API.GetSkillXP("RUNECRAFTING")
local strings, fail = 0, 0
local bobduration = 48 * 60
-- 26095 titan summon buff

ID = {
    PURE_ESSENCE = 7936,
    SORCERY_POT = 49063,
    AB_TITAN = 12796,
    SMALL_POUCH = 5509,
    MEDIUM_POUCH = 5510,
    LARGE_POUCH = 5512,
    GIANT_POUCH = 5514
}

-- Rounds a number to the nearest integer or to a specified number of decimal places.
local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- Format a number with commas as thousands separator
local function formatNumberWithCommas(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

-- Format script elapsed time to [hh:mm:ss]
local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function printProgressReport(final)
    local currentXp = API.GetSkillXP("RUNECRAFTING")
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local stringPH = round((strings * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    IG.string_value = "RC XP : " .. formatNumberWithCommas(diffXp) .. " (" .. formatNumberWithCommas(xpPH) .. ")"
    IG2.string_value = "  Runes : " .. formatNumberWithCommas(strings) .. " (" .. formatNumberWithCommas(stringPH) ..
                           ")"
    IG4.string_value = time
    if final then
        print(os.date("%H:%M:%S") .. " Script Finished\nRuntime : " .. time .. "\nRC XP : " ..
                  formatNumberWithCommas(diffXp) .. " \nRunes : " .. formatNumberWithCommas(strings))
    end
end

local function scanForInterface(interfaceComps)
    return #(API.ScanForInterfaceTest2Get(true, interfaceComps)) > 0
end

local function setupGUI()
    IG = API.CreateIG_answer()
    IG.box_start = FFPOINT.new(15, 40, 0)
    IG.box_name = "RUNECRAFTING"
    IG.colour = ImColor.new(255, 255, 255);
    IG.string_value = "RC XP : 0 (0)"

    IG2 = API.CreateIG_answer()
    IG2.box_start = FFPOINT.new(15, 55, 0)
    IG2.box_name = "RUNES"
    IG2.colour = ImColor.new(255, 255, 255);
    IG2.string_value = "Runes : 0 (0)"

    IG3 = API.CreateIG_answer()
    IG3.box_start = FFPOINT.new(40, 5, 0)
    IG3.box_name = "TITLE"
    IG3.colour = ImColor.new(0, 255, 0);
    IG3.string_value = "AstralCrafter v1.0"

    IG4 = API.CreateIG_answer()
    IG4.box_start = FFPOINT.new(70, 21, 0)
    IG4.box_name = "TIME"
    IG4.colour = ImColor.new(255, 255, 255);
    IG4.string_value = "[00:00:00]"

    IG_Back = API.CreateIG_answer();
    IG_Back.box_name = "back";
    IG_Back.box_start = FFPOINT.new(0, 0, 0)
    IG_Back.box_size = FFPOINT.new(220, 80, 0)
    IG_Back.colour = ImColor.new(15, 13, 18, 255)
    IG_Back.string_value = ""
end

function drawGUI()
    API.DrawSquareFilled(IG_Back)
    API.DrawTextAt(IG)
    API.DrawTextAt(IG2)
    API.DrawTextAt(IG3)
    API.DrawTextAt(IG4)
end

local function writeBuff()
    buffs = API.Buffbar_GetAllIDs()
    for k, v in pairs(buffs) do
        print(v.id, v.found, v.text, v.conv_text)
    end
end

local function grabPreset()
    print("Grabbing preset 2")
    API.KeyboardPress2(85, 20, 60)
    API.RandomSleep2(3500, 500, 500)
    API.DoAction_Object1(0x2e, 80, {127271}, 50)
    API.RandomSleep2(2000, 2000, 2000)
    API.WaitUntilMovingEnds()
    if API.BankOpen2() then
        strings = strings + API.InvItemcountStack_String("Astral rune")
        API.KeyboardPress2(113, 20, 60)
    end
end

local function renewFamiliar()
    print("Renewing familiar")
    API.DoAction_Interface(0x2e, 0xffffffff, 1, 1670, 123, -1, 5392) -- wars retreat
    API.RandomSleep2(3500, 500, 500)
    API.DoAction_Object1(0x3d, 0, {114748}, 50) -- obelisk renew
    API.RandomSleep2(4000, 500, 500)
    API.KeyboardPress2(85, 20, 60) -- goto um smithy
    API.RandomSleep2(3500, 500, 500)
    API.DoAction_Object1(0x2e, 80, {127271}, 50) -- open bank
    API.RandomSleep2(2000, 2000, 2000)
    API.WaitUntilMovingEnds()
    if API.BankOpen2() then
        API.KeyboardPress2(114, 200, 600) -- preset 3
        API.RandomSleep2(1000, 1000, 1000)
        API.DoAction_Interface(0x24, 0x31fc, 1, 1473, 5, 4, 5392) -- renew familiar
        API.RandomSleep2(1000, 1000, 1000)
    end
end

local function fillPouches()
    print("Filling pouches")
    API.DoAction_Interface(0x2e, 0x1585, 1, 1430, 181, -1, 5392) -- p1
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0x2e, 0x1586, 1, 1430, 194, -1, 5392) -- p2
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 662, 106, -1, 5392) -- take bob essence
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0x2e, 0x1588, 1, 1430, 207, -1, 5392) -- p3
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0x2e, 0x158a, 1, 1430, 220, -1, 5392) -- p4
    API.MouseRightClick(500, 50)
    API.RandomSleep2(500, 200, 300)
end

setupGUI()

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do

    drawGUI()

    API.DoRandomEvents()
    API.PIdle2()

    if API.CheckFamiliar() == false then
        renewFamiliar()
    end

    grabPreset()

    API.DoRandomEvents()

    fillPouches()

    API.DoRandomEvents()

    API.DoAction_Object1(0x2e, 80, {127271}, 50)
    API.RandomSleep2(2000, 2000, 2000)
    API.WaitUntilMovingEnds()
    if API.BankOpen2() then
        API.KeyboardPress2(113, 20, 60)
    end
    API.DoRandomEvents()

    API.RandomSleep2(500, 500, 500)
    API.KeyboardPress2(65, 500, 500)
    API.RandomSleep2(3000, 1000, 1000)
    API.DoRandomEvents()

    API.DoAction_Tile(WPOINT.new((2132 + API.Math_RandomNumber(2)), (3873 + API.Math_RandomNumber(2)), 0))
    API.RandomSleep2(4000, 1000, 1000)
    API.KeyboardPress2(78, 1000, 1000) -- surge
    API.DoRandomEvents()
    API.DoAction_Tile(WPOINT.new(2132, 3873, 0))
    API.RandomSleep2(4000, 1000, 1000)
    API.DoRandomEvents()
    API.KeyboardPress2(78, 500, 500) -- surge
    API.DoAction_Object1(0x42, 0, {17010}, 50)
    API.DoRandomEvents()
    API.RandomSleep2(7000, 1000, 1000)
    API.DoAction_Interface(0x30, 0xbfa9, 1, 1473, 5, 4, 5392)
    API.DoRandomEvents()
    API.DoAction_Object1(0x42, 0, {17010}, 50)
    API.RandomSleep2(5000, 1000, 1000)
    API.DoRandomEvents()

    printProgressReport()

end
