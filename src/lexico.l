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
char * infile = "test.c";


%}

%option yylineno

    /* à compléter : définitions */
    /* à compléter : règles */

LETTRE              [A-Za-z]
CHIFFRE             [0-9]
CHIFFRE_NON_NUL     [1-9]
ENTIER_DEC          0|{CHIFFRE_NON_NUL}({CHIFFRE})*|{CHIFFRE}
LETTRE_HEXA         [A-Fa-f]
SIGNE               -?
ENTIER_HEXA         0x({CHIFFRE}|{LETTRE_HEXA})

ENTIER              {SIGNE}({ENTIER_DEC}|{ENTIER_HEXA})

IDF                 {LETTRE}(_|{LETTRE}|{CHIFFRE})*
CHAINE_CAR          [\x20-\x21\x22-\x5c]
CHAINE              \"(\\.|[^"\\])*\"


%%


"void"          return TOK_VOID;
"int"           return TOK_INT;
"bool"          return TOK_BOOL;
"true"          return TOK_TRUE;
"false"         return TOK_FALSE;
"if"            return TOK_IF;
"else"          return TOK_ELSE;
"while"         return TOK_WHILE;
"for"           return TOK_FOR;
"print"         return TOK_PRINT;
"="             return TOK_AFFECT;
">="            return TOK_GE;
"<="            return TOK_LE;
">"             return TOK_GT;
"<"             return TOK_LT;
"=="            return TOK_EQ;
"!="            return TOK_NE;
"&&"            return TOK_AND;
"&"             return TOK_BAND;
"|"            return TOK_BOR;
"||"            return TOK_OR;
"+"             return TOK_PLUS;
"-"             return TOK_MINUS;
"*"             return TOK_MUL;
"/"             return TOK_DIV;
"%"             return TOK_MOD;
";"             return TOK_SEMICOL;
","             return TOK_COMMA;
"("             return TOK_LPAR;
")"             return TOK_RPAR;
"{"             return TOK_LACC;
"}"             return TOK_RACC;
"do"            return TOK_DO;




{IDF} {
                yylval.strval = strdup(yytext);
                return TOK_IDENT;
}

{ENTIER} {
                yylval.intval = atoi(yytext);
                return TOK_INTVAL;
}

{CHAINE} {
                yylval.strval = strdup(yytext);
                return TOK_STRING;
}


[ \t\n]+

[/]+.*

. {
                fprintf(stderr, "Error line %d: Lexical error\n", yylineno);
                exit(1);
}


%%

int yywrap(void) {
    return 1;
}



int main(int argc, char ** argv) {

    infile = argv[1];
    if(infile == NULL){
        printf("Error: input file not given\n\nCorrect Usage: ./minicc <infile>\n");
        return 1;
    }


    yyin = fopen(infile, "r");
    if(yyin == NULL){
    	printf("error opening file");
    	return 1;
    	}
    yyparse();

    fclose(yyin);
    yylex_destroy();
    return 0;
}
