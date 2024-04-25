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


vu = visa('ni',''); % Add SIGLENT INSTRUMENT ID
vu.InputBufferSize = 100000000;
fopen(vu);
fprintf(vu,'WFSU SP,0,NP,0,FP,0');
fprintf(vu,'EXT:TRSL POS'); % Sets the trigger slope
format long