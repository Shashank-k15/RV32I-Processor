// sum.c — C example: computes the sum of an array

void _start(void) __attribute__((section(".text.init")));

volatile int *result_ptr = (volatile int *)0x4000;

void _start(void) {
  int data[] = {3, 1, 4, 1, 5, 9, 2, 6, 5, 3};
  int n = 10;
  int sum = 0;

  for (int i = 0; i < n; i++) {
    sum += data[i];
  }

  // sum should be 39
  *result_ptr = sum;

  while (1)
    ;
}
