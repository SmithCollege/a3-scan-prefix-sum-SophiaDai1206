#include <cuda_runtime.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <chrono>  

__global__ void recursiveDoublingPrefixSum(int* input, int* output, int n) {
    extern __shared__ int temp[];  
    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    temp[threadIdx.x] = input[tid];

    __syncthreads();
    
    for (int offset = 1; offset < blockDim.x; offset *= 2) {
        int tempVal = 0;
        if (threadIdx.x >= offset) {
            tempVal = temp[threadIdx.x - offset];
        }
        __syncthreads();
        temp[threadIdx.x] += tempVal;
        __syncthreads();
    }

    // Store the result
    output[tid] = temp[threadIdx.x];
}

int main() {
    int SIZE = 10240;  // Example size
    int* h_input = (int*)malloc(sizeof(int) * SIZE);
    int* h_output = (int*)malloc(sizeof(int) * SIZE);
    int* d_input;
    int* d_output;

    for (int i = 0; i < SIZE; i++) {
        h_input[i] = 1;  
    }
   

    cudaMalloc((void**)&d_input, SIZE * sizeof(int));
    cudaMalloc((void**)&d_output, SIZE * sizeof(int));
    cudaMemcpy(d_input, h_input, SIZE * sizeof(int), cudaMemcpyHostToDevice);
    auto start = std::chrono::high_resolution_clock::now();
    recursiveDoublingPrefixSum<<<1, SIZE, SIZE * sizeof(int)>>>(d_input, d_output, SIZE);
   
    auto end = std::chrono::high_resolution_clock::now();
    cudaMemcpy(h_output, d_output, SIZE * sizeof(int), cudaMemcpyDeviceToHost);
    printf("%s\n", cudaGetErrorString(cudaGetLastError()));

    
    
    std::chrono::duration<double> elapsed = end - start;

    // printf("Prefix Sum Output:\n");
    // for (int i = 0; i < SIZE; i++) {
    //     printf("%d ", h_output[i]);
    // }
    // printf("\n");
    std::cout << "Time taken for naive GPU prefix sum: " << elapsed.count() << " seconds" << std::endl;
    cudaFree(d_input);
    cudaFree(d_output);
    return 0;
}
