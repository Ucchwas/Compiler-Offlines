%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<iostream>
#include<fstream>
//#include "SymbolTable.h"
#include "SymbolInfo.h"

#define YYSTYPE SymbolInfo*

using namespace std;

extern int yylex();
void yyerror(const char *s);
extern FILE *yyin;
extern int line_count;
extern int error;

string main_c = ".CODE\n\nMAIN PROC\n\nMOV AX, @DATA\nMOV DS, AX\n\n";

FILE *codeout;
FILE *logout;
FILE *errorout;
int labelCount=0;
int tempCount=0;
SymbolTable *table;
SymbolInfo* dam;
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





//SymbolTable *table= new SymbolTable(31);

%}

%error-verbose

%token IF ELSE FOR WHILE DO INT FLOAT DOUBLE CHAR RETURN VOID BREAK SWITCH CASE DEFAULT CONTINUE ADDOP MULOP ASSIGNOP RELOP
%token LOGICOP SEMICOLON COMMA LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD INCOP DECOP CONST_INT CONST_FLOAT ID NOT PRINTLN 

%nonassoc THEN
%nonassoc ELSE
%%
/*
Program : compound_statement {
	ofstream fout;
	fout.open("code.asm");
	fout << $1->code;
}
;

*/
start : program
         {
		ofstream fout;
		fout.open("code.asm");
              fout << $1->code;
              fprintf(logout,"Line no :%d start: program\n\n",line_count); 
              
              main_c = main_c + "\n\nMAIN ENDP\n\n";
             
	}
	;

program : program unit
	{
           fprintf(logout,"Line no :%d program: unit program\n\n",line_count);

	} 
       | unit {fprintf(logout,"Line no :%d program: unit \n\n",line_count); $$=$1;}
        
	
	;

unit :  
         var_declaration
	{
            fprintf(logout,"Line no :%d unit: var_declaration\n\n",line_count);
	}
     	| 
     	func_declaration
     	{
           fprintf(logout,"Line no :%d unit: func_declaration\n\n",line_count);

     	}
     	| 
     	func_definition
     	{
           fprintf(logout,"Line no :%d unit: func_definition\n\n",line_count);
           $$=$1;
     	}
       
     	;
     

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
			{
				fprintf(logout,"Line no :%d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
				
				SymbolInfo *temp = table->Look($2->name);
				if(temp != NULL){
					fprintf(errorout,"Array already declared\n\n"); 
					error++;
				}
			}
		 	|type_specifier ID LPAREN parameter_list RPAREN error
			{
				fprintf(errorout,"missing\n\n");
					error++;
			}
		 	;
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
{
		fprintf(logout,"Line no :%d func_definition:type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",line_count);
		SymbolInfo* temp=table->Look($2->name);
		if(!temp){
                        table->Insertnew($2->name,$2->type);
                        temp=table->Look($2->name);
		
                        
                              $6->code+="mov ax\n";
                              
                             $$->code +="\n"+temp->name+" proc near\n\n";
                             $$->code +="push ax\npush bx\npush cx\npush dx\n";
                             $$->code +=$6->code+"\n";
                             $$->code +="pop dx\npop cx\npop bx\npop ax\nret\n\n";
                             $$->code +=temp->name+" endp\n\n";

                            
		}

}
		| type_specifier ID LPAREN RPAREN compound_statement{
		SymbolInfo* temp=table->Look($2->name);
		if(!temp){
                        table->Insertnew($2->name,$2->type);
                        temp=table->Look($2->name);
		if(temp->name=="main") 
				{ $$=$5; 
				main_c=main_c+$5->code;  }
		}

 }
		;				


parameter_list  : parameter_list COMMA type_specifier ID
		| parameter_list COMMA type_specifier
 		| type_specifier ID
		| type_specifier
 		;


compound_statement	: LCURL statements RCURL
						{
				//fprintf(logout,"adfgusy");	
							$$=$2;
						}
					| LCURL RCURL
						{
							$$=new SymbolInfo("compound_statement","dummy");
						}
					;


var_declaration : type_specifier declaration_list SEMICOLON 

			{fprintf(logout,"Line no :%d var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);  }
                 ;
 		 ;
 		 
type_specifier	:INT  {fprintf(logout,"Line no :%d type_specifier: INT\n\n",line_count);  
                         SymbolInfo* temp=new SymbolInfo;
                         $$=temp;
                         
                          }  
 		| FLOAT {fprintf(logout,"Line no :%d type_specifier: FLOAT\n\n",line_count); 
                         SymbolInfo* temp=new SymbolInfo;
                         $$=temp;
                         
                         }
 		| VOID {fprintf(logout,"Line no :%d type_specifier: VOID\n\n",line_count);  
                         SymbolInfo* temp=new SymbolInfo;
                         $$=temp;
                         }
 		;
declaration_list : declaration_list COMMA ID{
			fprintf(logout,"Line no %d declaration_list : declaration_list COMMA ID\n %s\n\n",line_count,$3->getSymbol().c_str());
			SymbolInfo* temp = table->LookAll($3->getSymbol());
							if(temp != NULL){
								
							}
							else{
								SymbolInfo* temp2 = new SymbolInfo($3->getSymbol(), $3->getType());
								
								table->Insertnew($3->getSymbol(), $3->getType());
								
							}
	}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
			fprintf(logout,"Line no :%d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n %s\n\n",line_count,$3->getSymbol().c_str());
			if(table->Look($3->name)!=NULL) {fprintf(errorout,"Line no :%d Multiple declaration of %s",line_count,$3->getSymbol()); error++;}
                 else {
                    

                        table->Insertnew($3->name,$3->type);

                              }

}

 		  | ID{   
                 fprintf(logout,"Line no %d->declaration_list : ID\n %s \n\n",line_count,$1->getSymbol().c_str()); 
                 if(table->Look($1->name)!=NULL) {fprintf(errorout,"Line no :%d Multiple declaration of %s",line_count,$1->getSymbol().c_str());  error++;}
                 else {
                      table->Insertnew($1->name,$1->type);
                     }
                  }
 		  | ID LTHIRD CONST_INT RTHIRD {fprintf(logout,"Line no :%d declaration_list : ID LTHIRD CONST_INT RTHIRD\n %s\n\n",line_count,$1->getSymbol().c_str());
                  if(table->Look($1->name)!=NULL) 
			{fprintf(errorout,"Line no :%d Multiple declaration of %s",line_count,$1->name.c_str()); error++;}
                  else { 

                         

                         table->Insertnew($1->name,$1->type); 
                        
                 
                   
                   }
}
 		  ;

statements : statement {
				fprintf(logout,"Line no :%d statements : statement\n\n",line_count);
				$$=$1;
			}
	       | statements statement {
				fprintf(logout,"Line no :%d statements : statements statement\n\n",line_count);
				$$=$1;
				$$->code += $2->code;
				delete $2;
			}
	       ;


statement 	: 	var_declaration  {
					fprintf(logout,"Line no :%dstatement : var_declaration\n\n",line_count);
					$$=$1;
				}

			|       expression_statement {
					fprintf(logout,"Line no :%d statement : expression_statement\n\n",line_count);
					$$=$1;
				}
			| 	compound_statement {
					fprintf(logout,"Line no :%dstatement : compound_statement\n\n",line_count);
					$$=$1;
				}
			|	FOR LPAREN expression_statement expression_statement expression RPAREN statement {			
					/*
						$3's code at first, which is already done by assigning $$=$3
						create two labels and append one of them in $$->code
						compare $4's symbol with 0
						if equal jump to 2nd label
						append $7's code
						append $5's code
						append the second label in the code
					*/
					fprintf(logout,"Line no :%dstatement: FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
					$$ = $3;
					char *label1 = newLabel();
					char *label2 = newLabel();
					$$->code += string(label1) + ":\n";
					$$->code+=$4->code;
					$$->code+="mov ax , "+$4->getSymbol()+"\n";
					$$->code+="cmp ax , 0\n";
					$$->code+="je "+string(label2)+"\n";
					$$->code+=$7->code;
					$$->code+=$5->code;
					$$->code+="jmp "+string(label1)+"\n";
					$$->code+=string(label2)+":\n";
				}
			|	IF LPAREN expression RPAREN statement %prec THEN {
					fprintf(logout,"Line no :%d statement: IF LPAREN expression RPAREN statement\n\n",line_count);					
					$$=$3;
					
					char *label=newLabel();
					$$->code+="mov ax, "+$3->getSymbol()+"\n";
					$$->code+="cmp ax, 0\n";
					$$->code+="je "+string(label)+"\n";
					$$->code+=$5->code;
					$$->code+=string(label)+":\n";
					
					$$->setSymbol("if");//not necessary
				}
			|	IF LPAREN expression RPAREN statement ELSE statement {
					fprintf(logout,"Line no :%d statement: IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);					
					$$=$3;
					//similar to if part
					char *label1=newLabel();
					char *label2=newLabel();
					$$->code+="mov ax,"+$3->getSymbol()+"\n";
					$$->code+="cmp ax, 0\n";
					$$->code+="je "+string(label1)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label2)+"\n";
					$$->code+=string(label1)+":\n";
					$$->code+=$7->code;
					$$->code+=string(label2)+":\n";
				}
			|	WHILE LPAREN expression RPAREN statement {
					
					fprintf(logout,"Line no :%d statement: WHILE LPAREN expression RPAREN statement\n\n",line_count);
					$$=$3;
					
					// should be easy given you understood or implemented for loops part
					//$$ = new SymbolInfo();
					char * label1 = newLabel();
					char * label2 = newLabel();
					$$->code = string(label1) + ":\n"; 
					$$->code+=$3->code;
					$$->code+="mov ax , "+$3->getSymbol()+"\n";
					$$->code+="cmp ax , 0\n";
					$$->code+="je "+string(label2)+"\n";
					$$->code+=$5->code;
					$$->code+="jmp "+string(label1)+"\n";
					$$->code+=string(label2)+":\n";
				}
			|	PRINTLN LPAREN ID RPAREN SEMICOLON {
					fprintf(logout,"Line no :%d statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);  
					// write code for printing an ID. You may assume that ID is an integer variable.
					$$=new SymbolInfo("println","nonterminal");
					$$->code += "mov ax, " + $3->getSymbol() +"\n";
					$$->code += "call dec_out\n";
					$$->code+="mov ah,2\nmov dl,0dh\nint 21h\nmov dl,0ah\nint 21h\n";
				}
			| 	RETURN expression SEMICOLON {
					fprintf(logout,"Line no :%d statement: RETURN expression SEMICOLON\n\n",line_count);
					// write code for return.
					char * return_lbl = newLabel();
					$$=$2;
					$$->code+="mov dx,"+$2->getSymbol()+"\n";
					$$->code+="jmp   "+string(return_lbl)+"\n";
				}
			;
		
expression_statement	: SEMICOLON	{
						fprintf(logout,"Line no :%d expression_statement : SEMICOLON\n\n",line_count);
							$$=new SymbolInfo(";","SEMICOLON");
							$$->code="";
						}			
					| expression SEMICOLON {
						fprintf(logout,"Line no :%d expression_statement : expression SEMICOLON\n\n",line_count);
							$$=$1;
						}		
					;
						
variable	: ID {
				fprintf(logout,"Line no :%d variable: ID\n %s\n\n",line_count,$1->name.c_str());
				//SymbolInfo *d=st->LookAll($1->getSymbol());
				$$= new SymbolInfo($1);
				$$->code="";
				$$->setType("notarray");
		}		
		| ID LTHIRD expression RTHIRD {
			fprintf(logout,"Line no :%d variable: ID LTHIRD expression RTHIRD\n %s\n\n",line_count,$1->name.c_str());
				//SymbolInfo* temp = st->LookAll($1->getSymbol());
				$$= new SymbolInfo($1);
				$$->setType("array");
				

				$$->code=$3->code+"mov bx, " +$3->getSymbol() +"\nadd bx, bx\n";
				
				delete $3;
		}	
		;
			
expression : logic_expression {
		fprintf(logout,"Line no :%d expression: logic_expression\n\n",line_count);
			$$= $1;
		}	
		| variable ASSIGNOP logic_expression {
		fprintf(logout,"Line no :%dexpression: variable ASSIGNOP logic_expression\n\n",line_count);
				$$=$1;
				$$->code=$3->code+$1->code;
				$$->code+="mov ax, "+$3->getSymbol()+"\n";
				if($$->getType()=="notarray"){ 
					$$->code+= "mov "+$1->getSymbol()+", ax\n";
				}
				
				else{
					$$->code+= "mov  "+$1->getSymbol()+"[bx], ax\n";
				}
				delete $3;
			}	
		;
			
logic_expression : rel_expression {
			fprintf(logout,"Line no :%d logic_expression : rel_expression\n\n",line_count);
					$$= $1;		
				}	
		| rel_expression LOGICOP rel_expression {
				fprintf(logout,"Line no :%d logic_expression : rel_expression LOGICOP rel_expression\n\n",line_count);
					$$=$1;
					$$->code+=$3->code;
					char *temp=newTemp();
					char *label1=newLabel();
					char *label2=newLabel();	
					if($2->getSymbol()=="&&"){
						$$->code += "mov ax , " + $1->getSymbol() +"\n";
						$$->code += "cmp ax , 0\n";
				 		$$->code += "je " + string(label1) +"\n";
						$$->code += "mov ax , " + $3->getSymbol() +"\n";
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
					else if($2->getSymbol()=="||"){
						$$->code += "mov ax , " + $1->getSymbol() +"\n";
						$$->code += "cmp ax , 0\n";
				 		$$->code += "jne " + string(label1) +"\n";
						$$->code += "mov ax , " + $3->getSymbol() +"\n";
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
				fprintf(logout,"Line no :%d rel_expression: simple_expression\n\n",line_count);
				$$= $1;
			}	
		| simple_expression RELOP simple_expression {
				fprintf(logout,"Line no :%d rel_expression: simple_expression RELOP simple_expression\n\n",line_count);
				$$=$1;
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->getSymbol()+"\n";
				$$->code+="cmp ax, " + $3->getSymbol()+"\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				if($2->getSymbol()=="<"){
					$$->code+="jl " + string(label1)+"\n";
				}
				else if($2->getSymbol()=="<="){
					$$->code+="jle " + string(label1)+"\n";
				}
				else if($2->getSymbol()==">"){
					$$->code+="jg " + string(label1)+"\n";
				}
				else if($2->getSymbol()==">="){
					$$->code+="jge " + string(label1)+"\n";
				}
				else if($2->getSymbol()=="=="){
					$$->code+="je " + string(label1)+"\n";
				}
				else{
					$$->code+="jne " + string(label1)+"\n";
				}
				
				$$->code+="mov "+string(temp) +", 0\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov "+string(temp)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->setSymbol(temp);
				delete $3;
			}	
		;
				
simple_expression : term {
				fprintf(logout,"Line no :%d simple_expression : term\n\n",line_count);
				$$= $1;
			}
		| simple_expression ADDOP term {
				fprintf(logout,"Line no :%d simple_expression : simple_expression\n\n",line_count);
				$$=$1;
				$$->code+=$3->code;
				
				// move one of the operands to a register, perform addition or subtraction with the other operand and move the result in a temporary variable  
				
				if($2->getSymbol()=="+"){
					char* temp = newTemp();
					$$->code += "mov ax, " + $1->getSymbol() + "\n";
					$$->code += "add ax, " + $3->getSymbol() + "\n";
					$$->code += "mov " + string(temp) +" , ax\n";
					$$->setSymbol(string(temp));
				}
				else{
					char* temp = newTemp();
					$$->code += "\tmov ax, " + $1->getSymbol() + "\n";
					$$->code += "\tsub ax, " + $3->getSymbol() + "\n";
					$$->code += "\tmov " + string(temp) +" , ax\n";
					$$->setSymbol(string(temp));
				}
				delete $3;
				cout << endl;
			}
				;
				
term :	unary_expression {			fprintf(logout,"Line no :%d term :unary_expression\n\n",line_count);
						$$= $1;
						}
	 | 	term MULOP unary_expression {	
						fprintf(logout,"Line no :%d term :term MULOP unary_expression\n\n",line_count);
						$$=$1;
						$$->code += $3->code;
						$$->code += "mov ax, "+ $1->getSymbol()+"\n";
						$$->code += "mov bx, "+ $3->getSymbol() +"\n";
						char *temp=newTemp();
						if($2->getSymbol()=="*"){
							$$->code += "mul bx\n";
							$$->code += "mov "+ string(temp) + ", ax\n";
						}
						else if($2->getSymbol()=="/"){
							$$->code += "xor dx , dx\n";
							$$->code += "div bx\n";
							$$->code += "mov " + string(temp) + " , ax\n";
							// clear dx, perform 'div bx' and mov ax to temp
						}
						else{
							$$->code += "xor dx , dx\n";
							$$->code += "div bx\n";
							$$->code += "mov " + string(temp) + " , dx\n";
							// clear dx, perform 'div bx' and mov dx to temp
						}
						$$->setSymbol(temp);
						cout << endl << $$->code << endl;
						
						delete $3;
						}
	 ;

unary_expression 	:	ADDOP unary_expression  { 
					fprintf(logout,"Line no :%d unary_expression : ADDOP unary_expression\n\n",line_count);
							$$=$2;
						if($1->getSymbol() == "+"){
							$$=$2;
						}
						else if($1->getSymbol() == "-")
						{
							$$ = $2;
							$$->code += "mov ax, " + $2->getSymbol() + "\n";
							$$->code += "neg ax\n";
							$$->code += "mov " + $2->getSymbol() + " , ax\n";
						}
							// Perform NEG operation if the symbol of ADDOP is '-'
						}
					|	NOT unary_expression {
						fprintf(logout,"Line no :%d unary_expression : NOT unary_expression\n\n",line_count);
							$$=$2;
							char *temp=newTemp();
							$$->code="mov ax, " + $2->getSymbol() + "\n";
							$$->code+="not ax\n";
							$$->code+="mov "+string(temp)+", ax";
						}
					|	factor {
						fprintf(logout,"Line no :%d unary_expression: factor\n\n",line_count); 
							$$=$1;
						}
					;
	
factor	: variable {    fprintf(logout,"Line no :%dfactor: variable\n\n",line_count);
			$$= $1;
			
			if($$->getType()=="notarray"){
				
			}
			
			else{
				char *temp= newTemp();
				$$->code+="mov ax, " + $1->getSymbol() + "[bx]\n";
				$$->code+= "mov " + string(temp) + ", ax\n";
				$$->setSymbol(temp);
			}
			}
	| LPAREN expression RPAREN { fprintf(logout,"Line no :%dfactor: LPAREN expression RPAREN\n\n",line_count);
			$$= $2;
			}
	| CONST_INT {   fprintf(logout,"Line no :%dfactor: CONST_INT\n %s\n\n",line_count,$1->name.c_str());
			$$= $1;
			}
	| CONST_FLOAT {
			fprintf(logout,"Line no :%d factor: CONST_FLOAT\n %s\n\n",line_count,$1->name.c_str());
			$$= $1;
			}
	| variable INCOP {
			 fprintf(logout,"Line no :%dfactor: variable INCOP\n\n",line_count);
			$$=$1;
			// perform incop depending on whether the varaible is an array or not

			$$=$1;
			$$->code += "mov ax , " + $$->getSymbol()+ "\n";
			$$->code += "add ax , 1\n";
			$$->code += "mov " + $$->getSymbol() + " , ax\n";
			}
	| variable DECOP
			{
		        fprintf(logout,"Line no :%dfactor: variable DECOP\n\n",line_count);
			$$ = $1;
			
			$$->code += "mov ax , " + $$->getSymbol()+ "\n";
			$$->code += "sub ax , 1\n";
			$$->code += "mov " + $$->getSymbol() + " , ax\n";
	}
	;
	

		
%%


void yyerror(const char *s){
	cout << "Error at line no " << line_count << " : " << s << endl;
}

int main(int argc, char * argv[]){
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	
	logout=fopen("log.txt","w");
        errorout=fopen("error.txt","w");
        codeout=fopen("code.asm","w");
	yyin= fin;
	yyparse();
	cout << endl;
	cout << endl << "\t\tsymbol table: " << endl;
	//table->dump();
	
	printf("\nTotal Lines: %d\n",line_count);
	printf("\nTotal Errors: %d\n",error);
	
	printf("\n");

	fclose(yyin);
        fclose(logout);
        fclose(errorout);
	return 0;
}
