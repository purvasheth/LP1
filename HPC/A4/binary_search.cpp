#include<iostream>
#include<mpi.h>
using namespace std;
#define N 2048
#define ll long long int



ll binarySearch(ll arr[], ll x , ll l, ll r)
{
	while(r >= l)
   	{
         	ll mid = (l + r)/2;

        	if(arr[mid] == x)
            		return mid;
        	if(arr[mid] < x)
			l = mid+1;
        	else
			r = mid-1;
   	}
 	return -1;
}


int main(int argc,char* argv[]){

  ll *arr;
  ll *localArray;
	ll *res;
	ll *index;
  ll key,num_elements;
  MPI_Init(&argc,&argv);
  int pid,num_proc,ierr,flag=0;
  double start,finish;
  MPI_Status status;

  MPI_Comm_rank(MPI_COMM_WORLD,&pid);
  MPI_Comm_size(MPI_COMM_WORLD,&num_proc);

  start = MPI_Wtime();
  if(pid==0){
    cout<<"no of process "<<num_proc<<endl;
    arr = new ll[N];
		res = new ll[num_proc];
		index = new ll[1];
    for(ll i=0;i<N;i++){
      arr[i]=i;
    }
    //cout<<"enter key"<<endl;
    key=100000;
    num_elements = N/num_proc;

    for(int i =1;i<num_proc;i++){
    localArray = new ll[num_elements];
    ierr=  MPI_Send(&key,1,MPI_LONG_LONG,i,0,MPI_COMM_WORLD);
    ierr=  MPI_Send(&num_elements,1,MPI_LONG_LONG,i,0,MPI_COMM_WORLD);
    }

  }
  else{
    ierr = MPI_Recv(&key,1,MPI_LONG_LONG,0,0,MPI_COMM_WORLD,&status);
    ierr = MPI_Recv(&num_elements,1,MPI_LONG_LONG,0,0,MPI_COMM_WORLD,&status);
    localArray = new ll[num_elements];
		index = new ll[1];
  }
  ierr = MPI_Scatter(arr,num_elements, MPI_LONG_LONG, localArray,num_elements, MPI_LONG_LONG,0, MPI_COMM_WORLD);
	//cout<<num_elements<<endl;

  *index = binarySearch(localArray,key,0,num_elements-1);

  MPI_Barrier(MPI_COMM_WORLD);

	ierr = MPI_Gather(index, 1 , MPI_LONG_LONG,res,1, MPI_LONG_LONG,0, MPI_COMM_WORLD);

	finish = MPI_Wtime();

  //ierr = MPI_Gather(localArray, num_elements, MPI_LONG_LONG, arr,num_elements, MPI_LONG_LONG,0, MPI_COMM_WORLD);
  if(*index!=-1){
		cout<<"Element found at "<<num_elements*pid + *index<<endl;
  }
	if(pid==0){
		bool flag = 0;
		for(int i =0;i<num_proc;i++){
			if(res[i]!=-1){
				flag = 1;
				break;
			}
		}
		if(flag==0){
			cout<<"element not found"<<endl;
		}
	}





  MPI_Finalize();
  return 0;
}

