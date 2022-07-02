#include <iostream>
#include <math.h>
#include <time.h>
#include <stdexcept>
#include "cuda_runtime.h"


/* 
- Le Kernel est la fonction qui s'exécuter sur le GPU.
- les variables hôte (CPU) ont le suffixe _host de celles de périphérique (GPU) ont  _perif.
*/
// kernel
__global__ void AdditionVector(const float* A, const float* B, float* C,int N){
// calculer l'id unique pour caque thread , il doit savoir qui il est 
  int tid = blockDim.x * blockIdx.x + threadIdx.x;
  //l'addition que doit établir chaque thread 
  if (tid < N) C[tid] = A[tid] + B[tid];
}



//Fonction pour remplir les vecteur
void generateRandomVector(float *v, int dim, int lowVl, int upVal) {
    int j;
   
        for (j = 0; j < dim; ++j) {

          //v[j]=5;
         v[j] = (rand() % (upVal - lowVl + 1)) + lowVl;
        
    }

}

/***Déclaration***/
int N = 131072 ;//doit etre une puissance de 2
int NombreThread = 128 ;//doit etre une puissance de 2
int NombreBloc = N/NombreThread ;
size_t size = N * sizeof(float);





int main() {

//Déclarer les vecteurs d'entrée dans la mémoire du periphérique (GPU)
float *A_perif,*B_perif,*C_perif;
// allouer des vecteurs du periphérique dans la mémoire (GPU)
  cudaMallocManaged(&A_perif, size);
  cudaMallocManaged(&C_perif, size);
  cudaMallocManaged(&B_perif, size);
//Déclarer et allouer les vecteurs d'entrée dans la mémoire de l'hôte (CPU)
 float* A_host = (float*)malloc(size);
 float* B_host = (float*)malloc(size);
 float* C_host = (float*)malloc(size);


//Remplir les vecteur Host
 generateRandomVector(A_host, N , 1, 99);	
 generateRandomVector(B_host, N , 1, 99);	

// Ici il faut copier les donnée des vecteur de la mémoire de la CPU à la mémoire GPU avec "cudaMemcpyHostToDevice"
  cudaMemcpy(A_perif, A_host, size, cudaMemcpyHostToDevice);
  cudaMemcpy(B_perif, B_host, size, cudaMemcpyHostToDevice);

 //Faire l'addition dans le GPU avec la fonction definit comme kernel



 //Appler kernel
AdditionVector<<<NombreBloc,NombreThread>>>(A_perif,B_perif,C_perif, N);




// copier le résultat obtenu en  C_perif ver C_host acev "cudaMemcpyDeviceToHost"
  cudaMemcpy(C_host, C_perif, size, cudaMemcpyDeviceToHost);

for (int i=0; i<N; i++) { 
printf("vector C : %f\n", C_host[i]);
    }

printf("NombreBloc : %d\n", NombreBloc);

  // libérer l'éspace allouer en GPU et CPU
  cudaFree(A_perif);
  cudaFree(B_perif);
  cudaFree(C_perif);






  free(A_host);
  free(B_host);
  free(C_host);


return cudaDeviceSynchronize();

}