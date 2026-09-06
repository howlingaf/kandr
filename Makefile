# K&R: one program per .c file, named <chapter>-<exercise>.c with no zero
# padding (1-1.c, 1-20.c, 5-4.c). `make` builds them all into bin/;
# `make run FILE=1-20` builds and runs one.
CC      = gcc
CFLAGS  = -Wall -Wextra -g -std=c89 -pedantic   # ANSI C, as in the book
# Seconds a program may run under `make run` before it is killed.
TIMEOUT = 5

SRC := $(wildcard *.c)
BIN := $(patsubst %.c,bin/%,$(SRC))

all: $(BIN)

bin/%: %.c | bin
	$(CC) $(CFLAGS) $< -o $@

bin:
	mkdir -p bin

# make run FILE=1-20  ->  build bin/1-20 and run it. If 1-20.in exists it is
# fed on stdin; otherwise stdin is /dev/null so a program that reads input
# sees EOF instead of hanging. An exercise stuck in a loop is killed after
# TIMEOUT seconds (exit 124) so the watcher keeps going. This is the one place
# "run an exercise" is defined: watcher.sh and the Emacs build hook both call it.
ifeq ($(FILE),)
run:
	@echo "usage: make run FILE=<stem>   e.g. make run FILE=1-20" >&2; exit 2
else
run: bin/$(FILE)
	@echo "--- ./$(FILE) ---"
	@in=/dev/null; [ -f $(FILE).in ] && in=$(FILE).in; \
	timeout $(TIMEOUT) ./bin/$(FILE) <$$in; rc=$$?; \
	if [ $$rc -eq 124 ]; then echo; echo "--- killed: still running after $(TIMEOUT)s ---" >&2; fi; \
	exit $$rc
endif

clean:
	rm -rf bin

.PHONY: all run clean
