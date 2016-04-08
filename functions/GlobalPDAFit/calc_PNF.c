#include <mex.h>
#include <math.h>
#include <stdlib.h>
#include "randist.h"

///////////////////////////////////////////////////////////////////////////
/// Calculates the mixture of two P(eps) distributions
///////////////////////////////////////////////////////////////////////////
// This function does the actual calculation
///////////////////////////////////////////////////////////////////////////
void calc_PNF(double *NF, double *N, double *eps, double *PNF, unsigned int numel)
{
    int i;
    for (i=0;i<numel;i++)
    {
        PNF[i] = ran_binomial_pdf((unsigned int)NF[i] ,
                       eps[i], (unsigned int)N[i]);
    }
    return;
};


///////////////////////////////////////////////////////////////////////////
// This function is called from matlab  ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////
// nlhs is the number of output parameter
// *plhs is an array of pointers to the output parameters
// nrhs is the number of input parameters
// *prhs is an array of pointers to the input parameters
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{   
    // Initializes pointers for the photon times and the correlation times
    double *NF;
    double *N;
    double *eps;
     
    // Assigns input pointers to initialized pointers
    NF = mxGetPr(prhs[0]);
    N = mxGetPr(prhs[1]);
    eps = mxGetPr(prhs[2]);
    
    unsigned int size = mxGetScalar(prhs[3]);
    // Initializes output matrix and assigns pointer to it
    double *PNF; 
    
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)size, mxREAL);
    PNF = mxGetPr(plhs[0]);    

    // Calls function to do the actual work
    calc_PNF(NF,N,eps,PNF,size);
};





