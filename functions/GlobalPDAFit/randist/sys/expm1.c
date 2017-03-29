/* sys/expm1.c
 * 
 * Compute exp(x)-1 accurately for small values of x
 *
 */

#include <config.h>
#include <math.h>
#include "sys.h"
#include "sys_math.h"

double expm1 (const double x)
{
  /* FIXME: this should be improved */

  if (fabs(x) < M_LN2)
    {
      /* Compute the taylor series S = x + (1/2!) x^2 + (1/3!) x^3 + ... */

      double i = 1.0;
      double sum = x;
      double term = x / 1.0;

      do
        {
          i++ ;
          term *= x/i;
          sum += term;
        }
      while (fabs(term) > fabs(sum) * DBL_EPSILON) ;
      
      return sum ;
    }
  else
    {
      return exp(x) - 1;
    }
}
