# >>> sugeng-slay launcher
_slay_run() {
  local app=$1 E=$'\e' t ac bg name hint lo flag=~/.cache/slay-app.${TTY:t}
  local L="${E}[38;2;169;156;255m" V="${E}[38;2;214;211;245m" D="${E}[38;2;110;100;160m" G="${E}[38;2;125;220;160m" R="${E}[38;2;255;77;109m" X="${E}[0m"
  case $app in
    claude) t="✳ Claude Code"; ac="${E}[38;2;217;119;87m"; bg='#1c1519'; name='✳  CLAUDE CODE'
            lo=$(jq -r '[.model // "default", (.effortLevel // empty)] | join(" · effort ")' ~/.claude/settings.json 2>/dev/null)
            hint='/model · /effort · /exit' ;;
    agy)    t="▲ Antigravity"; ac="${E}[38;2;66;133;244m"; bg='#13171f'; name='▲  ANTIGRAVITY'
            lo='Gemini · Google AI Pro'; hint='shift+tab mode · ? shortcuts · /exit' ;;
  esac
  mkdir -p ~/.cache; touch $flag
  printf '\e_Ga=d\e\\'; printf '\e]11;%s\a' "$bg"; printf '\e]2;%s\a' "$t"; command clear
  local dir=${PWD/#$HOME/~} br=$(git branch --show-current 2>/dev/null) ch=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  print ""
  print -r -- "  ${ac}${E}[1m${name}${E}[22m${D}  //  LAUNCH SEQUENCE${X}"
  print -r -- "  ${D}──────────────────────────────────────────────${X}"
  print -r -- "  ${L}MISSION ${X}  ${V}${USER} ${D}·${V} ${dir}${X}"
  [[ -n $br ]] && print -r -- "  ${L}BRANCH  ${X}  ${G} ${br}${D} · ${V}${ch} changes${X}"
  print -r -- "  ${L}LOADOUT ${X}  ${V}${lo:-default}${X}"
  print -r -- "  ${L}CONTROLS${X}  ${D}${hint}${X}"
  printf '  %sLINK    %s  ' "$L" "$X"
  for i in {1..20}; do printf '%s▮' "$ac"; sleep 0.015; done; printf ' %sONLINE%s\n' "$G" "$X"
  sleep 0.35; command clear; printf '\e]2;%s\a' "$t"
  command "$@"; local rc=$?
  rm -f $flag
  if (( rc == 127 || rc == 126 )); then print -r -- "${R}✖ $app gagal dijalankan (kode $rc). Tab dibiarkan terbuka.${X}"; return $rc; fi
  exit
}
# <<< sugeng-slay launcher
