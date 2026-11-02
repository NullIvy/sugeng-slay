use strict; use utf8; use IO::Select;
binmode STDOUT, ':utf8'; $| = 1;
my $N = 120;
my @ch = ('▁','▁','▂','▃','▄','▅','▆','▇','█');
my @stops = ([75,91,255], [176,124,255], [255,79,163], [255,107,74]);
my @col;
for my $i (0 .. $N - 1) {
  my $t = $i / ($N - 1) * 3; my $s = int($t); $s = 2 if $s > 2; my $f = $t - $s;
  my @a = @{$stops[$s]}; my @b = @{$stops[$s + 1]};
  my @c = map { int($a[$_] + ($b[$_] - $a[$_]) * $f) } 0 .. 2;
  $col[$i] = "\e[38;2;$c[0];$c[1];$c[2]m";
}
my $orig = `stty -g < /dev/tty`; chomp $orig;
system("stty -icanon -echo min 1 time 0 < /dev/tty");
my $pid;
sub finish { kill 'TERM', $pid if $pid; system("stty $orig < /dev/tty"); exit 0 }
$SIG{INT} = \&finish; $SIG{TERM} = \&finish;
$pid = open(my $cv, '-|', "cava -p $ENV{HOME}/.config/cava/strip 2>/dev/null") or finish();
my $sel = IO::Select->new(\*STDIN, $cv);
my $buf = '';
while (1) {
  for my $fh ($sel->can_read(1)) {
    if (fileno($fh) == fileno(STDIN)) {
      my $c = ''; sysread(STDIN, $c, 1);
      open(my $o, '>', "/tmp/cd_key_$<"); print $o $c; close $o;
      finish();
    }
    my $n = sysread($cv, my $chunk, 65536); finish() unless $n;
    $buf .= $chunk; my @l = split /\n/, $buf, -1; $buf = pop @l; next unless @l;
    my @v = split /;/, $l[-1];
    my $out = "\e[3A\e[5G";
    for my $i (0 .. $N - 1) {
      my $x = $v[$i] // 0; $x = 8 if $x > 8; $x = 0 if $x < 0;
      $out .= ($x == 0 ? "\e[38;2;60;52;100m" : $col[$i]) . $ch[$x];
    }
    print $out . "\e[0m\e[3B\r";
  }
}
