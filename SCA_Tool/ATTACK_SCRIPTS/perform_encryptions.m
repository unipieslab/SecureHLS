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

ca
rng shuffle

addpath(genpath('./utils'));

datapoints    = double(zeros(100, lecroy_num_of_points - 18));
datapointsCH1 = double(zeros(100, lecroy_num_of_points - 18));
datapointsCH2 = double(zeros(100, lecroy_num_of_points - 18));

perform_CPA_every = numofencryptions; % Save the data every # traces.

revealled_key_bytes_int = zeros(1,16, 'uint8');

%key_hex  =     '0000000000000000000000000000D8D8';
key_hex  =     '00000000000000000000000000000000';

counterrors = 0;
% Initialization of AES variables for MATLAB calculation of the ciphertext
reshapedStringKey_matlab_aes = reshape(key_hex,2,16);
hexMtxKey_matlab_aes = reshapedStringKey_matlab_aes.';
%disp(hexMtx);
decMtxKey_matlab_aes = hex2dec(hexMtxKey_matlab_aes);
key_for_matlab_computation_dec = decMtxKey_matlab_aes.';
key_for_matlab_computation_hex = key_hex;

if flag_validate_aes == 1 [s_box, inv_s_box, w, poly_mat, inv_poly_mat] = aes_init(key_for_matlab_computation_dec); end

test_key = uint8(key_for_matlab_computation_dec);

if strcmp(TARGET_DEVICE, 'CW305')==1
    % Python setup for CW305
    path_with_pyscripts = fileparts(which('CW305_FPGA.py'));
    insert(py.sys.path,int32(0),path_with_pyscripts);
    py.CW305_FPGA.loadKey(test_key);
end

result = {};

if flag_capture_oscilloscope == 1; init_SIGLENT_scope; end

for enc_num = 1:numofencryptions

    pause(0.0015);

    write_plaintext;
    
    %tic
    
    % Trace Acquisition from a specific oscilloscope channel
    if flag_capture_oscilloscope == 1 
        if flag_capture_channel == 1
            acquire_SIGLENT_scope_data_CH1;
        end
        if flag_capture_channel == 2
            acquire_SIGLENT_scope_data_CH2;
        end
        if flag_capture_channel == 12
            acquire_SIGLENT_scope_data_CH1;
            acquire_SIGLENT_scope_data_CH2;
        end
    
    end
    
    %toc

   % Control for errors and break on first error!
    if isequal(result(enc_num,3),result(enc_num,6)) == 1
 
    else

        if flag_validate_aes == 1
            counterrors = counterrors + 1;
            display('#######################################################');
            display('# Error detected......................................#');
            display('#######################################################');
            display(counterrors);
        end
        
    end
    
% Save oscilloscope data
    if flag_capture_oscilloscope == 1
       if flag_capture_channel == 1           
           datapointsCH1(enc_num,:)  = C1_num_fixed2;     
       end
       if flag_capture_channel == 2           
           datapointsCH2(enc_num,:)  = C2_num_fixed2;
       end
       if flag_capture_channel == 12           
           datapointsCH1(enc_num,:)  = C1_num_fixed2;
           datapointsCH2(enc_num,:)  = C2_num_fixed2;
           plot(atapointsCH2(enc_num,:));
       end          
    end
    
    if mod(enc_num,perform_CPA_every) == 0 count_total_traces = count_total_traces + 100; display('Captured traces so far #:'); display(count_total_traces); end
    
    if enc_num > 1 && mod(enc_num,perform_CPA_every) == 0 
%         display('Performing CPA attack...'); 
          if flag_capture_oscilloscope == 1 
              %count_saves = count_saves + 1;
              if flag_capture_channel == 1
                  %get_temp;
                  file_name = strcat('attack_data_',num2str(count_saves,'%d'),'.mat');
                  save([pwd strcat('/attack_data/',file_name)], 'sara1','vdiv1','ofst1','tdiv1','plaintexts_SCA','datapointsCH1','result','key_for_matlab_computation_dec');

                  clear datapointsCH1;
              end
              if flag_capture_channel == 2
                  %get_temp;
                  file_name = strcat('attack_data_',num2str(count_saves,'%d'),'.mat');
                  save([pwd strcat('/trigger_data/',file_name)], 'sara2','vdiv2','ofst2','tdiv2','plaintexts_SCA','datapointsCH2','result','key_for_matlab_computation_dec');                  
                  clear datapointsCH2;
              end
              if flag_capture_channel == 12
                  %get_temp;
                  file_name = strcat('attack_data_',num2str(count_saves,'%d'),'.mat');
                  save([pwd strcat('/attack_data/',file_name)], 'sara1','vdiv1','ofst1','tdiv1','plaintexts_SCA','datapointsCH1','result','key_for_matlab_computation_dec');
                  save([pwd strcat('/trigger_data/',file_name)], 'sara2','vdiv2','ofst2','tdiv2','plaintexts_SCA','datapointsCH2','result','key_for_matlab_computation_dec');                  
                  clear datapointsCH1;
                  clear datapointsCH2;
              end
          end 
          clear result; 
          clear plaintexts_SCA;
    end
end

if flag_capture_oscilloscope == 1
    fclose(vu); 
    delete(vu); 
    clear vu;
end