#!/bin/zsh
# Sugeng Slay HUD statusline for Claude Code
in=$(cat); j() { print -r -- "$in" | jq -r "$1 // empty" 2>/dev/null; }
E=$'\e'; L="${E}[38;2;169;156;255m"; C="${E}[38;2;94;234;242m"; V="${E}[38;2;214;211;245m"; D="${E}[38;2;110;100;160m"
G="${E}[38;2;125;220;160m"; Y="${E}[38;2;242;196;109m"; R="${E}[38;2;255;77;109m"; B="${E}[1m"; X="${E}[0m"
bar() { local p=${1%.*}; p=${p:-0}
  local k=$G; (( p >= 60 )) && k=$Y; (( p >= 85 )) && k=$R; local f=$(( (p + 5) / 10 )); (( f > 10 )) && f=10; local e=$(( 10 - f ))
  printf '%s%s%s%s %s%3d%%%s' "$k" "${(l:$f::▰:)}" "$D" "${(l:$e::▱:)}" "$k" "$p" "$X"; }
left() { local t=$1; [[ -z $t ]] && return; local s=$(( t - $(date +%s) )); (( s <= 0 )) && return
  (( s >= 86400 )) && printf ' %s↻%dd%dh%s' "$D" $(( s / 86400 )) $(( s % 86400 / 3600 )) "$X" || printf ' %s↻%dh%02dm%s' "$D" $(( s / 3600 )) $(( s % 3600 / 60 )) "$X"; }
k() { local n=${1:-0}; if (( n >= 1000000 )); then printf '%dM' $(( n / 1000000 )); elif (( n >= 1000 )); then printf '%dk' $(( n / 1000 )); else printf '%d' $n; fi; }
model=$(j .model.display_name); eff=$(j .effort.level); dir=$(j .workspace.current_dir); dir=${dir:t}
br=$(git -C "$(j .workspace.current_dir)" branch --show-current 2>/dev/null)
ctx=$(j .context_window.used_percentage); size=$(j .context_window.context_window_size)
used=$(j .context_window.total_input_tokens); used=${used%.*}; used=${used:-0}
h5=$(j .rate_limits.five_hour.used_percentage); h5r=$(j .rate_limits.five_hour.resets_at)
d7=$(j .rate_limits.seven_day.used_percentage); d7r=$(j .rate_limits.seven_day.resets_at)
sep=" ${D}│${X} "
line1="${L}◆ ${B}${model:-Claude}${X}"
[[ -n $eff ]] && line1+=" ${D}·${X} ${C}⚡${eff}${X}"
line1+="${sep}${V} ${dir:-~}${X}"
if [[ -n $br ]]; then ch=$(git -C "$(j .workspace.current_dir)" status --porcelain 2>/dev/null | wc -l | tr -d ' '); line1+=" ${D}·${X} ${G} ${br}${X}"; (( ch )) && line1+=" ${Y}±${ch}${X}"; fi
la=$(j .cost.total_lines_added); lr=$(j .cost.total_lines_removed); ms=$(j .cost.total_duration_ms); ms=${ms%.*}
(( ${la:-0} + ${lr:-0} )) && line1+="${sep}${G}+${la:-0}${X} ${R}−${lr:-0}${X}"
[[ -n $ms ]] && line1+="${sep}${D}⏱ $(( ms / 60000 ))m${X}"
line1+="${sep}${V}$(date +%H:%M)${X}"
line2="${L}CTX${X} $(bar "$ctx") ${D}$(k $used)/$(k ${size:-0})${X}"
[[ -n $h5 ]] && line2+="${sep}${L}5H${X} $(bar "$h5")$(left $h5r)"
[[ -n $d7 ]] && line2+="${sep}${L}7D${X} $(bar "$d7")$(left $d7r)"
[[ -z $h5 && -z $d7 ]] && line2+="${sep}${D}5H · 7D ⋯ standby${X}"
[[ -n "$h5$d7" ]] && { mkdir -p ~/.cache; print -r -- "{\"h5\":${h5:-null},\"h5r\":${h5r:-0},\"d7\":${d7:-null},\"d7r\":${d7r:-0},\"t\":$(date +%s)}" > ~/.cache/slay-claude.json; }
print -r -- "$line1"; print -r -- "$line2"
