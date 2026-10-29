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

-- Loader boleh dijalankan berkali-kali: panel lama diganti panel baru (XevoraUI menghapus window
-- dengan nama sama), dan script game memakai RUN_ID untuk menghentikan salinan lamanya.

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

-- Mode uji tanpa key: script dimuat langsung dari link Raw (isi Url di Games.lua).
-- Pakai ini hanya untuk mencoba; link Raw publik bisa dijalankan siapa pun tanpa key.
if entry.Url then
	notify("Memuat " .. entry.Name .. " (mode uji, tanpa key)...")
	local ok, err = loadRemote(entry.Url, entry.Name)
	if not ok then
		fail(err)
	end
	return
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

-- 2) Tampilkan jendela key (tab Verify Key / Get Key / About Us / Partners)
local okUi, UI = loadRemote(CONFIG.UI, "XevoraUI")
if not okUi or type(UI) ~= "table" or type(UI.KeyWindow) ~= "function" then
	fail(okUi and "Main UI belum versi 3.4 (KeyWindow tidak ada)" or UI)
	return
end

local function placeholder(text)
	return type(text) ~= "string" or text == "" or text:find("ISI_", 1, true) ~= nil
end

local links = {}
local gk = reg.GetKey
if type(gk) == "string" then
	if not placeholder(gk) then
		table.insert(links, { Name = "Get Key", Url = gk })
	end
elseif type(gk) == "table" then
	for _, l in ipairs(gk) do
		if type(l) == "table" and not placeholder(l.Url) then
			table.insert(links, l)
		end
	end
end

UI:KeyWindow({
	Title = "XevoraHub | Key System",
	SubTitle = entry.Name,
	Links = links,
	Discord = reg.Discord,
	About = reg.About,
	Partners = reg.Partners,
	SavedKey = saved,
	Status = lastMessage,
	Check = check,
	OnSuccess = launch,
	OnClose = function()
		env.XevoraHubLoaded = nil
	end,
})