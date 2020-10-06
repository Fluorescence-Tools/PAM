/* eval_prob_3c_bg.c - Evaluate probabilty for 3-Color PDA after 
 *       blue and green excitation
 *
 *========================================================*/

 /* For Matlab interaction */
#include "mex.h"

 /* Standard c libs */
#include <stdio.h>                       
#include <stdlib.h>
// #include <stddef.h>
// #include <limits.h>
#include <string.h>
#include <errno.h>

#include "sys/memalloc.h"                           /* Memory allocation */
#include "randist/randist.h"                        /* Statistical distributions */
//#include "randist/sys/sys.h"                      /* For log1p before C99 */
#include "randist/sys/minmax.h"                     /* Minimum/Maximum Makro */
#include "sys/numcores.h"                           /* Determine Number of Cores */
#include "sys/tcpda.h"                              /* Data Structure of Calculations */

 /* For Multi-Threading */ 
#ifdef _WIN32
#include <windows.h>                                /* for HANDLE Definition */
#include <process.h>                                /* THREAD api */
#else                                               /* i.e. "__APPLE__" and "__linux__" */
#include <unistd.h>
#include <pthread.h>                                /* pthreads api */
#endif

 /* Constants */
#define NUM_CORES get_number_of_cores();            /* Set number of worker threads
                                                     * here dynamically */

#ifdef _WIN32
static unsigned __stdcall eval_prob_3c_bg(void *data);      // stdcall necessary for MSVC
#else
void *eval_prob_3c_bg(void *data);                          // cdecl for POSIX (pthreads)
#endif


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

    double **out_matrix;                        /* Calculated results, 2D double matrix */
    
    size_t burst_cols, burst_rows;              /* Dimension of Burst Arrray */
    size_t p_cols, p_rows;                      /* Dimension of P Array */
    
#ifdef WIN32
    HANDLE *thread_list;                        // Handles to the worker threads
    unsigned int *thread_id;                    // Thread IDs for worker threads
#else /* POSIX using pthreads (OS X and Linux) */
    pthread_t *thread_list;                        // Handles to the worker threads
#endif
    tcpda_data *thread_data_list;               // TCPDA data for worker threads
    //int num_cores = get_number_of_cores();      // Number of parallel threads
    int num_cores = NUM_CORES;                  // Number of parallel threads

    
    /* get dimensions of the burst matrices */
    burst_cols = mxGetN(prhs[0]);
    burst_rows = mxGetM(prhs[0]);
    
    /* get dimensions of the p matrix */
    p_cols = mxGetN(prhs[15]);
    p_rows = mxGetM(prhs[15]);

#ifdef WIN32
    // reserve room for handles for our worker threads
    thread_list = (HANDLE*)malloc(num_cores * sizeof( HANDLE ));
    
    // reserve room for thread_ids for our worker threads
    thread_id = (unsigned int*)malloc(num_cores * sizeof( unsigned int ));
#else
    // reserve room thread references for our worker threads
    thread_list = (pthread_t*)malloc(num_cores * sizeof( pthread_t ));
#endif
   
    // reserve room for the tcpda data strcutres
    thread_data_list = (tcpda_data*)malloc(num_cores * sizeof( tcpda_data ));    
    
    /* create a data structure on the heap for the working threads.
     * we simply assign the pointers, so we don't need to copy the whole
     * for every thread. */
    tcpda_data *thread_data;    
    thread_data = malloc(sizeof(tcpda_data));
    if(!thread_data) { 
            fprintf(stderr, "Memory allocation failed\n",
                strerror (errno));
            exit (EXIT_FAILURE);
    }
    
    /* Allocate continuous temporary memory for computed results.
     * This is necessary since the Matlab API (mex.h) is not Thread-
     * safe for writing with multiple threads (-> corrupted results, crash).
     * Make sure we get a continuouse chunk of space, so we can simply
     * memcpy the whole data back with a single instruction using SIMD */
    out_matrix = allocate_2d(p_rows, burst_rows);
    
    /* Setup the pointers to the proper vaules in our tcpda_data data
     * struct. */
    
    /* Bursts  */
    thread_data->fbb = mxGetPr(prhs[0]);    /*Sets "fbb" to be the first of the input values*/
    thread_data->fbg = mxGetPr(prhs[1]);
    thread_data->fbr = mxGetPr(prhs[2]);
    thread_data->fgg = mxGetPr(prhs[3]);
    thread_data->fgr = mxGetPr(prhs[4]);
    
    /* Backgrounds  */
    thread_data->NBGbb = mxGetScalar(prhs[5]);  /*Sets "NBGbb" to be the sixth of the input values*/
    thread_data->NBGbg = mxGetScalar(prhs[6]);
    thread_data->NBGbr = mxGetScalar(prhs[7]);
    thread_data->NBGgg = mxGetScalar(prhs[8]);
    thread_data->NBGgr = mxGetScalar(prhs[9]);    

    thread_data->BGbb = mxGetPr(prhs[10]);
    thread_data->BGbg = mxGetPr(prhs[11]);
    thread_data->BGbr = mxGetPr(prhs[12]);
    thread_data->BGgg = mxGetPr(prhs[13]);
    thread_data->BGgr = mxGetPr(prhs[14]);
   
    /* Probabilities */
    thread_data->p_bb = mxGetPr(prhs[15]);
    thread_data->p_bg = mxGetPr(prhs[16]);
    thread_data->p_gr = mxGetPr(prhs[17]);

    /* get dimensions of the burst matrices */
    thread_data->burst_cols = mxGetN(prhs[0]);
    thread_data->burst_rows = mxGetM(prhs[0]);
    
    /* get dimensions of the p (Probabilities) matrix */
    thread_data->p_cols = mxGetN(prhs[15]);
    thread_data->p_rows = mxGetM(prhs[15]);
    
    /* set a pointer to our temporary space for evaluted results */
    thread_data->out_matrix = out_matrix;
    
    /* Used for calculation, see in the caluclation routine for more */
    thread_data->num_cores = num_cores;
    
    /* create and start the working threads */
    
    /* Here we create one tcpda data struct for every thread.
     * Since most of them only contain pointers, we don't waste memory.
     * Every data struct for every thread gets an unique ID, so we can
     * use this ID to assign specific calculation tasks to each thread.
     * Doing so, we don't need to syncronize the task for writing the 
     * results */ 
#ifdef WIN32
    for (int i=0; i < num_cores; i++) {
        memcpy (&thread_data_list[i], thread_data, sizeof (tcpda_data));
        thread_data_list[i].thread_id = i;
        thread_list[i] = (HANDLE)_beginthreadex(
            NULL,                     /* Thread security */
            0,                        /* Thread stack size */
            &eval_prob_3c_bg,         /* Thread starting address - address of function*/
            (void *) &thread_data_list[i],     /* Thread arguments, our tcpda data struct.
                                                * Sorry for the (void *) casts, but thats
                                                * all we can pass to _beginthreadex() */
            0,                        /* Create threads in running state */
            &thread_id[i]);           /* Thread ID */
        if (thread_list[i] == INVALID_HANDLE_VALUE) {
            // Handle Error
            fprintf(stderr, "Error creating thread\n");
            abort();
        }
    }

    /* wait for threads (calculation) to finish before we continue */
    WaitForMultipleObjects(num_cores, thread_list, TRUE, INFINITE);
#else
    for (int i=0; i < num_cores; i++) {
        memcpy (&thread_data_list[i], thread_data, sizeof (tcpda_data));
        thread_data_list[i].thread_id = i;
        if (pthread_create(
            &thread_list[i],                    /* thread reference */
            NULL,                               /* extra attributes for the thread */
            eval_prob_3c_bg,                   /* Pointer to the function call (entry point) */
            (void *) &thread_data_list[i]))     /* Thread arguments, our tcpda data struct. */  
        {
            fprintf(stderr, "Error creating thread\n");
            abort();
        }
    }
    
    /* wait for threads (calculation) to finish before we continue */
    for (int i=0; i < num_cores; i++) {
        pthread_join(thread_list[i], NULL);  
    }
#endif
    
    /* Check for successfull exit codes */

    
    /* create the output 2-D double array */
    plhs[0] = mxCreateDoubleMatrix((mwSize)burst_rows,(mwSize)p_rows,mxREAL);
    
    /* get the evaluated data back into matlab */
    memcpy(mxGetPr(plhs[0]), *out_matrix, sizeof(double) * p_rows * burst_rows);    
      
    /* Maybe faster with memcpy, but 2 dimensional array? We used multiply
     * allocates, so there is no guarantee that the memory is continuous */
//     for (size_t p_row = 0; p_row < p_rows; p_row++) {
//         for (size_t burst_row = 0; burst_row < burst_rows; burst_row++) {
//             (mxGetPr(plhs[0]))[burst_row + p_row*burst_rows] =
//             out_matrix[p_row][burst_row];
//         }
//     }
    
#ifdef WIN32
    /* Clean up. */
    /* Explicit destroy the Thread objects. */
    for (int i=0; i < num_cores; i++) {
        CloseHandle( thread_list[i] );
    }
#endif
    
    /* Free up the memory, make sure we don't leak */
    free_2d(out_matrix, p_rows);
    free(thread_list);
#ifdef WIN32
    free(thread_id);
#endif
    free(thread_data_list);
    free(thread_data);
}

 /* The computational routine */
#ifdef WIN32
static unsigned __stdcall eval_prob_3c_bg(void *data)   // stdcall necessary for MSVC
#else
void *eval_prob_3c_bg(void *data)                       // cdecl for POSIX (pthreads)
#endif
{
    /* restore the data from the thread argument. */
    tcpda_data *thread_data = (tcpda_data *) data;
    
    /* Memory for temp. calculation results */
    double **P_binomial;              // bionomal results
    double **P_trinomial;             // trinomal results
    P_binomial = allocate_2d(thread_data->p_rows, thread_data->burst_rows);
    P_trinomial = allocate_2d(thread_data->p_rows, thread_data->burst_rows);    
    
    /* Calculate the probability */

    /* Loop over all the probabilities */
    for (size_t i=0; i < thread_data->p_rows; i++) {
        
        /* blue-red = blue-blue - blue-green */
        double p_br = 1 - thread_data->p_bb[i] - thread_data->p_bg[i];
        
        /* Loop over all bursts.
         * Here, we split up the work equally for the calculation threads
         * using the Thread ID in the data struct.
         * Every thread calculates the i+NUM_CORES'th Probabilies, so we
         * don't have to lock and synconize the threads for writing the
         * results, since the order does not matter and no race conditions
         * can occur.
         * For example: 6 (0-5) caluculation threads are available, thread 
         * 0 calculates the probabilites for 0, 6, 12, 18, .. bursts.
         */
        for (size_t j=thread_data->thread_id; j<thread_data->burst_rows; j=j+thread_data->num_cores) {
            
            /* trinomal calculation */
            size_t bg_bb;
            for (size_t a=0; a <= MIN(thread_data->fbb[j], thread_data->NBGbb) ; a++) {
                bg_bb = a;
                size_t bg_bg;
                for (size_t b=0; b <= MIN(thread_data->fbg[j], thread_data->NBGbg) ; b++) {
                    bg_bg = b;
                    size_t bg_br;
                        for (size_t c=0; c <= MIN(thread_data->fbr[j], thread_data->NBGbr) ; c++) {
                        bg_br = c;
                        
                        double background[3] = {thread_data->p_bb[i], thread_data->p_bg[i], p_br};
                        const unsigned int bursts[3] = {
                            (unsigned int) thread_data->fbb[j] - bg_bb,
                            (unsigned int) thread_data->fbg[j] - bg_bg,
                            (unsigned int) thread_data->fbr[j] - bg_br};

                        P_trinomial[i][j] = P_trinomial[i][j] +  // cumulative sum
                                thread_data->BGbb[bg_bb] *       // Background
                                thread_data->BGbg[bg_bg] *
                                thread_data->BGbr[bg_br] *         
                                ran_multinomial_pdf(3,background,bursts);
                        }
                }
            }

            /* bionomal calculation */

            size_t bg_gg;
            for (size_t a=0; a <= MIN(thread_data->fgg[j], thread_data->NBGgg) ; a++) {
                bg_gg = a;
                size_t bg_gr;
                for (size_t b=0; b <= MIN(thread_data->fgr[j], thread_data->NBGgr) ; b++) {
                    bg_gr = b;
                    
                   /* Subtract Background counts for FRET evaluation */
                   P_binomial[i][j] = P_binomial[i][j] +             // cumulative sum
                           thread_data->BGgg[bg_gg] *
                           thread_data->BGgr[bg_gr] *
                           ran_binomial_pdf((unsigned int)(thread_data->fgr[j] - bg_gr) ,
                           thread_data->p_gr[i], 
                           (unsigned int) (thread_data->fgr[j] - bg_gr + thread_data->fgg[j] - bg_gg) );
                }
            }
        }
    }

    /* multiply elementwise P_binomal by P_trinomal and fill the output array */
    for (size_t i=0; i < thread_data->p_rows; i++) {
        for (size_t j=thread_data->thread_id; j<thread_data->burst_rows; j=j+thread_data->num_cores) {
            thread_data->out_matrix[i][j] = P_binomial[i][j] * P_trinomial[i][j];
        }
    }
        
    /* Clean up */
    free_2d(P_binomial, thread_data->p_rows);
    free_2d(P_trinomial, thread_data->p_rows);
    
    return 0;
}
