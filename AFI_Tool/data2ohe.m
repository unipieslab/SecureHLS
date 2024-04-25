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


projectname = ".\Designs\";
flag_exit = 0;
for i=1:num_of_designs
    tic

    % reload mynodes in all graphs
    if ~(exist(strcat(paths(i),'matlab_graph.mat')))
        flag_exit =flag_exit + 1;
        oldfolder = strcat(paths(i));
        newfolder = strcat("remove",paths(i));

        movefile (oldfolder,newfolder)
        toc
        continue;
    end

    paths(i)
    load(strcat(paths(i),'matlab_graph.mat'))

    old_mynodes = mynodes;

    % rename functional units to their generic name :)

    for jj=1:size(old_mynodes,2)

        for ii=1:size(g_FU,2)
            if contains(old_mynodes(4,jj),g_FU(ii))
                old_mynodes(4,jj) = g_FU(ii);
            end
        end
        
    end

    mynodes = zeros(mynodes_size,size(mynodes,2));

    % add IO

    for col=1:size(mynodes,2)
        for row=1:size(ohe,1)

            idx = find(string(g_IO(1,:)) == old_mynodes(2,col)); %input
%             if isempty(idx)
%                 flag_exit =flag_exit + 1;
%                 oldfolder = strcat(paths(i));
%                 newfolder = strcat("remove",paths(i));
% 
%                 movefile (oldfolder,newfolder)
%                 break;
%             end
            mynodes(row,col)=ohe(row,idx);
        end
        %end

        current_end = size(ohe,1);
        %mynodes = [mynodes;strings(size(ohe,1),size(mynodes,2))];

        %for col=1:size(mynodes,2)
        for row=1:size(ohe,1)

            idx = find(string(g_IO(1,:)) == old_mynodes(3,col));%output
            if isempty(idx)
                flag_exit =flag_exit + 1;
                oldfolder = strcat(paths(i));
                newfolder = strcat("remove",paths(i));

                movefile (oldfolder,newfolder)
                break;
            end
            mynodes(row+current_end,col)=ohe(row,idx);
        end
        %end

        % add FU
        current_end = current_end + size(ohe,1);
        %mynodes = [mynodes;strings(size(ohe_2,1),size(mynodes,2))];

        %for col=1:size(mynodes,2)
        for row=1:size(ohe_2,1)

            idx = find(string(g_FU(1,:)) == old_mynodes(4,col)); %fu
%             if isempty(idx)
%                 flag_exit =flag_exit + 1;
%                 oldfolder = strcat(paths(i));
%                 newfolder = strcat("remove",paths(i));
% 
%                 movefile (oldfolder,newfolder)
%                 break;
%             end
            mynodes(row+current_end,col)=ohe_2(row,idx);
        end
        %end

        % add PIO
        current_end = current_end + size(ohe_2,1);

        %mynodes = [mynodes;strings(size(ohe,1),size(mynodes,2))];

        %for col=1:size(mynodes,2)
        for row=1:size(ohe,1)

            idx = find(string(g_IO(1,:)) == old_mynodes(5,col)); %pi

            mynodes(row+current_end,col)=ohe(row,idx);
        end
        %end

        current_end = current_end + size(ohe,1);
        %mynodes = [mynodes;strings(size(ohe,1),size(mynodes,2))];

        %for col=1:size(mynodes,2)
        for row=1:size(ohe,1)

            idx = find(string(g_IO(1,:)) == old_mynodes(6,col)); %po

            mynodes(row+current_end,col)=ohe(row,idx(1));
        end
    end

    current_end =current_end + size(ohe,1);

    verification = current_end

%     if verification ~= 640
%         disp("abort!")
%         break;
%     end

    %     % add truth table - vectorize!
    %
    %     current_end = size(mynodes,1) ;
    %
    %     for j=1:size(mynodes,2)
    %
    %         % vectorize the one-hot encoding of the truth-table
    %         % max value should be OR : 100000000000000 (15 digits)
    %         % '1's are located at first index!
    %
    %         vector = size(char(old_mynodes(7,j)),2);
    %
    %         for v=current_end+15:-1:current_end+1
    %             if v == (current_end+15)-vector+1
    %                 mynodes(v,j) = "1";
    %             else
    %                 mynodes(v,j) = "0";
    %             end
    %         end
    %
    %     end
    %
    %     %add probability
    %
    %     current_end = size(mynodes,1);
    %     mynodes = [mynodes;strings(size(ohe_3,1),size(mynodes,2))];
    %
    %     for col=1:size(mynodes,2)
    %         for row=1:size(ohe_3,1)
    %
    %             idx = find(string(g_PROB(1,:)) == old_mynodes(8,col));
    %
    %             mynodes(row+current_end,col)=ohe_3(row,idx);
    %         end
    %     end

    mynodes_size = size(mynodes,1)

    if flag_exit == 0
        save(strcat(paths(i),'matlab_graph.mat'),"A","mynodes","myedges");
    end
    toc

end