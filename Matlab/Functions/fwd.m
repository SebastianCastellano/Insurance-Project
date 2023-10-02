function [Fwd] = fwd (r, subyear, T)
% Compute the Forward Rates starting from the EIOPA yield curve
%
% INPUTS
% r = column vector of Spot Rates from t=0 to T
% subyear = fraction of year
% T = time to maturity
%
% OUTPUT
% Fwd = column vector of Forward Rates from t=0 to T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t = (0:subyear:T);
n = length(t);
Fwd = zeros(1,n);
Fwd(1) = 0;
for i = 2:n
    Fwd(i) = (r(i)*t(i)-r(i-1)*t(i-1))/(t(i)-t(i-1));
end
end