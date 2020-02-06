function [beat_Xshape] = Xshape_read(Xshape_num)
% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG".
%    Configured to extract X shape types of ICG beat.
%
% INPUT:
%    Xshape_num : Numeric X shape number read from text file
% OUTPUT:
%    beat_Xshape :  X shape type in string format
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

switch Xshape_num
        case 1
             beat_Xshape = 'X shape Not Selected';
        case 2
             beat_Xshape = 'Single notch';  
        case 3
             beat_Xshape = 'Double notch';
        case 4
             beat_Xshape = 'X not visible';  
        case 5
             beat_Xshape  = 'others - notes added';         
end

end

