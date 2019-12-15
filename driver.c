
#include <stdio.h>

extern double assign6();

int main()
{
  double answer = 0.0;
  printf("Welcome to fast number crunching by programmer Justin P \n");
  answer = assign6();
  printf("This main program has recieved this number %8.10lf. Have a nice day\n",answer);
  printf("Main will now return 0 to the operating system\n");
  return 0;
}
