#include<bits/stdc++.h>
#include<device_launch_parameters.h>
#include<cuda_runtime.h>
using namespace std;

#define SIZE 256
#define SSIZE SIZE*4 // sizeof(int)

__global__ void sum_reduction(int *v,int *v_r){

  __shared__ int partial_sum[SSIZE];

  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  partial_sum[threadIdx.x] = v[tid];

  __syncthreads();

  for(int s = blockDim.x/2;s>0;s=s/2){
      if(threadIdx.x < s){
        partial_sum[threadIdx.x] += partial_sum[threadIdx.x+s];
      }
      __syncthreads();
  }
  if(threadIdx.x ==0){
    v_r[blockIdx.x] = partial_sum[0];
  }
}

__global__ void max_reduction(int *v,int *v_r){

  __shared__ int partial_sum[SSIZE];

  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  partial_sum[threadIdx.x] = v[tid];

  __syncthreads();

  for(int s = blockDim.x/2;s>0;s=s/2){
      if(threadIdx.x < s){
        partial_sum[threadIdx.x] = max(partial_sum[threadIdx.x],partial_sum[threadIdx.x+s]);
      }
      __syncthreads();
  }
  if(threadIdx.x ==0){
    v_r[blockIdx.x] = partial_sum[0];
  }
}

__global__ void variance(int *v,int *v_r,float *mean){

  __shared__ int partial_sum[SSIZE];

  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  partial_sum[threadIdx.x] = v[tid];

  __syncthreads();

  partial_sum[threadIdx.x] = (partial_sum[threadIdx.x] - *mean) * (partial_sum[threadIdx.x] - *mean);

  __syncthreads();

  for(int s = blockDim.x/2;s>0;s=s/2){
      if(threadIdx.x < s){
        partial_sum[threadIdx.x] += partial_sum[threadIdx.x+s];
      }
      __syncthreads();
  }
  if(threadIdx.x ==0){
    v_r[blockIdx.x] = partial_sum[0];
  }
}

__global__ void min_reduction(int *v,int *v_r){

  __shared__ int partial_sum[SSIZE];

  int tid = blockIdx.x * blockDim.x + threadIdx.x;

  partial_sum[threadIdx.x] = v[tid];

  __syncthreads();

  for(int s = blockDim.x/2;s>0;s=s/2){
      if(threadIdx.x < s){
        partial_sum[threadIdx.x] = min(partial_sum[threadIdx.x],partial_sum[threadIdx.x+s]);
      }
      __syncthreads();
  }
  if(threadIdx.x ==0){
    v_r[blockIdx.x] = partial_sum[0];
  }
}

void inititialise(int* v,int n){
  for(int i =0;i<n;i++){
    v[i]= rand()%1000;
  }
}


int main(){
  int n = SIZE*SIZE;

  float elapsed_cpu, elapsed_gpu;
  clock_t t1, t2;


  int thread_block_size = SIZE;
  int num_blocks = n / thread_block_size;


  int *h_v,*d_v,*h_v_r,*d_v_r;
  float *d_mean;
  h_v = (int*)malloc(n*sizeof(int));
  cudaMalloc(&d_v,n*sizeof(int));
  h_v_r = (int*)malloc(num_blocks*sizeof(int));
  cudaMalloc(&d_v_r,num_blocks*sizeof(int));
  cudaMalloc((void**)&d_mean,sizeof(float));

  inititialise(h_v,n);

  int minimum = 0;
  for(int i =0;i<n;i++){
    minimum = minimum+h_v[i];
  }
  //cout<<minimum<<endl;

 float mean = minimum / n;
int var = 0;
t1 = clock();
  for(int i =0;i<n;i++){
    var = var + (h_v[i]-mean)*(h_v[i]-mean);
  }
  cout<<var<<endl;
t2 = clock();
elapsed_cpu = ((float)t2 - (float)t1) / CLOCKS_PER_SEC * 1000;	//cpu elapsed time in ms



	cudaEvent_t start, stop;

	cudaEventCreate(&start);

	cudaEventCreate(&stop);

	cudaEventRecord(start, 0);

  cudaMemcpy(d_v,h_v,n*sizeof(int),cudaMemcpyHostToDevice);
  cudaMemcpy(d_mean,&mean,sizeof(float),cudaMemcpyHostToDevice);

  variance<<<num_blocks,thread_block_size>>>(d_v,d_v_r,d_mean);
  sum_reduction<<<1,thread_block_size>>>(d_v_r,d_v_r);

  cudaMemcpy(h_v_r,d_v_r,thread_block_size*sizeof(int),cudaMemcpyDeviceToHost);
  cout<<h_v_r[0]<<endl;

  cudaEventRecord(stop, 0);

  cudaEventSynchronize(stop);

  cudaEventElapsedTime(&elapsed_gpu, start, stop);

  cudaEventDestroy(start);

  cudaEventDestroy(stop);

  cout<<elapsed_cpu<<endl;
  cout<<elapsed_gpu<<endl;
  cout<<"speedup"<<elapsed_cpu/elapsed_gpu<<endl;

  return 0;
}
