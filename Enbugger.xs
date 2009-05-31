#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

int (*old_runops)( pTHX );
int runops_enbug ( pTHX ) {
	while ( PL_op ) {
 		if ( PL_op->op_type == OP_NEXTSTATE ) {
			PL_op->op_type = OP_DBSTATE;
			PL_op->op_ppaddr = PL_ppaddr[ OP_DBSTATE ];
		}

		PL_op = CALL_FPTR( PL_op->op_ppaddr )( aTHX );

		PERL_ASYNC_CHECK();
	}

	TAINT_NOT;
	return 0;
}

MODULE = Enbugger		PACKAGE = Enbugger	PREFIX = Enbugger

PROTOTYPES: ENABLE

void
Enbugger_install_enbug()
	PROTOTYPE:
	CODE:
		PL_runops = runops_enbug;

void
Enbugger_remove_enbug()
	PROTOTYPE:
	CODE:
		PL_runops = old_runops;

BOOT:
	old_runops = PL_runops;
	Perl_init_debugger( aTHX );
	PL_runops = runops_enbug;

