# Build the ACM acmart conference paper with latexmk.
# Usage: make | make view | make clean | make distclean

MAIN = main

LATEXMK      = latexmk
LATEXMK_ARGS = -pdf -interaction=nonstopmode -halt-on-error $(MAIN).tex

# ---------------------------------------------------------------------------
# Repo-local TeX Live fallback
#
# The devcontainer's system TeX Live is broken: /var/lib/texmf is missing and
# the system trees are read-only, so no pdflatex format or font map can be
# used or rebuilt system-wide. If no usable format is found in the default
# locations, switch to a private state under .texlive/ (format + curated font
# maps; the heavy generated parts under .texlive/var are gitignored) and
# bootstrap it on demand. On a healthy TeX installation the lookup below
# succeeds and none of this applies.
SYS_PDFLATEX_FMT := $(shell env -u TEXMF -u TEXMFCONFIG -u TEXMFVAR kpsewhich --format=fmt pdflatex.fmt 2>/dev/null)
ifeq ($(SYS_PDFLATEX_FMT),)
DEFAULT_TEXMF     := $(shell env -u TEXMF -u TEXMFCONFIG -u TEXMFVAR kpsewhich -var-value=TEXMF 2>/dev/null | sed -e 's/!!//g')
TEXLIVE            := $(CURDIR)/.texlive
export TEXMFCONFIG := $(TEXLIVE)/config
export TEXMFVAR    := $(TEXLIVE)/var
export TEXMF       := {$(TEXMFCONFIG),$(TEXMFVAR),$(TEXLIVE)/texmf-local,$(DEFAULT_TEXMF)}
endif

.PHONY: all view clean distclean texlive

all: $(MAIN).pdf

# Rebuild the local format / font maps if the fallback state is incomplete.
texlive:
ifdef TEXLIVE
	@test -f "$(TEXMFVAR)/web2c/pdftex/pdflatex.fmt" || fmtutil-user --byfmt pdflatex
	@test -f "$(TEXMFVAR)/fonts/map/pdftex/updmap/pdftex.map" || updmap-user --force
endif

$(MAIN).pdf: $(MAIN).tex biblio.bib | texlive
	$(LATEXMK) $(LATEXMK_ARGS)

# Continuous rebuild + preview on file changes
view: | texlive
	$(LATEXMK) -pvc $(LATEXMK_ARGS)

# Remove auxiliary files, keep the PDF
clean:
	$(LATEXMK) -c $(MAIN).tex

# Remove auxiliary files and the PDF
distclean: clean
	$(LATEXMK) -C $(MAIN).tex
