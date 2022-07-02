#include <iostream>
#include <math.h>
#include <time.h>
#include <stdexcept>
#include "cuda_runtime.h"

/***Déclaration***/
int N=2048;
int NombreThread = 64;//doit etre une puissance de 2
size_t size = N* N * sizeof(int);


/* 
- Le Kernel est la fonction qui s'exécuter sur le GPU.
- les variables hôte (CPU) ont le suffixe _host de celles de périphérique (GPU) ont  _perif.
*/

// kernel
__global__ void AdditionMatrice(int *A, int *B, int *C,int N){

   //ICI on a une matrice de deux dimension chaque bloc aura deux ID donc, le tid1 et tid2
  //il faudra calculé le id pour chacque bloc
     int tid1 = blockIdx.x * blockDim.x + threadIdx.x;
     int tid2 = blockIdx.y * blockDim.y + threadIdx.y;
    
    //Ce calcule est une façon pour accéder à chaque bloc 
    int id=tid2*N+tid1;

    //l'addition que doit établir chaque thread 
    if (tid1 <N &&  tid2< N)
      C[id] = A[id]+ B[id];

}

//Fonction pour remplir les vecteur
 void generateRandomMatrix(int *M, int dim, int lowVal, int upVal) {
      for (int i = 0; i < dim; ++i) {
          for (int j = 0; j < dim; ++j) {
           M[i*dim+j] = (rand() % (upVal - lowVal + 1)) + lowVal;
      }}}


int main() {

//Déclarer les vecteurs d'entrée dans la mémoire du periphérique (GPU)
int *A_perif,*B_perif,*C_perif;


//Déclarer et allouer les matrice d'entrée dans la mémoire de l'hôte (CPU)
    int *A_host=(int*)malloc(sizeof(int) * (N*N));
    int *B_host=(int*)malloc(sizeof(int) * (N*N));
    int *C_host=(int*)malloc(sizeof(int) * (N*N));


//Allouer des vecteurs du periphérique dans la mémoire (GPU)
  cudaMalloc(&A_perif, (N*N )*sizeof(int));
  cudaMalloc(&C_perif, (N*N )*sizeof(int));
  cudaMalloc(&B_perif, (N*N )*sizeof(int));


//Remplir les vecteur Host
 generateRandomMatrix(A_host, N , 1,50); 
 generateRandomMatrix(B_host, N , 1,20);

//Ici il faut copier les donnée des Matrice de la mémoire de la CPU à la mémoire GPU avec "cudaMemcpyHostToDevice"
  cudaMemcpy(A_perif, A_host, size, cudaMemcpyHostToDevice);
  cudaMemcpy(B_perif, B_host, size, cudaMemcpyHostToDevice);
  cudaMemcpy(C_perif, C_host, size, cudaMemcpyHostToDevice);

 //Faire l'addition dans le GPU avec la fonction definit comme kernel


//Définir les paramètre du kernel 
dim3 bD(NombreThread,NombreThread);
int NombreBloc = (N +  NombreThread -1) / NombreThread;
dim3 gD( NombreBloc,NombreBloc);

//Appler kernel
AdditionMatrice<<< gD ,bD>>>(A_perif,B_perif,C_perif, N);


//copier le résultat obtenu en  C_perif ver C_host avec "cudaMemcpyDeviceToHost"
  cudaMemcpy(C_host, C_perif, size, cudaMemcpyDeviceToHost);

  
//Afficher le résultat de l'addition
for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      printf("Matrice C : %d",C_host[i*N+j]);}
       printf("\n");}
//Afficher Nombre Bloc
printf(" \n bloc ::: %d \n", NombreBloc);

// libérer l'éspace allouer en GPU et CPU
  cudaFree(A_perif);
  cudaFree(B_perif);
  cudaFree(C_perif);

  free(A_host);
  free(B_host);
  free(C_host);


return cudaDeviceSynchronize();

}