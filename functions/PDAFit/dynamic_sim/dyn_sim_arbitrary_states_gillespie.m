function time_in_states_gillespie = dyn_sim_arbitrary_states_gillespie(dynamic_rates,SimTime,number_of_timewindows)

% input check
if nargin < 3
    disp('Not enough inputs given. Requires 3 inputs.');
    return;
end
if size(dynamic_rates,1) ~= size(dynamic_rates,2)
    disp('Rate matrix must be square.');
    return;
end

% get number of states
n_states = size(dynamic_rates,1);
% obtain equlibrium distribution by solving K*p_eq = 0 and sum(p_eq) = 1
dynamic_eq = dynamic_rates;
for i = 1:n_states
    dynamic_eq(i,i) = -sum(dynamic_rates(:,i));
end
dynamic_eq(end+1,:) = ones(1,n_states);
b = zeros(n_states,1); b(end+1) = 1;
p_eq = dynamic_eq\b;
% ensure that p is a row vector
if size(p_eq,1) > size(p_eq,2)
    p_eq = p_eq';
end
% roll initial state based on equlibrium distribution
initial_state_random = mnrnd(1,p_eq,number_of_timewindows);

% preallocation while loop
R_max = 3;

% random numbers for state change
rand_nums = rand(1,number_of_timewindows*R_max+1);

% random numbers for dwell times

dwelltimes = 1 ./ dynamic_rates * 1000;
dwelltimes(isinf(dwelltimes)) = 0;
dynD_tot = sum(dwelltimes);

switch n_states
    case 2
        % preallocation for loop
        time_in_states_gillespie = zeros(number_of_timewindows,2);
        
        tau_rnd = [exprnd(dynD_tot(1,1),[1,number_of_timewindows*R_max+R_max]);...
            exprnd(dynD_tot(1,2),[1,number_of_timewindows*R_max+R_max])];
        
        states = [1;2];
        
        for i = 1:number_of_timewindows
            %nn = find(initial_state_random(i,:),1,'first'); % initial state
            nn = initial_state_random(i,:) * states;
            nn_store = zeros(1,R_max);
            tau = zeros(1,R_max);
            tt = 0; % time
            R_count = 0; % state change counter

            while tt < SimTime % simulate state changes for R_max changes
                R_count = R_count + 1;

                %tau(R_count) = exprnd(dynD_tot(1,nn));
                tau(R_count) = tau_rnd(nn,(i-1)*R_max+R_count);

                tt = tt + tau(R_count);
                
                nn_store(R_count) = nn;
                
                if tt > SimTime
                    tau(R_count) = SimTime - (tt-tau(R_count));
                    break
                end
                if nn == 1
                    nn = nn + 1;
                else
                    nn = nn - 1;
                end
            end
            time_in_states_gillespie(i,:) = [sum(tau(nn_store == 1)),sum(tau(nn_store == 2))];
        end
        
    case 3
        % preallocation for loop
        time_in_states_gillespie = zeros(number_of_timewindows,3);
        
        tau_rnd = [exprnd(dynD_tot(1,1),[1, number_of_timewindows*R_max+R_max]);...
            exprnd(dynD_tot(1,2),[1, number_of_timewindows*R_max+R_max]);...
            exprnd(dynD_tot(1,3),[1, number_of_timewindows*R_max+R_max])];

        state_changes = [NaN,  -1,  -2; 
                          +1, NaN,  -1;
                          +2,  +1, NaN];
                    
        change_prob = cumsum(dwelltimes);
        change_prob = change_prob ./ change_prob(end,:);
        change_prob(2,2) = 0; change_prob(3,3) = 0;
        
        for i = 1:number_of_timewindows
            nn = find(initial_state_random(i,:),1,'first'); % initial state
            nn_store = zeros(1,R_max+1);
            tau = zeros(1,R_max+1);
            tt = 0; % time
            R_count = 0; % state change counter

            while tt < SimTime % simulate state changes for R_max changes
                R_count = R_count + 1;

                tau(R_count) = tau_rnd(nn,(i-1)*R_max+R_count);
                
                s = state_changes(change_prob(:,nn) > rand_nums(1,(i-1)*R_max+R_count),nn);
                
                tt = tt + tau(R_count);
                
                nn_store(R_count) = nn;
                
                if tt > SimTime
                    tau(R_count) = SimTime - (tt-tau(R_count));
                    break
                end
                nn = nn + s(1);
            end
            time_in_states_gillespie(i,:) = [sum(tau(nn_store == 1)),sum(tau(nn_store == 2)),sum(tau(nn_store == 3))] ./ SimTime;
        end
end
end