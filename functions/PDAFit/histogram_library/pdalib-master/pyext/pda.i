%module pda
%{
#include "../include/Pda.h"
%}

%apply (double* IN_ARRAY1, int DIM1) {(double *in, int n_in)}
%apply (double** ARGOUTVIEW_ARRAY1, int* DIM1) {(double **out, int *n_out)}

%include "../include/Pda.h"

