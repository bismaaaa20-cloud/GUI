--// XevoraHub Loader | satu link untuk semua game + key system Luarmor
--// Alur: baca GameId -> cari di Games.lua -> cek key (Luarmor) -> jalankan script game.

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

local function notify(text)
	warn("[XevoraHub] " .. text)
	pcall(function()
		StarterGui:SetCore("SendNotification", { Title = "XevoraHub", Text = text, Duration = 6 })
	end)
end

-- Unduh, kompilasi, jalankan. Mengembalikan (true, hasil) atau (false, pesanError).
local function loadRemote(url, label)
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(body) ~= "string" or body == "" then
		return false, label .. ": gagal diunduh"
	end
	local fn, err = loadstring(body)
	if not fn then
		return false, label .. ": kode error (" .. tostring(err) .. ")"
	end
	local ran, result = pcall(fn)
	if not ran then
		return false, label .. ": gagal dijalankan (" .. tostring(result) .. ")"
	end
	return true, result
end

local function readSavedKey()
	if typeof(isfile) == "function" and typeof(readfile) == "function" then
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
		if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder(CONFIG.KeyFolder) then
			makefolder(CONFIG.KeyFolder)
		end
		writefile(CONFIG.KeyFile, key)
	end)
end

if env.XevoraHubLoaded then
	notify("Sudah berjalan di game ini")
	return
end

local gameId, placeId = game.GameId, game.PlaceId

local okReg, reg = loadRemote(CONFIG.Registry, "Daftar game")
if not okReg or type(reg) ~= "table" or type(reg.Games) ~= "table" then
	notify(okReg and "Daftar game rusak" or reg)
	return
end

local entry = reg.Games[gameId] or reg.Games[placeId]
if not entry then
	local line = string.format('[%d] = { Name = "Nama Game", ScriptId = "32 karakter dari Luarmor" },', gameId)
	print("[XevoraHub] Game belum terdaftar. GameId = " .. gameId .. ", PlaceId = " .. placeId)
	print(line)
	if setclipboard then
		pcall(setclipboard, line)
	end
	notify("Game ini belum didukung (GameId " .. gameId .. "). Baris pendaftaran disalin ke clipboard.")
	return
end

env.XevoraHub = {
	Name = entry.Name,
	GameId = gameId,
	PlaceId = placeId,
	UIUrl = CONFIG.UI,
}
env.XevoraHubLoaded = true

local function fail(text)
	env.XevoraHubLoaded = nil
	notify(text)
end

local scriptId = tostring(entry.ScriptId or "")
if #scriptId ~= 32 or not scriptId:match("^%x+$") then
	fail("ScriptId " .. entry.Name .. " belum diisi di Games.lua (32 karakter dari Luarmor)")
	return
end

-- Script tanpa key (mode FFA di Luarmor)
if entry.Free then
	notify("Memuat " .. entry.Name .. "...")
	local ok, err = loadRemote(CONFIG.FreeLoader .. scriptId .. ".lua", entry.Name)
	if not ok then
		fail(err)
	end
	return
end

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
	return false, MESSAGES[status.code] or ("Key ditolak: " .. tostring(status.message or status.code))
end

local function launch(key)
	saveKey(key)
	env.script_key = key
	notify("Memuat " .. entry.Name .. "...")
	local ok, err = pcall(api.load_script)
	if not ok then
		fail("Gagal memuat script: " .. tostring(err))
	end
end

-- 1) Pakai key yang tersimpan kalau masih valid
local saved = readSavedKey()
local lastMessage
if saved ~= "" then
	local ok, msg = check(saved)
	if ok then
		launch(saved)
		return
	end
	lastMessage = msg
end

-- 2) Tampilkan jendela key
local okUi, UI = loadRemote(CONFIG.UI, "XevoraUI")
if not okUi or type(UI) ~= "table" or type(UI.KeyPrompt) ~= "function" then
	fail(okUi and "Main UI belum versi 3.1 (KeyPrompt tidak ada)" or UI)
	return
end

local getKey = tostring(reg.GetKey or "")
if getKey == "" or getKey:find("ISI_", 1, true) then
	getKey = ""
end

UI:KeyPrompt({
	Title = "XevoraHub",
	SubTitle = entry.Name,
	GetKeyUrl = getKey,
	SavedKey = saved,
	Status = lastMessage,
	Check = check,
	OnSuccess = launch,
	OnClose = function()
		env.XevoraHubLoaded = nil
	end,
})