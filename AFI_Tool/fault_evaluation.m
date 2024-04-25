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

%% Read all design_*\FI\

filename = '.\Constants\MODE.txt'; %contains multiplicity of attack
fid = fopen(filename);

M = str2num(fgetl(fid));

fclose(fid);
projectname = ".\Designs";

% Gather all designs paths
paths = strings(1,1);

% Get all _registers.txt files from the correspinding design_ folders
files = dir(projectname);
for k=1:length(files)
    if (contains(files(k).name,"design_"))
        paths(end+1) = strcat(files(k).folder,"\",files(k).name,"\FI\");
    end
end

paths(:,1) = [];

error_table = strings(1,6); % columns shouldn't be static

for i=1:size(paths,2)

    % Derive design_x -- i does not correspond to x
    % in Matlab ordering, design_11 is before design_2

    design = str2num(extractBetween(paths(i),"design_","\FI\"))

    %% Read gold_out.txt
    % Format is : <signal_name>   <correct signal_value>
    gold_file = strcat(paths(i),"gold_run.txt");

    fid = fopen(gold_file);

    tline = fgetl(fid);

    gold_out = strings(1,2);

    while ischar(tline)

        t = split(tline,"	");

        gold_out(end+1,1) = string(t{1,1}); %name of signal -- 1st will always be DONE
        gold_out(end,2) = string(t{2,1});  %value of signal

        tline = fgetl(fid);
    end

    gold_out(1,:) = [];

    fclose(fid);

    %% Read #FFs from registers.txt
    % Just count the number of elements (FFs/registers) - An additional newline appears at the end of file, hence use 0
    if M == 1
        reg_file = strcat(paths(i),"registers.txt");
    else
        reg_file = strcat(paths(i),"M",string(M),"_registers.txt");
    end


    fid = fopen(reg_file);

    regs = 0; % FF counter

    tline = fgetl(fid);

    while ischar(tline)

        regs = regs + 1;

        tline = fgetl(fid);
    end

    fclose(fid);

    %% Categorize faults - Extract percentages
    % Read from out.txt
    % Format is : <signal_name>	<FI time> <DONE> <OUTPUT_i>	-- Delimiter is \t

    if M == 1
        out_file = strcat(paths(i),"out.txt");
    else
        out_file = strcat(paths(i),"M",string(M),"_out.txt");
    end

    fid = fopen(out_file);

    headers = fgetl(fid); % Headers line
    h = split(headers,"	").';
    h(:,end) = [];

    out = strings(1,size(h,2)+1);

    tline = fgetl(fid);

    while ischar(tline)

        t = split(tline,"	").';
        out(end+1,1) = t{1,1};
        for j=2:size(h,2)
            out(end,j) = t{1,j};
        end
        tline = fgetl(fid);
    end

    out(1,:) = [];

    fclose(fid);

    % Characterize faults in out

    s = 0;
    c = 0;
    h = 0;
    d = 0;

    result_pos = M*2+2; %this changes according to attack + 3 with every multiplicity

    for j=1:size(out,1)

        % Hang - DONE != GOLD_DONE
        if ~isequal(out(j,result_pos-1),gold_out(1,2))
            out(j,result_pos+1) = 'Hang';
            h = h + 1;
        elseif    ~isequal(out(j,result_pos),gold_out(2,2))

            %Detected - half output is different than the other half
            t=char(out(j,result_pos));
            if ~isequal(t(4),t(2)) && isequal(t(3),t(1)) %&& isequal(t(14),t(6)) && isequal(t(13),t(5)) && isequal(t(12),t(4)) && isequal(t(11),t(3)) && isequal(t(10),t(2)) && isequal(t(9),t(1))
                out(j,result_pos+1) = 'Detected';
                d = d + 1;

            else
                out(j,result_pos+1) = 'Critical';
                c = c + 1;
            end
        else

            out(j,result_pos+1) = 'Silent';
            s = s + 1;
        end
    end
    stats = strings(4,2);
    %[stats(:,2),stats(:,1)] = groupcounts(out(:,5));
    stats (1,1) = 'Detected';
    stats (1,2) = string(d);
    stats (2,1) = 'Critical';
    stats (2,2) = string(c);
    stats (3,1) = 'Hang';
    stats (3,2) = string(h);
    %     stats (4,1) = 'Relative Hang';
    %     stats (4,2) = string(rh);
    stats (4,1) = 'Silent';
    stats (4,2) = string(s);

    stats(end+1,2) = string(c + h + s + d);%string(size(out,1));
    stats(end,1) ='Total';

    stats

    % Save statistic in dedicated file

    %Prints

    if M == 1
        stats_file = strcat(paths(i),"SBF_stats.txt");
        fid = fopen(stats_file,"w");
        fprintf(fid,'\n\nStatistics for SBF on design\n\n');
    else
        stats_file = strcat(paths(i),"M",string(M),"_stats.txt");
        fid = fopen(stats_file,"w");
        s = strcat('\n\nStatistics for M',string(M),' on design_%s\n\n');
        fprintf(fid,s,string(i-1));
    end

    fprintf(fid,'\n  --Raw Data--\n\n');

    for L=1:size(stats,1)

        fprintf(fid,'%s : %s\n',stats(L,1),stats(L,2));

    end

    fprintf(fid,'\n   --Percentages--\n\n');

    for L=1:size(stats,1)-1

        fprintf(fid,'%s : %s\n',stats(L,1),string(str2num(stats(L,2))/str2num(stats(end,2))*100));

    end

    fclose(fid);
    % for j=1:size(out,1)
    %     if isequal(out(j,5),"Critical")
    %         error_table(end+1,1) = strcat("design_",string(i-1)); %design_(i-1)
    %         error_table(end,2:6) = out(j,1:5);
    %         error_table(end,7) = string(c + h + s);
    %     end
    % end
    %
    % error_table(1,:) = [];
    %clearvars -except error_table paths

    save(strcat(paths(i),'matlab_fault_matrix_',string(M),'.mat'),"out");

    %node_characterization(design)
end

log_filename = 'log_file.txt';

log_fid = fopen(log_filename,'a');
fprintf(log_fid,'CHECKPOINT - Fault evaluation done at %s\n\n',datetime('now'));
fclose(log_fid);

% diversity_analysis
%tidy_up

%addpath("F:\old_DATASET\")
%s1_write_SBFdotMAT
