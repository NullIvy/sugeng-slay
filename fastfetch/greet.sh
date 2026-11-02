#!/bin/zsh
h=$((10#$(date +%H)))
sun=$'\uf185'; moon=$'\uf186'

if (( h >= 5 && h < 12 )); then icon=$sun; g=(
  "Good morning bestie, kopi dulu baru ngoding"
  "Pagi! Rise and grind, jangan mager ya"
  "Sugeng enjang, let's slay hari ini"
  "Morning vibes: fresh, chill, siap deploy"
  "Bangun tidur langsung buka terminal, sigma banget"
  "Pagi bestie, semoga bug-nya libur hari ini"
  "Good morning, aura lo udah full charge belum?"
  "Selamat pagi, lowkey hari ini bakal produktif"
  "Pagi-pagi udah ngoding, main character energy"
  "Rise and shine bestie, jangan lupa sarapan"
)
elif (( h >= 12 && h < 17 )); then icon=$sun; g=(
  "Siang bestie, udah makan belum? Jangan skip lunch"
  "Good afternoon, ngantuk boleh, nyerah jangan"
  "Sugeng siang, gas tipis-tipis dulu"
  "Siang-siang gini enaknya es kopi susu sama clean code"
  "It's giving productive afternoon era"
  "Hydrate or diedrate, minum air dulu bestie"
  "Afternoon check: mood aman, wifi aman, kode semoga aman"
  "Siang bolong tetep slay, no cap"
  "Panas banget di luar, mending ngadem sambil ngoding"
  "Abis makan siang jangan langsung rebahan ya bestie"
)
elif (( h >= 17 && h < 21 )); then icon=$moon; g=(
  "Good evening, waktunya healing tipis-tipis"
  "Sore bestie, sunset vibes sambil commit"
  "Sugeng sonten, kerjaan hari ini udah W belum?"
  "Evening mode: santai dulu, deploy besok aja"
  "Sore-sore enaknya ngoding sambil playlist galau"
  "Udah magrib, rehat dulu bestie"
  "Good evening, lo udah slay banget hari ini"
  "Senja datang, bug pulang. Semoga"
  "Waktunya chill, tapi kalau mau gas juga gapapa"
  "Sore bestie, jangan lupa mandi ya, valid"
)
elif (( h >= 21 )); then icon=$moon; g=(
  "Good night, jangan begadang ya"
  "Malem bestie, mata udah 5 watt belum?"
  "Sugeng dalu, push terakhir terus bobo ya"
  "Night owl mode: on, tapi tetep jaga kesehatan"
  "Udah malem nih, jangan overthinking, mending overclock"
  "It's giving lembur era, semangat bestie"
  "Malam-malam ngoding, vibesnya hacker banget"
  "Good night, commit dulu biar tidurnya tenang"
  "Udah jam segini, besok lanjut lagi ya bestie"
  "Malem bestie, jangan lupa skincare sebelum tidur"
)
else icon=$moon; g=(
  "Jam segini masih melek? Lowkey sigma, highkey kurang tidur"
  "Tengah malem gini bug-nya udah tidur, lo kapan?"
  "Begadang mulu, auranya minus seribu bestie"
  "Udah dini hari, ngoding boleh, sakit jangan"
  "Insomnia atau deadline? Dua-duanya red flag"
  "Dini hari vibes: sunyi, gelap, penuh error"
  "Turu bestie, besok masih ada hari"
  "Jam segini masih push? Respect, tapi tidur dulu ya"
  "Melek terus kayak server production"
  "Bestie, ini udah bukan lembur, ini delulu"
)
fi
print -n "$icon  ${g[$(( RANDOM % ${#g} + 1 ))]}"
