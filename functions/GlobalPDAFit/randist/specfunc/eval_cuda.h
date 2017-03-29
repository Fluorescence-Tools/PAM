/* evaluate a function discarding the status value in a modifiable way */

#ifndef SF_EVAL_H
#define SF_EVAL_H

#define EVAL_RESULT(fn) \
   sf_result result; \
   int status = fn; \
   if (status != EXIT_SUCCESS) { \
   } ; \
   return result.val;

#define EVAL_DOUBLE(fn) \
   int status = fn; \
   if (status != EXIT_SUCCESS) { \
   } ; \
   return result;

#endif /* SF_EVAL_H */
