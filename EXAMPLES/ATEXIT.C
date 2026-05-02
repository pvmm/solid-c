#include <stdio.h>

void func1();
void func2();

void main()
{
      atexit(func1);		// "Exit Function 1 called"
      atexit(func2);		// "Exit Function 2 called"
      printf("\tMain quitting ...\n");

/*
 *  Выведется:
 *       Main quitting ...
 *       Exit Function 2 called ...
 *       Exit Function 1 called ...
 */
}

void func1()
{
    printf("\tExit Function 1 called ...\n");
}

void func2()
{
    printf("\tExit Function 2 called ...\n");
}
