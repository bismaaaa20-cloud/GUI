
--// XevoraHub Loader | Luarmor + XevoraUI
--// Default: gunakan sistem key Luarmor.
--// Mode uji tanpa key hanya aktif jika XevoraHubTestMode = true.

local CONFIG = {
    Registry = "https://raw.githubusercontent.com/bismaaaa20-cloud/GUI/refs/heads/main/Games.lua",
    UI = "https://raw.githubusercontent.com/bismaaaa20-cloud/GUI/refs/heads/main/Main%20UI",
    SDK = "https://sdkapi-public.luarmor.net/library.lua",
    FreeLoader = "https://api.luarmor.net/files/v4/loaders/",
    KeyFolder = "XevoraHub",
    KeyFile = "XevoraHub/key.txt",
}

local env = (getgenv and getgenv()) or _G
local StarterGui = game:GetService("StarterGui")

local MESSAGES = {
    KEY_VALID = "Key valid.",
    KEY_EXPIRED = "Key sudah kedaluwarsa. Ambil key baru lewat Get Key.",
    KEY_BANNED = "Key ini diblokir.",
    KEY_HWID_LOCKED = "Key terkunci ke perangkat lain. Reset lewat halaman Get Key, lalu coba lagi.",
    KEY_INCORRECT = "Key salah atau tidak ada.",
    KEY_INVALID = "Format key tidak valid.",
    SCRIPT_ID_INCORRECT = "ScriptId salah. Periksa Games.lua.",
    SCRIPT_ID_INVALID = "Format ScriptId salah. Periksa Games.lua.",
    INVALID_EXECUTOR = "Executor tidak didukung Luarmor.",
    TIME_ERROR = "Jam perangkat tidak sinkron. Setel jam otomatis lalu coba lagi.",
}

local function notify(message)
    warn("[XevoraHub] " .. tostring(message))
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "XevoraHub",
            Text = tostring(message),
            Duration = 6,
        })
    end)
end

local function loadRemote(url, label)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(body) ~= "string" or body == "" then
        return false, label .. ": gagal diunduh"
    end

    local fn, compileError = loadstring(body)
    if not fn then
        return false, label .. ": kode error (" .. tostring(compileError) .. ")"
    end

    local ran, result = pcall(fn)
    if not ran then
        return false, label .. ": gagal dijalankan (" .. tostring(result) .. ")"
    end

    return true, result
end

local function readSavedKey()
    if typeof(isfile) == "function"
        and typeof(readfile) == "function" then

        local ok, data = pcall(function()
            if isfile(CONFIG.KeyFile) then
                return readfile(CONFIG.KeyFile)
            end
        end)

        if ok and type(data) == "string" then
            return (data:gsub("%s+", ""))
        end
    end

    return ""
end

local function saveKey(key)
    if typeof(writefile) ~= "function" then
        return
    end

    pcall(function()
        if typeof(isfolder) == "function"
            and typeof(makefolder) == "function"
            and not isfolder(CONFIG.KeyFolder) then
            makefolder(CONFIG.KeyFolder)
        end

        writefile(CONFIG.KeyFile, key)
    end)
end

local gameId = game.GameId
local placeId = game.PlaceId

-- Muat daftar game
local okReg, reg = loadRemote(CONFIG.Registry, "Daftar game")

if not okReg or type(reg) ~= "table"
    or type(reg.Games) ~= "table" then
    notify(okReg and "Daftar game rusak" or reg)
    return
end

local entry = reg.Games[gameId] or reg.Games[placeId]

if type(entry) ~= "table" then
    local line = string.format(
        '[%d] = { Name = "Nama Game", ScriptId = "32 karakter dari Luarmor" },',
        gameId
    )

    print("[XevoraHub] Game belum terdaftar. GameId = "
        .. gameId .. ", PlaceId = " .. placeId)
    print(line)

    if setclipboard then
        pcall(setclipboard, line)
    end

    notify("Game belum didukung. GameId: " .. gameId)
    return
end

env.XevoraHub = {
    Name = entry.Name,
    GameId = gameId,
    PlaceId = placeId,
    UIUrl = CONFIG.UI,
}

env.XevoraHubLoaded = true

local function fail(message)
    env.XevoraHubLoaded = nil
    notify(message)
end

-- Mode uji harus diaktifkan secara eksplisit.
-- Jika tidak aktif, entry.Url tidak akan melewati sistem key.
if env.XevoraHubTestMode == true and entry.Url then
    notify("Memuat " .. entry.Name .. " (mode uji, tanpa key)...")

    local ok, err = loadRemote(entry.Url, entry.Name)
    if not ok then
        fail(err)
    end

    return
end

local scriptId = tostring(entry.ScriptId or "")

-- Mode Free/FFA Luarmor
if entry.Free then
    if #scriptId ~= 32 or not scriptId:match("^%x+$") then
        fail("ScriptId tidak valid di Games.lua")
        return
    end

    notify("Memuat " .. entry.Name .. "...")

    local ok, err = loadRemote(
        CONFIG.FreeLoader .. scriptId .. ".lua",
        entry.Name
    )

    if not ok then
        fail(err)
    end

    return
end

-- Validasi ScriptId untuk mode key
if #scriptId ~= 32 or not scriptId:match("^%x+$") then
    fail("ScriptId " .. entry.Name
        .. " belum diisi dengan benar di Games.lua")
    return
end

-- Muat SDK Luarmor
local okSdk, api = loadRemote(CONFIG.SDK, "Luarmor SDK")

if not okSdk or type(api) ~= "table" then
    fail(okSdk and "Luarmor SDK rusak" or api)
    return
end

api.script_id = scriptId

local function check(key)
    local ok, status = pcall(api.check_key, key)

    if not ok or type(status) ~= "table" then
        return false, "Gagal menghubungi Luarmor. Coba lagi."
    end

    if status.code == "KEY_VALID" then
        return true, MESSAGES.KEY_VALID
    end

    return false, MESSAGES[status.code]
        or ("Key ditolak: "
        .. tostring(status.message or status.code))
end

local function launch(key)
    saveKey(key)
    env.script_key = key

    notify("Memuat " .. entry.Name .. "...")

    local ok, result = pcall(api.load_script)

    if not ok then
        fail("Gagal memuat script: " .. tostring(result))
    elseif result == false then
        fail("Luarmor gagal memuat script.")
    end
end

-- Periksa key tersimpan
local saved = readSavedKey()
local lastMessage

if saved ~= "" then
    local valid, message = check(saved)

    if valid then
        launch(saved)
        return
    end

    lastMessage = message
end

-- Muat XevoraUI
local okUi, UI = loadRemote(CONFIG.UI, "XevoraUI")

if not okUi then
    fail(UI)
    return
end

if type(UI) ~= "table"
    or type(UI.KeyPrompt) ~= "function" then
    fail("Main UI tidak menyediakan fungsi KeyPrompt")
    return
end

local getKey = tostring(reg.GetKey or "")

if getKey == "" or getKey:find("ISI_", 1, true) then
    getKey = ""
end

-- Tampilkan Get Key dengan penanganan error
local okPrompt, promptResult = pcall(function()
    return UI:KeyPrompt({
        Title = "XevoraHub",
        SubTitle = entry.Name,
        GetKeyUrl = getKey,
        SavedKey = saved,
        Status = lastMessage,
        Check = check,

        OnSuccess = function(key)
            local okLaunch, launchError = pcall(launch, key)

            if not okLaunch then
                fail("Gagal menjalankan script: "
                    .. tostring(launchError))
            end
        end,

        OnClose = function()
            env.XevoraHubLoaded = nil
        end,
    })
end)

if not okPrompt then
    fail("KeyPrompt gagal: " .. tostring(promptResult))
    return
end
