.PHONY: clean

5s 5c: 5_APL3_servidor.o 5_APL3_cliente.o
	gcc 5_APL3_servidor.o -o 5s
	gcc 5_APL3_cliente.o -o 5c

5_APL3_servidor.o: 5_APL3_servidor.c servidor.h
	gcc -c 5_APL3_servidor.c -o 5_APL3_servidor.o

5_APL3_cliente.o: 5_APL3_cliente.c cliente.h
	gcc -c 5_APL3_cliente.c -o 5_APL3_cliente.o

clean:
	rm -f *.o