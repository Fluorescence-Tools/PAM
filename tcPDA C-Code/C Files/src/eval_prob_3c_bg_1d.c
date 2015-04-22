/* eval_prob_3c_bg.c - Evaluate probabilty for 3-Color PDA after 
 *       blue and green excitation
 *
 * Some documentation here 
 * 
 * 
 *
 * The calling syntax is:
 *
 * ...
 *
 *
 *========================================================*/
         
#include "mex.h"
#include <stdio.h>
#include <limits.h>
// #include <stdlib.h>
// #include <gsl/gsl_randist.h>             /*Statistical distributions*/
// #include <gsl/gsl_statistics.h>
// #include <gsl/gsl_cdf.h>
// #include <gsl/gsl_math.h>
//#include <gsl/gsl_min.h>
#include "randist.h"
//#include "sys/sys.h"
#include "sys/minmax.h"

 /* Allocate 1D Array (Mx1 Matrix) */
int allocArray(double **array, size_t size) {
    
    if ( NULL == (*array = calloc(size, sizeof(double))) ) {
        printf("Memory allocation failed\n");
        return(-1);
    }
    return 0;
}

 /* The computational routine */
int eval_prob_3c_bg(double *fbb, double *fbg, double *fbr, double *fgg,
        double *fgr, double NBGbb, double NBGbg, double NBGbr, double NBGgg,
        double NBGgr, double *BGbb, double *BGbg, double *BGbr, double *BGgg,
        double *BGgr, double p_bb, double p_bg, double p_gr, 
        double *out_matrix , size_t rows)
       
{
    double *P_binomial;              // Variables for Calculation, bionomal
    double *P_trinomial;             // Variables for Calculation, trinomal
    double p_br = 1 - p_bb - p_bg;   // blue red = blue blue - blue green
    size_t i;                        // Loop indexes

    /* Allocate Space for calculation */
    allocArray(&P_binomial, rows);
    allocArray(&P_trinomial, rows);    
    
    // Calculate the probability
    // Loop over all bursts
    for (i=0; i<rows; i++) {
        
        // trinomal calculation
        size_t bg_bb;
        for (size_t a=0; a <= MIN(fbb[i], NBGbb) ; a++) {
            bg_bb = a;
            size_t bg_bg;
            for (size_t b=0; b <= MIN(fbg[i], NBGbg) ; b++) {
                bg_bg = b;
                size_t bg_br;
                    for (size_t c=0; c <= MIN(fbr[i], NBGbr) ; c++) {
                    bg_br = c;
                    // Subtract Background counts for FRET evaluation
                    
                    // Setup Variable for final Calculation Call
                    double background[3] = {p_bb,p_bg,p_br};
                    const unsigned int bursts[3] = {(unsigned int) fbb[i]-bg_bb,
                                        (unsigned int) fbg[i]-bg_bg,
                                        (unsigned int) fbr[i]-bg_br};

                    P_trinomial[i] = P_trinomial[i] +  // cumulative sum
                            BGbb[bg_bb] * BGbg[bg_bg] *
                            BGbr[bg_br] *         // Background 
                                    // (+1 since also zero is included)
                            ran_multinomial_pdf(3,background,bursts);
                    }
            }
        }
        
        // bionomal calculation

        size_t bg_gg;
        for (size_t a=0; a <= MIN(fgg[i], NBGgg) ; a++) {
            bg_gg = a;
            size_t bg_gr;
            for (size_t b=0; b <= MIN(fgr[i], NBGgr) ; b++) {
                bg_gr = b;
                // Subtract Background counts for FRET evaluation
                
               P_binomial[i] = P_binomial[i] +  // cumulative sum
                    BGgg[bg_gg] * BGgr[bg_gr] *
                    ran_binomial_pdf((unsigned int)(fgr[i]-bg_gr) ,
                       p_gr, (unsigned int) (fgr[i] - bg_gr + fgg[i] - bg_gg) );
            }
        }
    }

    /* multiply elementwise P_binomal by P_trinomal and fill output array */
    // Maybe faster with memcpy, but 2 dimensional? Also Matlab is colomn-major
    // instead of row-majow, so reorder necessary in anyway    
    for (i=0; i<rows; i++) {
        out_matrix[i] = P_binomial[i] * P_trinomial[i];
    }
    
    /* Clean up */
    free(P_binomial);
    free(P_trinomial);
    
    return 0;
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *fbb, *fbg, *fbr, *fgg, *fgr,        /* Bursts */
           *out_matrix;                          /* Output pointer to {P} */
            
    double NBGbb, NBGbg, NBGbr, NBGgg, NBGgr,   /* NBGbb = numel(BGbb)-1 */
           *BGbb, *BGbg, *BGbr, *BGgg, *BGgr,   /* Background corrections */
           p_bb, p_bg, p_gr;                    /* percentage of 'PBB 
                                                   = Pout_B./P_total;' */
    
    size_t cols, rows;                         /* Dimension of Array */

    /* check for proper number of arguments */
    if(nrhs!=18) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","18 inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nlhs","One output required.");
    }
    
    /* FIXME: Check for proper input types */

    /* create a pointer to the data of the input matrix  */
    fbb = mxGetPr(prhs[0]);    /*Sets "fbb" to be the first of the input values*/
    fbg = mxGetPr(prhs[1]);
    fbr = mxGetPr(prhs[2]);
    fgg = mxGetPr(prhs[3]);
    fgr = mxGetPr(prhs[4]);
    
    /* get the value of the scalar input  */
    NBGbb = mxGetScalar(prhs[5]);   /*Sets "NBGbb" to be the sixth of the input values*/
    NBGbg = mxGetScalar(prhs[6]);
    NBGbr = mxGetScalar(prhs[7]);
    NBGgg = mxGetScalar(prhs[8]);
    NBGgr = mxGetScalar(prhs[9]);

    BGbb = mxGetPr(prhs[10]);
    BGbg = mxGetPr(prhs[11]);
    BGbr = mxGetPr(prhs[12]);
    BGgg = mxGetPr(prhs[13]);
    BGgr = mxGetPr(prhs[14]);
    
    p_bb = mxGetScalar(prhs[15]);
    p_bg = mxGetScalar(prhs[16]);
    p_gr = mxGetScalar(prhs[17]);
      
    /* get dimensions of the burst matrices */
    cols = mxGetN(prhs[0]);
    rows = mxGetM(prhs[0]);

    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix((mwSize)rows,(mwSize)cols,mxREAL);
    /* get a pointer for the data of the output matrix */
    out_matrix = mxGetPr(plhs[0]);
    
    /* call the computational routine */
    eval_prob_3c_bg(fbb, fbg, fbr, fgg, fgr, NBGbb, NBGbg, NBGbr, NBGgg,
        NBGgr, BGbb, BGbg, BGbr, BGgg, BGgr, p_bb, p_bg, p_gr, out_matrix,
        rows);
}
