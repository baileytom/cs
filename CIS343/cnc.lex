%{
	#include "cnc.tab.h"
	#include <stdlib.h>
%}

%option noyywrap

%%

G[0-9]+X[0-9]+Y[0-9]+Z[0-9] { return EXPR; }
ZERO		            { return ZERO; }
;                           { return END_STATEMENT; }
END                         { return END; }

%%
