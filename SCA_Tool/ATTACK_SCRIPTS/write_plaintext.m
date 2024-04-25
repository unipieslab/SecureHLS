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


% Generate random plaintext in hex format 

% Shuffle the seed for random number generation by means of current time
%rng shuffle
error_in_first_enc = 0;
% Generate a random 128 bit binary number
random_plaintext_bin = num2str(randi(2,1,128)-1);

random_plaintext_bin(strfind(random_plaintext_bin,' ')) = [];


reshapedString_plaintext = reshape(random_plaintext_bin,16,8);
hexMtx_plaintext = reshapedString_plaintext.';
plaintext_bin8bits = [];
for i = 1:8
    temp1 = hexMtx_plaintext(i,:);
    temp2 = reshape(temp1,8,2);
    temp3 = temp2.';
    plaintext_bin8bits = cat(1, plaintext_bin8bits, temp3);
    
end

random_plaintext_hex = bin2hex(random_plaintext_bin);
reshapedString = reshape(random_plaintext_hex,2,16);
hexMtx = reshapedString.';
%disp(hexMtx);
decMtx = hex2dec(hexMtx);
%disp(decMtx);

% Compute the ciphertext in MATLAB:
plaintext = decMtx.';

if flag_validate_aes == 1 
    ciphertext_matlab_dec = cipher (plaintext, w, s_box, poly_mat);%, 1);
    ciphertext_matlab_hex = dec2hex(ciphertext_matlab_dec);
    reshapedStringResult_ciphertext_matlab = ciphertext_matlab_hex.';
    reshapedStringResult_ciphertext_matlab = reshape(reshapedStringResult_ciphertext_matlab,1,32);
end

intVector = uint8(decMtx);

for k = 1:16
    sendbyte(k) = intVector(k);
end

% Transform to send to CW305 the data xor key.
sendDxorK = uint8(zeros(1,16));
sendkey = uint8(key_for_matlab_computation_dec); % Save the encryption key in this variable

for s = 1:16
    sendDxorK(s) = bitxor(sendbyte(s), sendkey(s));
end

plaintexts_SCA(enc_num,:) = sendbyte.'; % Save the plaintext in this variable


if (strcmp(acquisition_mode,'NORMAL'))
    if strcmp(TARGET_DEVICE, 'CW305')==1
        py.CW305_FPGA.loadPlaintext(sendDxorK);
        pause(0.000001);
        py.CW305_FPGA.goCW305();
        pause(0.000001);
        ciphertext = py.CW305_FPGA.readCiphertext();
        pause(0.000001);
        ciphertext_uint8 = uint8(ciphertext);
        ciphertext_hex = dec2hex(ciphertext_uint8);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          RESULTS SETUP                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reshapedStringResult = ciphertext_hex.';
reshapedStringResult = reshape(reshapedStringResult,1,[]); 

result{enc_num,1} = key_for_matlab_computation_hex;
result{enc_num,2} = key_for_matlab_computation_dec;

if flag_validate_sbox == 1 result{enc_num,3} = reshapedStringResult_ciphertext_matlab; end

result{enc_num,4} = key_hex; 

random_plaintext_hex_8bit = dec2hex(plaintexts_SCA(enc_num,:));
reshapedrandom_plaintext_hex_8bit = random_plaintext_hex_8bit.';
reshapedrandom_plaintext_hex_8bit = reshape(reshapedrandom_plaintext_hex_8bit,1,[]);

result{enc_num,5} = reshapedrandom_plaintext_hex_8bit;%random_plaintext_hex;
result{enc_num,6} = reshapedStringResult;

sendDxorK_sbox = dec2hex(SubBytes(sendDxorK + 1));
sendDxorK_sbox_hex = sendDxorK_sbox.';
sendDxorK_sbox_hex = reshape(sendDxorK_sbox_hex,1,[]);

result{enc_num,7} = sendDxorK_sbox_hex;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(TARGET_DEVICE, 'CW305')==1
    if isequal(result(enc_num,6),result(enc_num,7)) == 1
    else       
        if flag_validate_sbox == 1
            counterrors = counterrors + 1;
            display('#######################################################');
            display('#....................Error detected...................#');
            display('#######################################################');
            display(counterrors);
        end        
    end
end