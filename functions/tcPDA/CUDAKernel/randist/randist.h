/* randist/randist.h
 * 
 * Random Number Distributions
 * Currently implemented: Multinomial Distribution, Binomial Distribution
 *
 */

#ifndef RANDIST_H
#define RANDIST_H

#include <stdlib.h>									/* for size_t */

double ran_binomial_pdf (const unsigned int k, const double p, const unsigned int n);

double ran_multinomial_pdf (const size_t K,
                                const double p[], const unsigned int n[] );
double ran_multinomial_lnpdf (const size_t K,
                           const double p[], const unsigned int n[] );
						   				   
#endif /* RANDIST_H*/