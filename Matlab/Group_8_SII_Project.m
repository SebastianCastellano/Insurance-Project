%% Insurance Project

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Group 8:
%   Sebastian Castellano
%   Giulia Mulattieri
%   Virginia Muscionico
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data

clear; close all; clc;

addpath(genpath('.')) 

% load ISTAT 2021 life tables
load('Life_Tables_2021.mat');

% load risk free rates
load('RiskFreeRate_IT_NOVA310322.mat');

% get RFR vectors
RFR_NOVA = RFR_NOVA(:,2);
RFR_NOVA_UP = RFR_NOVA_UP(:,2);
RFR_NOVA_DW = RFR_NOVA_DW(:,2);


%% Parameters

C0 = 100000;         % insured capital
T = 50;              % maturity of policy

S0 = 100000;         % initial value of Equity
sigma = 0.25;        % volatility for GBM

x = 60;              % policy holder (man) initial age
lx = 0.15;           % flat annual lapse rate
Nsim = 1e+6;         % number of simulation for GBM
steps_per_year = 5;  % number of time steps per year for MC simulation
fee_rate = 0.02;     % RD
perc_prem = 1.1;     % percentual increase w.r.t. premium in death benefit 
inflation = 0.02;    % annual inflation rate
expenses = 50;       % annual expense per policy
comm_rate = 0.014;        % annual commissions
fix_cost = 20;       % fixed cost every time a benefit is paid   


%% "What if?" cases

% % upward parallel shift of 100bps
% RFR_NOVA = RFR_NOVA + 0.01;
% RFR_NOVA_UP = RFR_NOVA_UP + 0.01;
% RFR_NOVA_DW = RFR_NOVA_DW + 0.01;
% 
% % downward parallel shift of 100bps
% RFR_NOVA = RFR_NOVA - 0.01;
% RFR_NOVA_UP = RFR_NOVA_UP - 0.01;
% RFR_NOVA_DW = RFR_NOVA_DW - 0.01;
% 
% % increased insured age
% x = 80;
% 
% % female model point
% LT_M = LT_F;


%% Mortality rate and Survival probability

% index of the insured person age
i = x+1;

% mortality rate from age x to age x+T-1
qx = 1 - (LT_M{i+1:x+T+1,2}./LT_M{i:x+T,2});

% survival probability from x
t_px = LT_M{i:x+T,2}./LT_M{i,2};

%% Assets

% equity 
S = equity(S0, T, RFR_NOVA(1:T), sigma, Nsim, steps_per_year);


%% Liabilities

% Capitals to be payed
[C_lapse, C_death, C_expenses, C_comm] = capital(C0, S, T, Nsim, fee_rate, ...
    perc_prem, fix_cost, inflation, expenses, comm_rate);

Capitals = [C_lapse; C_death; C_expenses; C_comm];

% Liabilities and their duration
[V_t, dur] = liabilities(Capitals, T, qx, t_px, RFR_NOVA(1:T), lx);   

F = S0;
BOF_base = F - V_t;

table_Base_scenario = table(BOF_base,dur,...
                      'VariableNames',{'BOF','Duration'});


%% IR_UP and IR_DOWN

[table_IR_UP] = shock(T,RFR_NOVA_UP(1:T),S0,sigma,...
    Nsim,steps_per_year,C0,fee_rate,qx,t_px,lx,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

[table_IR_DW] = shock(T,RFR_NOVA_DW(1:T),S0,sigma,...
    Nsim,steps_per_year,C0,fee_rate,qx,t_px,lx,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

%% Stock

S0_stock = S0 * (1-0.39);
[table_Stock] = shock(T,RFR_NOVA(1:T),S0_stock,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx,t_px,lx,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

%% Life Mortality Risk

% constant 15% shock in mortality rate
qx_mort = qx*1.15;
t_px_mort = zeros(T,1);
t_px_mort(1) = 1;
for i=2:T
    t_px_mort(i) = t_px_mort(i-1)*(1-qx_mort(i-1));
end
[table_Mortality] = shock(T,RFR_NOVA(1:T),S0,sigma,...
    Nsim,steps_per_year,C0,fee_rate,qx_mort,t_px_mort,lx,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

%% Life Lapse Risk

% case upward shock
lx_up = min( 1.5*lx, 1);

[table_Lapse_UP] = shock(T,RFR_NOVA(1:T),S0,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx,t_px,lx_up,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

% case downward shock
lx_dw = max( 0.5*lx, lx-0.2);
[table_Lapse_DW] = shock(T,RFR_NOVA(1:T),S0,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx,t_px,lx_dw,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

%% MASS

MASS = 1; %control variable for use liabilities_MASS in shock function
[table_MASS] = shock(T,RFR_NOVA(1:T),S0,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx,t_px,lx,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem, MASS);

%% Life Catastrophy Risk

% catastrophy shock
qx_cat = qx + 0.0015*[1; zeros(length(qx)-1,1)];
t_px_cat = zeros(T,1);
t_px_cat(1) = 1;
for i=2:T
    t_px_cat(i) = t_px_cat(i-1)*(1-qx_cat(i-1));
end
[table_CAT] = shock(T,RFR_NOVA(1:T),S0,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx_cat,t_px_cat,lx,BOF_base, fix_cost, ...
    inflation, expenses, comm_rate, perc_prem);

%% Expenses risk

expenses = expenses *1.1;
inflation = inflation + 0.01;
[table_Expenses] = shock(T,RFR_NOVA(1:T),S0,sigma,Nsim,steps_per_year,C0,fee_rate,...
    qx,t_px,lx,BOF_base, fix_cost, inflation, expenses, comm_rate, perc_prem);

%% Market SCR

SCR_IR = max(table_IR_UP.dBOF(1),table_IR_DW.dBOF(1));
updw = (table_IR_UP.dBOF(1) > table_IR_DW.dBOF(1));

SCR_equity = table_Stock.dBOF(1);

%% LIFE SCR

SCR_mort = table_Mortality.dBOF(1);

SCR_Lapse = max([table_Lapse_UP.dBOF(1), table_Lapse_DW.dBOF(1), table_MASS.dBOF(1)]);

SCR_CAT = table_CAT.dBOF(1);

SCR_exp = table_Expenses.dBOF(1);

%% Basic SCR

[BSCR, table_SCR] = bscr(SCR_IR, updw, SCR_equity, SCR_mort, SCR_Lapse, SCR_CAT, SCR_exp);




