/* minmax.h
 * 
 * Define MAX and MIN macros/functions
 *
 */
 
#ifndef SYS_MINMAX_H
#define SYS_MINMAX_H

/* Define MAX and MIN macros/functions if they don't exist. */

/* plain old macros for general use */
#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define MIN(a,b) ((a) < (b) ? (a) : (b))

/* function versions of the above, in case they are needed */
//double max (double a, double b);
//double min (double a, double b);

#endif /* SYS_MINMAX_H */