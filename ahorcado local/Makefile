ahorcado: ahorcado_s.o ahorcado_c.o
	gcc ahorcado_s.o -o ahorcado_s -lprocps
	gcc ahorcado_c.o -o ahorcado_c -lprocps

ahorcado.o: ahorcado_s.c ahorcado_c.c
	gcc -c ahorcado_s.c
	gcc -c ahorcado_c.c

depend:
	makedepend ahorcado_s.c
	makedepend ahorcado_c.c
