#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include <vector>
#include <algorithm>
#include "time.h"
#include "matrix.h"
#include "randist/randist.h"                        /*Statistical distributions*/


using namespace std;

// generate shot-noise limited histogram for given epsilon value
// sum up all probabilities for all combinations of fluorescence and background that fall into a given bin
// works only if no brightness correction is performed
//
// Input:
// Nbins    -   number of bins for the histogram
// minE     -   minimum FRET efficiency
// maxE     -   maximumm FRET efficiency
// PN       -   experimental burst size distribution, approximation P(S) = P(F)
// N        -   maximum number of photons to consider (size of PN)
// eps      -   apparent FRET efficiencies to be used (array)
// Neps     -   number of apparent FRET efficiencies (size of eps)
// NBG      -   number of green background photons to consider
// NBR      -   number of red background photons to consider
// mBG_G    -   mean number of green background photons per time bin
// mBG_R    -   mean number of red background photons per time bin
//
// Output:
// *PE      -   shot-noise limited histogram
void shot_noise_limited_histogram(const int Nbins, const double minE, const double maxE, double *PN, const int N, double *eps, const int Neps, const int NBG, const int NBR, const double mBG_G, const double mBG_R, double *PBG_G, double *PBG_R, double *PE)        
{
    int i,j,k,l,m,n;
    double EPR;
    double binsE[Nbins]; // bins edges for E
    for (i = 0; i < Nbins; i++) {
        binsE[i] = minE + (i+1)*((maxE-minE)/Nbins);
    }

    for (i = 0; i < Neps; i++) { // loop over eps
        for (j = 0; j < N;  j++) {
            for (k = 0; k < min(j,NBG); k++) { // loop over green background
                for (l = 0; l < min(j,NBR); l++) { // loop over red background
                    // calculate proximity ratio
                    for (m = 0; m < (N-k-l); m++) { // loop over FRET photons
                        EPR = (m+l)/j;
                        for (n = 0; n < Nbins; n++) {
                            if (EPR < binsE[n]) {
                                // add probability to bin
                                PE[n+i*Neps] += PN[j]*PBG_G[k]*PBG_R[l]*ran_binomial_pdf(m,eps[i],j-k-l);
                            }
                        }
                    }
                }
            }
        }
    }
}

double min(double A, double B)
{
    if (A < B) {return A;} else {return B;}
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=4)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","4 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }

    const int Nbins = mxGetScalar(prhs[0]);
    const double minE = mxGetScalar(prhs[1]);
    const double maxE = mxGetScalar(prhs[2]);
    double * PN = mxGetPr(prhs[3]);
    const int N = mxGetScalar(prhs[4]);
    double * eps = mxGetPr(prhs[5]);
    const int Neps = mxGetScalar(prhs[6]);
    const int NBG = mxGetScalar(prhs[7]);
    const int NBR = mxGetScalar(prhs[8]);
    const double mBG_G = mxGetScalar(prhs[9]);
    const double mBG_R = mxGetScalar(prhs[10]);
    double * PBG_G = mxGetPr(prhs[11]);
    double * PBG_R = mxGetPr(prhs[12]);

    double * PE = (double*) mxCalloc(Nbins*Neps,sizeof(double));

    shot_noise_limited_histogram(Nbins,minE,maxE,PN,N,eps,Neps,NBG,NBR,mBG_G, mBG_R,PBG_G,PBG_R,PE);

    plhs[0] = mxCreateNumericMatrix(Nbins*Neps,1,mxDOUBLE_CLASS,mxREAL);
    mxSetData(plhs[0], PE);
}