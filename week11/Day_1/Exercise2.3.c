// Debugging 

#include <stdio.h>

int main (void)
{
     int x = 1; // assining a character to integer will still compile but will return garbage number when you print with %i
     char a = 'a';
     float point1 = 1.1;
     
     printf("An integer: %i\n", x);
     printf("A character: %c\n", a);
     printf("A floating point: %f\n", point1);
     
     return 0;
}