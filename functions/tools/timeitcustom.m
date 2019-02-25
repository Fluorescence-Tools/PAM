function [varargout] = timeitcustom(f)
% timeit measures the required time to excute a MATLAB routine by repetitive execution
    % ---------------------------------------------------------------------
    %
    %                           timeitcustom
    %
    % ---------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/timeitcustom.m $
    %
    % ---------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % timeit(F)
    % RequiredT = timeit(F)
    % [RequiredT OverheadT] = timeit(F)
    %
    % DESCRIPTION
    % -----------
    % timeit(F) measures the time (in milliseconds) required to
    % run F, which is a function handle. F should not need any input
    % argument. See Examples how to cope with functions that require input
    % arguments. The function is automatically supplied with the minimal
    % number of required output arguments. The mean required time to
    % execute the function is compared to the overhead time. This is the
    % time necessary to call an empty function. If the mean required time
    % is close to the overhead time, a warning is generated.
    % timeit handles automatically the usual benchmarking procedures of
    % "warming up" F, figuring out how many times to repeat F in a timing
    % loop, etc.  The routine also uses a median to form a reasonably
    % robust time estimate.
    % 
    % RequiredT = timeit(F) returns the mean required time in milliseconds.
    %
    % [RequiredT OverheadT] = timeit(F) returns the minimal overhead time
    % in the second output argument.
    %
    % EXAMPLES
    % --------
    % How much time does it take to compute sum(A.' .* B, 1), where A is
    % 12000-by-400 and B is 400-by-12000?
    % 
    % A = rand(12000, 400);
    % B = rand(400, 12000);
    % f = @() sum(A.' .* B, 1);
    % timeit(f)
    % 
    % How much time does it take to dilate the text.png image with
    % a 25-by-25 all-ones structuring element?
    % 
    % bw = imread('text.png');
    % se = strel(ones(25, 25));
    % g = @() imdilate(bw, se);
    % timeit(g)
    % 
    % MODIFICATIONS
    % -------------
    % 
    % 
    % ACKNOWLEDGEMENTS
    % ----------------
    % This function is based on timeit (Date: 2008/12/31), a MATLAB routine
    % written by Steve Eddins.
    % 
    % Copyright 2008-2014
    % =====================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    chknarg(nargin, 1, nargout, [0 2], mfilename);
    
    % make sure the inpur argument is a function handle
    if ~isa(f, 'function_handle')
        errorbox('The input argument has to be a valid function handle.', 'Invalid function handle', 'id', [mfilename ':InvalidFunctionHandle']);
        
    elseif isdeployed
        % the function is not allowed to run in deployed mode
        warningbox(sprintf('The function %s does not work in deployed mode.', mfilename), 'Deployed mode', 'id', [mfilename ':NotWorkingInDeployedMode']);
        return
        
    end
    
    
    % EXECUTION
    % ---------
    
    % Get the array of output arguments to be used on the left-hand
    % side when calling f
    outputs = outputArray(f);
    
    % get the number of necessary output arguments
    N_outputs = length(outputs);
    
    % Warm up f()
    for m = 1 : 2; [outputs{:}] = f();end;
    
    % Warm up tic/toc.
    tic;temp=toc; %#ok<*NASGU>
    
    % get a rough estimate of the required time
    counter = 0; t1 = tic;
    while toc(t1) < 1
        [outputs{:}] = f(); 
        counter = counter + 1;
    end
    t_rough = toc(t1) / counter;
    
    % Calculate the number of inner-loop repetitions so that 
    % the inner for-loop takes at least about 10ms to execute. The inner
    % loop should execute at least 10 times.
    desired_IL_time = 0.01;
    desired_IL_runs =  10;
    N_IL_iters = max(ceil(desired_IL_time / t_rough), desired_IL_runs);
    
    % Calculate the number of outer-loop repetitions so that the
    % outer for-loop takes at least about 1s to execute.  The outer
    % loop should execute at least 10 times.
    desired_OL_time = 1;
    IL_time = N_IL_iters * t_rough;
    min_OL_iters = 10;
    N_OL_iters = max(ceil(desired_OL_time / IL_time), min_OL_iters);
    
    % If the estimated running time for the timing loops is too long,
    % reduce the number of outer loop iterations.
    if N_OL_iters*IL_time > 15
        % the loops can take not more than 15 seconds
        N_OL_iters = max(ceil(15 / IL_time), 3);
    end
    
    % allocate memory
    ExeTimes = zeros(N_OL_iters,1);
    
    % Coding note: An earlier version of this code constructed an "outputs" cell
    % array, which was used in comma-separated form for the left-hand side of
    % the call to f().  It turned out, though, that the comma-separated output
    % argument added significant measurement overhead.  Therefore, the
    % zero-output-arg, one-output-arg, two-output-arg, three-output-arg and
    % four-output-arg cases were hard-coded into the separate branches of a
    % switch-case statement
    
    switch N_outputs
        case 0 % zero-output-arg case
            % time the function
            for k = 1:N_OL_iters
                t1 = tic;
                for p = 1:N_IL_iters
                    f();
                end
                ExeTimes(k) = toc(t1);
            end
        case 1 % one-output-arg case
            % time the function
            for k = 1:N_OL_iters
                t1 = tic;
                for p = 1:N_IL_iters
                    Otpt = f();
                end
                ExeTimes(k) = toc(t1);
            end
        case 2 % two-output-arg case
            % time the function
            for k = 1:N_OL_iters
                t1 = tic;
                for p = 1:N_IL_iters
                    [Otpt1 Otpt2] = f(); %#ok<*ASGLU>
                end
                ExeTimes(k) = toc(t1);
            end
        case 3 % three-output-arg case
            % time the function
            for k = 1:N_OL_iters
                t1 = tic;
                for p = 1:N_IL_iters
                    [Otpt1 Otpt2 Otpt3] = f();
                end
                ExeTimes(k) = toc(t1);
            end
        case 4 % four-output-arg case
            % time the function
            for k = 1:N_OL_iters
                t1 = tic;
                for p = 1:N_IL_iters
                    [Otpt1 Otpt2 Otpt3 Otpt4] = f();
                end
                ExeTimes(k) = toc(t1);
            end
        otherwise
            % time the function
            for k = 1:N_OL_iters
                t1 = tic;
                for p = 1:N_IL_iters
                    [outputs{:}] = f();
                end
                ExeTimes(k) = toc(t1);
            end
    end
    
    % claculate the average time and convert from seconds to milliseconds
    t = (median(ExeTimes)/N_IL_iters)*1000;
    
    % measure the time necessary for the function call overhead and convert
    % to milliseconds
    OverheadTime = ((tictocCallTime() / N_IL_iters) + functionHandleCallOverhead(f))*1000;
    
    if t < (5 * OverheadTime)
        warningbox(sprintf(['The measured time for F may be inaccurate because it is close ', ...
                            'to the estimated time-measurement overhead (%.1e ms).  Try ', ...
                            'measuring something that takes longer.'], OverheadTime),...
                   'Time close to overhead time', 'id', [mfilename ':HighOverhead']);
    end
    
    % process the output arguments
    switch nargout
        case 1
            % only the required time is requested
            varargout{1} = t;
            
        case 2
            % both the required time and the overhead information is
            % requested
            
            % return the mean required time in the first output argument
            varargout{1} = t;
            
            % return total overhead time in ms
            varargout{2} = OverheadTime;
        
        case 0
            % no output argument is given
            
            % get the maximal number of digits before the '.'
            N = max([length(num2str(round(t))) length(num2str(round(OverheadTime))) 1]);
            
            % define the number of decimal digits
            D = 4;
            
            % print information to command window
            fprintf(['\n   The mean required time is %*.*f ms.\n'...
                       'The minimal overhead time is %*.*f ms.\n'], N+1+D, D, t, N+1+D, D, OverheadTime);
            
    end
    
end % end of function 'timeit'
% =========================================================================

% SUBFUNCTIONS
%  ------------
%   * outputArray

% -------------------------------------------------------------------------
function outputs = outputArray(f)
    % Return a cell array to be used as the output arguments when calling f.  
    % * If nargout(f) > 0, return a nargout(f)-by-1 cell array so that f is called with
    %   nargout(f) output argument.
    % * If nargout(f) == 0, return a 1-by-0 cell array so that f will be called
    %   with zero output arguments.
    % * If nargout(f) < 0, use try/catch to determine the exact number of output argument
    %   to call f with.
    %   Note: It is not documented (as of R2008b) that nargout can return -1.
    %   However, it appears to do so for functions that use varargout and for
    %   anonymous function handles.  
    
    num_outputs = nargout(f);
    
    if num_outputs < 0
        % varargout is used as output argument or f is an anonymous
        % function
        
        % initialise the output arguments counter
        counter = abs(num_outputs)-1;
        
        while true
            
            % create the output arguments
            a = cell(counter, 1);
            
            try
                
                % evaluate the function handle with 'counter' output
                % arguments'
                [a{:}] = f();
                
                % If the line above doesn't throw an error, then it's OK to call f() with
                % one output argument.
                num_outputs = counter;
                
                break

            catch %#ok<CTCH>
                % If we get here, assume it's because f() needs more than
                % 'counter' output arguments
                counter = counter + 1;
                
            end
            
            if counter > 1000
                
                errorbox(['The function requires more than 1000 output arguments or something else is wrong. '...
                          'The exact number of output arguments could not be determined.'], 'Unknown number of output arguments', 'id', [mfilename ':NOutputDeterminationFailed']);
                
                break
            end
        end
        
    end
    
    outputs = cell(num_outputs, 1);
    
end % end of subfunction 'outputArray'

function t = tictocCallTime
    % Return the estimated time required to call tic/toc.

    % Warm up tic/toc.
    temp = tic; elapsed = toc(temp);
    temp = tic; elapsed = toc(temp);
    temp = tic; elapsed = toc(temp);
    
    % execute the timing 11 times    
    num_repeats = 11;
    
    % allocate memory
    times = zeros(1, num_repeats);

    for k = 1:num_repeats
       times(k) = tictocTimeExperiment();
    end
    
    % take the minimal necessary time
    t = min(times);
    
end % end of subfunction 'tictocCallTime'

function t = tictocTimeExperiment
    % Call tic/toc 100 times and return the average time required.

    % Record starting time.
    t1 = tic;

    % Call tic/toc 100 times.
    for m = 1 : 100
        temp = tic; elapsed = toc(temp);
    end

    % calculate the necessary time
    t = toc(t1) / 100; 
    
end % end of subfunction 'tictocTimeExperiment'

function t = functionHandleCallOverhead(f)
    % Return the estimated overhead, in seconds, for calling a function handle
    % compared to calling a normal function.

    fcns = functions(f);
    if strcmp(fcns.type, 'simple')
        t = simpleFunctionHandleCallTime();
    else
        t = anonFunctionHandleCallTime();
    end

    t = max(t - emptyFunctionCallTime(), 0);
end % end of subfunction 'functionHandleCallOverhead'

function emptyFunction()
    % empty function
    
end % end of subfunction 'emptyFunction'

function t = simpleFunctionHandleCallTime
    % Return the estimated time required to call a simple function handle to a
    % function with an empty body.
    %
    % A simple function handle fh has the form @foo.

    num_repeats = 101;
    % num_repeats chosen to take about 100 ms, assuming that
    % timeFunctionHandleCall() takes about 1 ms.
    times = zeros(1, num_repeats);

    fh = @emptyFunction;

    % Warm up fh().
    fh();
    fh();
    fh();

    for k = 1:num_repeats
       times(k) = functionHandleTimeExperiment(fh);
    end

    t = min(times);
end % end of subfunction 'simpleFunctionHandleCallTime'

function t = anonFunctionHandleCallTime
    % Return the estimated time required to call an anonymous function handle that
    % calls a function with an empty body.
    %
    % An anonymous function handle fh has the form @(arg_list) expression. For
    % example:
    %
    %       fh = @(thetad) sin(thetad * pi / 180)

    num_repeats = 101;
    % num_repeats chosen to take about 100 ms, assuming that timeFunctionCall()
    % takes about 1 ms.
    times = zeros(1, num_repeats);

    fh = @() emptyFunction();

    % Warm up fh().
    fh();
    fh();
    fh();

    for k = 1:num_repeats
       times(k) = functionHandleTimeExperiment(fh);
    end

    t = min(times);
end % end of subfunction 'anonFunctionHandleCallTime'

function t = functionHandleTimeExperiment(fh)
    % Call the function handle fh 1000 times and return the average time required.

    % Record starting time.
    t1 = tic;
    
    for m = 1 : 1000
        fh();
    end
    
    t = toc(t1) / 1000;
    
end % end of subfunction 'functionHandleTimeExperiment'

function t = emptyFunctionCallTime()
    % Return the estimated time required to call a function with an empty body.

    % Warm up emptyFunction.
    emptyFunction();
    emptyFunction();
    emptyFunction();

    num_repeats = 101;
    % num_repeats chosen to take about 100 ms, assuming that timeFunctionCall()
    % takes about 1 ms.
    times = zeros(1, num_repeats);

    for k = 1:num_repeats
       times(k) = emptyFunctionTimeExperiment();
    end

    t = min(times);
end % end of subfunction 'emptyFunctionCallTime'

function t = emptyFunctionTimeExperiment()
    % Call emptyFunction() 1000 times and return the average time required.

    % Record starting time.
    t1 = tic;
    
    for m = 1 : 1000
        emptyFunction();
    end
    
    t = toc(t1) / 1000;
end % end of subfunction 'emptyFunctionTimeExperiment'