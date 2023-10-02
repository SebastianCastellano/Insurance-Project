function [liabilities, duration] = liabilities_MASS(C, T, qx, px, spot, lx)
% Compute the liabilities value for T years in the case of MASS shock
%
% INPUTS
% C = matrix of capital to be paid from time 1 to T (Nsim rows)
% T = time to maturity
% qx = column vector of mortality rate from age x to age x+T-1
% px = column vector of survival probability from age x (to reach each age)
% spot = column vector of Spot Rates from time 1 to T
% lx = flat annual lapse rate
%
% OUTPUT
% liabilities = liabilities valuated in 0, column vector
% duration = duration of the liabilities, column vector

% Capitals
C_lapse = C(1,:);
C_death = C(2,:);
C_expenses = C(3,:);
C_comm = C(4,:);

% discounted (financial and demographic) cash flows
discount_factor = exp(-spot'.*(1:T));
% base_discount = discount * p_survival * p_not_lapse_tillnow (same for every capital)
base_discount = discount_factor.*px'.*(1-lx).^(0:T-1);
base_discount(2:end) = base_discount(2:end)/(1-lx)*(1-0.4);

% Disc_CashFlows_lapse = sum * base_discount * (p_survival*lapse_rate)
Disc_CashFlows_lapse = zeros(1,T);
Disc_CashFlows_lapse(1) = C_lapse(1)*discount_factor(1)*(1-qx(1))*0.4;
Disc_CashFlows_lapse(1:end-1) = C_lapse(1:end-1).*base_discount(1:end-1)  ...
                    .*(1-qx(1:end-1)')*lx;
Disc_CashFlows_lapse(end) = C_lapse(end)*base_discount(end)*(1-qx(end)'); % 100% lapse rate at end
% Disc_CashFlows_death = sum * base_discount * (death_rate)
Disc_CashFlows_death = C_death.*base_discount.*qx';
% Disc_CashFlows_exp = sum * base_discount (automatically paid if we reach the year)
Disc_CashFlows_exp = C_expenses.*base_discount;
% Disc_CashFlows_comm = sum * base_discount (automatically paid if we reach the year)
Disc_CashFlows_comm = C_comm.*base_discount;

Disc_CashFlows = Disc_CashFlows_lapse + Disc_CashFlows_death + Disc_CashFlows_exp + ...
    Disc_CashFlows_comm;

% liabilities
liabilities = sum(Disc_CashFlows);

% durations
duration = sum(Disc_CashFlows.*(1:T))./liabilities; 
end