all:
	flex scanner.l
	bison -d -v parser.y
	gcc -o parser lex.yy.c parser.tab.c -lfl
clean:
	rm lex.yy.c
	rm parser.tab.c
	rm parser.tab.h
	rm parser
	rm parser.output