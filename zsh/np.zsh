typeset -g __CD_PWDF="/tmp/cd_pwd_${UID}_$$" __CD_NPF="/tmp/cd_np_${UID}_$$"

__np_title() {
  media-control get 2>/dev/null | perl -MJSON::PP -e '
    my $j = eval { decode_json(join "", <STDIN>) };
    if ($j && $j->{title} && $j->{playing}) {
      my $s = join(" · ", grep { $_ } ($j->{artist}, $j->{album}));
      print "▶ " . $j->{title} . ($s ? " — $s" : "");
    }'
}

__cd_precmd() {
  print -rn -- "${(%):-%~}" > $__CD_PWDF
  [[ -s $__CD_NPF ]] || printf '\e]2;%s\a' "📂 ${(%):-%~}"
}
__cd_exit() { rm -f $__CD_PWDF $__CD_NPF }

__np_loop() {
  local parent=$$ t d
  while kill -0 $parent 2>/dev/null; do
    t=$(__np_title)
    if [[ -n $t ]]; then
      print -rn -- 1 > $__CD_NPF
      printf '\e]2;%s\a' "$t" > /dev/tty
    else
      : > $__CD_NPF
      d=$(cat $__CD_PWDF 2>/dev/null)
      printf '\e]2;%s\a' "📂 ${d:-~}" > /dev/tty
    fi
    sleep 2
  done
}

if [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd __cd_precmd
  add-zsh-hook zshexit __cd_exit
  command -v media-control >/dev/null && ( __np_loop & ) 2>/dev/null
fi
