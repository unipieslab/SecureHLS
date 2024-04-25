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
%% Design folder creation -- contains all required files
% See also : set_modules.m - Script to create random double modular redundancy enhanced designs

projectname = ".\Designs\";

% Gather all randomly-generated solutions paths
candidate_modules = strings(1,1);

files = dir(projectname);
for k=1:length(files)
    if (contains(files(k).name,"sol_"))

        if ~exist(strcat(projectname,files(k).name,"\directives.tcl"))
            continue;
        end
        candidate_modules(end+1) = strcat(projectname,files(k).name,"\impl\vhdl\");
    end
end

% Remove an extra element that occurs
candidate_modules(:,1) = [];

% Retrieve number of solutions found
num_of_designs = size(candidate_modules,2);

for i=1:num_of_designs

    if ~exist(strcat(projectname,"sol_",string(i-1),"\directives.tcl"))
        continue;
    end

    folderName = strcat(projectname,"design_",string(i-1));

    if exist(folderName,"dir")
        rmdir(folderName,'s')
    end

    mkdir(folderName);
    mkdir(folderName,"Module");
    mkdir(folderName,"FI");
    mkdir(folderName,"Graphs");

    copyfile(strcat(projectname,"sol_",string(i-1),"\directives.tcl"),folderName);

    % Copy vhdl files from sol# to design_#/Module
    module_files = candidate_modules(i);
    module_files = strcat(module_files,"*");
    module = split(module_files,"\");
    copyfile(module_files,strcat(folderName,"\Module"));

    copyfile('.\FI',strcat(folderName,"\FI"));

    %     % Change .vhd file names by adding a "_1"
    %     dinfo = dir( fullfile(strcat(folderName,"\Module"), '*.vhd') );
    %     old_names = {dinfo.name};
    %
    %     new_names = erase(old_names,".vhd");
    %     new_names = strcat(new_names,"_1.vhd");
    %
    %     for f = 1 : length(old_names)
    %         movefile( fullfile(strcat(folderName,"\Module"), old_names{f}), fullfile(strcat(folderName,"\Module"), new_names{f}) );
    %     end

end


