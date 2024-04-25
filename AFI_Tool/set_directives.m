%%Copyright (C) 2023  Amalia-Artemis Koufopoulou, Kalliopi Xevgeni, Athanasios Papadimitriou , Mihalis Psarakis, David Hely

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
rng('shuffle');
%% Version 4
% Get functions from code
% Enable or disable inling randomly, in a random number of functions
% Apply a random number of directives in functions (ex. 1 up to 3)
% (No need for 0, since we've already picked functions)

% Passed *generic* directives (probably with some effect, we need more
% information in certain cases - ex. operation allocation)
% top function is excluded from directives because of issues

projectname = ".\Designs\";

top_function = "top_function";

filename = 'code.c';

fid = fopen(strcat(projectname,filename));

funcRegEx = "(static )*(void|int|uint8_t|uint16_t)+ \w+\(";
forRegEx = "(label_[0-9]+)(_[0-9]+)*:"; % both simple and nested

tline = fgetl(fid);

functions = strings(1,1);

loops = strings(1,1); % keep label - TODO : #iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Directive's Pool (Functions)                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Limit on modules resulting from a function - extreme, set to 1
directives{1} = {'set_directive_allocation -limit 1 -type function "<>" <>'};

% Limit on operation of set function
% The following don't exclude one another + use of core might be smarter?
directives{2} = {'set_directive_allocation -limit 1 -type operation "<>" add','set_directive_allocation -limit 1 -type operation "<>" mul','set_directive_allocation -limit 1 -type operation "<>" icmp ','set_directive_allocation -limit 1 -type operation "<>" lshr','set_directive_allocation -limit 1 -type operation "<>" ashr','set_directive_allocation -limit 1 -type operation "<>" shl'};

% Dataflow analyses the C flow beforehands, seeking opportunities to retrieve data required
% by a function before they are returned as result from another
%directives{3} = {'set_directive_dataflow ','set_directive_dataflow -disable_start_propagation '};

% By default, Vivado HLS will rearrange the operations to create a balanced execution tree
% potentially reducing latency at the cost of extra hardware.
directives{3} = {'set_directive_expression_balance -off '};

% Inline - off, region (effect on one level below) recursive (effect on all levels below)
directives{4} = {'set_directive_inline ','set_directive_inline -off ','set_directive_inline -region ','set_directive_inline -region -off ','set_directive_inline -recursive '};

% Disables control signals, allowing continuious flow
%directives{5} = {'set_directive_interface -mode ap_ctrl_none '};

% Pipelines in an extreme way (II set to 1), with or without flush enabled
directives{5} = {'set_directive_pipeline -II 1 ','set_directive_pipeline -enable_flush '};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Directive's Pool (Loops)                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dataflow
loop_directives{1} = {'set_directive_dataflow ','set_directive_dataflow -disable_start_propagation '};

% Loop flatten - Only nested loops
%loop_directives{2} = {'set_directive_loop_flatten ','set_directive_loop_flatten -off '};

% Loop pipeline
loop_directives{2} = {'set_directive_pipeline -II 1 ','set_directive_pipeline -enable_flush ','set_directive_pipeline -rewind ','set_directive_pipeline -off '};

% Loop unroll - Full, regional (nested loops are not unrolled) and partial
% (factor is set to common prime numbers)
loop_directives{3} = {'set_directive_unroll  ','set_directive_unroll -region ','set_directive_unroll -factor 2 ','set_directive_unroll -factor 3 ','set_directive_unroll -factor 5 ','set_directive_unroll -factor 7 '};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse .c code to get functions' names
% Also, exclude top function and its loops from directives use

while ischar(tline)

    % Match name with regex, split to ge the name and add to "functions"
    if(~isempty(regexp(tline,funcRegEx,'match')) && ~(contains(tline,top_function)))
        funcDef = split(tline,"(");
        funcName = split(funcDef(1)," ");
        functions(end+1,1) = string(funcName(end));
    elseif(~isempty(regexp(tline,forRegEx,'match'))&& ~(contains(tline,top_function)))
        forDef = split(tline,":");
        % Weird : An indent symbol (arrow) appears before label
        % It is best to remove "label" and add it afterwards
        temp = split(forDef(1) ,"label");
        forName = strcat("label",temp(2));
        % definition id funcName\forName
        loops(end+1,1) = strcat(functions(end,1),"\",forName);
    end

    tline = fgetl(fid);
end

fclose(fid);

% Remove an extra element that occurs
functions(1,:) = [];
loops(1,:) = [];

%%% Create directive files
%for num=1:10
%directive_file = strcat(".\directives\directives_",string(num),".tcl")
directive_file = strcat("random_directives.tcl");

%% Determine functions

% Randomly generate the number of functions that directives will be applied
% (ex 5 out of 20)
s = size(functions,1);
%num_of_functions = randi(s);
num_of_functions = s;

% Generate the indices of the functions that directives will be applied in a unique manner
% (ex. define which 5 out of the 20 functions? -> [7,4,11,20,1]
idx = randperm(s,num_of_functions);

% Add the names in a new structure, functions_dir
s = size(directives,2);
functions_dir = strings(1,1+s); % +1 because we use end+1 for appending - remove the extra after the loop

for i=1:size(idx,2)
    functions_dir(end+1,1) = functions(idx(i));
end

functions_dir(1,:) = [];

%% Determine loops

% Randomly generate the number of functions that directives will be applied
% (ex 5 out of 20)
s = size(loops,1);
%num_of_loops = randi(s);
num_of_loops = s;

% Generate the indices of the functions that directives will be applied in a unique manner
% (ex. define which 5 out of the 20 loops? -> [7,4,11,20,1]
idx = randperm(s,num_of_loops);

% Add the names in a new structure, loop_dir
s = size(loop_directives,2);
loops_dir = strings(1,1+s); % +1 because we use end+1 for appending - remove the extra after the loop

for i=1:size(idx,2)
    loops_dir(end+1,1) = loops(idx(i));
end

loops_dir(1,:) = [];
%clearvars -except functions_dir directives loop_directives line loops_dir directive_file

%% Determine directives - functions

s=size(directives,2);

for i=1:size(functions_dir,1)

    j = 2;

    % For each function, randomly pick the #groups of directives
    num_of_dir = randi(s);

    % Then generate the indices of the groups
    idx = randperm(s,num_of_dir);

    for d=1:num_of_dir

        % Randomly pick ONE directive from each group

        ss = size(directives{idx(d)},2);
        dir = randi(ss);


        functions_dir(i,j) = string(directives{idx(d)}{dir});
        j = j+1;


    end

end

%% Determine directives - loops

s=size(loop_directives,2);

for i=1:size(loops_dir,1)

    j = 2;

    % For each function, randomly pick the #groups of directives
    num_of_dir = randi(s);

    % Then generate the indices of the groups
    idx = randperm(s,num_of_dir);

    for d=1:num_of_dir

        % Randomly pick ONE directive from each group

        ss = size(loop_directives{idx(d)},2);
        dir = randi(ss);

        loops_dir(i,j) = string(loop_directives{idx(d)}{dir});

        j = j+1;
    end

end

%% Write directives.tcl
fid = fopen(strcat(projectname,directive_file),'w');
time = datestr(clock,'YYYY/mm/dd HH:MM:SS:FFF');
fprintf(fid,'%s\n',strcat('#',time));

% write function directives
for i=1:size(functions_dir,1)

    if (contains (functions_dir(i,2),"allocation"))
        %line = strcat(functions_dir(i,2),'"',functions_dir(i,1),'"'," ",functions_dir(i,1));
        line = replace(functions_dir(i,2),'<>',functions_dir(i,1));
    else
        line = strcat(functions_dir(i,2),'"',functions_dir(i,1),'"');
    end
    fprintf(fid,'%s\n',line);

end

% write loop directives
for i=1:size(loops_dir,1)

    line = strcat(loops_dir(i,2),'"',loops_dir(i,1),'"');

    fprintf(fid,'%s\n',line);

end


fid = fclose(fid);
%end

