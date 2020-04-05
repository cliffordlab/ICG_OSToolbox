# Open Source Toolbox for ICG Analysis

1. [Introduction](#intro)
2. [Instructions](#fullinst) 
3. [Guide to output](#output) 

If you are using this software, please cite:
```
 Shafa-at Ali Sheikh, Amit Shah, Oleksiy Levantsevych, Majd Soudan, Jamil Alkhalaf, Ali Bahrami Rad, 
 Omer T.Inan, Gari D. Clifford, "An Open-Source Toolbox for Automated Removal of Noisy Beats for 
 Accurate ICG Analysis", (under review) .
```   

<a name="intro"></a>
## 1. Introduction
The impedance cardiogram (ICG) signal is sensitive to artifactual influences of respiration, speaking, motion, and electrode displacement.  Electrocardiogram  (ECG)  synchronized  ensemble averaging of ICG (conventional  ensemble averaging method) partially mitigates these artifacts but still suffers from intrasubject variability of ICG morphology and event latency. An open-source toolbox has been developed to remove noisy beats from the ICG signal for further suppressing artifacts in ensemble-averaged (EA) ICG beats. The toolbox also contains the "ICG manual annotation application" (ICMAA) to manually / automatically annotate fiducial points on EA ICG beats for further analysis. The toolbox will enable other researchers to readily reproduce and improve upon this work. 


<a name="fullinst"></a>
## 2. Instructions: 
### I. System requirements:
   
1)  Download and install Matlab 2017b (v9.3) https://www.mathworks.com

2)  Add the [Physionet Cardiovascular Signal toolbox](https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox) to your Matlab path: **run startup.m**
    
### II. Quick Start

1)  [Noise_removal.m](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Noise_Removal) can be used to obtain noise free three-stage EA ICG signal for futher analysis. Input data must be in .mat format with equal length vectors of synchronized ECG and ICG raw signals (physical units, mV and Ohm/sec respectively). Demo input data is available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/ECG_ICG_Data).

2) Impedance cardiogram manual annotation application, [ICMAA.m](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Annotation#impedance-cardiogram-manual-annotation-application-icmaa), can be used to visualize and annotate the three-stage EA ICG. Demo input data for ICMAA is available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG).

3) Data for demonstrating different functions of the toolbox is available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data).

<a name="output"></a>
## 3. Guide to Output

### I. Artifact free Ensemble-Averaged ICG Signal
Noise free three-stage EA ICG signal are obtained using [Noise_removal.m](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Noise_Removal). Demo output data is available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG).

### II. Beat Contribution Factor
A new parameter, Beat Contribution Factor (BCF), has been defined for each three-stage EA ICG beat to ascertain its validity for further analysis. Using [Noise_removal.m](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Noise_Removal), BCF is calculated as the ratio of the number of clean beats (output of the third stage of the noise removal algorithm) to the total number of beats in an analysis window (input to the noise removal algorithm). Demo BCF data is available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG).

### III. Annotation Files
Using [ICMAA.m](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Annotation#impedance-cardiogram-manual-annotation-application-icmaa) fiducial points can be annotated on EA ECG and ICG, and the annotation files are returned for following:  

    ECG : *Rpeak.txt    (for R peak locations)
    ICG : *Bpoint.txt   (for B point locations)
          *Feature.txt  (for type of B point feature shapes in RC interval)
          *Cpoint.txt   (for C point locations)
          *CShape.txt   (for type of C point shapes)
          *Xpoint.txt   (for X point locations)
          *XShape.txt   (for type of X point shapes)
          

Demo annotaion files are available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Sample_Annotations_by_ICMAA). To read these files use the toolbox functions available in [ICG_param_extract](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_param_extract):
    R peak locations = RBCX_read('ann_folder', '*Rpeak.txt','ID')
    B point locations = RBCX_read('ann_folder', '*Bpoint.txt','ID')
    C point locations = RBCX_read('ann_folder', '*Cpoint.txt','ID')
    X point locations = RBCX_read('ann_folder', '*Xpoint.txt','ID')
    RC feature types = feature_extract and feature_read(feature_num)
    C Shape types =   Cshape_extract and Cshape_read(Cshape_num)
    X Shape types =   Xshape_extract and Xshape_read(Cshape_num)
    

### IV. Hemodynamic Parameters 
The following metrics can be obtained for EA ICG beats/records using [param_extract.m](https://github.com/cliffordlab/ICG_OSToolbox/blob/master/ICG_param_extract). Demo parameters extracted from EA ICG beats/records are available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Sample_Parameters_Extracted).

    RB          : (ms)    Pre-ejection period
    RC          : (ms)    Intersystolic time interval
    LVET        : (ms)    Left ventricular ejection time
    C-amplitude : (Ohm/s) Ejection velocity index
 

