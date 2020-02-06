function [beat_Cshape] = Cshape_read(Cshape_num)
% OVERVIEW:
%    File for "Open source toolbox for removal of noisy beats from ICG".
%    Configured to extract C shape types of ICG beat.
%
% INPUT:
%    Cshape_num : Numeric C shape number read from text file
% OUTPUT:
%    beat_Cshape :  C shape type in string format
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

switch Cshape_num
        case 1
             beat_Cshape = 'C shape Not Selected';
        case 2
             beat_Cshape = 'Single Peak';  
        case 3
             beat_Cshape = 'Double Peak (M)';
        case 4
             beat_Cshape = 'Flat';  
        case 5
             beat_Cshape = 'Inflection close to peak';
        case 6
             beat_Cshape = 'Valley close to peak';  
        case 7
             beat_Cshape  = 'Inflection after peak';
        case 8
             beat_Cshape = 'Valley after peak';  
        case 9
             beat_Cshape  = 'others - notes added';         
end

end

