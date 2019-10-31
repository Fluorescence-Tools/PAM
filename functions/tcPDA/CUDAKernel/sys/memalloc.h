/* sys/memalloc.h
 * 
 * Allocate _continuous_ memory for data strctures
 *
 */
 
#ifndef SYS_memalloc_H
#define SYS_memalloc_H

#include <stdlib.h>									/* for size_t */

/* Allocate one dimensional array of continuous memory
 *
 */
double **allocate_1d(size_t size);

/* Allocate two dimensional array of continuous memory. 
 * (Array of pointers to pointers)
 *
 */
double **allocate_2d(size_t cols, size_t rows);

/* Free memory of two dimensional array. 
 *
 */
int free_2d(double **array, size_t col);

#endif /* SYS_memalloc_H */
