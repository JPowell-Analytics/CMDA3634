#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#include "cuda.h"
#include "functions.c"

__device__ unsigned int modprodCuda(unsigned int a, unsigned int b, unsigned int p) {
  unsigned int za = a;
  unsigned int ab = 0;

  while (b > 0) {
    if (b%2 == 1) ab = (ab +  za) % p;
    za = (2 * za) % p;
    b /= 2;
  }
  return ab;
}

__device__ unsigned int modExpCuda(unsigned int a, unsigned int b, unsigned int p) {
  unsigned int z = a;
  unsigned int aExpb = 1;

  while (b > 0) {
    if (b%2 == 1) aExpb = modprodCuda(aExpb, z, p);
    z = modprodCuda(z, z, p);
    b /= 2;
  }
  return aExpb;
}

__global__ void kernalFindKey(int p, int g, int h, int device_array){
/*int nthreads = modExp(2,n,p);
int blockid = //No clue as to what this would be however need help;
int Nblock = nthreads/1024;*/

unsigned int d_x, threadId, blockId, Nblock;
threadId = threadIdx.x;
blockId = blockIdx.x;
Nblock = blockDim.x;
unsigned  int id = threadId + Nblock*blockId;
if (id < p-1){
	if (modExpCuda(g, id, p) == h)
    		device_array[0] = id;
}

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
  //unsigned int N = atoi(argv[1]);
  unsigned int n, p, g, h, x;
  unsigned int Nints;

  //get the secret key from the user
/*  printf("Enter the secret key (0 if unknown): "); fflush(stdout);
  char stat = scanf("%u",&x);
*/
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
  }
  fclose(message);

  unsigned int Nthreads = 32;
  unsigned int *device_array, *host_array;
  host_array = (unsigned int *) malloc(Nthreads*sizeof(unsigned int));
  dim3 in(Nthreads, 1, 1);
  dim3 out((p+Nthreads-1)/Nthreads, 1, 1);
  cudaMalloc(&device_array, Nthreads*sizeof(unsigned int)); 
  
  kernalFindKey<<<out, in>>> (p, g, h, device_array);
  cudaDeviceSynchronize();
  cudaMemCpy(host_array, device_array, Nthreads*sizeof(unsigned int), cudaMemcpyDeviceToHost);
  x = host_array;
  cudaFree(device_array);

  free(host_array);
  
  /* Q3 After finding the secret key, decrypt the message */
  
  
  int bufferSize = 1024;
  unsigned char *message2 = (unsigned char*) malloc(bufferSize*sizeof(unsigned char));
  unsigned int Nchars = ((n-1)/8) * Nints;

  ElGamalDecrypt(m_array, a_array, Nints, p, x);
  convertZToString(m_array, Nints, message2, Nchars);
  printf("Decrypted Message = \"%s\"\n", message2);
  return 0;
}
