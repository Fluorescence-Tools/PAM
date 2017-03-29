/* sys/log1p.c
 * 
 * Compute log(1+x) accurately for small values of x
 *
 */

//#include <config.h>
#include <math.h>
#include "sys.h"

double log1p (const double x)
{
  volatile double y, z;
  y = 1 + x;
  z = y - 1;
  return log(y) - (z-x)/y ;  /* cancels errors with IEEE arithmetic */
}
