#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int main (){
  int i =3;
  char* hi ="hi";
  char * str = malloc(strlen(hi)+1);
  strcpy(str,hi);
  printf("\nstring memory is:: %p", &i);
  fflush(stdout);
 
  printf("\nstack memory is:: %p", &hi);
  fflush(stdout);
  printf("\nstring memory is:: %p", str);
  fflush(stdout);
  printf("\nstack memory is:: %p", hi);
  fflush(stdout);
  printf("\n");
  return 0;

}
