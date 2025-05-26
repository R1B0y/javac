%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../deser_warn.h"

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
extern int deser_cnt;

char* category;

void yyerror(const char* s);
void append_to_line(char *text);
void reset_line();
static void print_deser_report(void);
%}

%union {
    char *str;
    long long ival;
    double fval;
}

%token <str>  T_IDENTIFIER T_STRING_LITERAL T_CHAR_LITERAL T_TEXT_STRING
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
%token T_EXCEPTION

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


%%
compilation_unit
    : package_decl_opt import_list_opt type_decl_list_opt
    | compilation_unit error ';'   { yyerrok; yyclearin; category = "compilation_unit"; }
    ;

package_decl_opt
    : 
    | T_PACKAGE qualified_name ';'
    | error ';' { yyerrok; yyclearin; category = "package_decl_opt"; }
    ;

import_list_opt
    : 
    | import_list_opt import_decl
    ;

import_decl
    : T_IMPORT qualified_name ';'
    | T_IMPORT qualified_name '.' '*' ';'
    | T_IMPORT qualified_name '.' T_EXCEPTION ';'
    | error ';' { yyerrok; yyclearin; category = "import_decl"; }
    ;

type_decl_list_opt
    : 
    | type_decl_list_opt type_decl
    ;

type_decl
    : class_decl 
    | ';'
    ;

class_decl
    : modifiers_opt T_CLASS T_IDENTIFIER type_parameters_opt '{' class_body_decl_list_opt '}'
    | modifiers_opt T_CLASS T_IDENTIFIER type_parameters_opt T_EXTENDS reference_type '{' class_body_decl_list_opt '}'
    | modifiers_opt T_CLASS T_IDENTIFIER type_parameters_opt T_IMPLEMENTS interfaces '{' class_body_decl_list_opt '}'
    | modifiers_opt T_CLASS T_IDENTIFIER type_parameters_opt T_EXTENDS reference_type T_IMPLEMENTS interfaces '{' class_body_decl_list_opt '}'
    | modifiers_opt T_INTERFACE T_IDENTIFIER type_parameters_opt '{' class_body_decl_list_opt '}'
    | modifiers_opt T_INTERFACE T_IDENTIFIER type_parameters_opt T_EXTENDS reference_type '{' class_body_decl_list_opt '}'
    | modifiers_opt T_ENUM T_IDENTIFIER '{' enum_consts_opt enum_body_decls_opt '}'
    ;

class_body
    : '{' class_body_decl_list_opt '}'
    ;

class_body_opt
    : 
    | class_body
    ;

argument_list_opt
    : 
    | expression_list
    ;

interfaces
    : interface
    | interfaces ',' interface
    ;

interface
    : T_IDENTIFIER
    | T_IDENTIFIER '<' T_IDENTIFIER '>'
    ;

modifier
    : T_PUBLIC 
    | T_PRIVATE 
    | T_PROTECTED 
    | T_ABSTRACT 
    | T_FINAL 
    | T_STATIC
    | T_STRICTFP 
    | T_SEALED
    | T_SYNCHRONIZED 
    | T_NATIVE 
    | T_DEFAULT
    ;

modifiers_opt
    : 
    | modifiers_opt modifier
    | modifiers_opt annotation
    ;

annotation
    : '@' qualified_name annotation_params_opt
    | '@' qualified_name 
    ;

annotation_params_opt
    : '(' expression_list ')'
    ;

class_body_decl_list_opt
    : 
    | class_body_decl_list_opt class_body_decl
    ;

class_body_decl
    : method_decl
    | class_decl 
    | field_decl
    | error ';'     { yyerrok; yyclearin; category = "class_body_decl"; }
    | ';'
    ;

field_decl
    : modifiers_opt type var_declarators ';'
    | type var_declarators ';' 
    ;

var_declarators
    : var_declarators ',' var_declarator
    | var_declarator
    ;

var_declarator
    : T_IDENTIFIER var_initializer_opt
    ;

var_initializer_opt
    : 
    | '=' var_initializer
    | '=' qualified_name '(' formal_param_list_without_type_opt ')'
    ;

var_initializer
    : expression
    | initializer
    ;

initializer
    : '{' initializer_list initializer_trailing_opt '}'
    ;

initializer_list
    : initializer
    | expression
    | initializer_list ',' initializer
    | initializer_list ',' expression
    ;

initializer_trailing_opt
    : 
    | ','
    ;

method_decl
    : modifiers_opt method_header ';'
    | modifiers_opt method_header method_body
    | modifiers_opt type T_IDENTIFIER '(' formal_param_list_opt ')' throws_opt method_body
    | type T_IDENTIFIER '(' formal_param_list_opt ')' throws_opt method_body
    | T_IDENTIFIER '(' formal_param_list_opt ')' throws_opt method_body
    ;

method_header
    : type_or_void T_IDENTIFIER '(' formal_param_list_opt ')' throws_opt
    | T_IDENTIFIER '(' formal_param_list_opt ')' throws_opt
    ;

throws_opt
    : 
    | T_THROWS exception_list
    ;

exception_list
    : T_EXCEPTION
    | exception_list ',' T_EXCEPTION
    | exception_list '|' T_EXCEPTION
    ;

enum_body_decls_opt
    : 
    | ';' class_body_decl_list_opt 
    ;

enum_consts_opt
    :
    | enum_consts
    ;

enum_consts
    : enum_consts ',' enum_const
    | enum_const
    ;

enum_const
    : T_IDENTIFIER
    | T_IDENTIFIER '(' enum_const_params ')'
    ;

enum_const_params
    : primary
    | enum_const_params ',' primary
    ;

formal_param_list_opt
    : 
    | formal_param_list
    | formal_param_list ',' vararg
    | vararg
    ;

formal_param_list
    : formal_param_list ',' formal_param
    | formal_param
    ;

formal_param
    : type T_IDENTIFIER
    ;

vararg
    : type T_ELLIPSIS T_IDENTIFIER
    ;

formal_param_without_type
    : primary
    | expression
    ; 

formal_param_list_without_type
    : formal_param_list_without_type ',' formal_param_without_type
    | formal_param_without_type
    ;

formal_param_list_without_type_opt
    : 
    | formal_param_list_without_type
    ;

type_or_void
    : type_arg
    | T_VOID
    ;

type
    : reference_type
    | primitive_type
    | type_arr
    ;

types_or_voids
    : 
    | type_or_void
    | types_or_voids ',' type_or_void
    ;

type_arr
    : reference_type '[' ']'
    | primitive_type '[' ']'
    | type_arr '[' ']'
    ;

type_args_opt
    : 
    | '<' '>'
    | '<' type_arg_list '>'
    | '<' T_EXCEPTION '>'
    ;

type_arg_list
    : type_arg
    | type_arg_list ',' type_arg
    ;

type_arg
    : type
    | '?'
    | '?' T_EXTENDS type
    | '?' T_SUPER type
    ;

type_parameters_opt
    :
    | '<' type_parameter_list '>'
    ;

type_parameter_list
    : type_parameter
    | type_parameter_list ',' type_parameter

type_parameter
    : T_IDENTIFIER type_bound_opt
    ;

type_bound_opt
    :
    | T_EXTENDS bound
    ;

bound
    : reference_type
    | bound '&' reference_type
    ;

reference_type
    : qualified_name type_args_opt
    ;

qualified_name
    : T_IDENTIFIER 
    | qualified_name '.' T_IDENTIFIER 
    | T_THIS '.' qualified_name
    | T_THIS
    ;

primitive_type
    : T_BOOLEAN 
    | T_CHAR 
    | T_BYTE 
    | T_SHORT 
    | T_INT 
    | T_LONG 
    | T_FLOAT 
    | T_DOUBLE 
    | T_STRING
    ;

method_body
    : block
    ;

block
    : '{' block_statements_opt '}'
    | statement
    ;

block_statements_opt
    : 
    | block_statements_opt block_statement
    ;

block_statement
    : local_var_decl_statement
    | statement
    ;

local_var_decl_statement
    : type var_declarators ';'
    | error ';' { yyerrok; yyclearin; category = "local_var_decl_statement"; }
    ;

statement
    : expression ';'
    | T_IDENTIFIER ':' statement
    | '{' block_statements_opt '}'
    | T_IF '(' expression ')' block %prec LOWER_THAN_ELSE
    | T_IF '(' expression ')' block T_ELSE block
    | T_FOR '(' for_control ')' block
    | T_WHILE '(' expression ')' block
    | T_RETURN expression_opt ';'
    | T_CONTINUE ';'
    | T_BREAK ';'
    | T_BREAK T_IDENTIFIER ';'
    | qualified_name var_initializer_opt ';'
    | qualified_name '(' formal_param_list_without_type_opt ')'
    | type qualified_name '=' qualified_name '(' formal_param_list_without_type_opt ')'
    | qualified_name T_PLUSEQ expression ';'
    | qualified_name T_MINUSEQ expression ';'
    | T_SWITCH '(' expression ')' switch_block
    | T_TRY block T_CATCH '(' exceptions T_IDENTIFIER ')' block
    | T_TRY block T_FINALLY block
    | T_TRY block T_CATCH '(' exceptions T_IDENTIFIER ')' block T_FINALLY block
    | T_TRY '(' resource_spec ')' block
    | T_TRY '(' resource_spec ')' block T_CATCH '(' exceptions T_IDENTIFIER ')' block
    | T_TRY '(' resource_spec ')' block T_FINALLY block
    | T_TRY '(' resource_spec ')' block T_CATCH '(' exceptions T_IDENTIFIER ')' block T_FINALLY block
    | T_THROW T_NEW T_EXCEPTION '(' T_TEXT_STRING ')' ';'
    | variable T_INC ';'
    | variable T_DEC ';'
    | T_INC variable ';'
    | T_DEC variable ';'
    | error ';' { yyerrok; yyclearin; category = "statement"; }
    | ';'
    ;

resource_spec
    : type var_declarators
    ;

for_control
    : type T_IDENTIFIER ':' expression
    | for_init_opt ';' expression_opt ';' for_update_opt
    ;

for_init_opt   
    : 
    | for_init 
    ;

for_init       
    : 
    | type var_declarators 
    | var_declarators 
    ;

for_update_opt 
    :  
    | variable T_INC 
    | variable T_DEC 
    | T_INC variable
    | T_DEC variable
    | qualified_name var_initializer_opt 
    ;

switch_block
    : '{' switch_block_statements '}'
    ;

switch_block_statements
    : 
    | switch_block_statements switch_block_statement
    ;

switch_block_statement
    : T_CASE expression ':' block_statements_opt
    | T_DEFAULT ':' block_statements_opt
    ;

expression_list
    : expression_list ',' expression 
    | expression 
    ;

expression_opt 
    : 
    | expression 
    ;

expression
    : lambda_expression
    | postfix_expr
    | T_NEW postfix_expr
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
    | T_NEW type '(' argument_list_opt ')' class_body_opt
    | T_NEW T_EXCEPTION '(' argument_list_opt ')' 
    | T_TEXT_STRING 
    ;

variable
    : qualified_name 
    ;

primary
    : T_INT_LITERAL
    | T_FP_LITERAL
    | T_STRING_LITERAL
    | T_CHAR_LITERAL
    | T_TRUE
    | T_FALSE
    | T_NULL_LITERAL
    | T_TEXT_STRING
    | qualified_name
    | qualified_name '(' formal_param_list_without_type_opt ')'
    | '(' expression ')'
    ;

postfix_suffix
    : '.' T_IDENTIFIER
    | '.' T_IDENTIFIER '(' formal_param_list_without_type_opt ')'
    | T_COLONCOLON T_IDENTIFIER
    | '[' expression ']' 
    ;

postfix_suffixes
    : 
    | postfix_suffixes postfix_suffix
    ;

postfix_expr
    : primary postfix_suffixes
    ;

lambda_params
    : T_IDENTIFIER
    | '(' ')'
    | '(' lambda_param_list ')'
    ;

lambda_param_list
    : lambda_param 
    | lambda_param_list ',' lambda_param
    ;

lambda_param
    : T_IDENTIFIER
    | type T_IDENTIFIER
    ;

lambda_body
    : expression 
    | block
    ;

lambda_expression
    : lambda_params T_LAMBDA lambda_body
    ;

exception
    : T_EXCEPTION
    ;

exceptions
    : exception
    | exceptions '|' exception
    ;

%%


void yyerror(const char* s) {
    fprintf(stderr, "Error while parsing token (%s) \"%s\" at line %d:\n", category, yytext, line_num);
    error_count_point = strlen(yytext);
    error_flag = 1;
    error_pos = line_pos;
    error_count++;
}

static void print_deser_report(void) {
    if (deser_cnt == 0) return;

    printf("\n======= ПРЕДУПРЕЖДЕНИЯ ДЕСЕРИАЛИЗАЦИИ =======\n");
    for (int i = 0; i < deser_cnt; ++i) {
        printf("  [строка %d] %s\n", deser_warns[i].line, deser_warns[i].info);
    }
    printf("=============================================\n\n");
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
    print_deser_report();
    printf("Разбор завершен успешно, кол-во ошибок: %d\n", error_count);
    if (yyin != stdin) fclose(yyin);
    return 0;
}
