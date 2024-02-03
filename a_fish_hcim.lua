print("Script started, Let's Fish!")
local API = require("api")
local UTILS = require("utils")
local player = API.GetLocalPlayerName()

------GUI------
local skill = "FISHING"
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
    IGP.colour = ImColor.new(10, 150, 200)
    IGP.string_value = "FISHING"

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

local NPCS = {
    CRAYFISH = 14907,
    TROUT = 328
}

-- START at the spot you want to fish at, bot will handle the rest

--Set for type of fish
local crayfish = false -- lv1
local trout_salmon = true -- lvl 30

local function Fish()
    if crayfish == true then
        if not API.IsPlayerAnimating_(player, 40) then
            print("Fishing crayfish")
            API.DoAction_NPC(0x3c,API.OFF_ACT_InteractNPC_route,{ NPCS.CRAYFISH },50)
        end
    end

    if trout_salmon == true then
        if not API.IsPlayerAnimating_(player, 40) then
            print("Fishing trout/salmon")
            API.DoAction_NPC(0x3c,API.OFF_ACT_InteractNPC_route,{ NPCS.TROUT },50)
        end
    end

end

local function Bank()
    if crayfish == true then
        run_to_tile(2893,3496,0)
        run_to_tile(2892,3529,0)
        API.DoAction_Object1(0x5,API.OFF_ACT_GeneralObject_route1,{ 25688 },50) -- open bank burthorpe
        UTILS.randomSleep(2400)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,API.OFF_ACT_GeneralInterface_route) -- deposit all
        UTILS.randomSleep(2400)
        API.DoAction_Interface(0x24,0xffffffff,1,517,306,-1,API.OFF_ACT_GeneralInterface_route) -- close bank (x) button
        UTILS.randomSleep(2400)
        run_to_tile(2893,3495,0)
        run_to_tile(2898,3473,0)
        print("Back to fish some more")
        UTILS.randomSleep(1200)
    end

    if trout_salmon == true then
        run_to_tile(3094,3460,0)
        run_to_tile(3089,3490,0)
        API.DoAction_Object1(0x5,API.OFF_ACT_GeneralObject_route1,{ 42217 },50) -- open bank edgeville
        UTILS.randomSleep(2400)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,API.OFF_ACT_GeneralInterface_route) -- deposit all
        UTILS.randomSleep(2400)
        API.DoAction_Interface(0x24,0xffffffff,1,517,119,1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(2400)
        API.DoAction_Interface(0x24,0xffffffff,1,517,306,-1,API.OFF_ACT_GeneralInterface_route) -- close bank (x) button
        UTILS.randomSleep(2400)
        run_to_tile(3096,3454,0)
        run_to_tile(3107,3435,0)
        print("Back to fish some more")
        UTILS.randomSleep(1200)
    end

end

setupGUI()

while API.Read_LoopyLoop() do
    if API.Invfreecount_() <= math.random(1, 3) then
        print("Inventory full, banking")
        Bank()
    end
    Fish()
    printProgressReport()
    UTILS.randomSleep(2400)
end
