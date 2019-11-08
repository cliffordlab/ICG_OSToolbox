%% Noise Removal Algorithm

% ---------------- Noise Removal Algorithm for ICG signal -----------------
% OVERVIEW:
%    Main file for "Open source toolbox for removal of noisy beats from ICG"
%    Configured to accept ECG and ICG signals as input file to produce
%    noise free three - stage Ensemble averaged (EA) ICG signal.

% INPUT:
%    ECG and ICG signal under neutral and stress conditions.

% OUTPUT:
%    1. EA ECG signal and three Stage EA ICG signal.
%    2. Beat contribution factor for each three stage EA ICG beat.

% DEPENDENCIES & LIBRARIES:
%    PhysioNet Cardiovascular Signal Toolbox: To detect R peaks.
%    https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%

% REFERENCE: 
%   Shafa-at Ali Sheikh et al. "An Open Sourc Toolbox for Automated Removal
%   of Noisy Beats for Accurate ICG Analysis" (** Details to be added**) 

%	REPO for code:       
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_Noise_Removal
%
%   REPO for demo data:
%   1. Input data: 
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/ECG_ICG_Data
%   2. Sample output data:
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG
%
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information


%% 1. Initialize HRV toolbox for R peak detection
clc,clear

HRVparams = InitializeHRVparams('Noise_removal_ICG'); 
fs = 1000;
lag_thres = 50;                       
HRVparams.Fs = fs;

%% 2. Designate folders for input and ouput data

% Input Folder containing ECG and ICG channels
input_ECG_ICG_Folder = 'D:\Clifford_Lab\1_for_upload\data_for_upload\ECG_ICG_data\';

% Output folder for saving three stage EA ECG and ICG and Beat contribution factor
EA_folder = 'D:\Clifford_Lab\1_for_upload\data_for_upload\EA_ECG_ICG\';        % Destination for Ensemble Averaged data

%% 3. Selecting and loading record

filePattern = fullfile(input_ECG_ICG_Folder, '*.mat'); % Change to whatever pattern you need.
Files = dir(filePattern);
Rec_BCF = struct();                % structure containing BCF of all beats for all records

for r = 1: length(Files)
    baseFileName = Files(r).name;                                    % loading v4 'signal' for extracting the ECG_ICG signal
    fullFileName = fullfile(input_ECG_ICG_Folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);                          
    load(fullFileName)
    ecg = ecg_icg(:,1);                      % Extracting ECG Channel            
    icg = ecg_icg(:,2);                      % Extracting ICG Channel    
    
    EA_name = strcat('EA_',fullFileName(end-13:end-4));    % File name for EA record
    EA_file = strcat(EA_folder,EA_name,'.mat');            % File path for saving EA records
    
    record_id = fullFileName(end-13:end);
    Rec_BCF(r).record_id = record_id;
        
%% 4. Preprocessing:  Passing ICG signal through butterworth 4th order filter

    d_1k = designfilt('bandpassiir','FilterOrder',4, ...
            'HalfPowerFrequency1',0.5,'HalfPowerFrequency2',40, ...
            'SampleRate',1000,'DesignMethod','butter');
    icg = filtfilt(d_1k,icg);

%% 5. Extracting R peaks from ECG signal
    disp('Extracting RR_R peaks ...')
    [~, rr, R_pk, SQIvalue , SQIidx] = ConvertRawDataToRRIntervals(ecg,HRVparams, EA_name); %R_pk = index number of R peaks of ecg data
    
%% 6. Extracting 60 sec non overlapping windows for ensemble averaging
    disp('Computing Ensmeble Averaging ...')
    llim_win = ones(1,1);
    ulim_win = zeros(1,1);
    win_60 = zeros(1,60*fs);     % 60 secs window
    for n  =  1 : ceil(length(ecg)/(60*fs))
        ulim_win(n) = llim_win(n) + 60*fs -1;
        if ulim_win(n) > length(ecg)
            break
        end
        win_60(n,:) = llim_win(n) :ulim_win(n);
        llim_win(n+1) = ulim_win(n) + 1;                 % lower limit for next window of 60 secs
    end

%% 7. Synchronizing 60 sec non overlapping ICG signal using R peaks and median RR interval 
    disp('Synchronizing 60 sec non overlapping ICG signal using R peaks and median RR interval ...')

    % initializing EA variables
    EA_ecg = [];                                      % ensemble averaged ecg
    EA_icg_AXC = [];                                  % Three stage ensemble averaged ICG
    
    % initilizing variables for computation of BCF and beat summary
    BCF = zeros(1,size(win_60,1));                    % BCF for three stage ensemble average beat of all records
    beats_total = zeros(1,size(win_60,1));            %  
    beats_S1_removed = zeros(1,size(win_60,1));       % beats removed in phase 1
    beats_S2_removed = zeros(1,size(win_60,1));       % beats removed in phase 2
    beats_S3_removed = zeros(1,size(win_60,1));       % beats removed in phase 3
    beats_4_Eavg_AXC =zeros(1,size(win_60,1));        % no. of beats used for forming an ensemble averaged ICG beat
    
    
    % use k to select the three stage EAvg_beat 
    for k = 1: size(win_60,1)                                   % size(win_60,1)= Number of 60 sec segments of ecg /icg
        [R_pk_60,~] = intersect(R_pk,win_60(k,:),'stable');     % R_pk_60= index of R peaks in each 60 secs windows 
        RR_60 = diff(R_pk_60);                                  % finding RR interval in each 60 sec windowa                          
        median_RR_60 = ceil(median(RR_60));                     % Median of RR intervals for beat claculation
        llim_beat = 0.15*fs;                                    % default = 0.15 secs for 3149; pr = 0.12 - 0.20 secs : lower limit for beat
        ulim_beat = median_RR_60 - llim_beat;                   % upper limit for beat
        ecg_beat_mat = zeros(1,median_RR_60);                   % initializing for each 60 sec segment
        icg_beat_mat = zeros(1,median_RR_60);                         
        if (R_pk_60(1)-llim_beat) < 0                           % checking first peak ess than 150 ms from the start point
            b_start = 2;
        else
            b_start = 1;
        end
        for b = b_start: length(R_pk_60) - 1                    % Finding beats synchronized with R peaks
            ecg_beat_mat(b,:) = ecg((R_pk_60(b)-llim_beat):(R_pk_60(b) + ulim_beat -1));
            icg_beat_mat(b,:) = icg((R_pk_60(b)-llim_beat):(R_pk_60(b) + ulim_beat -1));
        end
        if (R_pk_60(1)-llim_beat) < 0                           % deleting the first row consisting of all zeros
            ecg_beat_mat(1,:) = [];
            icg_beat_mat(1,:) = [];
        end
    

 %% 8. Implementing three - stage noise removal algo
   
        Lag_value = [];                 % Lag values of ICG beats after deleting noisy beats of stage 1
        Lag_value_X = [];               % Lag values of ICG beats after deleting noisy beats in stage 2 
        Lag_value_S =[];                % Lag vlaues of ICG beats after circshift in stage 3
        Coef_value = [];                % coorelation coefficent between EA_ICG_1 and accumulated beats
        Coef_value_S = [];              % coorelation coefficent between EA_ICG_2 and accumulated beats
        beats_del_1 =[];                % index no of beats delelted in stage 1
        beats_del_2 = [];               % index no of beats delelted in stage 2
        beats_del_3 = [];               % index no of beats deleted in stage 3
        icg_beat_mat_amp = [];          % accumulated icg beats in stage 2 after deleting max_min beats in stage 1
        icg_beat_mat_X = [];            % accumulated icg beats in stage 3 after deleting noisy beats in stage 2
        icg_beat_mat_shifted = [];      % accumulated icg beats in stage 3 with zero lag and after cicrular shifting in stage 3
        icg_beat_mat_corrected = [];    % noise free icg_beats accumulted after stage 3

        %%  Implementation Stage 1: Fine filtering. 
        for m1 = 1:size(icg_beat_mat,1)
            max_amp(m1) = max( icg_beat_mat(m1,:));
            min_amp(m1) = min( icg_beat_mat(m1,:));
            beat_ID_0(m1)= m1;
        end
    
        icg_beat_mat_amp= icg_beat_mat;
    
        for  xa =size(icg_beat_mat,1):-1:1 
            if  (max_amp(xa) < 0.4) || (max_amp(xa) > 3) || (min_amp(xa) < -2)   % threshold for deleting the noisy signal
                icg_beat_mat_amp(xa,:) = [];
                beats_del_1 = [beats_del_1 xa];
            end
        end
        beats_del_1 = sort(beats_del_1);
     
        %% Implementation Stage 2: Coarse Filtering.
    
        if size(icg_beat_mat_amp,1) == 0
            EA_icg1 = zeros(1,size(icg_beat_mat,2));
        elseif size(icg_beat_mat_amp,1) == 1
            EA_icg1 = icg_beat_mat_amp;
        else
            EA_icg1 = mean(icg_beat_mat_amp);                           % computing EA of accumulated ICG beats in 60 secs window  
        end
        
        for m2 = 1:size(icg_beat_mat_amp,1)
            [corrX, lagX] =xcorr(EA_icg1, icg_beat_mat_amp(m2,:));
            [val_X,id_X] = max(corrX);
            Lag_value(m2) = lagX(id_X);    
            R1 = corrcoef(EA_icg1, icg_beat_mat_amp(m2,:));             % finding coorelation coefficent between EA_ICG_1 and accumulated ICG beats
            Coef_value(m2) = R1(1,2);
        end
    
        %  deleting beats by comparing to lag, corr_coef in stage 2
        icg_beat_mat_X= icg_beat_mat_amp;
        for  x =size(icg_beat_mat_amp,1):-1:1 
            if abs(Lag_value(x)) >= lag_thres || Coef_value(x) <= 0.5  % threshold for deleting the noisy ICG beats
                icg_beat_mat_X(x,:) = [];
                beats_del_2 = [beats_del_2 x];
            end
        end
        beats_del_2 = sort(beats_del_2);    
        
        %% Implementing Stage 3: Fine filtering.
        if  size(icg_beat_mat_X,1) == 0
            EA_icg_X = zeros(1,size(icg_beat_mat_X,2));
        elseif size(icg_beat_mat_X,1) == 1
             EA_icg_X = icg_beat_mat_X;           
        else
             EA_icg_X = mean(icg_beat_mat_X);     % EA ICG after deleting coarse filtering 
        end
        
        for m3 = 1:size(icg_beat_mat_X,1)
            [corr, lag] =xcorr(EA_icg_X, icg_beat_mat_X(m3,:));
            [~,id] = max(corr);
            Lag_value_X(m3) = lag(id);                                                      % lag values after deleting noisy beats
            icg_beat_mat_shifted(m3,:)= circshift(icg_beat_mat_X(m3,:),Lag_value_X(m3));    % circularshift by lag value
            [S_corr, S_lag] =xcorr(EA_icg_X, icg_beat_mat_shifted(m3,:));                   %  checking corr and lag after circshifting of icg_beats
            [val,S_id] = max(S_corr);
            Lag_value_S(m3) = S_lag(S_id);                                                  % lag values after shifting icg_beats
            R2 = corrcoef(EA_icg_X, icg_beat_mat_shifted(m3,:));                            % finding coorelation coefficent between EA ICG and it beats
            Coef_value_S(m3) = R2(1,2);
        end
       
        % Checking and removing beats which are not correlated to EA_icg2,
        % even after lag correction (circshifting)

        icg_beat_mat_corrected= icg_beat_mat_shifted;
        for  c =size(icg_beat_mat_shifted,1):-1:1
            if ((abs(Lag_value_S(c)) <= 1) && Coef_value_S(c) <= 0.80) || (abs(Lag_value_S(c)) > 1)
                icg_beat_mat_corrected(c,:) = [];
                beats_del_3 = [beats_del_3 c];
            end       
        end
        beats_del_3 = sort(beats_del_3);
        %% Finding Beat COntribution Factor(BCF)
        beats_total(k) =   size(icg_beat_mat,1);    % total beats 
        beats_S1_removed(k) = size(beats_del_1,2);   % Beats removed in stage 1 :Amplitude filtering
        beats_S2_removed(k) = size(beats_del_2,2);   % Beats removed in stage 2 :coarse filtering 
        beats_S3_removed(k) = size(beats_del_3,2);   % Beats removed in stage 3 :fine filtering
        
        beats_4_Eavg_AXC(k) = beats_total(k) - (beats_S1_removed(k) + beats_S2_removed(k) + beats_S3_removed(k));           % clean beats for three stage EA beat
        BCF(k) = beats_4_Eavg_AXC(k)/ beats_total(k); 

        %% Saving ensembled averaged results for ecg and different icg settings 
        EA_ecg =  [EA_ecg mean(ecg_beat_mat)];                      % ensemble averaged ecg for all segments
        
        if size(icg_beat_mat_corrected,1) == 0
            EA_icg_AXC = [EA_icg_AXC zeros(1,size(icg_beat_mat_corrected,2))];   % if no beat left
        elseif size(icg_beat_mat_corrected,1) == 1
            EA_icg_AXC = [EA_icg_AXC icg_beat_mat_corrected];                    % if one beat left
        else
            EA_icg_AXC = [EA_icg_AXC mean(icg_beat_mat_corrected)];              % icg_EA for zero lag beats only      
        end  
        
        % Beat contribution facor for three stage EA beat
        
        switch k
                case 1
                    disp("Saving data for Beat 1")
                    beat_1 = struct;
                    Rec_BCF(r).BCF_beat_1 = BCF(k);            
            case 2
                    disp("Saving data for Beat 2")
                    beat_2 = struct;
                    Rec_BCF(r).BCF_beat_2 = BCF(k);
            case 3
                    disp("Saving data for Beat 3")
                    beat_3 = struct;
                    Rec_BCF(r).BCF_beat_3 = BCF(k);
            case 4
                    disp("Saving data for Beat 4")
                    beat_4 = struct;
                    Rec_BCF(r).BCF_beat_4 = BCF(k);
            case 5
                    disp("Saving data for Beat 5")
                    beat_5 = struct;
                    Rec_BCF(r).BCF_beat_5 = BCF(k);
            case 6
                    disp("Saving data for Beat 6")
                    beat_6 = struct;
                    Rec_BCF(r).BCF_beat_6 = BCF(k);
              case 7
                    disp("Saving data for Beat 7")
                    beat_7 = struct;
                    Rec_BCF(r).BCF_beat_7 = BCF(k);
            case 8
                    disp("Saving data for Beat 8")
                    beat_8 = struct;
                    Rec_BCF(r).BCF_beat_8 = BCF(k);
            case 9
                    disp("Saving data for Beat 9")
                    beat_9 = struct;
                    Rec_BCF(r).BCF_beat_9 = BCF(k);
            case 10
                    disp("Saving data for Beat 10")
                    beat_10 = struct;
                    Rec_BCF(r).BCF_beat_10 = BCF(k);             
            otherwise
                disp('More than 10 EAvg beats')   
        end
   end
            
   %% 9. saving the three stage EA ECG and ICG sig results
     EA_ecg_icg = [EA_ecg; EA_icg_AXC];
     disp('Saving EAvg_AXC_ecg_icg  ...')      
     save(EA_file,'EA_ecg_icg');

end

%% 10. saving  BCF in excel sheet
disp('Saving BCF values ...')  
writetable(struct2table(Rec_BCF), strcat(EA_folder, 'Demo_BCF.xlsx'))
