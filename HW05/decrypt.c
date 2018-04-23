#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#include "functions.h"


int main (int argc, char **argv) {

  //declare storage for an ElGamal cryptosytem
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
  
   // find the secret key
  if (x==0 || modExp(g,x,p)!=h) {
    printf("Finding the secret key...\n");
    double startTime = clock();
    for (unsigned int i=0;i<p-1;i++) {   
      if (modExp(g,i+1,p)==h) {
        printf("Secret key found! x = %u \n", i+1);
        x=i+1; 
      } 
    }
    double endTime = clock();

    double totalTime = (endTime-startTime)/CLOCKS_PER_SEC;
    double work = (double) p;
    double throughput = work/totalTime;

    printf("Searching all keys took %g seconds, throughput was %g values tested per second.\n", totalTime, throughput);
  }
  /* Q3 After finding the secret key, decrypt the message */
  FILE* message = fopen("message.txt" , "r"); 
  unsigned int *m_array , *a_array;
  fscanf(message, "%u", &Nints);

  m_array = (unsigned int*) malloc(Nints*sizeof(unsigned int));
  a_array = (unsigned int*) malloc(Nints*sizeof(unsigned int));
    
  unsigned char *data_message = (unsigned char*) malloc(Nints*sizeof(unsigned char));
  
  for (unsigned int k = 0; k < Nints; k++)
  {
	fscanf(message, "%u %u", m_array+k, a_array+k);
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
