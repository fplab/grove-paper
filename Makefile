all:
	latexmk -pdflatex=lualatex -pdf grove-paper.tex

clean:
	latexmk -C
