# Demonstration - Noise Removal Algorithm

1. [Adding Physionet Toolbox to path ](#physio)
2. [Designating Folders for Input and Output Data](#folder) 
3. [Algorithm Execution and Output Data](#output) 

<a name="physio"></a>
## 1. Adding Physionet toolbox to path
Download and add the [Physionet Cardiovascular Signal toolbox](https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox) to MATLAB path.
![](noise_removal_gif/1_Add_physio.gif)

<a name="folder"></a>
## 2. Designating Folders for Input and Output Data
Download and save synchronized ECG and ICG signal to the local machine from [here](https://github.com/cliffordlab/ICG_OSToolbox/tree/master/ICG_ECG_Demo_Data/ECG_ICG_Data). The user need to indicate the folders for input data (ECG_ICG signal) and output data (EA ECG_ICG) on their local machine using variables "input_ECG_ICG_Folder" and "EA_folder", respectively.
![](noise_removal_gif/2_Designate_folders.gif)

<a name="output"></a>
## 3. Algorithm Execution and Output Data
Running the algorithm for two records and saving output data in the output folder "Ensemble_Averaged_ECG_ICG". The output folder contains EA ECG and ICG data alongwith beat contribution factor summary. The command window in MATLAB shows progress of algorithm. A folder "HRV_output" will also be created, alongwith a sub folder "Annotation" which contains annoatation files created by Physionet toolbox for ECG signal.
![](noise_removal_gif/3_run_and_save.gif)

