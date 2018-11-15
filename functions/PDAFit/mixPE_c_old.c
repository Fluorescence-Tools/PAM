#include <mex.h>
#include <math.h>
#include <stdlib.h>

///////////////////////////////////////////////////////////////////////////
/// Calculates the mixture of two P(eps) distributions
///////////////////////////////////////////////////////////////////////////
// This function does the actual calculation
///////////////////////////////////////////////////////////////////////////
void mixPeps(double *eps, double *PE1, double *PE2, unsigned int N_bins_T, unsigned int N_bins_eps,
        double Q1, double Q2,
        double *PEmix)
{
    unsigned int k;
    unsigned int i;
    unsigned int j;
    unsigned int ix;
    double T1, T2;
    double meanEps;
    
    for (k=0;k<N_bins_T;k++)
    {
        //p1 = (double)k/(double)(N_bins_T-1);
        T1 = (double)k;
        T2 = (double)(N_bins_T-k);
        for (i=0;i<N_bins_eps;i++)
        {
            for (j=0;j<N_bins_eps;j++)
            { 
                //meanEps = p1*eps[i]+(1-p1)*eps[j];
                // now with brightness correction!
                meanEps = (Q1*T1*eps[i]+Q2*T2*eps[j])/(Q1*T1+Q2*T2);
                for (ix = 0; ix<N_bins_eps; ix++)
                {
                    if (meanEps <= eps[ix])
                    {break;}
                }
                PEmix[N_bins_eps*k+ix] += PE1[i]*PE2[j];
            }
            
            
        }
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
    double *eps;
    double *PE1;
    double *PE2;
    double *PofT;
     
    // Initializes output matrix and assigns pointer to it
    double *PEmix; 
    
    unsigned int N_bins_T = (unsigned int)mxGetScalar(prhs[3]);
    unsigned int N_bins_eps = (unsigned int)mxGetScalar(prhs[4]);
    double Q1 = (double)mxGetScalar(prhs[5]);
    double Q2 = (double)mxGetScalar(prhs[6]);
    
    // Assigns input pointers to initialized pointers
    eps = mxGetPr(prhs[0]);
    PE1 = mxGetPr(prhs[1]);
    PE2 = mxGetPr(prhs[2]);
    
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)(N_bins_eps*N_bins_T), mxREAL);
    PEmix = mxGetPr(plhs[0]);    

    
    // Calls function to do the actual work
    mixPeps(eps,PE1,PE2,N_bins_T,N_bins_eps,Q1,Q2,PEmix);     
};





