local CONFIG = {
	Registry = "https://raw.githubusercontent.com/bismaaaa20-cloud/GUI/refs/heads/main/Games.lua",
	UI = "https://raw.githubusercontent.com/bismaaaa20-cloud/GUI/refs/heads/main/Main%20UI",
}

local env = (getgenv and getgenv()) or _G
local StarterGui = game:GetService("StarterGui")

local function notify(text)
	warn("[Mouse Hub] " .. text)
	pcall(function()
		StarterGui:SetCore("SendNotification", { Title = "Mouse Hub", Text = text, Duration = 6 })
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

if env.MouseHubLoaded then
	notify("Sudah berjalan di game ini")
	return
end

local gameId, placeId = game.GameId, game.PlaceId

local okList, games = loadRemote(CONFIG.Registry, "Daftar game")
if not okList or type(games) ~= "table" then
	notify(okList and "Daftar game rusak" or games)
	return
end

local entry = games[gameId] or games[placeId]
if not entry then
	local line = string.format('[%d] = { Name = "%s", Script = RAW .. "games/NamaFile.lua" },', gameId, "Nama Game")
	print("[Mouse Hub] Game belum terdaftar. GameId = " .. gameId .. ", PlaceId = " .. placeId)
	print(line)
	if setclipboard then
		pcall(setclipboard, line)
	end
	notify("Game ini belum didukung (GameId " .. gameId .. "). Baris pendaftaran disalin ke clipboard.")
	return
end

-- Tempat sistem key nanti: cek key diletakkan di sini sebelum script game dijalankan.
local function passKey(info)
	return true
end
if not passKey(entry) then
	return
end

env.MouseHub = {
	Name = entry.Name,
	GameId = gameId,
	PlaceId = placeId,
	UIUrl = CONFIG.UI,
}
env.MouseHubLoaded = true

notify("Memuat " .. entry.Name .. "...")
local okGame, err = loadRemote(entry.Script, entry.Name)
if not okGame then
	env.MouseHubLoaded = nil
	notify(err)
end
