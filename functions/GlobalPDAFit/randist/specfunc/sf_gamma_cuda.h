/* specfunc/sf_gamma.h
 * 
 * Special Functions - Factorials and Gamma Functions.
 *
 */
 
#ifndef SF_GAMMA_H
#define SF_GAMMA_H
 
#include "result_cuda.h"

/* log(n choose m)
 *
 * These routines compute the logarithm of n choose m. This is equivalent 
 * to the sum \log(n!) - \log(m!) - \log((n-m)!). 
 */
__device__ int sf_lnchoose_e(unsigned int n, unsigned int m, sf_result * result);
__device__ float sf_lnchoose(unsigned int n, unsigned int m);

/* log(n!) 
 * Faster than ln(Gamma(n+1)) for n < 170; defers for larger n.
 *
 * These routines compute the logarithm of the factorial of n, \log(n!). 
 * The algorithm is faster than computing \ln(\Gamma(n+1)) via sf_lngamma
 * (lgamma for C99) for n < 170, but defers for larger n. 
 */
__device__ int sf_lnfact_e(const unsigned int n, sf_result * result);
__device__ float sf_lnfact(const unsigned int n);

/* The maximum x such that gamma(x) is not
 * considered an overflow.
 */
#define SF_GAMMA_XMAX  171.0

/* The maximum n such that gsl_sf_fact(n) does not give an overflow. */
#define SF_FACT_NMAX 170

/* The maximum n such that gsl_sf_doublefact(n) does not give an overflow. */
#define SF_DOUBLEFACT_NMAX 297

#endif /* SF_GAMMA_H */
