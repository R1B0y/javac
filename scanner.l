%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include "../deser_warn.h"

#define MAX_LINE_LENGTH 1024

DeserWarn deser_warns[MAX_DESER];
int deser_cnt = 0;
char line[MAX_LINE_LENGTH];
int line_pos = 0;
int line_num = 1;

extern int error_pos;
extern int error_flag;
extern int error_count_point;

void append_to_line(char *text);
void reset_line();

#define RETURN(tok) ( { append_to_line(yytext); return tok; } )
#define RETURN_STR(tok) ( { append_to_line(yytext); yylval.str = strdup(yytext); return tok; } )

%}

digit        [0-9]
hexdigit     [0-9A-Fa-f]
bindigit     [01]
octdigit     [0-7]

idstart      [_A-Za-z$]
idpart       [_A-Za-z0-9$]

hex_prefix   0[xX]
bin_prefix   0[bB]

exp_part     [eE][+-]?{digit}+(_?{digit})*

hex_int_lit  {hex_prefix}{hexdigit}+(_?{hexdigit})*
bin_int_lit  {bin_prefix}{bindigit}+(_?{bindigit})*
oct_int_lit  0{octdigit}+(_?{octdigit})*
dec_int_lit  {digit}+(_?{digit})*

int_suffix   [lL]
fp_suffix    [fFdD]

dec_fp_lit   ({digit}+\.{digit}*(_?{digit})*|\.{digit}+(_?{digit})*|{digit}+){exp_part}?{fp_suffix}?
hex_fp_lit   {hex_prefix}{hexdigit}+\.?{hexdigit}*[pP][+-]?{digit}+{fp_suffix}?

string_char  ([^|"\\\n]|\\.)
char_char    ([^'\\\n]|\\.)

%x COMMENT
%x LINE_COMMENT

%%
[ \t\r\f]+ { append_to_line(yytext); }
\n    { reset_line(); line_num++; }

"/*"                { BEGIN(COMMENT); }
"/**"               { BEGIN(COMMENT); }
<COMMENT>{
    \n              { reset_line(); line_num++; }
    "*/"            { BEGIN(INITIAL); }
    .               ; 
}

"//"                { BEGIN(LINE_COMMENT); }
<LINE_COMMENT>{
    \n              { reset_line(); line_num++; BEGIN(INITIAL); }
    .               ; 
}


"\""([^\"\\]|\\.)*"\"" { RETURN(T_TEXT_STRING); }

"true"      { RETURN(T_TRUE); }
"false"     { RETURN(T_FALSE); }
"null"      { RETURN(T_NULL_LITERAL); }

"abstract" { RETURN(T_ABSTRACT); }
"assert"   { RETURN(T_ASSERT); }
"boolean"  { RETURN(T_BOOLEAN); }
"break"    { RETURN(T_BREAK); }
"byte"     { RETURN(T_BYTE); }
"case"     { RETURN(T_CASE); }
"catch"    { RETURN(T_CATCH); }
"char"     { RETURN(T_CHAR); }
"class"    { RETURN(T_CLASS); }
"const"    { RETURN(T_CONST); }
"continue" { RETURN(T_CONTINUE); }
"default"  { RETURN(T_DEFAULT); }
"do"       { RETURN(T_DO); }
"double"   { RETURN(T_DOUBLE); }
"else"     { RETURN(T_ELSE); }
"enum"     { RETURN(T_ENUM); }
"exports"  { RETURN(T_EXPORTS); }
"extends"  { RETURN(T_EXTENDS); }
"final"    { RETURN(T_FINAL); }
"finally"  { RETURN(T_FINALLY); }
"float"    { RETURN(T_FLOAT); }
"for"      { RETURN(T_FOR); }
"goto"     { RETURN(T_GOTO); }
"if"       { RETURN(T_IF); }
"implements" { RETURN(T_IMPLEMENTS); }
"import"   { RETURN(T_IMPORT); }
"instanceof" { RETURN(T_INSTANCEOF); }
"int"      { RETURN(T_INT); }
"interface"  { RETURN(T_INTERFACE); }
"long"     { RETURN(T_LONG); }
"module"   { RETURN(T_MODULE); }
"native"   { RETURN(T_NATIVE); }
"new"      { RETURN(T_NEW); }
"package"  { RETURN(T_PACKAGE); }
"private"  { RETURN(T_PRIVATE); }
"protected" { RETURN(T_PROTECTED); }
"public"   { RETURN(T_PUBLIC); }
"requires" { RETURN(T_REQUIRES); }
"return"   { RETURN(T_RETURN); }  
"String"   { RETURN(T_STRING); }  
"short"    { RETURN(T_SHORT); }
"static"   { RETURN(T_STATIC); }       
"strictfp" { RETURN(T_STRICTFP); }
"super"    { RETURN(T_SUPER); }
"switch"   { RETURN(T_SWITCH); }
"synchronized" { RETURN(T_SYNCHRONIZED); }
"this"     { RETURN(T_THIS); }
"throw"    { RETURN(T_THROW); }
"throws"   { RETURN(T_THROWS); }
"transient" { RETURN(T_TRANSIENT); }
"try"      { RETURN(T_TRY); }          
"var"      { RETURN(T_VAR); }
"void"     { RETURN(T_VOID); }         
"volatile" { RETURN(T_VOLATILE); }
"while"    { RETURN(T_WHILE); }        
"yield"    { RETURN(T_YIELD); }
"record"   { RETURN(T_RECORD); }       
"sealed"   { RETURN(T_SEALED); }
"permits"  { RETURN(T_PERMITS); }      
"non-sealed" { RETURN(T_NON_SEALED); }
"open"     { RETURN(T_OPEN); }         
"opens"    { RETURN(T_OPENS); }
"provides" { RETURN(T_PROVIDES); }    
"to"       { RETURN(T_TO); }
"uses"     { RETURN(T_USES); }         
"with"     { RETURN(T_WITH); }

"IOException"					{ RETURN(T_EXCEPTION); }
"FileNotFoundException"			{ RETURN(T_EXCEPTION); }
"EOFException"					{ RETURN(T_EXCEPTION); }
"SQLException"					{ RETURN(T_EXCEPTION); }
"ClassNotFoundException"		{ RETURN(T_EXCEPTION); }
"InterruptedException"			{ RETURN(T_EXCEPTION); }
"NullPointerException"			{ RETURN(T_EXCEPTION); }
"ArrayIndexOutOfBoundsExceptio"	{ RETURN(T_EXCEPTION); }
"ArithmeticException"			{ RETURN(T_EXCEPTION); }
"IllegalArgumentException"		{ RETURN(T_EXCEPTION); }
"NumberFormatException"			{ RETURN(T_EXCEPTION); }
"ClassCastException"			{ RETURN(T_EXCEPTION); }
"UnsupportedOperationException"	{ RETURN(T_EXCEPTION); }
"OutOfMemoryError"				{ RETURN(T_EXCEPTION); }
"StackOverflowError"			{ RETURN(T_EXCEPTION); }
"NoClassDefFoundError"			{ RETURN(T_EXCEPTION); }
"VirtualMachineError"			{ RETURN(T_EXCEPTION); }
"ObjectStreamException"			{ RETURN(T_EXCEPTION); }
"Exception"						{ RETURN(T_EXCEPTION); }

"ObjectInputStream"       { add_deser_warn("Создание java.io.ObjectInputStream", line_num); RETURN_STR(T_IDENTIFIER); }
"XMLDecoder"              { add_deser_warn("Создание java.beans.XMLDecoder", line_num); RETURN_STR(T_IDENTIFIER); }
"readObject"              { add_deser_warn("Вызов readObject()", line_num); RETURN_STR(T_IDENTIFIER); }
"readResolve"             { add_deser_warn("Вызов readResolve()", line_num); RETURN_STR(T_IDENTIFIER); }
"fromXML"                 { add_deser_warn("Вызов XStream#fromXML()", line_num); RETURN_STR(T_IDENTIFIER); }
"enableDefaultTyping"     { add_deser_warn("ObjectMapper.enableDefaultTyping()", line_num); RETURN_STR(T_IDENTIFIER); }
"Serializable"            { add_deser_warn("Реализация Serializable", line_num); RETURN_STR(T_IDENTIFIER); }
{idstart}{idpart}*            { RETURN_STR(T_IDENTIFIER); }

{hex_int_lit}{int_suffix}?    { RETURN_STR(T_INT_LITERAL); }
{bin_int_lit}{int_suffix}?    { RETURN_STR(T_INT_LITERAL); }
{oct_int_lit}{int_suffix}?    { RETURN_STR(T_INT_LITERAL); }
{dec_int_lit}{int_suffix}?    { RETURN_STR(T_INT_LITERAL); }
{dec_fp_lit}                  { RETURN_STR(T_FP_LITERAL); }
{hex_fp_lit}                  { RETURN_STR(T_FP_LITERAL); }
'{char_char}'                 { RETURN_STR(T_CHAR_LITERAL); }
"({string_char})*"            { RETURN_STR(T_STRING_LITERAL); }

"("  { RETURN('('); }
")" { RETURN(')'); }
"{"  { RETURN('{'); }
"}" { RETURN('}'); }
"["  { RETURN('['); } 
"]" { RETURN(']'); }
";"  { RETURN(';'); } 
"," { RETURN(','); }
"."  { RETURN('.'); }  
"..." { RETURN(T_ELLIPSIS); }
"@"  { RETURN('@'); }  
"::" { RETURN(T_COLONCOLON); }
"==" { RETURN(T_EQ); }  
"!=" { RETURN(T_NE); }
">=" { RETURN(T_GE); }
"<=" { RETURN(T_LE); }
">>>" { RETURN(T_RSHIFT_U); }  
">>" { RETURN(T_RSHIFT); }
"<<" { RETURN(T_LSHIFT); }
"&&" { RETURN(T_ANDAND); } 
"||" { RETURN(T_OROR); }
"++" { RETURN(T_INC); }    
"--" { RETURN(T_DEC); }
"+=" { RETURN(T_PLUSEQ); } 
"-=" { RETURN(T_MINUSEQ); }
"*=" { RETURN(T_MULTEQ); } 
"/=" { RETURN(T_DIVEQ); }
"%=" { RETURN(T_MODEQ); } 
"&=" { RETURN(T_ANDEQ); }
"|=" { RETURN(T_OREQ); } 
"^=" { RETURN(T_XOREQ); }
">>>=" { RETURN(T_RSHIFT_UEQ); } 
">>=" { RETURN(T_RSHIFTEQ); }
"<<=" { RETURN(T_LSHIFTEQ); }  
"->" { RETURN(T_LAMBDA); }

"="  { RETURN('='); }  
">" { RETURN('>'); }  
"<" { RETURN('<'); }
"!"  { RETURN('!'); }  
"~" { RETURN('~'); } 
"?" { RETURN('?'); }
":"  { RETURN(':'); }  
"+" { RETURN('+'); }  
"-" { RETURN('-'); }
"*"  { RETURN('*'); }  
"/" { RETURN('/'); }  
"&" { RETURN('&'); }
"|"  { RETURN('|'); }  
"^" { RETURN('^'); }  
"%" { RETURN('%'); }
#"\"" { RETURN('\"'); }
#"\'" { RETURN('\''); }

.               { 
					printf("Лексическая ошибка: Неизвестный символ '%s' в строке %d\n", yytext, line_num);
					append_to_line(yytext);
					error_count_point = strlen(yytext);
    				error_flag = 1;
    				error_pos = line_pos;
    			}

%%

void append_to_line(char *text) {
    int len = strlen(text);
    if (line_pos + len < MAX_LINE_LENGTH - 1) {
        strcpy(line + line_pos, text);
        line_pos += len;
    }
}

void reset_line() {
	if (error_flag == 1){
		
		printf("%d | %s\n", line_num, line);
		int tmp = line_num;
		while (tmp != 0){
			printf(".");
			tmp /= 10;
		}
		printf(".!");
		int i = error_count_point - 1;
		for(i; i < error_pos; i++){
			printf(".");
		}
		for(i = 0; i < error_count_point; i++){
			printf("^");
		}
		printf("\n");

		error_flag = 0;
	}
    line_pos = 0;
    line[0] = '\0';  // Очищаем буфер
}

void add_deser_warn(const char *info, int line) {
    if (deser_cnt < MAX_DESER) {
        strncpy(deser_warns[deser_cnt].info, info, sizeof(deser_warns[deser_cnt].info) - 1);
        deser_warns[deser_cnt].line = line;
        ++deser_cnt;
    }
}

int yywrap() {
    return 1;
}
