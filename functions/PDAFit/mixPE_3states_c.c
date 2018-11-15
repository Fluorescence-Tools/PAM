#include <mex.h>
#include <math.h>
#include <stdlib.h>

///////////////////////////////////////////////////////////////////////////
/// Calculates the mixture of two P(eps) distributions
///////////////////////////////////////////////////////////////////////////
// This function does the actual calculation
///////////////////////////////////////////////////////////////////////////
void mixPeps(double *eps, double *PE1, double *PE2, double* PE3, unsigned int N_bins_T, unsigned int N_bins_eps,
        double Q1, double Q2, double Q3,
        double *PEmix)
{
    unsigned int k;
    unsigned int l;
    unsigned int i;
    unsigned int j;
    unsigned int h;
    unsigned int ix;
    double T1, T2, T3;
    double meanEps;
    
    for (k=0;k<N_bins_T;k++)
    {
        T1 = (double)k;
        for (l=0;l<N_bins_T-k;l++)
        {
            T2 = (double)l;
            T3 = (double)(N_bins_T-k-l-1);
            for (i=0;i<N_bins_eps;i++)
            {   
                if (PE1[i]>1E-3)
                {
                    for (j=0;j<N_bins_eps;j++)
                    {
                        if (PE2[j]>1E-3)
                        {
                            for (h=0;h<N_bins_eps;h++)
                            {
                                if (PE3[h]>1E-3)
                                {
                                    //meanEps = p1*eps[i]+(1-p1)*eps[j];
                                    // now with brightness correction!
                                    meanEps = (Q1*T1*eps[i]+Q2*T2*eps[j]+Q3*T3*eps[h])/(Q1*T1+Q2*T2+Q3*T3);
                                    for (ix = 0; ix<N_bins_eps; ix++)
                                        {
                                        if (meanEps <= eps[ix])
                                            {break;}
                                        }
                                    PEmix[N_bins_eps*N_bins_T*k+N_bins_eps*l+ix] += PE1[i]*PE2[j]*PE3[h];
                                }
                            }
                        }
                    }
                }
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
    double *PE3;
    double *PofT;
     
    // Initializes output matrix and assigns pointer to it
    double *PEmix; 
    
    unsigned int N_bins_T = (unsigned int)mxGetScalar(prhs[4]);
    unsigned int N_bins_eps = (unsigned int)mxGetScalar(prhs[5]);
    double Q1 = (double)mxGetScalar(prhs[6]);
    double Q2 = (double)mxGetScalar(prhs[7]);
    double Q3 = (double)mxGetScalar(prhs[8]);
    // Assigns input pointers to initialized pointers
    eps = mxGetPr(prhs[0]);
    PE1 = mxGetPr(prhs[1]);
    PE2 = mxGetPr(prhs[2]);
    PE3 = mxGetPr(prhs[3]);
    
    
    plhs[0] = mxCreateDoubleMatrix(1,(mwSize)(N_bins_eps*N_bins_T*N_bins_T), mxREAL);
    PEmix = mxGetPr(plhs[0]);    

    
    // Calls function to do the actual work
    mixPeps(eps,PE1,PE2,PE3,N_bins_T,N_bins_eps,Q1,Q2,Q3,PEmix);     
};





