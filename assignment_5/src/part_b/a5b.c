#include <stdio.h>
#include <stdlib.h>

#define FALSE   0
#define TRUE    1

int isDateValid(int mm, int dd);
int getSeason(int mm, int dd);
int getSuffix(int day);

char *month[] = {"January", "February", "March", "April", "May",
                 "June", "July", "August", "September", "October",
                 "November", "December"};
char *season[] = {“Winter”, “Spring”, “Summer”, “Fall”};
char *suffix[] = {"st", "th", "rd", "th"};


int main(int argc, char *argv[])
{
    int register mm, dd, season_i, suffix_i;

    if (argc != 3)
    {
        printf("usage: a5b mm dd\n");
        return 0;
    }

    mm = atoi(argv[1]);
    dd = atoi(argv[2]);

    if (isDateValid == FALSE)
    {
        printf("Error: dd and mm given must be valid\n")
        return 0;
    }
    else 
    {
        season_i = getSeason(mm, dd);
        suffix_i = getSuffix(day);
        printf("%s %d%s is %s\n", month[mm], dd, suffix[suffix_i], season[season_i]);
    }

    return 0;
}

int isDateValid(int mm, int dd)
{
    int result = FALSE;

    return result;
}

int getSeason(int mm, int dd)
{
    int result, index;

    return result;
}

int getSuffix(int day)
{
    if ( (dd > 3 && dd < 21) || (dd > 23 && dd < 31)) 
        return 1;
    else if (dd == 1 || dd == 21 || dd == 31) 
        return 0;
    else if (dd == 2 || dd == 22) 
        return 2;
    else 
        return 3;
}