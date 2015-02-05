#include <mex.h>
#include <math.h>
#include <stdlib.h>


///////////////////////////////////////////////////////////////////////////
// This function does the actual correlation, but the function called is below
///////////////////////////////////////////////////////////////////////////
void fast_MT(double *mt1, double *mt2, double *w1, double *w2, unsigned int nc, unsigned int nb,
        unsigned int np1, unsigned int np2, double *corrl, double *xdat)               
{
    // mt1, mt2:    pointers to the macrotimes; should not be modified, since they are matlab input pointers
    // xdat:        pointer to correlation time bins
    // np1, np2:    number of photons in each channel
    // w1, w2:      photon weights
    // nc:          number of evenly spaced elements per block
    // nb:          number of blocks of increasing spacing
    // corrl:       pointer to correlation output

    
    //Initializes some variables for for loops
    unsigned int i=0;
    unsigned int j=0;
    unsigned int k=0;
    unsigned int p=0;
    unsigned int im;
    
    //Initializes some parameters
    __int64_t maxmat;
    __int64_t index;
    __int64_t pw;
    __int64_t limit_l;
    __int64_t limit_r;
    
    // Photon weights; if several photons are in the same bin, intensities will be summed up to save calculation time (see below)
    double *photons1;         
    double *photons2;
    
    // Since mt1 and mt2 should not be changed, here a new memoryblock and pointer is defined
    __int64_t *t1;
    __int64_t *t2;
    
    
    // Assigns each photon to different pointer to be able to change it
    t1=(__int64_t*) mxCalloc(np1, sizeof(__int64_t));
    t2=(__int64_t*) mxCalloc(np2, sizeof(__int64_t));
    for(im=0;im<np1;im++) {t1[im]=(__int64_t) mt1[im];};
    for(im=0;im<np2;im++) {t2[im]=(__int64_t) mt2[im];};
    

    // Initializes photon weights;
    photons1=(double*) mxCalloc(np1, sizeof(__int64_t));
    for(i=0;i<np1;i++) {photons1[i]=w1[i];}
    photons2=(double*) mxCalloc(np2, sizeof(__int64_t));
    for(i=0;i<np2;i++) {photons2[i]=w2[i];}
    
    //determine max macro time
    if (t1[np1-1]>t2[np2-1]) {maxmat=t1[np1-1];}
    else {maxmat=t2[np2-1];}
    
    
        
    // Goes through every block
    for (k=0;k<nb;k++) 
    {
        // Determines spacing; used 2time spacing of one
        if (k==0) {pw=1;}
        else {pw=pow(2, k-1);};
        
        // p is the starting photon in second array 
        p=0;

        // Goes through every photon in first array     
        for (i=0;i<np1;i++) {
            if (photons1[i]!=0)
            {
                // Calculates minimal and maximal time for photons in second array
                limit_l= (__int64_t)(xdat[k*nc]/pw+t1[i]);
                limit_r= limit_l+nc;
                
                j=p;
                while ((j<np2) && (t2[j]<=limit_r))
                {
                    if (photons2[j]!=0)
                    {
                        if (k == 0) // Special Case for first round to include the zero time delay bin
                            {
                                // If correlation time is positiv OR equal
                                if (t2[j]>=limit_l)
                                {
                                    // Calculates time between two photons
                                    index=t2[j]-limit_l+(__int64_t)(k*nc);
                                    // Adds one to correlation at the appropriate timelag
                                    corrl[index]+=(double) (photons1[i]*photons2[j]);
                                }
                                // Increases starting photon in second array, to save time 
                                else {p++;}
                            }
                        else
                            {
                            // If correlation time is positiv
                                if (t2[j]>limit_l)
                                {
                                    // Calculates time between two photons
                                    index=t2[j]-limit_l+(__int64_t)(k*nc);
                                    // Adds one to correlation at the appropriate timelag
                                    corrl[index]+=(double) (photons1[i]*photons2[j]);
                                }
                                // Increases starting photon in second array, to save time 
                                else {p++;}
                            }
                    }
                    j++;
                };                
            };            
        };
        
        //After second iteration;
        if (k>0) 
        {
            // Bitwise shift right => Corresponds to dividing by 2 and rounding down
            // If two photons are in the same time bin, sums intensities and sets one to 0 to save calculation time
            for(im=0;im<np1;im++) {t1[im]=t1[im]>>1;};
            for(im=1;im<np1;im++) 
            {
                if (t1[im]==t1[im-1])
                {photons1[im]+=photons1[im-1]; photons1[im-1]=0;};
            };   
            for(im=0;im<np2;im++) {t2[im]=t2[im]>>1;};           
            for(im=1;im<np2;im++) 
            {
                if (t2[im]==t2[im-1])
                {photons2[im]+=photons2[im-1]; photons2[im-1]=0;};
            };
        };
    };
    
    // Releases pointers
    mxFree(photons1);
    mxFree(photons2);
    mxFree(t1);
    mxFree(t2);
    
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
    double *mt1;
    double *mt2;
    double *xdat;
    double *w1;
    double *w2;
            
    // Gets the other input values
    unsigned int nc = (unsigned int)mxGetScalar(prhs[4]);
    unsigned int nb = (unsigned int)mxGetScalar(prhs[5]);
    unsigned int np1 = (unsigned int)mxGetScalar(prhs[6]);
    unsigned int np2 = (unsigned int)mxGetScalar(prhs[7]);
        
    // Initializes output matrix and assigns pointer to it
    double *corrl; 
    
    // Assigns input pointers to initialized pointers
    mt1 = mxGetPr(prhs[0]);
    mt2 = mxGetPr(prhs[1]);
    w1 = mxGetPr(prhs[2]);
    w2 = mxGetPr(prhs[3]);
    xdat = mxGetPr(prhs[8]);
    
    plhs[0] = mxCreateDoubleMatrix(1, nb*nc+100, mxREAL);
    corrl = mxGetPr(plhs[0]);    

    
    // Calls function to do the actual work
    fast_MT(mt1, mt2, w1, w2, nc, nb, np1, np2, corrl, xdat);     
};





