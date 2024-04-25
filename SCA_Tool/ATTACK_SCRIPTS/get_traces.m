%%Copyright (C) 2023  Amalia-Artemis Koufopoulou, Athanasios Papadimitriou , Mihalis Psarakis, David Hely

%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <https://www.gnu.org/licenses/>.


dbstop if error
ca
%clear all
%cleanupObj = onCleanup(@cleanMeUp);

load('constants.mat')

rng shuffle
%%rng(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         HOW TO INSTALL CW305                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Install Python
% go to cmd with admin privileges 
% pip install chipwhisperer
% install the usb driver from the CW github
% Install matlab engine 
% cd "C:\Program Files\MATLAB\R2020b\extern\engines\python"
% python setup.py install
%cd (fullfile(matlabroot,'extern','engines','python'))
%system('python setup.py install')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Python setup for CW305
path_with_pyscripts = fileparts(which('CW305_FPGA.py'));
insert(py.sys.path,int32(0),path_with_pyscripts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TRACE_ACQUISITION_DEVICE = 'SIGLENT';
TARGET_DEVICE = 'CW305';
OSC_DATA_FORMAT = 'VOLTAGE'; % VOLTAGE or BINARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(TARGET_DEVICE, 'CW305')==1
    system('python loadBitstreamCW305.py');
end

%cd (fullfile(matlabroot,'extern','engines','python'))
%system('python setup.py install')

format long;
if ~isempty(instrfind)
     fclose(instrfind);
     delete(instrfind);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         VARIABLE SETUP                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_capture_oscilloscope = 0; % If equal to 1 we capture the ocsilloscope. If 0 we do not.
flag_capture_channel = 1; % 1 for CH1, 2 for CH2 and 12 for both channels.
flag_validate_aes = 0;
flag_validate_sbox = 0;

total_encryptions = 1000000;%total_runs*numofencryptions
numofencryptions = 100;
total_runs = total_encryptions/numofencryptions;% This is the total number of encryptions.

start_file_number = 0 ; %normaly 0. So to resume use the number of the last saved attack_data file

lecroy_num_of_points = 1.4*1000; % Number of points we save from the points sent by SIGLENT.


acquisition_mode = 'NORMAL'; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count_saves = start_file_number;

count_total_traces = 0;

for i=start_file_number:total_runs

    clearvars -except OSC_DATA_FORMAT flag_validate_sbox baud_rate COM_PORT_NUMBER TARGET_DEVICE HW SubBytes TRACE_ACQUISITION_DEVICE deviceObj groupObj acquisition_mode averages count_total_traces flag_capture_channel count_saves averaging_delay total_encryptions total_runs numofencryptions flag_capture_oscilloscope lecroy_num_of_points flag_validate_aes
    count_saves = count_saves + 1;

    tic
    
    if (strcmp(TRACE_ACQUISITION_DEVICE,'SIGLENT'))
        perform_encryptions;
    end    

    toc

end
if flag_capture_oscilloscope == 1 disconnect(deviceObj); end
if flag_capture_oscilloscope == 1 delete([deviceObj visaObj]); end
total_encryptions = total_runs*numofencryptions
