# Impedance Cardiogram Manual Annotation Application (ICMAA)
An application for automatic and manual annotation of fiducial points on ensemble-averaged (EA) ECG and ICG beats.

## Demonstration - ICMAA
1. [Annotation Process](#1)
    - [Saving EA ECG and ICG records](#1a)
2. [Launch ICMAA](#2) 
3. [Folder Selection and Loading Record](#3) 
4. [Automatic Annotation - Rpeak, C point and X point](#4)
5. [Hide ECG and Beat Length View](#5)
6. [Select C shape](#6)
7. [Select X shape](#7)
8. [Select RC Feature](#8)
9. [Manual Annotation - B point on Feature: Inflection/Mild Inflection/ Plateau Feature](#9)
10. [Compute Hemodynamic Parameters](#10)
11. [Beat by Beat Navigation](#11)
12. [Using RC Interval in Time Axes Control](#12)
13. [Manual Annotation - B point in RC Interval mode](#13)
14. [Use of RC Inflection Visualization Panel](#14)
15. [Manual Deletion/Annotation C point](#15)
16. [Manual Deletion/Annotation X point](#16)
17. [Manual Deletion/Annotation R peak](#17)
18. [Annotation Files](#18)
19. [B point Annotation Examples](#19)
    - [Manual Deletion/ Annotation - B point](#19a)
    - [Manual Annotation - B point on Feature:  Valley/Notch](#19b)
    - [Manual Annotation - B point on Feature: Onset of the Rise](#19c)
    - [Manual Annotation - B point on Feature: Change in Gradient](#19c)
    - [Automatic Annotation - B point on Featureless](#19d)


<a name="1"></a>
### 1. Annotation Process
<a name="1a"></a>
#### - Saving EA ECG and ICG records

Download and save EA ECG and ICG signal in a folder on local machine from [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/Ensemble_Averaged_ECG_ICG). 
For demonstration purpose, we have saved EA ECG_ICG records in the folder 'Ensemble_Averaged_ECG_ICG' as shown in gif below.

![](ICMAA_gif/1_save_input_data_r.gif)

<a name="2"></a>
### 2. Launch ICMAA
Open ICMAA.m in MATLAB and click the run button to launch.

![](ICMAA_gif/2_Launch_ICMAA_r.gif)

<a name="3"></a>
### 3. Folder Selection and Loading Record
Use button`Select Records Folder` to select folder **Ensemble_Averaged_ECG_ICG** which contains four EA ECG_ICG records. While selecting folder, the pop up window will not show files because we are selecting the folder and not the files. The four records will be visible in `Records` listbox. Select record from the list box and use `Load Record` to load EA ECG and ICG record in ICMAA. The top window will show EA ECG signal and bottom window will show EA ICG signal.

![](ICMAA_gif/3_Select_load_r.gif)

<a name="4"></a>
### 4. Automatic Annotation - Rpeak, C point and X point
With `Time Axes Control` set to **Data Length**, use **ECG/ ICG Fiducial Points Panel** to automatically annotate R peaks, C points, and X points. Click button `Auto` under these fiducial point for automatic annotation.

![](ICMAA_gif/4_RCX_auto_r.gif)


<a name="5"></a>
### 5. Hide ECG and Beat Length View
Use button `Hide ECG` to hide the ECG plot, and set popup menu `Time Axes Control` to **Beat Length**. This will show single EA ICG beat in plot area.

![](ICMAA_gif/5_Hide_beat_len_r.gif)

<a name="6"></a>
### 6. Select C shape
In **C & X Shape Selection Panel**, use popup menu `Select C shape` to select the shape of C point. In this case, C shape is single peak. Images of different C shapes can be found [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Annotation/ICMAA_C_shape).

![](ICMAA_gif/6_sel_C_shape_r.gif)

<a name="7"></a>
### 7. Select X shape
In **C & X Shape Selection Panel**, use popup menu `Select X shape` to select the shape of X point. In this case, X shape is single notch. Images of different X shapes can be found [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Annotation/ICMAA_X_shape).

![](ICMAA_gif/7_sel_X_shape_r.gif)

<a name="8"></a>
### 8. Select RC Feature
In **RC Feature Selection Panel**, use popup menu `Select RC Feature` to select the type of feature between R peak and C point on EA ICG beat. In this case, the feature is **inflection**. With selection of inflection in popup menu, button`Show Inflection` will also be enabled and inflection visualization feature of ICMAA will be activated. Dotted lines alongwith **Zero Crossing Sign** will appear on the plot. Images of different features between Rpeak and C point can be found [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_Annotation/ICMAA_RC_Feature). 

![](ICMAA_gif/8_sel_RC_r.gif)

<a name="9"></a>
### 9. Manual Annotation - B point on Inflection/Mild Inflection/ Plateau Feature
After selecting RC feature as inflection/mild inflection or Plateau, use mouse to select the solid blue line. The solid blue line will also convert into broken blue line. Use mouse to drag the line inside ICG plot. **Zero Crossing Sign** will also change from NaN to -1 or +1. Align broken blue line with dotted black line, once **Zero Crossing Sign** changes from -1 to +1. Use **Shift + Left Click** to mark B point.

![](ICMAA_gif/9_mk_B_infl_r.gif)

<a name="10"></a>
### 10. Compute Hemodynamic Parameters
In **Current Beat Parameter Panel**, use button `Compute Parameters` to display hemodynamic parameters such as Pre-ejection period (RB interval), Inter-systolic time interval (ISTI - RC interval), ejection time (ET - BX interval), ejection velocity index (C point amplitude), B point amplitude and X point amplitude for current beat. 

![](ICMAA_gif/10_compute_param_r.gif)

<a name="11"></a>
### 11. Beat by Beat Navigation
In **Record Selection and Loading Panel**, use slider bar `Beat by Beat Navigation` to navigate between different beats of a record.
Use this slider bar to go to next / previous for annotation/ analysis.

![](ICMAA_gif/11_beat_by_beat_r.gif)

<a name="12"></a>
### 12. Using RC Interval in Time Axes Control
In **Record Selection and Loading Panel**, use  pop up menu `Time Axes Control` to select **RC Interval**. The ICG plot will be zoomed in to display RC interval. In **RC Feature Selection Panel**, use popup menu `Select RC Feature` to select the type of feature between R peak and C point on EA ICG beat. In this case, the feature is **inflection**. With selection of inflection in popup menu, button`Show Inflection` will also be enabled and inflection visualization feature of ICMAA will be activated. Dotted lines alongwith **Zero Crossing Sign** will appear on the plot. Images of different features between Rpeak and C point can be found here. 

![](ICMAA_gif/12_mk_B_RC_r.gif)

<a name="13"></a>
### 13. Manual Annotation - B point in RC Interval mode
Use mouse to select the solid blue line. The solid blue line will also convert into broken blue line. Use mouse to drag the line inside ICG plot. **Zero Crossing Sign** will also change from NaN to -1 or +1. Align broken blue line with dotted black line, once **Zero Crossing Sign** changes from -1 to +1. Use **Shift + Left Click** to mark B point.

![](ICMAA_gif/13_mk_B_RC_2_r.gif)

<a name="14"></a>
### 14. Use of RC Inflection Visualization Panel
In **RC Inflection Visualization Panel**, use button `Show Inflection` to visualize **Zero Crossing Sign (--)** along with dotted black lines. Use button `Clear Inflection` to clear the **Zero Crossing Sign (--)** and dotted black lines. Use mouse to select the solid blue line. The solid blue line will also convert into broken blue line. Use mouse to drag the line inside ICG plot. **Zero Crossing Sign** will also change from NaN to -1 or +1. Align broken blue line with dotted black line, once **Zero Crossing Sign** changes from -1 to +1. Use **Shift + Left Click** to mark B point.

![](ICMAA_gif/14_inflec_vis_r.gif)

<a name="15"></a>
### 15. Manual Deletion/Annotation C point
In **ECG/ICG Fiducial Points Panel**, under **C** point, use button `Del` to delete C point and use small triangle to manually annotate C point. Use mouse to select the solid black line. The solid black line will convert into broken black line. Use broken black line to annotate C point at maximum of ICG beat by looking at **ICG amp** in lower left corner of ICG plot. 

![](ICMAA_gif/15_man_C_r.gif)

<a name="16"></a>
### 16. Manual Deletion/Annotation X point
In **ECG/ICG Fiducial Points Panel**, under **X** point, use button `Del` to delete X point and use **o** to manually annotate X point. Use mouse to select the solid magenta line. The solid magenta line will convert into broken magenta line. Use broken magenta line to annotate X point at minimum of ICG beat by looking at **ICG amp** in lower left corner of ICG plot. 

![](ICMAA_gif/16_man_X_r.gif)

<a name="17"></a>
### 17. Manual Deletion/Annotation R peak
In case, Physionet toolbox incorrectly detects R peaks, then in **ECG/ICG Fiducial Points Panel**, under **R Peak**, use button `Del` to delete R peak and use **+** to manually annotate R peaks. Use mouse to select the solid red line. The solid red line will convert into broken red line. Use broken red line to annotate R peak at maximum of ECG beat by looking at **ECG amp** in lower left corner of ECG plot. 

![](ICMAA_gif/18_man_R_r.gif)


<a name="18"></a>
### 18. Annotation Files
All the annotation files are saved in .txt format in a subfolder **Ensemble_Averaged_ECG_ICG_manual_annotation** inside the  **Ensemble_Averaged_ECG_ICG** which contains four EA ECG_ICG records.

![](ICMAA_gif/17_annotaion_r.gif)

<a name="19"></a>
### 19. B point Annotation Examples
