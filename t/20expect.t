#!perl
use Test::More tests => 2;
use Data::Dumper 'Dumper';
sub cleanup { unlink '.perldb', '.perldb.out' }
BEGIN { cleanup() }
END { cleanup() }

try( 't/20expect.pl', [ 'y 1' ], qr/y 1\n\$hello = 'world'/ );
try( 't/20expect.pl', [ 'f t/20expect.pl', 'l 1-10' ], qr/sub foo \{/ );
exit;

sub try {
	my ( $program, $commands, $like ) = @_;
	open my($rc), '>', '.perldb'
		or die "Can't write to .perldb: $!";
	{
		local $Data::Dumper::Terse = 3;
		local $Data::Dumper::Purity = 1;
		print { $rc } <<".PERLDB" or die "Can't write to .perldb: $!";
parse_options( 'NonStop=0 TTY=.perldb.out LineInfo=.perldb.out' );
push \@DB::typeahead, @{[ join ', ', map { Dumper( $_ ) } @$commands ]}, 'q';
.PERLDB
	}
	close $rc
		or die "Can't flush .perldb: $!";
	system $^X, '-Mblib', $program;
	$? == 0
		or die "Can't run $^X -Mblib $program: $?";

	open $rc, '<', '.perldb.out'
		or die "Can't open .perldb: $!";
	local $/;
	like( scalar <$rc>, $like );
}
