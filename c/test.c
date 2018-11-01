#include <stdio.h>

// foo bar

struct s {
  int n0;
  int n1;
};

int main (int argc, char * * argv) {
    printf("d: %p", & (((struct s *) 0)->n1));
    return (0);
}

// test0
