package Enbugger::OnError;
use strict;
use warnings;
use Carp();

use constant {
	'DEFAULT_SIGNALS' => [qw[ __DIE__ USR1 ]],
	'DEFAULT_HOOK'    => \&DB::Enbugger_OnError_ExceptionHandler,
};

sub import {
	my ( $class, @signals ) = @_;

	my $hook = $class->DEFAULT_HOOK;

	$class->hook_signals(
		(   @signals
			? \@signals
			: $class->DEFAULT_SIGNALS
		),
		$hook
	);

	return;
}

sub hook_signals {
	my ( $self, $signals, $hook ) = @_;

	@SIG{@$signals} = ($hook) x @$signals;

	return;
}

package DB;

sub Enbugger_OnError_ExceptionHandler {

	# Enable the debugger even if it wasn't used at compilation time.
	require Enbugger;
	Enbugger->perl5db;

	# Log the current exception.
	no warnings 'once';
	print {$DB::OUT} Carp::longmess(@_);

	# Trigger the debugger.
	local $DB::signal = 1;
	local $^P ||= 0x02;
	DB::DB();
}

() = -.0
