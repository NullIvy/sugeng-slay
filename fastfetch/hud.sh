#!/bin/zsh
# Sugeng Slay HUD v2 · COMMS & SHIELD
E=$'\e'; V="${E}[38;2;214;211;245m"; N="${E}[38;2;94;234;242m"; D="${E}[38;2;130;120;190m"
G="${E}[38;2;125;220;160m"; R="${E}[38;2;255;77;109m"; Y="${E}[38;2;242;196;109m"; P="${E}[38;2;169;156;255m"; C="${E}[38;2;94;234;242m"; X="${E}[0m"
mask() { [[ $SLAY_SHOW_IP == 1 ]] && cat || perl -pe 's/\b(\d{1,3})(?:\.\d{1,3}){3}\b/$1.xxx.xxx.xxx/g; s{/\d{1,2}\b}{/xx}g'; }
iface() { route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}'; }
on()  { printf '%s● %s%s' "$G" "$V" "$1"; }
off() { printf '%s● %s%s %soff' "$R" "$V" "$1" "$R"; }
ago() { local s=$(( $(date +%s) - $1 )); (( s < 86400 )) && echo "$(( s / 3600 ))h ago" || echo "$(( s / 86400 )) days ago"; }
case $1 in
  wifi)
    i=$(iface); [[ -z $i ]] && { printf '%s– offline%s' "$R" "$X"; exit; }
    s=$(ipconfig getsummary "$i" 2>/dev/null | awk -F' SSID : ' '/ SSID : /{print $2; exit}')
    [[ -z $s || $s == *redacted* ]] && s=$(networksetup -listpreferredwirelessnetworks "$i" 2>/dev/null | sed -n '2s/^[[:space:]]*//p')
    cf=~/.cache/slay-wifi; mkdir -p ~/.cache
    if [[ ! -s $cf ]] || (( $(date +%s) - $(stat -f %m $cf) > 60 )); then
      ( system_profiler SPAirPortDataType 2>/dev/null | awk -F': ' '/Signal \/ Noise/{print $2; exit}' > $cf.tmp && mv $cf.tmp $cf ) &!
    fi
    r=$(grep -oE '^-?[0-9]+' $cf 2>/dev/null)
    if [[ -n $r ]]; then
      p=$(( 2 * (r + 100) )); (( p > 100 )) && p=100; (( p < 0 )) && p=0
      k=$G; (( p < 60 )) && k=$Y; (( p < 35 )) && k=$R; f=$(( (p + 10) / 20 )); e=$(( 5 - f ))
      sig=" ${D}· ${k}${(l:$f::▮:)}${D}${(l:$e::▯:)} ${k}${p}%"
    else sig=" ${D}· scanning…"; fi
    s=${s:-connected}; (( ${#s} > 20 )) && s="${s[1,19]}…"
    printf '%s%s%s %s· %s%s%s' "$V" "$s" "$sig" "$D" "$N" "$i" "$X" ;;
  ip)
    i=$(iface); a=$(ipconfig getifaddr "$i" 2>/dev/null); m=$(ipconfig getoption "$i" subnet_mask 2>/dev/null)
    [[ -z $a ]] && { printf '%s–%s' "$D" "$X"; exit; }
    c=0; for o in ${(s:.:)m}; do while (( o )); do (( c += o & 1, o >>= 1 )); done; done
    printf '%s%s%s' "$N" "$(echo "$a/$c" | mask)" "$X" ;;
  gw)
    g=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2; exit}')
    printf '%s%s%s' "$N" "$(echo "${g:-–}" | mask)" "$X" ;;
  dns)
    d=$(scutil --dns 2>/dev/null | awk '/nameserver\[[0-9]+\]/{print $3}' | grep -v ':' | awk '!s[$0]++' | head -2 | paste -sd, - | sed 's/,/ · /g')
    printf '%s%s%s' "$N" "$(echo "${d:-–}" | mask)" "$X" ;;
  vpn)
    v=$(scutil --nc list 2>/dev/null | awk -F'"' '/\(Connected\)/{print $2; exit}')
    [[ -z $v ]] && ifconfig 2>/dev/null | grep -q 'inet 100\.' && v='Tailscale'
    [[ -n $v ]] && on "$v · connected" || printf '%s○ %snot connected%s' "$D" "$D" "$X" ;;
  armor|disk|sys|guards)
    fv=0; fw=0; sip=0; gk=0
    fdesetup status 2>/dev/null | grep -q 'On' && fv=1
    /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -qE 'enabled|State = [12]' && fw=1
    csrutil status 2>/dev/null | grep -q 'enabled' && sip=1
    spctl --status 2>/dev/null | grep -q 'enabled' && gk=1
    case $1 in
      armor) n=$(( fv + fw + sip + gk )); k=$G; (( n < 4 )) && k=$Y; (( n < 3 )) && k=$R
             m=$(( 4 - n )); bar="${(l:$n::▰:)}${(l:$m::▱:)}"
             (( n == 4 )) && t='FULL ARMOR' || t='⚠ ARMOR BREACH'
             printf '%s%s  %s/4 %s%s' "$k" "$bar" "$n" "$t" "$X" ;;
      disk)  { (( fv )) && on FileVault || off FileVault; }; printf ' %s· ' "$D"; { (( fw )) && on Firewall || off Firewall; }; printf '%s' "$X" ;;
      sys)   { (( sip )) && on SIP || off SIP; }; printf ' %s· ' "$D"; { (( gk )) && on Gatekeeper || off Gatekeeper; }; printf '%s' "$X" ;;
      guards) for n v in FileVault $fv Firewall $fw SIP $sip Gatekeeper $gk; do (( v )) && printf '%s●%s %s ' "$G" "$V" $n || printf '%s●%s %s ' "$R" "$R" $n; done; printf '%s' "$X" ;;
    esac ;;
  xp)
    p=/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist
    [[ -f $p ]] || { printf '%s–%s' "$D" "$X"; exit; }
    v=$(defaults read "${p%.plist}" CFBundleShortVersionString 2>/dev/null); t=$(stat -f %m "$p")
    s=$(( ($(date +%s) - t) / 86400 )); k=$G; (( s > 14 )) && k=$Y; (( s > 30 )) && k=$R
    printf '%s✔ %sv%s %s· %supdated %s%s' "$k" "$N" "$v" "$D" "$V" "$(ago $t)" "$X" ;;
  temp)
    v=$(zsh ~/.config/fastfetch/temp.sh 2>/dev/null | perl -ne 'print $1 if /(\d+)(?:\.\d+)?\s*°C/'); 
    [[ -z $v ]] && { printf '%s–%s' "$D" "$X"; exit; }
    k=$G; lab='Cool'; (( v >= 50 )) && { k=$N; lab='Normal'; }; (( v >= 60 )) && { k=$N; lab='Warm'; }; (( v >= 75 )) && { k=$Y; lab='⚠ HOT'; }; (( v >= 85 )) && { k=$R; lab='⚠ OVERHEAT'; }
    f=$(( (v - 30) / 7 )); (( f < 0 )) && f=0; (( f > 6 )) && f=6; e=$(( 6 - f ))
    printf '%s%s%s%s  %s%d°C %s· %s%s%s' "$k" "${(l:$f::━:)}" "$D" "${(l:$e::─:)}" "$k" "$v" "$D" "$k" "$lab" "$X" ;;
  procs)
    n=$(ps -A | wc -l | tr -d ' '); printf '%s%s %srunning%s' "$N" "$(( n - 1 ))" "$V" "$X" ;;
  patch)
    cf=~/.cache/slay-hw.json; [[ -s $cf ]] || { printf '%sscanning…%s' "$D" "$X"; exit; }
    l=$(jq -r '[.SPInstallHistoryDataType[]? | select(._name | test("macOS|Security|Rapid";"i")) | select(._name | test("XProtect|Gatekeeper|MRT|Safari";"i") | not)] | sort_by(.install_date) | last | "\(._name)|\(.install_date)"' $cf 2>/dev/null)
    [[ -z $l || $l == null* ]] && { printf '%s–%s' "$D" "$X"; exit; }
    nm=${l%%|*}; (( ${#nm} > 24 )) && nm="${nm[1,23]}…"
    t=$(date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "${l#*|}" +%s 2>/dev/null); s=$(( ($(date +%s) - ${t:-0}) / 86400 ))
    k=$G; (( s > 30 )) && k=$Y; (( s > 60 )) && k=$R
    printf '%s%s %s· %s%s %s(%dd)%s' "$V" "$nm" "$D" "$k" "$(date -r ${t:-0} '+%d %b %Y')" "$D" "$s" "$X" ;;
  hw)
    cf=~/.cache/slay-hw.json
    if [[ ! -s $cf ]] || (( $(date +%s) - $(stat -f %m $cf) > 86400 )); then
      ( system_profiler SPHardwareDataType SPDisplaysDataType SPInstallHistoryDataType -json > $cf.tmp 2>/dev/null && mv $cf.tmp $cf ) &!
    fi
    [[ -s $cf ]] || { printf '%sscanning hardware…%s' "$D" "$X"; exit; }
    q() { jq -r "$1 // empty" $cf 2>/dev/null | head -1; }
    id=$(q '.SPHardwareDataType[0].machine_model')
    mk=$(defaults read ~/Library/Preferences/com.apple.SystemProfiler.plist 'CPU Names' 2>/dev/null | awk -F'= ' 'NR>1 && /=/{gsub(/[";]/,"",$2); print $2; exit}')
    case $id in
      MacBookPro17,1) an='A2338 · EMC 3578'; mk=${mk:-MacBook Pro (13-inch, M1, 2020)} ;;
      MacBookAir10,1) an='A2337 · EMC 3598' ;;
      *) an='' ;;
    esac
    case $2 in
      machine) printf '%s%s%s' "$V" "${mk:-$(q '.SPHardwareDataType[0].machine_name')}" "$X" ;;
      model)   [[ -n $an ]] && printf '%s%s %s· %s%s%s' "$N" "$an" "$D" "$V" "$id" "$X" || printf '%s%s%s' "$V" "$id" "$X" ;;
      specs)   pc=$(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null); ec=$(sysctl -n hw.perflevel1.physicalcpu 2>/dev/null)
               c=$(sysctl -n hw.physicalcpu 2>/dev/null); g=$(q '.SPDisplaysDataType[0].sppci_cores'); ch=$(q '.SPHardwareDataType[0].chip_type')
               printf '%s%s %s· %s%sC CPU %s%s %s· %s%sC GPU %s· %s%s%s' "$V" "${ch#Apple }" "$D" "$N" "$c" "$D" "${pc:+${pc}P+${ec}E}" "$D" "$N" "${g:-?}" "$D" "$V" "$(q '.SPHardwareDataType[0].physical_memory')" "$X" ;;
      display) typeset -a ins ext
               while IFS='|' read -r ty px res; do
                 if [[ $ty == *internal* ]]; then
                   [[ $px =~ '([0-9]+)x([0-9]+)' ]] && ins+="Retina ${match[1]}×${match[2]}" || ins+="Retina ${res// x /×}"
                 else r=${res// x /×}; r=${r/ @ /@}; ext+="Ext ${r/.00Hz/Hz}"; fi
               done < <(jq -r '.SPDisplaysDataType[].spdisplays_ndrvs[]? | "\(.spdisplays_connection_type // "ext")|\(.spdisplays_pixelresolution // "")|\(._spdisplays_resolution // "?")"' $cf 2>/dev/null)
               out=($ins $ext); printf '%s%s%s' "$V" "${${(j: · :)out}:-–}" "$X" ;;
    esac ;;
  mode)
    m=$(cat ~/.cache/slay-mode 2>/dev/null); m=${m:-auto}
    if [[ $m == auto ]]; then
      f=$(jq -r '.data[0].storeAssertionRecords[0].assertionDetails.assertionDetailsModeIdentifier // empty' ~/Library/DoNotDisturb/DB/Assertions.json 2>/dev/null)
      [[ $f == *work* ]] && m=work || m=play
    fi
    print $m ;;
  quote)
    qf=~/.config/fastfetch/quotes.txt; [[ $(zsh $0 mode) == work && -s ~/.config/fastfetch/work-quotes.txt ]] && qf=~/.config/fastfetch/work-quotes.txt
    awk 'BEGIN{srand()} NF && length($0) <= 52 {a[++n]=$0} END{print a[int(rand()*n)+1]}' $qf ;;
  hudbar)
    al=(); m=$(zsh $0 mode)
    route -n get default >/dev/null 2>&1 && on="${G}● ONLINE" || { on="${R}● OFFLINE"; al+=NET; }
    t=$(zsh ~/.config/fastfetch/temp.sh 2>/dev/null | perl -ne 'print $1 if /(\d+)(?:\.\d+)?\s*°C/'); (( ${t:-0} >= 85 )) && al+=OVERHEAT
    b=$(pmset -g batt | grep -oE '[0-9]+%' | tr -d %); pmset -g batt | grep -q discharging && (( ${b:-100} < 20 )) && al+=LOW-HP
    r=$(memory_pressure 2>/dev/null | awk '/free percentage/{print 100-$NF}' | tr -d %); (( ${r:-0} >= 90 )) && al+=MEM-CRIT
    np=$(media-control get 2>/dev/null | jq -r 'select(.playing == true) | "\(.title) — \(.artist)"' 2>/dev/null)
    (( ${#np} > 26 )) && np="${np[1,25]}…"
    [[ $m == work ]] && md="${C}■ WORK" || md="${P}◆ PLAY"
    (( ${#al} )) && a="${R}⚠ ${al[1]}$( (( ${#al} > 1 )) && print " +$(( ${#al} - 1 ))")" || a="${G}✔ ALL CLEAR"
    s=" ${D}│ "; o="$on$s$md$s$a"; [[ -n $np ]] && o+="$s${V}♪ $np"; o+="$s${V}$(date +%H:%M)"
    printf '%s%s' "$o" "$X" ;;
  hudframe)
    b=$(zsh $0 hudbar); pl=$(print -r -- "$b" | perl -pe 's/\e\[[0-9;]*m//g'); n=$(( 57 - ${#pl} )); (( n < 1 )) && n=1
    printf '%s %s%s╯%s' "$b" "$C" "${(l:$n::─:)}" "$X" ;;
  sysver)
    printf '%s%s %s· %sbuild %s %s· %sDarwin %s%s' "$V" "$(sw_vers -productVersion)" "$D" "$V" "$(sw_vers -buildVersion)" "$D" "$V" "$(uname -r)" "$X" ;;
  loadout)
    c=~/.cache/slay-brew; [[ -s $c ]] && read -r bf bc < $c
    printf '%s%s %sbrew %s· %s%s %scask %s· %szsh %s%s' "$N" "${bf:-?}" "$V" "$D" "$N" "${bc:-?}" "$V" "$D" "$V" "$ZSH_VERSION" "$X" ;;
  sample)
    m=~/.cache/slay-metrics.csv; mkdir -p ~/.cache
    cpu=$(top -l 2 -n 0 -s 1 | awk '/CPU usage/{i=$7} END{gsub("%","",i); printf "%d", 100-i}')
    ram=$(memory_pressure 2>/dev/null | awk '/free percentage/{gsub("%","",$NF); print 100-$NF}')
    tmp=$(zsh ~/.config/fastfetch/temp.sh 2>/dev/null | perl -ne 'print $1 if /(\d+)(?:\.\d+)?\s*°C/')
    g=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2}')
    pg=$(ping -c1 -t1 $g 2>/dev/null | awk -F'time=' '/time=/{printf "%d",$2}'); pn=$(ping -c1 -t2 1.1.1.1 2>/dev/null | awk -F'time=' '/time=/{printf "%d",$2}')
    print "$(date +%s),${cpu:-0},${ram:-0},${tmp:-0},${pg:--1},${pn:--1}" >> $m; tail -n 60 $m > $m.tmp && mv $m.tmp $m
    b=~/.cache/slay-brew; if [[ ! -s $b ]] || (( $(date +%s) - $(stat -f %m $b) > 3600 )); then
      print "$(/opt/homebrew/bin/brew list --formula 2>/dev/null | wc -l | tr -d ' ') $(/opt/homebrew/bin/brew list --cask 2>/dev/null | wc -l | tr -d ' ')" > $b; fi
    x=~/.cache/slay-xp; if [[ ! -s $x ]] || (( $(date +%s) - $(stat -f %m $x) > 3600 )); then
      em=$(git config --global user.email); tmpd=$(mktemp)
      for r in ${(f)"$(find ~ -maxdepth 3 -name .git -type d -not -path '*/Library/*' 2>/dev/null)"}; do
        git -C ${r:h} log ${em:+--author=$em} --since=365.days --format=%cd --date=short 2>/dev/null >> $tmpd; done
      tot=$(wc -l < $tmpd | tr -d ' '); st=0; d=$(date +%Y-%m-%d)
      grep -q "^$d" $tmpd || d=$(date -v-1d +%Y-%m-%d)
      while grep -q "^$d" $tmpd; do (( st++ )); d=$(date -j -v-1d -f %Y-%m-%d $d +%Y-%m-%d); done
      print "$tot $st" > $x; rm -f $tmpd; fi ;;
  trend)
    m=~/.cache/slay-metrics.csv; (( $(wc -l < $m 2>/dev/null || print 0) < 2 )) && { printf '%scollecting samples…%s' "$D" "$X"; exit; }
    sp() { tail -n 10 $m | awk -F, -v c=$1 -v lo=$2 -v hi=$3 'BEGIN{split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █",b," ")} {v=$c; i=int((v-lo)/(hi-lo)*7)+1; if(i<1)i=1; if(i>8)i=8; s=s b[i]; last=v} END{printf "%s %d", s, last}'; }
    printf '%sCPU %s%s%%  %s· %sTMP %s%s°%s' "$D" "$N" "$(sp 2 0 100)" "$D" "$D" "$Y" "$(sp 4 35 90)" "$X" ;;
  ping)
    l=$(tail -n 1 ~/.cache/slay-metrics.csv 2>/dev/null); [[ -z $l ]] && { printf '%scollecting…%s' "$D" "$X"; exit; }
    IFS=, read -r _ _ _ _ pg pn <<< "$l"
    col() { (( $1 < 0 )) && print $R || { (( $1 < $2 )) && print $G || { (( $1 < $3 )) && print $Y || print $R; }; }; }
    fm() { (( $1 < 0 )) && print 'timeout' || print "${1}ms"; }
    s=$(tail -n 10 ~/.cache/slay-metrics.csv | awk -F, 'BEGIN{split("· ∙ • ●",b," ")} {v=$6; if(v<0)v=999; i=(v<30)?1:(v<80)?2:(v<150)?3:4; s=s b[i]} END{print s}')
    printf '%sgw %s%s %s· %snet %s%s %s%s%s' "$D" "$(col $pg 10 50)" "$(fm $pg)" "$D" "$D" "$(col $pn 60 150)" "$(fm $pn)" "$D" "$s" "$X" ;;
  ai)
    f=~/.cache/slay-claude.json; [[ -s $f ]] || { printf '%s✳ %sstandby %s· ketik %sclaude%s untuk mulai%s' "$P" "$V" "$D" "$C" "$D" "$X"; exit; }
    now=$(date +%s); h5=$(jq -r '.h5 // empty' $f); h5r=$(jq -r '.h5r // 0' $f); d7=$(jq -r '.d7 // empty' $f); d7r=$(jq -r '.d7r // 0' $f)
    (( h5r && h5r < now )) && h5=0; (( d7r && d7r < now )) && d7=0
    mb() { local p=${1%.*}; p=${p:-0}; local k=$G; (( p >= 60 )) && k=$Y; (( p >= 85 )) && k=$R; local f=$(( (p + 10) / 20 )); local e=$(( 5 - f )); printf '%s%s%s%s %s%d%%' "$k" "${(l:$f::▰:)}" "$D" "${(l:$e::▱:)}" "$k" "$p"; }
    rs=''; (( h5r > now )) && rs=" ${D}↻$(( (h5r - now) / 3600 ))h$(( (h5r - now) % 3600 / 60 ))m"
    printf '%s✳ %s5H %s%s %s· %s7D %s%s' "$P" "$V" "$(mb $h5)" "$rs" "$D" "$V" "$(mb $d7)" "$X" ;;
  mission)
    c=~/.cache/slay-mission
    if [[ ! -s $c ]] || (( $(date +%s) - $(stat -f %m $c) > 300 )); then
      ( ev=''; command -v icalBuddy >/dev/null && ev=$(icalBuddy -n -nc -nrd -ea -li 1 -iep "title,datetime" -po "datetime,title" -ps "| |" -df "" -tf "%H:%M" eventsToday+1 2>/dev/null | head -1 | sed 's/ - [0-9:]*//; s/^ *//')
        rm=$(osascript -e 'tell application "Reminders" to count (reminders whose completed is false)' 2>/dev/null)
        print -r -- "${ev}|${rm}" > $c.tmp && mv $c.tmp $c ) &!
    fi
    [[ -s $c ]] || { printf '%ssyncing calendar…%s' "$D" "$X"; exit; }
    IFS='|' read -r ev rm < $c; (( ${#ev} > 28 )) && ev="${ev[1,27]}…"
    command -v icalBuddy >/dev/null || ev='brew install ical-buddy'
    printf '%s◷ %s%s %s· %s☑ %s todo%s' "$C" "$V" "${ev:-no meetings ahead}" "$D" "$Y" "${rm:-0}" "$X" ;;
  project)
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { printf '%s○ %sidle %s· cd ke repo Git untuk melihat status%s' "$D" "$V" "$D" "$X"; exit; }
    br=$(git branch --show-current); ch=$(git status --porcelain | wc -l | tr -d ' ')
    ab=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null); bh=${ab%%[[:space:]]*}; ah=${ab##*[[:space:]]}
    lm=$(git log -1 --format='%s' 2>/dev/null); (( ${#lm} > 16 )) && lm="${lm[1,15]}…"; lt=$(git log -1 --format='%cr' 2>/dev/null | sed 's/ ago//; s/ hours\{0,1\}/h/; s/ minutes\{0,1\}/m/; s/ days\{0,1\}/d/')
    printf '%s %s%s %s↑%s ↓%s %s±%s %s· %s"%s" %s%s%s' "$G" "$br" "$X" "$N" "${ah:-0}" "${bh:-0}" "$Y" "$ch" "$D" "$V" "$lm" "$D" "$lt" "$X" ;;
  level)
    zmodload zsh/mathfunc
    x=~/.cache/slay-xp; [[ -s $x ]] || { printf '%scalculating XP…%s' "$D" "$X"; exit; }
    read -r tot st < $x; lv=$(( int(sqrt(tot / 5.0)) + 1 )); lo=$(( (lv - 1) ** 2 * 5 )); hi=$(( lv ** 2 * 5 ))
    pc=$(( (tot - lo) * 100 / (hi - lo) )); f=$(( pc / 17 )); e=$(( 6 - f ))
    fl=''; (( st > 0 )) && fl=" ${D}· ${Y}🔥 ${st}-day streak"
    printf '%sLVL %d %s%s%s%s %s%d%%%s %s· %s%s commits%s' "$P" "$lv" "$P" "${(l:$f::▰:)}" "$D" "${(l:$e::▱:)}" "$N" "$pc" "$fl" "$D" "$V" "$tot" "$X" ;;
esac
