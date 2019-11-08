function [Beats_used, B_amp, Bamp_Avg,IBs,IB_Avg] = Bpt_param(EA_icg,Bpoint,Rpk,Cpoint,Xpoint, RorCorX)
% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG".
%    Configured to extract parameters related to B point based on ensemble 
%    averaged (EA) ECG /ICG signals and annotaions.
%   
% INPUTS:
%      EA_icg =  Three - stage ensemble averaged ICG
%      Bpoint = Annotations of B points 
%      Rpk =  Annotations of R peaks 
%      Cpoint = Annotations of C points 
%      Xpoint = Annotations of X points 
%      RorCorX = Text string for reference point 'R', 'C' or 'X'
% OUTPUTS:
%      Beats_used =  Beats used in calculating RB or BX based on features of B
%      B_amp =  Amplitude of all B points
%      Bamp_Avg = mean(B_amp)
%      IBs =  Time difference between RB, or BX points for all beats in an ICG beat
%      IXB_Avg = mean(IBs) 
%
%
% DEPENDENCIES & LIBRARIES:
%   ICG Noise Removal Toolbox
%   https://github.com/cliffordlab/ICG_OSToolbox
%   Function file : RBCX_read.m available at 
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_param_extract

% REFERENCE: 
%   Shafa-at Ali Sheikh et al. "An Open Sourc Toolbox for Automated Removal
%   of Noisy Beats for Accurate ICG Analysis" (** Details to be added**) 

%	REPO for code:       
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_param_extract
%   REPO for demo data:
%   1. Input data: 
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Sample_Annotations_by_ICMAA
%
%   2. Sample output data:
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Sample_Parameters_Extracted
%
%
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information

% This file has been updated on Nov 8, 2019 by Shafa-at Ali Sheikh.

%% 1. Checking reference point 
if RorCorX == 'R'
    Ipoint =  Rpk;
elseif RorCorX == 'C'
    Ipoint =  Cpoint;
elseif RorCorX == 'X'
    Ipoint =  Xpoint;
end
       
no_Ipt =  length(Ipoint);
no_Bpoint = length(Bpoint);

%% 2. compute parameters related to B points 
if (no_Bpoint == 0)                    % for featureless records    
    Beats_used = 0;
    B_amp = 'NaN';
    Bamp_Avg = 'NaN';
    IBs = 'NaN';
    IB_Avg = 'NaN';
elseif (no_Bpoint == no_Ipt)              %no. of R,C or X point = no. of B points
    Beats_used = no_Ipt;
    B_amp = EA_icg(Bpoint);
    Bamp_Avg = mean(B_amp); 
    if RorCorX == 'R'
        IBs = Bpoint - Ipoint;
    elseif (RorCorX == 'C') || (RorCorX == 'X')
        IBs = Ipoint - Bpoint;
    end
    IB_Avg = mean(IBs);  
% special case when feature based B points are not present in record    
elseif (no_Bpoint >=3) && ((no_Bpoint/no_Ipt) >= 0.6)     % no. of B points >3 and ratio greater than 0.6 
    
    B_amp = EA_icg(Bpoint);
    Bamp_Avg = mean(B_amp); 
    IB_cur = zeros(1,no_Ipt);
    
    for nb = 1: no_Ipt
        rg_B = [Rpk(nb) Cpoint(nb)];
        Bpt_cur = Bpoint(Bpoint>= rg_B(1) & Bpoint<= rg_B(2));
        if isempty(Bpt_cur)
            IB_cur(nb) = NaN;
        else
            if RorCorX == 'R'                                           % Ipoint is Rpk
                IB_cur(nb) = Bpt_cur - Ipoint(nb);
            elseif (RorCorX == 'C') || (RorCorX == 'X')
                IB_cur(nb) = Ipoint(nb) - Bpt_cur;                      % Ipoint is C or X point
            end
        end
    end
   
    Beats_used = no_Bpoint;
    IBs = IB_cur;
    IB_Avg = nanmean(IBs);
     
    else                                                            % no. of B points < 3
      B_amp = EA_icg(Bpoint);
      Bamp_Avg = mean(B_amp); 
      IB_cur = zeros(1,no_Ipt);
      for nb = 1: no_Ipt
          rg_B = [Rpk(nb) Cpoint(nb)];
          Bpt_cur = Bpoint(Bpoint>= rg_B(1) & Bpoint<= rg_B(2));
          if isempty(Bpt_cur)
              IB_cur(nb) = 0;
          else
            if RorCorX == 'R'                                           % Ipoint is Rpk
                IB_cur(nb) = Bpt_cur - Ipoint(nb);
            elseif (RorCorX == 'C') || (RorCorX == 'X')
                IB_cur(nb) = Ipoint(nb) - Bpt_cur;                      % Ipoint is C or X point
            end
          end
          Beats_used= no_Bpoint;
          IBs = IB_cur;
          IB_Avg = 'NaN';
      end
end 
end


