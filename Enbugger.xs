#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = Enbugger		PACKAGE = Enbugger	PREFIX = Enbugger

PROTOTYPES: DISABLE

void
Enbugger_alter_cop( o )
		SV * o
	PREINIT:
		COP* cop;
	CODE:
		if (!( SvOK(o) && SvROK(o) && SvIOK(SvRV(o)) )) {
		   warn("SvOK(o)=%d SvROK(o)=%d SvIOK(SvRV(o))=%d\n",SvOK(o),SvROK(o),SvIOK(SvRV(o)));
		   croak("_alter_cop($o) expects a B::COP object.");
		}
		cop = INT2PTR( COP*, SvIV( SvRV( o ) ) );
		cop->op_type = OP_DBSTATE;
		cop->op_ppaddr = PL_ppaddr[ OP_DBSTATE ];

BOOT:
	PL_perldb = PERLDB_ALL;
	PL_ppaddr[ OP_NEXTSTATE ]
		   = PL_ppaddr[ OP_DBSTATE   ]
		   = Perl_pp_dbstate;
	Perl_init_debugger( aTHX );

