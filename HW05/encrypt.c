#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#include "functions.h"

int main (int argc, char **argv) {

	//seed value for the randomizer 
  double seed = clock(); //this will make your program run differently everytime
  //double seed = 0; //uncomment this and your program will behave the same everytime it's run

  srand(seed);

  int bufferSize = 1024;
  unsigned char *message = (unsigned char *) malloc(bufferSize*sizeof(unsigned char));

  printf("Enter a message to encrypt: ");
  int stat = scanf (" %[^\n]%*c", message); //reads in a full line from terminal, including spaces

  //declare storage for an ElGamal cryptosytem
  unsigned int n, p, g, h;

  printf("Reading file.\n");

  /* Q2 Complete this function. Read in the public key data from public_key.txt,
    convert the string to elements of Z_p, encrypt them, and write the cyphertexts to 
    message.txt */
  
  //fscanf("%u\n %u\n %u\n %u\n ", n, p, g, h);
  FILE* file = fopen("message.txt", "r");
  unsigned int *data = (unsigned int *) malloc(4*sizeof(unsigned int));
  
  FILE *Fop = fopen("public_key.txt", "r");
  for (unsigned int i = 0; i < 4; i++)
  	fscanf(Fop, "%d", data + i);
  fclose(Fop);
  
  n = data[0];
  p = data[1];
  g = data[2];
  h = data[3];

  unsigned int CPI = (n-1)/8; //CharsPerInt == CPI
  padString(message, CPI);
  
  unsigned int Nchars = strlen(message);
  unsigned int Nints = strlen(message)/CPI;

  unsigned int *a1 = (unsigned int*) malloc(Nints*sizeof(unsigned int));
  unsigned int *Zmessage = (unsigned int*) malloc(Nints*sizeof(unsigned int));
  convertStringToZ(message, Nchars, Zmessage, Nints);

  ElGamalEncrypt(Zmessage, a1, Nints, p, g, h);
  
  FILE *fileOut = fopen("message.txt", "w");
  fprintf(fileOut, "%u \n", Nints);
  for (unsigned int m = 0; m < Nints; m++)
  	fprintf(fileOut, "%u %u \n", Zmessage[m], a1[m]);
  fclose(fileOut);
  free(data);  
  return 0;
}
