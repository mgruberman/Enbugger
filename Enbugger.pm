package Enbugger;

use strict;

use vars '$VERSION';
$VERSION = '1.00';

sub perl5db {

    # Load the main debugger.
    package DB;
    my $class = caller;
    ## no critic eval
    eval <<"PERL5DB";
        package $class;
        require 'perl5db.pl';
        Enbugger::_load_source();
PERL5DB
}

sub ebug {

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

sub ptkdb {

    package DB;
    my $class = caller;
    ## no critic eval
    eval <<"PTKDB";
        package $class;
        require Devel::ptkdb;
        Enbugger::_load_source();
PTKDB
}

sub sdb {

    package DB;
    my $class = caller;
    ## no critic eval
    eval <<"PTKDB";
        package $class;
        require Devel::sdb;
        Enbugger::_load_source();
PTKDB
}

sub _load_source {
    _load_file($0);
    _load_file($_) for grep {-e} values %INC;
}

sub _load_file {
    my ($file) = @_;

    my $fh;
    if ( not open $fh, '<', $file ) {
        warn "Can't open $file for reading: $!";
        return;
    }

    my $symname = "_<$file";
    local $/ = "\n";
    no strict 'refs';    ## no critic
    @$symname = readline $fh;
    %$symname = ();
    $$symname = $symname;
}

# Convenience functions to support `use Enbugger' and `no Enbugger'.
sub import {
    my $class = shift @_;
    $DB::single = 2;

    my $debugger = shift(@_) || 'perl5db';
    if ($debugger) {
        $class->$debugger;
    }
}

sub unimport {
    $DB::single = 0;
}

# Now do the *real* work.
my $old_single = $DB::single;
$DB::single = 0;
require XSLoader;
XSLoader::load( 'Enbugger', $VERSION );
require B::Utils;

# Load the source code for all loaded files. Too bad about (eval 1)
# though. This doesn't work. Why not!?!
_load_source();

B::Utils::walkallops_filtered(
    sub {
        B::Utils::opgrep(
            {   name    => 'nextstate',
                stashpv => '!DB'
            },
            @_
        );
    },
    sub { Enbugger::_alter_cop( $_[0] ) }
);

$DB::single = $old_single;

no warnings 'void';    ## no critic
'But this is the internet, dear, stupid is one of our prime exports.'

__END__

=head1 NAME

Enbugger - Enables the debugger at runtime.

=head1 SYNOPSIS

  eval { ... };
  if ( $@ ) {
      # Oops! there was an error! Enable the debugger now!
      require Enbugger;
      $DB::single = 2;
      Enbugger->import( 'ebug' );
  }

=head1 DESCRIPTION

Allowes the use of the debugger at runtime regardless of whether your
process was started with debugging on.

=head2 ENABLING THE DEBUGGER

The debugger is loaded automatically when Enbugger is loaded. Calling
C<< Enbugger->import >> also enables single stepping. This is optional
but it seems like a reasonable default.

  # Installs the debugger.
  require Enbugger;

  # Enables the debugger
  Enbugger->import( 'perl5db' );

Or...

  eval 'use Enbugger';

=head2 DISABLING THE DEBUGGER

Disables single stepping.

  Enbugger->unimport;

Or...

  eval 'no Enbugger';

=head1 EXAMPLES

=head2 DEBUGGING ON EXCEPTION

Maybe you don't expect anything to die but on the chance you do, you'd
like to do something about.

  $SIG{__DIE__} = sub {
      require Enbugger;
      $DB::single = 3;
      Enbugger->import( 'ptkdb' );
  };

=head2 DEBUGGING ON SIGNAL

You could include this snippet in your program and trigger the
debugger on SIGUSR1. Then later, when you're wondering what's up with
your process, send it SIGUSR1 and it starts the debugger on itself.

  $SIG{USR1} = sub {
      require Enbugger;
      $DB::single = 2;
      Enbugger->import( 'sdb' );
  };

Later:

  $ kill -USR1 12345

=head1 INSTALLATION

To install this module type the following:

   perl Makefile.PL
   make
   make test
   make install

=head1 DEPENDENCIES

A C compiler.

=head1 AUTHOR

Josh ben Jore <jjore@cpan.org>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2007 by Josh ben Jore

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
