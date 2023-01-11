.PHONY: clean

B A: B.o A.o
	gcc B.o -o B
	gcc A.o -o A

B.o: B.c
	gcc -c B.c -o B.o

A.o: A.c
	gcc -c A.c -o A.o

clean:
	rm -f *.o