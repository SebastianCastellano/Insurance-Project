function [bscr,table_scr] = bscr(scr_ir, updw, scr_equity, scr_mort, scr_lapse, scr_cat,  scr_expenses)
% Compute BSCR starting from single SCRs from various risk areas,
%   using the Standard Formula approach
% 
% INPUT:
% scr_ir: SCR for interest risk
% upwd: boolean variable (1 for IR shock UP, 0 for IR shock DW)
% scr_equity: SCR for equity risk
% scr_mort: SCR for life mortality risk
% scr_lapse: SCR for life lapse risk
% scr_cat: SCR for life catastrophy risk
% scr_expenses: SCR for expenses risk 
%
% OUTPUT:
% bscr: BSCR computed starting from single SCRs

% define correlation matrices
risks = [1 0.25; 0.25 1];
market_ir_up = [1 0; 0 1];
market_ir_dw = [1 0.5; 0.5 1];
life = [1 0 0.25 0.25; 0 1 0.25 0.5; 0.25 0.25 1 0.25; 0.25 0.5 0.25 1];

% SCR for market risks
scr = [scr_ir, scr_equity];
if updw == 1
    scr_market = sqrt(scr*market_ir_up*scr');
elseif updw == 0
    scr_market = sqrt(scr*market_ir_dw*scr');
end

% SCR for life risks
scr = [scr_mort, scr_lapse, scr_cat, scr_expenses];
scr_life = sqrt(scr*life*scr');

% BSCR
scr = [scr_market, scr_life];
bscr = sqrt(scr*risks*scr');
table_scr = table(scr_market,scr_life,bscr,'VariableNames',{'SCR Market','SCR Life','BSCR'});

end