package Enbugger;

use strict;

use vars '$VERSION';
$VERSION = '0.02';

# Load the source code for all loaded files. Too bad about (eval 1)
# though. This doesn't work. Why not!?!
for my $file ( $0, values %INC ) {
    next if not -e $file;
    _load_file($file);
}

# Load the main debugger.
my $class = caller;
eval "package $class; require 'perl5db.pl';";    ## no critic
_load_file($_) for grep /perl5db.pl/, values %INC;

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
    @$symname = <$fh>;
    %$symname = ();
    $$symname = $symname;
}

# Convenience functions to support `use Enbugger' and `no Enbugger'.
sub import {
    $DB::single = 2;
}

sub unimport {
    $DB::single = 0;
}

# Now do the *real* work.
require XSLoader;
XSLoader::load( 'Enbugger', $VERSION );

no warnings 'void';    ## no critic
'But this is the internet, dear, stupid is one of our prime exports.'

__END__

=head1 NAME

Enbugger - Turns the debugger on at runtime.

=head1 SYNOPSIS

  eval { ... };
  if ( $@ ) {
      # Oops! there was an error! Enable the debugger now!
      require Enbugger;
      $DB::single = 2;
  }

=head1 DESCRIPTION

Enables or disables the debugger at runtime regardless of whether your
process was started with debugging on.

=head2 ENABLING THE DEBUGGER

The debugger is loaded automatically when Enbugger is loaded. Calling
C<< Enbugger->import >> also enables single stepping. This is optional
but it seems like a reasonable default.

  # Installs the debugger.
  require Enbugger;

  # Enables the debugger
  Enbugger->import;

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
  };

=head2 DEBUGGING ON SIGNAL

You could include this snippet in your program and trigger the
debugger on SIGUSR1. Then later, when you're wondering what's up with
your process, send it SIGUSR1 and it starts the debugger on itself.

  $SIG{USR1} = sub {
      require Enbugger;
      $DB::single = 2;
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
