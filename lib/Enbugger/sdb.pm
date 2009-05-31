package Enbugger::sdb;

sub debugger {

    package DB;
    my $class = caller;
    ## no critic eval
    eval <<"PTKDB";
        package $class;
        require Devel::sdb;
        Enbugger::_load_source();
PTKDB
}

