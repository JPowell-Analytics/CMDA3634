#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#include "cuda.h"
#include "functions.c"

__global__ void kernalFindKey(int N, int n, int g, int h, int p){
/*int nthreads = modExp(2,n,p);
int blockid = //No clue as to what this would be however need help;
int Nblock = nthreads/1024;*/
if (modExp(g, blockIdx.x + 1, p) == h)
    d_x = blockIdx.x + 1;
//convert this to only 1 if statement.
/*if (x==0 || modExp(g,x,p)!=h) {
    printf("Finding the secret key...\n");
    double startTime = clock();
    for (unsigned int i=0;i<p-1;i++) {   
      if (modExp(g,i+1,p)==h) {
//        printf("Secret key found! x = %u \n", i+1);
        x=i+1; 
      } 
    }
    double endTime = clock();

    double totalTime = (endTime-startTime)/CLOCKS_PER_SEC;
    double work = (double) p;
    double throughput = work/totalTime;

    printf("Searching all keys took %g seconds, throughput was %g values tested per second.\n", totalTime, throughput);
*/
}

int main (int argc, char **argv) {

  /* Part 2. Start this program by first copying the contents of the main function from 
     your completed decrypt.c main function. */

  /* Q4 Make the search for the secret key parallel on the GPU using CUDA. */

//declare storage for an ElGamal cryptosytem
  unsigned int N = atoi(argv[1]);
  unsigned int n, p, g, h, x;
  unsigned int Nints;

  //get the secret key from the user
  printf("Enter the secret key (0 if unknown): "); fflush(stdout);
  char stat = scanf("%u",&x);

  printf("Reading file.\n");
  

  /* Q3 Complete this function. Read in the public key data from public_key.txt
    and the cyphertexts from messages.txt. */

  /* Q3 After finding the secret key, decrypt the message */
  FILE* Pkey = fopen("public_key.txt", "r");
  unsigned int *data_key = (unsigned int*) malloc(4*sizeof(unsigned int));
  for (unsigned int i = 0; i < 4; i++)
      fscanf(Pkey, "%u", data_key + i);
  fclose(Pkey);
  n = data_key[0];
  p = data_key[1];
  g = data_key[2];
  h = data_key[3];
  printf("%u, %u, %u, %u\n", n,p,g,h);
    // find the secret key
  
  //Idea is to make host storage so as to pass info to the device storage.
  unsigned int h_a, h_b, h_c;
  h_n = (unsigned int *) malloc(N*sizeof(unsigned int));
  h_g = (unsigned int *) malloc(N*sizeof(unsigned int));
  h_p = (unsigned int *) malloc(N*sizeof(unsigned int));  
  h_h = (unsigned int *) malloc(N*sizeof(unsigned int));


  size_t inputMem = 2* *sizeof(double);//missing a number
  size_t outMem = *sizeof(double);//missing a number  

  unsigned int d_n, d_g, d_h, d_p;
  cudaMalloc(&d_n, N*sizeof(unsigned int));
  cudaMalloc(&d_g, N*sizeof(unsigned int)); 
  cudaMalloc(&d_p, N*sizeof(unsigned int));
  cudaMalloc(&d_h, N*sizeof(unsigned int));

  cudaMemcpy(d_n, h_n, N*sizeof(unsigned int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_g, h_g, N*sizeof(unsigned int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_p, h_p, N*sizeof(unsigned int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_h, h_h, N*sizeof(unsigned int), cudaMemcpyHostToDevice);
 
  unsigned int Nthreads = modExp(2, N, p);
  unsigned int Nblocks = Nthreads/1024;
  unsigned int x;
  x = kernalFindKey<<<Nblocks, Nthreads>>> (N, d_n, d_g, d_p, d_h);
  cudaDeviceSynchronize();
  
  cudaFree(d_n);
  cudaFree(d_g);
  cudaFree(d_p);
  cudaFree(d_h);

  free(h_n);
  free(h_g);
  free(h_p);
  free(h_h);

  /* Q3 After finding the secret key, decrypt the message */
  FILE* message = fopen("message.txt" , "r"); 
  unsigned int *m_array , *a_array;
  fscanf(message, "%u", &Nints);
  printf("Nints is %u\n", Nints);
  m_array = (unsigned int*) malloc(Nints*sizeof(unsigned int));
  a_array = (unsigned int*) malloc(Nints*sizeof(unsigned int));
    
  // fscanf(message, "%u \n", &Nints);
  unsigned char *data_message = (unsigned char*) malloc(Nints*sizeof(unsigned char));
  
  printf("Nints is %u\n", Nints);
  for (unsigned int k = 0; k < Nints; k++)
  {
	fscanf(message, "%u %u", m_array+k, a_array+k);
        
        printf("%u is m\n", m_array[k]);
        printf("%u is a\n", a_array[k]);
  }
  fclose(message);  
  int bufferSize = 1024;
  unsigned char *message2 = (unsigned char*) malloc(bufferSize*sizeof(unsigned char));
  unsigned int Nchars = ((n-1)/8) * Nints;
  ElGamalDecrypt(m_array, a_array, Nints, p, x);
  convertZToString(m_array, Nints, message2, Nchars);
  printf("Decrypted Message = \"%s\"\n", message2);
  return 0;
}
