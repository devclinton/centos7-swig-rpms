simple:
	swig -r example.i
	R CMD SHLIB -o example.so example_wrap.c example.c
	Rscript test.R