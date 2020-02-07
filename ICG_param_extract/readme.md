# ICG Parameter Extraction
Function files to read annotation files and extract hemodynamic parameters from EA ECG and ICG record.

## Reading Annotation Files
Demo annotaion files are available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Sample_Annotations_by_ICMAA). To read these files use the functions available in [ICG_param_extract](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_param_extract) included in the toolbox:

    R peak locations = RBCX_read('ann_folder', '*Rpeak.txt','ID')
    B point locations = RBCX_read('ann_folder', '*Bpoint.txt','ID')
    C point locations = RBCX_read('ann_folder', '*Cpoint.txt','ID')
    X point locations = RBCX_read('ann_folder', '*Xpoint.txt','ID')
    RC feature types = feature_extract and feature_read(feature_num)
    C Shape types =   Cshape_extract and Cshape_read(Cshape_num)
    X Shape types =   Xshape_extract and Xshape_read(Cshape_num)
    

## Hemodynamic Parameters 
The following metrics can be obtained for EA ICG beats/records using [param_extract.m](https://github.com/cliffordlab/ICG_OSToolbox/blob/master/ICG_param_extract). Demo parameters extracted from EA ICG beats/records are available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Sample_Parameters_Extracted).

    RB          : (ms)    Pre-ejection period
    RC          : (ms)    Intersystolic time interval
    LVET        : (ms)    Left ventricular ejection time
    C-amplitude : (Ohm/s) Ejection velocity index
