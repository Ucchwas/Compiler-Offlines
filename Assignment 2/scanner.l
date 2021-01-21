%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include<string>
#include<fstream>
#include<string.h>
#include<iostream>
#include"y.tab.h"
#include"SymbolTable.h"

using namespace std;

extern YYSTYPE yylval;

extern SymbolTable* table;
void yyerror(char *);

extern FILE* errorout;

int line_count=1;
int error_count=0;
int c=0;

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
			
		}

"switch"	{
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n\n",line_count,yytext);
		}
"case"	{
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n\n",line_count,yytext);
		}
"default"	{
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n\n",line_count,yytext);
		}

"continue"	{
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n\n",line_count,yytext);
		}

{IDENTIFIER}  {
		        SymbolInfo *s= new SymbolInfo(yytext, "ID");
			s->value.c=-1;
			yylval = (YYSTYPE)s;					
			return ID;
		  
	      }



[+-]		{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"ADDOP");
			st.Printnew();
			}
[*/%]		{
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"MULOP");
			st.Printnew();
			}
"++"|"--"		{
			fprintf(tokenout,"<INCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"INCOP");
			st.Printnew();
			}
">"|">="|"<"|"<="|"=="|"!="		{
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"RELOP");
			st.Printnew();
			}
"="		{
			fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"ASSIGNOP");
			st.Printnew();
			}
"&&"|"||"		{
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"LOGICOP");
			st.Printnew();
			}
"!"                     {
			fprintf(tokenout,"<NOT,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"NOT");
			st.Printnew();
			}
"("		{
			fprintf(tokenout,"<LPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n\n",line_count,yytext);
			}
")"		{
			fprintf(tokenout,"<RPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n\n",line_count,yytext);
			}
"{"		{
			fprintf(tokenout,"<LCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n\n",line_count,yytext);
			st.Entry();
			}
"}"		{
			fprintf(tokenout,"<RCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n\n",line_count,yytext);
			st.Exit();
			}
"["		{
			fprintf(tokenout,"<LTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LBRACKET> Lexeme %s found\n\n",line_count,yytext);
			
			}
"]"		{
			fprintf(tokenout,"<RTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RBRACKET> Lexeme %s found\n\n",line_count,yytext);
			
			}
","		{
			fprintf(tokenout,"<COMMA,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"COMMA");
			st.Printnew();
			}
";"		{
			fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
			st.Insertnew(string(yytext),"SEMICOLON");
			st.Printnew();
			}

		
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_INT");
				st.Insertnew(string(yytext),"CONST_INT");
				st.Printnew();
	  	}

{FLOAT} {
				fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_FLOAT");
				st.Insertnew(string(yytext),"CONST_FLOAT");
				st.Printnew();
		}
{CHAR}	{
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
				SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_CHAR");
				st.Insertnew(string(yytext),"CONST_CHAR");
				st.Printnew();
	  	}    
   

{CHARACTER}    {        
			
	                if(yytext[2]=='t') fprintf(tokenout,"<CONST_CHAR,%c>",'\t');
                        if(yytext[2]=='n') fprintf(tokenout,"<CONST_CHAR,%c>",'\n');
                        if(yytext[2]=='a') fprintf(tokenout,"<CONST_CHAR,%c>",'\a');
                        if(yytext[2]=='f') fprintf(tokenout,"<CONST_CHAR,%c>",'\f');
                        if(yytext[2]=='r') fprintf(tokenout,"<CONST_CHAR,%c>",'\r');
                        if(yytext[2]=='b') fprintf(tokenout,"<CONST_CHAR,%c>",'\b');
                        if(yytext[2]=='v') fprintf(tokenout,"<CONST_CHAR,%c>",'\v');
                        if(yytext[2]=='0') fprintf(tokenout,"<CONST_CHAR,%c>",'\0');
                        if(yytext[2]=='"') fprintf(tokenout,"<CONST_CHAR,%c>",'\"');
                        
                        if(yytext[2]=='\\') fprintf(tokenout,"<CONST_CHAR,%c>",'\\');                        
			fprintf(logout,"Line no %d:<CONST_CHAR> %s found\n",line_count,yytext);
			st.Insertnew(string(yytext),"CONST_CHAR");
			st.Printnew();


             }

{DECIMAL_POINT} {	fprintf(logout,"Error at line no %d: Too many decimal point %s\n\n",line_count,yytext);
			error_count++;
			
		    }		   

{ILL_NUMBER}  {		fprintf(logout,"Error at line no %d: Ill formed number %s\n\n",line_count,yytext);
			error_count++;

		}
{INVALID_SUFFIX}  {		
			fprintf(logout,"Error at line no %d: Invalid Suffix on numeric constant or invalid prefix on identifier %s\n\n",line_count,yytext);
			error_count++;

		}

{MULTI_CHAR}    {        fprintf(logout,"Error at line no %d: Multi character constant error %s\n\n",line_count,yytext);
			error_count++;
                  }
{UNFIN_CHAR}    {        fprintf(logout,"Error at line no %d: Unfinished character %s\n\n",line_count,yytext);
			error_count++;
                  }
{UN_CHAR}                         {
			fprintf(logout,"Error at line no %d: Unterminated character %s\n\n",line_count,yytext);
			error_count++;
			}
{EMPTY_CHAR}    {        fprintf(logout,"Error at line no %d: Empty character constant error %s\n\n",line_count,yytext);
			error_count++;
                  }
{COMMENT_ERROR}    {    fprintf(logout,"Error at line no %d: Unterminated comment %s\n\n",line_count,yytext);
			error_count++;
                  }


\"           { 
		 BEGIN (STRING);
                 log=log+yytext;
                  c=line_count; 
             }

<STRING>{NEW} {   token=token+yytext;
                   log=log+yytext;
                   
                }
<STRING>{STRINGNEWLINE} {line_count++;
                     log=log+yytext;
                     }

<STRING>{STRINGSP} {
                       if(yytext[1]=='n') token=token+'\n';   
                       if(yytext[1]=='t') token=token+'\t';
                       if(yytext[1]=='a') token=token+'\a';
                       if(yytext[1]=='f') token=token+'\f';
                       if(yytext[1]=='r') token=token+'\r';
                       if(yytext[1]=='b') token=token+'\b';
                       if(yytext[1]=='v') token=token+'\v';
                       if(yytext[1]=='0') token=token+'\0';
                       if(yytext[1]=='"') token=token+'\"';
                       if(yytext[1]=='\\') token=token+'\\'; 
                       
                       log=log+yytext;
                       
                     }

<STRING>{NEWLINE}  {
                      fprintf(logout,"Error at line no %d: Unterminated String %s\n\n",c,log.c_str());
                      error_count++;
                      line_count++;
                      BEGIN INITIAL;
                      log="";
                    }
<STRING>\" { 
              log=log+yytext;
              fprintf(tokenout,"<STRING,%s>",token.c_str());
              fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n\n",c,log.c_str());
              BEGIN INITIAL;
              log="";
              token="";
              
              
             }

{SINGLE_LINE} 	{
				fprintf(tokenout,"<sINGLE_LINE_COMMENT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <SLCOMMENT> Lexeme %s found\n",line_count,yytext);
	  	}
{MULTI_LINE} 	{
				fprintf(tokenout,"<MULTI_LINE_COMMENT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <MLCOMMENT> Lexeme %s found\n",line_count,yytext);
	  	}
{ANOTHER_MULTI_LINE} 	{
				fprintf(tokenout,"<MULTI_LINE_COMMENT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <MLCOMMENT> Lexeme %s found\n",line_count,yytext);
	  	}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fprintf(logout,"Total Lines: %d\n\n",line_count-1); 
	fprintf(logout,"Total Errors: %d",error_count);		
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
