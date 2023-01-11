.PHONY: clean

ahorcado: ahorcado_s.o ahorcado_c.o
	gcc ahorcado_s.o -o ahorcado_s
	gcc ahorcado_c.o -o ahorcado_c

ahorcado_s.o: ahorcado_s.c servidor.h
	gcc -c ahorcado_s.c -o ahorcado_s.o

ahorcado_c.o: ahorcado_c.c cliente.h
	gcc -c ahorcado_c.c -o ahorcado_c.o

clean:
	rm -f *.o