/*Exercise 2-4. Write an alternative version of squeeze(s1,s2) that deletes each character in s1 that matches any character in the string s2.*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <stdbool.h>

void del(char arr[], char c);
void squeeze(char p[], char q[]);

int main() {
  char str_0[100] = "HelloWorld";
  char str_1[100] = "Wel";
  squeeze(str_0, str_1);
  return 0;
}

void del(char arr[], char c) {
  int i,j;
  for (i = j = 0 ;arr[i] != '\0';i++) {
    if (arr[i] != c) {
      arr[j++] = arr[i];
    }
  }
  arr[j] = '\0';
}

void squeeze(char p[], char q[]){
  for (;*q != '\0';q++) {
    char* pp = p;
    del(pp,*q);
  }
  printf("%s", p);
}
