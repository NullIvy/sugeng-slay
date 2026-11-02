audiostrip() {
  local E=$'\e' B=$'\e[38;2;169;156;255m' D=$'\e[38;2;90;82;140m' R=$'\e[0m' H="" flat="" k
  repeat 122 H+="─"; repeat 120 flat+="▁"
  print -rn -- "${E}[3G${B}╭${H}╮${E}[55G ◆◆◆ ${E}[1m  AUDIO   ${E}[22m ◆◆◆ ${R}"$'\n'
  print -rn -- "${E}[3G${B}│${R} ${D}${flat}${R}${E}[126G${B}│${R}"$'\n'
  print -rn -- "${E}[3G${B}╰${H}╯${R}"$'\n'
  print -rn -- "${E}[5G${D}♪ live audio  ·  mulai ketik untuk berhenti${R}"$'\n'
  command -v cava >/dev/null || return
  rm -f /tmp/cd_key_$UID
  tput civis
  perl ~/.config/zsh/strip.pl
  tput cnorm
  printf '\e[1A\e[5G\e[K\n'
  if [[ -f /tmp/cd_key_$UID ]]; then
    k=$(<"/tmp/cd_key_$UID"); rm -f /tmp/cd_key_$UID
    [[ -n $k ]] && print -z -- "$k"
  fi
}
