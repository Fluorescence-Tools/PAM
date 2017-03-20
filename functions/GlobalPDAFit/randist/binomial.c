/* randist/multinormal.c
 * 
 * Random Number Distributions - Binomial Distribution
 *
 */

//#include <config.h>
#include <math.h>
#include "randist.h"
#include "specfunc/sf_gamma.h"
//#include "sys/sys.h"						/* log1p and expm1 for C Standard < C99 */
 
/* The binomial distribution has the form,

   prob(k) =  n!/(k!(n-k)!) *  p^k (1-p)^(n-k) for k = 0, 1, ..., n

   This is the algorithm from Knuth */

double
ran_binomial_pdf (const unsigned int k, const double p,
                      const unsigned int n)
{
  if (k > n)
    {
      return 0;
    }
  else
    {
      double P;

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
          double ln_Cnk = sf_lnchoose (n, k);
          P = ln_Cnk + k * log (p) + (n - k) * log1p (-p);
          P = exp (P);
        }

      return P;
    }
}
