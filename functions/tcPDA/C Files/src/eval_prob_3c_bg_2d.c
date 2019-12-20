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
// #include <gsl/gsl_min.h>
#include "randist.h"
//#include "sys/sys.h"
#include "sys/minmax.h"

 /* Allocate 2D Array (MxN Matrix) */
int allocArray(double ***array, size_t cols, size_t rows) {
    
    size_t i;
    if ( NULL == (*array = malloc(cols * sizeof(double *))) ) {
        printf("Memory allocation failed\n");
        return(-1);
    }
    for (i = 0; i < cols; i++) {
        if ( NULL == ((*array)[i] = calloc(rows, sizeof(double))) ) {
            printf("Memory allocation failed\n");
            return(-1);
        }
    }
    return 0;
}

 /* Free 2D Array */
int freeArray(double ***array, size_t cols) {
    size_t i;
    for (i = 0; i < cols; ++i) {
        free((*array)[i]);
    }
    free(*array);
    return 0;
}

 /* The computational routine */
int eval_prob_3c_bg(double **fbb, double **fbg, double **fbr, double **fgg,
        double **fgr, double NBGbb, double NBGbg, double NBGbr, double NBGgg,
        double NBGgr, double *BGbb, double *BGbg, double *BGbr, double *BGgg,
        double *BGgr, double p_bb, double p_bg, double p_gr, 
        double **P_binomial, double **P_trinomial, size_t cols, size_t rows)
       
{
    
    double p_br = 1 - p_bb - p_bg;
    size_t i, j;                        // Loop indexes

    // Calculate the probability
    // Loop over all bursts
    for (i=0; i<cols; i++) {
        for (j=0; j<rows; j++) {

            // trinomal calculation
            size_t bg_bb;
            for (size_t a=0; a <= MIN(fbb[i][j], NBGbb) ; a++) {
                bg_bb = a;
                size_t bg_bg;
                for (size_t b=0; b <= MIN(fbg[i][j], NBGbg) ; b++) {
                    bg_bg = b;
                    size_t bg_br;
                        for (size_t c=0; c <= MIN(fbr[i][j], NBGbr) ; c++) {
                        bg_br = c;
                        // Subtract Background counts for FRET evaluation

                        // Setup Variable for final Calculation Call
                        double background[3] = {p_bb,p_bg,p_br};
                        const unsigned int bursts[3] = {(unsigned int) fbb[i][j]-bg_bb,
                                            (unsigned int) fbg[i][j]-bg_bg,
                                            (unsigned int) fbr[i][j]-bg_br};

                        P_trinomial[i][j] = P_trinomial[i][j] +  // cumulative sum
                                BGbb[bg_bb] * BGbg[bg_bg] *
                                BGbr[bg_br] *         // Background
                                        // (+1 since also zero is included)
                                ran_multinomial_pdf(3,background,bursts);
                        }
                }
            }

            // bionomal calculation

            size_t bg_gg;
            for (size_t a=0; a <= MIN(fgg[i][j], NBGgg) ; a++) {
                bg_gg = a;
                size_t bg_gr;
                for (size_t b=0; b <= MIN(fgr[i][j], NBGgr) ; b++) {
                    bg_gr = b;
                    // Subtract Background counts for FRET evaluation

                   P_binomial[i][j] = P_binomial[i][j] +  // cumulative sum
                        BGgg[bg_gg] * BGgr[bg_gr] *
                        ran_binomial_pdf((unsigned int)(fgr[i][j]-bg_gr) ,
                           p_gr, (unsigned int) (fgr[i][j] - bg_gr + fgg[i][j] - bg_gg) );
                }
            }
        }
    }
    return 0;
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double **fbb, **fbg, **fbr, **fgg, **fgr;       /* Bursts */
           //**out_matrix;                          /* Output pointer to {P} */
    double  *BGbb, *BGbg, *BGbr, *BGgg, *BGgr;      /* Background corrections */
            
    double NBGbb, NBGbg, NBGbr, NBGgg, NBGgr,   /* NBGbb = numel(BGbb)-1 */              
           p_bb, p_bg, p_gr;                    /* percentage of 'PBB 
                                                   = Pout_B./P_total;' */
    double **P_binomial;
    double **P_trinomial;
    
    size_t rows,cols;                         /* Dimension of Arry */

    /* check for proper number of arguments */
    if(nrhs!=18) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","18 inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nlhs","One output required.");
    }
    
    /* FIXME: Check for proper input types */
    
    /* get dimensions of the burst matrices */
    cols = mxGetN(prhs[0]);
    rows = mxGetM(prhs[0]);
    
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
    
    /* Allocate Space and fill fbb as first of the input values */
    allocArray(&fbb, cols, rows);
    // fill data into array
    for (size_t col = 0; col < cols; col++) {
        for (size_t row=0; row < rows; row++) {
            fbb[col][row] = 
            (mxGetPr(prhs[0]))[row+col*rows];
        }
    }
    
    /* fbg */
    allocArray(&fbg, cols, rows);
    // fill data into array
    for (size_t col = 0; col < cols; col++) {
        for (size_t row=0; row < rows; row++) {
            fbg[col][row] =
            (mxGetPr(prhs[1]))[row+col*rows];
        }
    }
    
    /* fbr */
    allocArray(&fbr, cols, rows);
    // fill data into array
    for (size_t col = 0; col < cols; col++) {
        for (size_t row=0; row < rows; row++) {
            fbr[col][row] =
            (mxGetPr(prhs[2]))[row+col*rows];
        }
    }
    
    /* fgg */
    allocArray(&fgg, cols, rows);
    // fill data into array
    for (size_t col = 0; col < cols; col++) {
        for (size_t row=0; row < rows; row++) {
            fgg[col][row] =
            (mxGetPr(prhs[3]))[row+col*rows];
        }
    }
    
    /* fgr */
    allocArray(&fgr, cols, rows);
    // fill data into array
    for (size_t col = 0; col < cols; col++) {
        for (size_t row=0; row < rows; row++) {
            fgr[col][row] =
            (mxGetPr(prhs[4]))[row+col*rows];
        }
    }

    /* Allocate Space for calculation */
    allocArray(&P_binomial, cols, rows);
    allocArray(&P_trinomial, cols, rows);

    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix((mwSize)rows,(mwSize)cols,mxREAL);
    
    /* call the computational routine */
    eval_prob_3c_bg(fbb, fbg, fbr, fgg, fgr, NBGbb, NBGbg, NBGbr, NBGgg,
        NBGgr, BGbb, BGbg, BGbr, BGgg, BGgr, p_bb, p_bg, p_gr, P_binomial,
        P_trinomial, cols, rows);
     
    /* multiply elementwise P_binomal by P_trinomal and fill output array */
    // Maybe faster with memcpy, but 2 dimensional? Also Matlab uses rows first
    // so reorder necessary..
    for (size_t col = 0; col < cols; col++) {
        for (size_t row = 0; row < rows; row++) {
            (mxGetPr(plhs[0]))[row + col*rows] =
            P_binomial[col][row] * P_trinomial[col][row];
        }
    }

    /* Clean up */
    freeArray(&P_binomial, cols);
    freeArray(&P_trinomial, cols);
    freeArray(&fbb, cols);
    freeArray(&fbg, cols);
    freeArray(&fbr, cols);
    freeArray(&fgg, cols);
    freeArray(&fgr, cols);
    
}
