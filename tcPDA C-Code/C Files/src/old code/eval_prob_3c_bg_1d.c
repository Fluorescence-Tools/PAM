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
#include <stdlib.h>
// #include <stddef.h>
// #include <limits.h>
#include <string.h>
#include <errno.h>
#include "randist/randist.h"                        /*Statistical distributions*/
//#include "randist/sys/sys.h"                      /*For log1p before C99*/
#include "randist/sys/minmax.h"                     /*Minimum/Maximum Makro*/
#include "sys/numcores.h"
#include "sys/tcpda.h"

#ifdef _WIN32
#include <windows.h>                                /* for HANDLE Definition */
#include <process.h>                                /* THREAD api */
#elif MACOS
//#include <sys/param.h>
//#include <sys/sysctl.h>
#else
//#include <unistd.h>
#endif

 /* Allocate 1D Array (Mx1 Matrix) */
int allocArray(double **array, size_t size) {
    
    if ( NULL == (*array = calloc(size, sizeof(double))) ) {
        fprintf(stderr, "Memory allocation failed\n",
                strerror (errno));
        exit (EXIT_FAILURE);
    }
    return 0;
}

 /* Allocate 2D Array (MxN Matrix) */
int allocMultiArray(double ***array, size_t cols, size_t rows) {
    
    size_t i;
    if ( NULL == (*array = malloc(cols * sizeof(double *))) ) {
        fprintf(stderr, "Memory allocation failed\n",
                strerror (errno));
        exit (EXIT_FAILURE);
    }
    for (i = 0; i < cols; i++) {
        if ( NULL == ((*array)[i] = calloc(rows, sizeof(double))) ) {
            fprintf(stderr, "Memory allocation failed\n",
                    strerror (errno));
            exit (EXIT_FAILURE);
        }
    }
    return 0;
}

 /* Free 2D Array */
int freeMultiArray(double ***array, size_t cols) {
    size_t i;
    for (i = 0; i < cols; ++i) {
        free((*array)[i]);
    }
    free(*array);
    return 0;
}

 /* The computational routine */
static unsigned __stdcall eval_prob_3c_bg(void *data)
{
    // restore data.
    tcpda_data *thread_data = (tcpda_data *) data;
        
    double **P_binomial;              // Variables for Calculation, bionomal
    double **P_trinomial;             // Variables for Calculation, trinomal

    /* Allocate Space for calculation */
    allocMultiArray(&P_binomial, thread_data->p_rows, thread_data->burst_rows);
    allocMultiArray(&P_trinomial, thread_data->p_rows, thread_data->burst_rows);    
    
    // Calculate the probability
    // Loop over all bursts
    for (size_t i=0; i < thread_data->p_rows; i++) {
        // blue red = blue blue - blue green
        double p_br = 1 - thread_data->p_bb[i] - thread_data->p_bg[i];   

        for (size_t j=thread_data->thread_id; j<thread_data->burst_rows; j=j+thread_data->num_cores) {
            // trinomal calculation
            size_t bg_bb;
            for (size_t a=0; a <= MIN(thread_data->fbb[j], thread_data->NBGbb) ; a++) {
                bg_bb = a;
                size_t bg_bg;
                for (size_t b=0; b <= MIN(thread_data->fbg[j], thread_data->NBGbg) ; b++) {
                    bg_bg = b;
                    size_t bg_br;
                        for (size_t c=0; c <= MIN(thread_data->fbr[j], thread_data->NBGbr) ; c++) {
                        bg_br = c;
                        // Subtract Background counts for FRET evaluation

                        // Setup Variable for final Calculation Call
                        double background[3] = {thread_data->p_bb[i], thread_data->p_bg[i], p_br};
                        const unsigned int bursts[3] = {(unsigned int) thread_data->fbb[j] - bg_bb,
                                            (unsigned int) thread_data->fbg[j] - bg_bg,
                                            (unsigned int) thread_data->fbr[j] - bg_br};

                        P_trinomial[i][j] = P_trinomial[i][j] +  // cumulative sum
                                thread_data->BGbb[bg_bb] * thread_data->BGbg[bg_bg] *
                                thread_data->BGbr[bg_br] *         // Background 
                                        // (+1 since also zero is included)
                                ran_multinomial_pdf(3,background,bursts);
                        }
                }
            }

            // bionomal calculation

            size_t bg_gg;
            for (size_t a=0; a <= MIN(thread_data->fgg[j], thread_data->NBGgg) ; a++) {
                bg_gg = a;
                size_t bg_gr;
                for (size_t b=0; b <= MIN(thread_data->fgr[j], thread_data->NBGgr) ; b++) {
                    bg_gr = b;
                    // Subtract Background counts for FRET evaluation

                   P_binomial[i][j] = P_binomial[i][j] +  // cumulative sum
                        thread_data->BGgg[bg_gg] * thread_data->BGgr[bg_gr] *
                        ran_binomial_pdf((unsigned int)(thread_data->fgr[j] - bg_gr) ,
                           thread_data->p_gr[i], (unsigned int) (thread_data->fgr[j] - bg_gr + thread_data->fgg[j] - bg_gg) );
                }
            }
        }
    }

    /* multiply elementwise P_binomal by P_trinomal and fill output array */
    // Maybe faster with memcpy, but 2 dimensional? Also Matlab is colomn-major
    // instead of row-majow, so reorder necessary in anyway
    
    for (size_t i=0; i < thread_data->p_rows; i++) {
        for (size_t j=thread_data->thread_id; j<thread_data->burst_rows; j=j+thread_data->num_cores) {
            thread_data->out_matrix[i][j] = P_binomial[i][j] * P_trinomial[i][j];
        }
    }
        
    /* Clean up */
    
    freeMultiArray(&P_binomial, thread_data->p_rows);
    freeMultiArray(&P_trinomial, thread_data->p_rows);
    
    return 0;
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
        
    /* check for proper number of arguments */
    if(nrhs!=18) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","18 inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nlhs","One output required.");
    }
    
    /* FIXME: Check for proper input types */

    // need for pre-allocation of the 2D Cell Matrix for output.
    double **out_matrix;
    
    size_t burst_cols, burst_rows;              /* Dimension of Burst Arrray */
    size_t p_cols, p_rows;                      /* Dimension of P Array */
    
    HANDLE *thread_list;                        // Handles to the worker threads
    unsigned int *thread_id;                    // Thread IDs for worker threads
    tcpda_data *thread_data_list;               // Thread IDs for worker threads
    int num_cores = get_number_of_cores();      // Number of parallel threads
    
    /* get dimensions of the burst matrices */
    burst_cols = mxGetN(prhs[0]);
    burst_rows = mxGetM(prhs[0]);
    
    /* get dimensions of the p matrix */
    p_cols = mxGetN(prhs[15]);
    p_rows = mxGetM(prhs[15]);
    
    // reserve room for handles in ThreadList
    thread_list = (HANDLE*)malloc(num_cores * sizeof( HANDLE ));
    
    // reserve room for handles in ThreadList
    thread_id = (unsigned int*)malloc(num_cores * sizeof( unsigned int ));
    
    // reserve room for handles in ThreadList
    thread_data_list = (tcpda_data*)malloc(num_cores * sizeof( tcpda_data ));    
    
    // create data on the heap for working threads
    tcpda_data *thread_data;
    
    thread_data = malloc(sizeof(tcpda_data));
    if(!thread_data) { 
            fprintf(stderr, "Memory allocation failed\n",
                strerror (errno));
            exit (EXIT_FAILURE);
    }
    
    allocMultiArray(&out_matrix, p_rows, burst_rows);
    
    /* create a pointer to the data of the input matrix  */
    thread_data->fbb = mxGetPr(prhs[0]);    /*Sets "fbb" to be the first of the input values*/
    thread_data->fbg = mxGetPr(prhs[1]);
    thread_data->fbr = mxGetPr(prhs[2]);
    thread_data->fgg = mxGetPr(prhs[3]);
    thread_data->fgr = mxGetPr(prhs[4]);
    
    /* get the value of the scalar input  */
    thread_data->NBGbb = mxGetScalar(prhs[5]);  /*Sets "NBGbb" to be the sixth of the input values*/
    thread_data->NBGbg = mxGetScalar(prhs[6]);
    thread_data->NBGbr = mxGetScalar(prhs[7]);
    thread_data->NBGgg = mxGetScalar(prhs[8]);
    thread_data->NBGgr = mxGetScalar(prhs[9]);    

    /* create a pointer to the data of the input matrix  */
    thread_data->BGbb = mxGetPr(prhs[10]);
    thread_data->BGbg = mxGetPr(prhs[11]);
    thread_data->BGbr = mxGetPr(prhs[12]);
    thread_data->BGgg = mxGetPr(prhs[13]);
    thread_data->BGgr = mxGetPr(prhs[14]);
   
    thread_data->p_bb = mxGetPr(prhs[15]);
    thread_data->p_bg = mxGetPr(prhs[16]);
    thread_data->p_gr = mxGetPr(prhs[17]);

    /* get dimensions of the burst matrices */
    thread_data->burst_cols = mxGetN(prhs[0]);
    thread_data->burst_rows = mxGetM(prhs[0]);
    
    /* get dimensions of the p matrix */
    thread_data->p_cols = mxGetN(prhs[15]);
    thread_data->p_rows = mxGetM(prhs[15]);
    
    thread_data->out_matrix = out_matrix;
    thread_data->num_cores = num_cores;
    
    // create and start the working threads
    for (int i=0; i < num_cores; i++) {
        memcpy (&thread_data_list[i], thread_data, sizeof (tcpda_data));
        //thread_data_list[i] = thread_data;
        thread_data_list[i].thread_id = i;
        thread_list[i] = (HANDLE)_beginthreadex(
            NULL,                     /* Thread security */
            0,                        /* Thread stack size */
            &eval_prob_3c_bg,         /* Thread starting address - address of function*/
            (void *) &thread_data_list[i],     /* Thread arguments */
            0,                        /* Create in running state */
            &thread_id[i]);           /* Thread ID */
        if (thread_list[i] == INVALID_HANDLE_VALUE) {
            // Handle Error
            // return -1;
        }
    }

    // wait for threads to finish
    WaitForMultipleObjects(num_cores, thread_list, TRUE, INFINITE);
    
    // Check for successfull exit codes

    
    /* create the output 2-D double array */
    /* This is necessary because the MATLAB mex api (mex.h) is NOT 
     * Thread-safe, i.e. all functions outside the MexFunction writing 
     * to the MATLAB memory allocator will likely crash or corrupt the 
     * results. */
    plhs[0] = mxCreateDoubleMatrix((mwSize)burst_rows,(mwSize)p_rows,mxREAL);
    
    /* get the data out */
    // Maybe faster with memcpy, but 2 dimensional? Also Matlab is column
    // major so reorder necessary..
    for (size_t p_row = 0; p_row < p_rows; p_row++) {
        for (size_t burst_row = 0; burst_row < burst_rows; burst_row++) {
            (mxGetPr(plhs[0]))[burst_row + p_row*burst_rows] =
            out_matrix[p_row][burst_row];
        }
    }

    // Clean up.
    // Explicit destroy the Thread objects.
    for (int i=0; i < num_cores; i++) {
        CloseHandle( thread_list[i] );
    }
    freeMultiArray(&out_matrix, p_rows);
    free(thread_list);
    free(thread_id);
    free(thread_data_list);
    free(thread_data);
}
