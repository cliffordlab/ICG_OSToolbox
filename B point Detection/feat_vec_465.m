% ---------------- File to extract feature vector for detecting B point on an ICG signal -----------------
% OVERVIEW:
%    File to extract feature vector for detecting B point from ICG signal
%    Details of feature vector can be found in
%   “Data-Driven Approach for Automatic Detection of Aortic Valve 
%    Opening: B-point Detection from Impedance Cardiogram”
%    Configured to accept synchronized ECG and ICG signals as input file to 
%    produce noise free three-stage ensemble-averaged (EA) ICG signal.

% INPUT:
%    EA ICG beat data prepared using ICG_Noise_Removal/Noise_removal.m. 
%    Demo data available at  B point Detection/Demo Data. 

% OUTPUT: Feature vector for B point detection

% DEPENDENCIES & LIBRARIES:
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_Noise_Removal

% REFERENCE: 
%   Shafa-at Ali Sheikh et al. "Data-Driven Approach for Automatic Detection of Aortic Valve 
%    Opening: B-point Detection from Impedance Cardiogram" (** Details to be added**) 

%	REPO for code:       
%   https://github.com/cliffordlab/ICG_OSToolbox/B point Detection
%
%   REPO for demo data:
%   1. Input data: 
%   https://github.com/cliffordlab/ICG_OSToolbox/B point Detection/Demo Data/Demo_102D3_B_1.mat
%   2. Sample output feature vector:
%   https://github.com/cliffordlab/ICG_OSToolbox/B point Detection/Demo Data/features_final_demo_465.xlsx
%
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information



clc
clear


demo_beat_folder = "ICG_OSToolbox\B point Detection\Demo Data\";
xcel_folder  = demo_beat_folder;

filePattern = fullfile(demo_beat_folder, '*.mat');     % Change to whatever pattern you need.
Files = dir(filePattern);
Rec_feat = struct();

for r  =  1:length(Files)

file                 = Files(r);
file_name            = strcat(file.folder,'\',file.name);
feat_output          = importdata(file_name);

beat_id              = char(feat_output.id);
Rec_feat(r).id       = feat_output.id;
Rec_feat(r).subj_id  = string(beat_id(1:5));
feat_icg             = feat_output.feat_icg;
feat_icg_D1          = feat_output.feat_icg_D1;
feat_icg_D1          = feat_icg_D1(1:150);
feat_icg_D2          = feat_output.feat_icg_D2;
feat_icg_D2          = feat_icg_D2(1:149);
feat_icg_D2_sign     = feat_output.feat_icg_D2_sign;  
feat_icg_D2_sign     = feat_icg_D2_sign (1:149);
vel_index            = feat_output.vel_index;           % magnitude C - magnitude B
RC                   = feat_output.RC;
RB_out               = feat_output.RB_out;                  % expert RB

mag_B               = feat_icg(RB_out+1);
mag_C               = vel_index + mag_B;


%% Setting lower and upper limit of phsyiologically valid search-window 
l_lim = 35;
if RC >= 140 
    u_lim = 140;
else
    u_lim = RC;
end
pt6_mag_C = 0.66*mag_C;
pt6_feat_icg = pt6_mag_C - feat_icg(1:u_lim);
sign_pt6_feat_icg = sign(pt6_feat_icg);
pos_to_neg_max = find(sign_pt6_feat_icg == -1);
if isempty(pos_to_neg_max)
    u_lim_max = u_lim;
else
    u_lim_max = pos_to_neg_max(1) - 1;   % for handling double peak, notched C
end
%% Number of zero crossings and last inflection
for_Zing = feat_icg_D2_sign(l_lim: u_lim_max);
id_sign_change = sign(diff(for_Zing));              %1 for positive, 0 for no change, -1, for negative
neg_to_pos_ids = find(id_sign_change == 1);
pos_to_neg_ids = find(id_sign_change == -1);

if isempty(neg_to_pos_ids) 
     RB_infl = 0;
     mag_RB_infl =0;
     mag_C_infl = 0;
     Diff_val_infl = 0;
     Diff_RC_infl = 0;
     neg_to_pos_all = 0;
 else
     neg_to_pos_all = neg_to_pos_ids + l_lim - 1;                               % extracting all negative to positive crossings
     RB_infl_sel = neg_to_pos_all( feat_icg_D1(neg_to_pos_all)>=0 );         % checking inflection from negative to positive crossings
     if isempty(RB_infl_sel)
         RB_infl_mag = [];
     else
         RB_infl_mag = RB_infl_sel(feat_icg(RB_infl_sel)<(pt6_mag_C));     % checking magnitude of inflection 
     end    
     RB_max_infl = max(RB_infl_mag);                                              % farthest inflection point                                      
     if isempty(RB_max_infl) 
         RB_infl = 0;
         mag_RB_infl = 0;
         Diff_RC_infl = RC - RB_infl;      
         mag_C_infl = mag_C - mag_RB_infl;
     else
         RB_infl = RB_max_infl;
         mag_RB_infl = feat_icg(RB_infl);
         mag_C_infl = mag_C - mag_RB_infl;
         Diff_RC_infl = RC - RB_infl;
     end
 end
 
%% 2. maximum of d3Z/dt3

rg_max_D2 = feat_icg_D2(l_lim:u_lim_max);
[~, Index_max_2D] = max(rg_max_D2);
RB_max_2D = Index_max_2D+l_lim -1;
mag_RB_max_2D = feat_icg(RB_max_2D);
mag_C_max_2D = mag_C - mag_RB_max_2D;
Diff_RC_max_2D = RC - RB_max_2D;

%% 3. Last notch index in the proposed Phsyiological search window dz/dt [35: 140] 
 % Initial point selected as 30 because findpeaks require atleast 3 data samples to find notch
for_val = feat_icg(30:u_lim_max);           
[~,trlocs] = findpeaks(-for_val);

if isempty(trlocs)
    RB_val = 0;
    mag_RB_val = 0;
    mag_C_val = 0;
    RB_val_all = 0;
else
    RB_val_all = trlocs + 29 - 1; 
    RB_val_mag = RB_val_all(feat_icg(RB_val_all)< (0.66*mag_C));    
    RB_max_val = max(RB_val_mag);
    if isempty(RB_max_val)
        RB_val = 0;
        mag_RB_val = 0;
        mag_C_val = 0;
    else
        RB_val = RB_max_val;
        mag_RB_val = feat_icg(RB_val);
        mag_C_val = mag_C - mag_RB_val;
    end
    
end
%% Difference from last notch to last inflection and RC
if RB_val == 0
    Diff_val_infl = 0;
    Diff_RC_val = 0;
else
    Diff_val_infl = RB_val - RB_infl;
    Diff_RC_val = RC - RB_val;
end

Rec_feat(r).feat_vec_out = [feat_icg  feat_icg_D1 feat_icg_D2 ...  
                           mag_RB_val mag_RB_infl mag_RB_max_2D mag_C mag_C_val mag_C_infl mag_C_max_2D ...
                           Diff_val_infl Diff_RC_val Diff_RC_infl Diff_RC_max_2D ...
                           RC RB_infl RB_val RB_max_2D RB_out];
                                      
end

%% Saving feature vector in an excel sheet
writetable(struct2table(Rec_feat), strcat(xcel_folder,'features_final_demo_465.xlsx'))


