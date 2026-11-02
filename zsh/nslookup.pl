use utf8; binmode STDOUT, ':utf8'; binmode STDIN, ':utf8'; $| = 1;
my ($R,$C,$L,$P,$D,$W) = ("\e[0m","\e[38;2;94;234;242m","\e[38;2;169;156;255m","\e[38;2;255;77;109m","\e[38;2;90;82;140m","\e[38;2;233;230;255m");
my $last = ""; print "\n";
while (<STDIN>) {
  s/\r//g;
  if (/^Server:\s+(\S+)/) { print "  $D\x{f233}  server   $W$1$R\n"; next }
  if (/^Address:\s+\S+#\d+/) { next }
  if (/Non-authoritative/) { print "  $D\x{f05a}  non-authoritative answer$R\n"; next }
  if (/^Name:\s+(\S+)/) { next if $1 eq $last; $last = $1; print "\n  $C\e[1m\x{f0ac}  $1$R\n"; next }
  if (/^Address:\s+(\S+)/) { my $a = $1; print $a =~ /:/ ? "     ${D}v6  $L$a$R\n" : "     ${D}v4  $C$a$R\n"; next }
  if (/can't find|NXDOMAIN|SERVFAIL|timed out/i) { print "  $P✘  $_$R"; next }
  print if /\S/;
}
print "\n";
