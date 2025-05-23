%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;
extern char* yytext;
extern int line_num;
extern int line_pos;
extern char line[];

int error_pos = 0;
int error_flag = 0;
int error_count_point = 0;
int error_count = 0;

void yyerror(const char* s);
void append_to_line(char *text);
void reset_line();
%}

%union {
    char *str;
    long long ival;
    double fval;
}

%token <str>  T_IDENTIFIER T_STRING_LITERAL T_CHAR_LITERAL
%token <ival> T_INT_LITERAL
%token <fval> T_FP_LITERAL
%token        T_TRUE T_FALSE T_NULL_LITERAL

%token T_ELLIPSIS T_COLONCOLON T_LAMBDA
%token T_EQ T_NE T_GE T_LE T_RSHIFT T_RSHIFT_U T_LSHIFT
%token T_ANDAND T_OROR T_INC T_DEC
%token T_PLUSEQ T_MINUSEQ T_MULTEQ T_DIVEQ T_MODEQ
%token T_ANDEQ T_OREQ T_XOREQ T_RSHIFTEQ T_RSHIFT_UEQ T_LSHIFTEQ
%token T_ABSTRACT T_ASSERT T_BOOLEAN T_BREAK T_BYTE T_CASE T_CATCH T_CHAR T_CLASS
%token T_CONST T_CONTINUE T_DEFAULT T_DO T_DOUBLE T_ELSE T_ENUM T_EXPORTS T_EXTENDS
%token T_FINAL T_FINALLY T_FLOAT T_FOR T_GOTO T_IF T_IMPLEMENTS T_IMPORT
%token T_INSTANCEOF T_INT T_INTERFACE T_LONG T_MODULE T_NATIVE T_NEW T_PACKAGE T_STRING
%token T_PRIVATE T_PROTECTED T_PUBLIC T_REQUIRES T_RETURN T_SHORT T_STATIC
%token T_STRICTFP T_SUPER T_SWITCH T_SYNCHRONIZED T_THIS T_THROW T_THROWS
%token T_TRANSIENT T_TRY T_VAR T_VOID T_VOLATILE T_WHILE T_YIELD T_RECORD
%token T_SEALED T_PERMITS T_NON_SEALED T_OPEN T_OPENS T_PROVIDES T_TO T_USES T_WITH

/* ----------------------------------------------------------------
 *  Precedence & Associativity
 * ----------------------------------------------------------------*/
%right  '=' T_PLUSEQ T_MINUSEQ T_MULTEQ T_DIVEQ T_MODEQ T_ANDEQ T_OREQ T_XOREQ
%left   T_OROR
%left   T_ANDAND
%left   '|' '^' '&'
%left   T_EQ T_NE
%left   '>' '<' T_GE T_LE T_RSHIFT T_RSHIFT_U T_LSHIFT
%left   '+' '-'
%left   '*' '/' '%'
%right  '!' '~' T_INC T_DEC
%left   T_LAMBDA
%nonassoc LOWER_THAN_ELSE

/* Semantic types for selected non‑terminals */
%type <str> type reference_type qualified_name

%%
compilation_unit
    : package_decl_opt import_list_opt type_decl_list_opt
    | compilation_unit error ';'   { yyerrok; yyclearin; }
    ;

package_decl_opt
    : /* empty */
    | T_PACKAGE qualified_name ';'
    | error ';' { yyerrok; yyclearin; }
    ;

import_list_opt
    : /* empty */
    | import_list_opt import_decl
    ;

import_decl
    : T_IMPORT qualified_name ';'
    | T_IMPORT qualified_name '.' '*' ';'
    | error ';' { yyerrok; yyclearin; }
    ;

type_decl_list_opt
    : /* empty */
    | type_decl_list_opt type_decl
    ;

type_decl
    : class_decl
    | ';'
    ;

class_decl
    : class_modifiers_opt T_CLASS T_IDENTIFIER '{' class_body_decl_list_opt '}'
    ;

class_modifiers_opt
    : /* empty */
    | class_modifiers_opt class_modifier
    ;

class_modifier
    : T_PUBLIC | T_PRIVATE | T_PROTECTED | T_ABSTRACT | T_FINAL | T_STATIC
    | T_STRICTFP | T_SEALED
    ;

class_body_decl_list_opt
    : /* empty */
    | class_body_decl_list_opt class_body_decl
    ;

class_body_decl
    : field_decl
    | method_decl
    | error ';' { yyerrok; yyclearin; }
    | ';'
    ;

field_decl
    : type var_declarators ';'
    ;

var_declarators
    : var_declarators ',' var_declarator
    | var_declarator
    ;

var_declarator
    : T_IDENTIFIER var_initializer_opt
    ;

var_initializer_opt
    : /*empty*/
    | '=' var_initializer
    ;

var_initializer
    : expression
    ;

method_decl
    : method_modifiers_opt method_header method_body
    ;

method_modifiers_opt
    : /* empty */
    | method_modifiers_opt method_modifier
    ;

method_modifier
    : T_PUBLIC | T_PRIVATE | T_PROTECTED | T_ABSTRACT | T_STATIC | T_FINAL
    | T_SYNCHRONIZED | T_NATIVE | T_STRICTFP
    ;

method_header
    : type_or_void T_IDENTIFIER '(' formal_param_list_opt ')'
    ;

formal_param_list_opt
    : /* empty */
    | formal_param_list
    ;

formal_param_list
    : formal_param_list ',' formal_param
    | formal_param
    ;

formal_param
    : type T_IDENTIFIER
    ;

type_or_void
    : type
    | T_VOID
    ;

type
    : reference_type
    | primitive_type
    | type_arr
    ;

type_arr
    : reference_type '[' ']'
    | primitive_type '[' ']'
    | type_arr '[' ']'
    ;

reference_type
    : qualified_name   { $$ = $1; }
    ;

qualified_name
    : T_IDENTIFIER                       { $$ = $1; }
    | qualified_name '.' T_IDENTIFIER    { /* concat if desired */ }
    ;

primitive_type
    : T_BOOLEAN | T_CHAR | T_BYTE | T_SHORT | T_INT | T_LONG | T_FLOAT | T_DOUBLE | T_STRING
    ;

method_body
    : block
    | ';'
    ;

block
    : '{' block_statements_opt '}'
    ;

block_statements_opt
    : /* empty */
    | block_statements_opt block_statement
    ;

block_statement
    : local_var_decl_statement
    | statement
    ;

local_var_decl_statement
    : type var_declarators ';'
    | error ';' { yyerrok; yyclearin; }
    ;

statement
    : '{' block_statements_opt '}'
    | T_IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | T_IF '(' expression ')' statement T_ELSE statement
    | T_FOR '(' for_init_opt ';' expression_opt ';' for_update_opt ')' statement
    | T_WHILE '(' expression ')' statement
    | T_RETURN expression_opt ';'
    | T_IDENTIFIER '=' expression ';'
    | elem_array '=' expression ';'
    | error ';' { yyerrok; yyclearin; }
    | ';'
    ;

for_init_opt   
    : /* empty */ 
    | for_init 
    ;

for_init       
    : local_var_decl_statement 
    | expression_list 
    ;

for_update_opt 
    : /* empty */ 
    | expression_list 
    ;

expression_list
    : expression_list ',' expression 
    | expression 
    ;

expression_opt 
    : /* empty */ 
    | expression 
    ;

expression
    : primary
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | expression '%' expression
    | expression T_EQ expression
    | expression T_NE expression
    | expression '>' expression
    | expression '<' expression
    | expression T_GE expression
    | expression T_LE expression
    | expression T_ANDAND expression
    | expression T_OROR expression
    | '(' type ')' expression
    | '-' expression %prec '!'
    | '!' expression %prec '!'
    | T_NEW reference_type '(' ')'
    | T_NEW type
    ;

elem_array
    : T_IDENTIFIER '[' T_INT_LITERAL ']'
    | elem_array '[' T_INT_LITERAL ']'
    ;

primary
    : T_INT_LITERAL
    | T_FP_LITERAL
    | T_STRING_LITERAL
    | T_CHAR_LITERAL
    | T_TRUE
    | T_FALSE
    | T_NULL_LITERAL
    | T_IDENTIFIER
    | '(' expression ')'
    ;

%%


void yyerror(const char* s) {
    fprintf(stderr, "Error while parsing token \"%s\" at line %d:\n", yytext, line_num);
    error_count_point = strlen(yytext);
    error_flag = 1;
    error_pos = line_pos;
    error_count++;
}

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Не удалось открыть файл");
            return 1;
        }
    } else {
        yyin = stdin;
    }
    yyparse();
    printf("Разбор завершен успешно, кол-во ошибок: %d\n", error_count);
    if (yyin != stdin) fclose(yyin);
    return 0;
}