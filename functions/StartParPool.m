function StartParPool()
global UserValues
%%% Initializes matlabpool for parallel computation
%%%
%%% To use parallel computation in your code, call this function at the
%%% beginning of your code
%%%
%%% User parfor loops with the optional argument given by
%%% UserValues.Settings.Pam.ParallelProcessing
%%% i.e.
%%%     parfor (i=1:100,UserValues.Settings.Pam.ParallelProcessing)
%%%         DoSomething();
%%%     end
%%%
%%% UserValues.Settings.Pam.ParallelProcessing is either 0 or Inf,
%%% thus the parfor loop uses either only the main worker or all available
%%% workers
if ~(UserValues.Settings.Pam.ParallelProcessing == 0)
    Pool=gcp('nocreate');
    if isempty(Pool)
        parpool('local',UserValues.Settings.Pam.NumberOfCores);
    else
        %%% pool exists, check if number of workers agrees with defined value
        if ~(UserValues.Settings.Pam.NumberOfCores==Pool.NumWorkers)
            delete(Pool);
            parpool('local',UserValues.Settings.Pam.NumberOfCores);
        end
    end        
end