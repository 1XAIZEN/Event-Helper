script_name("MPadmins")
script_version("3.8")
script_author("Mikki_Tyler")

local se       = require("samp.events")
local bit      = require("bit")
local vkeys    = require("vkeys")
local imgui    = require("mimgui")
local ffi      = require("ffi")
local encoding = require("encoding")
local dlstatus = require("moonloader").download_status
local inicfg   = require("inicfg")
local effil = require("effil")
encoding.default = "CP1251"
local u8       = encoding.UTF8

-- ==================== НАСТРОЙКИ АВТООБНОВЛЕНИЯ ====================
local UPDATE_CFG = {
    CURRENT_NUM   = 3.8,
    CURRENT_STR   = "v3.8",
    -- Прямая ссылка на файл update.ini
    INFO_URL      = "https://raw.githubusercontent.com/1XAIZEN/Event-Helper/main/update.ini",
    -- Прямая ссылка на скачивание самого скрипта
    SCRIPT_URL    = "https://raw.githubusercontent.com/1XAIZEN/Event-Helper/refs/heads/main/MPadmins.lua",
    TEMP_FILE     = getWorkingDirectory() .. "\\update_check.tmp"
}

local UpdateUI = {
    show        = imgui.new.bool(false),
    downloading = false,
    new_vers    = "",
    changelog   = {}
}

-- ==================== КОНФИГУРАЦИЯ ====================
local CFG = {
    PREFIX         = "{FFFFFF}[{FF3333}MP-Manager{FFFFFF}] ",
    CONFIG_PATH    = getWorkingDirectory() .. "/config/MPadmins.json",
    PRESETS_PATH   = getWorkingDirectory() .. "/config/MPadmins_presets.json",
    SPEED_TH_SQ    = 0.000225,
    DEADZONE       = 10,
    RED_DELAY      = 2.0,
    PENALTY_CD     = 5.0,
    SPAWN_CD       = 2.0,
    DIST           = 150.0,
    DEFAULT_Z      = 12.65,
    SHOW_MP_ZONE   = true,
    DM_DEATH_DELAY = 5.0,
    DM_CMD_DELAY   = 1.0,
    SECTOR_SPAWN_CD= 1.0,
    SECTOR_MIN_Z   = 200.0,
    MASK_COLOR     = 23486046
}

local C = {
    GREEN     = "{00FF00}", 
    RED       = "{FF0000}", 
    WARN      = "{FF8C00}",
    ARGB_G    = 0xFF00FF00, 
    ARGB_R    = 0xFFFF0000, 
    ARGB_IN   = 0x88888888, 
    ARGB_HUD  = 0xAA000000,
    ARGB_MP   = 0xFF00FFFF,
    ARGB_SEC  = 0xFFFF8800,
    ARGB_ZONE = 0xFF00E5FF,
    TXT_FREE  = 0xFF44FF44, 
    TXT_BUSY  = 0xFFFF4444, 
    TXT_INACT = 0xFFAAAAAA, 
    WHITE     = 0xFFFFFFFF, 
    YELLOW    = 0xFFFFFF00
}

local DIALOGS = {
    EVENT_LIST         = 25493,
    EVENT_EDIT         = 25494,
    EVENT_RENAME       = 25495,
    EVENT_RULES_LINES  = 25496,
    EVENT_RULES_INPUT  = 25497,
    SPAWN_MENU         = 25498,
    SPAWN_COUNT_INPUT  = 25499,
    SPAWN_TYPE_SELECT  = 25500,
    SPAWN_SLOTS_SELECT = 25501,
    EVENT_BROADCAST    = 25502,
    EVENT_LIMIT        = 25503,
    EVENT_TP_TIME      = 25504,
    EVENT_PASSWORD     = 25505,
    EVENT_HEALTH       = 25506,
    EVENT_ARMOUR       = 25507,
    EVENT_SKIN         = 25508,
    WEAPON_MENU        = 25509,
    WEAPON_TYPE_LIST   = 25510,
    WEAPON_AMMO_INPUT  = 25511
}

local WEAPON_NAMES = {
    u8"Не выдавать оружие",
    u8"(ID: 1) Brass Knuckles", u8"(ID: 2) Golf Club", u8"(ID: 3) Night Stick", u8"(ID: 4) Knife",
    u8"(ID: 5) Baseball Bat", u8"(ID: 6) Shovel", u8"(ID: 7) Pool Cue", u8"(ID: 8) Katana",
    u8"(ID: 9) Chainsaw", u8"(ID: 10) Purple Dildo", u8"(ID: 11) Big White Vibrator",
    u8"(ID: 12) Medium White Vibrator", u8"(ID: 13) Small White Vibrator", u8"(ID: 14) Flowers",
    u8"(ID: 15) Cane", u8"(ID: 16) Grenade", u8"(ID: 17) Teargas", u8"(ID: 18) Molotov",
    u8"(ID: 19) Pistols", u8"(ID: 20) Pistols (Silenced)", u8"(ID: 21) Desert Eagle",
    u8"(ID: 22) Shotgun", u8"(ID: 23) Sawnoff Shotgun", u8"(ID: 24) Combat Shotgun",
    u8"(ID: 25) Micro Uzi (Mac 10)", u8"(ID: 26) MP5", u8"(ID: 27) AK47", u8"(ID: 28) M4",
    u8"(ID: 29) Tec9", u8"(ID: 30) Country Rifle", u8"(ID: 31) Sniper Rifle",
    u8"(ID: 32) Spray Can", u8"(ID: 33) Fire Extinguisher"
}

local SPAWN_TYPES = {
    u8"1. Спавн всех на одну позицию",
    u8"2. Спавн на рандомные позиции",
    u8"3. Спавн на позиции по порядку"
}

local vehicle_names = {
    [400] = "Landstalker", [401] = "Bravura", [402] = "Buffalo", [403] = "Linerunner", [404] = "Perennial", 
    [405] = "Sentinel", [406] = "Dumper", [407] = "Firetruck", [408] = "Trashmaster", [409] = "Stretch", 
    [410] = "Manana", [411] = "Infernus", [412] = "Voodoo", [413] = "Pony", [414] = "Mule", 
    [415] = "Cheetah", [416] = "Ambulance", [418] = "Moonbeam", [419] = "Esperanto", [420] = "Taxi", 
    [421] = "Washington", [422] = "Bobcat", [423] = "Mr Whoopee", [424] = "BF Injection", [426] = "Premier", 
    [427] = "Enforcer", [428] = "Securicar", [429] = "Banshee", [431] = "Bus", [433] = "Barracks", 
    [434] = "Hotknife", [436] = "Previon", [437] = "Coach", [438] = "Cabbie", [439] = "Stallion", 
    [440] = "Rumpo", [442] = "Romero", [443] = "Packer", [444] = "Monster", [445] = "Admiral", 
    [448] = "Pizza Boy", [451] = "Turismo", [455] = "Flatbed", [456] = "Yankee", [457] = "Caddy", 
    [458] = "Solair", [459] = "Berkley's RC Van", [461] = "PCJ-600", [462] = "Faggio", [463] = "Freeway", 
    [466] = "Glendale", [467] = "Oceanic", [468] = "Sanchez", [469] = "Sparrow", [470] = "Patriot", 
    [471] = "Quadbike", [474] = "Hermes", [475] = "Sabre", [477] = "ZR-350", [478] = "Walton", 
    [479] = "Regina", [480] = "Comet", [482] = "Burrito", [483] = "Camper", [484] = "Marquis", 
    [485] = "Baggage", [486] = "Dozer", [489] = "Rancher", [490] = "FBI Rancher", [491] = "Virgo", 
    [494] = "Hotring Racer", [495] = "Sandking", [496] = "Blista Compact", [498] = "Boxville", [499] = "Benson", 
    [500] = "Mesa", [502] = "Hotring Racer 2", [503] = "Hotring Racer 3", [504] = "Bloodring Banger", [505] = "Rancher (Lure)", 
    [506] = "Super GT", [507] = "Elegant", [508] = "Journey", [514] = "Tanker", [515] = "Roadtrain", 
    [516] = "Nebula", [517] = "Majestic", [518] = "Buccaneer", [521] = "FCR-900", [522] = "NRG-500", 
    [523] = "HPV-1000", [524] = "Cement Truck", [525] = "Tow Truck", [526] = "Fortune", [527] = "Cadrona", 
    [528] = "FBI Truck", [529] = "Willard", [530] = "Forklift", [531] = "Tractor", [532] = "Combine Harvester", 
    [533] = "Feltzer", [534] = "Remington", [535] = "Slamvan", [536] = "Blade", [540] = "Vincent", 
    [541] = "Bullet", [542] = "Clover", [543] = "Sadler", [544] = "Firetruck LA", [545] = "Hustler", 
    [546] = "Intruder", [547] = "Primo", [549] = "Tampa", [550] = "Sunrise", [551] = "Merit", 
    [552] = "Utility Van", [554] = "Yosemite", [555] = "Windsor", [556] = "Monster A", [557] = "Monster B", 
    [558] = "Uranus", [559] = "Jester", [560] = "Sultan", [562] = "Elegy", [565] = "Flash", 
    [566] = "Tahoma", [567] = "Savanna", [571] = "Kart", [572] = "Mower", [573] = "Dune", 
    [574] = "Sweeper", [575] = "Broadway", [576] = "Tornado", [578] = "DFT-30", [579] = "Huntley", 
    [580] = "Stafford", [581] = "BF-400", [582] = "News Van", [583] = "Tug", [585] = "Emperor", 
    [586] = "Wayfarer", [587] = "Euros", [588] = "Hotdog", [589] = "Club", [596] = "Police Car (LSPD)", 
    [597] = "Police Car (SFPD)", [598] = "Police Car (LVPD)", [599] = "Police Ranger", [600] = "Picador", 
    [601] = "S.W.A.T.", [602] = "Alpha", [603] = "Phoenix", [604] = "Glendale Shit", [605] = "Sadler Shit", [609] = "Boxville Black"
}

local cars_list = {}
for id in pairs(vehicle_names) do table.insert(cars_list, id) end
table.sort(cars_list)

local DEFAULT_MP_RULES = {
    sectors = {
        "В чат будет писаться, какой сектор безопасен",
        "Ваша задача успеть встать в безопасный сектор",
        "Безопасный сектор находится за красно-белой линией",
        "Кто не успевает - проигрывает",
        "Желаем всем удачи"
    },
    rlgl = {
        "На зеленый свет разрешено свободно двигаться вперед",
        "На красный свет необходимо полностью замереть",
        "Любое движение или шаг на красный свет — спавн",
        "Побеждает тот, кто первым доберется до финиша",
        "Желаем всем удачи"
    },
    chairs = {
        "По команде СТАРТ — все катаются по кругу",
        "Как только прозвучит команда СТОП — занимайте свободные места",
        "Кто не успел занять стул / место — выбывает",
        "Запрещено занимать свободно место раньше времени",
        "Любой способ жульничества = СПАВН",
        "Там где стоят отбойники - места нет",
        "Желаем всем удачи"
    },
    dm = {
        "Ваша задача — сделать как можно больше убийств за 10 минут",
        "После смерти вы автоматически возрождаетесь через 5 секунд",
        "Победителем становится игрок, набравший больше всех фрагов",
        "Желаем всем удачи"
    },
    derby = {
        "Ваша задача — таранить машины противников и выживать",
        "Если ваш автомобиль сильно сломается или загорится — вы выбываете",
        "Выходить из автомобиля строго запрещено (авто-спавн)",
        "Побеждает последний оставшийся участник на арене",
        "Желаем всем удачи"
    },
    potato = {
        "Один из игроков получает горячую картошку",
        "У вас есть ровно 10 секунд, чтобы подбежать и передать ее другому",
        "Тот, у кого картошка взорвется по истечении времени — выбывает",
        "Побеждает последний выживший участник",
        "Желаем всем удачи"
    }
}

local MP_RULES = {}

local RAW_MP_ZONE = {
    { x = 1420.0, y = -2305.0 },
    { x = 1421.9, y = -2357.8 },
    { x = 1375.9, y = -2358.8 },
    { x = 1374.9, y = -2305.0 }
}

local Z_DATA = {
    {-2344.97, 1409.77, -2350.72, 1409.76, -2350.68, 1412.76, -2344.98, 1412.76},
    {-2350.62, 1409.52, -2344.88, 1409.52, -2344.88, 1406.32, -2350.60, 1406.35},
    {-2350.59, 1406.14, -2344.91, 1406.16, -2344.88, 1403.15, -2350.60, 1403.14},
    {-2350.58, 1402.97, -2344.91, 1402.97, -2344.91, 1399.79, -2350.58, 1399.76},
    {-2350.58, 1399.58, -2350.57, 1396.60, -2344.86, 1396.60, -2344.90, 1399.58},
    {-2350.59, 1396.43, -2344.87, 1396.41, -2344.89, 1393.22, -2350.57, 1393.20},
    {-2350.58, 1393.05, -2344.88, 1393.02, -2344.86, 1390.04, -2350.57, 1390.06},
    {-2350.55, 1389.86, -2344.88, 1389.86, -2344.89, 1386.69, -2350.57, 1386.68},
    {-2350.55, 1386.47, -2344.85, 1386.45, -2344.87, 1383.48, -2350.61, 1383.47},
    {-2333.51, 1412.65, -2327.87, 1412.66, -2327.85, 1409.67, -2333.54, 1409.72},
    {-2333.58, 1409.52, -2327.89, 1409.55, -2327.90, 1406.36, -2333.59, 1406.34},
    {-2333.62, 1406.15, -2327.90, 1406.15, -2327.91, 1403.16, -2333.60, 1403.16},
    {-2333.59, 1402.97, -2327.89, 1402.95, -2327.89, 1399.77, -2333.60, 1399.79},
    {-2333.60, 1399.59, -2327.90, 1399.58, -2327.90, 1396.61, -2333.58, 1396.61},
    {-2333.60, 1396.39, -2327.88, 1396.41, -2327.91, 1393.22, -2333.61, 1393.23},
    {-2333.61, 1393.01, -2327.87, 1393.02, -2327.88, 1390.05, -2333.58, 1390.07},
    {-2333.60, 1389.86, -2327.88, 1389.88, -2327.89, 1386.66, -2333.59, 1386.70},
    {-2333.60, 1386.46, -2327.86, 1386.44, -2327.85, 1383.48, -2333.61, 1383.52},
    {-2316.50, 1412.70, -2310.77, 1412.68, -2310.79, 1409.74, -2316.50, 1409.74},
    {-2316.49, 1409.53, -2310.78, 1409.52, -2310.78, 1406.37, -2316.47, 1406.37},
    {-2316.51, 1406.13, -2310.79, 1406.13, -2310.80, 1403.17, -2316.51, 1403.20},
    {-2316.49, 1402.96, -2310.79, 1402.97, -2310.79, 1399.79, -2316.48, 1399.80},
    {-2316.50, 1399.62, -2310.79, 1399.58, -2310.78, 1396.64, -2316.50, 1396.61},
    {-2316.50, 1396.44, -2310.79, 1396.41, -2310.78, 1393.23, -2316.50, 1393.21},
    {-2316.49, 1393.04, -2310.78, 1393.03, -2310.77, 1390.07, -2316.49, 1390.06},
    {-2316.51, 1389.88, -2310.78, 1389.88, -2310.77, 1386.69, -2316.51, 1386.72},
    {-2316.50, 1386.47, -2316.50, 1383.50, -2310.79, 1383.51, -2310.80, 1386.49}
}

local SECTOR_NAMES = { "A", "B", "C", "D" }

local DEFAULT_MP_NAMES = {
    "Король УЗИ", "Горячая картошка", "Сектор газа", "Прятки на корабле", "Стульчики", "Дерби", "Фабрика фрагов"
}

local DEFAULT_PRIZES = {
    "5.000.000$", "10.000.000$", "15.000.000$", "20.000.000$", "25.000.000$", 
    "30.000.000$", "35.000.000$", "40.000.000$", "45.000.000$", "50.000.000$"
}

-- ==================== СОСТОЯНИЕ (STATE) ====================
local Core = {
    running            = false,
    fetching_list      = false,
    fetching_settings  = false,
    toggling_event     = false,
    target_id          = 0,
    active_dialog_id   = -1,
    active_dialog_text = "",
    events_list        = {}
}

local HUD = {
    active         = false,
    mode           = "none",
    total_sec      = 0,
    end_time       = 0,
    progress       = 0.0,
    is_closing     = false,
    is_running_now = false,
    error_list     = {}
}

local st = {
    enabled          = false,
    isGreen          = true,
    redTime          = 0,
    curInt           = 0,
    myNick           = "",
    myId             = -1,
    movers           = {},
    queue            = {},
    inQueue          = {},
    chairs           = false,
    showInact        = true,
    selected         = {},
    active           = {},
    occupied         = {},
    stulActive       = false,
    potatoActive     = false,
    potatoHolder     = nil,
    lastHolder       = nil,
    antiBackCooldown = 0,
    potatoTimer      = 0,
    blacklist        = {},
    dmActive         = false,
    dmTimerEnd       = 0,
    dmPlayers        = {},
    dmRespawnQueue   = {},
    dmInRespawn      = {},
    sectors          = {},
    sectorSetupMode  = false,
    setupSectorIdx   = 1,
    setupPoints      = {},
    sectorRoundRun   = false,
    cursorActive     = false,
    aimPos           = nil,
    stZone           = nil,
    stZoneSetupMode  = false,
    stZonePoints     = {},
    derbyActive      = false,
    derbyHpThreshold = 400,
    derbyPedDelay    = 2.0,
    derbyCarDelay    = 4.3,
    derbyCheckInt    = true,
    derbyIntId       = 15,
    derbyAutoGiveVeh = false,
    derbyGiveMode    = 0,
    derbySelectedCar = 0,
    derbyPlayersWithVeh = {},
    vodaActive       = false,
    vodaReason       = "Вы были заспавнены, так как упали в воду",
    autospheal       = false,
    autosparm        = false,
    antimask         = false,
    autospgun        = false,
    radiusCmd        = 50,
    giveGunId        = 24,
    giveGunAmmo      = 100,
    giveSkinId       = 1,
    aoMpList         = {},
    aoSelectedMp     = 4,
    aoPrizeList      = {},
    aoSelectedPrize  = 9,
    aokd             = 1200
}

local UI = {
    show = imgui.new.bool(false),
    show_monitor = imgui.new.bool(false),
    currentSidebar = 3,
    current_mp = nil,
    selected_mp_idx = imgui.new.int(0),
    selected_preset_idx = imgui.new.int(0)
}

local Opt = {
    take_guns   = imgui.new.bool(false),
    re_tp       = imgui.new.bool(false),
    launcher    = imgui.new.bool(false),
    pvp_dmg     = imgui.new.bool(false),
    accessories = imgui.new.bool(false),
    guards      = imgui.new.bool(false),
    lic_car     = imgui.new.bool(false),
    lic_moto    = imgui.new.bool(false),
    lic_boat    = imgui.new.bool(false),
    lic_fly     = imgui.new.bool(false),
    collision   = imgui.new.bool(false)
}

local TH = {
    stul = nil, rveh = nil, derby = nil, dmTimer = nil,
    voda = nil, sector = nil, rules = nil, ao = nil
}

local B = {
    zones        = imgui.new.char[128]("1-5"),
    bl_id        = imgui.new.char[32](""),
    rveh_radius  = imgui.new.char[16]("50"),
    rveh_model   = imgui.new.char[16]("400"),
    derby_hp     = imgui.new.int(st.derbyHpThreshold),
    derby_ped_t  = imgui.new.float(st.derbyPedDelay),
    derby_car_t  = imgui.new.float(st.derbyCarDelay),
    car_search   = imgui.new.char[64](""),
    voda_reason  = imgui.new.char[256](u8(st.vodaReason)),
    radius_cmd   = imgui.new.int(st.radiusCmd),
    give_gun     = imgui.new.int(st.giveGunId),
    give_ammo    = imgui.new.int(st.giveGunAmmo),
    give_skin    = imgui.new.int(st.giveSkinId),
    aokd         = imgui.new.int(st.aokd),
    ao_custom_mp = imgui.new.char[128](""),
    ao_custom_prize = imgui.new.char[128](""),
    winner_input_id = imgui.new.char[16](""),
    new_preset_name = imgui.new.char[64](""),

    ev_new_title   = imgui.new.char[128](u8"Стульчики"),
    ev_prize       = imgui.new.char[64](u8"50.000.000$"),
    ev_broadcast   = imgui.new.char[256](u8'[Event] Сейчас пройдет МП "Стульчики". Приз: 50.000.000$ - /gotp'),
    ev_limit       = imgui.new.int(100),
    ev_tp_time     = imgui.new.int(60),
    ev_password    = imgui.new.char[16]("0"),
    ev_health      = imgui.new.int(100),
    ev_armour      = imgui.new.int(0),
    ev_skin        = imgui.new.int(0),
    ev_weapon_sel  = imgui.new.int(0),
    ev_ammo_count  = imgui.new.int(500),
    ev_rule1       = imgui.new.char[256](""),
    ev_rule2       = imgui.new.char[256](""),
    ev_rule3       = imgui.new.char[256](""),
    ev_sp_count    = imgui.new.int(1),
    ev_sp_type     = imgui.new.int(0),
    ev_sp_slot     = imgui.new.int(0)
}

local RuleEditBuffers = {}
local pointMarker = nil
local pZones, mpZoneData, fontText, fontHUD, fontSector, screenW, screenH = {}, nil, nil, nil, nil, 0, 0
local NEAR_PLANE_EPSILON = 1e-3
local event_logs = {}
local players_monitor_list = {}
local Presets = {}
local PresetsList = {}

-- ==================== БАЗОВЫЕ ФУНКЦИИ ====================
local function sendMsg(color, text)
    sampAddChatMessage(CFG.PREFIX .. color .. text, -1)
end

local function addEventLog(text)
    table.insert(event_logs, 1, os.date("[%H:%M:%S] ") .. text)
    if #event_logs > 40 then table.remove(event_logs, 41) end
end

local function cleanColorCodes(text)
    return text and text:gsub("{%x%x%x%x%x%x}", "") or ""
end

-- ==================== ЛОГИКА АВТООБНОВЛЕНИЯ ====================

local function asyncHttpGet(url, resolve, reject)
    local runner = effil.thread(function(u)
        local req = require("requests")
        local ok, resp = pcall(req.get, u, { timeout = 8 })
        if ok and resp and resp.status_code == 200 then
            return true, resp.text
        else
            return false, ok and (resp and resp.status_code or "err") or tostring(resp)
        end
    end)(url)

    lua_thread.create(function()
        while true do
            local status, err = runner:status()
            if not err then
                if status == "completed" then
                    local ok, result = runner:get()
                    if ok then
                        if resolve then resolve(result) end
                    else
                        if reject then reject(result) end
                    end
                    return
                elseif status == "canceled" then
                    if reject then reject("canceled") end
                    return
                end
            else
                if reject then reject(err) end
                return
            end
            wait(50)
        end
    end)
end

local function parseIniText(text)
    local t = {}
    for line in text:gmatch("[^\r\n]+") do
        local key, val = line:match("^([%w_]+)%s*=%s*(.+)$")
        if key and val then
            key = key:gsub("^%s*(.-)%s*$", "%1")
            val = val:gsub("^%s*(.-)%s*$", "%1")
            t[key] = val
        end
    end
    return t
end

local function checkScriptUpdate(is_manual)
    if is_manual then
        sendMsg(C.WARN, "Проверка обновлений на сервере...")
    end

    asyncHttpGet(UPDATE_CFG.INFO_URL, function(response_text)
        local data = parseIniText(response_text)
        local server_vers = tonumber(data["vers"])

        if is_manual then
            sendMsg(C.WHITE, string.format("Текущая версия: {00FF00}%s{FFFFFF} | На сервере: {FFFF00}%s", UPDATE_CFG.CURRENT_STR, data["vers_text"] or tostring(server_vers or "не указана")))
        end

        if server_vers and server_vers > UPDATE_CFG.CURRENT_NUM then
            UpdateUI.new_vers  = data["vers_text"] or tostring(server_vers)
            UpdateUI.changelog = {}

            for i = 1, 10 do
                local line = data["change" .. i]
                if line and #line > 0 then
                    -- Сохраняем строку как есть (она уже приходит в UTF-8 с GitHub)
                    table.insert(UpdateUI.changelog, line)
                end
            end

            UpdateUI.show[0] = true
            sendMsg(C.GREEN, "Найдена новая версия! Открыто окно установки.")
        else
            if is_manual then
                sendMsg(C.GREEN, "У вас установлена самая последняя версия скрипта!")
            end
        end
    end, function(err)
        if is_manual then
            sendMsg(C.RED, "Не удалось проверить обновления (ошибка соединения)!")
        end
    end)
end

local function startScriptDownload()
    if UpdateUI.downloading then return end
    UpdateUI.downloading = true
    sendMsg(C.WARN, "Загрузка новой версии скрипта...")

    asyncHttpGet(UPDATE_CFG.SCRIPT_URL, function(new_code)
        local f = io.open(thisScript().path, "wb")
        if f then
            f:write(new_code)
            f:close()
            UpdateUI.downloading = false
            UpdateUI.show[0] = false
            sendMsg(C.GREEN, "Скрипт успешно обновлён! Перезагрузка...")
            lua_thread.create(function()
                wait(600)
                thisScript():reload()
            end)
        else
            UpdateUI.downloading = false
            sendMsg(C.RED, "Ошибка: не удалось перезаписать файл скрипта (нет прав)!")
        end
    end, function(err)
        UpdateUI.downloading = false
        sendMsg(C.RED, "Ошибка при скачивании файла скрипта с GitHub!")
    end)
end

-- ==================== ОКНО ОБНОВЛЕНИЯ (MIMGUI) ====================
imgui.OnFrame(function() return UpdateUI.show[0] end, function()
    local resW, resH = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(480, 290), imgui.Cond.Always)
    imgui.SetNextWindowPos(imgui.ImVec2((resW - 480) / 2, (resH - 290) / 2), imgui.Cond.Always)
    
    local flags = imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize
    if imgui.Begin(u8"Обновление MPadmins##UpdateWindow", UpdateUI.show, flags) then
        imgui.TextColored(imgui.ImVec4(0.2, 1.0, 0.4, 1.0), string.format(u8"Доступно новое обновление! %s", UpdateUI.new_vers))
        imgui.Separator()
        imgui.Spacing()

        imgui.TextColored(imgui.ImVec4(0.9, 0.7, 0.2, 1.0), u8"Список изменений / улучшений:")
        imgui.Spacing()

        imgui.BeginChild("##ChangelogScroll", imgui.ImVec2(-1, 130), true)  
        if #UpdateUI.changelog == 0 then
            imgui.BulletText(u8"Общие улучшения стабильности и исправление ошибок.")
        else
            for _, line in ipairs(UpdateUI.changelog) do
                -- ПИШЕМ БЕЗ u8(), так как строка уже в UTF-8!
                imgui.BulletText(line)
            end
        end
        imgui.EndChild()

        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        if UpdateUI.downloading then
            imgui.TextColored(imgui.ImVec4(0.3, 0.8, 1.0, 1.0), u8"Загрузка обновления, подождите...")
        else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.18, 0.65, 0.28, 0.90))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.80, 0.35, 1.0))
            if imgui.Button(u8"Установить", imgui.ImVec2(150, 30)) then
                startScriptDownload()
            end
            imgui.PopStyleColor(2)

            imgui.SameLine()
            if imgui.Button(u8"Позже", imgui.ImVec2(100, 30)) then
                UpdateUI.show[0] = false
            end
        end

        imgui.End()
    end
end)

local function RadioButton(label, active)
    if imgui.RadioButtonBool then
        return imgui.RadioButtonBool(label, active)
    elseif imgui.RadioButton then
        return imgui.RadioButton(label, active)
    end
    return false
end

function HUD.show(mode, duration, errors)
    HUD.mode       = mode
    HUD.end_time   = os.clock() + (duration or 3.5)
    HUD.progress   = 0.0
    HUD.is_closing = false
    HUD.error_list = errors or {}
    HUD.active     = true
end

local function initRuleBuffers()
    RuleEditBuffers = {}
    for mpKey, lines in pairs(MP_RULES) do
        RuleEditBuffers[mpKey] = {}
        for idx, text in ipairs(lines) do
            RuleEditBuffers[mpKey][idx] = imgui.new.char[256](u8(text))
        end
    end
end

-- ==================== СОХРАНЕНИЕ / ЗАГРУЗКА КОНФИГА ====================
local function saveConfig()
    local cfgData = {
        derbyHpThreshold = st.derbyHpThreshold,
        derbyPedDelay    = st.derbyPedDelay,
        derbyCarDelay    = st.derbyCarDelay,
        derbyCheckInt    = st.derbyCheckInt,
        derbyAutoGiveVeh = st.derbyAutoGiveVeh,
        derbyGiveMode    = st.derbyGiveMode,
        derbySelectedCar = st.derbySelectedCar,
        vodaReason       = st.vodaReason,
        showMpZone       = CFG.SHOW_MP_ZONE,
        showInact        = st.showInact,
        rvehRadius       = ffi.string(B.rveh_radius),
        rvehModel        = ffi.string(B.rveh_model),
        blacklist        = st.blacklist,
        sectors          = st.sectors,
        stZone           = st.stZone,
        radiusCmd        = st.radiusCmd,
        aokd             = st.aokd,
        aoMpList         = st.aoMpList,
        aoPrizeList      = st.aoPrizeList,
        aoSelectedMp     = st.aoSelectedMp,
        aoSelectedPrize  = st.aoSelectedPrize,
        autospheal       = st.autospheal,
        autosparm        = st.autosparm,
        antimask         = st.antimask,
        autospgun        = st.autospgun,
        mpRules          = MP_RULES
    }
    local f = io.open(CFG.CONFIG_PATH, "w")
    if f then
        f:write(encodeJson(cfgData))
        f:close()
    end
end

local function loadConfig()
    MP_RULES = {}
    for k, v in pairs(DEFAULT_MP_RULES) do
        MP_RULES[k] = {}
        for _, str in ipairs(v) do table.insert(MP_RULES[k], str) end
    end

    st.aoMpList = {}
    for _, v in ipairs(DEFAULT_MP_NAMES) do table.insert(st.aoMpList, v) end
    st.aoPrizeList = {}
    for _, v in ipairs(DEFAULT_PRIZES) do table.insert(st.aoPrizeList, v) end

    local f = io.open(CFG.CONFIG_PATH, "r")
    if not f then 
        initRuleBuffers()
        return 
    end
    local content = f:read("*a")
    f:close()
    if not content or content == "" then 
        initRuleBuffers()
        return 
    end
    local success, cfgData = pcall(decodeJson, content)
    if not success or type(cfgData) ~= "table" then 
        initRuleBuffers()
        return 
    end

    if cfgData.derbyHpThreshold then st.derbyHpThreshold = cfgData.derbyHpThreshold; B.derby_hp[0] = st.derbyHpThreshold end
    if cfgData.derbyPedDelay    then st.derbyPedDelay = cfgData.derbyPedDelay; B.derby_ped_t[0] = st.derbyPedDelay end
    if cfgData.derbyCarDelay    then st.derbyCarDelay = cfgData.derbyCarDelay; B.derby_car_t[0] = st.derbyCarDelay end
    if cfgData.derbyCheckInt ~= nil then st.derbyCheckInt = cfgData.derbyCheckInt end
    if cfgData.derbyAutoGiveVeh ~= nil then st.derbyAutoGiveVeh = cfgData.derbyAutoGiveVeh end
    if cfgData.derbyGiveMode ~= nil then st.derbyGiveMode = cfgData.derbyGiveMode end
    if cfgData.derbySelectedCar ~= nil then st.derbySelectedCar = cfgData.derbySelectedCar end
    if cfgData.vodaReason       then st.vodaReason = cfgData.vodaReason; imgui.StrCopy(B.voda_reason, u8(st.vodaReason)) end
    if cfgData.showMpZone ~= nil then CFG.SHOW_MP_ZONE = cfgData.showMpZone end
    if cfgData.showInact ~= nil  then st.showInact = cfgData.showInact end
    if cfgData.rvehRadius       then imgui.StrCopy(B.rveh_radius, cfgData.rvehRadius) end
    if cfgData.rvehModel        then imgui.StrCopy(B.rveh_model, cfgData.rvehModel) end
    if type(cfgData.blacklist) == "table" then st.blacklist = cfgData.blacklist end
    if type(cfgData.sectors) == "table"   then st.sectors = cfgData.sectors end
    if type(cfgData.stZone) == "table"    then st.stZone = cfgData.stZone end
    if cfgData.radiusCmd ~= nil   then st.radiusCmd = cfgData.radiusCmd; B.radius_cmd[0] = st.radiusCmd end
    if cfgData.aokd ~= nil        then st.aokd = cfgData.aokd; B.aokd[0] = st.aokd end
    if type(cfgData.aoMpList) == "table" and #cfgData.aoMpList > 0 then st.aoMpList = cfgData.aoMpList end
    if type(cfgData.aoPrizeList) == "table" and #cfgData.aoPrizeList > 0 then st.aoPrizeList = cfgData.aoPrizeList end
    if cfgData.aoSelectedMp ~= nil then st.aoSelectedMp = cfgData.aoSelectedMp end
    if cfgData.aoSelectedPrize ~= nil then st.aoSelectedPrize = cfgData.aoSelectedPrize end
    if cfgData.autospheal ~= nil  then st.autospheal = cfgData.autospheal end
    if cfgData.autosparm ~= nil   then st.autosparm = cfgData.autosparm end
    if cfgData.antimask ~= nil    then st.antimask = cfgData.antimask end
    if cfgData.autospgun ~= nil   then st.autospgun = cfgData.autospgun end

    if type(cfgData.mpRules) == "table" then
        for k, lines in pairs(cfgData.mpRules) do
            if type(lines) == "table" and #lines > 0 then
                MP_RULES[k] = {}
                for _, str in ipairs(lines) do
                    table.insert(MP_RULES[k], str)
                end
            end
        end
    end

    initRuleBuffers()
end

-- ==================== СИСТЕМА ПРЕСЕТОВ ====================
local DEFAULT_PRESETS = {
    ["Стульчики"] = {
        title = "Стульчики", prize = "50.000.000$",
        broadcast = '[Event] Сейчас пройдет МП "Стульчики". Приз: 50.000.000$ - /gotp',
        limit = 100, tp_time = 60, password = "0", health = 100, armour = 0, skin = 0,
        weapon_sel = 0, ammo_count = 0,
        rule1 = "Бегайте по кругу, пока играет музыка",
        rule2 = "По команде СТОП займите стул",
        rule3 = "Кто без стула - выбывает",
        sp_count = 1, sp_type = 0, sp_slot = 0,
        toggles = { take_guns = true, re_tp = false, launcher = false, pvp_dmg = true, accessories = false, guards = true, lic_car = false, lic_moto = false, lic_boat = false, lic_fly = false, collision = true }
    },
    ["Дерби"] = {
        title = "Дерби", prize = "50.000.000$",
        broadcast = '[Event] Сейчас пройдет МП "Дерби". Приз: 50.000.000$ - /gotp',
        limit = 50, tp_time = 60, password = "0", health = 100, armour = 0, skin = 0,
        weapon_sel = 0, ammo_count = 0,
        rule1 = "Тараньте машины других участников",
        rule2 = "Выход из авто или мало HP - спавн",
        rule3 = "Побеждает последний выживший",
        sp_count = 1, sp_type = 0, sp_slot = 0,
        toggles = { take_guns = true, re_tp = false, launcher = false, pvp_dmg = true, accessories = false, guards = true, lic_car = true, lic_moto = false, lic_boat = false, lic_fly = false, collision = false }
    }
}

local function refreshPresetsList()
    PresetsList = {}
    for name in pairs(Presets) do table.insert(PresetsList, name) end
    table.sort(PresetsList)
end

local function savePresetsToFile()
    local f = io.open(CFG.PRESETS_PATH, "w")
    if f then
        f:write(encodeJson(Presets))
        f:close()
    end
end

local function loadPresetsFromFile()
    Presets = {}
    local f = io.open(CFG.PRESETS_PATH, "r")
    if f then
        local content = f:read("*a")
        f:close()
        if content and content ~= "" then
            local success, data = pcall(decodeJson, content)
            if success and type(data) == "table" then Presets = data end
        end
    end
    local count = 0
    for _ in pairs(Presets) do count = count + 1 end
    if count == 0 then
        Presets = DEFAULT_PRESETS
        savePresetsToFile()
    end
    refreshPresetsList()
end

local function applyPreset(name)
    local p = Presets[name]
    if not p then return end
    imgui.StrCopy(B.ev_new_title, u8(p.title or ""))
    imgui.StrCopy(B.ev_prize, u8(p.prize or "50.000.000$"))
    imgui.StrCopy(B.ev_broadcast, u8(p.broadcast or ""))
    B.ev_limit[0]      = p.limit or 100
    B.ev_tp_time[0]    = p.tp_time or 60
    imgui.StrCopy(B.ev_password, tostring(p.password or "0"))
    B.ev_health[0]     = p.health or 100
    B.ev_armour[0]     = p.armour or 0
    B.ev_skin[0]       = p.skin or 0
    B.ev_weapon_sel[0] = p.weapon_sel or 0
    B.ev_ammo_count[0] = p.ammo_count or 500
    imgui.StrCopy(B.ev_rule1, u8(p.rule1 or ""))
    imgui.StrCopy(B.ev_rule2, u8(p.rule2 or ""))
    imgui.StrCopy(B.ev_rule3, u8(p.rule3 or ""))
    B.ev_sp_count[0]   = p.sp_count or 1
    B.ev_sp_type[0]    = p.sp_type or 0
    B.ev_sp_slot[0]    = p.sp_slot or 0

    if p.toggles then
        Opt.take_guns[0]   = p.toggles.take_guns or false
        Opt.re_tp[0]       = p.toggles.re_tp or false
        Opt.launcher[0]    = p.toggles.launcher or false
        Opt.pvp_dmg[0]     = p.toggles.pvp_dmg or false
        Opt.accessories[0] = p.toggles.accessories or false
        Opt.guards[0]      = p.toggles.guards or false
        Opt.lic_car[0]     = p.toggles.lic_car or false
        Opt.lic_moto[0]    = p.toggles.lic_moto or false
        Opt.lic_boat[0]    = p.toggles.lic_boat or false
        Opt.lic_fly[0]     = p.toggles.lic_fly or false
        Opt.collision[0]   = p.toggles.collision or false
    end
end

local function saveCurrentAsPreset(name)
    name = name:gsub("^%s*(.-)%s*$", "%1")
    if #name == 0 then return false end
    Presets[name] = {
        title       = u8:decode(ffi.string(B.ev_new_title)),
        prize       = u8:decode(ffi.string(B.ev_prize)),
        broadcast   = u8:decode(ffi.string(B.ev_broadcast)),
        limit       = B.ev_limit[0],
        tp_time     = B.ev_tp_time[0],
        password    = ffi.string(B.ev_password),
        health      = B.ev_health[0],
        armour      = B.ev_armour[0],
        skin        = B.ev_skin[0],
        weapon_sel  = B.ev_weapon_sel[0],
        ammo_count  = B.ev_ammo_count[0],
        rule1       = u8:decode(ffi.string(B.ev_rule1)),
        rule2       = u8:decode(ffi.string(B.ev_rule2)),
        rule3       = u8:decode(ffi.string(B.ev_rule3)),
        sp_count    = B.ev_sp_count[0],
        sp_type     = B.ev_sp_type[0],
        sp_slot     = B.ev_sp_slot[0],
        toggles     = {
            take_guns   = Opt.take_guns[0],
            re_tp       = Opt.re_tp[0],
            launcher    = Opt.launcher[0],
            pvp_dmg     = Opt.pvp_dmg[0],
            accessories = Opt.accessories[0],
            guards      = Opt.guards[0],
            lic_car     = Opt.lic_car[0],
            lic_moto    = Opt.lic_moto[0],
            lic_boat    = Opt.lic_boat[0],
            lic_fly     = Opt.lic_fly[0],
            collision   = Opt.collision[0]
        }
    }
    savePresetsToFile()
    refreshPresetsList()
    return true
end

local function getEffectiveEventName()
    local title = u8:decode(ffi.string(B.ev_new_title)):gsub("^%s*(.-)%s*$", "%1")
    if #title > 0 then return title end
    if #Core.events_list > 0 and Core.events_list[UI.selected_mp_idx[0] + 1] then
        local t = Core.events_list[UI.selected_mp_idx[0] + 1].title
        if #t > 0 then return t end
    end
    local custom = u8:decode(ffi.string(B.ao_custom_mp)):gsub("^%s*(.-)%s*$", "%1")
    if #custom > 0 then return custom end
    return st.aoMpList[st.aoSelectedMp + 1] or "Мероприятие"
end

local function getEffectivePrize()
    local p = u8:decode(ffi.string(B.ev_prize)):gsub("^%s*(.-)%s*$", "%1")
    if #p > 0 then return p end
    local custom = u8:decode(ffi.string(B.ao_custom_prize)):gsub("^%s*(.-)%s*$", "%1")
    if #custom > 0 then return custom end
    return st.aoPrizeList[st.aoSelectedPrize + 1] or "50.000.000$"
end

local function generateBroadcastTemplate()
    local name = getEffectiveEventName()
    local prize = getEffectivePrize()
    return string.format('[Event] Сейчас пройдет МП "%s". Приз: %s - /gotp', name, prize)
end

local function announceWinner(targetId)
    local id = tonumber(targetId)
    if not id then
        sendMsg(C.RED, "Укажите ID игрока! Пример: /mpwin 661")
        return
    end

    if not sampIsPlayerConnected(id) then
        sendMsg(C.RED, string.format("Игрок с ID %d не в сети!", id))
        return
    end

    local nick = sampGetPlayerNickname(id)
    local mpName = getEffectiveEventName():gsub('^%s*["\']?', ''):gsub('["\']?%s*$', '')

    local winMsg = string.format('/ao [МП] Победителем МП "%s" стал %s[%d]! Поздравляем!', mpName, nick, id)
    sampSendChat(winMsg)

    addEventLog(string.format("Победитель: %s[%d] (МП: %s)", nick, id, mpName))
    sendMsg(C.GREEN, string.format("Объявлен победитель: %s[%d] на МП \"%s\"!", nick, id, mpName))
end

-- ==================== ПАРСИНГ ДИАЛОГОВ EVENTMENU ====================
local Dialogs = {}

function Dialogs.parseEvents(dialogText)
    Core.events_list = {}
    local line_idx = 0
    for line in dialogText:gmatch("[^\r\n]+") do
        local clean = cleanColorCodes(line)
        if not clean:find("ID%s+Название") then
            local id_str, name = clean:match("%[(%d+)%]%s*(.-)[\t\r\n]*$")
            if id_str and name then
                table.insert(Core.events_list, {
                    list_item = line_idx,
                    event_id  = tonumber(id_str),
                    title     = name:gsub("[\t%s\194\160]+$", "")
                })
                line_idx = line_idx + 1
            end
        end
    end
end

function Dialogs.parseToggles(dialogText)
    local t = {}
    for line in cleanColorCodes(dialogText):gmatch("[^\r\n]+") do
        local k, v = line:match("^(.-):%s*(.+)$")
        if k and v then
            t[k:gsub("^%s*(.-)%s*$", "%1")] = v:gsub("^%s*(.-)%s*$", "%1")
        end
    end
    return t
end

function Dialogs.parseBroadcast(dialogText)
    local msg = cleanColorCodes(dialogText):match("Сообщение на весь сервер:\r?\n?(.-)\r?\n?\r?\n?Укажите новое сообщение")
    return msg and msg:gsub("^%s*(.-)%s*$", "%1") or ""
end

function Dialogs.parseRules(dialogText)
    local r1, r2, r3 = "", "", ""
    for line in cleanColorCodes(dialogText):gmatch("[^\r\n]+") do
        local num, content = line:match("%[(%d+)%]%s*(.-)[\t\r\n]*$")
        if num and content then
            content = content:gsub("^%s*(.-)%s*$", "%1")
            if num == "1" then r1 = content end
            if num == "2" then r2 = content end
            if num == "3" then r3 = content end
        end
    end
    imgui.StrCopy(B.ev_rule1, u8(r1))
    imgui.StrCopy(B.ev_rule2, u8(r2))
    imgui.StrCopy(B.ev_rule3, u8(r3))
end

function Dialogs.parseWeapon(raw)
    if not raw or raw:find("Нет") then
        B.ev_weapon_sel[0] = 0
        return
    end
    local name, count = raw:match("^(.-)%s*%[количество:%s*(%d+)%]")
    name = (name or raw:gsub("%[.-%]", "")):gsub("^%s*(.-)%s*$", "%1"):lower()
    if count then B.ev_ammo_count[0] = tonumber(count) end

    for idx, wname_u8 in ipairs(WEAPON_NAMES) do
        local pure = u8:decode(wname_u8):gsub("^%(ID:%s*%d+%)%s*", ""):lower()
        if pure == name or pure:find(name, 1, true) then
            B.ev_weapon_sel[0] = idx - 1
            return
        end
    end
    B.ev_weapon_sel[0] = 0
end

function Dialogs.loadSettings(text)
    local t = Dialogs.parseToggles(text)
    if t["Название"] then 
        imgui.StrCopy(B.ev_new_title, u8(t["Название"]))
    end
    if t["Лимит игроков"] then B.ev_limit[0] = tonumber(t["Лимит игроков"]:match("%d+")) or B.ev_limit[0] end
    if t["Время действия телепорта"] then B.ev_tp_time[0] = tonumber(t["Время действия телепорта"]:match("%d+")) or B.ev_tp_time[0] end
    if t["Пароль для входа"] then imgui.StrCopy(B.ev_password, t["Пароль для входа"]:match("%d+") or "0") end
    if t["Выдать здоровье"] then B.ev_health[0] = tonumber(t["Выдать здоровье"]:match("%d+")) or B.ev_health[0] end
    if t["Выдать броню"] then B.ev_armour[0] = tonumber(t["Выдать броню"]:match("%d+")) or B.ev_armour[0] end
    if t["Выдать скин"] then B.ev_skin[0] = tonumber(t["Выдать скин"]:match("%d+")) or B.ev_skin[0] end

    Dialogs.parseWeapon(t["Выдать оружие"])

    Opt.take_guns[0]   = (t["Оружие при телепорте"] == "Отобрать")
    Opt.re_tp[0]       = (t["Повторный телепорт"] == "Разрешён")
    Opt.launcher[0]    = (t["Доступность"] == "Только с лаунчера")
    Opt.pvp_dmg[0]     = (t["Нанесение урона другим игрокам"] == "Нет")
    Opt.guards[0]      = (t["Охранники"] == "Нет")
    Opt.accessories[0] = (t["Эффекты от аксессуаров"] == "Да")
    Opt.lic_car[0]     = (t["Лицензия на авто"] == "Да")
    Opt.lic_moto[0]    = (t["Лицензия на мото"] == "Да")
    Opt.lic_boat[0]    = (t["Лицензия на водный ТС"] == "Да")
    Opt.lic_fly[0]     = (t["Лицензия на воздушный ТС"] == "Да")
    Opt.collision[0]   = (t["Коллизия игроков"] == "Да")
end

local function waitForDialog(expected_id, timeout_ms)
    timeout_ms = timeout_ms or 2500
    local start = os.clock()
    while (os.clock() - start) < (timeout_ms / 1000) do
        if Core.active_dialog_id == expected_id then return true end
        wait(20)
    end
    return false
end

local function waitReturnToEdit()
    wait(70)
    waitForDialog(DIALOGS.EVENT_EDIT, 2500)
    wait(70)
end

local function validateEventForm()
    local errs = {}
    if #Core.events_list == 0 or not Core.events_list[UI.selected_mp_idx[0] + 1] then
        table.insert(errs, "Не выбрано мероприятие в верхнем списке сервера")
    end
    local title = u8:decode(ffi.string(B.ev_new_title)):gsub("^%s*(.-)%s*$", "%1")
    if #title == 0 then
        table.insert(errs, "Поле 'Название МП' пустое")
    elseif #title < 3 then
        table.insert(errs, "Название МП: минимум 3 символа")
    end

    local ao = u8:decode(ffi.string(B.ev_broadcast)):gsub("^%s*(.-)%s*$", "%1")
    if #ao == 0 then
        table.insert(errs, "Поле 'Сообщение на весь сервер' пустое")
    elseif #ao < 5 then
        table.insert(errs, "Сообщение сервера: минимум 5 символов")
    elseif #ao > 128 then
        table.insert(errs, "Сообщение сервера слишком длинное (макс. 128 симв.)")
    end

    if B.ev_limit[0] < 1 or B.ev_limit[0] > 1000 then
        table.insert(errs, "Лимит игроков должен быть от 1 до 1000")
    end
    if B.ev_tp_time[0] < 1 or B.ev_tp_time[0] > 300 then
        table.insert(errs, "Время телепорта должно быть от 1 до 300 сек.")
    end

    local pass = ffi.string(B.ev_password)
    if #pass > 0 and (not pass:match("^%d+$") or #pass > 6) then
        table.insert(errs, "Пароль: только цифры (до 6 знаков)")
    end
    if B.ev_health[0] ~= 0 and (B.ev_health[0] < 5 or B.ev_health[0] > 250) then
        table.insert(errs, "HP: укажите от 5 до 250 (или 0)")
    end
    if B.ev_armour[0] ~= 0 and (B.ev_armour[0] < 5 or B.ev_armour[0] > 250) then
        table.insert(errs, "Броня: укажите от 5 до 250 (или 0)")
    end
    if B.ev_skin[0] ~= 0 and (B.ev_skin[0] < 1 or B.ev_skin[0] > 1120) then
        table.insert(errs, "Скин: ID от 1 до 1120 (или 0)")
    end
    if B.ev_weapon_sel[0] > 0 and (B.ev_ammo_count[0] < 1 or B.ev_ammo_count[0] > 500) then
        table.insert(errs, "Патроны: от 1 до 500 штук")
    end
    return errs
end

function Core.applySettings()
    if Core.running or Core.fetching_settings then
        HUD.show("validation_error", 3.0, { "Предыдущая операция еще не завершена" })
        return
    end

    local errs = validateEventForm()
    if #errs > 0 then
        HUD.show("validation_error", 5.5, errs)
        return
    end

    local current_mp = Core.events_list[UI.selected_mp_idx[0] + 1]
    Core.running = true
    Core.target_id = current_mp.event_id

    lua_thread.create(function()
        Core.active_dialog_id = -1
        sampSendChat("/eventmenu")
        if not waitForDialog(DIALOGS.EVENT_LIST, 3000) then
            HUD.show("validation_error", 4.0, { "Не удалось открыть меню МП (/eventmenu)" })
            Core.running = false
            return
        end

        wait(80)
        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_LIST, 1, current_mp.list_item, "")
        if not waitForDialog(DIALOGS.EVENT_EDIT, 3000) then
            HUD.show("validation_error", 4.0, { "Не удалось открыть параметры выбранного МП" })
            Core.running = false
            return
        end

        local cur = Dialogs.parseToggles(Core.active_dialog_text)

        local title = u8:decode(ffi.string(B.ev_new_title))
        if #title >= 3 and cur["Название"] ~= title then
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 0, "")
            if waitForDialog(DIALOGS.EVENT_RENAME, 2000) then
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.EVENT_RENAME, 1, -1, title)
                waitReturnToEdit()
            end
        end

        local r1 = u8:decode(ffi.string(B.ev_rule1))
        local r2 = u8:decode(ffi.string(B.ev_rule2))
        local r3 = u8:decode(ffi.string(B.ev_rule3))
        if #r1 > 0 or #r2 > 0 or #r3 > 0 then
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 1, "")
            if waitForDialog(DIALOGS.EVENT_RULES_LINES, 2000) then
                local function sendRule(line, val)
                    if #val > 0 then
                        wait(70)
                        Core.active_dialog_id = -1
                        sampSendDialogResponse(DIALOGS.EVENT_RULES_LINES, 1, line, "")
                        if waitForDialog(DIALOGS.EVENT_RULES_INPUT, 2000) then
                            wait(70)
                            Core.active_dialog_id = -1
                            sampSendDialogResponse(DIALOGS.EVENT_RULES_INPUT, 1, -1, val)
                            waitForDialog(DIALOGS.EVENT_RULES_LINES, 2000)
                        end
                    end
                end
                sendRule(0, r1); sendRule(1, r2); sendRule(2, r3)
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.EVENT_RULES_LINES, 0, -1, "")
                waitReturnToEdit()
            end
        end

        if B.ev_sp_slot[0] > 0 then
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 2, "")
            if waitForDialog(DIALOGS.SPAWN_MENU, 2000) then
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.SPAWN_MENU, 1, 0, "")
                if waitForDialog(DIALOGS.SPAWN_COUNT_INPUT, 2000) then
                    wait(70)
                    Core.active_dialog_id = -1
                    sampSendDialogResponse(DIALOGS.SPAWN_COUNT_INPUT, 1, -1, tostring(B.ev_sp_count[0]))
                    waitForDialog(DIALOGS.SPAWN_MENU, 2000)
                end

                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.SPAWN_MENU, 1, 1, "")
                if waitForDialog(DIALOGS.SPAWN_TYPE_SELECT, 2000) then
                    wait(70)
                    Core.active_dialog_id = -1
                    sampSendDialogResponse(DIALOGS.SPAWN_TYPE_SELECT, 1, B.ev_sp_type[0], "")
                    waitForDialog(DIALOGS.SPAWN_MENU, 2000)
                end

                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.SPAWN_MENU, 1, 2, "")
                if waitForDialog(DIALOGS.SPAWN_SLOTS_SELECT, 2000) then
                    wait(70)
                    Core.active_dialog_id = -1
                    sampSendDialogResponse(DIALOGS.SPAWN_SLOTS_SELECT, 1, B.ev_sp_slot[0] - 1, "")
                    waitForDialog(DIALOGS.SPAWN_MENU, 2000)
                end

                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.SPAWN_MENU, 0, -1, "")
                waitReturnToEdit()
            end
        end

        local ao = u8:decode(ffi.string(B.ev_broadcast))
        if #ao >= 5 then
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 3, "")
            if waitForDialog(DIALOGS.EVENT_BROADCAST, 2000) then
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.EVENT_BROADCAST, 1, -1, ao)
                waitReturnToEdit()
            end
        end

        cur = Dialogs.parseToggles(Core.active_dialog_text)

        local function syncField(row, expected_dialog, current_val, target_val)
            if current_val ~= target_val then
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, row, "")
                if waitForDialog(expected_dialog, 2000) then
                    wait(70)
                    Core.active_dialog_id = -1
                    sampSendDialogResponse(expected_dialog, 1, -1, tostring(target_val))
                    waitReturnToEdit()
                end
            end
        end

        local cur_lim = cur["Лимит игроков"] and tonumber(cur["Лимит игроков"]:match("%d+"))
        syncField(4, DIALOGS.EVENT_LIMIT, cur_lim, B.ev_limit[0])

        local target_tpt = math.max(1, math.min(300, math.floor(B.ev_tp_time[0])))
        local cur_tpt = cur["Время действия телепорта"] and tonumber(cur["Время действия телепорта"]:match("%d+"))
        syncField(5, DIALOGS.EVENT_TP_TIME, cur_tpt, target_tpt)

        local pass = ffi.string(B.ev_password)
        local cur_pass = cur["Пароль для входа"] and (cur["Пароль для входа"]:match("%d+") or "0")
        if #pass > 0 and cur_pass ~= pass then
            syncField(6, DIALOGS.EVENT_PASSWORD, cur_pass, pass)
        end

        local cur_hp = cur["Выдать здоровье"] and tonumber(cur["Выдать здоровье"]:match("%d+"))
        syncField(7, DIALOGS.EVENT_HEALTH, cur_hp, B.ev_health[0])

        local cur_arm = cur["Выдать броню"] and tonumber(cur["Выдать броню"]:match("%d+"))
        syncField(8, DIALOGS.EVENT_ARMOUR, cur_arm, B.ev_armour[0])

        local cur_sk = cur["Выдать скин"] and tonumber(cur["Выдать скин"]:match("%d+"))
        syncField(9, DIALOGS.EVENT_SKIN, cur_sk, B.ev_skin[0])

        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 10, "")
        if waitForDialog(DIALOGS.WEAPON_MENU, 2000) then
            wait(70)
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.WEAPON_MENU, 1, 0, "")
            if waitForDialog(DIALOGS.WEAPON_TYPE_LIST, 2000) then
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.WEAPON_TYPE_LIST, 1, B.ev_weapon_sel[0], "")
                waitForDialog(DIALOGS.WEAPON_MENU, 2000)
            end

            if B.ev_weapon_sel[0] > 0 then
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.WEAPON_MENU, 1, 1, "")
                if waitForDialog(DIALOGS.WEAPON_AMMO_INPUT, 2000) then
                    wait(70)
                    Core.active_dialog_id = -1
                    sampSendDialogResponse(DIALOGS.WEAPON_AMMO_INPUT, 1, -1, tostring(B.ev_ammo_count[0]))
                    waitForDialog(DIALOGS.WEAPON_MENU, 2000)
                end
            end

            wait(70)
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.WEAPON_MENU, 0, -1, "")
            waitReturnToEdit()
        end

        local toggles = {
            { 11, "Оружие при телепорте", Opt.take_guns[0] and "Отобрать" or "Не отбирать" },
            { 12, "Повторный телепорт", Opt.re_tp[0] and "Разрешён" or "Запрещён" },
            { 13, "Доступность", Opt.launcher[0] and "Только с лаунчера" or "Любой клиент" },
            { 14, "Нанесение урона другим игрокам", Opt.pvp_dmg[0] and "Нет" or "Да" },
            { 15, "Эффекты от аксессуаров", Opt.accessories[0] and "Да" or "Нет" },
            { 16, "Охранники", Opt.guards[0] and "Нет" or "Да" },
            { 17, "Лицензия на авто", Opt.lic_car[0] and "Да" or "Нет" },
            { 18, "Лицензия на мото", Opt.lic_moto[0] and "Да" or "Нет" },
            { 19, "Лицензия на водный ТС", Opt.lic_boat[0] and "Да" or "Нет" },
            { 20, "Лицензия на воздушный ТС", Opt.lic_fly[0] and "Да" or "Нет" },
            { 21, "Коллизия игроков", Opt.collision[0] and "Да" or "Нет" }
        }

        for _, item in ipairs(toggles) do
            local state = Dialogs.parseToggles(Core.active_dialog_text)
            if state[item[2]] and state[item[2]] ~= item[3] then
                wait(70)
                Core.active_dialog_id = -1
                sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, item[1], "")
                waitReturnToEdit()
            end
        end

        wait(100)
        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 24, "")
        wait(150)

        Core.running = false
        HUD.show("saved_success", 3.0)
    end)
end

function Core.fetchSettings()
    if #Core.events_list == 0 or Core.running or Core.fetching_settings then return end
    local current_mp = Core.events_list[UI.selected_mp_idx[0] + 1]
    if not current_mp then return end

    Core.fetching_settings = true
    sampAddChatMessage(string.format("{00FF00}[AMP]{FFFFFF} Загрузка данных МП #{FFFF00}%d{FFFFFF}...", current_mp.event_id), -1)

    lua_thread.create(function()
        Core.active_dialog_id = -1
        sampSendChat("/eventmenu")
        if not waitForDialog(DIALOGS.EVENT_LIST, 3000) then
            Core.fetching_settings = false
            return
        end

        wait(100)
        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_LIST, 1, current_mp.list_item, "")

        if not waitForDialog(DIALOGS.EVENT_EDIT, 3000) then
            Core.fetching_settings = false
            return
        end

        Dialogs.loadSettings(Core.active_dialog_text)
        wait(100)

        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 1, "")
        if waitForDialog(DIALOGS.EVENT_RULES_LINES, 2500) then
            Dialogs.parseRules(Core.active_dialog_text)
            wait(70)
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_RULES_LINES, 0, -1, "")
            waitReturnToEdit()
        end

        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 3, "")
        if waitForDialog(DIALOGS.EVENT_BROADCAST, 2500) then
            local msg = Dialogs.parseBroadcast(Core.active_dialog_text)
            if #msg > 0 then 
                imgui.StrCopy(B.ev_broadcast, u8(msg)) 
            else
                imgui.StrCopy(B.ev_broadcast, u8(generateBroadcastTemplate()))
            end
            wait(70)
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_BROADCAST, 0, -1, "")
            waitReturnToEdit()
        end

        wait(70)
        Core.active_dialog_id = -1
        sampSendDialogResponse(DIALOGS.EVENT_EDIT, 0, -1, "")
        wait(100)

        Core.fetching_settings = false
        HUD.show("fetched_success", 3.0)
    end)
end

function Core.toggleEvent()
    if #Core.events_list == 0 or Core.running or Core.fetching_settings or Core.toggling_event then return end
    local current_mp = Core.events_list[UI.selected_mp_idx[0] + 1]
    if not current_mp then return end

    Core.toggling_event = true
    local willStart = not HUD.is_running_now

    lua_thread.create(function()
        Core.active_dialog_id = -1
        sampSendChat("/eventmenu")
        if waitForDialog(DIALOGS.EVENT_LIST, 3000) then
            wait(100)
            Core.active_dialog_id = -1
            sampSendDialogResponse(DIALOGS.EVENT_LIST, 1, current_mp.list_item, "")
            if waitForDialog(DIALOGS.EVENT_EDIT, 3000) then
                wait(150)
                sampSendDialogResponse(DIALOGS.EVENT_EDIT, 1, 23, "")

                if willStart then
                    wait(400)
                    local broadcastText = generateBroadcastTemplate()
                    sampSendChat("/ao " .. broadcastText)
                    addEventLog("Запуск МП: отправлено сообщение в /ao")
                end
            end
        end
        Core.toggling_event = false
    end)
end

local function terminateThread(th)
    if th and th:status() ~= "dead" then th:terminate() end
    return nil
end

local function announceRules(mpKey)
    local lines = MP_RULES[mpKey]
    if not lines or #lines == 0 then return sendMsg(C.WARN, "Список правил пуст!") end
    if TH.rules and TH.rules:status() ~= "dead" then
        return sendMsg(C.WARN, "Озвучка правил уже выполняется!")
    end
    TH.rules = lua_thread.create(function()
        sendMsg(C.GREEN, "Начата озвучка правил мероприятия в /smp...")
        for _, line in ipairs(lines) do
            sampSendChat("/smp " .. line, -1)
            wait(1300)
        end
        sendMsg(C.GREEN, "Озвучка правил успешно завершена.")
        TH.rules = nil
    end)
end

local function DrawRulesEditor(mpKey)
    if not imgui.CollapsingHeader(u8"Редактировать правила озвучки (/smp)") then return end
    imgui.Indent(10)
    imgui.Spacing()

    if not RuleEditBuffers[mpKey] then RuleEditBuffers[mpKey] = {} end
    local bufs = RuleEditBuffers[mpKey]

    local toRemove = nil
    for idx, buf in ipairs(bufs) do
        imgui.Text(string.format("%d.", idx))
        imgui.SameLine()
        imgui.PushItemWidth(-40)
        imgui.InputText("##rline_" .. mpKey .. "_" .. idx, buf, 256)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("X##del_rl_" .. mpKey .. "_" .. idx, imgui.ImVec2(24, 20)) then
            toRemove = idx
        end
    end

    if toRemove then
        table.remove(bufs, toRemove)
    end

    imgui.Spacing()
    if imgui.Button(u8"+ Добавить строку##add_" .. mpKey, imgui.ImVec2(150, 24)) then
        table.insert(bufs, imgui.new.char[256](u8"Новое правило"))
    end
    imgui.SameLine()

    if imgui.Button(u8"Сохранить правила в конфиг##save_rl_" .. mpKey, imgui.ImVec2(200, 24)) then
        MP_RULES[mpKey] = {}
        for _, b in ipairs(bufs) do
            local str = u8:decode(ffi.string(b)):gsub("^%s*(.-)%s*$", "%1")
            if #str > 0 then
                table.insert(MP_RULES[mpKey], str)
            end
        end
        saveConfig()
        sendMsg(C.GREEN, "Правила для МП успешно сохранены в конфиг!")
    end
    imgui.SameLine()

    if imgui.Button(u8"Сбросить по умолчанию##rst_rl_" .. mpKey, imgui.ImVec2(160, 24)) then
        if DEFAULT_MP_RULES[mpKey] then
            MP_RULES[mpKey] = {}
            bufs = {}
            for idx, text in ipairs(DEFAULT_MP_RULES[mpKey]) do
                table.insert(MP_RULES[mpKey], text)
                bufs[idx] = imgui.new.char[256](u8(text))
            end
            RuleEditBuffers[mpKey] = bufs
            saveConfig()
            sendMsg(C.WARN, "Правила сброшены к стандартным и сохранены.")
        end
    end

    imgui.Spacing()
    imgui.Unindent(10)
end

local function isPlayerBlacklisted(idOrNick)
    local nick = type(idOrNick) == "number" and sampGetPlayerNickname(idOrNick) or idOrNick
    return nick and st.blacklist[nick] == true
end

local function punishViolator(id, reasonType, reasonPm, reasonSmp)
    if not sampIsPlayerConnected(id) or isPlayerBlacklisted(id) or id == st.myId then return end
    local nick = sampGetPlayerNickname(id)
    if not nick or nick == "" then return end
    lua_thread.create(function()
        sampSendChat("/spplayer " .. id)
        printStringNow(string.format("~r~%s ~w~%s", reasonType, nick), 2000)
        wait(400)
        sampSendChat(string.format("/pm %d 1 %s", id, reasonPm))
        wait(400)
        sampSendChat(string.format("/smp %s был дисквалифицирован за %s на мероприятии!", nick, reasonSmp))
        wait(400)
        sampSendChat("/weap " .. id .. " Нарушение Правил МП")
        addEventLog(string.format("Дисквалификация (%s): %s[%d]", reasonType, nick, id))
    end)
end

local function spawnAndNotify(target, pmType, pmText, customDelay)
    local nick = type(target) == "string" and target or sampGetPlayerNickname(target)
    if not nick or nick == "" then return end
    sampSendChat("/spplayer " .. nick, -1)
    wait(500)
    sampSendChat(string.format("/pm %s %d %s", nick, pmType or 1, pmText or ""), -1)
    addEventLog(string.format("Спавн (%s): %s", pmText or "Нарушение", nick))
    wait(math.floor((customDelay or CFG.SPAWN_CD) * 1000))
end

local function runAntiMaskScan()
    lua_thread.create(function()
        local chars = getAllChars()
        local count = 0
        if #chars > 1 then
            sendMsg(C.WARN, "Сканирование игроков на наличие масок...")
            for _, ped in ipairs(chars) do
                if ped ~= PLAYER_PED and doesCharExist(ped) then
                    local res, id = sampGetPlayerIdByCharHandle(ped)
                    if res and sampIsPlayerConnected(id) and not isPlayerBlacklisted(id) and id ~= st.myId then
                        local color = sampGetPlayerColor(id)
                        if color == CFG.MASK_COLOR then
                            punishViolator(id, "MASK", "Маски запрещены на мероприятии", "использование маски")
                            count = count + 1
                            wait(1200)
                        end
                    end
                end
            end
            sendMsg(C.GREEN, string.format("Проверка завершена. Заспавнено в масках: %d", count))
        else
            sendMsg(C.WARN, "Рядом нет игроков!")
        end
    end)
end

local function isValidTargetPed(ped)
    if ped == PLAYER_PED or not doesCharExist(ped) then return false, -1 end
    local res, id = sampGetPlayerIdByCharHandle(ped)
    if not res or not sampIsPlayerConnected(id) or isPlayerBlacklisted(id) then
        return false, -1
    end
    return true, id
end

local function isPlayerInWater(handle)
    if not doesCharExist(handle) then return false end
    local px, py, pz = getCharCoordinates(handle)
    local success, height = getWaterHeightAtCoords(px, py, false)
    if success and height and type(height) == "number" then return pz < height end
    if type(success) == "number" then return pz < success end
    return false
end

local function tolower(str)
    local bytes = { string.byte(str, 1, #str) }
    for i = 1, #bytes do
        local b = bytes[i]
        if (b >= 192 and b <= 223) or (b >= 65 and b <= 90) then
            bytes[i] = b + 32
        elseif b == 168 then
            bytes[i] = 229
        end
    end
    return string.char(unpack(bytes)):gsub("ё", "е")
end

local function isPointInPoly(x, y, poly)
    local ins, j = false, #poly
    for i = 1, #poly do
        if ((poly[i].y > y) ~= (poly[j].y > y)) and (x < (poly[j].x - poly[i].x) * (y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x) then
            ins = not ins
        end
        j = i
    end
    return ins
end

local function parseRange(str)
    local res, set = {}, {}
    for p in str:gmatch("[^,%s]+") do
        local f, t = p:match("^(%d+)%-(%d+)$")
        if f and t then
            f, t = tonumber(f), tonumber(t)
            for i = math.min(f, t), math.max(f, t) do
                if not set[i] then set[i] = true; table.insert(res, i) end
            end
        else
            local n = tonumber(p)
            if n and not set[n] then set[n] = true; table.insert(res, n) end
        end
    end
    return res
end

local function selectRandomPotatoHolder()
    local candidates = {}
    for _, ped in ipairs(getAllChars()) do
        local valid, id = isValidTargetPed(ped)
        if valid then table.insert(candidates, id) end
    end
    return (#candidates > 0) and candidates[math.random(1, #candidates)] or nil
end

local function clipToNearPlane(fx, fy, fz, wf, bx, by, bz, wb)
    local dw = wf - wb
    if dw == 0 then return nil, nil end
    local t = math.max(0.0, math.min(1.0, (wf - NEAR_PLANE_EPSILON) / dw))
    local _, sx, sy = convert3DCoordsToScreenEx(
        fx + (bx - fx) * t,
        fy + (by - fy) * t,
        fz + (bz - fz) * t
    )
    return sx, sy
end

local function renderDrawLine3D(x1, y1, z1, x2, y2, z2, thickness, color)
    local _, sx1, sy1, sz1 = convert3DCoordsToScreenEx(x1, y1, z1)
    local _, sx2, sy2, sz2 = convert3DCoordsToScreenEx(x2, y2, z2)
    if sz1 <= 0 and sz2 <= 0 then return false end
    if sz2 <= 0 then
        sx2, sy2 = clipToNearPlane(x1, y1, z1, sz1, x2, y2, z2, sz2)
    elseif sz1 <= 0 then
        sx1, sy1 = clipToNearPlane(x1, y1, z1, sz1, x2, y2, z2, sz2)
    end
    if not sx1 or not sx2 then return false end
    renderDrawLine(sx1, sy1, sx2, sy2, thickness, color)
    return true
end

local function getPedScreenPos(id)
    if not sampIsPlayerConnected(id) then return end
    local ex, ped = sampGetCharHandleBySampPlayerId(id)
    if not ex or not doesCharExist(ped) then return end
    local px, py, pz = getCharCoordinates(ped)
    if not isPointOnScreen(px, py, pz, 0) then return end
    local cx, cy, cz = getActiveCameraCoordinates()
    local dist = getDistanceBetweenCoords3d(cx, cy, cz, px, py, pz)
    if dist > CFG.DIST then return end
    local sx, sy = convert3DCoordsToScreen(px, py, pz + 0.8)
    return (sy > 0) and sx or nil, sy - math.max(18, 120 / dist)
end

local function findNextFreeSectorIdx()
    for i, name in ipairs(SECTOR_NAMES) do
        if not st.sectors[name] then return i end
    end
    return 5
end

local function removePointMarker()
    if pointMarker then
        removeUser3dMarker(pointMarker)
        pointMarker = nil
    end
end

local function createPointMarker(x, y, z)
    removePointMarker()
    pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end

local function showAimCursor(enable)
    if enable then
        sampSetCursorMode(3)
    else
        sampToggleCursor(false)
        removePointMarker()
        st.aimPos = nil
    end
    st.cursorActive = enable
end

-- ==================== МП ДЕРБИ ====================
local function toggleDerby()
    if st.derbyActive then
        TH.derby = terminateThread(TH.derby)
        st.derbyActive = false
        st.derbyPlayersWithVeh = {}
        return sendMsg(C.WARN, "МП 'Дерби' остановлено!")
    end
    if st.derbyCheckInt and getActiveInterior() ~= st.derbyIntId then
        return sendMsg(C.RED, string.format("МП 'Дерби' привязано к интерьеру 85! (Текущий: %d)", getActiveInterior()))
    end
    st.derbyActive = true
    st.derbyPlayersWithVeh = {}
    sendMsg(C.GREEN, "МП 'Дерби' успешно запущено!")
    addEventLog("Запуск МП Дерби")
    TH.derby = lua_thread.create(function()
        local lastVehGiveTime = 0
        local handled = {}
        while st.derbyActive do
            wait(200)
            if st.derbyCheckInt and getActiveInterior() ~= st.derbyIntId then
                st.derbyActive = false
                sendMsg(C.RED, "Вы покинули интерьер 85! Дерби выключено.")
                addEventLog("Выход из интерьера, Дерби отключено.")
                break
            end
            if st.derbyAutoGiveVeh and (os.clock() - lastVehGiveTime > 4.0) then
                lastVehGiveTime = os.clock()
                for _, ped in ipairs(getAllChars()) do
                    local valid, id = isValidTargetPed(ped)
                    if valid and not isCharInAnyCar(ped) then
                        local nick = sampGetPlayerNickname(id)
                        local chosen_car_id = (st.derbyGiveMode == 0) and cars_list[math.random(1, #cars_list)] or (cars_list[st.derbySelectedCar + 1] or 400)
                        sampSendChat(string.format("/plveh %s %d 0", nick, chosen_car_id))
                        st.derbyPlayersWithVeh[nick] = true
                        addEventLog(string.format("Выдано авто [%d] игроку %s", chosen_car_id, nick))
                        wait(600)
                    end
                end
            end
            for _, ped in ipairs(getAllChars()) do
                if not st.derbyActive then break end
                local valid, id = isValidTargetPed(ped)
                if valid and not handled[id] then
                    local nick = sampGetPlayerNickname(id)
                    if not isCharInAnyCar(ped) then
                        wait(math.floor(st.derbyPedDelay * 1000))
                        if not st.derbyActive then break end
                        local exist, curPed = sampGetCharHandleBySampPlayerId(id)
                        if exist and doesCharExist(curPed) and not isCharInAnyCar(curPed) and not handled[id] then
                            handled[id] = true
                            spawnAndNotify(nick, 0, "Вы были заспавнены: остались без машины на Дерби!")
                        end
                    else
                        local car = storeCarCharIsInNoSave(ped)
                        if doesVehicleExist(car) and getCarHealth(car) <= st.derbyHpThreshold then
                            wait(math.floor(st.derbyCarDelay * 1000))
                            if not st.derbyActive then break end
                            local exist, curPed = sampGetCharHandleBySampPlayerId(id)
                            if exist and doesCharExist(curPed) and isCharInAnyCar(curPed) and not handled[id] then
                                local curCar = storeCarCharIsInNoSave(curPed)
                                if doesVehicleExist(curCar) and getCarHealth(curCar) <= st.derbyHpThreshold then
                                    handled[id] = true
                                    spawnAndNotify(nick, 0, string.format("Вы выбыли: повреждения авто (меньше %d HP)!", st.derbyHpThreshold))
                                end
                            end
                        end
                    end
                end
            end
        end
        TH.derby = nil
    end)
end

-- ==================== 3D РЕНДЕР ====================
local function drawHUD(curTime)
    local hX, hY, moversCount = screenW - 220, 180, 0
    for id, exp in pairs(st.movers) do
        if curTime < exp then
            moversCount = moversCount + 1
            local sx, sy = getPedScreenPos(id)
            if sx and sy then
                local len = renderGetFontDrawTextLength(fontText, "сделал движение")
                renderFontDrawText(fontText, "сделал движение", sx - (len / 2), sy, C.YELLOW)
            end
        else
            st.movers[id] = nil
        end
    end
    renderDrawBox(hX - 10, hY - 5, 200, 50, C.ARGB_HUD)
    renderFontDrawText(fontHUD, st.isGreen and "ЗЕЛЕНЫЙ СВЕТ" or "КРАСНЫЙ СВЕТ", hX, hY, st.isGreen and C.ARGB_G or C.ARGB_R)
    renderFontDrawText(fontText, "Нарушителей: " .. moversCount, hX, hY + 22, C.WHITE)
end

local function drawDMHUD()
    local list = {}
    for id, data in pairs(st.dmPlayers) do
        table.insert(list, { id = id, nick = data.nick, kills = data.kills })
    end
    table.sort(list, function(a, b) return a.kills > b.kills end)
    local timeLeft = math.max(0, math.floor(st.dmTimerEnd - os.clock()))
    local mins = math.floor(timeLeft / 60)
    local secs = timeLeft % 60
    local hX, hY = screenW - 250, 240
    local height = 48 + math.min(#list, 3) * 20
    renderDrawBox(hX - 10, hY - 5, 230, height, C.ARGB_HUD)
    renderFontDrawText(fontHUD, string.format("ТОП-3 DM [%02d:%02d]", mins, secs), hX, hY, C.ARGB_MP)
    for i = 1, math.min(#list, 3) do
        local p = list[i]
        local str = string.format("%d. %s[%d]: %d", i, p.nick, p.id, p.kills)
        renderFontDrawText(fontText, str, hX, hY + 14 + (i * 18), C.WHITE)
    end
end

local function drawMPZone()
    if not CFG.SHOW_MP_ZONE or not mpZoneData then return end
    local cx, cy, cz = getActiveCameraCoordinates()
    if getDistanceBetweenCoords3d(cx, cy, cz, mpZoneData.center.x, mpZoneData.center.y, mpZoneData.center.z) <= CFG.DIST + 50.0 then
        local pts = mpZoneData.points
        for k = 1, 4 do
            local nxt = (k % 4) + 1
            renderDrawLine3D(pts[k].x, pts[k].y, pts[k].z, pts[nxt].x, pts[nxt].y, pts[nxt].z, 3, C.ARGB_MP)
        end
    end
end

local function drawZones()
    local cx, cy, cz = getActiveCameraCoordinates()
    for id, zone in pairs(pZones) do
        local act = st.active[id] == true
        if (act or st.showInact) and getDistanceBetweenCoords3d(cx, cy, cz, zone.center.x, zone.center.y, zone.center.z) <= CFG.DIST then
            local pts, occ = zone.points, st.occupied[id]
            local col, txt, tCol = C.ARGB_IN, string.format("Место #%d (Неактивна)", id), C.TXT_INACT
            if act then
                col = occ and C.ARGB_R or C.ARGB_G
                txt = occ and string.format("Место #%d занято %s[%d]", id, occ.nick, occ.id) or string.format("Свободное место #%d", id)
                tCol = occ and C.TXT_BUSY or C.TXT_FREE
            end
            for k = 1, 4 do
                local nxt = (k % 4) + 1
                renderDrawLine3D(pts[k].x, pts[k].y, pts[k].z, pts[nxt].x, pts[nxt].y, pts[nxt].z, act and 2 or 1, col)
            end
            local _, sx, sy, sz = convert3DCoordsToScreenEx(zone.center.x, zone.center.y, zone.center.z + 0.5)
            if sz and sz > 0 and sx and sy then
                local len = renderGetFontDrawTextLength(fontText, txt)
                renderFontDrawText(fontText, txt, sx - (len / 2), sy, tCol)
            end
        end
    end
end

local function drawSectorsAndSTZone()
    local cx, cy, cz = getActiveCameraCoordinates()
    for name, sec in pairs(st.sectors) do
        if getDistanceBetweenCoords3d(cx, cy, cz, sec.center.x, sec.center.y, sec.center.z) <= CFG.DIST + 50.0 then
            local pts = sec.points
            for k = 1, 4 do
                local nxt = (k % 4) + 1
                renderDrawLine3D(pts[k].x, pts[k].y, pts[k].z, pts[nxt].x, pts[nxt].y, pts[nxt].z, 3, C.ARGB_SEC)
            end
            local _, sx, sy, sz = convert3DCoordsToScreenEx(sec.center.x, sec.center.y, sec.center.z + 0.5)
            if sz and sz > 0 and sx and sy then
                local str = "Сектор " .. name
                local len = renderGetFontDrawTextLength(fontSector, str)
                renderFontDrawText(fontSector, str, sx - (len / 2), sy, C.WHITE)
            end
        end
    end
    if st.stZone then
        local sec = st.stZone
        if getDistanceBetweenCoords3d(cx, cy, cz, sec.center.x, sec.center.y, sec.center.z) <= CFG.DIST + 80.0 then
            local pts = sec.points
            for k = 1, 4 do
                local nxt = (k % 4) + 1
                renderDrawLine3D(pts[k].x, pts[k].y, pts[k].z, pts[nxt].x, pts[nxt].y, pts[nxt].z, 4, C.ARGB_ZONE)
            end
            local _, sx, sy, sz = convert3DCoordsToScreenEx(sec.center.x, sec.center.y, sec.center.z + 0.5)
            if sz and sz > 0 and sx and sy then
                local str = "Общая зона МП"
                local len = renderGetFontDrawTextLength(fontSector, str)
                renderFontDrawText(fontSector, str, sx - (len / 2), sy, C.WHITE)
            end
        end
    end
    if st.sectorSetupMode then
        local curLetter = SECTOR_NAMES[st.setupSectorIdx] or "?"
        local status = st.cursorActive and "{00FF00}Курсор активен (ЛКМ - сохранить точку){FFFFFF}" or "{FFCC00}Нажмите СКМ (колесо) для курсора{FFFFFF}"
        local infoText = string.format("Разметка: Сектор %s [%d/3] | %s", curLetter, #st.setupPoints, status)
        local boxW = 550
        renderDrawBox(screenW / 2 - (boxW / 2), 40, boxW, 30, C.ARGB_HUD)
        renderFontDrawText(fontText, infoText, screenW / 2 - (boxW / 2) + 10, 47, C.WHITE)
        for i, pt in ipairs(st.setupPoints) do
            local _, sx, sy, sz = convert3DCoordsToScreenEx(pt.x, pt.y, pt.z + 0.5)
            if sz and sz > 0 and sx and sy then
                renderFontDrawText(fontText, string.format("Точка #%d", i), sx, sy, C.YELLOW)
            end
        end
    end
    if st.stZoneSetupMode then
        local status = st.cursorActive and "{00FF00}Курсор активен (ЛКМ - сохранить точку){FFFFFF}" or "{FFCC00}Нажмите СКМ (колесо) для курсора{FFFFFF}"
        local infoText = string.format("Разметка: ОБЩАЯ ЗОНА МП [%d/3] | %s", #st.stZonePoints, status)
        local boxW = 550
        renderDrawBox(screenW / 2 - (boxW / 2), 40, boxW, 30, C.ARGB_HUD)
        renderFontDrawText(fontText, infoText, screenW / 2 - (boxW / 2) + 10, 47, C.WHITE)
        for i, pt in ipairs(st.stZonePoints) do
            local _, sx, sy, sz = convert3DCoordsToScreenEx(pt.x, pt.y, pt.z + 0.5)
            if sz and sz > 0 and sx and sy then
                renderFontDrawText(fontText, string.format("Угол арены #%d", i), sx, sy, C.ARGB_ZONE)
            end
        end
    end
end

-- ==================== МЕРОПРИЯТИЯ ====================
local function toggleRLGL()
    st.enabled = not st.enabled
    st.isGreen, st.movers, st.queue, st.inQueue = st.enabled, {}, {}, {}
    if st.enabled then st.curInt = getActiveInterior() end
    sendMsg(st.enabled and C.GREEN or C.RED, st.enabled and "Светофор ВКЛЮЧЕН." or "Светофор ВЫКЛЮЧЕН.")
end

local function sendRLGLSignal(isGreenSignal)
    if not st.enabled then return sendMsg(C.WARN, "Сначала включите Светофор!") end
    sampSendChat("/smp " .. (isGreenSignal and "Зеленый свет" or "Красный свет"), -1)
end

local function applyChairsZones(rangeStr)
    if rangeStr == "" then return sendMsg(C.WARN, "Укажите номера мест!") end
    local c = 0
    for _, id in ipairs(parseRange(rangeStr)) do
        if pZones[id] then st.selected[id], st.active[id], c = true, true, c + 1 end
    end
    st.chairs = true
    sendMsg(C.GREEN, "Активировано мест: " .. c)
end

local function removeChairsZones(rangeStr)
    if rangeStr == "" then return end
    local c = 0
    for _, id in ipairs(parseRange(rangeStr)) do
        if st.active[id] then st.active[id], c = nil, c + 1 end
    end
    sendMsg(C.RED, "Деактивировано мест: " .. c)
end

local function resetChairsZones()
    st.selected, st.active, st.occupied, st.chairs, st.showInact = {}, {}, {}, false, true
    sendMsg(C.WARN, "Сброс всех зон стульчиков выполнен.")
end

local function toggleStulGame()
    if st.stulActive then
        TH.stul = terminateThread(TH.stul)
        st.stulActive = false
        return sendMsg(C.WARN, "МП 'Стульчики' остановлено!")
    end
    local initialActive = 0
    for _ in pairs(st.active) do initialActive = initialActive + 1 end
    if initialActive == 0 then return sendMsg(C.WARN, "Сначала активируйте места через зоны!") end
    TH.stul = lua_thread.create(function()
        st.stulActive = true
        sampSendChat("/smp Старт")
        local startTime = os.clock()
        local waitTime = math.random(10, 30)
        while os.clock() - startTime < waitTime do wait(100) end
        sampSendChat("/smp Стоп")
        while true do
            wait(100)
            local curActive, curOccupied = 0, 0
            for zId in pairs(st.active) do 
                curActive = curActive + 1 
                if st.occupied[zId] then curOccupied = curOccupied + 1 end
            end
            if curActive > 0 and curOccupied >= curActive then break end
        end
        local seatedPlayers = {}
        for zId, info in pairs(st.occupied) do
            if st.active[zId] then seatedPlayers[info.id] = true end
        end
        local losers = {}
        for _, ped in ipairs(getAllChars()) do
            local valid, id = isValidTargetPed(ped)
            if valid and not seatedPlayers[id] then
                local px, py = getCharCoordinates(ped)
                if isPointInPoly(px, py, mpZoneData.points) then
                    local nick = sampGetPlayerNickname(id)
                    if nick and nick ~= "" then table.insert(losers, { id = id, nick = nick }) end
                end
            end
        end
        if #losers > 0 then
            for i = 1, #losers, 2 do
                local p1, p2 = losers[i], losers[i + 1]
                if p2 then
                    sampSendChat(string.format("/smp %s[%d], %s[%d] не успел занять стульчики!", p1.nick, p1.id, p2.nick, p2.id))
                else
                    sampSendChat(string.format("/smp %s[%d] не успел занять стульчики!", p1.nick, p1.id))
                end
                wait(1500)
            end
            for _, player in ipairs(losers) do
                if sampIsPlayerConnected(player.id) then
                    spawnAndNotify(player.nick, 1, "Вы не успели занять стульчик, вы выбыли с МП!")
                end
            end
        else
            sendMsg(C.GREEN, "Все успели занять стульчики!")
        end

        st.stulActive = false
        TH.stul = nil
    end)
end

local function toggleSectorSetup()
    if st.stZoneSetupMode then return sendMsg(C.WARN, "Сначала завершите настройку Общей Зоны!") end
    if st.sectorSetupMode then
        st.sectorSetupMode = false
        st.setupPoints = {}
        showAimCursor(false)
        return sendMsg(C.WARN, "Режим настройки секторов выключен.")
    end
    local nextIdx = findNextFreeSectorIdx()
    if nextIdx > 4 then
        return sendMsg(C.WARN, "Все 4 сектора (A, B, C, D) уже созданы!")
    end
    st.sectorSetupMode = true
    st.setupSectorIdx = nextIdx
    st.setupPoints = {}
    showAimCursor(false)
    sendMsg(C.GREEN, "Разметка секторов включена!")
    sendMsg(C.WHITE, "Нажмите {FFFF00}СКМ{FFFFFF} — курсор, затем {00FF00}ЛКМ{FFFFFF} — ставить точку (3 точки).")
    sendMsg(C.WARN, string.format("Размечаем Сектор %s (Точка 1/3)", SECTOR_NAMES[st.setupSectorIdx]))
end

local function toggleStZoneSetup()
    if st.sectorSetupMode then return sendMsg(C.WARN, "Сначала завершите настройку секторов!") end
    if st.stZoneSetupMode then
        st.stZoneSetupMode = false
        st.stZonePoints = {}
        showAimCursor(false)
        return sendMsg(C.WARN, "Режим разметки общей зоны выключен.")
    end
    st.stZoneSetupMode = true
    st.stZonePoints = {}
    showAimCursor(false)
    sendMsg(C.GREEN, "Разметка ОБЩЕЙ ЗОНЫ МП включена!")
    sendMsg(C.WHITE, "Нажмите {FFFF00}СКМ{FFFFFF} — курсор. Поставьте 3 угловые точки через {00FF00}ЛКМ{FFFFFF}.")
end

local function deleteSector(secName)
    secName = string.upper(secName or "")
    if secName ~= "" and st.sectors[secName] then
        st.sectors[secName] = nil
        saveConfig()
        sendMsg(C.RED, string.format("Сектор %s удален!", secName))
        if st.sectorSetupMode then
            st.setupSectorIdx = findNextFreeSectorIdx()
            st.setupPoints = {}
            showAimCursor(false)
        end
    else
        sendMsg(C.WARN, "Сектор не найден!")
    end
end

local function runSectorRound(isOneSafe, forcedSector)
    if st.sectorRoundRun then return sendMsg(C.WARN, "Раунд секторов уже идет!") end
    if not st.stZone then return sendMsg(C.RED, "Сначала задайте общую зону МП через разметку!") end
    local count = 0
    for _, n in ipairs(SECTOR_NAMES) do
        if st.sectors[n] then count = count + 1 end
    end
    if count < 4 then return sendMsg(C.RED, "Сначала создайте все 4 сектора (A, B, C, D)!") end
    local chosenSector = forcedSector or SECTOR_NAMES[math.random(1, 4)]
    st.sectorRoundRun = true
    TH.sector = lua_thread.create(function()
        if isOneSafe then
            sampSendChat(string.format("/smp 3 сектора заражены, безопасный сектор %s", chosenSector), -1)
        else
            sampSendChat(string.format("/smp 3 сектора безопасны, зараженный сектор %s", chosenSector), -1)
        end
        wait(1000)
        sampSendChat("/smp У вас есть 3 секунды, чтобы спастись", -1)
        wait(3000)
        local losers = {}
        local zonePoly = st.stZone.points
        for _, ped in ipairs(getAllChars()) do
            local valid, id = isValidTargetPed(ped)
            if valid then
                local px, py, pz = getCharCoordinates(ped)
                if pz >= CFG.SECTOR_MIN_Z and isPointInPoly(px, py, zonePoly) then
                    local isPlayerSurvived = false
                    if isOneSafe then
                        if isPointInPoly(px, py, st.sectors[chosenSector].points) then isPlayerSurvived = true end
                    else
                        local inInfected = isPointInPoly(px, py, st.sectors[chosenSector].points)
                        if not inInfected then
                            for secName, secData in pairs(st.sectors) do
                                if secName ~= chosenSector and isPointInPoly(px, py, secData.points) then
                                    isPlayerSurvived = true
                                    break
                                end
                            end
                        end
                    end

                    if not isPlayerSurvived then
                        local nick = sampGetPlayerNickname(id)
                        if nick and nick ~= "" then table.insert(losers, { id = id, nick = nick }) end
                    end
                end
            end
        end
        sendMsg(C.WARN, string.format("Выбыло игроков: %d. Начат спавн...", #losers))
        for _, loser in ipairs(losers) do
            if sampIsPlayerConnected(loser.id) then
                spawnAndNotify(loser.nick, 1, "Вы не успели покинуть зараженный сектор", CFG.SECTOR_SPAWN_CD)
            end
        end
        sendMsg(C.GREEN, "Раунд секторов успешно завершен!")
        st.sectorRoundRun = false
        TH.sector = nil
    end)
end

local function toggleDM()
    if st.dmActive then
        TH.dmTimer = terminateThread(TH.dmTimer)
        st.dmActive, st.dmPlayers, st.dmRespawnQueue, st.dmInRespawn = false, {}, {}, {}
        return sendMsg(C.WARN, "МП 'DeathMatch' остановлено досрочно!")
    end
    st.dmActive, st.dmPlayers, st.dmRespawnQueue, st.dmInRespawn = true, {}, {}, {}
    st.dmTimerEnd = os.clock() + 600.0
    local count = 0
    for _, ped in ipairs(getAllChars()) do
        local valid, id = isValidTargetPed(ped)
        if valid then
            st.dmPlayers[id] = { nick = sampGetPlayerNickname(id), kills = 0 }
            count = count + 1
        end
    end
    sendMsg(C.GREEN, string.format("МП 'DeathMatch' запущено на 10 минут! Игроков: %d", count))
    TH.dmTimer = lua_thread.create(function()
        while st.dmActive and os.clock() < st.dmTimerEnd do wait(200) end
        if st.dmActive then
            local bestPlayer = nil
            for id, data in pairs(st.dmPlayers) do
                if not bestPlayer or data.kills > bestPlayer.kills then
                    bestPlayer = { id = id, nick = data.nick, kills = data.kills }
                end
            end
            if bestPlayer then
                sampSendChat(string.format("/smp Время вышло, победитель - %s[%d]", bestPlayer.nick, bestPlayer.id), -1)
                wait(1000)
                sampSendChat("/spplayers 100", -1)
                wait(1500)
                sampSendChat("/gethere " .. bestPlayer.nick, -1)
            else
                sampSendChat("/smp Время вышло! Победитель не определен.", -1)
                wait(1000)
                sampSendChat("/spplayers 100", -1)
            end
            st.dmActive, st.dmPlayers, st.dmRespawnQueue, st.dmInRespawn = false, {}, {}, {}
            TH.dmTimer = nil
        end
    end)
end

local function togglePotato()
    if st.potatoActive then
        st.potatoActive, st.potatoHolder, st.lastHolder = false, nil, nil
        return sendMsg(C.WARN, "МП 'Горячая картошка' выключено!")
    end
    local targetId = selectRandomPotatoHolder()
    if not targetId then return sendMsg(C.WARN, "В зоне стрима нет игроков!") end
    st.potatoHolder = targetId
    st.lastHolder = nil
    st.potatoActive = true
    st.potatoTimer = os.clock() + 10.0
    local targetNick = sampGetPlayerNickname(targetId)
    sampSendChat(string.format("/setskin %d 104 0", targetId))
    sampSendChat(string.format("/pm %d 0 У вас есть 10 секунд, чтобы передать горячую картошку!", targetId))
    sampSendChat(string.format("/smp Горячая картошка у %s[%d], держитесь дальше!", targetNick, targetId))
end

local function toggleVoda()
    if st.vodaActive then
        TH.voda = terminateThread(TH.voda)
        st.vodaActive = false
        return sendMsg(C.WARN, "Функция 'Анти-Вода' выключена!")
    end
    st.vodaActive = true
    sendMsg(C.GREEN, "Функция 'Анти-Вода' активирована!")
    TH.voda = lua_thread.create(function()
        local handled = {}
        while st.vodaActive do
            wait(200)
            for _, ped in ipairs(getAllChars()) do
                if not st.vodaActive then break end
                local valid, id = isValidTargetPed(ped)
                if valid and not handled[id] and isPlayerInWater(ped) then
                    handled[id] = true
                    local nick = sampGetPlayerNickname(id)
                    local reason = u8:decode(ffi.string(B.voda_reason))
                    sendMsg(C.WARN, string.format("Игрок %s[%d] упал в воду, спавним...", nick, id))
                    spawnAndNotify(nick, 1, reason ~= "" and reason or "Вы были заспавнены, так как упали в воду")
                end
            end
        end
        TH.voda = nil
    end)
end

function se.onApplyPlayerAnimation(id, animname, frameDelta, loop, lockx, locky, freeze, time)
    if isPlayerBlacklisted(id) or id == st.myId then return end
    if st.autospheal then
        if (animname == "ped" and frameDelta == "gum_eat") or (animname == "FOOD" and frameDelta == "EAT_Burger") or (animname == "SMOKING" and frameDelta == "M_smk_drag") then
            punishViolator(id, "HEAL", "Запрещено пополнять здоровье на мероприятии!", "пополнение здоровья")
        end
    end
    if st.autosparm and animname == "goggles" and frameDelta == "goggles_put_on" then
        punishViolator(id, "ARMOUR", "Запрещено пополнять броню на мероприятии!", "пополнение брони")
    end
end

function se.onServerMessage(col, text)
    local clear = cleanColorCodes(text)

    local admin, sec_str = clear:match("%[Game Event%]%s*A:%s*([%a%d_]+)%s*запустил мероприятие,%s*время действие телепорта:%s*(%d+)%s*сек%.")
    if admin and sec_str then
        local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if admin == sampGetPlayerNickname(my_id) then
            local sec = tonumber(sec_str)
            HUD.total_sec      = sec
            HUD.end_time       = os.clock() + sec
            HUD.mode           = "countdown"
            HUD.progress       = 0.0
            HUD.is_closing     = false
            HUD.is_running_now = true
            HUD.active         = true
        end
    end

    local stop_admin = clear:match("%[Game Event%]%s*A:%s*([%a%d_]+)%s*выключил телепорт на мероприятие%.")
    if stop_admin then
        local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if stop_admin == sampGetPlayerNickname(my_id) then
            HUD.is_running_now = false
            HUD.show("stopped_manual", 3.0)
        end
    end

    if clear:find("%[Game Event%]%s*Телепорт на мероприятие закрыт,%s*набрано необходимое количество игроков%.") then
        HUD.is_running_now = false
        HUD.show("closed_players", 3.0)
    end

    if clear:find("%[Game Event%]%s*Телепорт на мероприятие закрыт,%s*время вышло%.") then
        HUD.is_running_now = false
        HUD.is_closing = true
    end

    if st.enabled then
        local sNick, sMsg = clear:match("^%[МП%]%s+([%w_]+):%s+(.+)$")
        if sNick and sNick == st.myNick then
            local lMsg = tolower(sMsg)
            if lMsg:find("зеленый свет") then
                st.isGreen, st.movers, st.queue, st.inQueue = true, {}, {}, {}
                sendMsg(C.GREEN, "Зеленый свет!")
            elseif lMsg:find("красный свет") then
                st.isGreen, st.movers, st.queue, st.inQueue, st.redTime = false, {}, {}, {}, os.clock()
                sendMsg(C.RED, "Красный свет!")
            end
        end
    end

    if st.autospheal then
        local healNick = clear:match("^(%S+)%s+использовал%(а%) аптечку")
            or clear:match("^(%S+)%s+принимает дозу укропа")
            or clear:match("^(%S+)%s+закинулся таблеткой адреналина")
            or clear:match("^(%S+)%s+выпил%(а%) банку спранка")
            or clear:match("^(%S+)%s+выпил%(а%) бутылку пива")
            or clear:match("^(%S+)%s+стряхнул%(а%) пепел")
            or clear:match("^(%S+)%s+достал сигарету с зажигалкой и закурил")
            or clear:match("^(%S+)%[%d+%]%s+принимает дозу укропа")
            or clear:match("^(%S+)%[%d+%]%s+стряхнул%(а%) пепел")
        if healNick and not isPlayerBlacklisted(healNick) and healNick ~= st.myNick then
            for _, ped in ipairs(getAllChars()) do
                local res, pId = sampGetPlayerIdByCharHandle(ped)
                if res and sampGetPlayerNickname(pId) == healNick then
                    punishViolator(pId, "HEAL", "Запрещено пополнять здоровье на мероприятии!", "пополнение здоровья")
                    break
                end
            end
        end
    end
end

function se.onPlayerChatBubble(id, col, dist, dur, msg)
    if isPlayerBlacklisted(id) or id == st.myId then return end
    local nick = sampGetPlayerNickname(id)
    if st.autospgun and msg:find("Достал%(а%) оружие из кармана") then
        lua_thread.create(function()
            sampSendChat('/weap ' .. id .. ' Нарушение Правил МП')
            wait(400)
            sampSendChat('/pm ' .. id .. ' 1 Запрещено использовать оружие на мероприятии!')
            addEventLog("Разоружение: " .. nick)
        end)
    end
end

function se.onPlayerQuit(id)
    st.movers[id] = nil
    if st.inQueue[id] then
        st.inQueue[id] = nil
        for i = #st.queue, 1, -1 do 
            if st.queue[i].id == id then table.remove(st.queue, i); break end 
        end
    end
    if st.dmPlayers[id] then st.dmPlayers[id] = nil end
    if st.dmInRespawn[id] then
        st.dmInRespawn[id] = nil
        for i = #st.dmRespawnQueue, 1, -1 do
            if st.dmRespawnQueue[i].id == id then table.remove(st.dmRespawnQueue, i); break end
        end
    end
end

function se.onPlayerDeathNotification(killerId, killedId, reason)
    if not st.dmActive then return end
    if killerId and st.dmPlayers[killerId] then
        st.dmPlayers[killerId].kills = st.dmPlayers[killerId].kills + 1
    end
    if killedId and st.dmPlayers[killedId] and not st.dmInRespawn[killedId] then
        st.dmInRespawn[killedId] = true
        table.insert(st.dmRespawnQueue, {
            id      = killedId,
            nick    = st.dmPlayers[killedId].nick,
            readyAt = os.clock() + CFG.DM_DEATH_DELAY
        })
    end
end

function se.onPlayerSync(id, data)
    if not st.enabled or st.isGreen or (os.clock() - st.redTime) < CFG.RED_DELAY then return end
    if id == st.myId or isPlayerBlacklisted(id) then return end
    local isMoving = (data.upDownKeys and math.abs(data.upDownKeys) > CFG.DEADZONE)
        or (data.leftRightKeys and math.abs(data.leftRightKeys) > CFG.DEADZONE)
        or (data.keysData and (bit.band(data.keysData, 40) ~= 0))
        or (data.moveSpeed and ((data.moveSpeed.x^2 + data.moveSpeed.y^2 + data.moveSpeed.z^2) > CFG.SPEED_TH_SQ))
    if isMoving then
        st.movers[id] = os.clock() + CFG.PENALTY_CD
        if not st.inQueue[id] then
            local nick = sampGetPlayerNickname(id)
            if nick and nick ~= "" then
                st.inQueue[id] = true
                table.insert(st.queue, { id = id, nick = nick })
            end
        end
    end
end

function se.onShowDialog(dialogId, style, title, button1, button2, text)
    Core.active_dialog_id   = dialogId
    Core.active_dialog_text = text

    if dialogId == DIALOGS.EVENT_LIST and Core.fetching_list then
        Dialogs.parseEvents(text)
        Core.fetching_list = false
        lua_thread.create(function()
            wait(50)
            sampSendDialogResponse(DIALOGS.EVENT_LIST, 0, -1, "")
        end)
        return false
    end

    if Core.running or Core.fetching_settings or Core.toggling_event then
        return false
    end
end

-- ==================== ТЕМА ====================
local function applyDarkWineTheme()
    local style = imgui.GetStyle()
    local c = style.Colors
    style.WindowRounding    = 8.0
    style.ChildRounding     = 7.0
    style.FrameRounding     = 6.0
    style.PopupRounding     = 6.0
    style.ScrollbarRounding = 6.0
    style.WindowBorderSize  = 1.0
    style.FrameBorderSize   = 1.0
    style.ItemSpacing       = imgui.ImVec2(8, 8)
    style.WindowPadding     = imgui.ImVec2(12, 12)
    c[imgui.Col.WindowBg]             = imgui.ImVec4(0.09, 0.04, 0.06, 0.96)
    c[imgui.Col.ChildBg]              = imgui.ImVec4(0.13, 0.06, 0.09, 0.85)
    c[imgui.Col.PopupBg]              = imgui.ImVec4(0.12, 0.05, 0.08, 0.98)
    c[imgui.Col.Border]               = imgui.ImVec4(0.35, 0.15, 0.20, 0.60)
    c[imgui.Col.FrameBg]              = imgui.ImVec4(0.18, 0.08, 0.12, 0.90)
    c[imgui.Col.FrameBgHovered]       = imgui.ImVec4(0.25, 0.10, 0.16, 0.90)
    c[imgui.Col.FrameBgActive]        = imgui.ImVec4(0.30, 0.12, 0.19, 1.00)
    c[imgui.Col.TitleBg]              = imgui.ImVec4(0.11, 0.05, 0.07, 1.00)
    c[imgui.Col.TitleBgActive]        = imgui.ImVec4(0.15, 0.06, 0.10, 1.00)
    c[imgui.Col.Button]               = imgui.ImVec4(0.68, 0.20, 0.26, 0.85)
    c[imgui.Col.ButtonHovered]        = imgui.ImVec4(0.82, 0.27, 0.34, 1.00)
    c[imgui.Col.ButtonActive]         = imgui.ImVec4(0.58, 0.16, 0.22, 1.00)
    c[imgui.Col.Header]               = imgui.ImVec4(0.28, 0.10, 0.17, 0.80)
    c[imgui.Col.HeaderHovered]        = imgui.ImVec4(0.38, 0.14, 0.23, 0.90)
    c[imgui.Col.HeaderActive]         = imgui.ImVec4(0.48, 0.18, 0.29, 1.00)
    c[imgui.Col.Separator]            = imgui.ImVec4(0.35, 0.15, 0.20, 0.50)
    c[imgui.Col.Text]                 = imgui.ImVec4(0.95, 0.95, 0.96, 1.00)
    c[imgui.Col.TextDisabled]         = imgui.ImVec4(0.55, 0.48, 0.50, 1.00)
end

local function ToggleSwitch(str_id, bool_val)
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local width, height = 40.0, 20.0
    local radius = height * 0.5
    imgui.InvisibleButton(str_id, imgui.ImVec2(width, height))
    local clicked = imgui.IsItemClicked()
    if clicked then bool_val = not bool_val end
    local hovered = imgui.IsItemHovered()
    local col_bg
    if bool_val then
        col_bg = hovered and imgui.GetColorU32Vec4(imgui.ImVec4(0.85, 0.27, 0.34, 1.0)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.75, 0.22, 0.28, 1.0))
    else
        col_bg = hovered and imgui.GetColorU32Vec4(imgui.ImVec4(0.28, 0.12, 0.17, 1.0)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.20, 0.09, 0.13, 1.0))
    end
    draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, radius)
    draw_list:AddRect(p, imgui.ImVec2(p.x + width, p.y + height), imgui.GetColorU32Vec4(imgui.ImVec4(0.40, 0.16, 0.22, 0.7)), radius, 15, 1.0)
    local circle_x = bool_val and (p.x + width - radius) or (p.x + radius)
    draw_list:AddCircleFilled(imgui.ImVec2(circle_x, p.y + radius), radius - 2.5, imgui.GetColorU32Vec4(imgui.ImVec4(1.0, 1.0, 1.0, 0.95)))
    return clicked, bool_val
end

local function DrawGameCard(id, title, desc, isActive, onClick)
    local draw_list = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local size = imgui.ImVec2(270, 76)
    imgui.InvisibleButton("##card_btn_" .. id, size)
    local hovered = imgui.IsItemHovered()
    local clicked = imgui.IsItemClicked()
    local col_bg
    if isActive then
        col_bg = hovered and imgui.GetColorU32Vec4(imgui.ImVec4(0.26, 0.10, 0.16, 0.95)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.20, 0.08, 0.13, 0.90))
    else
        col_bg = hovered and imgui.GetColorU32Vec4(imgui.ImVec4(0.18, 0.08, 0.11, 0.85)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.13, 0.06, 0.09, 0.75))
    end
    local col_border = isActive and imgui.GetColorU32Vec4(imgui.ImVec4(0.85, 0.28, 0.35, 0.90)) or (hovered and imgui.GetColorU32Vec4(imgui.ImVec4(0.50, 0.20, 0.26, 0.70)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.28, 0.12, 0.16, 0.50)))
    draw_list:AddRectFilled(p, imgui.ImVec2(p.x + size.x, p.y + size.y), col_bg, 7.0)
    draw_list:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), col_border, 7.0, 15, 1.0)
    local strip_col = isActive and imgui.GetColorU32Vec4(imgui.ImVec4(0.20, 0.95, 0.30, 1.0)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.45, 0.35, 0.40, 0.80))
    draw_list:AddRectFilled(imgui.ImVec2(p.x + 3, p.y + 8), imgui.ImVec2(p.x + 6, p.y + size.y - 8), strip_col, 2.0)
    draw_list:AddText(imgui.ImVec2(p.x + 14, p.y + 8), imgui.GetColorU32Vec4(imgui.ImVec4(0.98, 0.95, 0.96, 1.0)), u8(title))
    local statusText = isActive and u8("АКТИВНО") or u8("ВЫКЛ")
    local statusCol = isActive and imgui.GetColorU32Vec4(imgui.ImVec4(0.30, 0.95, 0.40, 1.0)) or imgui.GetColorU32Vec4(imgui.ImVec4(0.55, 0.50, 0.52, 0.80))
    local statusLen = imgui.CalcTextSize(statusText).x
    draw_list:AddText(imgui.ImVec2(p.x + size.x - statusLen - 12, p.y + 8), statusCol, statusText)
    draw_list:AddText(imgui.ImVec2(p.x + 14, p.y + 32), imgui.GetColorU32Vec4(imgui.ImVec4(0.72, 0.65, 0.68, 1.0)), u8(desc))
    if clicked and onClick then onClick() end
    return clicked
end

imgui.OnInitialize(function()
    applyDarkWineTheme()
    local io = imgui.GetIO()
    local font_path = getFolderPath(0x14) .. "\\trebuc.ttf"
    if doesFileExist(font_path) then
        io.Fonts:Clear()
        io.Fonts:AddFontFromFileTTF(font_path, 14.0, nil, io.Fonts:GetGlyphRangesCyrillic())
    end
end)

-- ==================== HUD УВЕДОМЛЕНИЙ И ОШИБОК ====================
imgui.OnFrame(function() return HUD.active end, function()
    local remaining = HUD.end_time - os.clock()

    if HUD.is_closing or remaining <= 0 then
        HUD.is_closing = true
        HUD.progress = HUD.progress - 0.09
        if HUD.progress <= 0.0 then
            HUD.active = false
            HUD.mode = "none"
            HUD.is_closing = false
            HUD.progress = 0.0
            HUD.error_list = {}
            return
        end
    else
        if HUD.progress < 1.0 then
            HUD.progress = math.min(1.0, HUD.progress + ((1.0 - HUD.progress) * 0.16 + 0.025))
        end
    end

    local is_err   = (HUD.mode == "validation_error")
    local is_green = (HUD.mode == "saved_success" or HUD.mode == "fetched_success")
    local is_blue  = (HUD.mode == "countdown")
    local color    = is_err and 0xFFFF3333 or (is_green and 0xFF00FF7F or (is_blue and 0xFF00E5FF or 0xFFFF6600))

    local err_count = #HUD.error_list
    local w = is_err and 560.0 or 420.0
    local h = is_err and (35.0 + math.max(1, err_count) * 22.0) or 56.0
    local pad = 10.0
    local win_w, win_h = w + pad * 2, h + pad * 2

    local resX, resY = getScreenResolution()
    local pos_x = (resX - win_w) / 2.0
    local target_y = resY - win_h - 25.0
    local hidden_y = resY + 30.0
    local pos_y = hidden_y + (target_y - hidden_y) * HUD.progress

    imgui.SetNextWindowPos(imgui.ImVec2(pos_x, pos_y), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(win_w, win_h), imgui.Cond.Always)

    local flags = imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + 
                  imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + 
                  imgui.WindowFlags.NoFocusOnAppearing + imgui.WindowFlags.NoBackground

    if imgui.Begin("##amp_fixed_hud", nil, flags) then
        local dl = imgui.GetWindowDrawList()
        local p = imgui.GetWindowPos()
        local c_min = imgui.ImVec2(p.x + pad, p.y + pad)
        local c_max = imgui.ImVec2(c_min.x + w, c_min.y + h)

        dl:AddRectFilled(c_min, c_max, 0xF212060A, 10.0)
        dl:AddRect(c_min, c_max, color, 10.0, 15, 2.0)

        local tx = c_min.x + 20.0
        local ty1 = c_min.y + 10.0
        dl:AddText(imgui.ImVec2(tx, ty1), 0xFFFFFFFF, u8"MP Manager | ")
        local prefix_sz = imgui.CalcTextSize(u8"MP Manager | ")

        if is_err then
            dl:AddText(imgui.ImVec2(tx + prefix_sz.x, ty1), color, u8"Обнаружены ошибки в заполнении:")
            for i, err in ipairs(HUD.error_list) do
                local err_line = "- " .. tostring(err)
                dl:AddText(imgui.ImVec2(tx + 6.0, ty1 + 4.0 + 20.0 * i), 0xFFFF7777, u8(err_line))
            end
        else
            local ty2 = c_min.y + 30.0
            if HUD.mode == "countdown" then
                dl:AddText(imgui.ImVec2(tx + prefix_sz.x, ty1), color, u8"Телепорт открыт!")
                dl:AddText(imgui.ImVec2(tx, ty2), 0xFFB0A4A8, string.format(u8"До закрытия входа: [ %d сек. ]", math.max(0, math.ceil(remaining))))
            elseif HUD.mode == "saved_success" then
                dl:AddText(imgui.ImVec2(tx + prefix_sz.x, ty1), color, u8"Настройки сохранены!")
                dl:AddText(imgui.ImVec2(tx, ty2), 0xFFB0A4A8, u8"Все параметры успешно обновлены на сервере")
            elseif HUD.mode == "fetched_success" then
                dl:AddText(imgui.ImVec2(tx + prefix_sz.x, ty1), color, u8"Настройки получены!")
                dl:AddText(imgui.ImVec2(tx, ty2), 0xFFB0A4A8, u8"Данные мероприятия успешно загружены в меню")
            elseif HUD.mode == "stopped_manual" then
                dl:AddText(imgui.ImVec2(tx + prefix_sz.x, ty1), color, u8"Телепорт остановлен!")
                dl:AddText(imgui.ImVec2(tx, ty2), 0xFFB0A4A8, u8"Вы выключили телепорт на мероприятие")
            elseif HUD.mode == "closed_players" then
                dl:AddText(imgui.ImVec2(tx + prefix_sz.x, ty1), color, u8"Телепорт закрыт!")
                dl:AddText(imgui.ImVec2(tx, ty2), 0xFFB0A4A8, u8"Набрано необходимое количество игроков")
            end
        end
        imgui.End()
    end
end)

-- ==================== ОКНО МОНИТОРИНГА ====================
imgui.OnFrame(function() return UI.show_monitor[0] end, function(player)
    local resW, resH = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(640, 340), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2((resW - 640) / 2, (resH - 340) / 2), imgui.Cond.FirstUseEver)
    if imgui.Begin(u8"Мониторинг участников Дерби##MonitorDerbyWin", UI.show_monitor) then
        imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Игроки в зоне стрима:")
        imgui.Separator()

        imgui.BeginChild("##MonitorScrollList", imgui.ImVec2(0, 0), true)
        if #players_monitor_list == 0 then
            imgui.TextDisabled(u8"В зоне стрима нет игроков...")
        else
            for _, data in ipairs(players_monitor_list) do
                imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), u8(data.name))
                imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(0.75, 0.75, 0.75, 1), u8(data.status))
                imgui.SameLine()
                local col = data.is_in_mp and imgui.ImVec4(0.3, 0.9, 0.4, 1) or imgui.ImVec4(0.9, 0.3, 0.3, 1)
                imgui.TextColored(col, u8("| " .. data.mp_status))
            end
        end
        imgui.EndChild()
        imgui.End()
    end
end)

-- ==================== ГЛАВНОЕ ОКНО ====================
imgui.OnFrame(function() return UI.show[0] end, function(player)
    local resW, resH = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(920, 640), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2((resW - 920) / 2, (resH - 640) / 2), imgui.Cond.FirstUseEver)
    local flags = imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar
    if imgui.Begin("##MPAdmins_MainWindow", UI.show, flags) then
        imgui.BeginGroup()
        imgui.TextColored(imgui.ImVec4(0.85, 0.28, 0.35, 1.0), u8"MP ADMIN MANAGER")
        imgui.SameLine()
        imgui.TextDisabled(u8"| Единый центр проведения мероприятий")
        imgui.EndGroup()
        imgui.SameLine(imgui.GetWindowWidth() - 36)
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.25, 0.08, 0.12, 0.6))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.85, 0.25, 0.30, 0.9))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.65, 0.15, 0.20, 1.0))
        if imgui.Button("X##close_btn", imgui.ImVec2(24, 20)) then UI.show[0] = false end
        imgui.PopStyleColor(3)
        imgui.Separator()
        imgui.Spacing()
        imgui.BeginChild("##Sidebar", imgui.ImVec2(185, 0), true)
        imgui.TextDisabled(u8"РАЗДЕЛЫ")
        imgui.Spacing()
        local tabs = {
            { id = 3, name = u8"Меню /eventmenu" },
            { id = 5, name = u8"Оповещения /ao" },
            { id = 1, name = u8"Каталог МП" },
            { id = 2, name = u8"Доп. функции" },
            { id = 4, name = u8"Действия в радиусе" },
            { id = 6, name = u8"Раздача авто" },
            { id = 7, name = u8"Черный список" }
        }
        for _, t in ipairs(tabs) do
            local isSel = (UI.currentSidebar == t.id)
            local p = imgui.GetCursorScreenPos()
            local bSize = imgui.ImVec2(169, 32)

            if isSel then
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.28, 0.11, 0.17, 0.95))
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.14, 0.06, 0.09, 0.50))
            end
            if imgui.Button(t.name .. "##side_tab", bSize) then
                UI.currentSidebar = t.id
                if t.id == 1 then UI.current_mp = nil end
                if t.id == 3 and #Core.events_list == 0 and not Core.fetching_list then
                    Core.fetching_list = true
                    Core.active_dialog_id = -1
                    sampSendChat("/eventmenu")
                end
            end
            imgui.PopStyleColor()

            if isSel then
                local draw_list = imgui.GetWindowDrawList()
                draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + 3), imgui.ImVec2(p.x + 4, p.y + bSize.y - 3), imgui.GetColorU32Vec4(imgui.ImVec4(0.85, 0.28, 0.35, 1.0)), 2.0)
            end
        end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("##WorkArea", imgui.ImVec2(0, 0), true)

        -- ==================== ВКЛАДКА 3: МЕНЮ /EVENTMENU ====================
        if UI.currentSidebar == 3 then
            imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Управление мероприятием через /eventmenu и /ao")
            imgui.Separator()
            imgui.Spacing()

            local preview_slot = u8"Выберите мероприятие из списка сервера..."
            if #Core.events_list > 0 and Core.events_list[UI.selected_mp_idx[0] + 1] then
                local it = Core.events_list[UI.selected_mp_idx[0] + 1]
                preview_slot = string.format("[%d] %s", it.event_id, u8(it.title))
            end

            imgui.PushItemWidth(340)
            if imgui.BeginCombo("##select_server_mp", preview_slot) then
                if #Core.events_list == 0 then
                    imgui.TextDisabled(u8"Список пуст. Нажмите 'Обновить список'")
                else
                    for idx, it in ipairs(Core.events_list) do
                        local is_sel = (UI.selected_mp_idx[0] == idx - 1)
                        local itemText = string.format("[%d] %s##mp_srv_%d", it.event_id, u8(it.title), idx)
                        if imgui.Selectable(itemText, is_sel) then
                            UI.selected_mp_idx[0] = idx - 1
                        end
                    end
                end
                imgui.EndCombo()
            end
            imgui.PopItemWidth()

            imgui.SameLine()
            if imgui.Button(u8"Обновить список##fetch_list_btn", imgui.ImVec2(130, 26)) then
                Core.fetching_list = true
                Core.active_dialog_id = -1
                sampSendChat("/eventmenu")
            end

            imgui.SameLine()
            if imgui.Button(u8"Считать с сервера##fetch_st_btn", imgui.ImVec2(140, 26)) then
                Core.fetchSettings()
            end

            imgui.Spacing()

            -- БЛОК ПРЕСЕТОВ
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.16, 0.07, 0.11, 0.7))
            imgui.BeginChild("##PresetsManagerBlock", imgui.ImVec2(-1, 72), true)
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8"Быстрые конфигурации (Пресеты настроек):")

            local cur_preset_name = PresetsList[UI.selected_preset_idx[0] + 1] or u8"Нет пресетов"
            imgui.PushItemWidth(220)
            if imgui.BeginCombo("##preset_selector", u8(cur_preset_name)) then
                for idx, pName in ipairs(PresetsList) do
                    local is_sel = (UI.selected_preset_idx[0] == idx - 1)
                    if imgui.Selectable(u8(pName), is_sel) then
                        UI.selected_preset_idx[0] = idx - 1
                    end
                end
                imgui.EndCombo()
            end
            imgui.PopItemWidth()

            imgui.SameLine()
            if imgui.Button(u8"Применить конфиг", imgui.ImVec2(130, 24)) then
                if PresetsList[UI.selected_preset_idx[0] + 1] then
                    applyPreset(PresetsList[UI.selected_preset_idx[0] + 1])
                    sendMsg(C.GREEN, "Конфиг '" .. PresetsList[UI.selected_preset_idx[0] + 1] .. "' успешно применен в форму!")
                end
            end

            imgui.SameLine()
            imgui.PushItemWidth(150)
            imgui.InputTextWithHint("##new_pr_name", u8("Имя нового конфига"), B.new_preset_name, 64)
            imgui.PopItemWidth()

            imgui.SameLine()
            if imgui.Button(u8"Сохранить##save_preset_btn", imgui.ImVec2(80, 24)) then
                local prName = u8:decode(ffi.string(B.new_preset_name))
                if #prName == 0 and PresetsList[UI.selected_preset_idx[0] + 1] then
                    prName = PresetsList[UI.selected_preset_idx[0] + 1]
                end
                if saveCurrentAsPreset(prName) then
                    imgui.StrCopy(B.new_preset_name, "")
                    sendMsg(C.GREEN, "Конфиг '" .. prName .. "' успешно сохранен!")
                else
                    sendMsg(C.WARN, "Введите название для сохранения конфига!")
                end
            end

            imgui.SameLine()
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.65, 0.15, 0.20, 0.8))
            if imgui.Button(u8"Удалить", imgui.ImVec2(70, 24)) then
                local delName = PresetsList[UI.selected_preset_idx[0] + 1]
                if delName and Presets[delName] then
                    Presets[delName] = nil
                    savePresetsToFile()
                    refreshPresetsList()
                    UI.selected_preset_idx[0] = 0
                    sendMsg(C.RED, "Конфиг '" .. delName .. "' удален.")
                end
            end
            imgui.PopStyleColor()

            imgui.EndChild()
            imgui.PopStyleColor()

            imgui.Spacing()

            -- Скроллируемая форма параметров
            imgui.BeginChild("##scrollable_event_form", imgui.ImVec2(-1, -66), true)

            imgui.TextColored(imgui.ImVec4(0.95, 0.85, 0.88, 1.0), u8"Основные параметры МП:")
            imgui.Spacing()

            imgui.Text(u8"Название МП:")
            imgui.PushItemWidth(240)
            imgui.InputText("##title_event_in", B.ev_new_title, ffi.sizeof(B.ev_new_title))
            imgui.PopItemWidth()

            imgui.SameLine()
            imgui.Text(u8"Приз:")
            imgui.PushItemWidth(170)
            imgui.InputText("##prize_event_in", B.ev_prize, ffi.sizeof(B.ev_prize))
            imgui.PopItemWidth()

            imgui.SameLine()
            if imgui.Button(u8"Сгенерировать шаблон /ao", imgui.ImVec2(210, 24)) then
                imgui.StrCopy(B.ev_broadcast, u8(generateBroadcastTemplate()))
            end

            imgui.Spacing()
            imgui.Text(u8"Сообщение на весь сервер (/eventmenu):")
            imgui.PushItemWidth(-1)
            imgui.InputText("##ao_event_in", B.ev_broadcast, ffi.sizeof(B.ev_broadcast))
            imgui.PopItemWidth()

            imgui.Spacing()
            imgui.Columns(2, "ev_main_cols", false)

            imgui.Text(u8"Лимит игроков:"); imgui.SameLine(220); imgui.PushItemWidth(100); imgui.InputInt("##ev_lim", B.ev_limit, 0); imgui.PopItemWidth()
            imgui.Text(u8"Время действия ТП (сек):"); imgui.SameLine(220); imgui.PushItemWidth(100); imgui.InputInt("##ev_tpt", B.ev_tp_time, 0); imgui.PopItemWidth()
            imgui.Text(u8"Пароль для входа:"); imgui.SameLine(220); imgui.PushItemWidth(100); imgui.InputText("##ev_pass", B.ev_password, ffi.sizeof(B.ev_password)); imgui.PopItemWidth()

            imgui.NextColumn()

            imgui.Text(u8"Выдать HP (0-250):"); imgui.SameLine(220); imgui.PushItemWidth(100); imgui.InputInt("##ev_hp", B.ev_health, 0); imgui.PopItemWidth()
            imgui.Text(u8"Выдать броню (0-250):"); imgui.SameLine(220); imgui.PushItemWidth(100); imgui.InputInt("##ev_arm", B.ev_armour, 0); imgui.PopItemWidth()
            imgui.Text(u8"ID скина (1-1120):"); imgui.SameLine(220); imgui.PushItemWidth(100); imgui.InputInt("##ev_skin", B.ev_skin, 0); imgui.PopItemWidth()

            imgui.Columns(1)

            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()

            if imgui.CollapsingHeader(u8"Выдача оружия и патронов") then
                imgui.Text(u8"Оружие:")
                imgui.PushItemWidth(320)
                if imgui.BeginCombo("##ev_wp_combo", WEAPON_NAMES[B.ev_weapon_sel[0] + 1]) then
                    for i, name in ipairs(WEAPON_NAMES) do
                        if imgui.Selectable(name, B.ev_weapon_sel[0] == i - 1) then
                            B.ev_weapon_sel[0] = i - 1
                        end
                    end
                    imgui.EndCombo()
                end
                imgui.PopItemWidth()
                imgui.SameLine()
                imgui.Text(u8"Патроны:")
                imgui.SameLine()
                imgui.PushItemWidth(120)
                imgui.InputInt("##ev_ammo", B.ev_ammo_count, 0)
                imgui.PopItemWidth()
            end

            if imgui.CollapsingHeader(u8"Правила диалога мероприятия") then
                imgui.Text(u8"Строка 1:"); imgui.PushItemWidth(-1); imgui.InputText("##r1_in", B.ev_rule1, ffi.sizeof(B.ev_rule1)); imgui.PopItemWidth()
                imgui.Text(u8"Строка 2:"); imgui.PushItemWidth(-1); imgui.InputText("##r2_in", B.ev_rule2, ffi.sizeof(B.ev_rule2)); imgui.PopItemWidth()
                imgui.Text(u8"Строка 3:"); imgui.PushItemWidth(-1); imgui.InputText("##r3_in", B.ev_rule3, ffi.sizeof(B.ev_rule3)); imgui.PopItemWidth()
            end

            if imgui.CollapsingHeader(u8"Точки спавна участников") then
                imgui.Text(u8"Количество точек:")
                imgui.SameLine(180)
                imgui.PushItemWidth(120)
                imgui.InputInt("##ev_sp_cnt", B.ev_sp_count, 0)
                imgui.PopItemWidth()

                imgui.Text(u8"Алгоритм распределения:")
                imgui.PushItemWidth(320)
                if imgui.BeginCombo("##ev_sp_alg", SPAWN_TYPES[B.ev_sp_type[0] + 1]) then
                    for i, name in ipairs(SPAWN_TYPES) do
                        if imgui.Selectable(name, B.ev_sp_type[0] == i - 1) then
                            B.ev_sp_type[0] = i - 1
                        end
                    end
                    imgui.EndCombo()
                end
                imgui.PopItemWidth()

                imgui.Spacing()
                imgui.TextDisabled(u8"Запись слота спавна на координаты вашего персонажа:")
                local max_slots = (B.ev_sp_type[0] == 0) and 1 or 10
                for slot = 1, max_slots do
                    local active = (B.ev_sp_slot[0] == slot)
                    if active then imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.85, 0.28, 0.35, 1.0)) end
                    if imgui.Button(string.format(u8"Слот #%d", slot), imgui.ImVec2(62, 26)) then
                        B.ev_sp_slot[0] = active and 0 or slot
                    end
                    if active then imgui.PopStyleColor() end
                    if slot ~= 5 and slot ~= 10 and slot ~= max_slots then imgui.SameLine() end
                end
            end

            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()

            imgui.TextColored(imgui.ImVec4(0.95, 0.85, 0.88, 1.0), u8"Модификаторы и правила входа:")
            imgui.Spacing()

            local toggles_grid = {
                { "##sw_pvp", Opt.pvp_dmg, u8"Запрет урона" },
                { "##sw_acc", Opt.accessories, u8"Аксессуары" },
                { "##sw_guards", Opt.guards, u8"Охранники" },
                { "##sw_coll", Opt.collision, u8"Коллизия" },
                { "##sw_car", Opt.lic_car, u8"Лиц. авто" },
                { "##sw_moto", Opt.lic_moto, u8"Лиц. мото" },
                { "##sw_boat", Opt.lic_boat, u8"Лиц. лодки" },
                { "##sw_fly", Opt.lic_fly, u8"Лиц. полёты" },
                { "##sw_take_guns", Opt.take_guns, u8"Забрать оружие" },
                { "##sw_re_tp", Opt.re_tp, u8"Повторный ТП" },
                { "##sw_launcher", Opt.launcher, u8"Лаунчер онли" }
            }

            for i = 1, #toggles_grid, 3 do
                local c1, v1 = ToggleSwitch(toggles_grid[i][1], toggles_grid[i][2][0])
                if c1 then toggles_grid[i][2][0] = v1 end
                imgui.SameLine()
                imgui.Text(toggles_grid[i][3])

                if toggles_grid[i+1] then
                    imgui.SameLine(230)
                    local c2, v2 = ToggleSwitch(toggles_grid[i+1][1], toggles_grid[i+1][2][0])
                    if c2 then toggles_grid[i+1][2][0] = v2 end
                    imgui.SameLine()
                    imgui.Text(toggles_grid[i+1][3])
                end

                if toggles_grid[i+2] then
                    imgui.SameLine(460)
                    local c3, v3 = ToggleSwitch(toggles_grid[i+2][1], toggles_grid[i+2][2][0])
                    if c3 then toggles_grid[i+2][2][0] = v3 end
                    imgui.SameLine()
                    imgui.Text(toggles_grid[i+2][3])
                end
                imgui.Spacing()
            end

            imgui.EndChild()
            imgui.Spacing()

            if Core.running then
                imgui.TextColored(imgui.ImVec4(1.0, 0.7, 0.2, 1.0), u8"Синхронизация параметров с сервером...")
            else
                if imgui.Button(u8"ПРИМЕНИТЬ НАСТРОЙКИ В /EVENTMENU", imgui.ImVec2(340, 32)) then
                    Core.applySettings()
                end

                imgui.SameLine()

                if HUD.is_running_now then
                    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.75, 0.15, 0.20, 0.90))
                    if imgui.Button(u8"ОСТАНОВИТЬ ТЕЛЕПОРТ НА МП", imgui.ImVec2(340, 32)) then
                        Core.toggleEvent()
                    end
                    imgui.PopStyleColor()
                else
                    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.20, 0.60, 0.25, 0.90))
                    if imgui.Button(u8"ОТКРЫТЬ ТЕЛЕПОРТ (СТАРТ МП + /AO)", imgui.ImVec2(340, 32)) then
                        Core.toggleEvent()
                    end
                    imgui.PopStyleColor()
                end
            end

        -- ==================== ВКЛАДКА 5: СООБЩЕНИЯ /AO И ПОБЕДИТЕЛЬ ====================
        elseif UI.currentSidebar == 5 then
            imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Оповещения в общий чат (/ao) и оглашение победителя")
            imgui.Separator()
            imgui.Spacing()

            imgui.TextColored(imgui.ImVec4(0.2, 1.0, 0.4, 1.0), u8"Оглашение победителя МП по ID:")
            imgui.TextDisabled(u8"Скрипт сам найдет ник игрока и подставит текущее название мероприятия:")
            imgui.Spacing()

            imgui.Text(u8"ID победителя:")
            imgui.SameLine()
            imgui.PushItemWidth(100)
            imgui.InputText("##win_id_input", B.winner_input_id, 16, imgui.InputTextFlags.CharsDecimal)
            imgui.PopItemWidth()

            imgui.SameLine()
            if imgui.Button(u8"ОБЪЯВИТЬ ПОБЕДИТЕЛЯ В /AO", imgui.ImVec2(240, 28)) then
                announceWinner(ffi.string(B.winner_input_id))
            end
            imgui.SameLine()
            imgui.TextDisabled(u8"(Команда в чат: /mpwin [ID])")

            local win_name_prev = getEffectiveEventName()
            local id_prev = ffi.string(B.winner_input_id)
            local nick_prev = "Nick_Name"
            if tonumber(id_prev) and sampIsPlayerConnected(tonumber(id_prev)) then
                nick_prev = sampGetPlayerNickname(tonumber(id_prev))
            end
            local preview_win = string.format('/ao [МП] Победителем МП "%s" стал %s[%s]! Поздравляем!', win_name_prev, nick_prev, id_prev ~= "" and id_prev or "ID")
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8("Пример: " .. preview_win))

            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()

            imgui.TextColored(imgui.ImVec4(0.95, 0.85, 0.88, 1.0), u8"Ручной анонс начала мероприятия:")
            imgui.Spacing()

            local previewBroadcast = generateBroadcastTemplate()
            imgui.Text(u8"Текст сообщения:")
            imgui.TextColored(imgui.ImVec4(0.3, 0.9, 0.4, 1.0), u8(previewBroadcast))
            imgui.Spacing()

            if imgui.Button(u8"ОТПРАВИТЬ АНОНС В /ao СЕЙЧАС", imgui.ImVec2(290, 32)) then
                sampSendChat("/ao " .. previewBroadcast)
                addEventLog("Ручная отправка анонса в /ao")
            end

        -- ==================== КАТАЛОГ МП ====================
        elseif UI.currentSidebar == 1 then
            if UI.current_mp == nil then
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Каталог мероприятий")
                imgui.TextDisabled(u8"Кликните по карточке для управления, настройки и озвучки правил")
                imgui.Separator()
                imgui.Spacing()
                DrawGameCard("derby", "Дерби", "Выживание на машинах.\nСпавн без авто или при низком HP", st.derbyActive, function() UI.current_mp = "derby" end)
                imgui.SameLine(290)
                DrawGameCard("sectors", "Секторы", "Игрокам нужно встать в безопасный сектор.\nКто не успел за 3 секунды — спавн", (st.sectorSetupMode or st.sectorRoundRun), function() UI.current_mp = "sectors" end)
                imgui.Spacing()
                DrawGameCard("rlgl", "Светофор", "Бег на зеленый, стоп на красный.\nЛюбое движение на красный — спавн", st.enabled, function() UI.current_mp = "rlgl" end)
                imgui.SameLine(290)
                DrawGameCard("chairs", "Стульчики", "Музыкальный раунд на парковке.\nКто не занял место по команде — спавн", (st.chairs or st.stulActive), function() UI.current_mp = "chairs" end)
                imgui.Spacing()
                DrawGameCard("dm", "DeathMatch", "10-минутная перестрелка.\nАвто-подсчет фрагов и авто-респавн", st.dmActive, function() UI.current_mp = "dm" end)
                imgui.SameLine(290)
                DrawGameCard("potato", "Горячая картошка", "Передача скина за 10 секунд.\nИгрок с картошкой по таймеру выбывает", st.potatoActive, function() UI.current_mp = "potato" end)

            elseif UI.current_mp == "derby" then
                if imgui.Button(u8"< Назад в каталог", imgui.ImVec2(150, 26)) then UI.current_mp = nil end
                imgui.Separator()
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Управление мероприятием: Дерби")
                imgui.Spacing()
                if imgui.Button(u8"Озвучить правила в /smp##derby_rules", imgui.ImVec2(280, 28)) then announceRules("derby") end
                imgui.SameLine()
                if imgui.Button(u8"Открыть окно Мониторинга", imgui.ImVec2(240, 28)) then UI.show_monitor[0] = not UI.show_monitor[0] end
                imgui.Spacing()
                DrawRulesEditor("derby")
                imgui.Spacing()
                local c_db_sw, _ = ToggleSwitch("##sw_derby", st.derbyActive)
                if c_db_sw then toggleDerby() end
                imgui.SameLine()
                imgui.Text(st.derbyActive and u8"МП Дерби ЗАПУЩЕНО" or u8"МП Дерби ВЫКЛЮЧЕНО")
                imgui.Spacing()
                imgui.Separator()
                imgui.Spacing()
                imgui.Columns(2, "derby_cols", false)
                imgui.Text(u8"Параметры выбывания:")
                imgui.Text(u8"Порог HP автомобиля:")
                imgui.PushItemWidth(200)
                if imgui.SliderInt("##derby_hp", B.derby_hp, 250, 800, "%d HP") then
                    st.derbyHpThreshold = B.derby_hp[0]
                    saveConfig()
                end
                imgui.PopItemWidth()
                local ch_gv, val_gv = ToggleSwitch("##sw_auto_give_v", st.derbyAutoGiveVeh)
                if ch_gv then st.derbyAutoGiveVeh = val_gv; saveConfig() end
                imgui.SameLine()
                imgui.Text(u8"Авто-выдача авто участникам")
                if st.derbyAutoGiveVeh then
                    if RadioButton(u8"Рандомное авто##rg", st.derbyGiveMode == 0) then st.derbyGiveMode = 0; saveConfig() end
                    imgui.SameLine()
                    if RadioButton(u8"Выбранное из списка##sg", st.derbyGiveMode == 1) then st.derbyGiveMode = 1; saveConfig() end
                    if st.derbyGiveMode == 1 then
                        local cur_car_id = cars_list[st.derbySelectedCar + 1] or 400
                        local preview = string.format("%d | %s", cur_car_id, vehicle_names[cur_car_id] or "Unknown")
                        imgui.PushItemWidth(240)
                        if imgui.BeginCombo("##car_combo_derby", u8(preview)) then
                            imgui.InputTextWithHint("##search_car", u8("Поиск..."), B.car_search, 64)
                            local sText = string.lower(ffi.string(B.car_search))
                            imgui.BeginChild("##car_scroll", imgui.ImVec2(0, 160), false)
                            for idx, id in ipairs(cars_list) do
                                local full_name = string.format("%d | %s", id, vehicle_names[id] or "Unknown")
                                if sText == "" or string.find(string.lower(full_name), sText, 1, true) then
                                    local is_selected = (st.derbySelectedCar == idx - 1)
                                    if imgui.Selectable(u8(full_name), is_selected) then
                                        st.derbySelectedCar = idx - 1
                                        saveConfig()
                                    end
                                end
                            end
                            imgui.EndChild()
                            imgui.EndCombo()
                        end
                        imgui.PopItemWidth()
                    end
                end
                imgui.Spacing()
                local ch_int, val_int = ToggleSwitch("##derby_check_int", st.derbyCheckInt)
                if ch_int then st.derbyCheckInt = val_int; saveConfig() end
                imgui.SameLine()
                imgui.Text(u8"Привязка к интерьеру 85")
                imgui.NextColumn()
                imgui.Text(u8"Логи действий Дерби:")
                imgui.BeginChild("##DerbyLogsFrame", imgui.ImVec2(0, 220), true)
                if #event_logs == 0 then
                    imgui.TextDisabled(u8"Логи пока пусты...")
                else
                    for _, log in ipairs(event_logs) do
                        imgui.TextWrapped(u8(log))
                    end
                end
                imgui.EndChild()
                imgui.Columns(1)

            elseif UI.current_mp == "sectors" then
                if imgui.Button(u8"< Назад в каталог", imgui.ImVec2(150, 26)) then UI.current_mp = nil end
                imgui.Separator()
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Мероприятие: Секторы (Зараженные зоны)")
                imgui.Spacing()
                if imgui.Button(u8"Озвучить правила в /smp##sec_rules", imgui.ImVec2(-1, 30)) then announceRules("sectors") end
                imgui.Spacing()
                DrawRulesEditor("sectors")
                imgui.Spacing()
                imgui.Columns(2, "sec_sub_cols", false)
                imgui.Text(u8"Разметка 4 секторов:")
                local c_s_setup, _ = ToggleSwitch("##sw_sec_mode", st.sectorSetupMode)
                if c_s_setup then toggleSectorSetup() end
                imgui.SameLine()
                imgui.Text(st.sectorSetupMode and u8"Разметка секторов ВКЛ" or u8"Выключена")
                imgui.Spacing()
                imgui.Text(u8"Разметка общей зоны МП:")
                local c_z_setup, _ = ToggleSwitch("##sw_zone_mode", st.stZoneSetupMode)
                if c_z_setup then toggleStZoneSetup() end
                imgui.SameLine()
                imgui.Text(st.stZoneSetupMode and u8"Разметка зоны ВКЛ" or u8"Выключена")
                imgui.NextColumn()
                imgui.Text(u8"Запуск раунда секторов:")
                if imgui.Button(u8"Случайный БЕЗОПАСНЫЙ сектор", imgui.ImVec2(240, 28)) then runSectorRound(true, nil) end
                if imgui.Button(u8"Случайный ЗАРАЖЕННЫЙ сектор", imgui.ImVec2(240, 28)) then runSectorRound(false, nil) end
                imgui.Spacing()
                imgui.Text(u8"Удалить сектор:")
                for _, letter in ipairs(SECTOR_NAMES) do
                    imgui.SameLine()
                    if imgui.Button(letter .. "##del_btn", imgui.ImVec2(30, 22)) then deleteSector(letter) end
                end
                imgui.Columns(1)

            elseif UI.current_mp == "rlgl" then
                if imgui.Button(u8"< Назад в каталог", imgui.ImVec2(150, 26)) then UI.current_mp = nil end
                imgui.Separator()
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Мероприятие: Светофор (Красный / Зеленый)")
                imgui.Spacing()
                if imgui.Button(u8"Озвучить правила в /smp##rlgl_rules", imgui.ImVec2(-1, 30)) then announceRules("rlgl") end
                imgui.Spacing()
                DrawRulesEditor("rlgl")
                imgui.Spacing()
                local c_rl, _ = ToggleSwitch("##sw_rlgl", st.enabled)
                if c_rl then toggleRLGL() end
                imgui.SameLine()
                imgui.Text(st.enabled and u8"Светофор ВКЛЮЧЕН" or u8"Светофор ВЫКЛЮЧЕН")
                imgui.Spacing()
                if st.enabled then
                    if imgui.Button(u8"Подать сигнал: ЗЕЛЕНЫЙ СВЕТ", imgui.ImVec2(240, 32)) then sendRLGLSignal(true) end
                    imgui.SameLine()
                    if imgui.Button(u8"Подать сигнал: КРАСНЫЙ СВЕТ", imgui.ImVec2(240, 32)) then sendRLGLSignal(false) end
                end

            elseif UI.current_mp == "chairs" then
                if imgui.Button(u8"< Назад в каталог", imgui.ImVec2(150, 26)) then UI.current_mp = nil end
                imgui.Separator()
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Мероприятие: Стульчики (Зоны парковки)")
                imgui.Spacing()
                if imgui.Button(u8"Озвучить правила в /smp##chairs_rules", imgui.ImVec2(-1, 30)) then announceRules("chairs") end
                imgui.Spacing()
                DrawRulesEditor("chairs")
                imgui.Spacing()
                local c_st, _ = ToggleSwitch("##sw_stul_round", st.stulActive)
                if c_st then toggleStulGame() end
                imgui.SameLine()
                imgui.Text(st.stulActive and u8"Раунд Стульчиков ИДЕТ" or u8"Раунд остановлен")
                imgui.Spacing()
                imgui.Text(u8"Активировать зоны (пример: 1-5, 8, 10-15):")
                imgui.PushItemWidth(250)
                imgui.InputText("##in_zones", B.zones, 128)
                imgui.PopItemWidth()
                imgui.SameLine()
                if imgui.Button(u8"Применить зоны", imgui.ImVec2(140, 24)) then applyChairsZones(ffi.string(B.zones)) end
                imgui.Spacing()
                if imgui.Button(u8"Сбросить все зоны", imgui.ImVec2(160, 26)) then resetChairsZones() end

            elseif UI.current_mp == "dm" then
                if imgui.Button(u8"< Назад в каталог", imgui.ImVec2(150, 26)) then UI.current_mp = nil end
                imgui.Separator()
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Мероприятие: DeathMatch Арена")
                imgui.Spacing()
                if imgui.Button(u8"Озвучить правила в /smp##dm_rules", imgui.ImVec2(-1, 30)) then announceRules("dm") end
                imgui.Spacing()
                DrawRulesEditor("dm")
                imgui.Spacing()
                local c_dm_sw, _ = ToggleSwitch("##sw_dm", st.dmActive)
                if c_dm_sw then toggleDM() end
                imgui.SameLine()
                imgui.Text(st.dmActive and u8"МП DeathMatch ЗАПУЩЕНО" or u8"МП DeathMatch ВЫКЛЮЧЕНО")

            elseif UI.current_mp == "potato" then
                if imgui.Button(u8"< Назад в каталог", imgui.ImVec2(150, 26)) then UI.current_mp = nil end
                imgui.Separator()
                imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Мероприятие: Горячая картошка")
                imgui.Spacing()
                if imgui.Button(u8"Озвучить правила в /smp##potato_rules", imgui.ImVec2(-1, 30)) then announceRules("potato") end
                imgui.Spacing()
                DrawRulesEditor("potato")
                imgui.Spacing()
                local c_pt_sw, _ = ToggleSwitch("##sw_potato", st.potatoActive)
                if c_pt_sw then togglePotato() end
                imgui.SameLine()
                imgui.Text(st.potatoActive and u8"МП 'Картошка' АКТИВНО" or u8"Картошка ВЫКЛЮЧЕНА")
            end

        -- ==================== ДОП. ФУНКЦИИ ====================
        elseif UI.currentSidebar == 2 then
            imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Дополнительные функции и контроль")
            imgui.Separator()
            imgui.Spacing()
            local c_vd_sw, _ = ToggleSwitch("##sw_voda_addon", st.vodaActive)
            if c_vd_sw then toggleVoda() end
            imgui.SameLine()
            imgui.Text(st.vodaActive and u8"Авто-спавн из воды ВКЛЮЧЕН" or u8"Авто-спавн из воды ВЫКЛЮЧЕН")
            imgui.Text(u8"Причина спавна из воды в /pm:")
            imgui.PushItemWidth(360)
            if imgui.InputText("##voda_reason_in", B.voda_reason, 256) then
                st.vodaReason = u8:decode(ffi.string(B.voda_reason))
                saveConfig()
            end
            imgui.PopItemWidth()
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            local ch_m, val_m = ToggleSwitch("##sw_auto_mask", st.antimask)
            if ch_m then st.antimask = val_m; saveConfig() end
            imgui.SameLine()
            imgui.Text(u8"Авто-спавн за надевание МАСКИ")
            imgui.SameLine(480)
            if imgui.Button(u8"Заспавнить всех в масках рядом", imgui.ImVec2(240, 22)) then
                runAntiMaskScan()
            end
            local ch_a, val_a = ToggleSwitch("##sw_auto_arm", st.autosparm)
            if ch_a then st.autosparm = val_a; saveConfig() end
            imgui.SameLine()
            imgui.Text(u8"Авто-спавн за пополнение БРОНИ")
            local ch_h, val_h = ToggleSwitch("##sw_auto_heal", st.autospheal)
            if ch_h then st.autospheal = val_h; saveConfig() end
            imgui.SameLine()
            imgui.Text(u8"Авто-спавн за ХИЛЛ (аптечки/чипсы/укроп)")
            local ch_g, val_g = ToggleSwitch("##sw_auto_gun", st.autospgun)
            if ch_g then st.autospgun = val_g; saveConfig() end
            imgui.SameLine()
            imgui.Text(u8"Авто-разоружение (/weap) за доставание оружия")

        -- ==================== В РАДИУС ====================
        elseif UI.currentSidebar == 4 then
            imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Массовые команды в радиусе")
            imgui.Separator()
            imgui.Spacing()
            imgui.Text(u8"Радиус действия команд:")
            imgui.PushItemWidth(300)
            if imgui.SliderInt("##rad_cmd_sl", B.radius_cmd, 5, 150, "%d м") then
                st.radiusCmd = B.radius_cmd[0]
                saveConfig()
            end
            imgui.PopItemWidth()
            imgui.Spacing()
            local rad = st.radiusCmd
            if imgui.Button(u8"Выдать 100 HP", imgui.ImVec2(180, 30)) then sampSendChat("/hpall " .. rad) end
            imgui.SameLine()
            if imgui.Button(u8"Выдать 100 Armour", imgui.ImVec2(180, 30)) then sampSendChat("/armourall " .. rad) end
            imgui.SameLine()
            if imgui.Button(u8"Выдать голод всех", imgui.ImVec2(180, 30)) then sampSendChat("/eatall " .. rad) end
            if imgui.Button(u8"Обнулить броню", imgui.ImVec2(180, 30)) then sampSendChat("/unarmourall " .. rad) end
            imgui.SameLine()
            if imgui.Button(u8"Заморозить всех", imgui.ImVec2(180, 30)) then sampSendChat("/freezeall " .. rad) end
            imgui.SameLine()
            if imgui.Button(u8"Разморозить всех", imgui.ImVec2(180, 30)) then sampSendChat("/unfreezeall " .. rad) end
            if imgui.Button(u8"Выдать анти-розыск", imgui.ImVec2(180, 30)) then sampSendChat("/azakon " .. rad) end
            imgui.SameLine()
            if imgui.Button(u8"Забрать все оружие", imgui.ImVec2(180, 30)) then sampSendChat("/weapall " .. rad) end

        -- ==================== РАЗДАЧА АВТО ====================
        elseif UI.currentSidebar == 6 then
            imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Раздача транспорта участникам")
            imgui.Separator()
            imgui.Spacing()
            imgui.Text(u8"Радиус выдачи вокруг администратора:")
            imgui.PushItemWidth(180)
            if imgui.InputText("##rad_veh", B.rveh_radius, 16) then saveConfig() end
            imgui.PopItemWidth()
            imgui.Text(u8"ID модели автомобиля:")
            imgui.PushItemWidth(180)
            if imgui.InputText("##model_veh", B.rveh_model, 16) then saveConfig() end
            imgui.PopItemWidth()
            imgui.Spacing()
            if imgui.Button(u8"Начать раздачу транспорта", imgui.ImVec2(220, 32)) then
                sampSendChat(string.format("/rplveh %s %s", ffi.string(B.rveh_radius), ffi.string(B.rveh_model)))
            end

        -- ==================== ЧЁРНЫЙ СПИСОК ====================
        elseif UI.currentSidebar == 7 then
            imgui.TextColored(imgui.ImVec4(0.9, 0.4, 0.45, 1.0), u8"Черный список участников")
            imgui.Separator()
            imgui.Spacing()
            imgui.Text(u8"ID игрока онлайн:")
            imgui.PushItemWidth(120)
            imgui.InputText("##in_bl_id", B.bl_id, 32)
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button(u8"Добавить / Удалить по ID", imgui.ImVec2(180, 24)) then
                local id = tonumber(ffi.string(B.bl_id))
                if id and sampIsPlayerConnected(id) then
                    local nick = sampGetPlayerNickname(id)
                    if st.blacklist[nick] then
                        st.blacklist[nick] = nil
                        sendMsg(C.GREEN, "Удален из ЧС: " .. nick)
                    else
                        st.blacklist[nick] = true
                        sendMsg(C.RED, "Добавлен в ЧС: " .. nick)
                    end
                    saveConfig()
                else
                    sendMsg(C.WARN, "Игрок не найден онлайн!")
                end
            end
            imgui.Spacing()
            imgui.BeginChild("##bl_frame", imgui.ImVec2(0, 200), true)
            for nick, active in pairs(st.blacklist) do
                if active then 
                    imgui.BulletText(nick)
                    imgui.SameLine(imgui.GetWindowWidth() - 35)
                    if imgui.SmallButton("X##del_" .. nick) then
                        st.blacklist[nick] = nil
                        saveConfig()
                    end
                end
            end
            imgui.EndChild()
        end
        imgui.EndChild()
        imgui.End()
    end
end)

-- ==================== MAIN ====================
function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    math.randomseed(os.time())
    loadConfig()
    loadPresetsFromFile()

    -- Проверка наличия обновлений при запуске
    checkScriptUpdate()

    local mpPts, sumX, sumY = {}, 0, 0
    for _, p in ipairs(RAW_MP_ZONE) do
        table.insert(mpPts, { x = p.x, y = p.y, z = CFG.DEFAULT_Z })
        sumX, sumY = sumX + p.x, sumY + p.y
    end
    mpZoneData = { points = mpPts, center = { x = sumX / 4, y = sumY / 4, z = CFG.DEFAULT_Z } }
    for i, d in ipairs(Z_DATA) do
        pZones[i] = {
            id = i,
            points = {
                { y = d[1], x = d[2], z = CFG.DEFAULT_Z }, { y = d[3], x = d[4], z = CFG.DEFAULT_Z },
                { y = d[5], x = d[6], z = CFG.DEFAULT_Z }, { y = d[7], x = d[8], z = CFG.DEFAULT_Z }
            },
            center = { x = (d[2] + d[4] + d[6] + d[8]) / 4, y = (d[1] + d[3] + d[5] + d[7]) / 4, z = CFG.DEFAULT_Z }
        }
    end

    fontText   = renderCreateFont("Arial", 12, 13)
    fontHUD    = renderCreateFont("Arial", 14, 15)
    fontSector = renderCreateFont("Arial", 16, 17)
    screenW, screenH = getScreenResolution()
    st.curInt  = getActiveInterior()
    local r, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if r then 
        st.myId = myId
        st.myNick = sampGetPlayerNickname(myId) 
    end

    sampRegisterChatCommand("amp", function() 
        UI.show[0] = not UI.show[0] 
        if UI.show[0] and #Core.events_list == 0 and not Core.fetching_list then
            Core.fetching_list = true
            Core.active_dialog_id = -1
            sampSendChat("/eventmenu")
        end
    end)

    sampRegisterChatCommand("mpupdate", function()
        if UpdateUI.new_vers ~= "" then
            UpdateUI.show[0] = not UpdateUI.show[0]
        else
            checkScriptUpdate()
            sendMsg(C.WARN, "Проверка обновлений запущена...")
        end
    end)

    checkScriptUpdate(false)

    -- Ручная проверка по команде /checkupdate
    sampRegisterChatCommand("checkupdate", function()
        checkScriptUpdate(true)
    end)

    sampRegisterChatCommand("mpwin", announceWinner)
    sampRegisterChatCommand("win", announceWinner)
    sampRegisterChatCommand("sector", toggleSectorSetup)
    sampRegisterChatCommand("stzone", toggleStZoneSetup)
    sampRegisterChatCommand("dsector", function(arg) deleteSector(arg) end)
    sampRegisterChatCommand("stsector", function() runSectorRound(true, nil) end)
    sampRegisterChatCommand("voda", toggleVoda)
    sampRegisterChatCommand("dm", toggleDM)
    sampRegisterChatCommand("db", toggleDerby)
    sampRegisterChatCommand("lapi", togglePotato)
    sampRegisterChatCommand("sfon", toggleRLGL)
    sampRegisterChatCommand("zs", function() sendRLGLSignal(true) end)
    sampRegisterChatCommand("ks", function() sendRLGLSignal(false) end)
    sampRegisterChatCommand("zones", applyChairsZones)
    sampRegisterChatCommand("dzones", removeChairsZones)
    sampRegisterChatCommand("czones", resetChairsZones)
    sampRegisterChatCommand("antimask", runAntiMaskScan)

    sendMsg(C.GREEN, "Скрипт успешно запущен! Меню: {FFFFFF}/amp{00FF00} | Объявить победу: {FFFF00}/mpwin [ID]")

    while true do
        wait(0)
        local curTime = os.clock()
        if st.enabled then drawHUD(curTime) end
        if st.chairs then drawMPZone(); drawZones() end
        if st.dmActive then drawDMHUD() end
        drawSectorsAndSTZone()
    end
end
