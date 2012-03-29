PREFIX=/usr/bin

all:
	ocamlbuild -lib str csc.native

install: all
	install csc.native ${PREFIX}/csc

clean:
	ocamlbuild -clean
