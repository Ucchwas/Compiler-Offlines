%{
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <vector>
#include <string>
#include <limits>
#include<bits/stdc++.h>
#include "SymbolTable.h"

#define YYSTYPE SymbolInfo*

using namespace std;


int yyparse(void);
int yylex(void);
extern FILE *yyin;

int type;
SymbolTable* table;
SymbolInfo* dam;
extern int line_count;
extern int error_count;

FILE *logout;
FILE *errorout;
int pos=0;
int flow[10];
int pos1=0;
int flow1[10];

void yyerror(const char *s)
{
	//write your code
}


%}
%token COMMENT IF ELSE FOR WHILE DO BREAK CONTINUE INT FLOAT CHAR DOUBLE VOID RETURN SWITCH CASE DEFAULT INCOP DECOP ASSIGNOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA STRING NOT PRINTLN ID CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP LOGICOP RELOP

%%

start : program
		{
			{fprintf(logout,"Line no %d->start: program\n\n",line_count);} 
		}
		;

program : program unit 
	{
		{fprintf(logout,"Line no %d-> program : program unit\n\n",line_count);} 
	}
	| unit
	{
		{fprintf(logout,"Line no %d-> program : unit\n\n",line_count);} 
	}
	;
	
unit : var_declaration
	{
		{fprintf(logout,"Line no %d-> unit : var_declaration\n\n",line_count);} 
	}
     | func_declaration
	{
		{fprintf(logout,"Line no %d-> unit : func_declaration\n\n",line_count);} 
	}
     | func_definition
	{
		{fprintf(logout,"Line no %d-> unit : func_definition\n\n",line_count);} 
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		{
                           fprintf(logout,"Line no %d->func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
                        table->Exit();
                        cout<<" exitscope ";
                       SymbolInfo* temp=table->Look($2->name);
                        
                       if(!temp){
                         table->Insertnew($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,$1->value.c);
                         temp=table->Look($2->name);
                        
                        
                        	
                        temp->type="Function";
                        temp->fsize=pos;
                        temp->para=1;
                        temp->isF=0;
                        if (temp->value.c==0) { temp->fsign=0; temp->value.c=-3;}
                        else if(temp->value.c==1) {temp->fsign=1; temp->value.c=-3;}
                        else if(temp->value.c==4) {temp->fsign=2; temp->value.c=-3;}
                         
                        for(int i=0;i<pos;i++) { temp->f[i]=flow[i];}; 
                        
                        
                        pos=0;
                        table->PrintAll();
                        
                          
			}
                        else if(temp) { fprintf(errorout,"Array already declared\n\n"); error_count++;}

}
		| type_specifier ID LPAREN RPAREN SEMICOLON
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		{
                         fprintf(logout,"Line no %d->func_definition:type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",line_count);
                        table->Exit();
                        cout<<" exitscope ";
                        
                        SymbolInfo* temp=table->Look($2->name);
                        
                       if(!temp){
                        table->Insertnew($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,type);
                        temp=table->Look($2->name);	
                        temp->type="Function";
                        temp->fsize=pos;
                        temp->para=1;
                        temp->isF=1;
                        if (temp->value.c==0) { temp->fsign=0; temp->value.c=-3;}
                        else if(temp->value.c==1) {temp->fsign=1; temp->value.c=-3;}
                        else if(temp->value.c==4) {temp->fsign=2; temp->value.c=-3;}
                         
                        for(int i=0;i<pos;i++) { temp->f[i]=flow[i];}; 
                        
                        
                        pos=0;
                        table->PrintAll();
                       
                          
			}
                        else if(temp->isF==0 && (temp->fsign==0||temp->fsign==1 || temp->fsign==2)) {temp->isF=1;}
                        else if(temp->isF==1){ fprintf(errorout,"%s is already defined \n\n",temp->name.c_str()); error_count++; } 
                        else { fprintf(errorout,"Error at Line no%d: %s is a ID ",line_count,temp->name.c_str()); error_count++; }                 


			}
		| type_specifier ID LPAREN RPAREN compound_statement
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		{fprintf(logout,"Line no %d->parameter_list : parameter_list COMMA type_specifier ID\n %s \n\n",line_count,$4->name.c_str());

                 if(table->Look($4->name)!=NULL) {fprintf(errorout,"Line np %d->Multiple declaration of %s\n\n",line_count,$4->name.c_str());  error_count++;}
                 else {table->Insertnew($4->name,$4->type,-1111,-1111,1,0,-1111,-1111,type);
                       flow[pos]=$3->value.c;
                        pos++;
                      table->PrintAll();}
                 

}
		| parameter_list COMMA type_specifier
		
 		| type_specifier ID
		{fprintf(logout,"Line no %d->parameter_list : type_specifier ID\n %s \n\n",line_count,$2->name.c_str());
                 if(table->Look($2->name)!=NULL) {fprintf(errorout,"Line np %d->Multiple declaration of %s \n\n ",line_count,$2->name.c_str());  error_count++;}
                 else {table->Insertnew($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,type);
                        flow[pos]=$1->value.c;
                      
                        pos++;
                      table->PrintAll();}
                 


}
		| type_specifier
 		;

 		
compound_statement : LCURL statements RCURL
			{fprintf(logout,"Line no %d->compound_statement : LCURL statements RCURL\n\n",line_count);}
 		    | LCURL RCURL
			{fprintf(logout,"Line no %d->compound_statement : LCURL RCURL\n\n",line_count);}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
			{fprintf(logout,"Line no %d->var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);  }
 		 ;
 		 
type_specifier	: INT
		{fprintf(logout,"Line no %d->type_specifier : INT\n\n",line_count); type=0;  
                         SymbolInfo* temp=new SymbolInfo;
                         temp->value.c=0;
                         $$=temp;
                         }
 		| FLOAT
		{fprintf(logout,"Line no %d->type_specifier : FLOAT\n\n",line_count); type=1;  
                         SymbolInfo* temp=new SymbolInfo;
                         temp->value.c=1;
                         $$=temp;
                         }
 		| VOID
		{fprintf(logout,"Line no %d->type_specifier : VOID\n\n",line_count); type=4;  
                         SymbolInfo* temp=new SymbolInfo;
                         temp->value.c=4;
                         $$=temp;
                         }
 		;
 		
declaration_list : declaration_list COMMA ID
		{
                 fprintf(logout,"Line no %d->declaration_list : declaration_list COMMA ID\n %s\n\n",line_count,$3->name.c_str());
                 if(table->Look($3->name)!=NULL) {fprintf(errorout,"Line no %d->Multiple declaration of %s",line_count,$3->name); error_count++;}
                 else {table->Insertnew($3->name,$3->type,-1111,-1111,1,0,-1111,-1111,type);
                        table->PrintAll();
                              }

                   }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		{
                 fprintf(logout,"Line no %d->declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n %s\n\n",line_count,$3->name);
                  if(table->Look($3->name)!=NULL) {fprintf(errorout,"Line no %d->Multiple declaration of %s",line_count,$3->name.c_str()); error_count++;}
                  else {if(type==0) {table->Insertnew($3->name,$3->type,-1111,-1111,$5->value.ival,0,-1111,-1111,2); 
			table->PrintAll();}
                        else if(type==1){table->Insertnew($3->name,$3->type,-1111,-1111,$5->value.ival,0,-1111,-1111,3); 
			table->PrintAll();}                     
}
                    }
 		  | ID
		{   
                 fprintf(logout,"Line no %d->declaration_list : ID\n %s \n\n",line_count,$1->name.c_str()); 
                 if(table->Look($1->name)!=NULL) {fprintf(errorout,"Line np %d->Multiple declaration of %s",line_count,$1->name.c_str());  error_count++;}
                 else {table->Insertnew($1->name,$1->type,-1111,-1111,1,0,-1111,-1111,type);
                      table->PrintAll();}
                  }
 		  | ID LTHIRD CONST_INT RTHIRD
		{fprintf(logout,"Line no %d->declaration_list : ID LTHIRD CONST_INT RTHIRD\n %s\n\n",line_count,$1->name.c_str());
                  if(table->Look($1->name)!=NULL) {fprintf(errorout,"Line no %d->Multiple declaration of %s",line_count,$1->name.c_str()); error_count++;}
                  else { if(type==0) {table->Insertnew($1->name,$1->type,-1111,-1111,$3->value.ival,0,-1111,-1111,2); 
			table->PrintAll();}
                         else if(type==1){table->Insertnew($1->name,$1->type,-1111,-1111,$3->value.ival,0,-1111,-1111,3); 
			table->PrintAll();}                          
}
                  
                   
                   }
 		  ;
 		  
statements : statement
		{fprintf(logout,"Line no %d-> statements : statement\n\n",line_count);}
	   | statements statement
		{fprintf(logout,"Line no %d-> statements : statements statement\n\n",line_count);}
	   ;
	   
statement : var_declaration
		{fprintf(logout,"Line no %d->statement : var_declaration\n\n",line_count);}	
	  | expression_statement
		{fprintf(logout,"Line no %d->statement : expression_statement\n\n",line_count);}
	  | compound_statement
		{fprintf(logout,"Line no %d-> statement : compound_statement\n\n",line_count);}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{fprintf(logout,"Line no %d->statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count); table->Exit(); cout<<"exitscope for "; }
	  | IF LPAREN expression RPAREN statement
		{fprintf(logout,"Line no %d->statement: IF LPAREN expression RPAREN statement\n\n",line_count); table->Exit(); cout<<"exitscope if "; }
	  | IF LPAREN expression RPAREN statement ELSE statement
		{fprintf(logout,"Line no %d->statement: IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count); 
		table->Exit(); cout<<"exitscope";}
	  | WHILE LPAREN expression RPAREN statement
		{fprintf(logout,"Line no %d->statement: WHILE LPAREN expression RPAREN statement\n\n",line_count); table->Exit(); cout<<"exitscopewhile";}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
fprintf(logout,"Line no %d->statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);  

if($3->value.c==0) fprintf(logout,"Value of %s is %d\n\n",$3->name.c_str(),$3->value.ival);
else if($3->value.c=0) fprintf(logout,"Value of %s is %f\n\n",$3->name.c_str(),$3->value.fval);


}
	  | RETURN expression SEMICOLON
		{fprintf(logout,"Line no %d->statement: RETURN expression SEMICOLON\n\n",line_count);}
	  ;
	  
expression_statement 	: SEMICOLON
		{fprintf(logout,"Line no %d->expression_statement : SEMICOLON\n\n",line_count);$$=$1;}			
			| expression SEMICOLON 
		{fprintf(logout,"Line no %d->expression_statement : expression SEMICOLON\n\n",line_count);$$=$1;}
			;
	  
variable : ID 		
		{  fprintf(logout,"Line no %d-> variable: ID\n %s\n\n",line_count,$1->name.c_str());
                     SymbolInfo* d=table->LookUp($1->name);
                     if(d==NULL) {fprintf(errorout,"Line no %d: Undeclared Variable %s \n\n",line_count,$1->name.c_str()); $$=dam; error_count++; }
                     else if(d->value.c==2 || d->value.c==3) {fprintf(errorout,"Line no %d: %s is Araay Type\n\n",line_count,$1->name.c_str());                  $$=dam; error_count++; } 
                     else {$$=d;}    
}
	 | ID LTHIRD expression RTHIRD 
		{
                   fprintf(logout,"Line no %d-> variable: ID LTHIRD expression RTHIRD\n %s\n\n",line_count,$1->name.c_str());
                SymbolInfo* d=table->LookUp($1->name);
                 if(d==NULL) {fprintf(errorout,"Line no %d: Undeclared variable %s \n\n",line_count,$1->name.c_str()); $$=dam; error_count++;}
                 
                 else { 
                         
                        if(d->value.c!=2 && d->value.c!=3) {fprintf(errorout,"Line no %d: %s is not a Array type\n\n",line_count,d->name.c_str()); $$=dam; error_count++; }
                        else if (d->value.arraysize<$3->value.ival){fprintf(errorout,"Line no %d: ArrayOutOfBound Error\n\n",line_count); $$=dam; error_count++;}
                        else if ($3->value.c==1) {fprintf(errorout,"Line no %d: Array Index is not  <INT> type\n\n",line_count); $$=dam; error_count++;} 
                        else if ($3->value.ival<0) {fprintf(errorout,"Line no %d: Array Index is Negative\n\n",line_count); $$=dam; error_count++;}
                        else if ($3->value.arrayl==1) {fprintf(errorout,"Line no %d: Ivalid Index found \n\n"); $$=dam; error_count++;} 
                        else  {  d->value.arraypos=$3->value.ival; $$=d;}
                     }
}
	 ;
	 
 expression : logic_expression	
		{fprintf(logout,"Line no %d->expression-> logic_expression\n\n",line_count); $$=$1;}
	   | variable ASSIGNOP logic_expression 	
		{
fprintf(logout,"Line no %d->expression-> variable ASSIGNOP logic_expression\n\n",line_count);
           
          //SymbolInfo* p= new SymbolInfo;
          if($1->value.c==0 && $3->value.c==0) {$1->value.ival=$3->value.ival;}
          else if($1->value.c==0 && $3->value.c==1) { fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",line_count); error_count++;  $1->value.ival=$3->value.fval;}
          else if($1->value.c==0 && $3->value.c==2) { $1->value.ival=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==0 && $3->value.c==3) { fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",line_count);
error_count++;  $1->value.ival=$3->value.farray[$3->value.arraypos];}

          else if($1->value.c==1 && $3->value.c==0) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",line_count); error_count++;  $1->value.fval=$3->value.ival;}
          else if($1->value.c==1 && $3->value.c==1) {$1->value.fval=$3->value.fval;}
          else if($1->value.c==1 && $3->value.c==2) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",line_count); error_count++;  $1->value.fval=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==1 && $3->value.c==3) {$1->value.fval=$3->value.farray[$3->value.arraypos];}

          else if($1->value.c==2 && $3->value.c==0) {$1->value.iarray[$1->value.arraypos]=$3->value.ival;}
          else if($1->value.c==2 && $3->value.c==1) {fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",line_count); error_count++;  $1->value.iarray[$1->value.arraypos]=$3->value.fval;}
          else if($1->value.c==2 && $3->value.c==2) {$1->value.iarray[$1->value.arraypos]=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==2 && $3->value.c==3) {fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",line_count);
error_count++;   $1->value.iarray[$1->value.arraypos]=$3->value.farray[$3->value.arraypos]; }

          else if($1->value.c==3 && $3->value.c==0) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",line_count); error_count++;  $1->value.farray[$1->value.arraypos]=$3->value.ival; } 
          else if($1->value.c==3 && $3->value.c==1) { $1->value.farray[$1->value.arraypos]=$3->value.fval; }
          else if($1->value.c==3 && $3->value.c==2) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",line_count); error_count++;  $1->value.farray[$1->value.arraypos]=$3->value.iarray[$3->value.arraypos]; }
          else if($1->value.c==3 && $3->value.c==3) {$1->value.farray[$1->value.arraypos]=$3->value.farray[$3->value.arraypos];}  
          $$=$1;
          
      table->PrintAll();

}
	   ;
			
logic_expression : rel_expression
	{fprintf(logout,"Line no %d->logic_expression : rel_expression\n\n",line_count); $$=$1;} 	
		 | rel_expression LOGICOP rel_expression 	
	{
fprintf(logout,"Line no %d->logic_expression : rel_expression LOGICOP rel_expression\n\n",line_count);
                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
                  SymbolInfo* p= new SymbolInfo;
                  string op=$2->name;
                  int temp;
               if($1->value.c==0 && $3->value.c==0) {
                       int x=$1->value.ival;
                       int y=$3->value.ival;
                         
                if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
               else if($1->value.c==0 && $3->value.c==1) {
                         int x=$1->value.ival;
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                 
                else if($1->value.c==0 && $3->value.c==2) {
                         int x=$1->value.ival;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                else if($1->value.c==0 && $3->value.c==3) {
                         int x=$1->value.ival;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                  
                     
                else if($1->value.c==1 && $3->value.c==0) {
                         float x=$1->value.fval;
                         int y=$3->value.ival;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                else if($1->value.c==1 && $3->value.c==1) {
                         float x=$1->value.fval;
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                
                else if($1->value.c==1 && $3->value.c==2) {
                         float x=$1->value.fval;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

                else if($1->value.c==1 && $3->value.c==3) {
                         float x=$1->value.fval;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
 
                else if($1->value.c==2 && $3->value.c==0) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                
               else if($1->value.c==2 && $3->value.c==1) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                else if($1->value.c==2 && $3->value.c==2) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

  
                else if($1->value.c==2 && $3->value.c==3) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

                else if($1->value.c==3 && $3->value.c==0) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

                else if($1->value.c==3 && $3->value.c==1) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

               else if($1->value.c==3 && $3->value.c==2) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
               else if($1->value.c==3 && $3->value.c==3) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
 
         p->value.c=0;
         p->value.ival=temp;
         $$=p;
        
 
}

  

}
		 ;
			
rel_expression	: simple_expression 
	{fprintf(logout,"Line no %d->rel_expression	: simple_expression\n\n",line_count); $$=$1;}
		| simple_expression RELOP simple_expression	
	{
                 fprintf(logout,"Line no %d->rel_expression: simple_expression RELOP simple_expression\n\n",line_count);
                 
                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
                  SymbolInfo* p= new SymbolInfo;
                  string op=$2->name;
                  int temp;
               if($1->value.c==0 && $3->value.c==0) {
                       int x=$1->value.ival;
                       int y=$3->value.ival;
                         
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
		                                }
               else if($1->value.c==0 && $3->value.c==1) {
                         int x=$1->value.ival;
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	
                                }
                 
                else if($1->value.c==0 && $3->value.c==2) {
                         int x=$1->value.ival;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                else if($1->value.c==0 && $3->value.c==3) {
                         int x=$1->value.ival;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                  
                     
                else if($1->value.c==1 && $3->value.c==0) {
                         float x=$1->value.fval;
                         int y=$3->value.ival;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                else if($1->value.c==1 && $3->value.c==1) {
                         float x=$1->value.fval;
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                
                else if($1->value.c==1 && $3->value.c==2) {
                         float x=$1->value.fval;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

                else if($1->value.c==1 && $3->value.c==3) {
                         float x=$1->value.fval;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
 
                else if($1->value.c==2 && $3->value.c==0) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                
               else if($1->value.c==2 && $3->value.c==1) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                else if($1->value.c==2 && $3->value.c==2) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

  
                else if($1->value.c==2 && $3->value.c==3) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

                else if($1->value.c==3 && $3->value.c==0) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

                else if($1->value.c==3 && $3->value.c==1) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

               else if($1->value.c==3 && $3->value.c==2) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
               else if($1->value.c==3 && $3->value.c==3) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
 
         p->value.c=0;
         p->value.ival=temp;
         $$=p;
         
 
}


                  } 
		;
				
simple_expression : term 
	{fprintf(logout,"Line no %d->simple_expression : term\n\n",line_count); $$=$1;}
		  | simple_expression ADDOP term 
	{fprintf(logout,"Line no %d->simple_expression : simple_expression\n\n",line_count);

                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
                     SymbolInfo* p = new SymbolInfo;
                   if($2->name=="+"){
                       if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival+$3->value.ival;}
               else if($1->value.c==0 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.ival+$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival+$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.farray[$3->value.arraypos];}
 
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]+$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]+$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]+$3->value.farray[$3->value.arraypos];}

               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.farray[$3->value.arraypos];}

                 }
                  else if($2->name=="-"){
                    if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival-$3->value.ival;}
               else if($1->value.c==0 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.ival-$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival-$3->value.farray[$3->value.arraypos];}
 
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.farray[$3->value.arraypos];}
            
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]-$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]-$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]-$3->value.farray[$3->value.arraypos];}
                  
               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.farray[$3->value.arraypos];}


                 }

             $$=p;
             
   }  
               
     table->PrintAll();



}
		  ;
					
term :	unary_expression
	{fprintf(logout,"Line no %d->term :	unary_expression\n\n",line_count); $$=$1;}
     |  term MULOP unary_expression
	{fprintf(logout,"Line no %d->term :	term MULOP unary_expression\n\n",line_count);

        if($1->value.arrayl==1) {$$=$1;}
        else if($3->value.arrayl==1) {$$=$3;}
        else{
             SymbolInfo* p=new SymbolInfo;
             if($2->name=="*"){
               if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival*$3->value.ival;}
               else if($1->value.c==0 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.ival*$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival*$3->value.farray[$3->value.arraypos];}
     
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]*$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]*$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]*$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.farray[$3->value.arraypos];}
                 }
             else if($2->name=="/"){
               if (($3->value.c==0 && $3->value.ival==0) || ($3->value.c==1 && $3->value.fval==0) || ($3->value.c==2 && $3->value.iarray[$3->value.arraypos]) || ($3->value.c==3 && $3->value.farray[$3->value.arraypos])) {fprintf(errorout,"Line no %d: divedend by zero error\n\n",line_count); error_count++; p=dam;  }
               else if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival/$3->value.ival;}                
               else if($1->value.c==0 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.ival/$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival/$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]/$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]/$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]/$3->value.farray[$3->value.arraypos];}
             
               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.farray[$3->value.arraypos];}
                         

               }
             else if($2->name=="%"){
                
                if($1->value.c==1 || $1->value.c==3 || $3->value.c==1 || $3->value.c==3){fprintf(errorout,"Line no %d: Ivalid operands to binary %\n\n ",line_count); error_count++; p=dam;}
                else if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival % $3->value.ival;}
                else if($2->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival % $3->value.iarray[$3->value.arraypos];}
                else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos] % $3->value.ival;}
                else if($2->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos] % $3->value.iarray[$3->value.arraypos];}

               }
               

           $$=p;
           
} 
   table->PrintAll();
}
     ;

unary_expression : ADDOP unary_expression
	{ fprintf(logout,"Line no %d-> unary_expression : ADDOP unary_expression\n\n",line_count);
                   if($2->value.arrayl==1) {$$=$2;}
                   else{
                    SymbolInfo* p= new SymbolInfo;
                    if($1->name=="+") {
                        if($2->value.c==0) {p->value.c=$2->value.c; p->value.ival=$2->value.ival;}
                        else if($2->value.c==1) {p->value.c=$2->value.c; p->value.fval=$2->value.fval;}
                        else if($2->value.c==2) {p->value.c=0; p->value.ival=$2->value.iarray[$2->value.arraypos];}
                        else if($2->value.c==3) {p->value.c=1; p->value.fval=$2->value.farray[$2->value.arraypos];}
                          }
                    else if($1->name=="-"){
                        if($2->value.c==0) {p->value.c=$2->value.c; p->value.ival=-$2->value.ival;}
                        else if($2->value.c==1) {p->value.c=$2->value.c; p->value.fval=-$2->value.fval;}
                        else if($2->value.c==2) {p->value.c=0; p->value.ival=-$2->value.iarray[$2->value.arraypos];}
                        else if($2->value.c==3) {p->value.c=1; p->value.fval=-$2->value.farray[$2->value.arraypos];}
                           }
                        
                     $$=p;
                    
 }
                  table->PrintAll();
                  
}  
		 | NOT unary_expression 
	{ fprintf(logout,"Line no %d-> unary_expression : NOT unary_expression\n\n",line_count);
                   
                   if($2->value.arrayl==1){$$=$2;} 
                   else{
                   SymbolInfo* p=new SymbolInfo;
                   p->value.c=0;
                  
                   if($2->value.c==0) p->value.ival=!($2->value.ival);
                   else if($2->value.c==1) p->value.ival=!($2->value.fval);
                   else if($2->value.c==2) p->value.ival=!($2->value.iarray[$2->value.arraypos]);
                   else if($2->value.c==3) p->value.ival=!($2->value.farray[$2->value.arraypos]);
                   $$=p;
                   
                         }
                  table->PrintAll();
}
		 | factor 
	{fprintf(logout,"Line no %d->unary_expression: factor\n\n",line_count); $$=$1;}
		 ;
	
factor	: variable
	{fprintf(logout,"Line no %d->factor: variable\n\n",line_count); $$=$1;} 
	| ID LPAREN argument_list RPAREN
	{fprintf(logout,"Line no %d->factor: ID LPAREN argument_list RPAREN\n\n",line_count);
             SymbolInfo* p=new SymbolInfo;
           SymbolInfo* temp=table->LookUp($1->name);
         
          if(temp==NULL) {fprintf(errorout,"Error at Line %d: function is not defined\n\n",line_count); p=dam; error_count++;}
          else if(temp->isF==0) {fprintf(errorout,"Error at Line %d: function is only declared , no defined\n\n",line_count); p=dam; error_count++; }
          else if(temp->isF==-1) {fprintf(errorout,"Error at Line %d: Not a Function\n\n",line_count); p=dam; error_count++; }
          else if(temp->fsize!=pos1 ) {fprintf(errorout,"Error at Line %d: parameter numbers are no equal\n\n",line_count); p=dam; error_count++;} 
          else if(temp->fsize==0 && pos1==0 && temp->fsign==0) {p->value.c=0; p->value.ival=temp->funi;}
          else if(temp->fsize==0 && pos1==0 && temp->fsign==1) {p->value.c=1; p->value.fval=temp->funf;}
          else if(temp->fsize==0 && pos1==0 && temp->fsign==2) {}
          
          else  if(temp->fsize==pos1){ int i=0,k=0;
for(i=0;i<temp->fsize;i++){if(temp->f[i]!=flow1[i]) {fprintf(errorout,"Error at Line %d: perameter is not matched\n\n",line_count);} p=dam; k=1; error_count++; break; }
          if(k==0){
                   if(temp->fsign==0) {p->value.c=0; p->value.ival=temp->funi;}
                   else if(temp->fsign==1) {p->value.c=1; p->value.fval=temp->funf;}
                   else if(temp->fsign==2) {p->value.arrayl=1;}
  }

}   
                    
         $$=p;
       pos1=0;
               


}
	| LPAREN expression RPAREN
	{fprintf(logout,"Line no %d->factor: LPAREN expression RPAREN\n\n",line_count); $$=$2;}
	| CONST_INT 
	{fprintf(logout,"Line no %d->factor: CONST_INT\n %s\n\n",line_count,$1->name.c_str()); $$=$1;}
	| CONST_FLOAT
	{fprintf(logout,"Line no %d->factor: CONST_FLOAT\n %s\n\n",line_count,$1->name.c_str()); $$=$1;}
	| variable INCOP 
	{fprintf(logout,"Line no %d->factor: variable INCOP\n\n",line_count);
$$=new SymbolInfo($1->name,$1->type,$1->value.ival,$1->value.fval,$1->value.arraysize,$1->value.arraypos,-1111,-1111,$1->value.c);
 
                          if($1->value.arrayl==1){$$->value.arrayl=1;}
                          else {  //$$=$1;
                          int c=$1->value.arraypos;  
                          if($1->value.c==0) {$1->value.ival=$1->value.ival+1; 
                         
                       

}
                          else if($1->value.c==1) {$1->value.fval=$1->value.fval+1;}
                          else if($1->value.c==2) {
                        
                           
                            $$->value.iarray[c]=$1->value.iarray[c];
                           $1->value.iarray[c]=$1->value.iarray[c]+1;
                            
}
                          else if($1->value.c==3) {$$->value.farray[c]=$1->value.farray[c]; $1->value.farray[c]=$1->value.farray[c]+1;}
                          }
                         
                          
                          table->PrintAll(); 
  
}

	| variable DECOP
	{ fprintf(logout,"Line no %d->factor: variable DECOP\n\n",line_count);
                $$=new SymbolInfo($1->name,$1->type,$1->value.ival,$1->value.fval,$1->value.arraysize,$1->value.arraypos,-1111,-1111,$1->value.c); 
                   
                  if($1->value.arrayl==1){$$->value.arrayl=1;}
                  else {  
                          int c=$1->value.arraypos;  
                          
                          if($1->value.c==0) {  
                            
                            
                            $1->value.ival=$1->value.ival-1;
                            
                            
                              }
                          else if($1->value.c==1) { $1->value.fval=$1->value.fval-1; }
                          else if($1->value.c==2) { 
                          
                          
                           $$->value.iarray[c]=$1->value.iarray[c];
                           $1->value.iarray[c]=$1->value.iarray[c]-1;
                           

}
                          else if($1->value.c==3) {$$->value.farray[c]=$1->value.farray[c]; $1->value.farray[c]=$1->value.farray[c]-1;  } 
                       }
                     
                     
                     table->PrintAll(); 
           }
	;
	
argument_list : arguments
	{fprintf(logout,"Line no %d->argument_list: arguments\n\n",line_count);} 
			  |
	{fprintf(logout,"Line no %d->argument_list: ",line_count); }
			  ;
	
arguments : arguments COMMA logic_expression
	{fprintf(logout,"Line no %d->arguments: arguments COMMA logic_expression\n\n",line_count);               
                              if($3->value.c==0 || $3->value.c==1) {flow1[pos1]=$3->value.c; pos1++;}
                              else {flow1[pos]=-2; pos++;}

}
	      | logic_expression
	{fprintf(logout,"Line no %d->arguments: logic_expression\n\n",line_count); 


              
               if($1->value.c==0 || $1->value.c==1) {flow1[pos1]=$1->value.c; pos1++;}
               else {flow1[pos]=-2; pos++;}
}
	      ;
 







%%
int main(int argc,char *argv[])
{

	table=new SymbolTable(7);
        dam=new SymbolInfo;
        dam->value.arrayl=1;
        dam->value.c=-2;

        
	FILE *fp;	
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}


        logout=fopen("log.txt","w");
        errorout=fopen("error.txt","w");	
	

	yyin=fp;
	yyparse();

        fprintf(logout,"Total Line: %d\n\n",line_count);
        fprintf(logout,"Total Error: %d\n\n",error_count);
        
	fclose(yyin);
        fclose(logout);
        fclose(errorout);

	
	return 0;
}

