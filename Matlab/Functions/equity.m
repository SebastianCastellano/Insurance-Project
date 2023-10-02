function S = equity(S0, T, spot, sigma, Nsim, steps_per_year)
% Compute the equity value for T years using GBM and MC method
%
% INPUTS
% S0 = initial value of Equity
% T = time to maturity
% spot = column vector of Spot Rates from time 1 to T
% sigma = volatility for GBM
% Nsim = number of simulation for MonteCarlo
% steps_per_year = number of time steps per year for MC simulation
% 
% OUTPUT
% S = matrix of Equity prices from time 0 to T (Nsim rows, T+1 columns)

subyear = 1/steps_per_year;    % fraction of year for simulation
r = interp1(0:T,[0;spot],0:subyear:T);
f = fwd(r, subyear, T);

% Equity simulation
T_periods = T*steps_per_year + 1;
S_period = zeros(Nsim,T_periods);    % vector stock prices
S_period(:,1) = S0;
rng('default'); % for reproducibility
Z = randn(Nsim, T_periods); % matrix normal random variable
for i = 1:(T_periods-1)
    S_period(:,i+1) = S_period(:,i).*exp( (f(i+1)-sigma^2/2)*subyear + sigma*sqrt(subyear)*Z(:,i));
end
idx_year = 1:steps_per_year:T_periods;
S = S_period(:,idx_year);
end