# template-acm-conference
Template repo for ACM conference style

## Build

Requires a TeX Live installation with `latexmk`, `pdflatex`, and `bibtex`.

```sh
make          # build main.pdf
make view     # continuous rebuild + preview on change
make clean    # remove auxiliary files (keeps main.pdf)
make distclean # remove auxiliary files and main.pdf
```

The paper source is [main.tex](main.tex) with references in [biblio.bib](biblio.bib).

Note: if the system TeX Live is broken (e.g. missing `/var/lib/texmf`), the
Makefile automatically falls back to a repo-local state in `.texlive/` (formats
and font maps, bootstrapped on first run; only the generated `.texlive/var/`
is gitignored). On a healthy installation nothing special happens.
