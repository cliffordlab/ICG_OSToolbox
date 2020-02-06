function [beat_feature] = feature_read(feature_num)
% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG".
%    Configured to extract feature type of B point between RC interval of
%    ICG beat.
%
% INPUT:
%    feature_num : Numeric feature number read from text file
% OUTPUT:
%    beat_feature :  Feature name in string format
%
% DEPENDENCIES & LIBRARIES:
%   ICG Noise Removal Toolbox
%   https://github.com/cliffordlab/ICG_OSToolbox
%
%	REPO for code:       
%   https://github.com/cliffordlab/ICG_OSToolbox/ICG_param_extract
%
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
%       more information.

% This file has been updated on Feb 5, 2020 by Shafa-at Ali Sheikh.

switch feature_num
        case 1
             beat_feature = 'Feature Not Selected';
        case 2
             beat_feature = 'Notch';  
        case 3
             beat_feature = 'Valley';
        case 4
             beat_feature = 'Plateau';  
        case 5
             beat_feature = 'Inflection';
        case 6
             beat_feature = 'Mild inflection';  
        case 7
             beat_feature  = 'Change in gradient';
        case 8
             beat_feature = 'Corner';  
        case 9
             beat_feature = 'Onset of the rise';
        case 10
             beat_feature  = 'Featureless';  
        case 11
             beat_feature  = 'Invalid or noisy'; 
        case 12
             beat_feature  = 'others - notes added';         
end

end

