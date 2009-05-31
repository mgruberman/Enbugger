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
	/* TODO: PL_debstash = GvHV(gv_fetchpvs("DB::", GV_ADDMULTI, SVt_PVHV)); */

	/* Copied right out ouf perl.c */
	sv_setpvn(PERL_DEBUG_PAD(0), "", 0);  /* For regex debugging. */
	sv_setpvn(PERL_DEBUG_PAD(1), "", 0);  /* ext/re needs these */
	sv_setpvn(PERL_DEBUG_PAD(2), "", 0);  /* even without DEBUGGING. */

	PL_perldb = PERLDB_ALL;
	PL_ppaddr[ OP_NEXTSTATE ]
		   = PL_ppaddr[ OP_DBSTATE   ]
		   = Perl_pp_dbstate;
	Perl_init_debugger( aTHX );
