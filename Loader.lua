--// XevoraHub Loader | satu link untuk semua game + panel Get Key
--// Alur: baca GameId -> cari di Games.lua -> panel Get Key -> cek key -> jalankan script game.
--// Tiga mode per game (diatur di Games.lua):
--//   Url (tanpa Key)      : uji, langsung dimuat tanpa key
--//   Url + Key = true     : key dicek ke Keys.lua di GitHub (gratis)
--//   ScriptId             : key dicek Luarmor, script diunggah ke Luarmor

local RAW = "https://raw.githubusercontent.com/bismaaaa20-cloud/GUI/refs/heads/main/"
local CONFIG = {
	Registry = RAW .. "Games.lua",
	Keys = RAW .. "Keys.lua",
	UI = RAW .. "Main%20UI",
	SDK = "https://sdkapi-public.luarmor.net/library.lua",
	FreeLoader = "https://api.luarmor.net/files/v4/loaders/",
	KeyFolder = "XevoraHub",
	KeyFile = "XevoraHub/key.txt",
}

local env = (getgenv and getgenv()) or _G
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

local MESSAGES = {
	KEY_VALID = "Key valid.",
	KEY_EXPIRED = "Key sudah kedaluwarsa. Ambil key baru lewat tab Get Key.",
	KEY_BANNED = "Key ini diblokir.",
	KEY_HWID_LOCKED = "Key terkunci ke perangkat lain. Reset lewat halaman Get Key, lalu coba lagi.",
	KEY_INCORRECT = "Key salah atau tidak ada.",
	KEY_INVALID = "Format key tidak valid.",
	SCRIPT_ID_INCORRECT = "ScriptId salah. Periksa Games.lua.",
	SCRIPT_ID_INVALID = "Format ScriptId salah. Periksa Games.lua.",
	INVALID_EXECUTOR = "Executor tidak didukung Luarmor.",
	TIME_ERROR = "Jam perangkat tidak sinkron. Setel jam otomatis lalu coba lagi.",
	KEY_OTHER_ACCOUNT = "Key ini terikat ke akun Roblox lain.",
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
	local line = string.format('[%d] = { Name = "Nama Game", Url = "link Raw script", Key = true },', gameId)
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

local check, launch

if entry.Url and not entry.Key then
	-- MODE UJI: tanpa key. Link Raw publik bisa dijalankan siapa pun.
	notify("Memuat " .. entry.Name .. " (mode uji, tanpa key)...")
	local ok, err = loadRemote(entry.Url, entry.Name)
	if not ok then
		fail(err)
	end
	return
elseif entry.Url then
	-- MODE KEY GITHUB: key dicek ke Keys.lua
	local keys
	check = function(key)
		if not keys then
			local ok, res = loadRemote(CONFIG.Keys, "Daftar key")
			if ok and type(res) == "table" then
				keys = res
			end
		end
		if not keys then
			return false, "Gagal mengambil daftar key. Coba lagi."
		end
		local info = keys[key]
		if info == nil then
			return false, MESSAGES.KEY_INCORRECT
		end
		if type(info) == "table" then
			if info.Banned then
				return false, MESSAGES.KEY_BANNED
			end
			if info.UserId and info.UserId ~= 0 and info.UserId ~= LocalPlayer.UserId then
				return false, MESSAGES.KEY_OTHER_ACCOUNT
			end
			if info.Expires and os.date("!%Y-%m-%d") > tostring(info.Expires) then
				return false, MESSAGES.KEY_EXPIRED
			end
		end
		return true, MESSAGES.KEY_VALID
	end
	launch = function(key)
		saveKey(key)
		notify("Memuat " .. entry.Name .. "...")
		local ok, err = loadRemote(entry.Url, entry.Name)
		if not ok then
			fail(err)
		end
	end
else
	-- MODE LUARMOR: ScriptId dari dashboard Luarmor
	local scriptId = tostring(entry.ScriptId or "")
	if #scriptId ~= 32 or not scriptId:match("^%x+$") then
		fail("ScriptId " .. entry.Name .. " belum diisi di Games.lua (32 karakter dari Luarmor)")
		return
	end
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
	check = function(key)
		local ok, status = pcall(api.check_key, key)
		if not ok or type(status) ~= "table" then
			return false, "Gagal menghubungi Luarmor. Coba lagi."
		end
		if status.code == "KEY_VALID" then
			return true, MESSAGES.KEY_VALID
		end
		return false, MESSAGES[status.code] or ("Key ditolak: " .. tostring(status.message or status.code))
	end
	launch = function(key)
		saveKey(key)
		env.script_key = key
		notify("Memuat " .. entry.Name .. "...")
		local ok, err = pcall(api.load_script)
		if not ok then
			fail("Gagal memuat script: " .. tostring(err))
		end
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

-- 2) Panel "Get Key" (tab Verify Key / Get Key / About Us / Partners)
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
	Title = "Get Key",
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