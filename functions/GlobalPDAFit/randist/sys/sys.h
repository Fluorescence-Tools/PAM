/* sys/sys.h
 * 
 * calculates expm1(x) = exp(x) - 1 and log1p(x) = log(1 + x) for very small x 
 * witch cancels out errors due to floating point arithmetic.
 * Included in the C99 Standard (VS 2013 needed)
 *
 */

#ifndef SYS_H
#define SYS_H

#undef __BEGIN_DECLS
#undef __END_DECLS
#ifdef __cplusplus
# define __BEGIN_DECLS extern "C" {
# define __END_DECLS }
#else
# define __BEGIN_DECLS /* empty */
# define __END_DECLS /* empty */
#endif

__BEGIN_DECLS

double log1p (const double x);
//double expm1 (const double x);
__END_DECLS

#endif /* SYS_H */
