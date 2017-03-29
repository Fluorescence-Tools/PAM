/* randist/multinormal.c
 * 
 * Random Number Distributions - Multinomial Distribution
 *
 */

//#include <config.h>
#include <math.h>
#include "randist.h"
#include "specfunc/sf_gamma.h"

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

double
ran_multinomial_pdf (const size_t K,
                         const double p[], const unsigned int n[])
{
  return exp (ran_multinomial_lnpdf (K, p, n));
}


double
ran_multinomial_lnpdf (const size_t K,
                           const double p[], const unsigned int n[])
{
  size_t k;
  unsigned int N = 0;
  double log_pdf = 0.0;
  double norm = 0.0;

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
          log_pdf += log (p[k] / norm) * n[k] - sf_lnfact (n[k]);
        }
    }

  return log_pdf;
}
