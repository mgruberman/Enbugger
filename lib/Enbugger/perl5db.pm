package Enbugger::perl5db;

sub debugger {

    # Load the main debugger.
    package DB;

	eval <<'PERL5DB_FUNCTIONS';
		sub frame {}
		sub select_frame {}
PERL5DB_FUNCTIONS

    my $class = caller;
    ## no critic eval
    eval <<"PERL5DB";
        package $class;
        require 'perl5db.pl';
        Enbugger::_load_source();
PERL5DB
}

package DB;

%DB::alias = (
	%DB::alias,
	frame          => 'DB::frame',
	'select-frame' => 'DB::select_frame',
	'proceed-at'   => 'DB::proceed_at',
	'restart-at'   => 'DB::restart_at',
);

sub frame { warn 'NOT IMPLEMENTED' }
sub select_frame { warn 'NOT IMPLEMENTED' }
sub restart_at {
	
}

() = -.0
