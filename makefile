poot: lex.yy.c y.tab.c 
	gcc lex.yy.c y.tab.c -lfl -o proj2

lex.yy.c: y.tab.c lexer.l
	lex -i lexer.l

y.tab.c: calc_trans_cpp.y
	yacc -d calc_trans_cpp.y

clean: 
	rm -f lex.yy.c y.tab.c y.tab.h proj2

