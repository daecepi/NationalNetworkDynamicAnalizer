
#include <stdio.h>
#include <stdlib.h>


// N = Numero de nodos a simular.
const int N = 125;

const int K_strength = 3;

//FUNCTION PROTOTYPE'S SECTION
double evaluateDegreeToCero(double[N][N]);
double sumVector(double[N]);
int main(){
    double defaultWhite[N][N];
    double K[N][N]; // matriz de conectividad
    double degMat[N][N];

    //Initialize with zeros
    for(int i = 0; i < N; i++){
        for (int j = 0; j < N; j++){
            defaultWhite[i][j] = 0;
            K[i][j] = 0;
            degMat[i][j] = 0;
        }
    }

    // p_conn: prbabilidad de conexión
    const float p_conn = 0.05;

    // Parámetro de inercia
    const float alpha = 0.1;

    // Inicializo la matriz de conectividad tamaño NxN and initialize with zeros

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

        flag = evaluateDegreeToCero(K); // corrigiendo la flag que terminará el loop
    }

    flag = evaluateDegreeToCero(K);
    printf("%d\n",flag);

    //Este es el vector de "Potencias" generadas y consumidas por la red
    double P[N];

    //Initializing vector to zero
    for (int i = 0; i < 5; i++){
        P[i] = 10;
    }
    for (int i = 5; i < 25; i++){
        P[i] = 2.5;
    }
    for (int i = 25; i < N; i++){
        P[i] = -1;
    }
    

    //La suma de P's debe ser igual a 0!
    printf("\nThe sum must be cero and is: %f", sumVector(P));

    double A[N][N];

    for (int i = 0; i < N; i++){
        for (int j = 0; j < N; j++){
            A[i][j] = K[i][j]*K_strength;
        }
    }
    
    // DE AQUI EN ADELANTE SON CÁLCULOS NECESARIOS
    // PARA EL PUNTO DE EQUILIBRIO

    // 1. Defino el Laplaciano, para ello calculo primero el grado de cada nodo
    // incluyendo su "fuerza de acople" y coloco estos valores en una matriz
    // diagonal
    //Aqui se usa 
    for(int i = 0; i < N; i++){
        double sum = 0.0;
        for (int j = 0; j < N; j++)
        {
            sum = sum + A[i][j];
        }
        degMat[i][i] = sum;
    }


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
double evaluateDegreeToCero(double matrix[N][N]){
    for(int i = 0; i < N ; i++){
        double sum = 0.0;
        for (int j = 0; j < N; j++){
            
            sum = sum + matrix[i][j];
        }
        if (sum == 0){
            return 1;
        }
    }
    return 0;
}

/*
Function that returns that the sum of all the elements on the vector is zero
*/
double sumVector(double vec[N]){
    double sum = 0.0;
    for (int  i = 0; i < N; i++){
        sum = sum + vec[i];
    }
    return sum;
}