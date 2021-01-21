
%x STRING 
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




extern YYSTYPE yylval;
//SymbolTable* table=new SymbolTable(7);
extern SymbolTable* table;
void yyerror(char *);

extern FILE* errorout;
int line_count=1;
int error_count=0;;
int c;



%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [_a-zA-Z]

                                                                                                                                                                                                       
DIGIT [0-9]
CHAR '[A-Za-z0-9]'
CHARACTER \'\\[nt\\"afrbv0]\'
FLOAT [0-9]*[\.][0-9]+((E[+-])?[0-9]+)?
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
NEWLINE \n

DECIMAL_POINT [0-9]*[\.][0-9]*([\.]+[0-9]*)+

ILL_NUMBER  [0-9]*[\.]?[0-9]*((E[+-]?[0-9]+[\.]+[0-9]+)+)
INVALID_SUFFIX ([0-9]+[a-zA-Z]+)
MULTI_CHAR '[A-Za-z0-9 ][ a-zA-Z0-9]+'
UNFIN_CHAR '[a-zA-Z0-9]|'\\'
UN_CHAR ('[A-Za-z0-9]*[\\]?[^'\n]?)|'[\\]'
SINGLE_LINE "//".*
EMPTY_CHAR ('')

MULTI_LINE "//".*(\\{NEWLINE}.*)*
ANOTHER_MULTI_LINE "/*"(.*({NEWLINE})*.*)*"*/"
COMMENT_ERROR "/**".*

NEW [^\"\n]
STRINGNEWLINE \\\n
STRINGSP \\[nt\\"afrbv0]

%%

{WHITESPACE}       {}

{NEWLINE} {line_count++;}

"if"	{
			//fprintf(tokenout,"<IF>");
			//fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
			return IF;
		}
"else"	{
			//fprintf(tokenout,"<ELSE>");
			//fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n\n",line_count,yytext);
			return ELSE;
		}


"for"	{
			//fprintf(tokenout,"<FOR>");
			//fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n\n",line_count,yytext);
			return FOR;
		}
"while"	{
			//fprintf(tokenout,"<WHILE>");
			//fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n\n",line_count,yytext);
			return WHILE;
		}

"do"	{
			//fprintf(tokenout,"<DO>");
			//fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n\n",line_count,yytext);
			return DO;
		}
"break"	{
			//fprintf(tokenout,"<BREAK>");
			//fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n\n",line_count,yytext);
			return BREAK;
		}

"int"	{
			//fprintf(tokenout,"<INT>");
			//fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n\n",line_count,yytext);
			return INT;
		}
"char"	{
			//fprintf(tokenout,"<CHAR>");
			//fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n\n",line_count,yytext);
			return CHAR;
		}
"float"	{
			//fprintf(tokenout,"<FLOAT>");
			//fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n\n",line_count,yytext);
			return FLOAT;

		}
"double"	{
			//fprintf(tokenout,"<DOUBLE>");
			//fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n\n",line_count,yytext);
			return DOUBLE;		
			}
"void"	{
			//fprintf(tokenout,"<VOID>");
			//fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n\n",line_count,yytext);
			return VOID;
		}
"return"	{
			//fprintf(tokenout,"<RETURN>");
			//fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n\n",line_count,yytext);
			return RETURN;
			
		}

"switch"	{
			//fprintf(tokenout,"<SWITCH>");
			//fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n\n",line_count,yytext);
			return SWITCH;
		}
"case"	{
			//fprintf(tokenout,"<CASE>");
			//fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n\n",line_count,yytext);
			return CASE;
		}
"default"	{
			//fprintf(tokenout,"<DEFAULT>");
			//fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n\n",line_count,yytext);
			return DEFAULT;
		}

"continue"	{
			//fprintf(tokenout,"<CONTINUE>");
			//fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n\n",line_count,yytext);
			return CONTINUE;
		}

{IDENTIFIER}  {
		        SymbolInfo *s= new SymbolInfo(yytext, "ID");
			s->value.c=-1;
			yylval = (YYSTYPE)s;					
			return ID;
		  
	      }



[+-]		{
			SymbolInfo *s= new  SymbolInfo(yytext,"ADDOP");
			yylval = (YYSTYPE)s;
			return ADDOP;
			}
[*/%]		{
			SymbolInfo *s= new  SymbolInfo(yytext,"MULOP");
			yylval = (YYSTYPE)s;
			return MULOP;
			}
("++")		{
			return INCOP;
			}
("--")		{
			return DECOP;
			}

">"|">="|"<"|"<="|"=="|"!="		{
			SymbolInfo *s= new  SymbolInfo(yytext,"RELOP");
			yylval = (YYSTYPE)s;
			return RELOP;
			}
"="		{
			return ASSIGNOP;
			}
"&&"|"||"		{
			SymbolInfo *s= new  SymbolInfo(yytext,"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;
			}
"!"                     {
			return NOT;
			}
"("		{
			SymbolInfo *s= new  SymbolInfo(yytext,"LPAREN");
			yylval = (YYSTYPE)s;
			return LPAREN;
			}
")"		{
			return RPAREN;
			}
"{"		{
			SymbolInfo *s= new  SymbolInfo(yytext,"LCURL");
			yylval = (YYSTYPE)s;
			return LCURL;
			}
"}"		{
			return RCURL;
			}
"["		{
			return LTHIRD;
			
			}
"]"		{
			return RTHIRD;
			
			}
","		{
			return COMMA;
			}
";"		{
			return SEMICOLON;
			}

		
{DIGIT}+ 	{
				SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT");
                                s->value.ival=atoi(yytext);
                                s->value.c=0;
      				yylval = (YYSTYPE)s;
				return CONST_INT;
	  	}

{FLOAT} {
				SymbolInfo *s= new  SymbolInfo(yytext, "CONST_FLOAT");
                                s->value.fval=atof(yytext);
                                s->value.c=1;
				yylval = (YYSTYPE)s;
				return CONST_FLOAT; 
/*		}
{CHAR}	{		
			SymbolInfo* s =new  SymbolInfo(yytext, "CONST_CHAR");
			yylval = (YYSTYPE)s;
			return CONST_CHAR;
	  	}    
   

{CHARACTER}    {        
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
*/
{DECIMAL_POINT} {	//fprintf(logout,"Error at line no %d: Too many decimal point %s\n\n",line_count,yytext);
			error_count++;
			
		    }		   

{ILL_NUMBER}  {		//fprintf(logout,"Error at line no %d: Ill formed number %s\n\n",line_count,yytext);
			error_count++;

		}
{INVALID_SUFFIX}  {		
			//fprintf(logout,"Error at line no %d: Invalid Suffix on numeric constant or invalid prefix on identifier %s\n\n",line_count,yytext);
			error_count++;

		}

{MULTI_CHAR}    {        //fprintf(logout,"Error at line no %d: Multi character constant error %s\n\n",line_count,yytext);
			error_count++;
                  }
{UNFIN_CHAR}    {        //fprintf(logout,"Error at line no %d: Unfinished character %s\n\n",line_count,yytext);
			error_count++;
                  }
{UN_CHAR}                         {
			//fprintf(logout,"Error at line no %d: Unterminated character %s\n\n",line_count,yytext);
			error_count++;
			}
{EMPTY_CHAR}    {        //fprintf(logout,"Error at line no %d: Empty character constant error %s\n\n",line_count,yytext);
			error_count++;
                  }
{COMMENT_ERROR}    {    //fprintf(logout,"Error at line no %d: Unterminated comment %s\n\n",line_count,yytext);
			for(int i = 0; i<yyleng ; i++){if(yytext[i] == '\n') line_count++;}
			error_count++;
                  }
/*

\"      { 
			BEGIN STRING;		
		} 
		                          				  
<STRING>{NEWLINE}     {
	                                 line_count++;
	                                 error_count++;
                                     BEGIN INITIAL;					                            
                                }
			

<STRING>\"        {			                       
			                      BEGIN INITIAL;
			                      return STRING;
			                        
			               }	
					
<STRING>[^\"\n]+    {
                                        
			                }

<STRING>[^\"\n]*\\\n  {
                                        
			                            line_count++;
                              }	
                                		         
<STRING>[^\"\n\\]+\n   {
		                            error_count++;
		                            BEGIN INITIAL;
			                   }
*/
{SINGLE_LINE} 	{
			for(int i = 0; i<yyleng ; i++){
				if(yytext[i] == '\n') 
					line_count++;
					}

			return COMMENT;
	  	}
{MULTI_LINE} 	{
				for(int i = 0; i<yyleng ; i++){
 				if(yytext[i] == '\n') 
					line_count++;
					}

			return COMMENT;
	  	}
{ANOTHER_MULTI_LINE} 	{
				for(int i = 0; i<yyleng ; i++){
				if(yytext[i] == '\n') 
					line_count++;
					}
			return COMMENT;
	  	}

%%

int yywrap(void)
{
	return 1;
}

