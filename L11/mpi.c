#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "mpi.h"

int main(int argc, char **argv) {

MPI_Init(&argc, &argv);
  //need running tallies
	long long int Ntotal;
	long long int Ncircle;
	int rank, size;
	srand48(rank);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);
  //seed random number generator
  double seed = 1.0;
  srand48(seed);
//	printf("Rank %d recieved the value N = %d\n",rank, N);
 
 for (long long int n=0; n<1000000000;n++) {
    //gererate two random numbers
    double rand1 = drand48(); //drand48 returns a number between 0 and 1
    double rand2 = drand48();
    
    double x = -1 + 2*rand1; //shift to [-1,1]
    double y = -1 + 2*rand2;

    //check if its in the circle

    if (sqrt(x*x+y*y)<=1) Ncircle++;
    Ntotal++;

  double pi = 4.0*Ncircle/ (double) Ntotal;

  printf("Our estimate of pi is %f \n", pi);
 MPI_Allreduce(&Ncircle, &Ntotal, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
 float *gatheredVal;
 if(rank == 0 && size == 100) gatheredVal = (float*) malloc(size*sizeof(float));
}
	MPI_Finalize();
	return 0;
}
