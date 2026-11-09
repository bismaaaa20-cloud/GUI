# XevoraUI Private

Library UI Roblox/Luau untuk XevoraHub. Versi saat ini: **3.9.0**.

## Isi repository
- `Main UI` — library UI utama.
- `SOUL_HUB_Decal_1024.jpg` — aset logo.

Loader, daftar game, dan file konfigurasi key terpisah tidak disimpan di repository ini.

## Fitur UI
- Window responsif untuk mobile dan desktop.
- Tab, Section, Toggle, Slider, Dropdown, Input, Keybind, Button, Label.
- Divider, Paragraph, ProgressBar, dan Notification.
- KeyPrompt dan KeyWindow.
- Simpan, muat, daftar, dan hapus konfigurasi.
- RGB, pengaturan skala, maximize, dan mode performa.
- Show, Hide, Toggle, IsVisible, dan SetToggleKey.

## Fitur tambahan
- CheckCompatibility: memeriksa ketersediaan API executor secara pasif.
- ScanScript: pemindai pola berisiko berbasis heuristik; tidak menjalankan atau memblokir script.
- IsWebhookSupported, SendWebhook, dan SendDiscordWebhook.
- Deteksi ulang API executor saat diperlukan.

Fitur yang bergantung pada executor (clipboard, file system, dan HTTP request) hanya berfungsi jika API terkait tersedia. Deteksi API bukan jaminan bahwa API berjalan sempurna.

## Contoh penggunaan
```lua
local Library = loadstring(game:HttpGet("RAW_URL_MAIN_UI"))()
local Window = Library:CreateWindow({
    Title = "XevoraHub",
    ToggleKey = Enum.KeyCode.RightControl
})
local Tab = Window:AddTab("Main")
Tab:AddSection("Example")
Tab:AddParagraph({
    Title = "Welcome",
    Content = "XevoraUI Private 3.9.0"
})
Tab:AddToggle({
    Name = "Example Toggle",
    Callback = function(enabled)
        print("Toggle:", enabled)
    end
})
```
Ganti `RAW_URL_MAIN_UI` dengan URL raw file `Main UI`.

## Keamanan dan pengujian
- ScanScript hanya memberi indikator pemeriksaan manual. Risiko rendah bukan jaminan aman; risiko tinggi bukan bukti pasti scam.
- Webhook tidak dikirim otomatis. Pemanggil harus memberikan URL HTTPS dan payload secara eksplisit.
- Jangan menyimpan token, cookie, password, atau webhook rahasia di source publik.
- Kompatibilitas executor berbeda-beda. Uji di Roblox dan executor target sebelum digunakan.
