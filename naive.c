#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

double get_clock() {
    struct timeval tv;
    int ok = gettimeofday(&tv, NULL);
    if (ok < 0) {
        printf("gettimeofday error\n");
        return -1.0; 
    }
    return (tv.tv_sec * 1.0 + tv.tv_usec * 1.0E-6);
}

#define SIZE 128
#define N 1000000
int main() {
    // Allocate memory
    int* input = malloc(sizeof(int) * SIZE);
    int* output = malloc(sizeof(int) * SIZE);

    // Initialize input array
    for (int i = 0; i < SIZE; i++) {
        input[i] = 1;  
    }
    
    double times[N];
    double t0 = get_clock();  // Start time before the loop

    for (int i = 0; i < N; i++) {
        times[i] = get_clock();
    }

    double t1 = get_clock();  // End time after the loop

    // Calculate the time per call to get_clock() in nanoseconds
    printf("Time per call to get_clock(): %f ns\n", (1000000000.0 * (t1 - t0) / N));

   
    double t_start = get_clock(); 


    for (int i = 0; i < SIZE; i++) {
        int value = 0;
        for (int j = 0; j <= i; j++) {
            value += input[j];
        }
        output[i] = value;
    }
    double t_end = get_clock();

    // Check and print results
    for (int i = 0; i < SIZE; i++) {
        printf("%d ", output[i]);
    }
    printf("\n");
    double time_taken = (t_end - t_start) ;
    printf("Time taken for prefix sum: %f seconds\n", time_taken);

    // Free allocated memory
    free(input);
    free(output);

    return 0;
}
