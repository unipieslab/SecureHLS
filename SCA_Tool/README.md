# SCA_Tool - Side-Channel Analysis Attack and Analysis Platform

The platform enables users to automatically perform trace acquisition regarding power consumption as well as Side-Channel Analysis (SCA) attacks on a programmed _ChipWhisperer_ platform (`CW305 Artix FPGA` Target). The trace acquisition is performed using a _Siglent SDS2352X-E_ oscilloscope, which is remotely configured through the platform’s script.

## Prerequisites

Regarding the software, the platform requires 
* Python 3.7 
    - ChipWhisperer (version 5.7.0) package 
* NI-VISA drivers 
* Matlab 2021.b
    - Matlab Engine


## Flow
The platform is designed to perform SCA attacks on the SubBytes step of the first round of an AES-128 ECB encryption. The platform can perform Correlated Power Analysis (CPA)

* On Time and Frequency domain, using Fast Fourier Transformation – FFT)
* Using different power models (Hamming Weight and Hamming Distance)
* On the output of the computation, as well as the intermediate operations. Attacking all the operations of the design under evaluation would provide better insights regarding internal optimizations performed over the design.

The platform consists of ATTACK_SCRIPTS and ANALYSIS_SCRIPTS folders, which contain all the required functionality. 



## Attack Scripts - Trace Aqcuisition
The ChipWhisperer platform contains a series of examples to verify its operation. For our case, we take the aes-128 example and use it as a template, in order to retain the correct interface for the data exchange. From that, we locate the cw305_interface.vhd file in the RTL hierarchy. This file creates the entity for the victim operation the platform will target. Therefore, we modify the code in order to use our victim operation, retaining the interface.
An additional modification is performed. A new signal is created, operating as a trigger. This will later assist on with the trace acquisition process. The trigger signal has multiple uses: a) It triggers the trace acquisition process on the oscilloscope, b) indicates the duration of the activity of the victim operation and c) enables user to perform signal alignment. For our victim SubBytes, we use the interface signals that indicate the start and end of execution to setup the trigger.
The bitstream can be then generated and placed in the ATTACK_SCRIPTS folder, under the name cw305_top.bit. In the same folder, the following scripts for the trace acquisition process are also included.

The trace acquisition process can begin from the get_traces.m script . Before running, the variable `flag_capture_oscilloscope` variable should be set to `0` and the acquisition mode needs to be set to Normal. This will allow users to properly setup the oscilloscope, by performing an initial run that will not acquire traces.

get_traces.m executes the Python code loadBitstreamCW305.py. The absolute path of the bitstream needs to be set on cw.con() command. From this code it is also possible to set the clock of the target platform, using the cw.pll.pll_outfreq_set() command. 
The trace acquisition script proceeds to the perform_encryptions.m script. This script first sets up the cryptographic key that is going to be used throughout the process. It should be noted here that the ChipWhisperer platform handles data from right to left, i.e. the first key byte as well as data byte is going to be the rightmost in Matlab (indexed as 16). 
The script then initializes the oscilloscope’s scope, by using the init_SIGLENT_scope.m script. Make sure that visa() command attributes correspond to your device before using. From there, certain commands can be send to the oscilloscope, allowing its remote setup.
In order to perform each encryption, i.e. send a plaintext to the target platform and receive the ciphertext, perform_encryptions.m uses the write_plaitext.m script. This script generates a random plaintext which is combined with the cryptographic key that was previously generated, by means of XOR. The result is therefore the AddRoundKey of the first round that precedes the victim SubBytes operation. 

write_plaitext.m uses the appropriate Python commands to send the plaintext and receive the ciphertext. 

## Analysis Scripts
All side-channel analysis scripts are included in the ANALYSIS_SCRIPTS folder. They perform a series of preprocesses, as well as the correlated power analysis (CPA) attacks.

First, the s1_regroup_attack_data.m script should be executed. This script reads all the attack_data_x.mat files from the ATTACK_SCRIPTS folder and combines a specified number of files (as set from the variable numofprocessedfiles value) into one file called attack_data_all.mat . Additionally, from this script, undersampling of trace points may be performed, if the new_sampling_rate is appropriately set. The range of trace points to be examined can be defined, by setting the startsample and endsample variables appropriately.

From there, the CPA attacks can be performed. The user may select the key byte to be attacked (16 to 1), as defined from the variable keybyte. The user can also select the attack domain, by setting the variable domain as TIME (time domain) or FFT (frequency domain). Additionally, they may select the power model to be used: Hamming Weight (HW), Hamming Distance (HD), Most-Significant Bit (MSB), Least-Significant Bit (LSB) and Identity as defined in the LEAKAGE_MODEL variable.

s2_simple_cpa_CPU.m script performs a simple CPA attack on the output of the SubBytes process, given the attack_data_all.mat data. The script generates the extracted key value, as well as a plot displaying the correlation-coefficient values.

s3_simple_cpa_all_interm_values_TIME.m performs simple CPA attacks on all intermediate values of the SubBytes process, on the time domain for a specific LEAKAGE_MODEL. For each intermediate command, as defined in the all_canright_sbox_interm_values.mat file (339 commands in total), the script generates a plot of the correlation-coefficient values, with the expected key value highlighted. The plots are saved in a dedicated folder, depending on the LEAKAGE_MODEL selected. The user may select the range of intermediate values to examine, by altering the range of values for the i_op variable. 

s4_simple_cpa_all_interm_values_FFT.m performs simple CPA attacks on all intermediate values of the SubBytes process as the previous script, on the frequency domain for a specific LEAKAGE_MODEL.

s5_run_all_power_models_TIME.m executes the attacks for all power models in the time domain, by setting the LEAKAGE_MODEL variable and calling the s3_simple_cpa_all_interm_values_TIME.m. Similarly, s6_run_all_power_models_FFT.m executes the attacks for all power models in the frequency domain.

# Welch's t-test
Welch’s t-test evaluation is also available in our platform. This examines whether two sets of data, consisting of the traces derived for different inputs, can be distinguished. If so, it means that the leakage is strongly related to the input, and therefore, to the cryptographic key. The degree of distinguishability is given by the value t, calculated for each set’s mean μ, variance s2 and number of elements n

In order to perform the t-test evaluation, two sets of traces are required: One generated using random plaintexts, and one generated using the same constant plaintext. The latter data set can be derived from the trace acquisition flow, if a constant plaintext value is set to the write_plaintext.m script. The s1_regroup_attack_data.m should also be performed on both datasets, generating two separate attack_data_all.mat files. The t-test.m script can be then performed using those. The script generates a plot, indicating whether the t value per trace point exceeds |4.5|. This value indicates that the design generates a side channel leakage capable of exposing the secret key.
