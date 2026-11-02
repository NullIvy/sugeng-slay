use strict; use warnings; use utf8; use IO::Select; use JSON::PP; use Time::HiRes qw(time);
binmode STDOUT, ':utf8'; $| = 1;
my ($R,$B,$C,$Y,$D,$W,$V) = ("\e[0m","\e[38;2;169;156;255m","\e[38;2;94;234;242m","\e[38;2;242;196;109m","\e[38;2;90;82;140m","\e[1;38;2;233;230;255m","\e[38;2;214;211;245m");
my $cols = (`tput cols` + 0) || 80; $cols = 50 if $cols < 50;
my $Wb = $cols - 2; my $N = $Wb - 4; my $H = 3; my $LV = $H * 8;
my @ch = (' ','▁','▂','▃','▄','▅','▆','▇','█');
my @stops = ([75,91,255],[176,124,255],[255,79,163],[255,107,74]); my @col;
for my $i (0 .. $N - 1) {
  my $t = $i / ($N - 1) * 3; my $s = int($t); $s = 2 if $s > 2; my $f = $t - $s;
  my @c = map { int($stops[$s][$_] + ($stops[$s+1][$_] - $stops[$s][$_]) * $f) } 0 .. 2;
  $col[$i] = "\e[38;2;$c[0];$c[1];$c[2]m";
}
my $cfg = "/tmp/cava_deck_$<";
open(my $cf, '>', $cfg); print $cf "[general]\nframerate = 30\nbars = $N\nsensitivity = 120\n[input]\nmethod = portaudio\nsource = \"BlackHole 2ch\"\n[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = $LV\nbar_delimiter = 59\nframe_delimiter = 10\n[smoothing]\nnoise_reduction = 77\n"; close $cf;

sub at { "\e[$_[0];$_[1]H" }
sub fit { my ($s, $n) = @_; $s //= ''; length($s) > $n ? substr($s, 0, $n - 1) . '…' : $s }
sub mmss { my $t = int($_[0] // 0); sprintf("%d:%02d", int($t / 60), $t % 60) }
sub top { my ($r, $t, $c) = @_; my $s = " ◆◆◆  $t  ◆◆◆ "; at($r,2).$c.'╭'.('─' x ($Wb-2)).'╮'.at($r, 2 + int(($Wb - length $s) / 2)).$s.$R }
sub side { my ($r, $c) = @_; at($r,2).$c.'│'.$R.at($r,$Wb+1).$c.'│'.$R }
sub bot { my ($r, $c) = @_; at($r,2).$c.'╰'.('─' x ($Wb-2)).'╯'.$R }
sub line { my ($r, $txt) = @_; at($r,4).(' ' x ($Wb-4)).at($r,4).$txt.$R }

my $orig = `stty -g < /dev/tty`; chomp $orig; my $pid;
sub finish { kill 'TERM', $pid if $pid; system("stty $orig < /dev/tty"); print "\e[?25h\e[2J\e[H"; exit 0 }
$SIG{INT} = \&finish; $SIG{TERM} = \&finish;
$SIG{WINCH} = sub { kill 'TERM', $pid if $pid; system("stty $orig < /dev/tty"); exec('perl', $0) };
system("stty -icanon -echo min 1 time 0 < /dev/tty");

print "\e[?25l\e[2J", top(1, 'NOW PLAYING', $B);
print side($_, $B) for 2 .. 4; print bot(5, $B), top(6, '  AUDIO  ', $B);
print side($_, $B) for 7 .. 9; print bot(10, $B);
print at(11,4), $D, "q untuk keluar", $R;

my ($title, $base, $baseT, $lastEl, $dur, $play) = ('', 0, time, -1, 0, 0);
sub nowplaying {
  my $raw = `media-control get 2>/dev/null`; my $j = eval { decode_json($raw) };
  if (!$j || !$j->{title}) {
    print line(2, "$D♪  Nothing playing"), line(3, ''), line(4, ''); return;
  }
  my $el = $j->{elapsedTime} // 0;
  if ($el != $lastEl || ($j->{title} // '') ne $title) { $base = $el; $baseT = time; $lastEl = $el }
  ($title, $dur, $play) = ($j->{title}, $j->{duration} // 0, $j->{playing} ? 1 : 0);
  my $cur = $play ? $base + (time - $baseT) : $base; $cur = $dur if $dur && $cur > $dur;
  my $icon = $play ? "$C▶" : "$Y❚❚";
  my $sub = join(' · ', grep { $_ } ($j->{artist}, $j->{album}));
  my $pw = $Wb - 4 - 3 - 14; my $n = $dur > 0 ? int($cur / $dur * $pw) : 0; $n = $pw if $n > $pw;
  print line(2, "$icon  $W" . fit($title, $Wb - 10));
  print line(3, "   $V" . fit($sub, $Wb - 10));
  print line(4, "   $V" . sprintf("%5s ", mmss($cur)) . $C . ('━' x $n) . $D . ('─' x ($pw - $n)) . $V . ' ' . mmss($dur));
}

my $sel = IO::Select->new(\*STDIN);
$pid = open(my $cv, '-|', "cava -p $cfg 2>/dev/null"); $sel->add($cv) if $pid;
my ($buf, $lastNP) = ('', 0);
nowplaying();
while (1) {
  for my $fh ($sel->can_read(0.2)) {
    if (fileno($fh) == fileno(STDIN)) { my $c = ''; sysread(STDIN, $c, 1); finish() if $c =~ /[qQ]/; next }
    my $n = sysread($cv, my $chunk, 65536); if (!$n) { $sel->remove($cv); next }
    $buf .= $chunk; my @l = split /\n/, $buf, -1; $buf = pop @l; next unless @l;
    my @v = split /;/, $l[-1]; my $out = '';
    for my $k (0 .. $H - 1) {
      $out .= at(7 + $k, 4);
      for my $i (0 .. $N - 1) {
        my $x = ($v[$i] // 0) - ($H - 1 - $k) * 8; $x = 0 if $x < 0; $x = 8 if $x > 8;
        $out .= ($k == $H - 1 && $x == 0) ? "$D▁" : $col[$i] . $ch[$x];
      }
    }
    print $out, $R;
  }
  if (time - $lastNP >= 1) { nowplaying(); $lastNP = time }
}
