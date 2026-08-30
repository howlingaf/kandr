# K&R: one program per .c file. `make` builds them all into bin/;
# `make run FILE=hello` builds and runs one.
CC     = gcc
CFLAGS = -Wall -Wextra -g -std=c17

SRC := $(wildcard *.c)
BIN := $(patsubst %.c,bin/%,$(SRC))

all: $(BIN)

bin/%: %.c | bin
	$(CC) $(CFLAGS) $< -o $@

bin:
	mkdir -p bin

# make run FILE=hello   ->   builds bin/hello and runs it
run: bin/$(FILE)
	@echo "--- ./$(FILE) ---"
	@./bin/$(FILE)

clean:
	rm -rf bin

.PHONY: all run clean
