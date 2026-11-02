# ---------- traceroute ----------
traceroute() { script -q /dev/null /usr/sbin/traceroute "$@" | perl ~/.config/zsh/trace.pl }

# ---------- myip ----------
myip() {
  local l=$(ipconfig getifaddr en0 2>/dev/null) p=$(curl -s --max-time 3 ifconfig.me)
  print ""
  print "  \e[38;2;94;234;242m\uf0ac\e[0m  \e[38;2;90;82;140mlocal \e[0m  \e[38;2;233;230;255m${l:-–}\e[0m"
  print "  \e[38;2;169;156;255m\uf0c2\e[0m  \e[38;2;90;82;140mpublic\e[0m  \e[38;2;233;230;255m${p:-–}\e[0m"
  print ""
}

# ---------- disk, monitor, help ----------
alias df='duf -theme dark'
alias top='btop'
alias help='tldr'

# ---------- man berwarna ----------
export LESS_TERMCAP_md=$'\e[1;38;2;169;156;255m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;2;94;234;242m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_so=$'\e[38;2;11;10;20;48;2;242;196;109m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS='-R'

# ---------- warna file di ls/ll/tree ----------
export EZA_COLORS="di=1;38;2;169;156;255:ex=38;2;125;249;200:ln=38;2;94;234;242:da=38;2;90;82;140:sn=38;2;242;196;109:sb=38;2;90;82;140:uu=38;2;169;156;255:*.md=38;2;233;230;255:*.json=38;2;242;196;109:*.yml=38;2;242;196;109:*.sh=38;2;125;249;200:*.py=38;2;94;234;242:*.js=38;2;242;196;109:*.ts=38;2;94;234;242:*.php=38;2;169;156;255:*.pdf=38;2;255;77;109:*.zip=38;2;255;77;109"

# ---------- git log cantik ----------
alias glog="git log --graph --pretty=format:'%C(#A99CFF)%h%C(reset) %C(#5EEAF2)%d%C(reset) %s %C(#5A528C)· %cr · %an%C(reset)' -20"

# ---------- typo command ----------
command_not_found_handler() {
  print "  \e[38;2;255;77;109m✘\e[0m  \e[38;2;242;196;109m$1\e[0m \e[38;2;214;211;245mgak ketemu, typo kali bestie?\e[0m"
  return 127
}

sudo() {
  if [[ "$1" == "su" && $# -eq 1 ]]; then command sudo -s
  else command sudo "$@"; fi
}
alias viz='cava'
alias deck='perl ~/.config/zsh/deck.pl'
alias macterm='open /System/Applications/Utilities/Terminal.app'

# Kunci ukuran jendela Terminal macOS supaya background tidak gepeng
TRAPWINCH() {
  [[ $TERM_PROGRAM == Apple_Terminal && -f ~/.config/fastfetch/terminal-bg.size ]] || return 0
  local wh=($(<~/.config/fastfetch/terminal-bg.size))
  osascript -e 'tell application "Terminal"' \
            -e 'set b to bounds of front window' \
            -e "set bounds of front window to {item 1 of b, item 2 of b, (item 1 of b) + ${wh[1]}, (item 2 of b) + ${wh[2]}}" \
            -e 'end tell' &>/dev/null &!
}

# Kunci ukuran jendela Terminal macOS supaya background tidak gepeng
TRAPWINCH() {
  [[ $TERM_PROGRAM == Apple_Terminal && -f ~/.config/fastfetch/terminal-bg.size ]] || return 0
  local wh=($(<~/.config/fastfetch/terminal-bg.size))
  osascript -e 'tell application "Terminal"' \
            -e 'set b to bounds of front window' \
            -e "set bounds of front window to {item 1 of b, item 2 of b, (item 1 of b) + ${wh[1]}, (item 2 of b) + ${wh[2]}}" \
            -e 'end tell' &>/dev/null &!
}

# ---------- Tips alias ----------
[[ -f /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh ]] && source /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh
export YSU_MESSAGE_FORMAT=$'\e[38;2;242;196;109m💡 Pakai alias \e[1m%alias\e[22m biar cepet: %command\e[0m'

# ---------- Koreksi typo: ketik f ----------
command -v thefuck >/dev/null && eval "$(thefuck --alias f)"

# ---------- Tips alias ----------
[[ -f /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh ]] && source /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh
export YSU_MESSAGE_FORMAT=$'\e[38;2;242;196;109m💡 Pakai alias \e[1m%alias\e[22m biar cepet: %command\e[0m'

# ---------- Koreksi typo: ketik f ----------
command -v thefuck >/dev/null && eval "$(thefuck --alias f)"
