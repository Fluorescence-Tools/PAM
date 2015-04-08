// Compile by simply typing mex simulate.cpp

#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include "time.h"
#include "matrix.h"
// #include <omp.h>
// #include <process.h>
// #include <windows.h>

using namespace std;
using namespace tr1;

///////////////////////////////////////////////////////////////////////////
/// Single color diffusion simulation /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void Simulate_Diffusion(__int64 maxtime, double bs_x, double bs_y, double bs_z, double posx, double posy, double posz, double d, // Box and Particle parameters
                               __int16 scan_type, double x_step, double y_step, double x_px, double y_px, __int64 x_t, __int64 y_t, // Scan parameters 
                               double wr_b, double wz_b, double mb_b, double bp_b, double dx_b, double dy_b, double dz_b,  // Color parameters blue    
                               double wr_y, double wz_y, double mb_y, double bp_y, double dx_y, double dy_y, double dz_y,  // Color parameters yellow
                               double wr_r, double wz_r, double mb_r, double bp_r, double dx_r, double dy_r, double dz_r,  // Color parameters red
                               double wr_ir, double wz_ir, double mb_ir, double bp_ir, double dx_ir, double dy_ir, double dz_ir,  // Color parameters ir
                               __int64 *Photons_b, __int64 *C_b, // Output parameters blue
                               __int64 *Photons_y, __int64 *C_y, // Output parameters yellow
                               __int64 *Photons_r, __int64 *C_r, // Output parameters red
                               __int64 *Photons_ir, __int64 *C_ir, // Output parameters ir
                               double *Final_x, double *Final_y, double *Final_z) //Final particle position

{
    /// Counting variable definition
	__int64 t = 0;

    /// Random number generator
	mt19937 mt; // initialize mersenne twister engine
    mt.seed((unsigned long)time(NULL)); // engine seeding
    //normal distribtion for diffusion
	normal_distribution<double> normal(0.0, d); //mu = 0.0, sigma = 1.0

    double pb_b;    /// Current particle brightness; is 0 or mb_b
    pb_b = mb_b;
    double pb_y;    /// Current particle brightness; is 0 or mb_y
    pb_y = mb_y;
    double pb_r;    /// Current particle brightness; is 0 or mb_r
    pb_r = mb_r;
    double pb_ir;    /// Current particle brightness; is 0 or mb_ir
    pb_ir = mb_ir;
    double P_em;  /// Emission probability
    double P_bl;  /// Bleaching probability
 

    /// Starting point of focus
    double x0 = -x_px*x_step/2;
    double y0 = -y_px*y_step/2;
    /// Initializes focus positions
    double x = 0;
    double y = 0;
 
    ///////////////////////////////////////////////////////////////////////
    /// Main loop going through all time points ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    for (t=0;t<maxtime;t++) 
    {
        /// Particle movement /////////////////////////////////////////////
        posx = posx + normal(mt); // Go one step in x direction
        posy = posy + normal(mt); // Go one step in y direction
        if (bs_z > 0) { posz = posz + normal(mt); } // Go one step in z direction, if not 2D
        
        
        /// Particle exits border /////////////////////////////////////////
        if ((posx < 0.0) || (posx > bs_x) || (posy < 0.0) || (posy > bs_y) || (posz < 0.0) || (posz > bs_z))
        {
            // Unbleach on box border crossing
            pb_b = mb_b; 
            pb_y = mb_y; 
            pb_r = mb_r; 
            pb_ir = mb_ir
                    ; 
            // Put particle back on the other side
            posx = fmod((posx + bs_x), bs_x);
            posy = fmod((posy + bs_y), bs_y);
            if (bs_z > 0) { posz = fmod((posz + bs_z), bs_z) ; } 
        }
        
        /// Focus movement ////////////////////////////////////////////////
        switch (scan_type)
        {
            case 1: /// Point measurement
                x = 0;
                y = 0;
                break;
            case 2: /// Raster scan (includes point and line)
                x = fmod((double)(t / x_t), x_px) * x_step + x0;
                y = fmod((double)(t / y_t), y_px) * y_step + y0;
                break;
            case 3: /// Line scan
                break;
            default: 
                x = 0;
                y = 0;
        }
        
        ///////////////////////////////////////////////////////////////////
        /// Generate photons for blue, only if not bleached ///////////////
        ///////////////////////////////////////////////////////////////////
        if (pb_b > 0)
        {
            /// Calculates 3D gaussian emission profile
            P_em = pb_b*exp(-2*(((posx-bs_x/2+dx_b-x)*(posx-bs_x/2+dx_b-x))+((posy-bs_y/2+dy_b-y)*(posy-bs_y/2+dy_b-y)))/(wr_b*wr_b) -2*((posz-bs_z/2+dz_b)*(posz-bs_z/2+dz_b))/(wz_b*wz_b));
            /// Calculates bleaching probability
            P_bl = bp_b*P_em;
            /// Checks, if particle bleaches
            if (P_bl > 0.0)
            {
                /// Create binomial distribution for bleaching probability
                binomial_distribution<__int64, double> binomial1(1, P_bl);
                /// Bleaches particle with probability
                if ((double)binomial1(mt)) { pb_b = 0; }
            }

            /// Only roll if P_em is larger than 0.01% = 1E-4
            if (P_em > 1E-4) 
            {
                /// Create binomial distribution for photon probability
                binomial_distribution<__int64, double> binomial2(1, P_em);
                /// Generates photons with probability    
                if ((double)binomial2(mt))
                {
                    /// Adds photon to list at time t 
                    Photons_b[C_b[0]] = (__int64)t;
                    /// Adde one to number of photons
                    C_b[0]++;
                }
            }
        }
        ///////////////////////////////////////////////////////////////////
        /// Generate photons for yellow, only if not bleached /////////////
        ///////////////////////////////////////////////////////////////////
        if (pb_y > 0)
        {
            /// Calculates 3D gaussian emission profile
            P_em = pb_y*exp(-2*(((posx-bs_x/2+dx_y-x)*(posx-bs_x/2+dx_y-x))+((posy-bs_y/2+dy_y-y)*(posy-bs_y/2+dy_y-y)))/(wr_y*wr_y) -2*((posz-bs_z/2+dz_y)*(posz-bs_z/2+dz_y))/(wz_y*wz_y));
            /// Calculates bleaching probability
            P_bl = bp_y*P_em;
            /// Checks, if particle bleaches
            if (P_bl > 0.0)
            {
                /// Create binomial distribution for bleaching probability
                binomial_distribution<__int64, double> binomial1(1, P_bl);
                /// Bleaches particle with probability
                if ((double)binomial1(mt)) { pb_y = 0; }
            }

            /// Only roll if P_em_g is larger than 0.01% = 1E-4
            if (P_em > 1E-4) 
            {
                /// Create binomial distribution for photon probability
                binomial_distribution<__int64, double> binomial2(1, P_em);
                /// Generates photons with probability    
                if ((double)binomial2(mt))
                {
                    /// Adds photon to list at time t 
                    Photons_y[C_y[0]] = (__int64)t;
                    /// Adde one to number of photons
                    C_y[0]++;
                }
            }
        }
        ///////////////////////////////////////////////////////////////////
        /// Generate photons for red, only if not bleached ////////////////
        ///////////////////////////////////////////////////////////////////
        if (pb_r > 0)
        {
            /// Calculates 3D gaussian emission profile
            P_em = pb_r*exp(-2*(((posx-bs_x/2+dx_r-x)*(posx-bs_x/2+dx_r-x))+((posy-bs_y/2+dy_r-y)*(posy-bs_y/2+dy_r-y)))/(wr_r*wr_r) -2*((posz-bs_z/2+dz_r)*(posz-bs_z/2+dz_r))/(wz_r*wz_r));
            /// Calculates bleaching probability
            P_bl = bp_y*P_em;
            /// Checks, if particle bleaches
            if (P_bl > 0.0)
            {
                /// Create binomial distribution for bleaching probability
                binomial_distribution<__int64, double> binomial1(1, P_bl);
                /// Bleaches particle with probability
                if ((double)binomial1(mt)) { pb_r = 0; }
            }

            /// Only roll if P_em_g is larger than 0.01% = 1E-4
            if (P_em > 1E-4) 
            {
                /// Create binomial distribution for photon probability
                binomial_distribution<__int64, double> binomial2(1, P_em);
                /// Generates photons with probability    
                if ((double)binomial2(mt))
                {
                    /// Adds photon to list at time t 
                    Photons_r[C_r[0]] = (__int64)t;
                    /// Adde one to number of photons
                    C_r[0]++;
                }
            }
        }
        ///////////////////////////////////////////////////////////////////
        /// Generate photons for ir, only if not bleached /////////////////
        ///////////////////////////////////////////////////////////////////
        if (pb_ir > 0)
        {
            /// Calculates 3D gaussian emission profile
            P_em = pb_ir*exp(-2*(((posx-bs_x/2+dx_ir-x)*(posx-bs_x/2+dx_ir-x))+((posy-bs_y/2+dy_ir-y)*(posy-bs_y/2+dy_ir-y)))/(wr_ir*wr_ir) -2*((posz-bs_z/2+dz_ir)*(posz-bs_z/2+dz_ir))/(wz_ir*wz_ir));
            /// Calculates bleaching probability
            P_bl = bp_ir*P_em;
            /// Checks, if particle bleaches
            if (P_bl > 0.0)
            {
                /// Create binomial distribution for bleaching probability
                binomial_distribution<__int64, double> binomial1(1, P_bl);
                /// Bleaches particle with probability
                if ((double)binomial1(mt)) { pb_ir = 0; }
            }

            /// Only roll if P_em_g is larger than 0.01% = 1E-4
            if (P_em > 1E-4) 
            {
                /// Create binomial distribution for photon probability
                binomial_distribution<__int64, double> binomial2(1, P_em);
                /// Generates photons with probability    
                if ((double)binomial2(mt))
                {
                    /// Adds photon to list at time t 
                    Photons_ir[C_ir[0]] = (__int64)t;
                    /// Adde one to number of photons
                    C_ir[0]++;
                }
            }
        }
        
    }

    Final_x[0] = posx;
    Final_y[0] = posy;
    Final_z[0] = posz;

	return;

}




///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(__int64 nlhs, mxArray *plhs[], __int64 nrhs, const mxArray *prhs[])
{
	///////////////////////////////////////////////////////////////////////
	/// Parameters defining general simulation parameters /////////////
	///////////////////////////////////////////////////////////////////////
    // simulation time in clockticks
	__int64 maxtime = (__int64)mxGetScalar(prhs[0]);
    // Box dimentions in nm/points
	double bs_x = (double)mxGetScalar(prhs[1]);
    double bs_y = (double)mxGetScalar(prhs[2]);
    double bs_z = (double)mxGetScalar(prhs[3]); 
    // Starting position
    double posx = (double)mxGetScalar(prhs[4]);
    double posy = (double)mxGetScalar(prhs[5]);
    double posz = (double)mxGetScalar(prhs[6]);
    // Diffusion coefficient as sigma of gaussian diffusion steps
    double d = (double)mxGetScalar(prhs[7]);
    
	///////////////////////////////////////////////////////////////////////
    /// Parameters defining scanning type /////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
    /// Scan type: 
    /// 0: Raster scan (includes point and line)
    /// 1: Circle scan
    __int16 scan_type = (__int16)mxGetScalar(prhs[8]);
    /// Diameter in x and y in nm/points
    double x_step = (double)mxGetScalar(prhs[9]);
	double y_step = (double)mxGetScalar(prhs[10]);
    /// Number of pixels/lines
    double x_px = (double)mxGetScalar(prhs[11]);
	double y_px = (double)mxGetScalar(prhs[12]);
    /// Pixel/Line time in ticks
    __int64 x_t = (__int64)mxGetScalar(prhs[13]);
	__int64 y_t = (__int64)mxGetScalar(prhs[14]);
    
	//////////////////////////////////////////////////////////////////////
	/// First color parameters ///////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////
	double wr_b = (double)mxGetScalar(prhs[15]);
	double wz_b = (double)mxGetScalar(prhs[16]);
	double mb_b = (double)mxGetScalar(prhs[17]);
	double bp_b = (double)mxGetScalar(prhs[18]);
    double dx_b = (double)mxGetScalar(prhs[19]);
    double dy_b = (double)mxGetScalar(prhs[20]);
    double dz_b = (double)mxGetScalar(prhs[21]);

    ///////////////////////////////////////////////////////////////////////
	/// Second color parameters ///////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////
    double wr_y = (double)mxGetScalar(prhs[22]);
    double wz_y = (double)mxGetScalar(prhs[23]);
    double mb_y = (double)mxGetScalar(prhs[24]);
    double bp_y = (double)mxGetScalar(prhs[25]);
    double dx_y = (double)mxGetScalar(prhs[26]);
    double dy_y = (double)mxGetScalar(prhs[27]);
    double dz_y = (double)mxGetScalar(prhs[28]);
    
    ///////////////////////////////////////////////////////////////////////
    /// Third color parameters ////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
    double wr_r = (double)mxGetScalar(prhs[29]);
    double wz_r = (double)mxGetScalar(prhs[30]);
    double mb_r = (double)mxGetScalar(prhs[31]);
    double bp_r = (double)mxGetScalar(prhs[32]);
    double dx_r = (double)mxGetScalar(prhs[33]);
    double dy_r = (double)mxGetScalar(prhs[34]);
    double dz_r = (double)mxGetScalar(prhs[35]);
    
    ///////////////////////////////////////////////////////////////////////
    /// Forth color parameters ////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
    double wr_ir = (double)mxGetScalar(prhs[36]);
    double wz_ir = (double)mxGetScalar(prhs[37]);
    double mb_ir = (double)mxGetScalar(prhs[38]);
    double bp_ir = (double)mxGetScalar(prhs[39]);
    double dx_ir = (double)mxGetScalar(prhs[40]);
    double dy_ir = (double)mxGetScalar(prhs[41]);
    double dz_ir = (double)mxGetScalar(prhs[42]);
    

    ///////////////////////////////////////////////////////////////////////
    /// Allocates memory for output parameters ////////////////////////////
    ///////////////////////////////////////////////////////////////////////
    /// Photons
    __int64 *Photons_b;
    Photons_b=(__int64*) mxCalloc(maxtime, sizeof(__int64));
    __int64 *Photons_y;
    Photons_y=(__int64*) mxCalloc(maxtime, sizeof(__int64));
    __int64 *Photons_r;
    Photons_r=(__int64*) mxCalloc(maxtime, sizeof(__int64));
    __int64 *Photons_ir;
    Photons_ir=(__int64*) mxCalloc(maxtime, sizeof(__int64));
    
    /// Final particle position
    double *Final_x;
    double *Final_y;
    double *Final_z;
    Final_x=(double*) mxCalloc(1, sizeof(double));
    Final_y=(double*) mxCalloc(1, sizeof(double));
    Final_z=(double*) mxCalloc(1, sizeof(double));
    /// Counts per channel
    __int64 *C_b;
    C_b=(_int64*) mxCalloc(1, sizeof(__int64));
    __int64 *C_y;
    C_y=(_int64*) mxCalloc(1, sizeof(__int64));
    __int64 *C_r;
    C_r=(_int64*) mxCalloc(1, sizeof(__int64));
    __int64 *C_ir;
    C_ir=(_int64*) mxCalloc(1, sizeof(__int64));

    ///////////////////////////////////////////////////////////////////////
    /// Simulate 4Col Dif |#Ticks| Bixsize in nm| Start position  | D| Scan Type| Scan dim.     | Px/Lines  |T per p/l|| 
    Simulate_Diffusion(maxtime, bs_x, bs_y, bs_z, posx, posy, posz, d, scan_type, x_step, y_step, x_px, y_px, x_t, y_t,
            wr_b, wz_b, mb_b, bp_b, dx_b, dy_b, dz_b, // Blue parameters  
            wr_y, wz_y, mb_y, bp_y, dx_y, dy_y, dz_y, // Yellow parameters  
            wr_r, wz_r, mb_r, bp_r, dx_r, dy_r, dz_r, // Red parameters  
            wr_ir, wz_ir, mb_ir, bp_ir, dx_ir, dy_ir, dz_ir, // IR parameters  
            Photons_b, C_b, Photons_y, C_y, Photons_r, C_r, Photons_ir, C_ir, // Photon output parameters     
            Final_x, Final_y, Final_z);// Final particle position  

    const mwSize dims_b[]={(double)C_b[0],1};
    const mwSize dims_y[]={(double)C_y[0],1};
    const mwSize dims_r[]={(double)C_r[0],1};
    const mwSize dims_ir[]={(double)C_ir[0],1};
    const mwSize dims_X[]={1,1};
    const mwSize dims_Y[]={1,1};
    const mwSize dims_Z[]={1,1};
     
    plhs[0] = mxCreateNumericArray(2, dims_b, mxINT64_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, dims_y, mxINT64_CLASS, mxREAL);
    plhs[2] = mxCreateNumericArray(2, dims_r, mxINT64_CLASS, mxREAL);
    plhs[3] = mxCreateNumericArray(2, dims_ir, mxINT64_CLASS, mxREAL);
    plhs[4] = mxCreateNumericArray(2, dims_X, mxDOUBLE_CLASS, mxREAL);
    plhs[5] = mxCreateNumericArray(2, dims_Y, mxDOUBLE_CLASS, mxREAL);
    plhs[6] = mxCreateNumericArray(2, dims_Z, mxDOUBLE_CLASS, mxREAL);

    mxSetData(plhs[0], Photons_b);
    mxSetData(plhs[1], Photons_y);
    mxSetData(plhs[2], Photons_r);
    mxSetData(plhs[3], Photons_ir);
    mxSetData(plhs[4], Final_x);
    mxSetData(plhs[5], Final_y);
    mxSetData(plhs[6], Final_z);


}