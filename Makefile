.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

root := $(makefile_dir)

prefix ?= $(abspath $(root)/usr)

nproc := $(shell getconf _NPROCESSORS_ONLN)

bash_version := 5.2
bash_ver := $(subst .,,$(bash_version))

bash := bash-$(bash_version)
bash_archive := $(bash).tar.gz
bash_patches := [01-36]

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: clean
clean: ## remove files
	$(RM) -r $(root)/usr/bin/* $(root)/usr/include/* $(root)/usr/lib/* $(root)/usr/share/* $(root)/usr/src/*

.PHONY: install
install: CFLAGS := -DSSH_SOURCE_BASHRC
install: ## install Bash
	curl -o '$(root)/usr/src/$(bash_archive)' -fsSL 'https://ftp.gnu.org/gnu/bash/$(bash_archive)'
	curl -o '$(root)/usr/src/bash$(bash_ver)-0#1' -fsSL 'https://ftp.gnu.org/gnu/bash/bash-$(bash_version)-patches/bash$(bash_ver)-0$(bash_patches)'
	tar fx '$(root)/usr/src/$(bash_archive)' -C '$(root)/usr/src'
	mv '$(root)'/usr/src/bash$(bash_ver)-0?? '$(root)/usr/src/$(bash)'
	cd '$(root)/usr/src/$(bash)' && find . -type f -name 'bash$(bash_ver)-0??' -print0 | sort -nz | xargs -0 -n 1 -I % patch -p 0 -i %
	cd '$(root)/usr/src/$(bash)' && CFLAGS='$(CFLAGS)' ./configure --prefix='$(prefix)'
	cd '$(root)/usr/src/$(bash)' && CFLAGS='$(CFLAGS)' make -j$(nproc) install
	chmod -x $(root)/usr/lib/bash/*
