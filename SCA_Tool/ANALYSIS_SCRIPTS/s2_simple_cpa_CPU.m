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

clear all;
load('attack_data_all.mat');
load('constants.mat');

keybyte = 16;
sample_start = 1;
sample_stop = size(datapoints,2)-1;

domain = 'TIME'; % Possibilities are 'FFT' or 'TIME'.

LEAKAGE_MODEL = 'HW';% LSB, MSB, HW, IDENTITY
samples = sample_stop - sample_start + 1;

if (strcmp(domain,'TIME'))
    datapoints = (datapoints(:,sample_start:sample_stop));
    f = 0;
    Fs = 0;
    datapoints=(datapoints(:,sample_start:sample_stop));
    traces=datapoints;
elseif (strcmp(domain,'FFT'))
    
    datapoints = (datapoints(:,sample_start:sample_stop));
    Fs = sara1; %str2num(sara1);           % Sampling frequency                    
    T_fft = 1/Fs;             % Sampling period       
    L = samples;    % Length of signal
    t = ((0:L-1)*T_fft);        % Time vector
    for i_fft = 1:size(datapoints,1)
        display(i_fft)
        signal_tmp = (datapoints(i_fft,:));
        Y = (fft(signal_tmp));
        P2 = (abs(Y/L));
        P1 = (P2(1:L/2+1));
        P1(2:end-1) = 2*P1(2:end-1);
        f = Fs*(0:(L/2))/L;
        datapoints_fft(i_fft,:) = P1;
        if (i_fft == 1)
           datapoints_fft = zeros(size(datapoints,1),size(P1,2)); 
           datapoints_fft(i_fft,:) = P1;
        end
    end
    
    clear datapoints;
    traces = datapoints_fft;
    datapoints = datapoints_fft;
    file_name = 'attack_data_all_FFT.mat';
    save(file_name, 'f', 'sara1', 'plaintexts_SCA','datapoints','result','key_for_matlab_computation_dec','-v7.3');              

end


plaintext=plaintexts_SCA(:,keybyte);

key = (key_for_matlab_computation_dec(keybyte));
SubBytes = (SubBytes);
HW = (HW);
for ikey = 1:256
        iikey(1:256) = ikey;
        if (strcmp(LEAKAGE_MODEL,'LSB')==1)
            hypotheses(:,ikey) = bitget(SubBytes(( bitxor((double(plaintext(:,1))),(double(ikey-1))))+1),1);
        elseif (strcmp(LEAKAGE_MODEL,'MSB')==1)
            hypotheses(:,ikey)=bitget(SubBytes(( bitxor((double(plaintext(:,1))),(double(ikey-1))))+1),8);
        elseif (strcmp(LEAKAGE_MODEL,'HW')==1)
            hypotheses(:,ikey) = HW( SubBytes(( bitxor((double(plaintext(:,1))),(double(ikey-1))))+1)+1);
        elseif (strcmp(LEAKAGE_MODEL,'IDENTITY')==1)
            hypotheses(:,ikey)=SubBytes(( bitxor((double(plaintext(:,1))),(double(ikey-1))))+1);
        end
    display(ikey)
end
hypotheses = double(hypotheses);
traces = (traces);
tic
R = corr(traces,hypotheses,'Type','Pearson');%'Pearson', 'Kendall', 'Spearman'
toc
figure;
plot(abs(R));

[M,I] = max(abs(R(:)));
[key_row, key_col] = ind2sub(size(R),I);
key_found = key_col - 1 %Matlab counts from 1

