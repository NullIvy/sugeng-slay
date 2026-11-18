#!/bin/zsh
t=$(macmon pipe -s 1 -i 400 2>/dev/null | jq -r '.temp.cpu_temp_avg' | xargs printf "%.0f" 2>/dev/null)
[[ -z "$t" || "$t" == "0" ]] && { echo "n/a"; exit; }

# Batas M1: normal < 60, hangat 60-79, panas 80-94, overheat >= 95
if   (( t < 60 )); then c="38;2;94;234;242";  s="Normal"
elif (( t < 80 )); then c="38;2;242;196;109"; s="Hangat"
elif (( t < 95 )); then c="38;2;255;140;90";  s="Panas"
else                    c="38;2;255;77;109";  s="Overheat"; fi

w=6; f=$(( t * w / 100 )); (( f > w )) && f=$w
bar=""; for ((i=0;i<f;i++)); do bar+="━"; done
rest=""; for ((i=f;i<w;i++)); do rest+="─"; done
printf "\e[${c}m%s\e[38;2;60;52;100m%s\e[0m \e[${c}m%4s°C\e[0m  %s \e[38;2;130;120;190m· normal <60°C\e[0m\n" "$bar" "$rest" "$t" "$s"
