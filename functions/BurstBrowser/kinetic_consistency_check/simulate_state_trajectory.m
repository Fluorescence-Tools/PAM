function states = simulate_state_trajectory(dynamic_rates,simtime,frequency)
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
%%%                     matrix. Given in Hz.
%%%
%%% Output parameters:
%%% states          -   state sequence evaluated at every step


% input check
if nargin < 3
    disp('Not enough inputs given. Requires 3 inputs.');
    return;
end
if size(dynamic_rates,1) ~= size(dynamic_rates,2)
    disp('Rate matrix must be square.');
    return;
end

% convert simTime to number of TimeSteps
timesteps = ceil(simtime * frequency);

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
% ensure that p is a row vector
if size(p_eq,1) > size(p_eq,2)
    p_eq = p_eq';
end
% roll initial state based on equlibrium distribution
initial_state_random = mnrnd(1,p_eq);
initial_state = find(initial_state_random,1,'first')-1;
% generate seed
seed = randi([1,2^20],1);
% simulate states
states = dyn_sim_state_trajectory(timesteps,n_states,p,initial_state,seed);
% convert to double and revert to matlab indexing starting at 1
states = double(states)+1;