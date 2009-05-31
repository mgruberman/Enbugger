#!/usr/bin/perl
use Enbugger::OnError;

foo();

sub foo {
	my $hello = 'world';
	die;
}
