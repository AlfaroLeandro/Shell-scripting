.PHONY: clean

B A: B.o A.o
	gcc B.o -o B
	gcc A.o -o A

B.o: 3_APL3.c
	gcc -c 3_APL3.c -o B.o

A.o: A.c
	gcc -c A.c -o A.o

clean:
	rm -f *.o