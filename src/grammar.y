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
node_t make_node(node_nature nature , int nbArg, ...);
node_t make_final_node(node_nature nature , int nbArg, ...);

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
%right TOK_AFFECT

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

%type <ptr> program listdecl listdeclnonnull vardecl ident type listtypedecl decl maindecl

%type <ptr> listinst listinstnonnull inst block expr listparamprint paramprint


%%

/* à compléter : grammaire hors-contexte et construction de l'arbre */

program:
        listdeclnonnull maindecl  
        {
            $$ = make_node(NODE_PROGRAM, 2, $1, $2);
            printf("PROGRAM\n");
        }
        | maindecl
        {
            $$ = make_node(NODE_PROGRAM, 2, NULL, $1 );
            printf("PROGRAMnull\n");
        }
        ;

listdecl:
        listdeclnonnull
        {
          $$ = $1;
          printf("listdeclnonnull\n");

        }
        |
        {
          $$ = NULL; 
          printf("listdeclnull\n");
        }
        ;


listdeclnonnull:
                vardecl
                {
                  $$ = $1;
                  printf("listdeclnonnull\n");
                }
                | listdeclnonnull vardecl
                {
                	$$ = make_node(NODE_LIST, 2, $1, $2);
                  printf("listdeclnonnull\n");
                }
                ;

vardecl:
        type listtypedecl TOK_SEMICOL
        {
        	$$ = make_node(NODE_DECLS, 2, $1, $2);
          printf("vardecl\n");
        }
        ;

type:
    TOK_INT
    {
    	 $$ = make_final_node(NODE_TYPE, 1, TYPE_INT);
       printf("typeInt\n");
    }
    | TOK_BOOL
    {
    	 $$ = make_final_node(NODE_TYPE, 1, TYPE_BOOL);
       printf("typeBool\n");
    }
    | TOK_VOID
    {
     	$$ = make_final_node(NODE_TYPE, 1, TYPE_VOID);
      printf("typeVoid\n");
	}
    ;

listtypedecl:
            decl
            {
              $$ = $1;
              printf("listtypedecl\n");
            }
            | listtypedecl TOK_COMMA decl
            {
              $$ = $3;
              printf("listtypedecl\n");
            }
            ;

decl:
    ident
    {
      printf("decl\n");
    	$$ = make_node(NODE_DECL, 2, $1, NULL);
      
    }
    | ident TOK_AFFECT expr
    {
    	$$ = make_node(NODE_DECL, 2, $1, $3);
      printf("TOK_AFFECT\n");
    }
    ;

maindecl:
    type ident TOK_LPAR TOK_RPAR block
    {
    	$$ = make_node(NODE_FUNC, 3, $1, $2, $5);
      printf("main\n");

    }
    ;

listinst:
        listinstnonnull
        {
          $$ = $1;
          printf("listinst\n");
        }
        |
        {
        	$$ = NULL;
          printf("listinstnull\n");
        }
        ;

listinstnonnull :
        inst
				{
				    $$ = $1;
            printf("listinstnonnull\n");
				}
        | listinstnonnull inst
        {
				    $$ = make_node(NODE_LIST, 2, $1, $2);
            printf("listinstnonnull\n");
				}
                ;

inst            :
        expr TOK_SEMICOL
				{
				    $$ = $1;
            printf("inst\n");
				}
                | TOK_IF TOK_LPAR expr TOK_RPAR inst %prec TOK_THEN
                {
				    $$ = make_node(NODE_IF, 2, $3, $5);
            printf("inst\n");
				}
                | TOK_IF TOK_LPAR expr TOK_RPAR inst TOK_ELSE inst
                {
				    $$ = make_node(NODE_IF, 3, $3, $5, $7);
            printf("inst\n");
				}
                | TOK_WHILE TOK_LPAR expr TOK_RPAR inst
             	{
				    $$ = make_node(NODE_WHILE, 2, $3, $5);
            printf("inst\n");
				}
                | TOK_FOR TOK_LPAR expr TOK_SEMICOL expr TOK_SEMICOL expr TOK_RPAR inst
                {
				    $$ = make_node(NODE_FOR, 4, $3, $5, $7, $9);
            printf("inst\n");
				}
                | TOK_DO inst TOK_WHILE TOK_LPAR expr TOK_RPAR TOK_SEMICOL
                {
				    $$ = make_node(NODE_DOWHILE, 2, $5, $2);
            printf("inst\n");
				}
                | block
                {
				    $$ = $1;
            printf("inst\n");
				}
                | TOK_SEMICOL
                {
                  $$ = NULL;
                  printf("inst\n");
                }
                | TOK_PRINT TOK_LPAR listparamprint TOK_RPAR TOK_SEMICOL
                {
				    $$ = make_node(NODE_PRINT, 1, $3);
            printf("inst\n");
				}
                ;

block:
    TOK_LACC listdecl listinst TOK_RACC
    {
    	$$ = make_node(NODE_BLOCK, 2, $2, $3);
      printf("block\n");
    }
    ;

expr:
    expr TOK_MUL expr
    {
      $$ = make_node(NODE_MUL, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_DIV expr
    {
      $$ = make_node(NODE_DIV, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_PLUS expr
    {
      $$ = make_node(NODE_PLUS, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_MINUS expr
    {
      $$ = make_node(NODE_MINUS, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_MOD expr
    {
      $$ = make_node(NODE_MOD, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_LT expr
    {
      $$ = make_node(NODE_LT, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_GT expr
    {
      $$ = make_node(NODE_GT, 2, $1, $3);
      printf("exp\n");
    }
    |
    TOK_MINUS expr %prec TOK_MINUS
    {
     //$$ = make_node(NODE_UMINUS, 1, $2);
      printf("exp\n");
    }
    | expr TOK_GE expr
    {
      $$ = make_node(NODE_GE, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_LE expr
    {
      $$ = make_node(NODE_LE, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_EQ expr
    {
      $$ = make_node(NODE_EQ, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_NE expr
    {
      $$ = make_node(NODE_NE, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_AND expr
    {
      $$ = make_node(NODE_AND, 2, $1, $3);
      printf("exp\n");
    }
    | expr TOK_OR expr
    {
      $$ = make_node(NODE_OR, 2, $1, $3);
      printf("exp\n");
    }
    | ident TOK_AFFECT expr
    {
      $$ = make_node(NODE_AFFECT, 2, $1, $3);
      printf("exp\n");
    }
    | TOK_INTVAL
    {
      $$ = make_final_node(NODE_INTVAL, 0);
      printf("exp");
    }
    | TOK_TRUE
    {
      $$ = NULL;
      printf("exp\n");
    }
    | TOK_FALSE
    {
      $$ = NULL;
      printf("exp\n");
    }
    | TOK_STRING
    { 
      $$ = make_final_node(NODE_STRINGVAL, 0);
      printf("exp\n");
    }
    |
    ident
    {
    	$$ = $1;
      printf("exp\n");
    }
    ;

listparamprint:
                listparamprint TOK_COMMA paramprint
                {
    				$$ = make_node(NODE_LIST, 2, $1, $3);
            printf("printparm_list\n");
				}
                | paramprint
                {
    				$$ = $1;
              printf("printparm_list\n"); 
				}
                ;

paramprint:
      ident
      {
    			$$ = $1;
            printf("printparm");
			}
      | TOK_STRING
            {
			    $$ = make_final_node(NODE_STRINGVAL, 0);
            printf("printparm\n");
			}
            ;

ident:
    TOK_IDENT
    {
    	$$ = make_final_node(NODE_IDENT, 0);
        printf("ident\n");
    }
    ;



%%

/* à compléter : fonctions de création des noeuds de l'arbre */

node_t make_node(node_nature nature , int nbArg, ...)
{
	printf("\n\n\n--> nature noeud courant %s\n", node_nature2string(nature));
	printf("nombre argument   : %d\n", nbArg);

	int i = 0;

	// allocation de memoire pour le noeud
	node_t nouveau_noeud = malloc(sizeof(node_s));

	nouveau_noeud -> nature = nature;
	nouveau_noeud -> nops = nbArg; 	// nombre d enfants du noeud

	// ------ On cree les fils ------
	if (nbArg > 0){
		nouveau_noeud -> opr = malloc(nbArg * sizeof(node_s*));

		if( !nouveau_noeud -> opr ){
			printf("allocation fils non reussite");
			exit(0);
		}

		va_list arg_noeud;
		va_start(arg_noeud, nbArg);

		//node_t depile = va_arg(arg_noeud, node_t);

		for( i = 0; i < nbArg; i++){
			nouveau_noeud->opr[i] = va_arg(arg_noeud, node_t);

			if(nouveau_noeud->opr[i]== NULL){
				printf("------>nil/null\n");
			}
			else{
				//provoque segfault si $$=null
				//printf("nature fils : %s\n", node_nature2string(nouveau_noeud->opr[i]->nature));
				if(!nouveau_noeud->opr[i]->nature){
					printf("nature fils : NONE");
					nouveau_noeud->opr[i]->nature = NONE;
				}
				else{
					printf("nature fils : %s\n", node_nature2string(nouveau_noeud->opr[i]->nature));
				}
			}
		}
		va_end(arg_noeud);

		if(nature == NODE_PROGRAM){
			//printf("fils program : %s\n", node_nature2string(nouveau_noeud->opr[0]->nature));
			//dump_tree(nouveau_noeud, "output.dot");
		}
	}

	/*	// ------ On remplie le noeud ------
	nouveau_noeud -> nature = nature;
	nouveau_noeud -> nops = nbArg; 	// nombre d enfants du noeud

	nouveau_noeud -> lineno = yylineno;

	if( nature == NODE_IDENT)
	{
	nouveau_noeud -> ident = yylval.strval;
	}

	if( nature == NODE_TYPE){
	nouveau_noeud -> type = yylval.ptr -> type;
	}

	if( nature == NODE_INTVAL || nature == NODE_BOOLVAL ){
	nouveau_noeud -> value = (int64_t)yylval.intval;
	}

	if( nature == NODE_STRINGVAL){
	nouveau_noeud -> str = yylval.strval; //  A REVOIR
	}

	if( nature == NODE_STRINGVAL){
	nouveau_noeud -> value = (int64_t)yylval.strval;
	}

	*/


	if(nature == NODE_PROGRAM){
		//printf("fils program : %s\n", node_nature2string(nouveau_noeud->opr[0]->nature));
		//dump_tree(nouveau_noeud, "output.dot");
	}

    return nouveau_noeud;
}


node_t make_final_node(node_nature nature , int nbArg, ...)
{
  node_t nouveau_noeud = malloc(sizeof(node_t));
  nouveau_noeud->nature = nature;
  printf("nature  : %s\n", node_nature2string(nouveau_noeud->nature));
  va_list arg_noeud;
  va_start(arg_noeud, nbArg);

  switch(nature)
  {
    case NODE_TYPE : 
    {
      nouveau_noeud-> type = va_arg(arg_noeud, node_type);

    }

    case NODE_IDENT : 
    {
     
    }

    case NODE_INTVAL : 
    {

    }
  }

  return nouveau_noeud;
}


void analyse_tree(node_t root) {
    /* à compléter */

}





void yyerror(char * s) {
    fprintf(stderr, "Error line %d: %s\n", yylineno, s);
    exit(1);
}
