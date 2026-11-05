# XevoraHub — Inventaris Kompatibilitas Executor

**Tanggal pemeriksaan:** 5 November 2026  
**Tujuan:** mencatat cakupan platform dan keterbatasan executor sebelum mengubah kode XevoraHub. Dokumen ini adalah inventaris riset, bukan daftar rekomendasi download.

> **Batas klaim:** tidak ada cara yang jujur untuk menjamin “semua executor”. Daftar publik berubah cepat, beberapa halaman saling bertentangan, dan label *Updated* atau skor sUNC bukan jaminan sebuah script tertentu akan berjalan. Entri “tidak dinyatakan” berarti sumber yang diperiksa tidak memberikan bukti, bukan berarti fitur pasti tersedia.

## 1. API yang benar-benar dipakai XevoraHub

Bagian ini diturunkan dari `Loader.lua`, `Main UI`, dan template script game XevoraHub yang ada di repository.

### A. Syarat minimum untuk menjalankan loader dan script game

| Kemampuan | Pemakaian XevoraHub | Dampak jika tidak tersedia |
| --- | --- | --- |
| Luau client + Roblox DataModel | `game`, `Players.LocalPlayer`, `PlayerGui`, `Instance.new` | UI atau script game tidak bisa berjalan sebagaimana dirancang |
| `loadstring` | Kompilasi dan jalankan Loader, XevoraUI, SDK, serta script yang diambil dari URL | Loader berhenti sebelum memuat komponen |
| HTTP GET | `game:HttpGet`; fallback di Loader: `request`, `http_request`, `syn.request`, atau `http.get` | Tidak bisa mengambil Games.lua, Main UI, SDK, atau script |
| Lingkungan global bersama | `getgenv().XevoraHub` pada template script game; Loader saat ini mencoba `getgenv()` lalu fallback ke `_G` | Template yang memanggil `getgenv()` langsung akan gagal bila fungsi itu tidak tersedia |
| Task scheduler Luau | `task.spawn`, `task.wait`, `task.defer`, `task.delay` | Loop fitur, callback tertunda, atau pemuatan asinkron bisa gagal |
| Pemasangan GUI client | `LocalPlayer` dan `PlayerGui` yang dapat menerima `ScreenGui` | Panel tidak tampil walau source berhasil dijalankan |

### B. Fitur opsional — harus punya fallback

| API opsional | Fungsi | Fallback / dampak |
| --- | --- | --- |
| `writefile`, `readfile`, `isfile` | Simpan dan baca key serta config | Tanpa dukungan, key mungkin harus dimasukkan lagi dan config tidak dapat disimpan |
| `isfolder`, `makefolder` | Membuat folder cache/config | Penyimpanan folder bisa gagal; jangan menganggap folder selalu tersedia |
| `setclipboard` / `toclipboard` | Salin link Get Key dan baris pendaftaran game | Pengguna perlu menyalin manual |
| `getcustomasset` / `getsynasset` | Memuat logo GitHub dari cache executor | XevoraUI tetap mencoba Roblox Decal ID; logo lokal/GitHub dapat tidak tersedia |
| `delfile`, `listfiles` | Hapus dan daftar config | Fitur pengelolaan config tertentu tidak tersedia |

**Catatan penting untuk global:** Loader sudah punya fallback `_G` ketika `getgenv` tidak ada, tetapi contoh template game masih memanggil `getgenv()` secara langsung. Ini adalah ketidaksamaan kontrak yang harus dibereskan pada tahap implementasi kompatibilitas, bukan diasumsikan aman di semua executor.

**Catatan Luarmor:** dukungan HTTP umum belum membuktikan bahwa SDK Luarmor berhasil. Pemeriksaan key dan `api.load_script()` harus diuji terpisah pada setiap executor/build yang ditargetkan.

## 2. Inventaris executor menurut platform

Sumber katalog utama: [ScriptBlox — daftar executor dan status live](https://scriptblox.com/executors). Halaman tersebut menyatakan melacak 30 entri, status build Roblox, dan skor sUNC. Status di bawah adalah snapshot katalog saat diperiksa, bukan pengesahan keamanan atau jaminan kompatibilitas XevoraHub.

### Android — 4 entri

- **Delta** — Android (juga dicatat untuk iOS). Halaman detail menyebut Android updated dan iOS outdated; skor sUNC 100% tercatat untuk build lama 2.729.840. Artinya skor tersebut tidak boleh dianggap sebagai hasil untuk build Roblox terbaru. [Detail](https://scriptblox.com/executor/delta)
- **Codex** — Android. Katalog menandai updated, tetapi halaman detail menampilkan versi 2.726.1142 dan Roblox build pengujian 2.684.688; skor sUNC tidak ditampilkan. Metadata build perlu diverifikasi ulang. [Detail](https://scriptblox.com/executor/codex)
- **Cryptic** — Android. Katalog menandai updated; skor sUNC tidak ditampilkan dan halaman detail menampilkan versi/build 2.693.960. Belum ada bukti publik yang cukup tentang API wajib XevoraHub. [Detail](https://scriptblox.com/executor/cryptic)
- **Vega X** — Android. Katalog/halaman detail menandai outdated; skor sUNC 98% mengacu pada versi 2.734.917. Status lama berarti belum layak dinyatakan kompatibel pada snapshot ini. [Detail](https://scriptblox.com/executor/vega-x)

**Keterbatasan data Android:** untuk Codex dan Cryptic tidak ada skor sUNC atau daftar fungsi gagal yang jelas pada halaman yang diperiksa. Untuk Delta, skor yang ditampilkan tertaut ke build lama. Jangan menebak dukungan `getgenv`, `loadstring`, HTTP, atau filesystem dari nama executor maupun label updated saja.

### Windows / PC — 24 entri

- **Serotonin** — External; tidak diberi skor sUNC. Halaman menjelaskan external bekerja di luar proses dan bukan kategori yang dinilai sebagai executor Luau internal. [Detail](https://scriptblox.com/executor/serotonin)
- **Volt** — Internal; sUNC 100%. Fungsi inti XevoraHub tetap harus diuji langsung. [Detail](https://scriptblox.com/executor/volt)
- **Matcha** — External; tidak diberi skor sUNC pada katalog. [Detail](https://scriptblox.com/executor/matcha)
- **Potassium** — Internal; sUNC 100%. Tracker memberi catatan risiko teknis karena metode injeksi tingkat kernel dan riwayat deteksi; ini bukan alasan untuk menginstal atau menggunakannya. [Detail](https://scriptblox.com/executor/potassium)
- **Severe** — External; tidak diberi skor sUNC. Halaman menyebut fitur eksternal seperti ESP/aimbot, bukan pelaksanaan script Luau internal. [Detail](https://scriptblox.com/executor/severe)
- **Wave** — Internal; sUNC 100%; tracker juga memberi label “could be detected”. Skor tinggi bukan jaminan keamanan atau kompatibilitas. [Detail](https://scriptblox.com/executor/wave)
- **Lumen** — External; halaman tidak memberikan skor sUNC. [Detail](https://scriptblox.com/executor/lumen)
- **Synapse Z** — Internal; sUNC 98%. Satu kegagalan yang dicatat adalah `getscripts` tidak dapat mengambil script yang parent-nya nil. Ini bukan fungsi inti XevoraHub saat ini. [Detail](https://scriptblox.com/executor/synapse-z)
- **Lucid** — Internal; sUNC 96%. Halaman mencatat `getscriptbytecode` tidak andal; tes `loadstring` dan `decompile` ikut tidak dapat dipastikan karena ketergantungan tes pada bytecode tersebut. Jangan menyimpulkan `loadstring` pasti gagal dari tes yang tidak konklusif. [Detail](https://scriptblox.com/executor/lucid)
- **Madius** — External; tidak diberi skor sUNC. [Detail](https://scriptblox.com/executor/madius)
- **Matrix Hub** — External; tidak diberi skor sUNC. Halaman menyebut fungsi eksternal seperti ESP/aimbot, bukan pelaksanaan Luau internal. [Detail](https://scriptblox.com/executor/matrix-hub)
- **Seliware** — Internal; sUNC 100%, tetapi ditandai outdated pada snapshot katalog. Skor lama tidak mengatasi status build yang usang. [Detail](https://scriptblox.com/executor/seliware)
- **Axis** — Windows; skor sUNC dan rincian API yang gagal tidak dinyatakan pada halaman yang diperiksa. [Detail](https://scriptblox.com/executor/axis)
- **Madium** — Internal; sUNC 100%. Tetap perlu tes wajib XevoraHub. [Detail](https://scriptblox.com/executor/madium)
- **Photon** — External; tidak diberi skor sUNC pada katalog. [Detail](https://scriptblox.com/executor/photon)
- **Real** — Internal; sUNC 100%. Tetap perlu tes wajib XevoraHub. [Detail](https://scriptblox.com/executor/real)
- **Isaeva** — Internal; sUNC 100%. Tetap perlu tes wajib XevoraHub. [Detail](https://scriptblox.com/executor/isaeva)
- **DX9WARE V2** — External; tidak diberi skor sUNC pada katalog. [Detail](https://scriptblox.com/executor/dx9ware-v2)
- **Volcano** — Internal; sUNC 96%. Halaman mencatat tiga kegagalan/ketidakandalan terkait `getconnections`, `gethiddenproperty` yang membuat tes `sethiddenproperty` tak konklusif, dan hook `__namecall` yang belum andal. Fungsi-fungsi ini bukan ketergantungan XevoraUI standar. [Detail](https://scriptblox.com/executor/volcano)
- **Velocity** — Internal; sUNC 100%. Tracker mencatat risiko deteksi pada halaman saat diperiksa. [Detail](https://scriptblox.com/executor/velocity)
- **Lynx** — Internal; sUNC 100%. Rincian fungsi gagal tidak dinyatakan pada halaman yang diperiksa. [Detail](https://scriptblox.com/executor/lynx)
- **SirHurt** — Internal; sUNC 100%. Rincian fungsi gagal tidak dinyatakan pada halaman yang diperiksa. [Detail](https://scriptblox.com/executor/sirhurt)
- **Solara** — External; sUNC 59%. Halaman secara eksplisit menyebut keterbatasan fungsi executor karena model external. Jangan mengasumsikan API internal tersedia. [Detail](https://scriptblox.com/executor/solara)
- **Xeno** — External; sUNC 40%. Halaman menyebut banyak fungsi lingkungan/introspeksi tidak tersedia atau gagal, termasuk `getgenv`, serta hook/metamethod/debug APIs. `getgenv` penting bagi template script game XevoraHub saat ini, sehingga Xeno tidak boleh dinyatakan kompatibel dengan template tersebut sebelum kontrak global diperbaiki dan diuji. Halaman juga menyebut dukungan Microsoft Roblox belum tersedia pada build yang diperiksa. [Detail](https://scriptblox.com/executor/xeno)

### macOS — 2 entri terpantau (dicatat sebagai referensi)

- **MacSploit** — macOS; sUNC 100% pada halaman tracker. [Detail](https://scriptblox.com/executor/macsploit)
- **Opiumware** — macOS; sUNC 100% pada halaman tracker. [Detail](https://scriptblox.com/executor/opiumware)

macOS belum menjadi target utama permintaan saat ini, yaitu Android dan laptop/PC Windows.

## 3. Cara membaca skor dan jenis executor

- **sUNC/UNC bukan sertifikasi universal.** Skor menunjukkan hasil rangkaian tes fungsi pada build yang diuji. Itu tidak membuktikan endpoint Luarmor, UI XevoraUI, metode HTTP, penyimpanan key, atau seluruh script game akan berjalan.
- **Skor tidak selalu menguji build saat ini.** Contoh: halaman detail Delta masih menunjukkan build lama meski katalog menampilkan status platform yang lebih baru.
- **Internal vs external penting.** Sejumlah halaman menyatakan executor external beroperasi di luar proses dan tidak dinilai dengan sUNC. Untuk hub yang mengandalkan Luau, `getgenv`, `loadstring`, dan GUI di dalam client, external tidak boleh diasumsikan setara dengan executor internal.
- **“Tidak dinyatakan” bukan “tidak punya”.** Ketiadaan dokumentasi harus diubah menjadi status “belum diverifikasi”, bukan klaim bahwa API ada atau tidak ada.

## 4. Matriks pemeriksaan XevoraHub sebelum memberi status kompatibel

Setiap nama executor harus diperiksa per platform, versi executor, dan versi Roblox yang sama. Jangan hanya memberi satu label untuk semua versinya.

1. **Runtime:** script Luau sederhana, `typeof`, `pcall`, `task.spawn`, dan `task.wait` bekerja.
2. **Global:** cek apakah `getgenv` ada, berupa table, serta mempertahankan `XevoraHub` selama pemuatan script. Catat bila perlu fallback yang aman.
3. **Compiler & HTTP:** cek `loadstring` dan jalur HTTP yang tersedia; ambil file teks kecil dan pastikan respons valid.
4. **GUI:** pastikan `Players.LocalPlayer`, `PlayerGui`, `Instance.new("ScreenGui")`, input touch/mouse, dan cleanup GUI berjalan.
5. **Fitur opsional:** cek filesystem, clipboard, dan custom asset satu per satu. Kegagalan fitur opsional tidak boleh menjatuhkan seluruh UI.
6. **Luarmor:** uji SDK, check key, dan load script pada build yang sama; hasil tes API umum tidak menggantikan tes ini.
7. **Stabilitas:** buka/tutup UI berulang, jalankan ulang loader, respawn, dan bersihkan koneksi/tween. Catat crash, freeze, atau error.
8. **Beban:** ukur startup dan frame-time di perangkat target; jangan menyatakan “anti-lag” tanpa pengukuran.

### Label hasil yang akan dipakai nanti

- **Lulus inti:** runtime, global/adapter, HTTP, `loadstring`, GUI, dan alur Luarmor terbukti bekerja.
- **Lulus terbatas:** fitur inti bekerja, tetapi satu atau beberapa fitur opsional tidak tersedia.
- **Perlu adapter:** ada perbedaan API yang dapat ditangani tanpa mengubah perilaku produk.
- **Belum diverifikasi:** data belum cukup atau build berubah.
- **Tidak kompatibel:** salah satu syarat inti gagal pada build yang diuji.

## 5. Keputusan sementara untuk arsitektur

1. Pertahankan satu basis Luau untuk Android dan Windows; jangan membuat fork per executor sebelum data uji membuktikan perlu.
2. Nanti buat lapisan deteksi kapabilitas satu kali di Loader, lalu kirim hasilnya melalui `getgenv().XevoraHub`.
3. Fitur opsional seperti penyimpanan, clipboard, dan logo lokal harus mempunyai fallback.
4. Hindari ketergantungan pada fungsi khusus yang tidak dipakai XevoraHub (misalnya hook/metamethod, decompiler, atau fungsi introspeksi) hanya demi mengejar skor UNC.
5. Sebelum menulis adapter, selesaikan ketidaksamaan `getgenv` antara Loader dan template script game.
6. Jangan memasang atau mengunduh executor dari tautan cermin yang tidak diverifikasi. Dokumen ini hanya inventaris kompatibilitas, bukan rekomendasi instalasi.

## 6. Sumber

- [ScriptBlox — live executor catalog](https://scriptblox.com/executors) — katalog status, platform, build, jenis, dan skor yang digunakan untuk snapshot.
- [sUNC documentation — Environment](https://github.com/sUNC-Utilities/docs.sunc.su/blob/0eacf1919d556476efa668ee98d914ff0bfbb52b/docs/Environment/getgenv.md) — menjelaskan bahwa `getgenv()` adalah environment global executor.
- [sUNC documentation — Filesystem](https://github.com/sUNC-Utilities/docs.sunc.su/blob/0eacf1919d556476efa668ee98d914ff0bfbb52b/docs/Filesystem/README.md) — daftar kemampuan dan batas filesystem executor.
- [Roblox Creator Hub — Script capabilities](https://create.roblox.com/docs/scripting/capabilities) — konteks batas kapabilitas script resmi Roblox; tidak mendokumentasikan dukungan executor pihak ketiga.
- [Rayfield documentation — executor requirements](https://docs.sirius.menu/rayfield/secure-mode) — contoh dokumentasi UI library yang menyebut ketergantungan `getcustomasset` dan API filesystem. Ini referensi pola dependensi, bukan bukti bahwa XevoraHub harus memakai Rayfield.

**Catatan sumber:** ScriptBlox adalah pelacak pihak ketiga, bukan vendor dari semua executor. Informasi skor, status, risiko deteksi, dan deskripsi keterbatasan adalah laporan yang ditampilkan halaman tracker; tidak diverifikasi secara independen pada perangkat. Nama/versi/status harus diperiksa ulang sebelum hasil ini dipakai sebagai klaim dukungan resmi.
