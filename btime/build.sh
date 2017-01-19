#!/bin/bash

g++ -fPIC -c btime.cpp
g++ btime.o -m32 -lstdc++ -shared -Wl,-soname,btime.so -o btime.so
