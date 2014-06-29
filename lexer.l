%{
#include "struct.h"
#include "y.tab.h"
#include "stdio.h"
#include "string.h"


int yyline = 1, yycolumn = 1;
%}

delim   [ \t]    
ws 		{delim}+
letter 	[a-zA-Z]
digit	[0-9]
id 		{letter}({letter}|{digit})*
number	{digit}+


%%

\n 								{++yyline; yycolumn = 1;}

[b][e][g][i][n]					{return BEGINtoken;}
[p][r][i][n][t]					{ return PRINTtoken;}
[e][n][d]						{ return ENDtoken;}
[d][i][v]						{ return DIVtoken;}
[i][s]							{ return IStoken;}
[v][a][r]						{ return VARtoken;}
[p][r][o][g][r][a][m]			{ return PROGRAMtoken;}
{ws}							{yycolumn+=yyleng;}

{number}						{ yylval.value = atoi(yytext);
								return ICONSTtoken;}
";"								{ return SEMItoken;}
","								{ return COMMAtoken;}
"("								{ return LPARENtoken;}
")"								{ return RPARENtoken;}
"="								{ return EQtoken;}
"-"								{ return MINUStoken;}
"+"								{ return PLUStoken;}
"*"								{ return TIMEStoken;}

{id}							{yylval.idName = strdup(yytext);
								return IDtoken;}
.								{printf("Unknown character %s, line = %d, column = %d\n", 
								yytext, yyline, yycolumn);yycolumn += yyleng;}


%%




