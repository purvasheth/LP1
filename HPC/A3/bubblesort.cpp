#include<omp.h>
#include<bits/stdc++.h>
using namespace std;

void odd_even(int* arr,int n){
  for(int i =0;i<n;i++){
    int first = i%2;
    for(int j = first;j<n;j=j+2){
      if(arr[j]>arr[j+1]){
        swap(arr[j],arr[j+1]);
      }
    }
  }
}


void parallel_odd_even(int* arr,int n){
  for(int i =0;i<n;i++){
    int first = i%2;
    #pragma omp parallel for
    for(int j = first;j<n;j=j+2){
      if(arr[j]>arr[j+1]){
        swap(arr[j],arr[j+1]);
      }
    }
  }
}
void initialise(int* v,int n){
  for(int i = 0;i<n;i++){
    v[i] = rand()%1000;
  }
}


int main(){
  int n = 1024;
  int *arr = (int*)malloc(n*sizeof(int));
  initialise(arr,n);
  int *arr1 = (int*)malloc(n*sizeof(int));
  copy(arr,arr+n,arr1);


  double start = omp_get_wtime();
  odd_even(arr,n);
  double end = omp_get_wtime();
  cout<<"serial time "<<(end-start)<<endl;

  start = omp_get_wtime();
  parallel_odd_even(arr1,n);
  end = omp_get_wtime();
  cout<<"parallel time "<<(end-start)<<endl;



  for(int i =0;i<n;i++){
    if(arr[i]!=arr1[i]){
      cout<<"wrong";
      break;
    }
  }


  return 0;
}
