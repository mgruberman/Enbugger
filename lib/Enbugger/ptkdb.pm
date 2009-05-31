package Enbugger::ptkdb;

sub debugger {
    package DB;
    my $class = caller;
    ## no critic eval
    eval <<"PTKDB";
        package $class;
        require Devel::ptkdb;
        Enbugger::_load_source();
PTKDB
}

() = -.0
