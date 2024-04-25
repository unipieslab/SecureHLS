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

fprintf(vu,'c2:wf? dat2');
outputbuffer2 = fread(vu,lecroy_num_of_points,'uint8');
%pause(0.1);
outputbuffer2 = transpose(outputbuffer2);
%pause(0.1);

if enc_num == 1
    fprintf(vu,'chdr off');

    fprintf(vu,'c2:vdiv?');
    vdiv2 = fscanf(vu);

    fprintf(vu,'c2:ofst?');
    ofst2 = fscanf(vu);

    fprintf(vu,'tdiv?');
    tdiv2 = fscanf(vu);

    fprintf(vu,'sara?');
    sara2 = fscanf(vu);
end

%pause(0.1);


C2_num = int16(outputbuffer2);
if size(C2_num,2) > 18
    C2_num(1:18) = [];
end

for i2=1:size(C2_num,2)
   
    if C2_num(i2) > 127
      C2_num_fixed(i2) = C2_num(i2) - 255;
   else
      C2_num_fixed(i2) = C2_num(i2);
      %continue;
   end
end

a2=double(str2num(vdiv2));
b2=str2num(ofst2);
C2_num_fixed2 = double(C2_num_fixed);
for idx2=1:size(C2_num_fixed2,2)
    code2 = C2_num_fixed2(idx2);
    tmp2 = double(code2)*(a2/25);
    aa2 = tmp2-b2;
    C2_num_fixed2(idx2) = aa2;
end
