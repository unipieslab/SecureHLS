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

projectname = ".\Designs\";

%  Set counter for registers. 
registerCount = 0;

% Create new file (registers.txt), with proper naming FF naming:
% Replace _reg_reg occurences with _reg
% Replace _reg[ occurences with [

% NEW : remove _reg altogether

% Gather all designs paths
paths = strings(1,1);

% Get all _registers.txt files from the correspinding design_ folders
files = dir(projectname);
for k=1:length(files)
    if (contains(files(k).name,"design_"))
        paths(end+1) = strcat(projectname,files(k).name,"\");
    end
end

paths(:,1) = [];

for i=1:size(paths,2)

projectname = paths(1,i); %just so that not to change projectname variable use below. It should be ;)

old_filename = strcat(projectname,'FI\_registers.txt');
new_filename = strcat(projectname,'FI\registers.txt');

old_fid = fopen(old_filename);
new_fid = fopen(new_filename,'w');

tline = fgetl(old_fid);

tline = fgetl(old_fid); %skip first line

while ischar(tline)

	if ~isequal(tline,'\n')
		tline = tline(find(~isspace(tline)));
        if contains(tline,"input")
            tline = fgetl(old_fid);
            continue;
        end
		if (contains(tline,"_reg_reg"))
			tline = replace(tline,"_reg_reg","_reg");
		elseif (contains(tline,"_reg["))
			tline = replace(tline,"_reg[","[");
		elseif (contains(tline,"_reg")) 
			tline = replace(tline,"_reg","");
        end

        %if (contains(tline,"srl"))         %Dummy solution, resolve
        %    tline = regexprep(tline, '_srl\d*', '');
        %elseif (contains(tline,"inv"))         %Dummy solution, resolve
        %    tline = regexprep(tline, '_inv\d*', '');
        %end
		
		fprintf(new_fid,'%s\n',tline);
		registerCount = registerCount + 1;
		tline = fgetl(old_fid);
	end
end

fclose(old_fid);
fclose(new_fid);

% _register.txt no longer required -- leave for debug
%delete(old_filename);

% Verification of #FFs
%log_filename = 'log_file.txt';

%log_fid = fopen(log_filename,'a');
%fprintf(log_fid,'%s -- %s FFs FOUND \n',projectname,num2str(registerCount));
%fclose(log_fid);
end


