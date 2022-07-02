#include <iostream>
#include <math.h>
#include <time.h>
#include <stdexcept>
#include "cuda_runtime.h"

/***Déclarations***/
int N=4096;//16777216 elements
int NombreThread = 8;//puissance de 2
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
    
    C[tid2*N+tid1]=0;

  //Ce calcule est une façon pour accéder à chaque bloc 
  //l'addition que doit établir chaque thread 
    for (int i = 0; i < N; ++i){
       C[tid2*N+tid1] += A[tid2*N+i]* B[N*i+tid1];
    }
  }


//Fonction pour remplir les vecteurs
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

//Allouer les Matrices du periphérique dans la mémoire (GPU)

    cudaMalloc(&A_perif, (N*N )*sizeof(int));
    cudaMalloc(&C_perif, (N*N )*sizeof(int));
    cudaMalloc(&B_perif, (N*N )*sizeof(int));

//Remplir les Matrices Host
    generateRandomMatrix(A_host, N , 1,99); 
    generateRandomMatrix(B_host, N , 1,99);

// Ici il faut copier les donnée des Matrices de la mémoire de la CPU à la mémoire GPU avec "cudaMemcpyHostToDevice"
    cudaMemcpy(A_perif, A_host, size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_perif, B_host, size, cudaMemcpyHostToDevice);
    cudaMemcpy(C_perif, C_host, size, cudaMemcpyHostToDevice);

//Faire l'addition dans le GPU avec la fonction definit comme kernel
   
       //bD correspond au nombre de threads par block.
      //gD correspond au nombre de block de threads dans une grille
     //Définir gD bD
      dim3 bD(NombreThread,NombreThread);

      int NombreBloc = (N +  NombreThread -1) / NombreThread;
      printf(" bloc ::: %d \n", NombreBloc);
      dim3 gD( NombreBloc,NombreBloc);

     //Appler kernel
      AdditionMatrice<<< gD ,bD>>>(A_perif,B_perif,C_perif, N);


/*copier le résultat obtenu en  C_perif ver C_host avec "cudaMemcpyDeviceToHost"*/
cudaMemcpy(C_host, C_perif, size, cudaMemcpyDeviceToHost);
for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      printf("\nMatrice C : %d",C_host[i*N+j]);

}
  printf("\n");
}

 printf(" \n bloc ::: %d \n", NombreBloc);
// libérer l'éspace allouer en GPU et CPU
  cudaFree(A_perif);
  cudaFree(B_perif);
  cudaFree(C_perif);

free(A_host);
free(B_host);
free(C_host);
//Attendre que le GPU termine
cudaDeviceSynchronize();
return 0;

}