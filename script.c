
#include <stdio.h>
#include <stdlib.h>
// N = Numero de nodos a simular.
const int N = 125;

const K_strength = 3;

int main(){
    // p_conn: prbabilidad de conexión
    const double p_conn = 0.05;

    // Parámetro de inercia
    const float alpha = 0.1;

    // Inicializo la matriz de conectividad tamaño NxN
    int K[N][N] = {{0}}; 
    
    for(int i = 0; i < N; i++){
        for(int j = i+1; j < N; j++){
            //
            int r = rand() % (100+1); //Comvertir en un rango de cero a 100
            if((r/100) < p_conn){
                K[i][j] = 1;
                K[j][i] = 1;
            }
        }
    }

    

    printf("%d", N);

    return 0;
}
