# Sugeng Slay

Sugeng rawuh, bestie. Kalau Shell Senpai adalah markas saya di Windows, maka Sugeng Slay adalah kokpit saya di macOS. Namanya gabungan dari sugeng, sapaan hangat khas Jawa yang biasa dipakai untuk menyambut tamu, dan slay, istilah gen z untuk sesuatu yang tampil maksimal. Jadi setiap kali terminal dibuka, rasanya seperti disambut dengan ramah oleh sebuah dashboard yang auranya plus seribu.

Proyek ini lahir dari satu malam panjang ngoprek terminal yang awalnya cuma ingin menghilangkan tulisan Last login yang mengganggu, lalu pelan pelan berubah menjadi tampilan bergaya cyberpunk yang terasa seperti layar HUD di game favorit. Repo ini berisi seluruh dotfiles yang saya pakai di macOS dengan Ghostty sebagai terminal utama. Semua konfigurasi disimpan di sini supaya kalau suatu hari MacBook harus diinstal ulang, saya cukup clone repo ini dan dalam beberapa menit semuanya kembali menyala seperti semula. Anggap saja ini save file untuk terminal kamu, wis lengkap karo loadout e.

## Tentang Proyek Ini

Sugeng Slay bukan aplikasi baru, melainkan kumpulan konfigurasi yang menyatukan beberapa tools open source menjadi satu tampilan yang konsisten. Ghostty dipakai sebagai terminal karena mendukung gambar, warna 24 bit, transparansi, dan shader GPU. Fastfetch bertugas menampilkan panel informasi sistem, Starship mengurus prompt, sedangkan sisanya adalah script zsh, perl, dan JavaScript for Automation buatan sendiri yang membaca data langsung dari macOS. Semuanya dibalut palet Cyberdeck yang terdiri dari lavender untuk identitas, cyan untuk informasi, kuning untuk peringatan, dan merah untuk hal yang perlu diwaspadai.

Ada satu prinsip yang saya pegang selama membangun proyek ini, yaitu dekorasi tidak boleh mengalahkan informasi. Foto karakter dan equalizer memang membuat terminal terasa hidup, tapi keduanya sengaja dibuat samar supaya panel dan teks tetap menjadi pusat perhatian. Terminal bawaan macOS juga ikut didukung secara otomatis. Karena Terminal bawaan tidak bisa menampilkan gambar, panelnya akan memakai logo Apple berwarna sebagai pengganti foto, sementara struktur, warna, dan fungsinya tetap sama.

## Fitur Unggulan

Berikut ringkasan fitur yang bikin Sugeng Slay terasa beda dari terminal biasa.

| Fitur | Penjelasan |
|---|---|
| Boot Sequence | Animasi CYBERDECK ADMIN ACCESS GRANTED muncul setiap kali terminal dibuka seperti layar boot di game cyberpunk |
| Sapaan Jaksel Random | Greeting acak sesuai jam dengan campuran bahasa gaul, slang Inggris, gen z, gen alpha, dan sedikit bahasa Jawa |
| Panel Empat Kartu | Kartu System, Software, Hardware, dan Status berbingkai rapi dengan judul tepat di tengah |
| Info Build dan Update | Nomor build macOS dan status software update tampil langsung di kartu System |
| Spesifikasi Lengkap | Model, chip, GPU, memori, storage, layar, dan baterai tertulis sesuai mesin asli |
| Storage ala System Settings | Pemakaian storage dan bar bersegmen Docs, Apps, Trash, System, dan Free yang angkanya sama dengan System Settings |
| Kesehatan Baterai | Persentase baterai, status pengisian, dan battery health asli dari macOS |
| Quote IT Jaksel | Seratus quote acak bertema IT dengan gaya bahasa anak Jaksel di bawah panel |
| Logo Duotone | Foto karakter favorit otomatis diubah menjadi hitam putih dengan tint lavender |
| Equalizer Shader | Equalizer bergradasi biru, ungu, pink, dan merah bergerak samar di background tanpa mengganggu ketikan |
| Now Playing Title Bar | Judul lagu, penyanyi, dan album tampil di title bar lalu otomatis berganti ke nama folder saat musik berhenti |
| Panel Deck | Panel musik lengkap dengan progress lagu dan visualizer audio yang benar benar sinkron dengan irama |
| Prompt Kapsul | Prompt Starship dua baris dengan kapsul user, folder, dan branch Git yang berubah merah saat mode root |
| CLI Berwarna | Output ping, traceroute, dan nslookup diberi ikon centang, silang, dan latency bar berwarna |
| Tab Interaktif | Tombol Tab membuka menu pencarian dengan preview isi folder dan file |
| Prediksi Command | Saran abu abu dari history dan daftar command muncul otomatis saat mengetik |
| Tips Alias | Pengingat otomatis ketika ada alias yang lebih singkat dari command yang kamu ketik |
| Koreksi Typo | Salah ketik command cukup dibenahi dengan mengetik f |
| Tools Modern | ls dan tree dengan ikon, cat dengan syntax highlight, git diff ala editor, dan top bertema Cyberdeck |
| Dukungan Dua Terminal | Tampil di Ghostty secara penuh dan tetap rapi di Terminal bawaan macOS |

## Struktur Repo

Folder ghostty berisi konfigurasi terminal beserta shader equalizer. Folder fastfetch berisi konfigurasi panel, script greeting, script data status dan storage, script pengubah warna logo, serta koleksi quote. Folder zsh menyimpan blok konfigurasi shell, pewarna output command, pembaca lagu untuk title bar, script deck, dan pengaturan menu Tab. Folder starship menyimpan tema prompt, folder cava menyimpan konfigurasi visualizer audio, dan folder btop menyimpan tema monitor sistem.

## Instalasi

Pertama, pastikan Homebrew sudah terpasang, lalu install semua tools yang dibutuhkan dengan perintah berikut.

```bash
brew install fastfetch starship eza zoxide fzf bat git-delta duf btop tlrc grc cava
brew install zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use thefuck
brew install --cask ghostty font-jetbrains-mono-nerd-font blackhole-2ch
brew tap ungive/media-control
brew install media-control
```

Selanjutnya, clone repo ini lalu salin semua konfigurasi ke tempatnya masing masing. Perintah terakhir di blok ini mengganti penanda lokasi folder dengan folder home milikmu secara otomatis.

```bash
git clone https://github.com/NullIvy/sugeng-slay.git
cd sugeng-slay
mkdir -p ~/.config/ghostty ~/.config/fastfetch ~/.config/zsh ~/.config/cava ~/.config/btop/themes
cp ghostty/* ~/.config/ghostty/
cp fastfetch/* ~/.config/fastfetch/
cp zsh/*.zsh zsh/*.pl ~/.config/zsh/
cp starship/starship.toml ~/.config/starship.toml
cp cava/* ~/.config/cava/
cp btop/cyberdeck.theme ~/.config/btop/themes/
git clone --depth 1 https://github.com/Aloxaf/fzf-tab ~/.config/zsh/fzf-tab
cat zsh/zshrc.cyberdeck >> ~/.zshrc
grep -rl "__HOME__" ~/.config/ghostty ~/.config/fastfetch ~/.config/zsh ~/.zshrc | xargs sed -i '' "s|__HOME__|$HOME|g"
touch ~/.hushlogin
```

Setelah itu, siapkan gambar karakter untuk logo. Gambar sengaja tidak disertakan di repo ini, jadi pilih gambar favoritmu sendiri lalu ubah menjadi versi hitam putih dengan tint lavender menggunakan perintah berikut. Ganti gambar.jpg dengan lokasi gambar pilihanmu.

```bash
sips -s format png --matchTo '/System/Library/ColorSync/Profiles/Generic Gray Profile.icc' gambar.jpg --out ~/.config/fastfetch/logo-bw.png
osascript -l JavaScript ~/.config/fastfetch/duotone.js ~/.config/fastfetch/logo-bw.png ~/.config/fastfetch/logo-cyber.png 200 185 255
```

Langkah berikutnya adalah memberi izin dan menyiapkan audio. Buka System Settings bagian Privacy and Security lalu berikan Full Disk Access untuk Ghostty supaya bar storage bisa menghitung ukuran folder tanpa popup berulang. Untuk visualizer, buka Audio MIDI Setup, buat Multi-Output Device yang berisi MacBook Pro Speakers dan BlackHole 2ch, lalu pilih perangkat itu sebagai output suara dari menu bar. Terakhir, tutup Ghostty sepenuhnya dengan Cmd Q lalu buka kembali, dan Sugeng Slay akan langsung menyambutmu.

## Kustomisasi

Hampir semua bagian Sugeng Slay bisa dimodifikasi seperti skin dan loadout di game. Spesifikasi di kartu Hardware ditulis sesuai MacBook Pro 13 inch M1 tahun 2020, jadi sesuaikan teksnya di fastfetch/config.jsonc kalau kamu memakai mesin yang berbeda. Sapaan bisa ditambah di greet.sh dan quote bisa ditambah di quotes.txt dengan menulis satu kalimat di setiap baris. Warna prompt diatur di starship.toml, warna output command diatur di bagian atas cyberdeck-cli.zsh, intensitas equalizer diatur dari angka glow di eq.glsl, dan untuk mengganti logo cukup ulangi dua perintah sips dan osascript di atas lalu ketik clear.

## Penutup

Proyek ini awalnya cuma iseng karena bosan melihat terminal yang itu itu saja, tapi ternyata berakhir menjadi sesi ngoprek sampai lewat tengah malam dengan banyak trial and error di setiap langkahnya. Kalau kamu menemukan bug atau punya ide untuk membuatnya lebih keren, silakan buka issue atau kirim pull request, karena party yang lengkap selalu lebih seru daripada solo queue. Semua tools yang dipakai di sini adalah proyek open source luar biasa, jadi kredit sepenuhnya untuk para pembuat Ghostty, Fastfetch, Starship, eza, zoxide, fzf, fzf-tab, bat, delta, btop, cava, BlackHole, media-control, dan semua plugin zsh yang ikut membuat terminal ini slay.

Digarap di antara jam satu dan tiga pagi dengan secangkir kopi oleh Rizki. Matur nuwun, bestie. GG and have fun.
