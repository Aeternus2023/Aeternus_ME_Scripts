print("*****Begin the script inside the Burthorpe mine*****")

local api = require("api")
local utils = require("EverUtils")
local player = api.GetLocalPlayerName()
local script_version = 1.0
local miningVB = 1252

-- XP stuff
local ELITE_XP_TABLE = {
    0,
    0,
    830,
    1861,
    2902,
    3980,
    5126,
    6380,
    7787,
    9400,
    11275,
    13605,
    16372,
    19656,
    23546,
    28134,
    33520,
    39809,
    47109,
    55535,
    65209,
    77190,
    90811,
    106221,
    123573,
    143025,
    164742,
    188893,
    215651,
    245196,
    277713,
    316311,
    358547,
    404634,
    454796,
    509259,
    568254,
    632019,
    700797,
    774834,
    854383,
    946227,
    1044569,
    1149696,
    1261903,
    1381488,
    1508756,
    1644015,
    1787581,
    1939773,
    2100917,
    2283490,
    2476369,
    2679917,
    2894505,
    3120508,
    3358307,
    3608290,
    3870846,
    4146374,
    4435275,
    4758122,
    5096111,
    5449685,
    5819299,
    6205407,
    6608473,
    7028964,
    7467354,
    7924122,
    8399751,
    8925664,
    9472665,
    10041285,
    10632061,
    11245538,
    11882262,
    12542789,
    13227679,
    13937496,
    14672812,
    15478994,
    16313404,
    17176661,
    18069395,
    18992239,
    19945833,
    20930821,
    21947856,
    22997593,
    24080695,
    25259906,
    26475754,
    27728955,
    29020233,
    30350318,
    31719944,
    33129852,
    34580790,
    36073511,
    37608773,
    39270442,
    40978509,
    42733789,
    44537107,
    46389292,
    48291180,
    50243611,
    52247435,
    54303504,
    56412678,
    58575824,
    60793812,
    63067521,
    65397835,
    67785643,
    70231841,
    72737330,
    75303019,
    77929820,
    80618654,
    83370445,
    86186124,
    89066630,
    92012904,
    95025896,
    98106559,
    101255855,
    104474750,
    107764216,
    111125230,
    114558777,
    118065845,
    121647430,
    125304532,
    129038159,
    132849323,
    136739041,
    140708338,
    144758242,
    148889790,
    153104021,
    157401983,
    161784728,
    166253312,
    170808801,
    175452262,
    180184770,
    185007406,
    189921255,
    194927409
}

local REGULAR_XP_TABLE = {
    0,
    83,
    174,
    276,
    388,
    512,
    650,
    801,
    969,
    1154,
    1358,
    1584,
    1833,
    2107,
    2411,
    2746,
    3115,
    3523,
    3973,
    4470,
    5018,
    5624,
    6291,
    7028,
    7842,
    8740,
    9730,
    10824,
    12031,
    13363,
    14833,
    16456,
    18247,
    20224,
    22406,
    24815,
    27473,
    30408,
    33648,
    37224,
    41171,
    45529,
    50339,
    55649,
    61512,
    67983,
    75127,
    83014,
    91721,
    101333,
    111945,
    123660,
    136594,
    150872,
    166636,
    184040,
    203254,
    224466,
    247886,
    273742,
    302288,
    333804,
    368599,
    407015,
    449428,
    496254,
    547953,
    605032,
    668051,
    737627,
    814445,
    899257,
    992895,
    1096278,
    1210421,
    1336443,
    1475581,
    1629200,
    1798808,
    1986068,
    2192818,
    2421087,
    2673114,
    2951373,
    3258594,
    3597792,
    3972294,
    4385776,
    4842295,
    5346332,
    5902831,
    6517253,
    7195629,
    7944614,
    8771558,
    9684577,
    10692629,
    11805606,
    13034431,
    14391160,
    15889109,
    17542976,
    19368992,
    21385073,
    23611006,
    26068632,
    28782069,
    31777943,
    35085654,
    38737661,
    42769801,
    47221641,
    52136869,
    57563718,
    63555443,
    70170840,
    77474828,
    85539082,
    94442737,
    104273167
}
--XP stuff end

local function getLevelForXp(xp, maxValue, elite)
    if maxValue <= 0 then
        return 1
    end
    if elite then
        for i = #ELITE_XP_TABLE, 1, -1 do
            if xp >= ELITE_XP_TABLE[i] then
                return i > 120 and 120 or i
            end
        end
    end
    local exp = xp
    for lvl = maxValue - 1, 0, -1 do
        if REGULAR_XP_TABLE[lvl + 1] <= exp then
            return lvl + 1
        end
    end
    return maxValue
end

local function getMiningXP()
    if (api.VB_FindPSett(miningVB).stateAlt > 0) then
        return api.VB_FindPSett(miningVB).stateAlt
    end
    return api.VB_FindPSett(miningVB).state
end

local function getMiningLevel()
    return getLevelForXp(getMiningXP(), 120, false)
end

local afk = os.time()
local startTime = os.time()
local startXp = getMiningXP()
local startLevel = getLevelForXp(startXp, 120, false)
local xOffset = 50
local yOffset = 20
local fieldsCount = 5

--GUI HERE
local function setupGUI()
    local fieldsCount = 1
    local y = 5
    title_box = api.CreateIG_answer()
    title_box.box_start = FFPOINT.new(xOffset, y, 0)
    title_box.box_name = "title"
    title_box.colour = ImColor.new(128, 0, 128)
    title_box.string_value = "-- Ironman Miner " .. script_version .. " --"

    fieldsCount = fieldsCount + 1
    y = y + yOffset
    statusBox = api.CreateIG_answer()
    statusBox.box_start = FFPOINT.new(0, y, 0)
    statusBox.box_name = "status"
    statusBox.colour = ImColor.new(255, 255, 255)
    statusBox.string_value = "Status: Idle"

    fieldsCount = fieldsCount + 1
    y = y + yOffset
    runTimeBox = api.CreateIG_answer()
    runTimeBox.box_start = FFPOINT.new(0, y, 0)
    runTimeBox.box_name = "runTime"
    runTimeBox.colour = ImColor.new(255, 255, 255)
    runTimeBox.string_value = "Time elapsed: 00:00:00"

    fieldsCount = fieldsCount + 1
    y = y + yOffset
    levelBox = api.CreateIG_answer()
    levelBox.box_start = FFPOINT.new(0, y, 0)
    levelBox.box_name = "gainedlvls"
    levelBox.colour = ImColor.new(255, 255, 255)
    levelBox.string_value = "Mining Level: " .. getMiningLevel() .. " (0)"

    fieldsCount = fieldsCount + 1
    y = y + yOffset
    xpBox = api.CreateIG_answer()
    xpBox.box_start = FFPOINT.new(0, y, 0)
    xpBox.box_name = "gainedxp"
    xpBox.colour = ImColor.new(255, 255, 255)
    xpBox.string_value = "Mining XP: 0.00 (0.00)"

    ----------------- background ---------------------------
    background = api.CreateIG_answer()
    background.box_name = "back"
    background.box_start = FFPOINT.new(0, 0, 0)
    background.box_size = FFPOINT.new(182 + (xOffset * 2), 5 + (fieldsCount * yOffset) + (yOffset / 2), 0)
    background.colour = ImColor.new(15, 13, 18, 255)
    background.string_value = ""
end
--GUI END

local function drawGUI()
    api.DrawSquareFilled(background)
    api.DrawTextAt(title_box)
    api.DrawTextAt(statusBox)
    api.DrawTextAt(runTimeBox)
    api.DrawTextAt(ritualBox)
    api.DrawTextAt(inputbox)
    api.DrawTextAt(completed)
    api.DrawTextAt(levelBox)
    api.DrawTextAt(xpBox)
    api.DrawTextAt(remainingBox)
    api.DrawTextAt(etaBox)
end

local function round(val, decimal)
    if (val <= 0) then
        return 0
    end
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

local function formatElapsedTime(time)
    local hours = math.floor(time / 3600)
    local minutes = math.floor((time % 3600) / 60)
    local seconds = math.floor(time % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function getFormattedNumber(value)
    local formattedValue = tostring(value)
    local formatted = string.gsub(formattedValue, "^(-?%d+)(%d%d%d)", "%1,%2")
    while true do
        local newFormatted, replacements = string.gsub(formatted, "(%d)(%d%d%d),", "%1,%2,")
        if replacements == 0 then
            break
        else
            formatted = newFormatted
        end
    end
    return formatted
end

local function updateGUI()
    local xpGained = getMiningXP() - startXp
    local elapsedTime = (os.time() - startTime)
    local xpPerHour = round((xpGained * 60) / (elapsedTime / 60))
    local currentLevel = getMiningLevel()
    local gainedLevels = currentLevel - startLevel
    runTimeBox.string_value = "Time elapsed: " .. formatElapsedTime(elapsedTime)
    levelBox.string_value = "Mining Level: " .. currentLevel .. " (" .. gainedLevels .. ")"
    xpBox.string_value = "Mining XP: " .. getFormattedNumber(xpGained) .. " (" .. getFormattedNumber(xpPerHour) .. ") "
end

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random(180, 280)
    if timeDiff > randomTime then
        api.PIdle2()
        api.DoRandomEvents()
        afk = os.time()
    end
end

local ore = {}
local copper = {113028, 113027, 113026}
local tin = {113031, 113030}
local iron = {113040, 113038, 113039}
local coal = {113103, 113102, 113101}
local mithril = {113050, 113051, 113052}
local adamantite = {113055, 113053, 113054}
local runite = {113125, 113127, 113126}
local player = api.GetLocalPlayerName()
local Cselect =
    api.ScriptDialogWindow2(
    "Mining",
    {"Copper", "Tin", "Iron", "Coal", "Mithril", "Adamantite", "Runite"},
    "Start",
    "Close"
).Name

--Assign stuff here
if "Copper" == Cselect then
    ScripCuRunning1 = "Mine copper"
    ore = copper
end
if "Tin" == Cselect then
    ScripCuRunning1 = "Mine tin"
    ore = tin
end
if "Iron" == Cselect then
    ScripCuRunning1 = "Mine iron"
    ore = iron
end
if "Coal" == Cselect then
    ScripCuRunning1 = "Mine coal"
    ore = coal
end
if "Mithril" == Cselect then
    ScripCuRunning1 = "Mine mithril"
    ore = mithril
end
if "Adamantite" == Cselect then
    ScripCuRunning1 = "Mine adamantite"
    ore = adamantite
end
if "Runite" == Cselect then
    ScripCuRunning1 = "Mine runite"
    ore = runite
end

print("STARTING TO MINE: |", ScripCuRunning1, "|")

local function isScriptActive()
    return api.Read_LoopyLoop() and api.PlayerLoggedIn()
end

-- Function to shuffle table
local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function run_to_tile(x, y, z)
    local tile = WPOINT.new(x, y, z)

    api.DoAction_Tile(tile)

    while api.Read_LoopyLoop() and api.Math_DistanceW(api.PlayerCoord(), tile) > 5 do
        api.RandomSleep2(100, 200, 200)

        idleCheck()
    end
end

local function OreBoxDeposit()
    api.DoAction_Interface(0x24, 0xaeeb, 1, 1473, 5, 0, 3808)
end

local function bankOresAndGoBack()
    api.DoAction_Object1(0x39, 0, {67002}, 50) --goin out of cave
    api.RandomSleep2(1000, 10000, 12000)

    api.DoAction_Object1(0x3f, 0, {67467}, 50) --clicked on forge to open ores interface
    api.RandomSleep2(2000, 2000, 2000)
    api.DoAction_Interface(0x24, 0xffffffff, 1, 37, 167, -1, 3808) --deposits ores
    api.RandomSleep2(2000, 2000, 2000)
    api.DoAction_Interface(0x24, 0xffffffff, 1, 37, 42, -1, 3808) --close interface
    api.RandomSleep2(2000, 2000, 2000)

    api.DoAction_Object1(0x39, 0, {66876}, 50) --goin into cave
    api.RandomSleep2(1000, 10000, 12000)
end

--main loop
api.Write_LoopyLoop(true)

setupGUI()

local depositAttempts = 0

while (api.Read_LoopyLoop()) do

    local maxDepositAttempts = 4 -- Change this to the number of attempts you want to allow

    drawGUI()

    updateGUI()

    -- Inside your loop
    if api.Invfreecount_() < math.random(3, 7) then
        OreBoxDeposit()
        depositAttempts = depositAttempts + 1
        print("Ores deposited in ore box")
        api.RandomSleep2(500, 500, 500)
    end

    if depositAttempts == maxDepositAttempts then
        print("Ore box full, going to bank")
        bankOresAndGoBack()
        depositAttempts = 0
        print("Put ores in bank, walking back")
        api.RandomSleep2(500, 500, 500)
    end

    if api.Invfreecount_() > 0 then
        print("idle check")
        updateGUI()
        if not api.IsPlayerAnimating_(player, 3) then
            api.RandomSleep2(1500, 6050, 2000)
            if not api.IsPlayerAnimating_(player, 2) then
                print("idle so start mining...")
                updateGUI()
                -- Shuffle the ore IDs
                ore = shuffle(ore)
                -- Mine the first ore in the shuffled list
                api.DoAction_Object_r(0x3a, 0, {ore[1]}, 50, FFPOINT.new(0, 0, 0), 50)
            end
        end

        print(api.LocalPlayer_HoverProgress())
        while api.LocalPlayer_HoverProgress() <= 90 do
            print("no stamina..")
            updateGUI()
            print(api.LocalPlayer_HoverProgress())
            -- Try to find and mine a sparkling rock
            local foundSparkling = api.FindHl(0x3a, 0, ore, 50, {7165, 7164})
            if foundSparkling then
                print("Sparkle found")
                updateGUI()
                api.FindHl(0x3a, 0, ore, 50, {7165, 7164})
                api.RandomSleep2(2500, 3050, 12000)
            else
                -- If no sparkling rock was found, mine the first ore in the shuffled list
                print("No Sparkle found")
                updateGUI()
                api.DoAction_Object_r(0x3a, 0, ore, 50, FFPOINT.new(0, 0, 0), 50)
                api.RandomSleep2(2500, 3050, 12000)
            end
        end
    end
    updateGUI()
    api.RandomSleep2(500, 3050, 12000)
end
