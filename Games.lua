--// Games.lua | daftar game XevoraHub (dibaca oleh Loader.lua)
return {
	-- Tab "Get Key": satu tombol per link. Ambil link dari Luarmor > Ad System
	-- (bentuknya https://ads.luarmor.net/get_key?for=...). Boleh satu, boleh banyak.
	GetKey = {
		{ Name = "Get Key - Linkvertise (24 jam)", Url = "https://ads.luarmor.net/get_key?for=ISI_DARI_DASHBOARD" },
		-- { Name = "Get Key - Lootlabs", Url = "https://ads.luarmor.net/get_key?for=..." },
	},

	-- Tab "About Us" (kosongkan Discord bila tidak ada)
	Discord = "",
	About = "XevoraHub: script hub Roblox. Ambil key di tab Get Key, lalu cek di tab Verify Key.",

	-- Tab "Partners" muncul hanya kalau daftar ini berisi:
	-- Partners = { { Name = "Nama", Url = "https://..." } },
	Partners = {},

	Games = {
		-- MODE UJI (tanpa key): Url = link Raw script.
		[1526814825] = {
			Name = "War Tycoon",
			Url = "https://raw.githubusercontent.com/bismaaaa20-cloud/War-tycoon/refs/heads/main/1",
		},
		-- MODE KEY (Luarmor): ganti baris Url di atas dengan
		--   ScriptId = "32 karakter dari Luarmor",
	},
}