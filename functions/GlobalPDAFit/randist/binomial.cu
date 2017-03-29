/* randist/multinormal.c
 * 
 * Random Number Distributions - Binomial Distribution
 *
 */

#include <math.h>
#include "randist_cuda.h"
#include "specfunc/sf_gamma_cuda.h"
 
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
