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

fprintf(vu,'c1:wf? dat2');
outputbuffer1 = fread(vu,lecroy_num_of_points,'uint8');
%pause(0.1);
outputbuffer1 = transpose(outputbuffer1);
%pause(0.1);

if enc_num == 1
    fprintf(vu,'chdr off');

    fprintf(vu,'c1:vdiv?');
    vdiv1 = fscanf(vu);

    fprintf(vu,'c1:ofst?');
    ofst1 = fscanf(vu);

    fprintf(vu,'tdiv?');
    tdiv1 = fscanf(vu);

    fprintf(vu,'sara?');
    sara1 = fscanf(vu);
end

%pause(0.1);


C1_num = int16(outputbuffer1);
if size(C1_num,2) > 18
    C1_num(1:18) = [];
end

for i1=1:size(C1_num,2)
   
    if C1_num(i1) > 127
      C1_num_fixed(i1) = C1_num(i1) - 255;
   else
      C1_num_fixed(i1) = C1_num(i1);
      %continue;
   end
end

a1=double(str2num(vdiv1));
b1=str2num(ofst1);
C1_num_fixed2 = double(C1_num_fixed);
for idx1=1:size(C1_num_fixed2,2)
    code1 = C1_num_fixed2(idx1);
    tmp1 = double(code1)*(a1/25);
    aa1 = tmp1-b1;
    C1_num_fixed2(idx1) = aa1;
end
