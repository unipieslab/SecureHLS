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

%clear all;
load('./attack_data_all.mat');
load('./constants.mat');
load('./all_canright_sbox_interm_values.mat')

keybyte = 16;
sample_start = 1;
sample_stop = size(datapoints,2);

LEAKAGE_MODEL = 'HD';% LSB, MSB, HW, IDENTITY, HD
myfolder = strcat('./',LEAKAGE_MODEL);

samples = sample_start - sample_stop;

traces=(datapoints(:,sample_start:sample_stop));

plaintext=(plaintexts_SCA(:,keybyte));

key = (key_for_matlab_computation_dec(keybyte));
SubBytes = (SubBytes);
HW = (HW);
bitsize = 8;

for i_op = 1:size(all_int_values,1)-1 
tic
    for ikey = 1:256
            %iikey(1:256) = ikey;
            if (strcmp(LEAKAGE_MODEL,'LSB')==1)
                hypotheses(:,ikey) = bitget(all_int_values(i_op, bitxor((uint8(plaintext(:,1))),(uint8(ikey-1)))+1),1);
            elseif (strcmp(LEAKAGE_MODEL,'MSB')==1)
                hypotheses(:,ikey)=bitget(all_int_values(i_op, bitxor((uint8(plaintext(:,1))),(uint8(ikey-1)))+1),8);
            elseif (strcmp(LEAKAGE_MODEL,'HW')==1)
                hypotheses(:,ikey) = HW( all_int_values(i_op, bitxor((uint8(plaintext(:,1))),(uint8(ikey-1)))+1)+1);           
            elseif (strcmp(LEAKAGE_MODEL,'IDENTITY')==1)
                hypotheses(:,ikey) = all_int_values(i_op, bitxor((uint8(plaintext(:,1))),(uint8(ikey-1)))+1);
            elseif (strcmp(LEAKAGE_MODEL,'HD')==1)
                V = all_int_values(i_op, bitxor((uint8(plaintext(:,1))),(uint8(ikey-1)))+1);
                V1 = transpose([zeros(1),V]);
                V1(size(V1,1)) = [];
                V2 = transpose(all_int_values(i_op, bitxor((uint8(plaintext(:,1))),(uint8(ikey-1)))+1));
                V1b = dec2bin(V1, 8);
                V2b = dec2bin(V2, 8);
                %tic
                for hdi = 1:size(V1,1)                    
                    Vhd(hdi,1) = bitsize * pdist2(double(V1b(hdi,:)), double(V2b(hdi,:)),'hamming');
                    %Vhd(hdi,1) = disthamming(uint8(V1(hdi,:)),uint8(V2(hdi,:)));
                end
                %toc
                hypotheses(:,ikey) = Vhd;                          
            end
        %display(ikey)
    end


    traces(1,:) = traces(2,:);
    R = corr(traces,double(hypotheses));

b = unique(R.', 'rows').';
if size(b,2) == 256
    F2 = figure;
    title(strcat('Corr. vs Sample Points - ',string(i_op)));
    xlabel('Sample Points');
    ylabel('Correlation');
    %top_plot2 = plot(f,abs((R(:,key+1))), '-', 'LineWidth',2,'color','b', 'DisplayName', '1');
    top_plot2 = plot(abs((R(:,key+1))), '-', 'LineWidth',2,'color','b', 'DisplayName', '1');
    hold on;
    %plot(R);
    CM = gray(10);
    %plot(f,abs(R), '-', 'LineWidth',1,'color',CM(6,:), 'DisplayName',' 0.1');
    plot(abs(R), '-', 'LineWidth',1,'color',CM(6,:), 'DisplayName',' 0.1');
    uistack(top_plot2, 'top')
    title(strcat('VALID - ',string(i_op),' - ', string(all_sbox_functions(i_op,key + 1)), ' -- ', string(all_int_codes(i_op,key + 1))));
    xlabel('Sample Points');
    ylabel('Correlation');
    pause(1);
    cd(myfolder);
    saveas(F2,strcat('VALID_Fig2_intermediate_value_',LEAKAGE_MODEL,'_',string(i_op)));

    disp(["my_max:",max(abs(R(:,key+1))) ,"max_leakage",max(max(abs(R)))])
    if max(abs(R(:,key+1))) > max(max(abs(R)))
        disp('here')
    end
    
    sbox_function_string = string(all_sbox_functions(i_op,key + 1))
    code_string = string(all_int_codes(i_op,key + 1))
    
    file_name = strcat('VALID_R_',LEAKAGE_MODEL,'_',string(i_op));
    %save(file_name, 'sara1', 'f', 'R','key_for_matlab_computation_dec','-v7.3');
    save(file_name, 'hypotheses', 'sbox_function_string','code_string','sara1', 'R','key_for_matlab_computation_dec','-v7.3');
    cd ..
else
    F2 = figure;
    title(strcat('Corr. vs Sample Points - ',string(i_op)));
    xlabel('Sample Points');
    ylabel('Correlation');
    %top_plot2 = plot(f,abs((R(:,key+1))), '-', 'LineWidth',2,'color','b', 'DisplayName', '1');
    top_plot2 = plot(abs((R(:,key+1))), '-', 'LineWidth',2,'color','b', 'DisplayName', '1');
    hold on;
    %plot(R);
    CM = gray(10);
    %plot(f,abs(R), '-', 'LineWidth',1,'color',CM(6,:), 'DisplayName',' 0.1');
    %plot(abs(R), '-', 'LineWidth',1,'color',CM(6,:), 'DisplayName',' 0.1');
    uistack(top_plot2, 'top')
    title(strcat('INVALID - ',string(i_op),' - ', string(all_sbox_functions(i_op,key + 1)), ' -- ',string(all_int_codes(i_op,key + 1))));
    xlabel('Sample Points');
    ylabel('Correlation');
    pause(0.01);
    cd(myfolder);
    saveas(F2,strcat('INVALID_Fig2_intermediate_value_',LEAKAGE_MODEL,'_',string(i_op)));
    
    sbox_function_string = string(all_sbox_functions(i_op,key + 1))
    code_string = string(all_int_codes(i_op,key + 1))
    
    
    file_name = strcat('INVALID_R_',LEAKAGE_MODEL,'_',string(i_op));
    %save(file_name, 'sara1', 'f', 'R','key_for_matlab_computation_dec','-v7.3');
    save(file_name, 'hypotheses', 'sbox_function_string', 'code_string','sara1', 'R','key_for_matlab_computation_dec','-v7.3');
    cd ..
end
    
toc
pause(0.01);
close all;
pause(0.01);
a=1;
end
