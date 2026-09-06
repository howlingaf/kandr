/* Exercise 1-20. Write a program detab that replaces tabs in the input with the proper number of blanks to space to the next tab stop. Assume a fixed set of tab stops, say every n columns. Should n be a variable or a symbolic parameter? */

#include <stdio.h>
int main(void) {
  int c;
  int pos = 0;
  while ((c = getchar()) != EOF) {

    switch (c) {

        case '\t': {
          do {
            putchar(' ');
            pos++;
          } while (pos % 8 != 0);
          break;
        }
        case '\n':
          pos = 0;
          break;
        default:
            putchar(c);
            pos++;
      }
    }
  return 0;
}
