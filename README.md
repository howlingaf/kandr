Working through *The C Programming Language* (2nd edition) by Brian Kernighan
and Denise Richards.

Files are `<chapter>-<exercise>.c` with no zero padding (`1-1.c`, `1-20.c`,
`5-4.c`). An optional `<chapter>-<exercise>.in` is fed on stdin when the
program runs; without one stdin is empty.

```
make                 # build every program
make run FILE=1-20   # build and run bin/1-20 (1-20.in on stdin if present)
./watcher.sh         # rebuild on save, run the .c or .in you just saved
```
