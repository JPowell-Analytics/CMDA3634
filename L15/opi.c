#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include<omp.h>
int main(int argc, char **argv) {

int i;
char buffer[256];
i = atoi(argv[1]);
  //seed random number generator
  // Q2b: get the number of threads to run with from agrv and 
  // add OpenMP API code to set number of threads here
  int Nthreads = i;
  omp_set_num_threads(Nthreads); 
  struct drand48_data *drandData; 
  drandData = (struct drand48_data*) malloc(Nthreads*sizeof(struct drand48_data));

  // Q2c: add an OpenMP parallel region here, wherein each thread initializes 
  //      one entry in drandData using srand48_r and seed based on thread number
  long int seed = 0;
#pragma omp parallel
{
  srand48_r(seed, drandData+0);
}
  long long int Ntrials = 100000;


  //need running tallies
  long long int Ntotal=0;
  long long int Ncircle=0;
  double start = omp_get_wtime();

#pragma omp parallel for 
  for (long long int n=0; n<Ntrials; n++) {
    double rand1;
    double rand2;
    
    //gererate two random numbers (use the thread id to offset drandData)
    drand48_r(drandData+0, &rand1);
    drand48_r(drandData+0, &rand2);
    
    double x = -1 + 2*rand1; //shift to [-1,1]
    double y = -1 + 2*rand2;

    //check if its in the circle
    if (sqrt(x*x+y*y)<=1) Ncircle++;
    Ntotal++;
    
    if (n%100 ==0) {
      double pi = 4.0*Ncircle/ (double) (n);
      printf("Our estimate of pi is %g \n", pi);
    }



}
 

  double pi = 4.0*Ncircle/ (double) (Ntotal);
  printf("Our final estimate of pi is %g \n", pi);
  printf("Final time is \t %f \n",omp_get_wtime()- start);
  free(drandData);
  
  return 0;
}
