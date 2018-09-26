/**
 * Daniel Contreras
 * 10080311
 */

#include <stdio.h>

int main()
{
    long int maximum = -500000;
    long int x = -6;
    long int currentMaximum = -500000;


    while (x <= 5)
    {
        currentMaximum = (-5 * x * x * x) - (31 * x * x) + (4 * x) + 31;
        if (currentMaximum > maximum)
        {
            maximum = currentMaximum;
        }
        printf("Current values:\n\tx: %d\n\ty: %d\n\tCurrent Maximum: %d\n\n", x, currentMaximum, maximum);
        x++;
    }
    return 0;
}
