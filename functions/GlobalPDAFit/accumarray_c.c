// Accumarray in C
#include <mex.h>
#include <math.h>
#include <stdlib.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{   
    // Initializes pointers for the photon times and the correlation times
    double *bin;
    double *P;
     
    // Assigns input pointers to initialized pointers
    bin = mxGetPr(prhs[0]); // bins in Matlab notation, so substract -1
    P = mxGetPr(prhs[1]);

    unsigned int maxBin = mxGetScalar(prhs[2]); // Assume that we start at bin 0 to bin maxBin-1
    unsigned int numel = mxGetScalar(prhs[3]);
    // Initializes output matrix and assigns pointer to it
    double *Hist; 
    
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)(maxBin), mxREAL);
    Hist = mxGetPr(plhs[0]);    

    
    // Perform calculation
    int i;
    for (i = 0; i<numel; i++) {
        Hist[(int)bin[i]-1] +=  P[i];
        }
};