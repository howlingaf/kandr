/* Exercise 2-5. Write the function any(s1,s2), which returns the first location in a string s1 where any character from the string s2 occurs, or -1 if s1 contains no characters from s2. (The standard library function strpbrk does the same job but returns a pointer to the location.)  */

#include <stdio.h>

int any_(char p[], char q[]);

int main(void) {
  char c_0[100] = "Hello World";
  char c_1[100] = "W";

  printf("%d",any_(c_0,c_1));
  return 0;
}

int any_(char p[], char q[]) {
  int i;
  char* qq;
  for (i = 0; *p != '\0'; p++,i++) {
    for (qq = q;*qq != '\0'; qq++) {
      if (*p == *qq) return i;
    }
  }
  return -1;
}
