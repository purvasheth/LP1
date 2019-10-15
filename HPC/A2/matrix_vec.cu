#include<bits/stdc++.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>
using namespace std;

#define N 2048


void initialise(int* v,int n){
  for(int i = 0;i<n;i++){
    v[i] = rand()%1000;
  }
}

__global__ void mat_vec_mult(int* mat,int*v,int* res,int n){
  int tid = threadIdx.x;
  res[tid] = 0;
  for(int i =0;i<n;i++){
    res[tid] = res[tid] + mat[ tid*n + i]*v[i];
  }
}


int main(){

  int *h_mat,*h_v,*h_r;
  int *d_mat,*d_v,*d_r;
  int *s_r;

  float elapsed_cpu, elapsed_gpu;
  clock_t t1, t2;

  h_mat =(int*)malloc(N*N*sizeof(int));
  h_v = (int*)malloc(N*sizeof(int));
  h_r = (int*)malloc(N*sizeof(int));
  s_r = (int*)malloc(N*sizeof(int));

  cudaMalloc(&d_mat,N*N*sizeof(int));
  cudaMalloc(&d_v,N*sizeof(int));
  cudaMalloc(&d_r,N*sizeof(int));

  initialise(h_mat,N*N);
  initialise(h_v,N);

  //serial
  t1 = clock();
  for(int i =0;i<N;i++){
    s_r[i]=0;
    for(int j=0;j<N;j++){
      s_r[i] = s_r[i] + h_mat[i*N + j]*h_v[j];
    }
  }
  t2 = clock();


  //parallel

  cudaEvent_t start, stop;

  cudaEventCreate(&start);

  cudaEventCreate(&stop);

  cudaEventRecord(start, 0);

  cudaMemcpy(d_mat,h_mat,N*N*sizeof(int),cudaMemcpyHostToDevice);
  cudaMemcpy(d_v,h_v,N*sizeof(int),cudaMemcpyHostToDevice);

  mat_vec_mult<<<1,N>>>(d_mat,d_v,d_r,N);

  cudaMemcpy(h_r,d_r,N*sizeof(int),cudaMemcpyDeviceToHost);


  cudaEventRecord(stop, 0);

  cudaEventSynchronize(stop);

  cudaEventElapsedTime(&elapsed_gpu, start, stop);

  cudaEventDestroy(start);

  cudaEventDestroy(stop);

  elapsed_cpu = ((float)t2 - (float)t1) / CLOCKS_PER_SEC * 1000;	//cpu elapsed time in ms

  cout<<elapsed_cpu<<endl;
  cout<<elapsed_gpu<<endl;
  cout<<"speedup "<<elapsed_cpu/elapsed_gpu<<endl;

  for(int i =0;i<N;i++){
    if(s_r[i]!=h_r[i]){
      cout<<"failed";
      break;
    }
  }






  return 0;
}
