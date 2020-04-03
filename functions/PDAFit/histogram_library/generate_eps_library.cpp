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
//#include "randist/randist.h"                        /*Statistical distributions*/

using namespace std;


// poisson distribution
void poisson_0toN(double *return_p, double lambda, unsigned int return_dim) {
    unsigned int i;
    return_p[0] = exp(-lambda);
    for (i = 1; i <= return_dim; i++) {
        return_p[i] = return_p[i - 1] * lambda / (double) i;
    }
}

// binomial distribution
void polynom2_conv(double *return_p, double *p, unsigned int n, double p2) {
    unsigned int i;
    return_p[0] = p[0] * p2;
    for (i = 1; i < n; i++) return_p[i] = p[i - 1] * (1. - p2) + p[i] * p2;
    return_p[n] = p[n - 1] * (1. - p2);
}

////////////////////////////////// convolution with background ////////////////////////////////////
void conv_pF(double *SgSr, double *FgFr, unsigned int Nmax, double Bg, double Br) {

    double *tmp = new double[(Nmax + 1) * (Nmax + 1)];

    // green and red background
    double *bg = new double[Nmax + 1];
    poisson_0toN(bg, Bg, Nmax);
    unsigned int Bg_max = 2 * (unsigned int) Bg + 52;
    double *br = new double[Nmax + 1];
    poisson_0toN(br, Br, Nmax);
    unsigned int Br_max = 2 * (unsigned int) Br + 52;

    // sum
    double s;
    unsigned int j, i, i_start, red, green;

    for (red = 0; red <= Nmax; red++) {
        red > Br_max ? i_start = red - Br_max : i_start = 0;
        for (green = 0; green <= Nmax - red; green++) {
            s = 0.;
            j = (Nmax + 1) * green;
            for (i = i_start; i <= red; i++) s += FgFr[j + i] * br[red - i];
            tmp[(Nmax + 1) * red + green] = s;
        }
    }
    for (green = 0; green <= Nmax; green++) {
        green > Bg_max ? i_start = green - Bg_max : i_start = 0;
        for (red = 0; red <= Nmax - green; red++) {
            s = 0.;
            j = (Nmax + 1) * red;
            for (i = i_start; i <= green; i++) s += tmp[j + i] * bg[green - i];
            SgSr[(Nmax + 1) * green + red] = s;
        }
    }

    delete[] bg;
    delete[] br;
    delete[] tmp;
}

/***** modification for P(N) *****/
void conv_pN(double *SgSr, double *FgFr,
                  unsigned int Nmax,
                  double Bg, double Br,
                  double *pN) {


    double s;
    unsigned int j, i;

    conv_pF(SgSr, FgFr, Nmax, Bg, Br);

    for (i = 0; i <= Nmax; i++) {
        s = 0.;
        for (j = 0; j <= i; j++) s += SgSr[Nmax * j + i];
        for (j = 0; j <= i; j++) SgSr[Nmax * j + i] *= pN[i] / s;
    }

}


void sgsr_pN(double *SgSr,        // return: SgSr(i,j) = p(Sg=i, Sr=j)
                  double *pN,        // p(N)
                  unsigned int Nmax,    // max number of photons (max N)
                  double Bg,        // <background green>, per time window (!)
                  double Br,        // <background red>, -"-
                  double pg_theor)        // p(green|F=1), incl. crosstalk
{

    /*** FgFr: matrix, FgFr(i,j) = p(Fg=i, Fr=j | F=i+j) ***/
    auto *FgFr = new double[(Nmax + 1) * (Nmax + 1)];
    FgFr[0] = 1.;
    unsigned int i, red;

    for (i = 1; i <= Nmax; i++) {
        polynom2_conv(FgFr + i * (Nmax + 1), FgFr + (i - 1) * (Nmax + 1), i, pg_theor);
        for (red = 0; red <= i - 1; red++)
            FgFr[(i - 1 - red) * (Nmax + 1) + red] = FgFr[(i - 1) * (Nmax + 1) + red];
    }
    for (red = 0; red <= Nmax; red++)
        FgFr[(Nmax - red) * (Nmax + 1) + red] = FgFr[Nmax * (Nmax + 1) + red];


    /*** SgSr: matrix, SgSr(i,j) = p(Sg = i, Sr = j) ***/

    conv_pN(SgSr, FgFr, Nmax, Bg, Br, pN);

    delete[] FgFr;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=5)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","5 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }

    const unsigned int Nmax = mxGetScalar(prhs[0]);
    double * pN = mxGetPr(prhs[1]);
    const double eps = mxGetScalar(prhs[2]);
    const double Bg = mxGetScalar(prhs[3]);
    const double Br = mxGetScalar(prhs[4]);

    double * SgSr = (double*) mxCalloc((Nmax + 1) * (Nmax + 1),sizeof(double));

    //shot_noise_limited_histogram(Nbins,minE,maxE,PN,N,eps,Neps,NBG,NBR,PBG_G,PBG_R,PE);
    sgsr_pN(SgSr,        // return: SgSr(i,j) = p(Sg=i, Sr=j)
            pN,        // p(N)
            Nmax,    // max number of photons (max N)
            Bg,        // <background green>, per time window (!)
            Br,        // <background red>, -"-
            eps);  


    plhs[0] = mxCreateNumericMatrix((Nmax + 1) * (Nmax + 1),1,mxDOUBLE_CLASS,mxREAL);
    mxSetData(plhs[0], SgSr);
}

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
// PBG      -   probability of green background photons
// PBR      -   probability of red background photons
//
// Output:
// *PE      -   shot-noise limited histogram
// void shot_noise_limited_histogram(const int Nbins, const double minE, const double maxE, double *PN, const int N, double *eps, const int Neps, const int NBG, const int NBR, double *PBG_G, double *PBG_R, double *PE)        
// {
//     int i,j,k,l,m,n;
//     double EPR;
//     double binsE[Nbins+1]; // bins edges for E
//     for (i = 0; i < (Nbins+1); i++) {
//         binsE[i] = minE + i*((maxE-minE)/Nbins);
//     }
    
//     for (i = 0; i < Neps; i++) { // loop over eps
//         for (j = 1; j <= N;  j++) {
//             for (k = 0; k <= min(j,NBG); k++) { // loop over green background
//                 for (l = 0; l <= min(j-k,NBR); l++) { // loop over red background
//                     // calculate proximity ratio
//                     for (m = 0; m <= (j-k-l); m++) { // loop over FRET photons
//                         EPR = log10(((double)j-(double)m+(double)k)/((double(m)+double(l))));//((double)m+(double)l)/((double)j);
//                         for (n = 0; n < Nbins; n++) {
//                             if (binsE[n+1] > EPR) { // find first bin that is larger than EPR
//                                 // cout << EPR;
//                                 // cout << '\n';
//                                 // cout << binsE[n+1];
//                                 // cout << '\n';
//                                 // cout << n;
//                                 // cout << '\n';
//                                 // add probability to bin
//                                 PE[n+i*Neps] += PN[j]*PBG_G[k]*PBG_R[l]*ran_binomial_pdf((unsigned int)m,eps[i],(unsigned int)(j-k-l)); 
//                                 break; // break the for loop
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

// double min(double A, double B)
// {
//     if (A < B) {return A;} else {return B;}
// }
