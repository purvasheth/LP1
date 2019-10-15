#include <bits/stdc++.h>
#include <stdlib.h>
#include <mpi.h>
using namespace std;

//create a vector of pointers which each point to a root of binary tree.
#define N 1023

void dfs(int arr[],int n){
  vector<bool> visited(n,0);
  int *GlobalTree;
  int l = 1;
  stack<int> s;
  s.push(0);
  visited[0]=1;
  l1:
  while(l<n-1){
    s.push(l);
    visited[l]=1;
    l = 2*l + 1;
  }
  while(!s.empty()){
    int curr = s.top();
    s.pop();
//    cout<<arr[curr]<<" ";
    l = 2*curr + 1;
    int r = l+1;
    if(r<n){
      s.push(r);
      visited[r]=1;
    }
    if(l < n-1 && visited[l]==0){
      goto l1;
    }
  }
}

int main(int argc, char* argv[])
{
  vector<int*> root(4);
  int *GlobalTree;
  MPI_Init(&argc,&argv);
  double start,end;
  int pid,num_proc,ierr;
  int *LocalTree;
  MPI_Comm_rank(MPI_COMM_WORLD, &pid);
  MPI_Comm_size(MPI_COMM_WORLD, &num_proc);
  LocalTree = new int[N];
  for(int i =0;i<N;i++){
    //LocalTree[i] = rand()%1000;
    LocalTree[i] = i;
  }
  start = MPI_Wtime();
  root[pid] = LocalTree;
  dfs(LocalTree,N);
  MPI_Barrier(MPI_COMM_WORLD);
  end = MPI_Wtime();

  //gather local array in 1 Array and perform dfs on it using pid = 0;
  if(pid==0){
    cout<<"time for parallel "<<end-start<<endl;
    GlobalTree = new int[N*num_proc];
  }
  ierr = MPI_Gather(LocalTree, N, MPI_INT, GlobalTree, N, MPI_INT, 0, MPI_COMM_WORLD);

  if(pid==0){
    start = MPI_Wtime();
    for(int i =0;i<num_proc;i++){
      dfs(GlobalTree + pid*N ,N);
    }
  end = MPI_Wtime();
cout<<"time for serial "<<end-start<<endl;
}




  MPI_Finalize();
  return 0;
}
