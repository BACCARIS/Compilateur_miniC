%{
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>

#include "defs.h"
#include "common.h"


/* Global variables */

// à compléter


/* prototypes */
int yylex(void);
extern int yylineno;

void yyerror(char *s);
void analyse_tree(node_t root);

// à compléter

%}

%union {
    int32_t intval;
    char * strval;
    node_t ptr;
};


/* à compléter : définition des tokens et de leur associativité */

%token TOK_VOID
%token TOK_INT
%token TOK_INTVAL
%token TOK_BOOL
%token TOK_TRUE
%token TOK_FALSE
%token TOK_IDENT
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_FOR
%token TOK_PRINT
%token TOK_AFFECT
%token TOK_GE
%token TOK_LE
%token TOK_GT
%token TOK_LT
%token TOK_EQ
%token TOK_NE
%token TOK_PLUS
%token TOK_MINUS
%token TOK_MUL
%token TOK_DIV
%token TOK_MOD
%token TOK_UMINUS
%token TOK_SEMICOL
%token TOK_COMMA
%token TOK_LPAR
%token TOK_RPAR
%token TOK_LACC
%token TOK_RACC
%token TOK_STRING
%token TOK_DO


%nonassoc TOK_THEN
%nonassoc TOK_ELSE


/* a = b = c + d <=> b = c + d; a = b; */
%right TOK_AFECT

%left   TOK_OR
%left   TOK_AND
%left   TOK_BOR
%left   TOK_BXOR
%left   TOK_BAND
%left   TOK_EQ TOK_NE
%left   TOK_GT TOK_LT TOK_GE TOK_LE
%left   TOK_SRL TOK_SRA ROK_SLL

/* a / b / c = (a / b) / c et a - b - c = (a - b) - c */
%left   TOK_PLUS TOK_MINUS
%left   TOK_MUL TOK_DIV TOK_MOD

%left   TOK_UMINUS TOK_NOT TOK_BNOT

%type <intval> TOK_INTVAL
%type <strval> TOK_IDENT TOK_STRING

%type <ptr> program listdeclnonnull vardecl ident type listtypedecl decl main listdecl

%type <ptr> listinst listinstnonnull inst block exp printparam_list printparam


%%

/* à compléter : grammaire hors-contexte et construction de l'arbre */

program:
        listdecl main
        {
            $$ = make_node(NODE_PROGRAM, 2, $1, $2);
            analyse_tree($$);
        }
        ;

listdecl:
        listdeclnonnull 
        |
        {
        	$$ = NULL;
        }
        ;

listdeclnonnull: 
                vardecl
                | listdeclnonnull vardecl
                {
                	$$ = make_node(NODE_LIST, 2, $1, $2);
                }
                ;

vardecl:
        type listtypedecl TOK_SEMICOL
        {
        	$$ = make_node(NODE_DECLS, 2, $1, $2);
        }
        ;

type:
    TOK_INT
    |TOK_BOOL
    |TOK_VOID
    {
    $$ = make_node(NODE_TYPE, 0);
	}
    ;

listtypedecl:
            decl
            | listtypedecl TOK_COMMA decl
            ;

decl:
    ident
    {
    	$$ = make_node(NODE_DECL, 1, $1);
	}
    | ident TOK_AFFECT exp
	{
    	$$ = make_node(NODE_DECL, 2, $1, $3);
	}
    ;
  
listdecl : listdecl decl
		{
		    $$ = make_node(NODE_LIST, 2, $1, $2);
		}
		| decl
		{
		    $$ = $1;
		}
		;

main:
    type ident TOK_LPAR TOK_RPAR block
    {
    	$$ = make_node(NODE_FUNC, 3, $1, $2, $5);
    }
    ;

listinst:
        listinstnonnull
        |
        {
        	$$ = NULL;
        }
        ;

listinstnonnull : inst
				{
				    $$ = $1;
				}
                | listinstnonnull inst
                {
				    $$ = make_node(NODE_LIST, 2, $1, $2);
				}
                ;

inst            : exp TOK_SEMICOL
				{
				    $$ = $1;
				}
                | TOK_IF TOK_LPAR exp TOK_RPAR inst %prec TOK_THEN
                {
				    $$ = make_node(NODE_IF, 2, $3, $5);
				}
                | TOK_IF TOK_LPAR exp TOK_RPAR inst TOK_ELSE inst
                {
				    $$ = make_node(NODE_IF, 3, $3, $5, $7);
				}
                | TOK_WHILE TOK_LPAR exp TOK_RPAR inst
             	{
				    $$ = make_node(NODE_WHILE, 2, $3, $5);
				}
                | TOK_FOR TOK_LPAR exp TOK_SEMICOL exp TOK_SEMICOL exp TOK_RPAR inst
                {
				    $$ = make_node(NODE_FOR, 4, $3, $5, $7, $9);
				}
                | TOK_DO inst TOK_WHILE TOK_LPAR exp TOK_RPAR TOK_SEMICOL
                {
				    $$ = make_node(NODE_DOWHILE, 2, $5, $2);
				}
                | block
                {
				    $$ = $1;
				}
                | TOK_SEMICOL
                | TOK_PRINT TOK_LPAR printparam_list TOK_RPAR TOK_SEMICOL
                {
				    $$ = make_node(NODE_PRINT, 1, $3);
				}
                ;

block:
    TOK_LACC listdecl listinst TOK_RACC
    {
    	$$ = make_node(NODE_BLOCK, 2, $2, $3);
	}
    ;

exp:
    exp TOK_MUL exp
    {
    	$$ = make_node(NODE_MUL, 2, $1, $3);  
	}
    | exp TOK_DIV exp
    {
    	$$ = make_node(NODE_DIV, 2, $1, $3);  
	}
    | exp TOK_PLUS exp
    {
    	$$ = make_node(NODE_PLUS, 2, $1, $3);  
	}
    | exp TOK_MINUS exp
    {
    	$$ = make_node(NODE_MINUS, 2, $1, $3);  
	}
    | exp TOK_MOD exp
    {
    	$$ = make_node(NODE_MOD, 2, $1, $3);  
	}
    | exp TOK_LT exp
    {
    	$$ = make_node(NODE_LT, 2, $1, $3);  
	}
    | exp TOK_GT exp
    {
    	$$ = make_node(NODE_GT, 2, $1, $3);  
	}
    | TOK_MINUS exp %prec TOK_MINUS
    {
    	$$ = make_node(NODE_MINUS, 1, $2);  
	}
    | exp TOK_GE exp
    {
    	$$ = make_node(NODE_GE, 2, $1, $3);  
	}
    | exp TOK_LE exp
    {
    	$$ = make_node(NODE_LE, 2, $1, $3);  
	}
    | exp TOK_EQ exp
    {
    	$$ = make_node(NODE_EQ, 2, $1, $3);  
	}
    | exp TOK_NE exp
    {
    	$$ = make_node(NODE_NE, 2, $1, $3);  
	}
    | exp TOK_AND exp
    {
    	$$ = make_node(NODE_AND, 2, $1, $3);  
	}
    | exp TOK_OR exp
    {
    	$$ = make_node(NODE_OR, 2, $1, $3);  
	}
    | exp TOK_BAND exp
    {
    	$$ = make_node(NODE_BAND, 2, $1, $3);  
	}
    | exp TOK_BOR exp
    {
    	$$ = make_node(NODE_BOR, 2, $1, $3);  
	}
    | exp TOK_BXOR exp
    {
    	$$ = make_node(NODE_BXOR, 2, $1, $3);  
	}
    | exp TOK_SRL exp
    {
    	$$ = make_node(NODE_SRL, 2, $1, $3);  
	}
    | exp TOK_SRA exp
    {
    	$$ = make_node(NODE_SRA, 2, $1, $3);  
	}
    /* | exp TOK_SLL exp */
    | TOK_NOT exp
    {
    	$$ = make_node(NODE_NOT, 1, $2);  
	}
    | TOK_BNOT exp
    {
    	$$ = make_node(NODE_BNOT, 1, $2);  
	}
    | TOK_LPAR exp TOK_RPAR
    {
    	$$ = make_node(NODE_LPAR, 1, $2);  
	}
    | ident TOK_AFFECT exp
    {
    	$$ = make_node(NODE_AFFECT, 1, $1);  
	}
    | TOK_INTVAL
    {
    	$$ = make_node(NODE_INTVAL, 0);  
	}
    | TOK_TRUE
    {
    	$$ = make_node(NODE_TRUE, 0);  
	}
    | TOK_FALSE
    {
    	$$ = make_node(NODE_FALSE, 0);  
	}
    | TOK_STRING
    {
    	$$ = make_node(NODE_STRING, 0);  
	}
    | ident
    {
    	$$ = $1;
	}
    ;

printparam_list:
                printparam_list TOK_COMMA printparam
                {
    				$$ = make_node(NODE_LIST, 2, $1, $3);
				}
                | printparam
                {
    				$$ = $1;
				}
                ;

printparam:
            ident
            {
    			$$ = $1;
			}
            | TOK_STRING
            {
			    $$ = make_node(NODE_STRINGVAL, 0);
			}
            ;

ident:
    TOK_IDENT
    {
    	$$ = make_node(NODE_IDENT, 1, $1);
    }
    ;



%%

/* à compléter : fonctions de création des noeuds de l'arbre */

node_t make_node(node_nature nature , int nbArg, ...)
{
	node_t ptr = malloc(sizeof(node_t));

	ptr -> node_nature = nature;
    
    // node_type type;
	// int64_t value;
    // int32_t offset;
    // bool global_decl;
    // int32_t lineno;
    // int32_t stack_size;
	
	ptr ->nops = nbArg;

	node_t * opr = malloc(sizeof(node_t)*nbArg);
	ptr -> opr = opr;

    
    // struct _node_s * decl_node;

    // char * ident;
    if ( nature = NODE_IDENT ){
    	*ident = truc;
    }


    // char * str;

    // Pour l'afichage du graphe
    // int32_t node_num;


    return ptr;
}




void analyse_tree(node_t root) {
    /* à compléter */
}



void yyerror(char * s) {
    fprintf(stderr, "Error line %d: %s\n", yylineno, s);
    exit(1);
}