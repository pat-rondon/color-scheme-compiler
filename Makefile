all:
	ocamlbuild -lib str csc.native

clean:
	ocamlbuild -clean
