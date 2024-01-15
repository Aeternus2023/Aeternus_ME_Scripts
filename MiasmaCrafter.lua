local API = require("api")
local UTILS = require("utils")
local startTime = os.time()
local startXp = API.GetSkillXP("RUNECRAFTING")
local runes = 0

-- 8939 Teleporting from location
-- 8941 Arriving from Teleport

ID = {
    IMPURE_ESSENCE = 55667,
    SMALL_POUCH = 5509,
    MEDIUM_POUCH = 5510,
    LARGE_POUCH = 5512,
    GIANT_POUCH = 5514,
    BANK_CHEST = 127271,
    DARK_PORTAL = 127376,
    MIASMA_ALTAR = 127383
}

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
    local runesPH = round((runes * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    IG.string_value = "Runecrafting XP : " .. formatNumberWithCommas(diffXp) .. " (" .. formatNumberWithCommas(xpPH) ..
                          ")"
    IG2.string_value =
        "  Miasma runes : " .. formatNumberWithCommas(runes) .. " (" .. formatNumberWithCommas(runesPH) .. ")"
    IG4.string_value = time
    if final then
        print(os.date("%H:%M:%S") .. " Script Finished\nRuntime : " .. time .. "\nRunecrafting XP : " ..
                  formatNumberWithCommas(diffXp) .. " \nMiasma runes : " .. formatNumberWithCommas(runes))
    end
end

local function scanForInterface(interfaceComps)
    return #(API.ScanForInterfaceTest2Get(true, interfaceComps)) > 0
end

local function doBank()
    print("Banking")
    API.DoAction_Object1(0x2e, 80, {ID.BANK_CHEST}, 50)
    API.WaitUntilMovingEnds()
    if API.BankOpen2() then -- Multiple ways of checking banking interface the way you want
        print("Preset 1 loaded")
        API.DoAction_Interface(0x24, 0xffffffff, 1, 517, 119, 1, 5392)
        API.RandomSleep2(100, 200, 300)
    end
end

local function setupGUI()
    IG = API.CreateIG_answer()
    IG.box_start = FFPOINT.new(15, 40, 0)
    IG.box_name = "RUNECRAFTING"
    IG.colour = ImColor.new(255, 255, 255);
    IG.string_value = "Runecrafting XP : 0 (0)"

    IG2 = API.CreateIG_answer()
    IG2.box_start = FFPOINT.new(15, 55, 0)
    IG2.box_name = "RUNES"
    IG2.colour = ImColor.new(255, 255, 255);
    IG2.string_value = "  Miasma runes : 0 (0)"

    IG3 = API.CreateIG_answer()
    IG3.box_start = FFPOINT.new(40, 5, 0)
    IG3.box_name = "TITLE"
    IG3.colour = ImColor.new(0, 255, 0);
    IG3.string_value = "- Miasma Crafter 1.0-"

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

local function drawGUI()
    API.DrawSquareFilled(IG_Back)
    API.DrawTextAt(IG)
    API.DrawTextAt(IG2)
    API.DrawTextAt(IG3)
    API.DrawTextAt(IG4)
end

setupGUI()

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do
    drawGUI()
    printProgressReport()
    API.DoRandomEvents()

    -- API.KeyboardPress(0x55, 50, 100) -- u key
    print("Going to smithy")
    API.DoAction_Interface(0x2e, 0xd97c, 1, 1430, 233, -1, 5392)
    API.RandomSleep2(5000, 1000, 2000)

    print("Openeing bank")
    API.DoAction_Object1(0x2e, 80, {ID.BANK_CHEST}, 50)
    API.WaitUntilMovingEnds()
    API.RandomSleep2(3000, 1000, 1000)

    print("Loading preset 1")
    API.RandomSleep2(1000, 1000, 1000)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 517, 119, 1, 5392)
    API.RandomSleep2(1000, 1000, 1000)

    print("Filling pouches")
    API.DoAction_Interface(0x2e, 0x1585, 1, 1430, 181, -1, 5392)
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0x2e, 0x1586, 1, 1430, 194, -1, 5392)
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0x2e, 0x1588, 1, 1430, 207, -1, 5392)
    API.RandomSleep2(500, 200, 300)
    API.DoAction_Interface(0x2e, 0x158a, 1, 1430, 220, -1, 5392)
    API.MouseRightClick(500, 50)
    API.RandomSleep2(500, 200, 300)

    print("Openeing bank again")
    API.DoAction_Object1(0x2e, 80, {ID.BANK_CHEST}, 50)
    API.WaitUntilMovingEnds()
    API.RandomSleep2(3000, 1000, 1000)

    print("Preset 1 again")
    API.RandomSleep2(1000, 1000, 1000)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 517, 119, 1, 5392)
    API.RandomSleep2(1000, 1000, 1000)

    print("Going to portal")
    API.DoAction_Object1(0x39, 0, {ID.DARK_PORTAL}, 50)
    API.WaitUntilMovingEnds()
    API.RandomSleep2(25000, 1000, 2500) -- waits

    print("Making runes")
    API.RandomSleep2(2000, 500, 500)
    API.DoAction_Object1(0x29, 0, {ID.MIASMA_ALTAR}, 50) -- makes runes
    API.WaitUntilMovingEnds()
    API.RandomSleep2(7000, 500, 1000) -- waits 

    print("Runes made, repeating...")

    printProgressReport()
    API.PIdle2()
    API.RandomSleep2(1000, 2000, 2000)
end
