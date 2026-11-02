use utf8; binmode STDOUT, ':utf8'; binmode STDIN, ':utf8'; $| = 1;
my ($R,$C,$Y,$P,$G,$D,$W) = ("\e[0m","\e[38;2;94;234;242m","\e[38;2;242;196;109m","\e[38;2;255;77;109m","\e[38;2;125;249;200m","\e[38;2;90;82;140m","\e[38;2;233;230;255m");
sub lat { my $t = shift; $t < 50 ? $G : $t < 100 ? $Y : $P }
sub bar { my $t = shift; my $n = int($t / 20); $n = 1 if $n < 1; $n = 8 if $n > 8; ("▮" x $n) . $D . ("▯" x (8 - $n)) }
sub avg { my @t = @_; my $s = 0; $s += $_ for @t; @t ? $s / @t : 0 }
sub hostip { my $s = shift; return $s =~ /(\S+) \(([\d.:a-f]+)\)/ ? ($1 eq $2 ? ($2, "") : ($1, $2)) : ($s =~ /^(\S+)/, "") }
while (<STDIN>) {
  s/\r//g;
  if (/^traceroute: Warning: (.*)/) { print "  $Y\x{f071}  $D$1$R\r\n"; next }
  if (/^traceroute to (\S+) \(([^)]+)\)/) { print "\r\n  $C\x{f0e8}  TRACE $W\e[1m$1\e[22m $D($2)$R\r\n\r\n"; next }
  if (/^\s*(\d+)\s+(.*)$/) {
    my ($hop, $rest) = ($1, $2); my @t = ($rest =~ /([\d.]+) ms/g);
    if (!@t) { printf "  $D%02d ┃ $P✘  ${D}no response$R\r\n", $hop; next }
    my ($h, $ip) = hostip($rest); my $a = avg(@t); my $c = lat($a);
    printf "  $D%02d ┃ $G✔  $W%-30.30s $D%-15s $c%s$c %7.1f ms$R\r\n", $hop, $h, $ip, bar($a), $a; next }
  if (/^\s+(\S.*)$/) {
    my $rest = $1; my @t = ($rest =~ /([\d.]+) ms/g); next unless @t;
    my ($h, $ip) = hostip($rest); my $a = avg(@t); my $c = lat($a);
    printf "     $D┃ ↳  %-30.30s %-15s $c%s$c %7.1f ms$R\r\n", $h, $ip, bar($a), $a; next }
}
print "\r\n";
