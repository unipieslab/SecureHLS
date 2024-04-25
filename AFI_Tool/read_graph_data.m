%%Copyright (C) 2023  Amalia-Artemis Koufopoulou, Athanasios Papadimitriou, Aggelos Pikrakis, Mihalis Psarakis, David Hely

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
tic
%% This script is optional for the flow
% Call it by adding the following command in the run.cmd file, after vivado -mode tcl -source vivado_script.tcl :

% matlab -nosplash -nodesktop -r "run ('read_graph_data.m'); quit"


%% First run python script to parse edif as graph

pyExec = '<YOUR_PATH>\miniconda3\envs\spyder-env\python.exe';
pyRoot = fileparts(pyExec);
p = getenv('PATH');
p = strsplit(p, ';');
addToPath = {
    pyRoot
    fullfile(pyRoot, 'Library', 'mingw-w64', 'bin')
    fullfile(pyRoot, 'Library', 'usr', 'bin')
    fullfile(pyRoot, 'Library', 'bin')
    fullfile(pyRoot, 'Scripts')
    fullfile(pyRoot, 'bin')
    };
p = [addToPath(:); p(:)];
p = unique(p, 'stable');
p = strjoin(p, ';');
setenv('PATH', p);

command = "python ./graph_gen.py";
system(command);

%% Then parse the output texts to transform them to matlab .mat

projectname = ".\Designs\";

% Gather all design edif paths
paths = strings(1,1);
designs = strings(1,1);

files = dir(projectname);
for k=1:length(files)
    if (contains(files(k).name,"design_"))
        if ~exist(strcat(projectname,files(k).name,"\Graphs\")) || ~exist(strcat(projectname,files(k).name,"\Graphs\design.edf"))

            
            f = strcat(projectname,files(k).name);
            disp(strcat("Removing:",f))
            n = strcat(projectname,"remove\",files(k).name);
            movefile (f,n);

        else

            paths(end+1) = strcat(projectname,files(k).name,"\Graphs\");
            designs(end+1) = strcat(projectname,files(k).name,"\Graphs\design.edf");
        end
    end
end

% Remove an extra element that occurs
paths(:,1) = [];
designs(:,1) = [];

% Retrieve number of solutions found
num_of_designs = size(designs,2);


global_IO = strings(1,1);
global_FU = strings(1,1);
global_PROB = strings(1,1);
global_TT = strings(1,1);

for i=1:num_of_designs

    %% Step 1 : Parse adj_matrix.txt
    % The file contains multiple lines of thre elements:
    %   The row index (source node)
    %   The col index (destination node), ONLY IF a connection exists (
    %   symbolized as 1 in the third element)

	
    paths(i)

    filename = strcat(paths(i),'adj_matrix.txt');
    fid = fopen(filename);

    t = [];

    tline = fgetl(fid);

    % Parse file
    while ischar(tline)

        line = split(tline," ");

        t(end+1) = str2num(line{1,1});
        t(end+1) = str2num(line{2,1});

        tline = fgetl(fid);

    end

    fclose(fid);

    % Faster if we first read the file, derive the size of adjacency matrix
    % (row x row, since it is square)

    %number_of_nodes = str2num(line{1,1});
    number_of_nodes = max(t);
    A = zeros(number_of_nodes+1,number_of_nodes+1);

    fid = fopen(filename);

    tline = fgetl(fid);

    % Parse file again
    while ischar(tline)

        line = split(tline," ");

        % will add obne because matlab indices start from 1, not 0
        row = str2num(line{1,1});
        col = str2num(line{2,1});

        % A(row+1,col+1) = 1;                    % simple adjacency matrix
        A(row+1,col+1) = str2num(line{3,1});    % weighted adjacency matrix

        tline = fgetl(fid);
    end

    fclose(fid);


    %     % Remove self loops
    %     for r=1:size(A,1)
    %             A(r,r) = 0;
    %     end

    %% Step 2 : Parse node_id.txt
    % The file contains the names (labes) of each node

    nodenames = strings(1,1);

    filename = strcat(paths(i),'node_id.txt');
    fid = fopen(filename);

    tline = fgetl(fid);

    %     idx_vcc = 0;
    %     idx_gnd = 0;

    node_PIO = strings(2,1);
    pi = "0";
    po = "0";

    % Parse file
    while ischar(tline)

        % + and - in functional unit name indicate that the FU is connected to a
        % primary input and output -- smarter way?

        % We need to count them
        % Pass the info to a new table, retaining the node index
        % (if pio is not contained, just add 0)
        % and remove them from the fu name to be added to node_FU

        if contains(tline,"+") || contains(tline,"-")

            t = split(tline," ");
            [occ,type] = groupcounts(t);
            for ii = 1:size(type,1)
                if contains(string(t{ii,1}),"+")
                    pi = string(str2num(pi)+occ(ii));
                elseif contains(string(t{ii}),"-")
                    po = string(str2num(pi)+occ(ii));
                end
            end
            tline = string(t(1));

        end

        node_PIO(1,end+1) = pi;
        node_PIO(2,end) = po;
        pi="0";
        po="0";
        nodenames(end+1) = string(tline);
        tline = fgetl(fid);
    end

    fclose(fid);

    % Step 3 : Parse node_FU.txt
    % The file contains the names (labes) of each node

    node_FU = strings(1,1);

    filename = strcat(paths(i),'node_FU.txt');
    fid = fopen(filename);

    tline = fgetl(fid);

    % Parse file
    while ischar(tline)

        node_FU(end+1) = string(tline);
        tline = fgetl(fid);

    end

    fclose(fid);

    nodenames(1) = [];
    node_FU(1) = [];

    node_PIO(:,1)  =[];

    NodeTable = table(nodenames.',node_FU.','VariableNames',{'Name','Functional Units'});

    % Non-unique nodes exist!



    % Find the indexes of occurences,
    % update adj_matrix according to the
    % other occ, then delete the other occurences
    for ii = 1:size(NodeTable)-1
        rows = NodeTable.Name==NodeTable.Name(ii);
        T = NodeTable(rows,:);
        if size(T,1) ~= 1
            occ_idx = find(rows==1);
            for j=size(occ_idx):-1:2

                % ------------------------RETHINK--------------------------

                A(occ_idx(1),:) = A(occ_idx(1),:) + A(occ_idx(j),:);
                A(:,occ_idx(1)) = A(:,occ_idx(1)) + A(:,occ_idx(j));

                A(occ_idx(j),:) = [];
                A(:,occ_idx(j)) = [];

                % ---------------------------------------------------------
                %
                %                 A(occ_idx(1),:) = A(occ_idx(1),:) + A(occ_idx(j),:);
                %                 A(:,occ_idx(1)) = A(:,occ_idx(1)) + A(:,occ_idx(j));
                %                 A(occ_idx(j),:) = [];
                %                 A(:,occ_idx(j)) = [];

                NodeTable(occ_idx(j),:) = [];
                node_PIO(:,occ_idx(j)) = [];
            end
        end

        if ii == size(NodeTable,1)
            break;
        end
    end

    % In the adjacency matrix, values of 2 will occur, but 1 wire only exists!
    %     T = find(A == 2);
    %     for r =1:size(T)
    %         A(T(r)) = 1;
    %     end

    G = digraph(A,NodeTable);

    %% Get Pytorch Data - mynodes and myedges

    graph4PyG

    %save(strcat(paths(i),'matlab_graph.mat'));
    %plot(G,'Interpreter', 'none')

    %clearvars -except 'A' 'NodeTable' 'G' 'paths' 'i' node_PIO

    %% Get truth tables for nodes and add new features to mynodes

    %     truth_tables
    %
    %
    %     for j=1:size(mynodes,2)
    %         FU = strcat(" ",mynodes(4,j)," ");
    %
    %         idx = find(strcmp(new_db(:,1),FU));
    %         mynodes(7,j) = new_db(idx,2);
    %
    %         idx = find(strcmp(fault_probabilities(:,1),FU));
    %         mynodes(8,j) = fault_probabilities(idx,2);
    %     end
    %
    %     neighbors
    %clearvars -except 'truth_tables' 'designs' 'paths' 'i' 'mynodes' 'myedges'


    %Clear any GND or VCC appearing

    for n=1:size(mynodes,2)
        if mynodes(4,n) == "GND" || mynodes(4,n) == "VCC"
            mynodes(:,n) = [];
            A(:,n) = [];
            A(n,:) = [];
        end
    end

    if ~size(mynodes,2) == size(A,1)
        break;
    end
    
    save(strcat(paths(i),'matlab_graph.mat'),"A","mynodes","myedges");

    %add mynodes to global_mynodes!

%     % Only scalar data
%     temp_mynodes = mynodes;
%     %temp_mynodes(8,:) = [];
%     %temp_mynodes(7,:) = [];
%     temp_mynodes(4,:) = [];
%     %temp_mynodes(1,:) = [];
%     temp_mynodes = unique(temp_mynodes);
%     global_IO = [global_IO temp_mynodes.'];
% 
%     % Only FUs
%     temp_mynodes = mynodes(4,:);
%     temp_mynodes = unique(temp_mynodes);
%     global_FU = [global_FU temp_mynodes];
% 
%     %     % Only truth table
%     %     temp_mynodes = mynodes(7,:);
%     %     temp_mynodes = unique(temp_mynodes);
%     %     global_TT = [global_TT temp_mynodes];
%     %
%     %     % Only probability
%     %     temp_mynodes = mynodes(8,:);
%     %     temp_mynodes = unique(temp_mynodes);
%     %     global_PROB = [global_PROB temp_mynodes];
% 
%     if i==1
%         global_IO(:,1) = [];
%         global_FU(:,1) = [];
%         global_TT(:,1) = [];
%         global_PROB(:,1) = [];
%     else
%         global_IO = unique(global_IO);
%         global_FU = unique(global_FU);
%         global_TT = unique(global_TT);
%         global_PROB = unique(global_PROB);
%     end
% 
% end


% g_IO = str2double(global_IO);
% %g_IO = sort(g_IO);
% g_TT = str2double(global_TT);
% %g_TT = sort(g_TT);
% g_PROB = str2double(global_PROB);
% %g_PROB = sort(g_PROB);
% g_FU = global_FU;
% %g_FU = sort(g_FU);
% 

% 
% temp_3 = categorical(g_PROB);
% ohe_3 = onehotencode(temp_3,1);
% 
% clear global_IO global_FU global_PROB global_TT mynodes

end

%load(".\this_workspace.mat",'ohe','ohe_2','mynodes_size','g_IO','g_FU');

%%


g_IO = [0:200];
g_FU = ["RTL_INV","RTL_AND","RTL_OR","RTL_XOR","RTL_RAM","RTL_ROM","RTL_MUX","RTL_ADD","RTL_MULT","RTL_SUB","RTL_EQ","RTL_RSHIFT","RTL_REG"];

temp = categorical(g_IO);
ohe = onehotencode(temp,1);
% 
temp_2 = categorical(g_FU);
ohe_2 = onehotencode(temp_2,1);

mynodes_size = size(ohe,1) +size(ohe_2,1) ;

data2ohe;


log_filename = 'log_file.txt';

log_fid = fopen(log_filename,'a');
fprintf(log_fid,'Graph parsings done \n');
fclose(log_fid);

%s2_write_graph_data
s2_write_graph_data_v2

toc



