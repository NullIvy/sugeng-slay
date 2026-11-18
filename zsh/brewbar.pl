$| = 1; $/ = "\r";
while (<STDIN>) { s/(={4,}|#{4,})/"\e[38;2;169;156;255m" . ("▰" x length($1)) . "\e[0m"/ge; print STDERR $_; }
