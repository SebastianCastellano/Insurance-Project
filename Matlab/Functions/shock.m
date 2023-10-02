function [table_results] = shock(T,RFR,S0,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx,t_px,lx,BOF_base,fix_cost, inflation, expenses, comm_rate, perc_prem, MASS)
% Evaluate BOF, delta_BOF and duration of the shock
% 
% INPUT
% T = maturity of policy
% RFR = column vector of Spot Rates from time 1 to T
% S0 = initial value of Equity
% sigma = volatility for GBM
% Nsim = number of simulation for MonteCarlo
% steps_per_year = number of time steps per year for MC simulation
% C0 = insured capital
% fee_rate = rate of fee tax payed each year
% qx = column vector of mortality rate from age x to age x+T-1
% t_px = column vector of survival probability from age x (to reach each age)
% lx = flat annual lapse rate
% BOF_base = Base scenario BOF
% fix_cost = cost per benefit payment
% inflation = annual inflation rate
% expenses = annual expenses
% comm_rate = rate of commissions
% perc_prem = value to multiply the premium given in case of death
% MASS = control variable for MASS risk
% 
% OUTPUT
% table_results = table with BOF, deltaBOF and duration for the shock

% equity 
S = equity(S0, T, RFR, sigma, Nsim, steps_per_year);

%Capitals
[C_lapse, C_death,  C_expenses, C_comm] = capital(C0, S, T, Nsim, fee_rate, perc_prem, ...
    fix_cost, inflation, expenses, comm_rate);
Capitals = [C_lapse; C_death; C_expenses; C_comm];

% Liabilities and their duration
if (nargin == 17)
    [V_t_shock, dur_shock] = liabilities(Capitals, T, qx, t_px, RFR, lx);   
elseif (nargin == 18)
    [V_t_shock, dur_shock] = liabilities_MASS(Capitals, T, qx, t_px, RFR, lx); 
end

% Fund value
F = S0;
% BOF shock and deltaBOF 
BOF_shock = F - V_t_shock;
delta_BOF = max(0,BOF_base-BOF_shock);

table_results = table(BOF_shock,delta_BOF,dur_shock,...
                      'VariableNames',{'BOF','dBOF','Duration'});

end