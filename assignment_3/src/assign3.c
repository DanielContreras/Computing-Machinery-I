#define  SIZE 50

int main()
{
  int v[SIZE], i, j, temp;

  /*  Initialize array to random positive integers, mod 256  */
  for (i = 0; i < SIZE; i++) {
    v[i] = rand() & 0xFF;
    printf("v[%d]: %d\n", i, v[i]);
  }

  /*  Sort the array using an insertion sort  */
  for (i = 1; i < SIZE; i++) {
    temp = v[i];
    for (j = i; j > 0 && temp < v[j-1]; j--) {
      v[j] = v[j-1];
    }
    v[j] = temp;
  }

  /*  Print out the sorted array  */
  printf("\nSorted array:\n");
  for (i = 0; i < SIZE; i++)
    printf("v[%d]: %d\n", i, v[i]);

  return 0;
}