package Enbugger::ebug;

sub debugger {

    package DB;
    my $class = caller;
    ## no critic eval
    eval <<"EBUG";
        package $class;
        require Devel::ebug::Console;
        my \$console = Devel::ebug::Console->new;
        Enbugger::_load_source();
        \$console->run;
EBUG
}

() = -.0
