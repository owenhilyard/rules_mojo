#include <stdio.h>

extern void bar();

void foo() {
  bar();
  printf("Hello from foo!\n");
}
