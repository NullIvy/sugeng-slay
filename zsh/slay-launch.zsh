# >>> sugeng-slay launcher
_slay_agy_splash() {
  local E=$'\e' W=${COLUMNS:-120} H=${LINES:-40} X="${E}[0m"
  local nm=${SLAY_NAME:-$(git config --global user.name 2>/dev/null | awk '{print toupper($1)}')}; nm=${nm:-${USER:u}}
  local -a mark=('      ▄█▄      ' '     ▟███▙     ' '    ▟█▛ ▜█▙    ' '   ▟█▛   ▜█▙   ' '  ▟█▛     ▜█▙  ' ' ▟█▛       ▜█▙ ')
  local -a col=('66;133;244' '96;120;240' '140;110;235' '190;100;220' '234;90;120' '251;140;60')
  ctr() { local s=$1 p=$2; printf '%*s%s\n' $(( (W - ${#p}) / 2 )) '' "$s"; }
  printf '\n%.0s' {1..$(( H / 2 - 9 ))}
  local i; for i in {1..6}; do ctr "${E}[38;2;${col[i]}m${mark[i]}$X" "${mark[i]}"; done
  print ""
  local wl="Welcome back, ${nm}. Where should we pick up?"
  ctr "${E}[1;38;2;240;240;245m${wl}$X" "$wl"; print ""
  local br=$(git branch --show-current 2>/dev/null) d=${PWD/#$HOME/\~}
  local -a sg=("◇  Lanjutkan kerja di ${d}" "◇  Review perubahan Git${br:+ di branch $br}" "◇  Jelaskan error terakhir di terminal")
  local s pad=$(( (W - 44) / 2 )); for s in $sg; do printf "%*s%s\n" $pad "" "${E}[38;2;150;150;160m${s}$X"; done
  print ""
  local ft="Gemini · Google AI Pro    shift+tab mode · ? shortcuts · /exit"
  ctr "${E}[38;2;95;95;105m${ft}$X" "$ft"
  printf "%*s" $(( (W - 24) / 2 )) ''; for i in {1..24}; do printf '%s▬' "${E}[38;2;${col[$(( (i - 1) / 4 + 1 ))]}m"; sleep 0.02; done; print $X
}
_slay_run() {
  local app=$1 E=$'\e' t ac bg name hint lo flag=~/.cache/slay-app.${TTY:t}
  local L="${E}[38;2;169;156;255m" V="${E}[38;2;214;211;245m" D="${E}[38;2;110;100;160m" G="${E}[38;2;125;220;160m" R="${E}[38;2;255;77;109m" X="${E}[0m"
  case $app in
    claude) t="✳ Claude Code"; ac="${E}[38;2;217;119;87m"; bg='#1c1519'; name='✳  CLAUDE CODE'
            lo=$(jq -r '[.model // "default", (.effortLevel // empty)] | join(" · effort ")' ~/.claude/settings.json 2>/dev/null)
            hint='/model · /effort · /exit' ;;
    agy)    t="▲ Antigravity"; bg='#0b0b0c' ;;
  esac
  mkdir -p ~/.cache; touch $flag
  printf '\e_Ga=d\e\\'; printf '\e]11;%s\a' "$bg"; printf '\e]2;%s\a' "$t"; command clear
  if [[ $app == agy ]]; then
    _slay_agy_splash; sleep 0.9
  else
    local dir=${PWD/#$HOME/~} br=$(git branch --show-current 2>/dev/null) ch=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    print ""
    print -r -- "  ${ac}${E}[1m${name}${E}[22m${D}  //  LAUNCH SEQUENCE${X}"
    print -r -- "  ${D}──────────────────────────────────────────────${X}"
    print -r -- "  ${L}MISSION ${X}  ${V}${USER} ${D}·${V} ${dir}${X}"
    [[ -n $br ]] && print -r -- "  ${L}BRANCH  ${X}  ${G} ${br}${D} · ${V}${ch} changes${X}"
    print -r -- "  ${L}LOADOUT ${X}  ${V}${lo:-default}${X}"
    print -r -- "  ${L}CONTROLS${X}  ${D}${hint}${X}"
    printf '  %sLINK    %s  ' "$L" "$X"
    local i; for i in {1..20}; do printf '%s▮' "$ac"; sleep 0.015; done; printf ' %sONLINE%s\n' "$G" "$X"
    sleep 0.35
  fi
  command clear; printf '\e]2;%s\a' "$t"
  command "$@"; local rc=$?
  rm -f $flag
  if (( rc == 127 || rc == 126 )); then print -r -- "${R}✖ $app gagal dijalankan (kode $rc). Tab dibiarkan terbuka.${X}"; return $rc; fi
  exit
}
# <<< sugeng-slay launcher
