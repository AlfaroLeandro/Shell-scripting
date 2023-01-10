4: 4_APL3_s.o 4_APL3_c.o
	gcc 4_APL3_s.o -o 4s -lprocps
	gcc 4_APL3_c.o -o 4c -lprocps

4_APL3.o: 4_APL3_s.c 4_APL3_c.c
	gcc -c 4_APL3_s.c
	gcc -c 4_APL3_c.c

depend:
	makedepend 4_APL3_s.c
	makedepend 4_APL3_c.c
