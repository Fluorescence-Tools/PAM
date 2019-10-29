/* sys/memalloc.c
 * 
 * Allocate _continuous_ memory for data strctures
 *
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "memalloc.h"

 /* Allocate 1D Array (Mx1 Matrix) */
double **allocate_1d(size_t size) {
    
    double **array;
    
    if ( NULL == (array = calloc(size, sizeof(double))) ) {
        fprintf(stderr, "Memory allocation failed\n",
                strerror (errno));
        exit (EXIT_FAILURE);
    }
    return array;
}

 /* Allocate 2D Array (MxN Matrix) of continuous memory */
double **allocate_2d(size_t cols, size_t rows) {
    
    double **array;
    size_t i;
    
    /* Allocating pointers */
    if ( NULL == (array = malloc(cols * sizeof (double*))) ) {
        fprintf(stderr, "Memory allocation failed\n",
                 strerror (errno));
         exit (EXIT_FAILURE);
    }
    /* Allocating data */
    if ( NULL == ((array)[0] = calloc(cols * rows, sizeof (double))) ) {
            fprintf(stderr, "Memory allocation failed\n",
                    strerror (errno));
            exit (EXIT_FAILURE);
        }
    for (i = 0; i < cols; i++)
        (array)[i] = (array)[0] + i * rows;
    return array;
}

//  /* Free 2D Array */
int free_2d(double **array, size_t col) {   
    free(array[0]);
    free(array);
    return 0;
}

//  /* Allocate 1D Array (Mx1 Matrix) */
// int allocate_1d(double **array, size_t size) {
//     
//     if ( NULL == (*array = calloc(size, sizeof(double))) ) {
//         fprintf(stderr, "Memory allocation failed\n",
//                 strerror (errno));
//         exit (EXIT_FAILURE);
//     }
//     return 0;
// }

//	Old variant, no continuous memory
//
//  /* Allocate 2D Array (MxN Matrix) */
// int allocate_2d(double ***array, size_t cols, size_t rows) {
//     
//     size_t i;
//     if ( NULL == (*array = malloc(cols * sizeof(double *))) ) {
//         fprintf(stderr, "Memory allocation failed\n",
//                 strerror (errno));
//         exit (EXIT_FAILURE);
//     }
//     for (i = 0; i < cols; i++) {
//         if ( NULL == ((*array)[i] = calloc(rows, sizeof(double))) ) {
//             fprintf(stderr, "Memory allocation failed\n",
//                     strerror (errno));
//             exit (EXIT_FAILURE);
//         }
//     }
//     return 0;
// }

//  /* Allocate 2D Array (MxN Matrix) of continuous memory */
// int allocate_2d(double ***array, size_t cols, size_t rows) {
//     size_t i;
//     /* Allocating pointers */
//     if ( NULL == (*array = malloc(cols * sizeof (double*))) ) {
//         fprintf(stderr, "Memory allocation failed\n",
//                  strerror (errno));
//          exit (EXIT_FAILURE);
//     }
//     /* Allocating data */
//     if ( NULL == ((*array)[0] = calloc(cols * rows, sizeof (double))) ) {
//             fprintf(stderr, "Memory allocation failed\n",
//                     strerror (errno));
//             exit (EXIT_FAILURE);
//         }
//     for (i = 0; i < cols; i++)
//         (*array)[i] = (*array)[0] + i * rows;
//     return 0;
// }

// Free for old variant
//
//  /* Free 2D Array */
// int free_2d(double ***array, size_t cols) {
//     size_t i;
//     for (i = 0; i < cols; ++i) {
//         free((*array)[i]);
//     }
//     free(*array);
//     return 0;
// }
