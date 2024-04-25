%%Copyright (C) 2023  Amalia-Artemis Koufopoulou, Kalliopi Xevgeni, Athanasios Papadimitriou, Mihalis Psarakis, David Hely

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

clearvars

%% Automated replacing of redundant elements in _registers.txt files

% read multiplicity of attack
filename = '.\Constants\MODE.txt';
fid = fopen(filename);

M = str2num(fgetl(fid));

fclose(fid);

% read input from input.txt
filename = '.\Constants\INPUT.txt'; 
fid = fopen(filename);

input = fgetl(fid);

fclose(fid);

projectname = ".\Designs\";

% Gather all designs paths
paths = strings(1,1);
paths_ext = strings(1,1);

% Get all _registers.txt files from the correspinding design_ folders
files = dir(projectname);
for k=1:length(files)
    if (contains(files(k).name,"design_"))
        paths(end+1) = strcat(files(k).folder,"\",files(k).name,"\FI");
        paths_ext(end+1) = strcat(files(k).folder,"\",files(k).name,"\xsim\cmd.tcl");
    end
end

paths(:,1) = [];
paths_ext(:,1) = [];

for i=1:size(paths,2)

    fid = fopen(paths_ext(i),'w');

    % Add 'cd' to path
    paths(i)
    paths(i) = replace(paths(i),'\','/');
    fprintf(fid,'set d %s\n',paths(i));

    % Add FI script to be used, according to MM set

    if (M == 1)
        fi_fid = fopen('.\Attack_Scenarios\FI_script_SBF.tcl');
    elseif (M == 2)
        fi_fid = fopen('.\Attack_Scenarios\FI_script_M2.tcl');
    elseif (M == 3)
        fi_fid = fopen('.\Attack_Scenarios\FI_script_M3.tcl');
    elseif (M == 4)
        fi_fid = fopen('.\Attack_Scenarios\FI_script_M4.tcl');
    elseif (M == 5)
        fi_fid = fopen('.\Attack_Scenarios\FI_script_M5.tcl');

    end

    % Write input value
    tline = fgetl(fi_fid);

    while ischar(tline)
        if (contains(tline,"{*** 0ns}"))
            tline = replace(tline,"***",input);
        end
        fprintf(fid,'%s\n',tline);
        tline = fgetl(fi_fid);
    end

    fclose(fi_fid);

    % Add quit
    fprintf(fid,'quit\n');

    fclose(fid);
end