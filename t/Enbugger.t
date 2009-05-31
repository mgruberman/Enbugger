BEGIN { print "1..1\n" }
$ENV{PERLDB_OPTS} = 'NonStop=1';
require Enbugger;
print "ok 1\n";
