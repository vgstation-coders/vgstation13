all: compile link

compile:
	g++ -fPIC -O3 -c btime.cpp -m32

link:
	g++ btime.o -O3 -m32 -lstdc++ -lrt -shared -Wl,-soname,btime.so -o btime.so

install:
	cp btime.so /usr/local/lib
