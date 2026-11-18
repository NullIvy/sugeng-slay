#!/bin/zsh
# Sugeng Slay installer · NullIvy
# Pakai: ./install.sh [path/ke/gambar-karakter.jpg]
set -e
REPO=${0:A:h}; IMG=$1; TS=$(date +%Y%m%d-%H%M)
c() { print -P "%F{141}◆%f $1"; }
command -v brew >/dev/null || { print "Homebrew belum terpasang. Pasang dulu dari https://brew.sh lalu jalankan ulang."; exit 1; }
BP=$(brew --prefix)

c "Memasang dependensi"
brew install -q fastfetch starship eza zoxide fzf bat git-delta duf btop tlrc grc cava jq ical-buddy gh \
  zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use thefuck
brew install -q --cask ghostty font-jetbrains-mono-nerd-font blackhole-2ch 2>/dev/null || true
brew tap ungive/media-control 2>/dev/null || true
brew trust --formula ungive/media-control/media-control 2>/dev/null || true
brew install -q media-control 2>/dev/null || true
command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash

c "Membackup konfigurasi lama ke ~/.sugeng-slay-backup-$TS"
B=~/.sugeng-slay-backup-$TS; mkdir -p $B
for d in ghostty fastfetch zsh cava; do [[ -d ~/.config/$d ]] && cp -R ~/.config/$d $B/; done
[[ -f ~/.config/starship.toml ]] && cp ~/.config/starship.toml $B/
[[ -f ~/.zshrc ]] && cp ~/.zshrc $B/zshrc

c "Menyalin konfigurasi"
mkdir -p ~/.config/{ghostty,fastfetch,zsh,cava,btop/themes} ~/.claude ~/.cache
cp -R $REPO/ghostty/. ~/.config/ghostty/
cp -R $REPO/fastfetch/. ~/.config/fastfetch/
cp -R $REPO/zsh/. ~/.config/zsh/
cp $REPO/starship/starship.toml ~/.config/starship.toml
cp -R $REPO/cava/. ~/.config/cava/ 2>/dev/null || true
cp $REPO/btop/* ~/.config/btop/themes/ 2>/dev/null || true
cp $REPO/claude/statusline.sh ~/.claude/statusline.sh
grep -rlI "__HOME__" ~/.config/{ghostty,fastfetch,zsh,cava} ~/.claude/statusline.sh 2>/dev/null | xargs sed -i '' "s|__HOME__|$HOME|g"
sed -i '' "s|/opt/homebrew/bin/brew|$BP/bin/brew|g" ~/.config/fastfetch/hud.sh
chmod +x ~/.config/fastfetch/*.sh ~/.claude/statusline.sh
cp ~/.config/fastfetch/config-compact.jsonc ~/.config/fastfetch/config.jsonc

c "Mengatur zsh"
[[ -d ~/.config/zsh/fzf-tab ]] || git clone -q --depth 1 https://github.com/Aloxaf/fzf-tab ~/.config/zsh/fzf-tab
touch ~/.zshrc ~/.hushlogin
grep -q 'sugeng-slay core' ~/.zshrc || { print "\n# >>> sugeng-slay core"; cat ~/.config/zsh/zshrc.cyberdeck; print "# <<< sugeng-slay core"; } >> ~/.zshrc
grep -q 'slay-launch.zsh' ~/.zshrc || print 'source ~/.config/zsh/slay-launch.zsh' >> ~/.zshrc
grep -q 'slay-tools.zsh' ~/.zshrc || print 'source ~/.config/zsh/slay-tools.zsh # last' >> ~/.zshrc
sed -i '' "s|__HOME__|$HOME|g" ~/.zshrc

c "Mengatur statusline Claude Code"
S=~/.claude/settings.json; [[ -s $S ]] || print '{}' > $S
jq '.statusLine = {"type":"command","command":"zsh ~/.claude/statusline.sh","padding":0}' $S > $S.tmp && mv $S.tmp $S

c "Memasang sampler background"
P=~/Library/LaunchAgents/com.nullivy.slay.sampler.plist; mkdir -p ${P:h}
cat > $P <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.nullivy.slay.sampler</string>
  <key>ProgramArguments</key><array><string>/bin/zsh</string><string>$HOME/.config/fastfetch/hud.sh</string><string>sample</string></array>
  <key>StartInterval</key><integer>60</integer>
  <key>RunAtLoad</key><true/>
  <key>EnvironmentVariables</key><dict><key>PATH</key><string>$BP/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string></dict>
</dict></plist>
PL
launchctl bootout gui/$UID $P 2>/dev/null || true; launchctl bootstrap gui/$UID $P

FF=~/.config/fastfetch
if [[ -n $IMG && -f $IMG ]]; then
  c "Membuat logo dari $IMG"
  sips -s format png --matchTo '/System/Library/ColorSync/Profiles/Generic Gray Profile.icc' "$IMG" --out $FF/logo-bw.png >/dev/null
  osascript -l JavaScript $FF/duotone.js $FF/logo-bw.png $FF/logo-cyber.png 200 185 255
  H=$(sips -g pixelHeight $FF/logo-cyber.png | awk '/pixelHeight/{print $2}'); W=$(sips -g pixelWidth $FF/logo-cyber.png | awk '/pixelWidth/{print $2}')
  NW=$(( H * 76 / 88 )); (( NW > W )) && NW=$W
  sips --cropToHeightWidth $H $NW $FF/logo-cyber.png --out $FF/logo-tall.png >/dev/null
  print auto > ~/.cache/slay-mode
elif [[ ! -f $FF/logo-tall.png ]]; then
  c "Belum ada gambar karakter, mode work dipakai sebagai bawaan"
  print work > ~/.cache/slay-mode
fi

print -P "\n%F{120}✔ Sugeng Slay terpasang.%f"
print "  1. Beri Full Disk Access untuk Ghostty di System Settings > Privacy & Security"
print "  2. Izinkan Calendar dan Reminders saat diminta"
print "  3. Tutup Ghostty dengan Cmd Q lalu buka lagi"
print "  Backup konfigurasi lama ada di $B"
