# Impedance Cardiogram Manual Annotation Application (ICMAA)
An application for automatic and manual annotation of fiducial points on ensemble-averaged (EA) ECG and ICG beats.

## Demonstration - ICMAA

### 1. Saving EA ECG and ICG records

Download and save EA ECG and ICG signal in a folder on local machine from [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG). 
For demonstration purpose, we have saved EA ECG_ICG records in the folder 'Ensemble_Averaged_ECG_ICG' as shown in gif below.

![](ICMAA_gif/1_save_input_data_r.gif)

### 2. Launch ICMAA
Open ICMAA.m in MATLAB and click the run button to launch.

![](ICMAA_gif/2_Launch_ICMAA_r.gif)

### 3. Folder selection and loading record
Use button`Select Records Folder` to select folder "Ensemble_Averaged_ECG_ICG" which contains four EA ECG_ICG records. While selecting folder, the pop up window will not show files because we are selecting the folder and not the files. The four records will be visible in `Records` listbox. Select record from the list box and use `Load Record` to load EA ECG and ICG record in ICMAA. The top window will show EA ECG signal and bottom window will show EA ICG signal.

![](ICMAA_gif/3_Select_load_r.gif)

### 4. Automatic Annotation - Rpeak, C point and X point
With `Time Axes Control` set to **Data Length**, use **ECG/ ICG Fiducial Points Panel** to automatically annotate R peaks, C points, and X point. Click button `Auto` under these fiducial point for automatic annotation.

![](ICMAA_gif/4_RCX_auto_r.gif)

### 5. Hide ECG and Beat Length View
Use button `Hide ECG` to hide the ECG plot, and set popup menu `Time Axes Control` to **Beat Length**. This will show single EA ICG beat in plot area.

![](ICMAA_gif/5_Hide_beat_len_r.gif)

### 6. Select C shape
In **C & X Shape Selection Panel**, use popup menu `Select C shape` to select the shape of C point. In this case, C shape is single peak. Images of different C shapes for reference can be found here............

![](ICMAA_gif/6_sel_C_shape_r.gif)

### 7. Select X shape
In **C & X Shape Selection Panel**, use popup menu `Select X shape` to select the shape of X point. In this case, X shape is single notch. Images of different X shapes for reference can be found here............

![](ICMAA_gif/7_sel_X_shape_r.gif)

### 8. Select RC Feature
In **RC Feature Selection Panel**, use popup menu `Select RC Feature` to select the type of feature between R peak and C point on EA ICG beat. In this case, the feature is **inflection**. With selection of inflection in popup menu, button`Show Inflection` will also be enabled and inflection visualization feature of ICMAA will be activated. Dotted lines alongwith **Zero Crossing Sign** will appear on the plot. Images of different features between Rpeak and C point can be found here. 

![](ICMAA_gif/8_sel_RC_r.gif)





