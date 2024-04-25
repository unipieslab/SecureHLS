%%Copyright (C) 2023  Amalia-Artemis Koufopoulou, Kalliopi Xevgeni, Ioanna Souvatzoglou, Athanasios Papadimitriou, Mihalis Psarakis, David Hely

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


%This function generates ALL fault vectors to be attacked (M2 to M5)

function generateFaultPairs(design,end_time)
tic

disp(design);
disp(end_time);

scriptPath = fileparts(mfilename('fullpath'));
parentDirectory = fileparts(scriptPath);

path = "\AFI_Tool\Designs\design_";

path = strcat(parentDirectory,path,string(design));

rng('shuffle');

attack_pair = strings(1,4);
module_signals = strings(1,1);

% Read execution time, derived from the gold run of the current design
cc = end_time/10;

% Read register.txt and divide signals per module
filename = strcat(path,'\FI\registers.txt');

fid = fopen(filename);

tline = fgetl(fid);

while ischar(tline)

    module_signals(end+1) = tline;

    tline = fgetl(fid);

end

fclose(fid);

module_signals(:,1) = [];

% Set number of signal pairs to be attacked using the statistical method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
instructions = cc; % #clock cycles
current_set_size = size(module_signals,2);%# of FFs

filename = strcat(parentDirectory,'\AFI_tool\Constants\MODE.txt'); %contains multiplicity of attack
fid = fopen(filename);

m = fgetl(fid);
M = str2num(m);

fclose(fid);

filename = strcat(parentDirectory,'\AFI_tool\Constants\ERROR_MARGIN.txt'); %contains multiplicity of attack
fid = fopen(filename);

em = fgetl(fid);
e= str2num(em); % e is the desired margin of error, it is 0<e<1 (percentage %). ex. 0.05 = 5%

fclose(fid);

%e = 0.01;  

Z = 2.5758;       % 1.96 corresponds to 95% confidence.  2.5758 corresponds to 99% confidence
pinit = 0.5;    % pinit is the initial percentage estimation in order to compute.
% n, which is the required number of samples in each set.
% worst case scenario is for pinit = 0.5
N = 0;          % N is the population being sampled, here it is just initialized.
%psample = 0;    % psample is the percentage of the proportion of the sample that
% fullfills a specific property.
n = 0;          % n is the sample size required to achieve a specific margin of error

% Now calculate the size of the population. a.k.a. the combinations of
% (setsize) by M of the current set.
%current_set_size = NUMBER_OF_BITS_OF_ALL_REGISTERS; %size(grab_my_row,2);
% Here I must make sure that M is smaller or equal to current_set_size

if current_set_size > M
    N = nchoosek(current_set_size,M);
elseif current_set_size == M
    N = nchoosek(current_set_size,M);
else %current_set_size < M
    N = 1; % In this case there is only one sample to take.
    M = current_set_size; % The multiplicity can only be as large as the set size.
end

N = instructions * N;

ntemp = N/(1 +((e^2)*((N-1)/((Z^2)*pinit*(1-pinit)))));

n = round(ntemp); % Here we have our sample size

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_of_gen = n;
num_of_pairs = n

attack_pair = strings(n,M*2); %two attack_pair elements for each fault - signal & attack time

for i=1:num_of_gen

    % First, pick a random signal from module_signals

    % Then, determine the attack time step

    % First get the attack cycle
    % First cycle (1) is reserved for initilization, so it's avoided
    % Attacks are performed every 10 ns, hence the division by 10

    % Re-do : Create two vectors for signals and times per attack (row of attack_pair)
    % and order everything by the time vector. Will make things easier for the script.

    attack_cycle = [];
    ridx = [];

    for m=1:M
        attack_cycle(end+1) = randi([1 cc]);
        ridx(end+1) = randi([1 size(module_signals,2)]);
    end

    [attack_cycle,sortIdx] = sort(attack_cycle);
    ridx = ridx(sortIdx);

    m = 1;
    for j=1:2:M*2
        attack_pair(i,j) = module_signals(ridx(m));
        attack_pair(i,j+1) = string(attack_cycle(1) * 10);
        m=m+1;
    end

    % Repeat for next pair
end


fid = fopen(strcat(path,'\FI\M',num2str(M),'_registers.txt'),'w');

for i=1:size(attack_pair,1)
    for j=1:size(attack_pair,2)
        fprintf(fid,'%s--',attack_pair(i,j));
    end
    fprintf(fid,'\n');
end

fclose(fid);

toc

end