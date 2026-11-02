#!/bin/zsh
E=$'\e'; G="${E}[38;2;94;234;242m"; Y="${E}[38;2;242;196;109m"; P="${E}[38;2;255;77;109m"
D="${E}[38;2;90;82;140m"; V="${E}[38;2;214;211;245m"; R="${E}[0m"
C=~/.cache/cyberdeck; mkdir -p $C
SU=/Library/Preferences/com.apple.SoftwareUpdate

bar() {
  local p=${1:-0} n c s="" t=""; n=$(( p * 6 / 100 )); (( n > 6 )) && n=6
  if [[ $2 == inv ]]; then
    if (( p >= 80 )); then c=$G; elif (( p >= 40 )); then c=$Y; else c=$P; fi
  else
    if (( p < 60 )); then c=$G; elif (( p < 85 )); then c=$Y; else c=$P; fi
  fi
  repeat $n s+="━"; repeat $(( 6 - n )) t+="─"
  print -rn -- "${c}${s}${D}${t}${R}  ${c}${(l:3:)p}%${R}"
}

case $1 in
  update)
    if [[ ! -f $C/stamp || -n $(find $C/stamp -mmin +360 2>/dev/null) ]]; then
      touch $C/stamp
      ( softwareupdate -l >/dev/null 2>&1
        system_profiler SPPowerDataType 2>/dev/null | awk -F': ' '/Maximum Capacity/{print $2; exit}' > $C/health.txt
      ) </dev/null >/dev/null 2>&1 &!
    fi
    n=$(defaults read $SU LastRecommendedUpdatesAvailable 2>/dev/null)
    name=$(defaults read $SU RecommendedUpdates 2>/dev/null | awk -F'= ' '/"Display Name"/{gsub(/[";]/,"",$2); print $2; exit}')
    if (( ${n:-0} > 0 )) && [[ -n $name ]]; then
      msg="${Y}⬆ ${V}${name[1,34]}"; (( n > 1 )) && msg+="${D} +$(( n - 1 ))"
      print -rn -- "${msg}${R}"
    elif [[ -n $n ]]; then
      print -rn -- "${G}✔ ${V}Up to Date${R}"
    else
      print -rn -- "${D}Checking…${R}"
    fi ;;
  ram)
    mem=$(sysctl -n hw.memsize); pg=$(sysctl -n hw.pagesize)
    vm=($(command vm_stat | awk '/Pages active/{a=$3} /Pages wired/{w=$4} /occupied by compressor/{c=$5} END{gsub(/\./,"",a); gsub(/\./,"",w); gsub(/\./,"",c); print a+0, w+0, c+0}'))
    used=$(( (vm[1] + vm[2] + vm[3]) * pg )); p=$(( used * 100 / mem ))
    print -rn -- "$(bar $p)  ${V}$(printf '%.1f' $(( used / 1073741824.0 ))) / $(( mem / 1073741824 )) GB${D} · ${V}$(printf '%.1f' $(( (mem - used) / 1073741824.0 ))) GB Free${R}" ;;
  disk)
    st=($(osascript -l JavaScript -e 'ObjC.import("Foundation"); const r = $.NSURL.fileURLWithPath("/").resourceValuesForKeysError($(["NSURLVolumeTotalCapacityKey","NSURLVolumeAvailableCapacityForImportantUsageKey"]), null); ObjC.unwrap(r.objectForKey("NSURLVolumeTotalCapacityKey")) + " " + ObjC.unwrap(r.objectForKey("NSURLVolumeAvailableCapacityForImportantUsageKey"))' 2>/dev/null))
    if (( ${st[1]:-0} > 0 )); then
      t=$(( st[1] / 1000000000.0 )); f=$(( st[2] / 1000000000.0 ))
    else
      dk=($(command df -k / | awk 'NR==2{print $2+0, $4+0}')); t=$(( dk[1] * 1024 / 1000000000.0 )); f=$(( dk[2] * 1024 / 1000000000.0 ))
    fi
    u=$(( t - f )); p=$(printf "%.0f" $(( u * 100 / t )))
    print -rn -- "$(bar $p)  ${V}$(printf '%.0f' $u) / $(printf '%.0f' $t) GB${D} · ${V}$(printf '%.0f' $f) GB Free${R}" ;;
  batt)
    bp=$(command pmset -g batt | grep -Eo '[0-9]+%' | tr -d %)
    st="On Battery"; command pmset -g batt | grep -q "AC Power" && st="AC Power"
    h=$(cat $C/health.txt 2>/dev/null)
    print -rn -- "$(bar ${bp:-0} inv)  ${V}${st}${D} · ${V}${h:-–} Health${R}" ;;
esac
