---@diagnostic disable: missing-parameter
print("Let's Fish The Frenzy!")
print("Make sure to being at the Fishing Frenzy spot,")
print("located in the Deep Sea Fishing Hub")

local API = require("api")
local UTILS = require("utils")
local player = API.GetLocalPlayerName()

local FISH = {
    
}

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

local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function Bank()
    API.DoAction_Object1(0x5,API.OFF_ACT_GeneralObject_route1,{ 110860 },50)
    UTILS.randomSleep(10000)
    if API.BankOpen2() then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(1800)
    end
end

--------MAIN LOOP--------

setupGUI()

while API.Read_LoopyLoop() do

    printProgressReport()

    idleCheck()

    if API.Invfreecount_() < math.random(3, 7) then
        Bank()
    end

    if not API.IsPlayerAnimating_(player, 2) then
        print("Not animating -- selecting next fish")
        --shuffle(FISH)
        --API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {FISH[1]}, 50)
        API.DoAction_NPC_str(0x3c, API.OFF_ACT_InteractNPC_route, {"Blue blubber jellyfish"}, 50)
    end

    UTILS.randomSleep((1800 + API.Math_RandomNumber(80)))

end
