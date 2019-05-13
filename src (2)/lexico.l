%{
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "defs.h"
#include "common.h"

#include "y.tab.h"

void yyerror(char *);
int yyparse(void);
int fileno(FILE * stream);

/* à compléter : variables globales éventuelles */
char * infile = NULL;


%}

%option yylineno

/* à compléter : définitions */

%%

/* à compléter : règles */

"void"          return TOK_VOID;

{IDF} {
                yylval.strval = strdup(yytext);
                return TOK_IDENT;
}


[ \t\n]+

. {
                fprintf(stderr, "Error line %d: Lexical error\n", yylineno);
                exit(1);
}


%%

int yywrap(void) {
    return 1;
}



int main(int argc, char ** argv) {
    /* à compléter */
    // ...

    yyin = fopen(infile, "r");
    yyparse();
    fclose(yyin);
    yylex_destroy();
    return 0;
}




