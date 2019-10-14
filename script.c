
#include <stdio.h>
#include <stdlib.h>


// N = Numero de nodos a simular.
const int N = 125;

const int K_strength = 3;

//FUNCTION PROTOTYPE'S SECTION
int evaluateDegreeToCero(int[N][N]);

int main(){
    // p_conn: prbabilidad de conexión
    const float p_conn = 0.05;

    // Parámetro de inercia
    const float alpha = 0.1;

    // Inicializo la matriz de conectividad tamaño NxN
    int K[N][N]; 
    
    //Initialize with zeros
    for(int i = 0; i < N; i++){
        for (int j = 0; j < N; j++){
            K[i][j] = 0;
        }
    }

    int flag; //Variable that ressembles bool variables

    flag = 1;

    while(flag == 1){

        for(int i = 0; i < N; i++){
            for(int j = i+1; j < N; j++){
                // La matriz es simétrica
                float r = rand() % 101; //Comvertir en un rango de cero a 100
                float r2 = r/100;
                if(r2 < p_conn){
                    K[i][j] = 1;
                    K[j][i] = 1;
                }
            }
        }

        flag = evaluateDegreeToCero(K);
        printf("%d\n",flag);
    }

    flag = evaluateDegreeToCero(K);
        printf("%d\n",flag);
    return 0;
}

/*
Function that initializes the each item
*/
/*int **initializeFuction(int K[N][N], int n){
    for(int i = 0; i < N; i++){
        for (int j = 0; j < N; j++){
            K[i][j] = n;
        }
    }
    return K;
}*/

/*
Function that evals the node's degree on the matrix and returns 1 
*/
int evaluateDegreeToCero(int matrix[N][N]){
    int num = 0;
    for(int i = 0; i < N ; i++){
        int sum = 0;
        for (int j = 0; j < N; j++){
            
            sum = sum + matrix[i][j];
        }
        if (sum == 0){
            return 1;
        }
    }
    return 0;
}