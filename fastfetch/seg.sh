#!/bin/zsh
E=$'\e'; R="${E}[0m"; V="${E}[38;2;214;211;245m"; D="${E}[38;2;60;52;100m"
CD="${E}[38;2;255;77;109m"; CA="${E}[38;2;255;159;67m"; CT="${E}[38;2;242;196;109m"; CS="${E}[38;2;142;138;168m"
C=~/.cache/cyberdeck; mkdir -p $C; W=42

sz() { command du -sk "$1" 2>/dev/null | awk '{s=$1+0} END{print (s+0)*1024}' }

calc() {
  local st tot free used home lib trash apps docs sys
  st=($(osascript -l JavaScript -e 'ObjC.import("Foundation"); const r = $.NSURL.fileURLWithPath("/").resourceValuesForKeysError($(["NSURLVolumeTotalCapacityKey","NSURLVolumeAvailableCapacityForImportantUsageKey"]), null); ObjC.unwrap(r.objectForKey("NSURLVolumeTotalCapacityKey")) + " " + ObjC.unwrap(r.objectForKey("NSURLVolumeAvailableCapacityForImportantUsageKey"))'))
  tot=${st[1]:-0}; free=${st[2]:-0}; used=$(( tot - free ))
  home=$(sz __HOME__); lib=$(sz __HOME__/Library); trash=$(sz __HOME__/.Trash); apps=$(sz /Applications)
  docs=$(( home - lib - trash )); (( docs < 0 )) && docs=0
  sys=$(( used - docs - apps - trash )); (( sys < 0 )) && sys=0
  print "$docs $apps $trash $sys $free $tot" > $C/seg.tmp && mv $C/seg.tmp $C/seg.txt
}

case $1 in
  calc) calc ;;
  bar)
    if [[ ! -f $C/segstamp || -n $(find $C/segstamp -mmin +1440 2>/dev/null) ]]; then
      touch $C/segstamp; ( calc ) </dev/null >/dev/null 2>&1 &!
    fi
    if [[ ! -f $C/seg.txt ]]; then print -rn -- "${D}Calculating storage breakdown…${R}"; exit; fi
    read docs apps trash sys free tot < $C/seg.txt
    (( tot > 0 )) || { print -rn -- "${D}–${R}"; exit; }
    used=0; out=""
    for pair in "$docs:$CD" "$apps:$CA" "$trash:$CT" "$sys:$CS"; do
      v=${pair%%:*}; c=${pair#*:}; n=$(( v * W / tot )); (( v > 0 && n < 1 )) && n=1
      out+="$c"; repeat $n out+="█"; used=$(( used + n ))
    done
    out+="$D"; repeat $(( W - used )) out+="░"
    print -rn -- "${out}${R}" ;;
  legend)
    print -rn -- "${CD}■${V} Docs  ${CA}■${V} Apps  ${CT}■${V} Trash  ${CS}■${V} System  ${D}■${V} Free${R}" ;;
esac
