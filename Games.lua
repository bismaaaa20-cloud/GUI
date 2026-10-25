--// Games.lua | daftar game XevoraHub (dibaca oleh Loader.lua)
return {
	-- Link Get Key dari dashboard Luarmor (menu Ad System). Bentuknya:
	-- https://ads.luarmor.net/get_key?for=...
	GetKey = "https://ads.luarmor.net/get_key?for=ISI_DARI_DASHBOARD",

	Games = {
		-- [GameId] = { Name = "Nama", ScriptId = "32 karakter dari Luarmor", Free = false },
		-- Free = true  -> script tanpa key (mode FFA di Luarmor)
		[1526814825] = { Name = "War Tycoon", ScriptId = "ISI_32_KARAKTER_SCRIPT_ID" },
	},
}