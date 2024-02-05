---@diagnostic disable: missing-parameter
print("*****Begin the script at Burthope furnace*****")

local API = require("api")
local utils = require("EverUtils")
local player = API.GetLocalPlayerName()

local afk = os.time()

local makeBase = true
local upgradeOne = false
local upgradeTwo = false
local upgradeThree = false
local upgradeFour = false

local ITEMS = {
    BASE = 45217,
    PLUS_ONE = 45222,
    PLUS_TWO = 45227,
    PLUS_THREE = 45232,
    PLUS_FOUR = 45237,
    UNFINISHED = 47068
}

------GUI------
local skill = "SMITHING"
local startXp = API.GetSkillXP(skill)
local startTime, afk = os.time(), os.time()

local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

local function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function calcProgressPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then
        return 100
    end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end

local function printProgressReport(final)
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp)
    local xpPH = round((diffXp * 60) / elapsedMinutes)
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    IGP.radius = calcProgressPercentage(skill, API.GetSkillXP(skill)) / 100
    IGP.string_value =
        time ..
        " | " ..
            string.lower(skill):gsub("^%l", string.upper) ..
                ": " .. currentLevel .. " | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp)
end

local function setupGUI()
    IGP = API.CreateIG_answer()
    IGP.box_start = FFPOINT.new(5, 5, 0)
    IGP.box_name = "PROGRESSBAR"
    IGP.colour = ImColor.new(75, 0, 130)
    IGP.string_value = "SMITHING"

    API.DrawProgressBar(IGP)
end
------End of GUI------

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random(180, 280)
    if timeDiff > randomTime then
        API.DoRandomEvents()
        API.PIdle2()
        afk = os.time()
    end
end

local function run_to_tile(x, y, z)
    local tile = WPOINT.new(x, y, z)

    API.DoAction_Tile(tile)

    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > 5 do
        API.RandomSleep2(100, 200, 200)

        idleCheck()
    end
end

local function reheat()
    idleCheck()
    API.RandomSleep2(750, 300, 300)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113259}, 50) --forge
    API.RandomSleep2(6000, 300, 300)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113258}, 50) -- anvil
    API.RandomSleep2(20000, 1000, 1500)
end

local function bankItems()
    run_to_tile(2888, 3535, 0)
    API.DoAction_Object1(0x5, 80, {25688}, 50)
    API.RandomSleep2(3000, 4000, 5000)
    if API.BankOpen2() then
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 39, -1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1000, 2000, 2000)
        API.BankClose()
    end
    run_to_tile(2887, 3506, 0)
    print("Back at starting spot")
    API.RandomSleep2(1000, 2000, 2000)
end

local function SelectPlusFour()
    if API.InvItemFound1(ITEMS.PLUS_FOUR) then
        print("Going to bank method")
        upgradeFour = false
        makeBase = true
        bankItems()
    end
    print("SelectPlusFour")
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113259}, 50) -- open forge
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0xffffffff, 0xb0a1, 1, 37, 103, 5, API.OFF_ACT_GeneralInterface_route) -- select platebody
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 155, -1, API.OFF_ACT_GeneralInterface_route) -- select +4
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 163, -1, API.OFF_ACT_GeneralInterface_route) -- select begin project
    API.RandomSleep2(6000, 400, 500)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113258}, 50) -- anvil
    API.RandomSleep2(20000, 1000, 1500)
end

local function SelectPlusThree()
    if API.InvItemFound1(ITEMS.PLUS_THREE) then
        print("Going to SelectPlusThree method")
        upgradeThree = false
        upgradeFour = true
        SelectPlusFour()
    end
    print("SelectPlusThree")
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113259}, 50) -- open forge
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0xffffffff, 0xb0a1, 1, 37, 103, 5, API.OFF_ACT_GeneralInterface_route) -- select platebody
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 157, -1, API.OFF_ACT_GeneralInterface_route) -- select +3
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 163, -1, API.OFF_ACT_GeneralInterface_route) -- select begin project
    API.RandomSleep2(6000, 400, 500)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113258}, 50) -- anvil
    API.RandomSleep2(20000, 1000, 1500)
end

local function SelectPlusTwo()
    if API.InvItemFound1(ITEMS.PLUS_TWO) then
        print("Going to SelectPlusThree method")
        upgradeTwo = false
        upgradeThree = true
        SelectPlusThree()
    end
    print("SelectPlusTwo")
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113259}, 50) -- open forge
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0xffffffff, 0xb0a1, 1, 37, 103, 5, API.OFF_ACT_GeneralInterface_route) -- select platebody
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 159, -1, API.OFF_ACT_GeneralInterface_route) -- select +2
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 163, -1, API.OFF_ACT_GeneralInterface_route) -- select begin project
    API.RandomSleep2(6000, 400, 500)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113258}, 50) -- anvil
    API.RandomSleep2(20000, 1000, 1500)
end

local function SelectPlusOne()
    if API.InvItemFound1(ITEMS.PLUS_ONE) then
        print("Going to SelectPlusTwo method")
        upgradeOne = false
        upgradeTwo = true
        SelectPlusTwo()
    end
    print("SelectPlusOne")
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113259}, 50) -- open forge
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0xffffffff, 0xb0a1, 1, 37, 103, 5, API.OFF_ACT_GeneralInterface_route) -- select platebody
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 161, -1, API.OFF_ACT_GeneralInterface_route) -- select +1
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 163, -1, API.OFF_ACT_GeneralInterface_route) -- select begin project
    API.RandomSleep2(6000, 400, 500)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113258}, 50) -- anvil
    API.RandomSleep2(20000, 1000, 1500)
end

local function SelectBase()
    if API.InvItemFound1(ITEMS.BASE) then
        print("Going to SelectPlusOne method")
        makeBase = false
        upgradeOne = true
        SelectPlusOne()
    end
    print("SelectBase")
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113259}, 50) -- open forge
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0xffffffff, 0xb0a1, 1, 37, 103, 5, API.OFF_ACT_GeneralInterface_route) -- select platebody
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 149, -1, API.OFF_ACT_GeneralInterface_route) -- select base
    API.RandomSleep2(1800, 400, 500)
    API.DoAction_Interface(0x24, 0xffffffff, 1, 37, 163, -1, API.OFF_ACT_GeneralInterface_route) -- select begin project
    API.RandomSleep2(6000, 400, 500)
    API.DoAction_Object1(0x3f, API.OFF_ACT_GeneralObject_route0, {113258}, 50) -- anvil
    API.RandomSleep2(20000, 1000, 1500)
end

setupGUI()

-- Main Loop
API.Write_LoopyLoop(true)

while (API.Read_LoopyLoop()) do
    if API.LocalPlayer_HoverProgress() <= 230 and API.InvItemFound1(ITEMS.UNFINISHED) then
        print("reheating...")
        reheat()
    end

    if makeBase == true and not API.IsPlayerAnimating_(player, 2) then
        SelectBase()
    end

    if upgradeOne == true and not API.IsPlayerAnimating_(player, 2) then
        SelectPlusOne()
    end

    if upgradeTwo == true and not API.IsPlayerAnimating_(player, 2) then
        SelectPlusTwo()
    end

    if upgradeThree == true and not API.IsPlayerAnimating_(player, 2) then
        SelectPlusThree()
    end

    if upgradeFour == true and not API.IsPlayerAnimating_(player, 2) then
        SelectPlusFour()
    end

    if API.InvItemFound1(ITEMS.PLUS_FOUR) == true then
        print("Banking cause finished +4 item")
        bankItems()
        API.RandomSleep2(500, 500, 500)
    end

    printProgressReport()
    print("print report, sleep")
    API.RandomSleep2(600, 600, 600)
end
