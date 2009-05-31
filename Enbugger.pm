package Enbugger;

use strict;

use vars '$VERSION';
$VERSION = '0.01';

local $@;
my $class = caller;
eval "package $class; require 'perl5db.pl'";
die $@ if $@;
undef $class;

sub import {
    $DB::single = 2;
}

sub unimport {
    $DB::single = 0;
}

require XSLoader;
XSLoader::load( 'Enbugger', $VERSION );

1;

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
