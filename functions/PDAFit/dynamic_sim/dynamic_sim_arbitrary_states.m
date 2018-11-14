function time_in_states = dynamic_sim_arbitrary_states(dynamic_rates,simtime,frequency,number_of_timewindows)
%%% Simulates dynamic system interconverting between size(dynamic_rates,1)
%%% states.
%%%
%%% Input parameters:
%%% dynamic_rates   -   Rate matrix where element ij describes the rate
%%%                     from state i to state j.
%%%                     Rates are given in Hz, i.e. 1/s.
%%%                     Diagonal elements are ignored, as they are
%%%                     recomputed from the off-diagonal elements.
%%%
%%%                     Example:
%%%                     ( 11 21 31 41 )
%%%                     ( 12 22 32 42 )
%%%                     ( 13 23 33 43 )
%%%                     ( 14 24 34 44 )
%%%
%%% simtime         -   Duration of the simulation in seconds.
%%% frequency       -   Probing frequency, i.e. how often the current state
%%%                     is output. This should be at least an order of
%%%                     magnitude higher than the largest rate in the rate
%%%                     matrix. Given in Hz
%%%
%%% Output parameters:
%%% time_in_state1   -   number of time steps spent in state1


% input check
if nargin < 4
    disp('Not enough inputs given. Requires 4 inputs.');
    return;
end
if size(dynamic_rates,1) ~= size(dynamic_rates,2)
    disp('Rate matrix must be square.');
    return;
end
% convert simTime to number of TimeSteps
timesteps = round(simtime * frequency);
%%% convert to probability per step
% Assuming k/f is close to zero, we can approximate:
% pTrans = dynamic_rates./frequency;
% However, this breaks down if k/f is larger.
% The correct formula is:
pTrans = 1-exp(-dynamic_rates./frequency);
% This is the probability of having a transition in the time interval
% deltaT = 1/f for an exponential distribution.
% P(transition) = 1 - P(no transition) = 1 - P_exp(deltaT|k)
%               = 1- exp(-k/f)

% fix possible NaN entries
pTrans(isnan(pTrans)) = 0;

% calculate diagonal elements from off-diagonal elements
% diagonal elements are 1-sum(p_else)
for i = 1:size(pTrans,1)
    pTrans(i,i) = 1-sum(pTrans(:,i));
end

%%% For input to the mex file, the rates must have the following structure:
%%% p = [p11,p12,13,...p21,p22,p23,...p31,p32,p33,...]
p=[];
for i = 1:size(pTrans,1)
    p = [p,pTrans(:,i)'];
end

% get number of states
n_states = size(dynamic_rates,1);
% obtain equlibrium distribution by solving K*p_eq = 0 and sum(p_eq) = 1
for i = 1:n_states
    dynamic_rates(i,i) = -sum(dynamic_rates(:,i));
end
dynamic_rates(end+1,:) = ones(1,n_states);
b = zeros(n_states,1); b(end+1) = 1;
p_eq = dynamic_rates\b;
% roll initial state based on equlibrium distribution
initial_state_random = mnrnd(1,p_eq,number_of_timewindows);
for i = 1:number_of_timewindows
    initial_state(i) = find(initial_state_random(i,:),1,'first')-1;
end
% generate seed
seed = randi([1,2^20],1);
% as a control, get p_eq from long simulation for comparison
% time_in_states = double(dyn_Sim_array_arbitrary_states_mac(1E8,n_states,p,2,seed,1))./1E8;
% -> matrix caclulation works
% simulate states for all time windows
time_in_states = dyn_Sim_array_arbitrary_states_mac(timesteps,n_states,p,initial_state,seed,number_of_timewindows);
time_in_states = reshape(double(time_in_states),[number_of_timewindows,n_states]);
% note: the function returns the sum over the state trajectory.
% Since state1 == 0 and state2 == 1 in C, the functions thus return the
% number of time steps in state2.
% The C function needs to be adapted for 3 or more states!

% return time in state as fraction
time_in_states = time_in_states./timesteps;
