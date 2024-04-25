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


mynodes ="";
myedges ="";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:size(NodeTable,1)
        mynodes(1,j) = string(NodeTable{j,1});
    end
    for j=1:size(G.Edges.EndNodes,1)
        myedges(j,1) = string(G.Edges.EndNodes{j,1});
        myedges(j,2) = string(G.Edges.EndNodes{j,2});
    end

    mystr1 = '';
    mystr2 = '';
    for j=1:size(G.Edges.EndNodes,1)
        if (j < size(G.Edges.EndNodes,1))
            tmpstr1 = G.Edges.EndNodes(j,1);
            tmpstr2 = G.Edges.EndNodes(j,2);
            str1 = string(tmpstr1{1});
            str2 = string(tmpstr2{1});
            Index1 = int64(find(strcmp(mynodes,str1)));
            Index2 = int64(find(strcmp(mynodes,str2)));
            mystr1 = strcat(mystr1, num2str(Index1),', ');
            mystr2 = strcat(mystr2, num2str(Index2),', ');
        else
            tmpstr1 = G.Edges.EndNodes(j,1);
            tmpstr2 = G.Edges.EndNodes(j,2);
            str1 = string(tmpstr1{1});
            str2 = string(tmpstr2{1});
            Index1 = int64(find(strcmp(mynodes,str1)));
            Index2 = int64(find(strcmp(mynodes,str2)));
            mystr1 = strcat(mystr1, num2str(Index1));
            mystr2 = strcat(mystr2, num2str(Index2));
        end
    end
    edge_index = strcat('edge_index = torch.tensor([[', mystr1, '], [', mystr2, ']], dtype=torch.long)');

    %clearvars -except A A_real NodeTable G mynodes myedges paths i node_PIO

    % Add number of node inputs in mynodes[2]
    % Get from A the total 1s per column (self loop included)
    % The indices of mynodes correspond to those of A
    inputs = sum(A,1);
    for j=1:size(mynodes,2)
        mynodes(2,j) = string(inputs(j));
    end

    % Add number of node outputs in mynodes[3]
    % Get from A the total 1s per row (self loop included)
    % The indices of mynodes correspond to those of A
    outputs = sum(A,2);
    for j=1:size(mynodes,2)
        mynodes(3,j) = string(outputs(j));

        % Add REF_NAMES from NodeTable{2} in mynodes[4]
        % The indices of mynodes correspond to those of A

        mynodes(4,j) = string(NodeTable{j,2});

        % Add PI from node_PIO in mynodes[5]

        mynodes(5,j) = node_PIO(1,j);

        % Add PI from node_PIO in mynodes[5]

        mynodes(6,j) = node_PIO(2,j);
    end
    %x = torch.tensor([[-1], [0], [1]], dtype=torch.float)

    %save(strcat(paths(i),'matlab_graph_2.mat'));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%