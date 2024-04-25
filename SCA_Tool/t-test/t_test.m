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

%% Info
% The null hypothesis is that there is no leakage.
% Thus the design is not secure when the test rejects the hypothesis,
% which happens when the tval (or tstat) is outside of the threshold
% of +-4.5. Matlab does it differently but the results are very similar.

clear all

set(gcf,'color','w');
set(gca,'fontname','times')  % Set it to times


in_random = {}; % Add paths to your own random attack_data_all file.

in_const = {}; % Add paths to your own random attack_data_all file.

design = {}; % Add file names (appear on titles)


% Assume we have 12 t-test plots. We make them appear in a tiled-layout plot (4 rows, 3 columns)
% First plot is centered - pos=1 and pos=3 are left empty
pos = [2 4 5 6 7 8 9 10 11 12];


% Create a tiled layout
tiledlayout(4,3,"TileSpacing","compact","Padding","compact");

% File loop
for d=1:size(design,2)
    tic

    % fast - data are sampled
    load(strcat(in_random{d},''));
    data_const_fast = (datapoints);
    clear datapoints
    load(strcat(in_const{d},''));
    data_random_fast =(datapoints);
    clear datapoints
    num_of_samples = (size(data_random_fast,2));

    tval(d) = 0;
    for i = 1:num_of_samples
        %display(i);
        x = data_const_fast(:,i);
        y = data_random_fast(:,i);
        [h,p,ci,stats] = ttest2(x,y,'Vartype','unequal','Alpha',0.01); % Alpha=0.01 --> significance level 1%
        hh(i) = h;
        pp(i) = p;
        cci1(i) = ci(1,1);
        cci2(i) = ci(2,1);
        t(i) = stats.tstat;
        dfval(i) = stats.df;
        if (stats.tstat > 4.5 || stats.tstat < -4.5)
            tval(d) =  tval(d) + 1;
        end
    end

    % Create a subplot in the tiled layout
    nexttile(pos(d));

    plot(t);
    thresholdplus(1:num_of_samples) = 4.5;
    hold on;
    plot(thresholdplus,'r');
    thresholdminus(1:num_of_samples) = -4.5;
    plot(thresholdminus,'r');
    hold off;
    title(strcat("",design{d}), 'Interpreter', 'none');
    format bank
    percent = round((tval(d)*100/i),2);
    subtitle(strcat(num2str(percent),{'% of points over |4.5| threshold '}));

    ylim([-100 100]);
    xlim([0 num_of_samples])


    toc
    pause(0.001);

end
