# >>> sugeng-slay tools v2.2
fastfetch() {
  if [[ $(zsh ~/.config/fastfetch/hud.sh mode) == work ]]; then
    command fastfetch --logo-type builtin --logo macos --logo-color-1 '38;2;169;156;255' --logo-color-2 '38;2;169;156;255' \
      --logo-color-3 '38;2;94;234;242' --logo-color-4 '38;2;94;234;242' --logo-color-5 '38;2;255;121;198' --logo-color-6 '38;2;255;121;198' "$@"
  else command fastfetch "$@"; fi
}
_slay_mode() { mkdir -p ~/.cache; print $1 > ~/.cache/slay-mode; command clear 2>/dev/null; printf '\e_Ga=d\e\\'; fastfetch; }
work() { _slay_mode work; }
play() { _slay_mode play; }
focus() { _slay_mode auto; }
myip() {
  local E=$'\e' i=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
  print ""; print "  ${E}[38;2;94;234;242m󰩟${E}[0m  ${E}[38;2;110;100;160mlocal ${E}[0m  ${E}[38;2;233;230;255m$(ipconfig getifaddr $i 2>/dev/null) ($i)${E}[0m"
  print "  ${E}[38;2;169;156;255m${E}[0m  ${E}[38;2;110;100;160mpublic${E}[0m  ${E}[38;2;233;230;255m$(curl -s --max-time 3 https://ifconfig.me || print –)${E}[0m"; print ""
}
hud() {
  osascript -e 'tell application "System Events" to keystroke "d" using command down' -e 'delay 0.6' \
    -e 'tell application "System Events" to keystroke "btop"' -e 'tell application "System Events" to key code 36' >/dev/null 2>&1 \
    || print "⚠ Izinkan Ghostty di Accessibility dulu"
}
slay-release() {
  local ver=$1 title=$2 notes=$3 repo=~/sugeng-slay
  [[ -z $ver || -z $title ]] && { print "pakai: slay-release v2.2 \"Judul\" \"Catatan\""; return 1; }
  [[ "$title $notes" =~ '^Judul|Catatan singkat|aslimu' ]] && { print "✖ Judul/catatan masih contoh"; return 1; }
  command -v gh >/dev/null || brew install gh
  (
    cd $repo || exit 1
    git pull -q --rebase --autostash
    mkdir -p ghostty fastfetch zsh starship cava btop claude
    cp ~/.config/ghostty/* ghostty/ 2>/dev/null
    cp ~/.config/fastfetch/{*.jsonc,*.sh,*.js,*.txt} fastfetch/ 2>/dev/null; rm -f fastfetch/*.bak*(N)
    cp ~/.config/zsh/*.zsh ~/.config/zsh/*.pl zsh/ 2>/dev/null
    cp ~/.config/starship.toml starship/ 2>/dev/null; cp ~/.config/cava/* cava/ 2>/dev/null
    cp ~/.config/btop/themes/cyberdeck.theme btop/ 2>/dev/null; cp ~/.claude/statusline.sh claude/ 2>/dev/null
    grep -rlI "$HOME" . --exclude-dir=.git | xargs sed -i '' "s|$HOME|__HOME__|g" 2>/dev/null
    sed -i '' 's/oleh Rizki\./oleh NullIvy./' README.md 2>/dev/null
    hit=$(grep -rnIiE 'rizki|gmail\.com|(api|access|auth)_?token *[=:]|secret *[=:]|api_key|password *[=:]' . --exclude-dir=.git | grep -viE 'quotes|README|slay-tools.zsh|statusline.sh' )
    [[ -n $hit ]] && { print "$hit"; print "✖ Data pribadi terdeteksi, rilis dibatalkan"; exit 1; }
    [[ -z $(git status --porcelain) ]] && { print "• Tidak ada perubahan"; exit 0; }
    git status --short; read -q "?Lanjut rilis ${ver}? (y/n) " || { print; exit 0; }; print
    git add . && git commit -qm "feat: $ver $title" && git push -q && git tag -a $ver -m "$title" && git push -q origin $ver
    local -a ex; [[ -n $notes ]] && ex=(--notes "$notes")
    gh release create $ver --title "$ver — $title" --latest --generate-notes $ex
  )
}
# <<< sugeng-slay tools v2.2
# >>> sugeng-slay icon v2.2b
fastfetch() {
  local m=$(zsh ~/.config/fastfetch/hud.sh mode); mkdir -p ~/.cache
  [[ $m == work ]] && print '💼' > ~/.cache/slay-icon || print '🎮' > ~/.cache/slay-icon
  if [[ $m == work ]]; then
    command fastfetch --logo-type builtin --logo macos --logo-color-1 '38;2;169;156;255' --logo-color-2 '38;2;169;156;255' \
      --logo-color-3 '38;2;94;234;242' --logo-color-4 '38;2;94;234;242' --logo-color-5 '38;2;255;121;198' --logo-color-6 '38;2;255;121;198' "$@"
  else command fastfetch "$@"; fi
  printf '\e]2;%s %s\a' "$(< ~/.cache/slay-icon)" "${PWD/#$HOME/~}"
}
# <<< sugeng-slay icon v2.2b
# >>> sugeng-slay brew bar
brew() {
  if [[ $1 == (install|upgrade|reinstall|fetch) ]]; then
    command brew "$@" 2> >(perl -e '$|=1; $/="\r"; while(<STDIN>){ s/(={4,}|#{4,})(?!>)/"\e[38;2;169;156;255m".("▰" x length($1))."\e[0m"/ge; print STDERR $_ }')
  else command brew "$@"; fi
}
# <<< sugeng-slay brew bar
