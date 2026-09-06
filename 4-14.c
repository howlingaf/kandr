#include <stdio.h>

#define swap(T, x, y)      \
  {                        \
  T t = x;                 \
  x = y;                   \
  y = t;                   \
  }

int main(void) {
  int X = 420;
  int Y = 69;
  printf("%d %d\n", X, Y);
  swap(int, X, Y)
  printf("%d %d\n", X, Y);
  return 0;
}
