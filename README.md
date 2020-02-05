# Impedance Cardiogram Opensource Toolbox

1. [Introduction](intro)
2. [Full Instructions](fullinst)
3. [Guide to Output](output) 
4. [Contributing to this project](cont)
5. [FAQ](faq)

<a name="intro"></a>
## Introduction



<a name="fullinst"></a>
## Full Instructions: 
System requirements:

- Matlab and License    https://www.mathworks.com/

1)  Download and install Matlab 2017b (v9.3) (required Matlab Toolboxes: 
    Signal Processing Toolbox, and Statistics and Machine Learning Toolbox, 
    Neural Network Toolbox)

2)  Add the PhysioNet Cardiovascular Signal Toolbox to your
    Matlab path: **run startup.m**
    
### II. Starting Analysis

#### Quick Start: 
1) Dependency : [Physionet Cardiovascular Signal toolbox](https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox) is reuired to detect R peaks from raw ECG signal.

2)  [Noise_removal.m](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Noise_Removal) can be used to obtain noise free three-stage ensemble averaged ICG signal for futher analysis. Input data must be a mat file with equal length vectors of ECG and ICG raw signals (physical units, mV and Ohm/sec respectively). Demo input data is also available [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/ECG_ICG_Data)



<a name="output"></a>
## III. Guide to Output:
The following metrics are output from the HRV Toolbox:

    - t_start   : (s)  Start time of each window analyzed
    - t_end     : (s)  End time of each window analyzed

#### Time domain measures of HRV:
