#include <mex.h>
#include <math.h>
#include <stdlib.h>
/* This function computes the biased kernel density estimator of timestamps
 * around the given timevals. */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{   
    // Initializes pointers for the photon times and the correlation times
    double *KDE;
    double *timeval;
    double *timestamps;
    // Compute KDE around timeval given timestamps
    // Gets the other input values
    unsigned int tau = (unsigned int)mxGetScalar(prhs[2]);     
    unsigned int N_timeval = (unsigned int)mxGetScalar(prhs[3]);
    unsigned int N_timestamps = (unsigned int)mxGetScalar(prhs[4]);
    // Assigns input pointers to initialized pointers
    timeval = mxGetPr(prhs[0]);
    timestamps = mxGetPr(prhs[1]);
    
    plhs[0] = mxCreateDoubleMatrix(1, N_timeval, mxREAL);
    KDE = mxGetPr(plhs[0]);    

    unsigned int tau_lim = 5*tau;
    double t;
    int ipos, ineg;
    for (int i = 0; i<N_timeval; i++) {
        t = timeval[i];        
        while (( (timestamps[ipos]-t) < tau_lim) && (ipos < N_timestamps))
        {
            ipos += 1;
        }
        
        while (( (t - timestamps[ineg]) > tau_lim) && (ineg < N_timestamps))
        {
            ineg += 1;
        }
        
        for (int j = ineg; j<ipos; j++)
        {
            KDE[i] += exp(-fabs(timestamps[j]-t)/(double)tau);
        }
    }
};