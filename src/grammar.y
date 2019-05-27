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
#define MAIN "main"


/* Global variables */

// à compléter


/* prototypes */
int yylex(void);
extern int yylineno;

void yyerror(char *s);
void analyse_tree(node_t root);
void arbreFinal(node_t root);
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
            analyse_tree($$);
            arbreFinal($$);
        }
        | maindecl
        {
            $$ = make_node(NODE_PROGRAM, 2, NULL, $1 );
            analyse_tree($$);
            arbreFinal($$);
        }
        ;

listdecl:
        listdeclnonnull
        {
          $$ = $1;
        }
        |
        {
          $$ = NULL; 
        }
        ;


listdeclnonnull:
                vardecl
                {
                  $$ = $1;
                }
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
    {
    	 $$ = make_final_node(NODE_TYPE, 1, TYPE_INT);
    }
    | TOK_BOOL
    {
    	 $$ = make_final_node(NODE_TYPE, 1, TYPE_BOOL);
    }
    | TOK_VOID
    {
     	$$ = make_final_node(NODE_TYPE, 1, TYPE_VOID);
	}
    ;

listtypedecl:
            decl
            {
              $$ = $1;
            }
            | listtypedecl TOK_COMMA decl
            {
              $$ = make_node(NODE_LIST, 2, $1, $3);
            }
            ;

decl:
    ident
    {
    	$$ = make_node(NODE_DECL, 2, $1, NULL);
      
    }
    | ident TOK_AFFECT expr
    {
    	$$ = make_node(NODE_DECL, 2, $1, $3);
    }

    ;

maindecl:
    type ident TOK_LPAR TOK_RPAR block
    {
    	$$ = make_node(NODE_FUNC, 3, $1, $2, $5);
    }
    ;

listinst:
        listinstnonnull
        {
          $$ = $1;
        }
        |
        {
        	$$ = NULL;
        }
        ;

listinstnonnull :
        inst
				{
				    $$ = $1;
				}
        | listinstnonnull inst
        {
				  $$ = make_node(NODE_LIST, 2, $1, $2);
				}
                ;

inst            :
        expr TOK_SEMICOL
				{
				  $$ = $1;
				}
        | TOK_IF TOK_LPAR expr TOK_RPAR inst %prec TOK_THEN
        {
				  $$ = make_node(NODE_IF, 2, $3, $5);
				}
        | TOK_IF TOK_LPAR expr TOK_RPAR inst TOK_ELSE inst
        {
				  $$ = make_node(NODE_IF, 3, $3, $5, $7);
				}
        | TOK_WHILE TOK_LPAR expr TOK_RPAR inst
        {
				  $$ = make_node(NODE_WHILE, 2, $3, $5);
        }
        | TOK_FOR TOK_LPAR expr TOK_SEMICOL expr TOK_SEMICOL expr TOK_RPAR inst
        {
				  $$ = make_node(NODE_FOR, 4, $3, $5, $7, $9);   
				}
        | TOK_DO inst TOK_WHILE TOK_LPAR expr TOK_RPAR TOK_SEMICOL
        {
				  $$ = make_node(NODE_DOWHILE, 2, $5, $2);
        }
        | block
        {
				  $$ = $1;
        }
        | TOK_SEMICOL
        {
          $$ = NULL;
        }
        | TOK_PRINT TOK_LPAR listparamprint TOK_RPAR TOK_SEMICOL
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

expr:
    expr TOK_MUL expr
    {
      $$ = make_node(NODE_MUL, 2, $1, $3);
    }
    | expr TOK_DIV expr
    {
      $$ = make_node(NODE_DIV, 2, $1, $3);;
    }
    | expr TOK_PLUS expr
    {
      $$ = make_node(NODE_PLUS, 2, $1, $3);
    }
    | expr TOK_MINUS expr
    {
      $$ = make_node(NODE_MINUS, 2, $1, $3);
    }
    | expr TOK_MOD expr
    {
      $$ = make_node(NODE_MOD, 2, $1, $3);
    }
    | expr TOK_LT expr
    {
      $$ = make_node(NODE_LT, 2, $1, $3);
    }
    | expr TOK_GT expr
    {
      $$ = make_node(NODE_GT, 2, $1, $3);
    }
    |
    TOK_MINUS expr %prec TOK_MINUS
    {
     //$$ = make_node(NODE_UMINUS, 1, $2);
    }
    | expr TOK_GE expr
    {
      $$ = make_node(NODE_GE, 2, $1, $3);
    }
    | expr TOK_LE expr
    {
      $$ = make_node(NODE_LE, 2, $1, $3);
    }
    | expr TOK_EQ expr
    {
      $$ = make_node(NODE_EQ, 2, $1, $3);
    }
    | expr TOK_NE expr
    {
      $$ = make_node(NODE_NE, 2, $1, $3);
    }
    | expr TOK_AND expr
    {
      $$ = make_node(NODE_AND, 2, $1, $3);
    }
    | expr TOK_BAND expr
    {
      $$ = make_node(NODE_BAND, 2, $1, $3);
    }
    | expr TOK_OR expr
    {
      $$ = make_node(NODE_OR, 2, $1, $3);
    }
    | expr TOK_BOR expr
    {
      $$ = make_node(NODE_BOR, 2, $1, $3);
    }
    | ident TOK_AFFECT expr
    {
      $$ = make_node(NODE_AFFECT, 2, $1, $3);
    }
    | TOK_INTVAL
    {
      $$ = make_final_node(NODE_INTVAL, 0);
    }
    | TOK_TRUE
    {
      $$ = make_final_node(NODE_BOOLVAL, 1, "true");
    }
    | TOK_FALSE
    {
      $$ = make_final_node(NODE_BOOLVAL, 1, "false");
    }
    | TOK_STRING
    { 
      $$ = make_final_node(NODE_STRINGVAL, 0);
    }
    |
    ident
    {
    	$$ = $1;
    }
    | TOK_LPAR expr TOK_RPAR
    {
      $$ = $2;
    }
    ;

listparamprint:
        listparamprint TOK_COMMA paramprint
        {
    			$$ = make_node(NODE_LIST, 2, $1, $3);
				}
        | paramprint
        {
    			$$ = $1;
				}
        ;

paramprint:
      ident
      {
    		$$ = $1;
			}
      | TOK_STRING
      {
        $$ = make_final_node(NODE_STRINGVAL, 0);
			}
      ;

ident:
    TOK_IDENT
    {
    	$$ = make_final_node(NODE_IDENT, 0);
    }
    ;



%%

/* à compléter : fonctions de création des noeuds de l'arbre */

node_t make_node_null(node_t i_am_null){
	i_am_null = malloc(sizeof(node_s));
	i_am_null -> nature = NONE;
    i_am_null -> type = TYPE_NONE;

    i_am_null -> value = 0;
    i_am_null -> offset = 0;
    i_am_null -> global_decl = false;

    i_am_null -> nops = 0;

    i_am_null -> lineno = yylineno;
    i_am_null -> stack_size = 0;

    i_am_null -> opr = NULL;

    i_am_null -> decl_node = NULL;

    i_am_null -> ident = NULL;
    i_am_null -> str = NULL;
    return i_am_null;
}

node_t make_node(node_nature nature , int nbArg, ...)
{
	int i = 0;

	// allocation de memoire pour le noeud
	node_t nouveau_noeud = malloc(sizeof(node_s));

	nouveau_noeud -> nature = nature;
	nouveau_noeud -> nops = nbArg; 	// nombre d enfants du noeud

	// ------ On cree les fils ------
	if (nbArg > 0){
		nouveau_noeud -> opr = malloc(nbArg * sizeof(node_s*));
		va_list arg_noeud;
		va_start(arg_noeud, nbArg);

		for( i = 0; i < nbArg; i++){
			nouveau_noeud -> opr[i] = va_arg(arg_noeud, node_t);

			if(nouveau_noeud -> opr[i]== NULL){
				nouveau_noeud -> opr[i] = make_node_null(nouveau_noeud->opr[i]);
			}
		}
		va_end(arg_noeud);

    //arbre pre-analyse
		if(nature == NODE_PROGRAM){
			dump_tree(nouveau_noeud, "apres_syntaxe.dot");
		}
	}

    return nouveau_noeud;
}


node_t make_final_node(node_nature nature , int nbArg, ...)
{
  node_t nouveau_noeud = NULL;
  nouveau_noeud = make_node_null(nouveau_noeud);
  nouveau_noeud -> nature = nature;
  va_list arg_noeud;
  va_start(arg_noeud, nbArg);

  switch(nature)
  {
    case NODE_TYPE : 
    {
      nouveau_noeud -> type = va_arg(arg_noeud, node_type);
      break;
    }
<<<<<<< HEAD
=======

    case NODE_IDENT : 
    {
    	nouveau_noeud -> ident = yylval.strval;
      break;
    }

    case NODE_INTVAL : 
    {
      nouveau_noeud -> value = yylval.intval;
      nouveau_noeud -> type = TYPE_INT;
      break;
    }
    case NODE_STRINGVAL : 
    {
    	nouveau_noeud -> str = yylval.strval;
      nouveau_noeud -> type = TYPE_STRING;

  switch(nature){

    case NODE_TYPE :
    	nouveau_noeud-> type = va_arg(arg_noeud, node_type);
    	break;
>>>>>>> 21d59c59716782c022a1edf5d1b37b0479d19595

    case NODE_IDENT : 
    {
    	nouveau_noeud -> ident = yylval.strval;
      break;
    }

    case NODE_INTVAL : 
    {
      nouveau_noeud -> value = yylval.intval;
      nouveau_noeud -> type = TYPE_INT;
      break;
    }
    case NODE_STRINGVAL : 
    {
    	nouveau_noeud -> str = yylval.strval;
      nouveau_noeud -> type = TYPE_STRING;
    }
    case NODE_BOOLVAL : 
<<<<<<< HEAD
=======
D
>>>>>>> 21d59c59716782c022a1edf5d1b37b0479d19595
    {
      nouveau_noeud->type = TYPE_BOOL;
      if("true" == va_arg(arg_noeud, char*))
      {
        nouveau_noeud->value = 1;
      }
      else
      {
        nouveau_noeud->value = 0;
      }
      break;
    }
<<<<<<< HEAD
=======
  }

		if("true" == va_arg(arg_noeud, char*)){
			nouveau_noeud->value = 1;
		}
		else{
			nouveau_noeud->value = 0;
		}
		break;
	}

>>>>>>> 21d59c59716782c022a1edf5d1b37b0479d19595
	return nouveau_noeud;
  }
}


// Global bool variable to indicate if we are dealing with global decls or not
bool global_decl_var = true;
node_type type_courant = TYPE_INT; 
bool decl_var = true;


<<<<<<< HEAD
void analyse_tree(node_t root) 
{
    /* à compléter */
=======
void analyse_tree(node_t root) {
    /* à compléter */

	switch(root->nature) 
		{
			case NODE_PROGRAM : 
				push_global_context();
				break;


			case NODE_IDENT:
        //informations recueillies grace au variables globales 
				root->global_decl = global_decl_var;
				root->type = type_courant;

        //si declaration en cours
        if(decl_var || !strcmp("main", root->ident))
        {
          //env_add_element = -1 -> déjà déclarée dans le contexte local
          int32_t var_context = env_add_element(root->ident, root, 4);
          
          //variable déja déclarée dans ce contexte
          if(var_context == -1)
          {
            char* buffer;
            sprintf(buffer,"Variable '%s' deja declaree dans ce contexte", root->ident);
            yyerror(buffer);
          }
          else
          {
            root->offset = var_context;
            root->decl_node = NULL;
          }

        }
        //si declaration non en cours
        else
        {
          int32_t var_context = env_add_element(root->ident, root, 4);
          root->offset = -1;
          root->decl_node = get_decl_node(root->ident);
          root->type = root->decl_node->type;

          //pas de declaration trouvee
          if(!root->decl_node)
          {
            char* buffer;
            sprintf(buffer, "Variable '%s' non declaree", root->ident);
            yyerror(buffer);
          }
        }

        //si ident main
        if(!strcmp("main",root->ident))
        {
          root->offset = -1;
          if(root->type != TYPE_VOID)
          {
            yyerror("Fonction main n'est pas de type void");
          }
        }
        break;


      case NODE_DECL : 
        decl_var = true;
        break;




			case NODE_FUNC :
        reset_env_current_offset();
				global_decl_var = false;
        root->global_decl = global_decl_var;
				break;

			case NODE_TYPE : 
				type_courant = root->type;
				break;

      case NODE_BOOLVAL : 
        root->type = TYPE_BOOL;
        break;

      case NODE_INTVAL : 
        root->type = TYPE_INT;
        break;

      case NODE_STRINGVAL : 
        root->type = TYPE_STRING;
        root->offset = add_string(root->str);
        break;

      case NODE_BLOCK :
        push_context();
        break;


		} 

	switch(root->nature){
		case NODE_PROGRAM : 
			push_global_context();
			break;
		case NODE_IDENT:
			//informations recueillies grace au variables globales 
			root->global_decl = global_decl_var;
			root->type = type_courant;

			//si declaration en cours
			if(decl_var)
			{
				int32_t var_context = env_add_element(root->ident, root, 4);

				//variable déja déclarée dans ce contexte
				if(var_context == -1){
					char* buffer;
					sprintf(buffer,"Variable '%s' deja declaree dans ce contexte", root->ident);
					yyerror(buffer);
				}
				else{
					root->offset = var_context;
					root->decl_node = NULL;
				}
			}
        	//si declaration non en cours
			else
			{
				int32_t var_context = env_add_element(root->ident, root, 4);
				root->offset = -1;
				root->decl_node = (node_t)malloc(sizeof(node_t));
				root->decl_node = get_decl_node(root->ident);

				//pas de declaration trouvee
				if(!root->decl_node){
					char* buffer;
					sprintf(buffer, "Variable '%s' non declaree", root->ident);
					yyerror(buffer);
				}
			}
>>>>>>> 21d59c59716782c022a1edf5d1b37b0479d19595

	switch(root->nature) 
		{
			case NODE_PROGRAM : 
				push_global_context();
				break;


			case NODE_IDENT:
        //informations recueillies grace au variables globales 
				root->global_decl = global_decl_var;
				root->type = type_courant;

        //si declaration en cours
        if(decl_var || !strcmp("main", root->ident))
        {
          //env_add_element = -1 -> déjà déclarée dans le contexte local
          int32_t var_context = env_add_element(root->ident, root, 4);
          
          //variable déja déclarée dans ce contexte
          if(var_context == -1)
          {
            char* buffer;
            sprintf(buffer,"Variable '%s' deja declaree dans ce contexte", root->ident);
            yyerror(buffer);
          }
          else
          {
            root->offset = var_context;
            root->decl_node = NULL;
          }

        }
        //si declaration non en cours
        else
        {
          int32_t var_context = env_add_element(root->ident, root, 4);
          root->offset = -1;
          root->decl_node = get_decl_node(root->ident);
          root->type = root->decl_node->type;

          //pas de declaration trouvee
          if(!root->decl_node)
          {
            char* buffer;
            sprintf(buffer, "Variable '%s' non declaree", root->ident);
            yyerror(buffer);
          }
        }

        //si ident main
        if(!strcmp("main",root->ident))
        {
          root->offset = -1;
          if(root->type != TYPE_VOID)
          {
            yyerror("Fonction main n'est pas de type void");
          }
        }
        break;

      case NODE_DECL : 
        decl_var = true;
        break;

			case NODE_FUNC :
        reset_env_current_offset();
				global_decl_var = false;
        root->global_decl = global_decl_var;
				break;

			case NODE_TYPE : 
				type_courant = root->type;
				break;

      case NODE_BOOLVAL : 
        root->type = TYPE_BOOL;
        break;

      case NODE_INTVAL : 
        root->type = TYPE_INT;
        break;

      case NODE_STRINGVAL : 
        root->type = TYPE_STRING;
        root->offset = add_string(root->str);
        break;

      case NODE_BLOCK :
        push_context();
        break;
      } 



	for(int i = 0; i < root->nops; i++){
		analyse_tree(root->opr[i]);
	}


  //champ des parents après ceux des fils
<<<<<<< HEAD

  switch(root ->nature) {
=======
  switch(root->nature)
  {

  switch(root->nature) {
>>>>>>> 21d59c59716782c022a1edf5d1b37b0479d19595

    case NODE_FUNC : 
      global_decl_var = false;
      root->global_decl = global_decl_var;
      root->offset =  get_env_current_offset();
      break;

    case NODE_BLOCK : 
      pop_context();
      break;



    case NODE_DECL : 
      decl_var = false;
      if(!root->opr[1])
        if((root->opr[0]->type != root->opr[1]->type))
        {
          char* buffer;
          sprintf(buffer, "Variable de type %s est initialisee a un type %s", 
            node_type2string(root->opr[0]->type), 
            node_type2string(root->opr[1]->type));
          yyerror(buffer);
        }
        break;


    case NODE_AFFECT : 
      if((TYPE_VOID != root->opr[0]->type) &&(root->opr[0]->type != root->opr[1]->type))
      {
        char* buffer;
        sprintf(buffer, "Variable de type %s est affectee a un type %s", 
          node_type2string(root->opr[0]->type), 
          node_type2string(root->opr[1]->type));
        yyerror(buffer);
      }
<<<<<<< HEAD
      break;

    case NODE_PLUS : 
      if(root->opr[0]->type != TYPE_INT || root->opr[1]->type != TYPE_INT)
      {
        char* buffer;
        sprintf(buffer, "Une variable de type %s ne peut pas s'additionner à une variable de type %s", 
          node_type2string(root->opr[0]->type), 
          node_type2string(root->opr[1]->type));
        yyerror(buffer);
      }
      else
      {
        root->type = TYPE_INT;
      }
=======
>>>>>>> 21d59c59716782c022a1edf5d1b37b0479d19595
      break;

    case NODE_PLUS : 
      if(root->opr[0]->type != TYPE_INT || root->opr[1]->type != TYPE_INT)
      {
        char* buffer;
        sprintf(buffer, "Une variable de type %s ne peut pas s'additionner à une variable de type %s", 
          node_type2string(root->opr[0]->type), 
          node_type2string(root->opr[1]->type));
        yyerror(buffer);
      }
      else
      {
        root->type = TYPE_INT;
      }
      break;


  }
}

void arbreFinal(node_t root){
    if(root->nature == NODE_PROGRAM){
		dump_tree(root, "apres_passe_1.dot");
    }
}




void yyerror(char * s) {
    fprintf(stderr, "Error line %d: %s\n", yylineno, s);
    exit(1);
}
