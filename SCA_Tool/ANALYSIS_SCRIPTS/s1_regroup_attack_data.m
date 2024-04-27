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

clear all
choose_channel = 1;

addpath('..\..\ATTACK_SCRIPTS\attack_data')
%addpath('ignore')

numofprocessedfiles = 10000;

original_sampling_rate = 2e9;
new_sampling_rate = 200e6;
one_every = original_sampling_rate / new_sampling_rate;
load('attack_data_1.mat')
if choose_channel == 1
    datapoints = datapointsCH1;
    clear datapointsCH1 datapointsCH2
elseif choose_channel ==2
    datapoints = datapointsCH2;
    clear datapointsCH1 datapointsCH2
end

startsample = 1;
endsample   = size(datapoints,2);%5600-18;

datapoints(:,1:startsample-1) = [];



icount = 0;
for ii=1:one_every:endsample-startsample
    icount = icount + 1;
    datapoints_copy(:,icount) = datapoints(:,ii);
end
datapoints = datapoints_copy;

count = 0;
datapoints_all = zeros(100*numofprocessedfiles,size(datapoints,2));
plaintexts_SCA_all = zeros(100*numofprocessedfiles,16);
result_all = cell(100*numofprocessedfiles,7);
datapoints_all = (datapoints_all);
plaintexts_SCA_all = (plaintexts_SCA_all);
result_all = result_all;


for i=1:numofprocessedfiles
    count = count + 1;
    display(count);
    attack_data_file_name = strcat('attack_data_',num2str(i,'%d'),'.mat');
    load(attack_data_file_name);
    if choose_channel == 1
        datapoints = datapointsCH1;
        clear datapointsCH1 datapointsCH2
    elseif choose_channel ==2
        datapoints = datapointsCH2;
        clear datapointsCH1 datapointsCH2
    end

    datapoints(:,1:startsample-1) = [];

    icount = 0;
    for ii=1:one_every:endsample-startsample
        icount = icount + 1;
        datapoints_copy(:,icount) = datapoints(:,ii);
    end
    datapoints = datapoints_copy;
    startsample2 = 1;
    endsample2 = size(datapoints,2);

    %     datapoints = (datapoints);
    %     plaintexts_SCA = (plaintexts_SCA);
    datapoints_all((100*i-100)+1:(100*i),startsample2:endsample2) = datapoints(:,startsample2:endsample2);
    plaintexts_SCA_all((100*i-100)+1:(100*i),1:16) = plaintexts_SCA;
    result_all((100*i-100)+1:(100*i),1:7) = result;

%     plot(datapoints);
%     pause(0.001);


end
datapoints = (datapoints_all);
plaintexts_SCA = (plaintexts_SCA_all);
result = (result_all);
clear datapoints_all plaintexts_SCA_all result_all

sara1 = new_sampling_rate;

file_name = 'attack_data_all.mat';
%save(file_name, 'sara1', 'plaintexts_SCA','datapoints','result','key_for_matlab_computation_dec','-v7.3');
save(file_name, 'sara1', 'plaintexts_SCA','datapoints','result','key_for_matlab_computation_dec');
% file_name = 'attack_data_all_1';
% save(file_name, 'plaintexts_SCA','datapoints','result','key_for_matlab_computation_dec');

% save('sara1.mat', sara1);

%s2_simple_cpa_CPU
s3_run_all_power_models_TIME

