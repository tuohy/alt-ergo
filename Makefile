# ====================================
# Variable Definitions & Configuration
# ====================================

NAME=alt-ergo
SRC_DIR := src

BIN_DIR := $(SRC_DIR)/bin
LIB_DIR := $(SRC_DIR)/lib
PLUGINS_DIR := $(SRC_DIR)/plugins
PARSERS_DIR := $(SRC_DIR)/parsers

COMMON_DIR := $(BIN_DIR)/common
BTEXT_DIR := $(BIN_DIR)/text
BJS_DIR := $(BIN_DIR)/js

UTIL_DIR := $(LIB_DIR)/util
FTND_DIR := $(LIB_DIR)/frontend
RSNRS_DIR := $(LIB_DIR)/reasoners
STRCT_DIR := $(LIB_DIR)/structures

RSC_DIR := rsc
EXTRA_DIR := $(RSC_DIR)/extra
SPHINX_DOC_DIR   := docs/sphinx_docs

BUILD_DIR := _build
INSTALL_DIR := $(BUILD_DIR)/install
DEFAULT_DIR := $(BUILD_DIR)/default
SPHINX_BUILD_DIR := $(BUILD_DIR)/sphinx_docs

# Some variables to help with adding
# flags and/or renaming the dune binary
DUNE=dune
DUNE_FLAGS?=

# Definining the sphinx build command
SPHINXBUILD = sphinx-build

# List the files:
# - generated by rules in this makefile,
# - used by the build process
#
# This excludes:
# - .ml files generated by menhir or ocamllex
#   (since they reside in dune specific directory)
GENERATED_LINKS=alt-ergo alt-ergo.js alt-ergo-worker.js AB-Why3-plugin.cma AB-Why3-plugin.cmxs fm-simplex-plugin.cma fm-simplex-plugin.cmxs
GENERATED=$(GENERATED_LINKS)


# =======
# Aliases
# =======

# IMPORTANT: this is the first rules, and as such the default
# run when "make" is called, keep it as the first rule
world: all

# Alias for generated artifacts
clean: generated-clean dune-clean ocamldot-clean

# Alias to remove all generated files
distclean: makefile-distclean release-distclean

# declare these aliases as phony
.PHONY: world conf clean distclean alt-ergo-lib \
	alt-ergo-parsers alt-ergo

# =================
# Build rules (dev)
# =================

lib:
	$(DUNE) build $(DUNE_FLAGS) @$(LIB_DIR)/all

bin:
	$(DUNE) build $(DUNE_FLAGS) @$(BTEXT_DIR)/all
	ln -sf src/bin/text/Main_text.exe alt-ergo

parsers:
	$(DUNE) build $(DUNE_FLAGS) @$(PARSERS_DIR)/all

fm-simplex:
	$(DUNE) build $(DUNE_FLAGS) @$(PLUGINS_DIR)/fm-simplex/all
	$(DUNE) build $(DUNE_FLAGS) @install

AB-Why3:
	$(DUNE) build $(DUNE_FLAGS) @$(PLUGINS_DIR)/AB-Why3/all
	$(DUNE) build $(DUNE_FLAGS) alt-ergo-plugin-ab-why3.install

plugins:
	$(DUNE) build $(DUNE_FLAGS) @$(PLUGINS_DIR)/all

# Alias to build all targets using dune
# Hopefully more efficient than making "all" depend
# on "lib" and "bin", since dune can
# parralelize more
all:
	$(DUNE) build $(DUNE_FLAGS) @$(LIB_DIR)/all @$(BTEXT_DIR)/all \
		@$(PARSERS_DIR)/all @$(BJS_DIR)/all @$(PLUGINS_DIR)/all

# declare these targets as phony to avoid name clashes with existing directories,
# particularly the "plugins" target
.PHONY: lib bin fm-simplex AB-Why3 plugins all

# =====================
# Build rules (release)
# =====================

packages:
	$(DUNE) build $(DUNE_FLAGS) --release

.PHONY: packages

# ==============
# Generate tests
# ==============

# Generate new Dune tests from the problems in
# the directory tests/.
gentest: $(wildcard tests/**/*)
	dune exec -- tools/gentest.exe tests/

# Run non-regression tests.
runtest: gentest bin
	dune build @runtest @runtest-quick

# Run non-regression tests for the CI.
runtest-ci: gentest bin
	dune build @runtest @runtest-quick @runtest-ci

# Promote new outputs of the tests.
promote:
	dune promote

.PHONY: gentest runtest runtest-ci promote

# ============
# Installation
# ============

# Installation using dune is *NOT* recommended
# The good way to install alt-ergo is to use the alt-ergo.install
# file generated by dune, which specifies all files that need to
# be copied, and where they should be copied

install: packages
	$(DUNE) install --release

uninstall: packages
	$(DUNE) uninstall

.PHONY: install uninstall

# ========================
# Documentation generation
# ========================

# Build the documentations
doc: odoc sphinx-doc

# Build the sphinx documentation
sphinx-doc:
	# cp LICENSE.md $(SPHINX_DOC_DIR)/About/license.md
	# cp -r licenses $(SPHINX_DOC_DIR)/About
	$(SPHINXBUILD) "$(SPHINX_DOC_DIR)" "$(SPHINX_BUILD_DIR)"

# Build the odoc
odoc:
	$(DUNE) build $(DUNE_FLAGS) @doc

# Open the html doc generated by sphinx and odoc in browser
html: doc
	mkdir -p $(SPHINX_BUILD_DIR)/odoc/dev
	cp -r $(DEFAULT_DIR)/_doc/_html/* $(SPHINX_BUILD_DIR)/odoc/dev
	xdg-open $(SPHINX_BUILD_DIR)/index.html

.PHONY: doc sphinx-doc odoc html

# ======================
# Javascript generation
# ======================

# Build the text alt-ergo bin in Js with js_of_ocaml-compiler
# zarith_stubs_js package is needed for this rule
# note that --timeout option is ignored due to the lack of js primitives
# and the use of input zip file is also unavailable
js-node:
	$(DUNE) build $(DUNE_FLAGS) --profile=release $(BJS_DIR)/main_text_js.bc.js
	ln -sf $(DEFAULT_DIR)/$(BJS_DIR)/main_text_js.bc.js alt-ergo.js

# Build a web worker for alt-ergo
# zarith_stubs_js, data-encoding, js_of_ocaml and js_of_ocaml-lwt packages are needed for this rule
js-worker:
	$(DUNE) build $(DUNE_FLAGS) --profile=release $(BJS_DIR)/worker_js.bc.js
	ln -sf $(DEFAULT_DIR)/$(BJS_DIR)/worker_js.bc.js alt-ergo-worker.js \

# Build a small web example using the alt-ergo web worker
# This example is available in the www/ directory
# zarith_stubs_js, data-encoding, js_of_ocaml and js_of_ocaml-lwt js_of_ocaml-ppx lwt_ppx packages are needed for this rule
js-example: js-worker
	$(DUNE) build $(DUNE_FLAGS) --profile=release $(BJS_DIR)/worker_example.bc.js
	mkdir -p www
	cp $(EXTRA_DIR)/worker_example.html www/index.html
	cd www \
	&& ln -sf ../$(DEFAULT_DIR)/$(BJS_DIR)/worker_js.bc.js alt-ergo-worker.js \
	&& ln -sf ../$(DEFAULT_DIR)/$(BJS_DIR)/worker_example.bc.js alt-ergo-main.js

.PHONY: js-node js-worker js-example

# ================
# Dependency graph
# ================

$(EXTRA_DIR)/ocamldot/ocamldot:
	cd $(EXTRA_DIR)/ocamldot/ && $(MAKE) bin

# plot the dependency graph
# specifying all dependencies is really, really bothersome,
# so we just put the ocamldot executable as dep
archi: $(EXTRA_DIR)/ocamldot/ocamldot
	ocamldep \
		-I $(BIN_DIR)/ -I $(LIB_DIR)/ -I $(COMMON_DIR)/ -I $(PARSERS_DIR)/ \
		-I $(PLUGINS_DIR)/ -I $(BTEXT_DIR)/ \
		-I $(FTND_DIR)/ -I $(RSNRS_DIR)/ -I $(STRCT_DIR)/ -I $(UTIL_DIR)/ \
		-I $(DEFAULT_DIR)/$(COMMON_DIR)/ \
		-I $(DEFAULT_DIR)/$(PARSERS_DIR)/ -I $(DEFAULT_DIR)/$(PLUGINS_DIR)/ \
		$(FTND_DIR)/*.ml $(RSNRS_DIR)/*.ml $(STRCT_DIR)/*.ml $(UTIL_DIR)/*.ml \
		$(COMMON_DIR)/*.ml $(DEFAULT_DIR)/$(COMMON_DIR)/*.ml \
		$(PARSERS_DIR)/*.ml $(DEFAULT_DIR)/$(PARSERS_DIR)/*.ml \
		$(PLUGINS_DIR)/*/*.ml $(DEFAULT_DIR)/$(PLUGINS_DIR)/*/*.ml \
		$(BTEXT_DIR)/*.ml | \
		$(EXTRA_DIR)/ocamldot/ocamldot | grep -v "}" > archi.dot
	cat $(EXTRA_DIR)/subgraphs.dot >> archi.dot
	echo "}" >> archi.dot
	dot -Tpdf archi.dot > archi.pdf

lock:
	dune build ./alt-ergo-lib.opam
	opam lock ./alt-ergo-lib.opam -w
	# Remove OCaml compiler constraints
	sed -i '/"ocaml"\|"ocaml-base-compiler"\|"ocaml-system"\|"ocaml-config"/d' ./alt-ergo-lib.opam.locked

dev-switch:
	opam switch create -y . --deps-only --ignore-constraints-on alt-ergo-lib,alt-ergo-parsers

js-deps:
	opam pin add js_of_ocaml 5.0.1
	opam install js_of_ocaml-lwt js_of_ocaml-ppx data-encoding zarith_stubs_js lwt_ppx -y

deps:
	opam install -y . --locked --deps-only

test-deps:
	opam install -y . --locked --deps-only --with-test

dune-deps:
	dune-deps . | dot -Tpng -o docs/deps.png

.PHONY: archi deps test-deps dune-deps dev-switch lock

# ===============
# PUBLIC RELEASES
# ===============

# Get the current commit hash and version number
VCS_COMMIT_ID = $(shell git rev-parse HEAD)
# Use the same command as dune subst
VERSION=$(shell git describe --always --dirty --abbrev=7)
# vX.Y.Z -> X.Y.Z
VERSION_NUM=$(VERSION:v%=%)

# Some convenient variables
PUBLIC_RELEASE=alt-ergo-$(VERSION_NUM)
PUBLIC_TARGZ=$(PUBLIC_RELEASE).tar.gz
FILES_DEST=public-release/$(PUBLIC_RELEASE)

--prepare-release:
	git clean -dfxi
	mkdir -p $(FILES_DEST)
	cp --parents -r \
	docs \
	examples \
	licenses/Apache-License-2.0.txt \
	licenses/OCamlPro-Non-Commercial-License.pdf \
	licenses/OCamlPro-Non-Commercial-License.txt \
	licenses/LGPL-License.txt \
	non-regression \
	rsc \
	src \
	tests \
	alt-ergo.opam \
	alt-ergo-lib.opam \
	alt-ergo-parsers.opam \
	dune-project \
	Makefile \
	README.md \
	LICENSE.md \
	CHANGES.md \
	$(FILES_DEST)
	sed -i "s/%%VERSION_NUM%%/$(VERSION_NUM)/" $(FILES_DEST)/$(UTIL_DIR)/version.ml
	sed -i "s/%%VCS_COMMIT_ID%%/$(VCS_COMMIT_ID)/" $(FILES_DEST)/$(UTIL_DIR)/version.ml
	sed -i "s/%%BUILD_DATE%%/`LANG=en_US; date`/" $(FILES_DEST)/$(UTIL_DIR)/version.ml

public-release: --prepare-release
	cd public-release && tar cfz $(PUBLIC_TARGZ) $(PUBLIC_RELEASE)
	rm -rf $(FILES_DEST)

free-public-release: --prepare-release
	cp licenses/CeCILL-C-License-v1.txt $(FILES_DEST)
	find src/lib src/bin src/parsers -iname "*.ml*" -exec headache -h licenses/free-header.txt {} \;
	cd public-release && tar cfz $(PUBLIC_TARGZ) $(PUBLIC_RELEASE)
	git restore $(SRC_DIR)
	rm -rf $(FILES_DEST)

# ==============
# Cleaning rules
# ==============

# Cleanup generated files
generated-clean:
	rm -rf $(GENERATED)

# Clean build artifacts
dune-clean:
	$(DUNE) clean

# Clean js example files
js-clean:
	rm -rf www

# Clean ocamldot's build artifacts
ocamldot-clean:
	cd $(EXTRA_DIR)/ocamldot && $(MAKE) clean

# Cleanup all makefile-related files
makefile-distclean: generated-clean

# Clenaup release generated files and dirs
release-distclean:
	rm -rf public-release

.PHONY: generated-clean dune-clean js-clean makefile-distclean release-distclean

emacs-edit:
	emacs `find . -name '*'.ml* | grep -v _build | grep -v _opam` &

modules-dep-graph dep-graph:
	rsc/extra/gen-modules-dep-graph.sh
