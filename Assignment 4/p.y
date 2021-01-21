%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<fstream>
#include<cmath>
#include "SymbolTable.h"

#define YYSTYPE SymbolInfo*

using namespace std;

extern string yy;
string par_list;
string program;
string unit;
string func_dec;
string type1;
string var_dec;
string dec_list;
string var;
string args;
string logic;
string expr;
string expr_st;
string rel;
string simple;
string term;
string unary;
string factor;
int yyparse(void);
int yylex(void);
extern FILE *yyin;

int labelCount=0;
int tempCount=0;

string main_c = ".CODE\n\nMAIN PROC\n\nMOV AX, @DATA\nMOV DS, AX\n\n";
extern int lin_count;
extern int error_count;
int type;
SymbolTable* table;
SymbolInfo* dam;
FILE *logout;
FILE *errorout;
FILE *aout;
int pos=0;
int flow[10];
int pos1=0;
int flow1[10];
void yyerror(char *s)
{
	//write your code
}

char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}
%}


%token IF ELSE FOR INT CHAR WHILE FLOAT VOID RETURN PRINTLN ID ADDOP MULOP INCOP DECOP RELOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON ASSIGNOP CONST_CHAR CONST_INT CONST_FLOAT LOGICOP MAIN DO BREAK DOUBLE SWITCH CASE DEFAULT CONTINUE COMMENT




%nonassoc noelse 

%nonassoc ELSE

%%

start : program
         {
	
              	
              {fprintf(logout,"Line no :%d start: program\n\n",lin_count);} 
             //write your code in this block in all the similar blocks below
	}
	;

program : program unit
	{
	   program=program+unit;
	   unit="\0";
           fprintf(logout,"Line no : %d  program : program unit \n\n%s\n\n",lin_count,yy.c_str());
		
	} 
       | unit {
	program=unit;
	fprintf(logout,"Line no : %d  program: unit \n\n%s\n\n",lin_count,program.c_str());}
        
	
	;
unit :  
         var_declaration
	{
		unit=var_dec;
            fprintf(logout,"Line no : %d  unit: var_declaration\n\n%s\n\n",lin_count,unit.c_str());
	}
     	| 
     	func_declaration
     	{
		unit=func_dec;
           fprintf(logout,"Line no : %d  unit: func_declaration\n\n%s\n\n",lin_count,unit.c_str());

     	}
     	| 
     	func_definition
     	{
           fprintf(logout,"Line no : %d  unit: func_definition\n\n",lin_count);
     	}
       
     	;
     
func_declaration : type_specifier ID lparen parameter_list RPAREN SEMICOLON
			{
			type1="int ";
			func_dec=type1+$2->name+"("+$4->name+")"+";";
                           fprintf(logout,"Line no : %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n%s\n\n",lin_count,func_dec.c_str());
                        table->ExitScope();
                        cout<<" exitscope ";
                       SymbolInfo* temp=table->Look($2->name);
                        
                       if(!temp){
                         table->InsertS($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,$1->value.c);
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
                        table->AllScopePrint();
                        
                          
			}
                        else if(temp) { fprintf(errorout,"Array already declared\n\n"); error_count++;}
			

}
			| type_specifier ID LPAREN RPAREN SEMICOLON
		 	;
		 
func_definition : type_specifier ID lparen parameter_list RPAREN compound_statement
			{
			table->AllScopePrint();
                         fprintf(logout,"Line no : %d func_definition:type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",lin_count);
                        table->ExitScope();
                        cout<<" exitscope ";
                        
                        SymbolInfo* temp=table->Look($2->name);
                        
                       if(!temp){
                        table->InsertS($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,type);
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
                        
                       
                          
			}
                        else if(temp->isF==0 && (temp->fsign==0||temp->fsign==1 || temp->fsign==2)) {temp->isF=1;}
                        else if(temp->isF==1){ fprintf(errorout,"%s is already defined \n\n",temp->name.c_str()); error_count++; } 
                        else { fprintf(errorout,"Error at Line no%d: %s is a ID ",lin_count,temp->name.c_str()); error_count++; }                 

			
			}
			| type_specifier ID LPAREN RPAREN compound_statement
 		 	;
lparen :
         LPAREN  {if($1->name=="(") {table->EntryScope();}}
         ;



 

parameter_list  : parameter_list COMMA type_specifier ID {
		type1="int ";		
		par_list=par_list+","+type1+$4->name;
fprintf(logout,"Line no :%d parameter_list : parameter_list COMMA type_specifier ID\n\n%s\n\n",lin_count,par_list.c_str());

                 if(table->Look($4->name)!=NULL) {fprintf(errorout,"Error at Line :%d Multiple declaration of %s\n\n",lin_count,$4->name.c_str());  error_count++;}
                 else {table->InsertS($4->name,$4->type,-1111,-1111,1,0,-1111,-1111,type);
                       flow[pos]=$3->value.c;
                        pos++;
                      }
		//$$->s=$4->name+"["+$3->s+"]";
		//fprintf(logout,"%s\n",$$->s.c_str());
                 

}
		| parameter_list COMMA type_specifier{
		type1="int ";
		par_list=par_list+","+type1;
		fprintf(logout,"Line no :%d parameter_list : type_specifier ID\n\n%s\n\n",lin_count,par_list.c_str());
}
			 
 		| type_specifier ID  {
		type1="int ";
		par_list=type1+$2->name;
		fprintf(logout,"Line no :%d parameter_list : type_specifier ID\n\n%s\n\n",lin_count,par_list.c_str());
                 if(table->Look($2->name)!=NULL) {fprintf(errorout,"Error at Line :%d Multiple declaration of %s \n\n ",lin_count,$2->name.c_str());  error_count++;}
                 else {table->InsertS($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,type);
                        flow[pos]=$1->value.c;
                      
                        pos++;
                      }


}	 
		| type_specifier{
		type1="int ";
		par_list=type1;
		fprintf(logout,"Line no :%d parameter_list : type_specifier ID\n\n%s\n\n",lin_count,par_list.c_str());
}
 		;
 		
compound_statement : LCURL statements RCURL {fprintf(logout,"Line no : %d compound_statement : LCURL statements RCURL\n\n",lin_count);}
 		    | LCURL RCURL {fprintf(logout,"Line no : %d compound_statement : LCURL RCURL\n\n",lin_count);}
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON {
		var_dec=type1+dec_list+";";
		dec_list="\0";
		fprintf(logout,"Line no : %d  var_declaration : type_specifier declaration_list SEMICOLON\n\n%s\n\n",lin_count,var_dec.c_str());  }
                 ;
 		 
type_specifier	: INT  {fprintf(logout,"Line no %d: type_specifier : INT\n\nint\n\n",lin_count);
						
			 type=0;  
                         SymbolInfo* temp=new SymbolInfo;
			 type1="int ";
                         temp->value.c=0;
                         $$=temp;
                         
                          }  
 		| FLOAT {fprintf(logout,"Line no %d: type_specifier : FLOAT\n\nfloat\n\n",lin_count); type=1;
                         SymbolInfo* temp=new SymbolInfo;
			 type1="float ";
                         temp->value.c=1;
                         $$=temp;
                         
                         }
 		| VOID {fprintf(logout,"Line no %d: type_specifier : VOID\n\nvoid\n\n",lin_count);  type=4;
                         SymbolInfo* temp=new SymbolInfo;
			 type1="void ";
                         temp->value.c=4;
                         $$=temp;
                         }
 		;
 		
declaration_list : declaration_list COMMA ID {
		dec_list=dec_list+","+$3->name;
                 fprintf(logout,"Line no %d : declaration_list : declaration_list COMMA ID\n\n%s\n\n",lin_count,dec_list.c_str());
                 if(table->Look($3->name)!=NULL) {fprintf(errorout,"Line no : %d Multiple declaration of %s",lin_count,$3->name); error_count++;}
                 else {table->InsertS($3->name,$3->type,-1111,-1111,1,0,-1111,-1111,type);
                        
                              }

                   }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
		dec_list=dec_list+","+$3->name+"["+$5->name+"]";
                 fprintf(logout,"Line no %d : declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",lin_count,dec_list.c_str());
                  if(table->Look($3->name)!=NULL) {fprintf(errorout,"Error at Line : %d Multiple declaration of %s\n\n",lin_count,$3->name.c_str()); error_count++;}
                  else {if(type==0) {table->InsertS($3->name,$3->type,-1111,-1111,$5->value.ival,0,-1111,-1111,2);}
                        else if(type==1){table->InsertS($3->name,$3->type,-1111,-1111,$5->value.ival,0,-1111,-1111,3);}                     
}
		
                    }
 		  | ID {
		dec_list=$1->name;   
                 fprintf(logout,"Line no %d : declaration_list : ID\n\n%s \n\n",lin_count,dec_list.c_str()); 
                 if(table->Look($1->name)!=NULL) {fprintf(errorout,"Error at Line : %d Multiple declaration of %s\n\n",lin_count,$1->name.c_str());  error_count++;}
                 else {table->InsertS($1->name,$1->type,-1111,-1111,1,0,-1111,-1111,type);
                      }

                  }
 		  | ID LTHIRD CONST_INT RTHIRD {
		dec_list=$1->name+"["+$3->name+"]";		
fprintf(logout,"Line no %d : declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n%s\n\n",lin_count,$1->name.c_str());
                  if(table->Look($1->name)!=NULL) {fprintf(errorout,"Error at Line : %d Multiple declaration of %s\n\n",lin_count,$1->name.c_str()); error_count++;}
                  else { if(type==0) {table->InsertS($1->name,$1->type,-1111,-1111,$3->value.ival,0,-1111,-1111,2);}
                         else if(type==1){table->InsertS($1->name,$1->type,-1111,-1111,$3->value.ival,0,-1111,-1111,3);}                          
}
                  
                   }
 		  ;
 		  
statements : statement {fprintf(logout,"Line no : %d statements : statement\n\n",lin_count);
				$$=$1;
}
	   | statements statement {fprintf(logout,"Line no : %d statements : statements statement\n\n",lin_count);
				$$=$1;
				$$->code += $2->code;
				delete $2;
}
	   ;
	   
statement : var_declaration  {fprintf(logout,"Line no : %d statement : var_declaration\n\n",lin_count);$$=$1;}
	  | expression_statement {fprintf(logout,"Line no : %d statement : expression_statement\n\n",lin_count);$$=$1;}
	  | compound_statement  {fprintf(logout,"Line no : %d statement : compound_statement\n\n",lin_count);
		$$=$1;
}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {fprintf(logout,"Line no : %d statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",lin_count); table->ExitScope(); cout<<"exitscopefor "; 
					/*
						$3's code at first, which is already done by assigning $$=$3
						create two labels and append one of them in $$->code
						compare $4's symbol with 0
						if equal jump to 2nd label
						append $7's code
						append $5's code
						append the second label in the code
					*/
					
					$$ = $3;
					char *label1 = newLabel();
					char *label2 = newLabel();
					$$->code += string(label1) + ":\n";
					$$->code+=$4->code;
					$$->code+="mov ax , "+$4->name+"\n";
					$$->code+="cmp ax , 0\n";
					$$->code+="je "+string(label2)+"\n";
					$$->code+=$7->code;
					$$->code+=$5->code;
					$$->code+="jmp "+string(label1)+"\n";
					$$->code+=string(label2)+":\n";

}
	  | IF LPAREN expression RPAREN statement  {fprintf(logout,"Line no : %d statement: IF LPAREN expression RPAREN statement\n\n",lin_count); table->ExitScope(); cout<<"exitscope if "; 
				
					$$=$3;
					
					char *label=newLabel();
					$$->code+="mov ax, "+$3->name+"\n";
					$$->code+="cmp ax, 0\n";
					$$->code+="je "+string(label)+"\n";
					$$->code+=$5->code;
					$$->code+=string(label)+":\n";
					
					$$->setSymbol("if");

}
	  | IF LPAREN expression RPAREN statement ELSE statement {fprintf(logout,"Line no : %d statement: IF LPAREN expression RPAREN statement ELSE statement\n\n",lin_count); table->ExitScope(); cout<<"exitscope";
			$$=$3;
					//similar to if part
					char *label1=newLabel();
					char *label2=newLabel();
					$$->code+="mov ax,"+$3->name+"\n";
					$$->code+="cmp ax, 0\n";
					$$->code+="je "+string(label1)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label2)+"\n";
					$$->code+=string(label1)+":\n";
					$$->code+=$7->code;
					$$->code+=string(label2)+":\n";

}
	  | WHILE LPAREN expression RPAREN statement {fprintf(logout,"Line no : %d statement: WHILE LPAREN expression RPAREN statement\n\n",lin_count); table->ExitScope(); cout<<"exitscopewhile";
	$$=$3;
					
					// should be easy given you understood or implemented for loops part
					//$$ = new SymbolInfo();
					char * label1 = newLabel();
					char * label2 = newLabel();
					$$->code = string(label1) + ":\n"; 
					$$->code+=$3->code;
					$$->code+="mov ax , "+$3->name+"\n";
					$$->code+="cmp ax , 0\n";
					$$->code+="je "+string(label2)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label1)+"\n";
					$$->code+=string(label2)+":\n";
}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON  {
fprintf(logout,"Line no : %d statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",lin_count);  

if($3->value.c==0) fprintf(logout,"Value of %s is %d\n\n",$3->name.c_str(),$3->value.ival);
else if($3->value.c=0) fprintf(logout,"Value of %s is %f\n\n",$3->name.c_str(),$3->value.fval);

// write code for printing an ID. You may assume that ID is an integer variable.
					$$=new SymbolInfo("println","nonterminal");
					$$->code += "mov ax, " + $3->name +"\n";
					$$->code += "call dec_out\n";
					$$->code+="mov ah,2\nmov dl,0dh\nint 21h\nmov dl,0ah\nint 21h\n";

}
	  | RETURN expression SEMICOLON {fprintf(logout,"Line no : %d statement: RETURN expression SEMICOLON\n\n",lin_count);
// write code for return.					
					char * return_lbl = newLabel();
					$$=$2;
					$$->code+="mov dx,"+$2->name+"\n";
					$$->code+="jmp   "+string(return_lbl)+"\n";
}
	  ;
	  
expression_statement 	: SEMICOLON {
		expr_st=";";
		fprintf(logout,"Line no : %d expression_statement : SEMICOLON\n\n%s\n\n",lin_count,expr_st.c_str());$$=$1;
		//	$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
}			
			| expression SEMICOLON {
		expr_st=expr+";";		
		fprintf(logout,"Line no : %d expression_statement : expression SEMICOLON\n\n%s\n\n",lin_count,expr_st.c_str());$$=$1;
		//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());

}
			;
	  
variable : ID  { 
		var=$1->name;		
 fprintf(logout,"Line no : %d variable: ID\n %s\n\n",lin_count,$1->name.c_str());
                     SymbolInfo* d=table->LookAll($1->name);
                     if(d==NULL) {fprintf(errorout,"Error at Line %d: Undeclared Variable %s \n\n",lin_count,$1->name.c_str()); $$=dam; error_count++; }
                     else if(d->value.c==2 || d->value.c==3) {fprintf(errorout,"Line no %d: %s is Array Type\n\n",lin_count,$1->name.c_str());                  $$=dam; error_count++; } 
                     else {$$=d;} 
	
		//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str()); 

				$$->code="";
				$$->setType("notarray");
				fprintf(aout,"%s",$$->getType().c_str());  
}
	 | ID LTHIRD expression RTHIRD {
		var=$1->name+"["+expr+"]";
                   fprintf(logout,"Line no : %d variable: ID LTHIRD expression RTHIRD\n %s\n\n",lin_count,$1->name.c_str());
                SymbolInfo* d=table->LookAll($1->name);
                 if(d==NULL) {fprintf(errorout,"Error at Line %d: Undeclared variable %s \n\n",lin_count,$1->name.c_str()); $$=dam; error_count++;}
                 
                 else { 
                         
                        if(d->value.c!=2 && d->value.c!=3) {fprintf(errorout,"Error at Line %d: %s is not a Array type\n\n",lin_count,d->name.c_str()); $$=dam; error_count++; }
                        else if (d->value.arraysize<$3->value.ival){fprintf(errorout,"Error at Line %d: ArrayOutOfBound Error\n\n",lin_count); $$=dam; error_count++;}
                        else if ($3->value.c==1) {fprintf(errorout,"Error at Line %d: Non-integer Array Index\n\n",lin_count); $$=dam; error_count++;} 
                        else if ($3->value.ival<0) {fprintf(errorout,"Error at Line %d: Array Index is Negative\n\n",lin_count); $$=dam; error_count++;}
                        else if ($3->value.arrayl==1) {fprintf(errorout,"Error at Line %d: Ivalid Index found \n\n"); $$=dam; error_count++;} 
                        else  {  d->value.arraypos=$3->value.ival; $$=d;}
                     }
		//$$->s=$1->name+"["+$3->s+"]";
		//fprintf(logout,"%s\n",$$->s.c_str());
				$$->setType("array");
				

				$$->code=$3->code+"mov bx, " +$3->name +"\nadd bx, bx\n";
				
				delete $3;	
}
	 ;
	 
expression : logic_expression {
		expr=logic;
		fprintf(logout,"Line no : %d expression : logic_expression\n\n%s\n\n",lin_count,expr.c_str()); $$=$1;
		
		//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
}		
	   | variable ASSIGNOP logic_expression {
		expr=$1->name+"="+logic;
fprintf(logout,"Line no : %d expression : variable ASSIGNOP logic_expression\n\n",lin_count);
           
          if($1->value.c==0 && $3->value.c==0) {$1->value.ival=$3->value.ival;}
          else if($1->value.c==0 && $3->value.c==1) { fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count); error_count++;  $1->value.ival=$3->value.fval;}
          else if($1->value.c==0 && $3->value.c==2) { $1->value.ival=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==0 && $3->value.c==3) { fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count);
error_count++;  $1->value.ival=$3->value.farray[$3->value.arraypos];}

          else if($1->value.c==1 && $3->value.c==0) {fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count); error_count++;  $1->value.fval=$3->value.ival;}
          else if($1->value.c==1 && $3->value.c==1) {$1->value.fval=$3->value.fval;}
          else if($1->value.c==1 && $3->value.c==2) {fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count); error_count++;  $1->value.fval=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==1 && $3->value.c==3) {$1->value.fval=$3->value.farray[$3->value.arraypos];}

          else if($1->value.c==2 && $3->value.c==0) {$1->value.iarray[$1->value.arraypos]=$3->value.ival;}
          else if($1->value.c==2 && $3->value.c==1) {fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count); error_count++;  $1->value.iarray[$1->value.arraypos]=$3->value.fval;}
          else if($1->value.c==2 && $3->value.c==2) {$1->value.iarray[$1->value.arraypos]=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==2 && $3->value.c==3) {fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count);
error_count++;   $1->value.iarray[$1->value.arraypos]=$3->value.farray[$3->value.arraypos]; }

          else if($1->value.c==3 && $3->value.c==0) {fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count); error_count++;  $1->value.farray[$1->value.arraypos]=$3->value.ival; } 
          else if($1->value.c==3 && $3->value.c==1) { $1->value.farray[$1->value.arraypos]=$3->value.fval; }
          else if($1->value.c==3 && $3->value.c==2) {fprintf(errorout,"Error at Line %d: Type Mismatch\n\n",lin_count); error_count++;  $1->value.farray[$1->value.arraypos]=$3->value.iarray[$3->value.arraypos]; }
          else if($1->value.c==3 && $3->value.c==3) {$1->value.farray[$1->value.arraypos]=$3->value.farray[$3->value.arraypos];}  
          $$=$1;
          
	$$->s=$1->s;
		fprintf(logout,"%s\n",$$->s.c_str());

		$$=$1;
				$$->code=$3->code+$1->code;
				$$->code+="mov ax, "+$3->name+"\n";
				if($$->getType()=="notarray"){ 
					$$->code+= "mov "+$1->name+", ax\n";
				}
				
				else{
					$$->code+= "mov  "+$1->name+"[bx], ax\n";
				}
				delete $3;
}

         



	
	   ;
			
logic_expression : rel_expression {
		logic=rel;
		fprintf(logout,"Line no :%d logic_expression : rel_expression\n\n%s\n\n",lin_count,rel.c_str()); $$=$1;
		//	$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
}	 	
		 | rel_expression LOGICOP rel_expression {
		logic=$1->name+$2->name+$3->name;
fprintf(logout,"Line no :%d logic_expression : rel_expression LOGICOP rel_expression\n\n%s\n\n",lin_count,rel.c_str());
                 
                $$=$1;
					$$->code+=$3->code;
					char *temp=newTemp();
					char *label1=newLabel();
					char *label2=newLabel();	
					if($2->name=="&&"){
						$$->code += "mov ax , " + $1->name +"\n";
						$$->code += "cmp ax , 0\n";
				 		$$->code += "je " + string(label1) +"\n";
						$$->code += "mov ax , " + $3->name +"\n";
						$$->code += "cmp ax , 0\n";
						$$->code += "je " + string(label1) +"\n";
						$$->code += "mov " + string(temp) + " , 1\n";
						$$->code += "jmp " + string(label2) + "\n";
						$$->code += string(label1) + ":\n" ;
						$$->code += "mov " + string(temp) + ", 0\n";
						$$->code += string(label2) + ":\n";
						$$->setSymbol(temp);
						/* 
						Check whether both operands value is 1. If both are one set value of a temporary variable to 1
						otherwise 0
						*/
					}
					else if($2->name=="||"){
						$$->code += "mov ax , " + $1->name +"\n";
						$$->code += "cmp ax , 0\n";
				 		$$->code += "jne " + string(label1) +"\n";
						$$->code += "mov ax , " + $3->name +"\n";
						$$->code += "cmp ax , 0\n";
						$$->code += "jne " + string(label1) +"\n";
						$$->code += "mov " + string(temp) + " , 0\n";
						$$->code += "jmp " + string(label2) + "\n";
						$$->code += string(label1) + ":\n" ;
						$$->code += "mov " + string(temp) + ", 1\n";
						$$->code += string(label2) + ":\n";
						$$->setSymbol(temp);
					}
					delete $3;

  

}	
		 ;
			
rel_expression	: simple_expression {
		rel=simple;
		fprintf(logout,"Line no :%d rel_expression	: simple_expression\n\n%s\n\n",lin_count,rel.c_str()); $$=$1;
			//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
}
		| simple_expression RELOP simple_expression {
		rel=$1->name+$2->name+$3->name;
                 fprintf(logout,"Line no :%d rel_expression: simple_expression RELOP simple_expression\n\n%s\n\n",lin_count,rel.c_str());
                 
                 $$=$1;
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->name+"\n";
				$$->code+="cmp ax, " + $3->name+"\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				if($2->getSymbol()=="<"){
					$$->code+="jl " + string(label1)+"\n";
				}
				else if($2->name=="<="){
					$$->code+="jle " + string(label1)+"\n";
				}
				else if($2->name==">"){
					$$->code+="jg " + string(label1)+"\n";
				}
				else if($2->name==">="){
					$$->code+="jge " + string(label1)+"\n";
				}
				else if($2->name=="=="){
					$$->code+="je " + string(label1)+"\n";
				}
				else{
					$$->code+="jge " + string(label1)+"\n";
				}
				
				$$->code+="mov "+string(temp) +", 0\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->setSymbol(temp);
				delete $3;
		


                  } 
 



	
		;
				
simple_expression : term  {
		simple=term;
	fprintf(logout,"Line no : %d simple_expression : term\n\n%s\n\n",lin_count,simple.c_str()); $$=$1;
			//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
} 
		  | simple_expression ADDOP term {
		simple=simple+$2->name+term;		
		fprintf(logout,"Line no : %d simple_expression : simple_expression ADDOP term\n\n%s\n\n",lin_count,simple.c_str());

                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
             
   }  
               
	$$=$1;
				$$->code+=$3->code;
				
				// move one of the operands to a register, perform addition or subtraction with the other operand and move the result in a temporary variable  
				
				if($2->name=="+"){
					char* temp = newTemp();
					$$->code += "mov ax, " + $1->name + "\n";
					$$->code += "add ax, " + $3->name + "\n";
					$$->code += "mov " + string(temp) +" , ax\n";
					$$->setSymbol(string(temp));
				}
				else{
					char* temp = newTemp();
					$$->code += "\tmov ax, " + $1->name + "\n";
					$$->code += "\tsub ax, " + $3->name + "\n";
					$$->code += "\tmov " + string(temp) +" , ax\n";
					$$->setSymbol(string(temp));
				}
				delete $3;


} 
		  ;
					
term :	unary_expression {
	term=unary;	
	fprintf(logout,"Line no : %d term : unary_expression\n\n%s\n\n",lin_count,term.c_str()); $$=$1;
	//$$->s=$1->s;
	//	fprintf(logout,"%s\n",$$->s.c_str());
	unary="\0";
}
     |  term MULOP unary_expression {
		term=term+$2->name+unary;	
		fprintf(logout,"Line no : %d term : term MULOP unary_expression\n\n%s\n\n",lin_count,term.c_str());
	unary="\0";	
        if($1->value.arrayl==1) {$$=$1;}
        else if($3->value.arrayl==1) {$$=$3;}
        else{
     
           
} 
   table->AllScopePrint();
$$=$1;
						$$->code += $3->code;
						$$->code += "mov ax, "+ $1->name+"\n";
						$$->code += "mov bx, "+ $3->name +"\n";
						char *temp=newTemp();
						if($2->name=="*"){
							$$->code += "mul bx\n";
							$$->code += "mov "+ string(temp) + ", ax\n";
						}
						else if($2->name=="/"){
							$$->code += "xor dx,dx\n";
							$$->code += "div bx\n";
							$$->code += "mov "+ string(temp) + ", ax\n";
						}
						else{
							$$->code += "xor dx,dx\n";
							$$->code += "div bx\n";
							$$->code += "mov "+ string(temp) + ", dx\n";
						}
						$$->setSymbol(temp);
						cout << endl << $$->code << endl;
						fprintf(aout,"%s",$$->code.c_str());
						delete $3;
}
     ;

unary_expression : ADDOP unary_expression { 
		unary=$1->name+$2->name;		
		fprintf(logout,"Line no : %d unary_expression : ADDOP unary_expression\n\n%s\n\n",lin_count,unary.c_str());
                   if($2->value.arrayl==1) {$$=$2;}
                   else{
                    
                    
 }
                  table->AllScopePrint();
		//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
         if($1->name == "+") {$$=$2;}
                   else if($1->name == "-"){

                          $$=$2;
			  $2->code += "mov ax, " + $2->name + "\n";
			  $$->code += "neg ax\n";
			  $$->code += "mov " + $2->name + ", ax";		
 }
                  
} 
		 | NOT unary_expression { 
		unary=$1->name+$2->name;
		fprintf(logout,"Line no ; %d unary_expression : NOT unary_expression\n\n%s\n\n",lin_count,unary.c_str());
                   
                   if($2->value.arrayl==1){$$=$2;} 
                   else{
                   
                   
                         }
                  table->AllScopePrint();
$$=$2;
							char *temp=newTemp();
							$$->code="mov ax, " + $2->name + "\n";
							$$->code+="not ax\n";
							$$->code+="mov "+string(temp)+", ax";
}
		 | factor {
		unary=factor;		
		fprintf(logout,"Line no : %d unary_expression: factor\n\n%s\n\n",lin_count,unary.c_str()); $$=$1;
			//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());

}
		 ;
	
factor	: variable  {
		factor=var;		
		fprintf(logout,"Line no : %d factor: variable\n\n%s\n\n",lin_count,factor.c_str()); $$=$1;
		var="\0";
//		$$->s=$1->s;
//		fprintf(logout,"%s\n",$$->s.c_str());

if($$->getType()=="notarray"){
				
			}
			
			else{
				char *temp= newTemp();
				$$->code+="mov ax, " + $1->name + "[bx]\n";
				$$->code+= "mov " + string(temp) + ", ax\n";
				$$->setSymbol(temp);
			}
}
	| ID LPAREN argument_list RPAREN {
		factor=$1->name+"("+args+")";
		args="\0";
		fprintf(logout,"Line no : %d factor: ID LPAREN argument_list RPAREN\n\n%s\n\n",lin_count,unary.c_str());
             SymbolInfo* p=new SymbolInfo;
           SymbolInfo* temp=table->LookAll($1->name);
         
          if(temp==NULL) {fprintf(errorout,"Error at Line %d: function is not defined\n\n",lin_count); p=dam; error_count++;}
          else if(temp->isF==0) {fprintf(errorout,"Error at Line %d: function is only declared,not defined\n\n",lin_count); p=dam; error_count++; }
          else if(temp->isF==-1) {fprintf(errorout,"Error at Line %d: Not a Function\n\n",lin_count); p=dam; error_count++; }
          else if(temp->fsize!=pos1 ) {fprintf(errorout,"Error at Line %d: parameter numbers are not equal\n\n",lin_count); p=dam; error_count++;} 
          else if(temp->fsize==0 && pos1==0 && temp->fsign==0) {p->value.c=0; p->value.ival=temp->funi;}
          else if(temp->fsize==0 && pos1==0 && temp->fsign==1) {p->value.c=1; p->value.fval=temp->funf;}
          else if(temp->fsize==0 && pos1==0 && temp->fsign==2) {}
          
          else  if(temp->fsize==pos1){ int i=0,k=0;
for(i=0;i<temp->fsize;i++){if(temp->f[i]!=flow1[i]) {fprintf(errorout,"Error at Line %d: parameter is not matched\n\n",lin_count);} p=dam; k=1; error_count++; break; }
          if(k==0){
                   if(temp->fsign==0) {p->value.c=0; p->value.ival=temp->funi;}
                   else if(temp->fsign==1) {p->value.c=1; p->value.fval=temp->funf;}
                   else if(temp->fsign==2) {p->value.arrayl=1;}
  }

}   
                    
         $$=p;
       pos1=0;
              


}





	| LPAREN expression RPAREN {
		factor="("+$1->name+")";	
		fprintf(logout,"Line no :%d factor: LPAREN expression RPAREN\n\n%s\n\n",lin_count,factor.c_str()); $$=$2;
//			$$->s=$1->s;
//		fprintf(logout,"%s\n",$$->s.c_str());
}
	| CONST_INT       {
		factor=$1->name;	
		fprintf(logout,"Line no :%d factor: CONST_INT\n %s\n\n",lin_count,factor.c_str()); $$=$1;
//			$$->s=$1->s;
//		fprintf(logout,"%s\n",$$->s.c_str());
}
	| CONST_FLOAT    {
		factor=$1->name;
		fprintf(logout,"Line no :%d factor: CONST_FLOAT\n %s\n\n",lin_count,factor.c_str()); $$=$1;
//			$$->s=$1->s;
//		fprintf(logout,"%s\n",$$->s.c_str());
}
	| variable INCOP {
		factor=$1->name+"++";	
fprintf(logout,"Line no :%d factor: variable INCOP\n\n%s\n\n",lin_count,factor.c_str());
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
                         
                          
                          table->AllScopePrint();
$$=$1;
		$$->code += "mov ax , " + $$->name + "\n";
		$$->code += "add ax , 1\n";
		$$->code += " mov " + $$->name + " , ax\n";
		
  

}
	| variable DECOP { 
		factor=$1->name+"--";		
		fprintf(logout,"Line no :%d factor: variable DECOP\n\n%s\n\n",lin_count,factor.c_str());
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
                     
                     
                     table->AllScopePrint(); 
		$$->s=$1->s;
		fprintf(logout,"%s\n",$$->s.c_str());
		$$ = $1;
		
		$$->code += "mov ax , " + $$->name + "\n";
		$$->code += "sub ax , 1\n";
		$$->code += "mov " + $$->name + " , ax\n";
           }
	;
	
	
 

argument_list : arguments {
		args=args;		
fprintf(logout,"Line no %d->argument_list: arguments\n\n%s\n\n",lin_count,args.c_str());} 
                    |    {fprintf(logout,"Line no %d->argument_list: ",lin_count); 
				
}
                    ;
arguments: arguments COMMA logic_expression {
		args=args+","+logic;
		logic="\0";		
		fprintf(logout,"Line no %d->arguments: arguments COMMA logic_expression\n\n",lin_count);               
                              if($3->value.c==0 || $3->value.c==1) {flow1[pos1]=$3->value.c; pos1++;}
                              else {flow1[pos]=-2; pos++;}

}
              | logic_expression {
		args=logic;	
		fprintf(logout,"Line no %d->arguments: logic_expression\n\n%s\n\n",lin_count,args.c_str()); 


              
               if($1->value.c==0 || $1->value.c==1) {flow1[pos1]=$1->value.c; pos1++;}
               else {flow1[pos]=-2; pos++;}
		//$$->s=$1->s;
		//fprintf(logout,"%s\n",$$->s.c_str());
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
	aout=fopen("code.asm","w");

	yyin=fp;
	yyparse();

        fprintf(logout,"Total Line: %d\n\n",lin_count);
        fprintf(logout,"Total Error: %d\n\n",error_count);
        
	fclose(yyin);
        fclose(logout);
        fclose(errorout);
	fclose(aout);

	
	return 0;
}
