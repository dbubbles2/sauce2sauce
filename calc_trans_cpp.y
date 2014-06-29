%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "struct.h"

extern int yyline;

typedef struct {
	char *name;
	int value;
	int isInit;
}word;

int word_count = 0;


word wordtable[20000];

void yyerror(char *str);
int yyparse();
int yylex();
char *endString;

void UpdateWordTable(char * word);
int FindWord(char *word);
int StringEqualsInsensitive(char * stringA, char * stringB);

%}
	
%union {
	int value;
	char *idName;
	doody semantic_value;
}

%token SEMItoken 		
%token COMMAtoken
%token <value> ICONSTtoken	
%token LPARENtoken	
%token RPARENtoken	
%token EQtoken		
%token MINUStoken		
%token PLUStoken		
%token TIMEStoken			
%token BEGINtoken		
%token DIVtoken		
%token <idName> IDtoken	
%token ENDtoken		
%token IStoken		
%token PROGRAMtoken	
%token VARtoken		
%token PRINTtoken	

%type <semantic_value> program
%type <semantic_value> compound
%type <semantic_value> statements
%type <semantic_value> statement
%type <semantic_value> declaration
%type <semantic_value> id
%type <semantic_value> exp
%type <semantic_value> terms
%type <semantic_value> term
%type <semantic_value> factors
%type <semantic_value> factor


%left PLUStoken MINUStoken
%left DIVtoken TIMEStoken

%%

program 	:	PROGRAMtoken IDtoken IStoken compound
				{
					strcat(endString, "#include <iostream>\n\n");
					strcat(endString, "using namespace std;\n\n");
					strcat(endString, "main()");
					$$.butt_str = $4.butt_str;
					strcat(endString, "{\n");
					strcat(endString, $$.butt_str);
					strcat(endString, ";\n\n}");

					FILE * fp = fopen("mya.cpp", "w");
					fprintf(fp, "%s\n", endString);
					fclose(fp);
					
				}
			
compound	:	BEGINtoken statements ENDtoken
				{
					$$.butt_str = $2.butt_str;
				}
			
statements	:	statement
				{
					$$.butt_str = $1.butt_str;
				}
			|	statement SEMItoken statements
				{
					$$.butt_str = malloc(strlen($1.butt_str) + strlen($3.butt_str) + 10);
					//think on this onec
					strncpy($$.butt_str, $1.butt_str, strlen($1.butt_str));
					strcat($$.butt_str, ";\n");
					strcat($$.butt_str, $3.butt_str);
				}

statement 	:	IDtoken EQtoken exp
				{
					int num = FindWord($1);
					
					if(num == -1)
						yyerror($1);

					wordtable[num].isInit = 1;
					wordtable[num].value = $3.val;
					$$.val = $3.val;
					$$.butt_str = malloc(strlen($1)+strlen($3.butt_str)+10);
					$$.butt_str = $1;
					strcat($$.butt_str, "=");
					strcat($$.butt_str, $3.butt_str);
				}
			|	PRINTtoken exp
				{
					$$.butt_str = malloc(strlen($2.butt_str)+10);
					sprintf($$.butt_str, "cout << %s", $2.butt_str);
					printf("%i\n", $2.val);
				}
			|	declaration
				{
					$$.butt_str = $1.butt_str;
				}
			

declaration	:	VARtoken id
				{
					$$.butt_str = malloc(strlen($2.butt_str)+10);
					sprintf($$.butt_str, "int %s", $2.butt_str);
				}
			

id 			:	IDtoken
				{
					int num = FindWord($1);
					if(num != -1)
						yyerror($1);

					UpdateWordTable($1);
					$$.butt_str = $1;
				}
			|	 IDtoken COMMAtoken id
				{
					int num = FindWord($1);
					if(num != -1)
						yyerror($1);
					UpdateWordTable($1);

					$$.butt_str = malloc(1000);
					strcat($$.butt_str, $1);
					strcat($$.butt_str, ", ");
					strcat($$.butt_str, $3.butt_str);
				}
			
exp 		:	MINUStoken terms
				{
					$$.butt_str = malloc(strlen($2.butt_str) + 5);
					sprintf($$.butt_str, "-%s", $2.butt_str);
					$$.val = $2.val * -1;
				}
			|	terms
				{
					$$.val = $1.val;
					$$.butt_str = $1.butt_str;
				}
			

terms		:	term
				{
					$$.val = $1.val;
					$$.butt_str = $1.butt_str;
				}
			|	term PLUStoken terms
				{
					$$.butt_str = malloc(strlen($1.butt_str));
					strcat($$.butt_str, $1.butt_str);
					strcat($$.butt_str, " + ");
					strcat($$.butt_str, $3.butt_str);

					$$.val = $1.val + $3.val;
				}
			|	term MINUStoken terms
				{
					$$.butt_str = malloc(strlen($1.butt_str));
					strcat($$.butt_str, $1.butt_str);
					strcat($$.butt_str, " - ");
					strcat($$.butt_str, $3.butt_str);

					$$.val = $1.val - $3.val;
				}
			

term		: 	factors
				{
					$$.val = $1.val;
					$$.butt_str = $1.butt_str;
				}
			

factors		:	factor
				{
					$$.val = $1.val;
					$$.butt_str = $1.butt_str;
				}
			|	factors TIMEStoken factor
				{
					$$.butt_str = malloc(strlen($1.butt_str));
					strcat($$.butt_str, $1.butt_str);
					strcat($$.butt_str, "*");
					strcat($$.butt_str, $3.butt_str);

					$$.val = $1.val * $3.val;
				}
			|	factors DIVtoken factor
				{
					if($3.val == 0){
						printf("\nDivide by zero error on line %i\n", yyline);
						exit(1);
					}

					$$.butt_str = malloc(strlen($1.butt_str));
					strcat($$.butt_str, $1.butt_str);
					strcat($$.butt_str, "/");
					strcat($$.butt_str, $3.butt_str);

					$$.val = $1.val / $3.val;
				}
			

factor		:	ICONSTtoken
				{
					char *tmp = malloc(80);
					
					$$.val = $1;
					sprintf(tmp, "%d", $1);
					$$.butt_str = tmp;

				}
			|	IDtoken
				{
					int num = FindWord($1);
					if(num == -1)
						yyerror($1);

					if(wordtable[num].isInit == 0)
						yyerror($1);

					$$.val = wordtable[num].value;
					$$.butt_str = strdup($1);
				}
			|	LPARENtoken exp RPARENtoken
				{
					$$.val = $2.val;
					$$.butt_str = malloc(strlen($2.butt_str));
					sprintf($$.butt_str, "(%s)", $2.butt_str);
				}
			


%%
void UpdateWordTable(char *word){
   int index = FindWord(word);

   if(index == -1){
      wordtable[word_count].name = strdup(word);
      wordtable[word_count].isInit = 0;
      ++word_count;
   }
   
   else{
      //wordtable[index].num += occurrences;
   }
}


int FindWord(char *word){
   int i;

   for(i = 0; i < word_count; i++)
      if(StringEqualsInsensitive(word, wordtable[i].name))
         return i;

   return -1;
}

int StringEqualsInsensitive(char * stringA, char * stringB){
   
   int i;

   if(strlen(stringA) != strlen(stringB))
      return 0;
 
   for(i = 0; i < strlen(stringA); i++)
      if(tolower(stringA[i]) != tolower(stringB[i]))
         return 0;
 
   return 1;
}


void yyerror(char *str) { 
	printf("yyerror: %s at line %d\n", str, yyline);
}

int main(void){
	endString = malloc(65000);
	
	if(yyparse()){
		printf("reject\n");
	}
	else 
		printf("accept\n");

	
	free(endString);

}






