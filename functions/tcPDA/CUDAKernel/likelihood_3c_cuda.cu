/* eval_prob_3c_bg.cu - Evaluate probabilty for 3-Color PDA after 
 *       blue and green excitation using CUDA
 *
 *========================================================*/

 /* Standard c libs */
#include <stdio.h>                       
#include <stdlib.h>
// #include <stddef.h>
// #include <limits.h>
#include <string.h>
#include <errno.h>

//#include "randist/randist_cuda.h"                        /* Statistical distributions */
#include "randist/sys/minmax.h"                            /* Minimum/Maximum Makro */

#include "randist/specfunc/eval_cuda.h"                    /* Data Structure of Calculations */
#include "randist/specfunc/result_cuda.h"                  /* Evaluvating results of calculations */

 /* For gpu calculation using CUDA */ 
#include <cuda.h>

 /* Forward declarations:
  * I couldn't split the source file without compile errors, even after customizing
  * mex_CUDA_win64.xml (contains matlab (mex) and cuda compile instructions for the
  * nvcc, the nvidia C/C++ Compiler) and adding '-rdc=true' as compile option and the
  * libraries 'cudart.lib' and 'cudadevrt.lib' */

__device__ int sf_lnfact_e(const unsigned int n, sf_result * result);
__device__ int sf_lnchoose_e(unsigned int n, unsigned int m, sf_result * result);
__device__ float sf_lnfact(const unsigned int n);
__device__ float sf_lnchoose(unsigned int n, unsigned int m);
__device__ float ran_multinomial_lnpdf (const size_t K, const float p[], const unsigned int n[]);
__device__ float ran_multinomial_pdf (const size_t K, const float p[], const unsigned int n[]);
__device__ float ran_binomial_pdf (const unsigned int k, const float p, const unsigned int n);

 /* The computational routine */

__global__ void eval_prob_3c_bg(
            float *likelihood,
 
            const int *fbb,
            const int *fbg,
            const int *fbr,
            const int *fgg,
            const int *fgr,

            const int NBGbb,
            const int NBGbg,
            const int NBGbr,
            const int NBGgg,
            const int NBGgr,

            const float *BGbb,
            const float *BGbg,
            const float *BGbr,
            const float *BGgg,
            const float *BGgr,

            const float *p_bb,
            const float *p_bg,       
            const float *p_gr,

            const int p_rows,
            const int n_bins            
)
{
    /* index is an identifier number of every single thread running on the gpu */
    int idx = blockDim.x * blockIdx.x + threadIdx.x;
    
    /* 
     * Every thread calculates one burst over all points of the grid
    */
    if (idx < n_bins){
        /* Calculate the probability */
        /* Loop over all the probabilities */
        for (int i=0; i < p_rows; i++) {

            /* blue-red = blue-blue - blue-green */        
            float prob[3] = {p_bb[i], p_bg[i], 1 - p_bb[i] - p_bg[i]};

            float P_binomial = 0;
            float P_trinomial = 0;

            /* trinomal calculation */
            int bg_bb;
            for (int a=0; a <= MIN(fbb[idx], NBGbb) ; a++) {
                bg_bb = a;
                int bg_bg;
                for (int b=0; b <= MIN(fbg[idx], NBGbg) ; b++) {
                    bg_bg = b;
                    int bg_br;
                    for (int c=0; c <= MIN(fbr[idx], NBGbr) ; c++) {
                        bg_br = c;
                        const unsigned int bursts[3] = {
                            (unsigned int) fbb[idx] - bg_bb,
                            (unsigned int) fbg[idx] - bg_bg,
                            (unsigned int) fbr[idx] - bg_br};

                        P_trinomial += BGbb[bg_bb] *       
                                BGbg[bg_bg] *
                                BGbr[bg_br] *         
                                ran_multinomial_pdf(3,prob,bursts);
                    }
                }
            }

            /* binomial calculation */
            int bg_gg;
            for (int a=0; a <= MIN(fgg[idx], NBGgg) ; a++) {
                bg_gg = a;
                int bg_gr;
                for (int b=0; b <= MIN(fgr[idx], NBGgr) ; b++) {
                   bg_gr = b;
                   /* Subtract Background counts for FRET evaluation */
                   P_binomial += BGgg[bg_gg] *
                           BGgr[bg_gr] *
                           ran_binomial_pdf((unsigned int)(fgr[idx] - bg_gr),
                           p_gr[i], 
                           (unsigned int) (fgr[idx] - bg_gr + fgg[idx] - bg_gg) );
                }
            }

            /* multiply both */
            likelihood[idx*p_rows + i] += P_trinomial*P_binomial;
        }
    }
}


__device__
int sf_lnfact_e(const unsigned int n, sf_result * result)
{

  result->val = lgammaf(n+1.0);
  return EXIT_SUCCESS;

}

__device__
int sf_lnchoose_e(unsigned int n, unsigned int m, sf_result * result)
{
  /* CHECK_POINTER(result) */

  if(m > n) {
	  /* Handle Error */
    //DOMAIN_ERROR(result);
	return EXIT_FAILURE;
  }
  else if(m == n || m == 0) {
    result->val = 0.0;
    result->err = 0.0;
	return EXIT_SUCCESS;
  }
  else {
    sf_result nf;
    sf_result mf;
    sf_result nmmf;
    if(m*2 > n) m = n-m;
    sf_lnfact_e(n, &nf);
    sf_lnfact_e(m, &mf);
    sf_lnfact_e(n-m, &nmmf);
    result->val  = nf.val - mf.val - nmmf.val;
    //result->err  = nf.err + mf.err + nmmf.err;
    //result->err += 2.0 * GSL_DBL_EPSILON * fabs(result->val);
	return EXIT_SUCCESS;
  }
}

__device__
float sf_lnfact(const unsigned int n)
{
  EVAL_RESULT(sf_lnfact_e(n, &result));
}

__device__
float sf_lnchoose(unsigned int n, unsigned int m)
{
  EVAL_RESULT(sf_lnchoose_e(n, m, &result));
}

/* The multinomial distribution has the form

                                      N!           n_1  n_2      n_K
   prob(n_1, n_2, ... n_K) = -------------------- p_1  p_2  ... p_K
                             (n_1! n_2! ... n_K!) 

   where n_1, n_2, ... n_K are nonnegative integers, sum_{k=1,K} n_k = N,
   and p = (p_1, p_2, ..., p_K) is a probability distribution. 

   Random variates are generated using the conditional binomial method.
   This scales well with N and does not require a setup step.

   Ref: 
   C.S. David, The computer generation of multinomial random variates,
   Comp. Stat. Data Anal. 16 (1993) 205-217
*/
 
__device__
float
ran_multinomial_lnpdf (const size_t K,
                           const float p[], const unsigned int n[])
{
  size_t k;
  unsigned int N = 0;
  float log_pdf = 0.0;
  float norm = 0.0;

  for (k = 0; k < K; k++)
    {
      N += n[k];
    }

  for (k = 0; k < K; k++)
    {
      norm += p[k];
    }

  log_pdf = sf_lnfact (N);

  for (k = 0; k < K; k++)
    {
      /* Handle case where n[k]==0 and p[k]==0 */

      if (n[k] > 0) 
        {
          log_pdf += logf (p[k] / norm) * n[k] - sf_lnfact (n[k]);
        }
    }

  return log_pdf;
}

__device__
float
ran_multinomial_pdf (const size_t K,
                         const float p[], const unsigned int n[])
{
  return expf (ran_multinomial_lnpdf (K, p, n));
}

/* The binomial distribution has the form,

   prob(k) =  n!/(k!(n-k)!) *  p^k (1-p)^(n-k) for k = 0, 1, ..., n

   This is the algorithm from Knuth */

__device__
float
ran_binomial_pdf (const unsigned int k, const float p,
                      const unsigned int n)
{
  if (k > n)
    {
      return 0;
    }
  else
    {
      float P;

      if (p == 0) 
        {
          P = (k == 0) ? 1 : 0;
        }
      else if (p == 1)
        {
          P = (k == n) ? 1 : 0;
        }
      else
        {
          float ln_Cnk = sf_lnchoose (n, k);
          P = ln_Cnk + k * logf (p) + (n - k) * log1pf (-p);
          P = expf (P);
        }

      return P;
    }
}
