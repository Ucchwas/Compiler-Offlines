
%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include<string>
#include<fstream>
#include<string.h>
#include"y.tab.h"
#include"SymbolTable.h"
using namespace std;



string yy;
extern YYSTYPE yylval;
//SymbolTable* table=new SymbolTable(7);
extern SymbolTable* table;
void yyerror(char *);

extern FILE* errorout;
int lin_count=1;
int error_count=0;;
int c;




%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [_a-zA-Z]
DIGIT [0-9]
CHARACTER \'\\[nt\\"afrbv0]\'
FLOAT_NUMBER [0-9]*([.][0-9]+)?(E[+-]?[0-9]+)?
IDENTIFIER ([a-zA-Z0-9_]([a-zA-Z0-9_]*)?)
NEWLINE \n
NOT_IDENTIFIER [0-9]+(\.)?[A-Za-z0-9_]+

DECIMAL_POINT [0-9]*[\.][0-9]*([\.]+[0-9]*)+

ILL_NUMBER  [0-9]*[\.]?[0-9]*((E[+-]?[0-9]+[\.]+[0-9]+)+)
MULTI_CHAR '[A-Za-z0-9 ][ a-zA-Z0-9]+'
UNFIN_CHAR '[a-zA-Z0-9]|'\\'
UN_CHAR ('[A-Za-z0-9]*[\\]?[^'\n]?)|'[\\]'
EMPTY_CHAR ('')
COMMENT_ERROR "/**".*
SINGLE_LINE "//".*

MULTI_LINE "//".*(\\{NEWLINE}.*)*
ANOTHER_MULTI_LINE "/*"(.*({NEWLINE})*.*)*"*/"

%%

{WHITESPACE}       {yy+=yytext;}

{NEWLINE} {
	yy+=yytext;	
	lin_count++;}

"if"	{ 
yy+=yytext;
  return IF;}
"else"	{   
yy+=yytext;
return ELSE;}
"for"	{ 
yy+=yytext;
  return FOR;}
"while" { 
yy+=yytext;
  return WHILE;}
"do"	{  
yy+=yytext;
 return DO;
	}
"break"	{  
yy+=yytext;
 return BREAK;
	}
"int"	{ 
yy+=yytext;
  return INT;}
"float"	{ 
yy+=yytext;
  return FLOAT;}
"void"	{ 
yy+=yytext;
  return VOID;}
"char"	{ 
yy+=yytext;
  return CHAR;}
"double" {
yy+=yytext;
  return DOUBLE;}
"switch" { 
yy+=yytext;
 return SWITCH;
		}
"case"	{  
yy+=yytext;
 return CASE;
		}
"default" { 
yy+=yytext;
return DEFAULT;
		}

"continue" {
yy+=yytext;
return CONTINUE;
		}
"println"	{
yy+=yytext;
return PRINTLN;}

"return"	{
yy+=yytext;
return RETURN;}

[+-]		{yy+=yytext;
                     SymbolInfo *s= new  SymbolInfo(yytext,"ADDOP");
			yylval = (YYSTYPE)s;
			return ADDOP;
			}
[*/%]		{
			yy+=yytext;
			SymbolInfo *s= new  SymbolInfo(yytext,"MULOP");
			yylval = (YYSTYPE)s;
			return MULOP;
	}


">"|">="|"<"|"<="|"=="|"!="		{
			yy+=yytext;
			SymbolInfo *s= new  SymbolInfo(yytext,"RELOP");
		yylval = (YYSTYPE)s;
		return RELOP;

                                     }
"="		{	yy+=yytext;
			return ASSIGNOP;
			}

"&&"|"||"		{
			yy+=yytext;
			SymbolInfo *s= new  SymbolInfo(yytext,"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;
		        }
"!"                     { 
yy+=yytext;
 return NOT;			}
"("		{
	yy+=yytext;
SymbolInfo *s= new SymbolInfo(yytext, "LCURL");
				
				yylval = (YYSTYPE)s;  return LPAREN;}
")"		{
yy+=yytext;
return RPAREN;}
"{"		{  
yy+=yytext;
		SymbolInfo *s= new SymbolInfo(yytext, "LCURL");
				
				yylval = (YYSTYPE)s;   return LCURL;}
"}"		{
yy+=yytext;
return RCURL;}
"["		{
yy+=yytext;
return LTHIRD;}
"]"		{
yy+=yytext;
return RTHIRD;}
","		{
yy+=yytext;
return COMMA;}
";"		{
yy+=yytext;
return SEMICOLON;}
"++"		{
yy+=yytext;
return INCOP;}
"--"		{
yy+=yytext;
return DECOP;}






		
{DIGIT}+ 	{      yy+=yytext;
				

                                SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT");
                                s->value.ival=atoi(yytext);
                                s->value.c=0;
				yylval = (YYSTYPE)s;
				return CONST_INT;
	  	}

{FLOAT_NUMBER} {yy+=yytext;
				SymbolInfo *s= new  SymbolInfo(yytext, "CONST_FLOAT");
                                s->value.fval=atof(yytext);
                                s->value.c=1;
				yylval = (YYSTYPE)s;
				return CONST_FLOAT; 
               }

{NOT_IDENTIFIER}  {yy+=yytext;
			fprintf(errorout,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number\n\n",lin_count);
			error_count++;
                       
                        
		}




{IDENTIFIER}  {yy+=yytext;

                       		SymbolInfo *s= new SymbolInfo(yytext, "ID");
				s->value.c=-1;
				yylval = (YYSTYPE)s;
							
				return ID;
              }

{CHARACTER}    {        yy+=yytext;
			char text;
			switch(yytext[2]){
				case 'n': text = '\n'; break;
				case 't': text = '\t'; break;
				case 'v': text = '\v'; break;
				case 'a': text = '\a'; break;
				case 'f': text = '\f'; break;
				case 'r': text = '\r'; break;
				case 'b': text = '\b'; break;
				case '0': text = '\0'; break;
				default: break;			
			}
			yytext[0] = text;
			yytext[1] = '\0';
			
	                SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval = (YYSTYPE)s;
			return CONST_CHAR;


             }

{DECIMAL_POINT} {yy+=yytext;	
			error_count++;
			
		    }		   

{ILL_NUMBER}  {		yy+=yytext;
			error_count++;

		}

{MULTI_CHAR}    {      yy+=yytext; 
			error_count++;
                  }
{UNFIN_CHAR}    {       yy+=yytext; 
			error_count++;
                  }
{UN_CHAR}                         {yy+=yytext;
			error_count++;
			}
{EMPTY_CHAR}    {        yy+=yytext;
			error_count++;
                  }
{COMMENT_ERROR}    {    yy+=yytext;
			for(int i = 0; i<yyleng ; i++){if(yytext[i] == '\n') lin_count++;}
			error_count++;
                  }



{SINGLE_LINE} 	{yy+=yytext;
			for(int i = 0; i<yyleng ; i++){
				if(yytext[i] == '\n') 
					lin_count++;
					}

			return COMMENT;
	  	}
{MULTI_LINE} 	{yy+=yytext;
				for(int i = 0; i<yyleng ; i++){
 				if(yytext[i] == '\n') 
					lin_count++;
					}

			return COMMENT;
	  	}
{ANOTHER_MULTI_LINE} 	{yy+=yytext;
				for(int i = 0; i<yyleng ; i++){
				if(yytext[i] == '\n') 
					lin_count++;
					}
			return COMMENT;
	  	}
			

%%

int yywrap(void)
{
	return 1;
}

