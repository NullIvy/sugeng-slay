use utf8; binmode STDOUT, ':utf8'; binmode STDIN, ':utf8'; $| = 1;
my ($R,$C,$L,$Y,$P,$G,$D,$W) = ("\e[0m","\e[38;2;94;234;242m","\e[38;2;169;156;255m","\e[38;2;242;196;109m","\e[38;2;255;77;109m","\e[38;2;125;249;200m","\e[38;2;90;82;140m","\e[38;2;233;230;255m");
sub lat { my $t = shift; $t < 50 ? $G : $t < 100 ? $Y : $P }
sub bar { my $t = shift; my $n = int($t / 20); $n = 1 if $n < 1; $n = 10 if $n > 10; ("▮" x $n) . $D . ("▯" x (10 - $n)) }
while (<STDIN>) {
  s/\r//g;
  if (/^PING (\S+) \(([^)]+)\)/) { print "\r\n  $C\x{f0ac}  PING $W\e[1m$1\e[22m $D($2)$R\r\n\r\n"; next }
  if (/bytes from ([^:]+): icmp_seq=(\d+) ttl=(\d+) time=([\d.]+) ms/) {
    my $c = lat($4);
    printf "  $G✔$R  ${D}seq $W%-4s ${D}ttl $W%-4s $c%s$c  %7.1f ms$R\r\n", $2, $3, bar($4), $4; next }
  if (/Request timeout for icmp_seq (\d+)/) { printf "  $P✘  ${D}seq $W%-4s $P request timeout$R\r\n", $1; next }
  if (/statistics/) { print "\r\n  $L\e[1m── statistics ──$R\r\n"; next }
  if (/(\d+) packets transmitted, (\d+) packets received, ([\d.]+)% packet loss/) {
    my $c = $3 == 0 ? $G : $P;
    print "  ${D}sent $W$1   ${D}received $W$2   ${D}loss $c$3%$R\r\n"; next }
  if (m{= ([\d.]+)/([\d.]+)/([\d.]+)/([\d.]+) ms}) {
    printf "  ${D}min %s%.1f   ${D}avg %s%.1f   ${D}max %s%.1f $D ms$R\r\n\r\n", lat($1), $1, lat($2), $2, lat($3), $3; next }
  if (/cannot resolve|Unknown host|No route|unreachable/i) { print "  $P✘  $_$R"; next }
  if (/\S/) { s/\n/\r\n/; print }
}
