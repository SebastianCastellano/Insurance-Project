function [C_lapse_MC,C_death_MC,C_expenses,C_comm_MC] = capital(C0, S, T, Nsim, fee_rate, perc_prem, fix_cost, ...
    inflation, expenses, comm_rate)
% Compute the value of the capital to be paid in the two cases (for T years)
% 
% INPUTS
% C0 = insure capital
% S = matrix of equity values from time 0 to T ((T+1) x Nsim)
% Nsim = number of simulation for GBM
% fee_rate = rate of fee tax payed each year 
% perc_prem = value to multiply the premium given in case of death
% fix_cost = cost per benefit payment
% inflation = annual inflation rate
% expenses = annual expenses
% comm_rate = rate of commissions
%
% OUTPUTS
% Clapse_MC =  Capital to be paid case of lapse with MonteCarlo method
% Cdeath_MC =  Capital to be paid case of death with MonteCarlo method

% fund value (no fees)
F = S;

% fund value (with fees)
F_prime_t = zeros(Nsim,T+1);
F_prime_t(:,1) = F(:,1);
F_prime_t(:,2:end) = F(:,2:end) - fee_rate*F(:,1:end-1);

% capital to be paid, case of lapse
C_lapse_sim = F_prime_t(:,2:end) - fix_cost;
C_lapse_MC = mean(C_lapse_sim,1);
% capital to be paid, case of death
C_death_sim = max(F_prime_t(:,2:end), C0*perc_prem) - fix_cost;
C_death_MC = mean(C_death_sim,1);
% capital to be paid, expenses
C_expenses = expenses*(1+inflation).^(0:(T-1));
% capital to be paid, commission
C_comm_sim = comm_rate*F(:,1:end-1);
C_comm_MC = mean(C_comm_sim,1);
end