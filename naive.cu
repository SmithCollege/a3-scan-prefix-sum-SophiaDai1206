#include <stdio.h>
#include <stdlib.h>
#include <chrono>  
#include <iostream>

#define SIZE 1024
__global__ void scanKernel(int* d_out, int* d_in) {
    __shared__ int temp[SIZE]; 

    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    temp[tid] = d_in[tid];
    __syncthreads();


    int value = 0;
    for (int i = 0; i <= tid; i++) {
        value += temp[i];
    }

    d_out[tid] = value;
}

int main() {
    int* h_input = (int*)malloc(sizeof(int) * SIZE);
    int* h_output = (int*)malloc(sizeof(int) * SIZE);
    int* d_input;
    int* d_output;

    
    for (int i = 0; i < SIZE; i++) {
        h_input[i] = 1;  
    }
    

   
    cudaMalloc((void**)&d_input, sizeof(int) * SIZE);
    cudaMalloc((void**)&d_output, sizeof(int) * SIZE);

 
    cudaMemcpy(d_input, h_input, sizeof(int) * SIZE, cudaMemcpyHostToDevice);

    auto start = std::chrono::high_resolution_clock::now();
    scanKernel<<<1, SIZE>>>(d_output, d_input);
    auto end = std::chrono::high_resolution_clock::now();
    cudaMemcpy(h_output, d_output, sizeof(int) * SIZE, cudaMemcpyDeviceToHost);
    
    std::chrono::duration<double> elapsed = end - start;
    printf("Scan result:\n");
    for (int i = 0; i < SIZE; i++) {
        printf("%d ", h_output[i]);
    }
    printf("\n");

    std::cout << "Time taken for naive GPU prefix sum: " << elapsed.count() << " seconds" << std::endl;
    cudaFree(d_input);
    cudaFree(d_output);


    free(h_input);
    free(h_output);

    return 0;
}
