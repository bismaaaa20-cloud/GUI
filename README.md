# XevoraHub

Repository publik untuk komponen XevoraHub: Loader, daftar game, library UI XevoraUI, dan aset logo.

## Standar bahasa dan lingkungan eksekusi

**Bahasa utama seluruh script game XevoraHub adalah Luau (Roblox Lua) yang ditujukan untuk lingkungan Roblox Executor**, termasuk executor Android dan PC. Script tidak ditulis sebagai Lua umum, JavaScript, Node.js, atau kode khusus Roblox Studio kecuali diminta secara eksplisit.

### Aturan wajib

- Gunakan sintaks Luau yang kompatibel dengan lingkungan Roblox.
- Gunakan `getgenv()` sebagai lingkungan global executor untuk berbagi data antara Loader dan script game. Loader menyediakan `getgenv().XevoraHub`; script game membaca data tersebut.
- Jangan mengganti kontrak `getgenv().XevoraHub` dengan `_G`, `shared`, atau variabel lokal sebagai jalur utama tanpa permintaan pemilik proyek.
- Pemuatan library mengikuti arsitektur proyek: `loadstring(game:HttpGet(hub.UIUrl))()`, selama executor mendukung `loadstring` dan `game:HttpGet`.
- Gunakan API Roblox/Luau seperti `game:GetService()`, `task.spawn`, `task.wait`, `pcall`, `FindFirstChild`, dan `WaitForChild` dengan batas waktu secara tepat.
- API khusus executor seperti `writefile`, `readfile`, `isfile`, dan `setclipboard` bersifat opsional dan tidak universal. Periksa ketersediaannya sebelum dipakai; sediakan penanganan kegagalan yang jelas.
- Jangan mengasumsikan semua executor Android dan PC memiliki API tambahan atau perilaku yang sama. Sebutkan ketergantungan executor jika sebuah fitur membutuhkannya.
- Jangan menggunakan API browser, DOM, `localStorage`, Node.js, atau API desktop sebagai pengganti API Roblox/executor.
- Jangan mengarang nama Remote, path Instance, atau properti game. Minta bukti dari pemeriksaan game yang sah dan sesuai sebelum menulis integrasi yang bergantung pada objek tersebut.
- Jangan mengubah desain atau API XevoraUI tanpa permintaan pemilik proyek.
- Jangan mengklaim script telah diuji di Roblox/executor jika pengujian langsung belum dilakukan. Nyatakan status pengujian dengan jujur.

### Contoh kontrak global XevoraHub

Loader menyiapkan data untuk script game:

```lua
-- Disiapkan oleh Loader sebelum script game dimuat.
getgenv().XevoraHub = {
    Name = "Nama Game",
    GameId = game.GameId,
    PlaceId = game.PlaceId,
    UIUrl = "URL Raw XevoraUI"
}
```

Script game mengambil data tersebut:

```lua
local env = getgenv()
local hub = env and env.XevoraHub

if type(hub) ~= "table" or type(hub.UIUrl) ~= "string" then
    warn("[XevoraHub] Data Loader tidak tersedia atau tidak lengkap.")
    return
end

local ok, UI = pcall(function()
    return loadstring(game:HttpGet(hub.UIUrl))()
end)

if not ok or not UI then
    warn("[XevoraHub] Gagal memuat XevoraUI:", UI)
    return
end
```

Contoh ini adalah pola integrasi, bukan bukti bahwa semua executor mendukung fungsi pemuatan tersebut.

## Arsitektur repository

- `Loader.lua` — satu-satunya loader yang dijalankan pengguna.
- `Games.lua` — pemetaan GameId/PlaceId ke ScriptId Luarmor dan konfigurasi Get Key.
- `Main UI` — library UI XevoraUI.
- `Keys.lua` — konfigurasi terkait key system.
- `SOUL_HUB_Decal_1024.jpg` — aset logo.

Script game dikelola melalui project Luarmor sesuai konfigurasi pemilik; jangan menaruh key pribadi atau rahasia pengguna di repository publik.

## Prinsip pengembangan

- Utamakan kompatibilitas mobile, khususnya Android.
- Ikuti API XevoraUI yang sudah ada.
- Untuk fitur berulang, gunakan status toggle dan loop yang memiliki jeda serta dapat dihentikan.
- Gunakan `pcall` pada operasi yang berpotensi gagal.
- Jangan menghindari atau menonaktifkan sistem key, HWID, atau proteksi script.
- Jelaskan file yang diubah, langkah pengujian, dan bagian yang belum diuji.
