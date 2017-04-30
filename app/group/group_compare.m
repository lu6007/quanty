% function group = group_compare( group, varargin )
% Plot the mean time course of FRET ratio data with standard error bar from different
% groups together
% parameter_name = {'excel_file','error_bar_interval',...
%     'enable_box_plot', 'enable_violin_plot', 'load_file',...
%     'group_name', 'time_range'};
% default_value = {'result.xlsx', 5, 0, 0, 0, {'G1', 'G2'}, [10 20]};

% Copyright: Shaoying Lu, Lexie Qin Qin and Yingxiao Wang 2014-2017 
% Email: shaoying.lu@gmail.com

function group = group_compare( group, varargin )
parameter_name = {'excel_file','error_bar_interval',...
    'enable_box_plot', 'enable_violin_plot', 'load_file',...
    'group_name', 'time_range'};
default_value = {'result.xlsx', 5, 0, 0, 0, {'G1', 'G2'}, [10 20]};
[excel_file, error_bar_interval, enable_box_plot,...
    enable_violin_plot, load_file, group_name, time_range] = parse_parameter...
    (parameter_name, default_value, varargin);
excel_file = strcat(group.data.path, '../../',excel_file);
% DeleteEmptyExcelSheets(excel_file);

font_size = 24;
line_width = 3;

[~, ~, xls_str] = fileparts(excel_file);
mat_file = regexprep(excel_file, xls_str, '.mat');
if ~exist(mat_file, 'file') || ~load_file
    group = excel_read_curve(excel_file, 'method', 2);
    save(mat_file, 'group');
else 
    input = load(mat_file);
    group = input.group;
    clear input;
end

% Calculate the average and std_error of ratio values.
num_group = length(group);
time = cell(num_group);
ratio = cell(num_group);
mean_ratio = cell(num_group);
std_error = cell(num_group);
for i = 1:num_group        
    time{i} = group{i}.time;
    ratio{i} = group{i}.ratio;
    num_cells = size(ratio{i}, 2);
    mean_ratio{i} = mean(ratio{i}, 2);
    std_error{i} = std(ratio{i},0,2) / sqrt(num_cells);
end % for i

% Lexie on 03/20/2015, extract the time information about how long it will
% take to reach peak ratio
for i = 1 : num_group
    max_ratio = max(ratio{i});
    peak_time.name{i} = group{i}.name;
    for j = 1 : length(ratio{i}(1, :))
        index_peak = find((ratio{i}(:, j)) == max_ratio(j), 1, 'first');
        peak_time.time{i}(j) = time{i}(index_peak);
    end
end
clear max_ratio index_peak;


% Make plots
% Plot the mean ratio with standard error.
figure('color','w'); hold on;
set(gca, 'FontSize', 12, 'FontWeight', 'bold','Box', 'off', 'LineWidth',2); 
xlabel('Time (min)'); ylabel('Normalized Mean Ratio');

color = {'r', 'b', 'k','g', 'm', 'c', 'y'};
colorbase = [0.8 0.5 0.2];
q = 8;
    for j = 1:2
        for n = 1:3
            for h = 2:3
                color{q} = [colorbase(j) colorbase(n) colorbase(h)];
                q = q + 1;
            end
        end
    end
clear q j h n
% color = lines(30);

fs = font_size;
lw = line_width; 
for i = 1:num_group
    min_t = min(time{i});
    index11 = 1 : ((abs(min_t) / 0.5) );
    index22 = (abs(min_t) / 0.5 + 1) : 5 : ((abs(min_t) / 0.5 + 5 * 20));
    index33 = (((abs(min_t) / 0.5 + 5 * 20)) + 1): length(time{i});
    index = [index11 index22 index33]';
    t1 = time{i}(index); mr1 = mean_ratio{i}(index);
    set(gca,'FontSize', fs,'FontName','Arial', 'Fontweight', 'bold');
    set(findall(gcf,'type','text'),'FontSize', fs,'FontName','Arial', 'Fontweight', 'bold');
    plot(t1,mr1,'Color', color{i}, 'LineWidth', lw);  
    clear t1 mr1 index index1;
end

% Generate the legend str
% Lexie on 03112015, clickableLegend can control the curve but not the
% errorbar
legend_str = 'legend(';
for i = 1:num_group-1
    legend_str = strcat(legend_str, '''', group{i}.name, '''', ', ');
end
legend_str = strcat(legend_str, '''', group{num_group}.name, '''', ');');
eval(legend_str);


%add the error bar
for i = 1:num_group
    add_error_bar(time{i}, mean_ratio{i}, std_error{i}, 'error_bar_color', color{i},...
        'error_bar_interva', error_bar_interval);
end
%

% statistics part - t-test, Lexie on 02/23/2015
stat_data= cell(num_group, 1);
range_data = cell(num_group, 1);
test_data = cell(num_group, 1);
stat_peak_ratio = cell(num_group, 1);
group_mean = zeros(num_group, 1);
sem = zeros(num_group, 1);
stat_peak_time = cell(num_group, 1);
time_mean = zeros(num_group, 1);
sem_time = zeros(num_group, 1);
ratio_mean = zeros(num_group, 1);
sem_ratio = zeros(num_group, 1);

for n = 1 : num_group
    stat_data{n} = xlsread(excel_file, group_name{n});
    num_cell = size(stat_data{n}, 2)-1;
    time = stat_data{n}(:,1); 
    range_data{n} = stat_data{n}(:, 2:num_cell+1);
    ii = (time>=time_range(1) & time<=time_range(2));
    test_data{n} = (mean(range_data{n}(ii, :), 1))';
    temp = max(range_data{n});
    stat_peak_ratio{n} = temp';
    %stat_peak_time{n} = time(jj)';
    for i = 1:num_cell
        jj = find(range_data{n}(:,i)>0.99*stat_peak_ratio{n}(i), 1);
        stat_peak_time{n}(i) = time(jj) ;
    end
    clear temp jj;
    group_mean(n) = mean(test_data{n}, 1);
    sem(n) = std(test_data{n}) / length(test_data{n});
     time_mean(n) = mean(stat_peak_time{n});
     sem_time(n)  = std(stat_peak_time{n}) / sqrt(num_cell);
     ratio_mean(n)  = mean(stat_peak_ratio{n});
     sem_ratio(n)  = std(stat_peak_ratio{n}) / sqrt(num_cell);
     clear ii;
end % for n = 1 : length(group_name)

% Comparison of the mean ratio between a user specified time range
title_str = strcat('Time interval [', num2str(time_range),']');
if enable_box_plot
    box_plot(test_data, group_name, 'title_string', title_str);
    ylabel('Intensity Ratio');
end
if enable_violin_plot
    violin_plot(test_data, group_name, 'title_string', title_str,...
        'line_width', lw, 'font_size', fs);
    ylabel('Intensity Ratio');
end
clear title_str
disp(' ');
disp('Mean Ratio +/- Standard Error');
for n = 1 : length(group_name)
    display(['For group ', group_name{n}, ' (n=', num2str(length(test_data{n})), '), ',...
        num2str(group_mean(n)), ' +/- ', num2str(sem(n))]);
end 
[h, p, ~, ~] = ttest2(test_data{1}, test_data{2});
if h == 1
    disp(['There is significant difference between ',group_name{1},...
        ' and ', group_name{2}, '.']);
else
    disp(['There is no significant difference between ', group_name{1},...
        ' and ', group_name{2}, '.']);
end
disp(['The p value is ', num2str(p), '.']);
disp(' ');

% Comparison of the time to reach peak ratio
title_str = 'Peak Time';
if enable_box_plot
    box_plot(stat_peak_time, group_name, 'title_string', title_str);
    ylabel('Time (min)');
end
if enable_violin_plot
    violin_plot(stat_peak_time, group_name, 'title_string', title_str,...
        'line_width', lw, 'font_size', fs);
    ylabel('Time (min)');
end
disp([title_str ' +/- Standard Error'])
for n = 1 : length(group_name)
    disp(['For group ', group_name{n}, ' (n=', num2str(length(stat_peak_time{n})), '),' ,...
        num2str(time_mean(n)), ' +/- ', num2str(sem_time(n))]);
end
[h_peak_time, p_peak_time, ~, ~] = ttest2(stat_peak_time{1}, stat_peak_time{2});
if h_peak_time == 1
    disp(['There is significant difference between ',group_name{1},...
        ' and ', group_name{2}, '.']);
else
    disp(['There is no significant difference between ', group_name{1},...
        ' and ', group_name{2}, '.']);
end
disp(['The p value is ', num2str(p_peak_time), '.']);
disp(' ');


title_str = 'Peak Ratio';
if enable_box_plot
    box_plot(stat_peak_ratio, group_name, 'title_string', title_str);
    ylabel('Intensity Ratio');
end
if enable_violin_plot
    violin_plot(stat_peak_ratio, group_name, 'title_string', title_str,...
        'line_width', lw, 'font_size', fs);
    ylabel('Intensity Ratio');
end
disp('Peak Ratio +/- Standard Error')
for n = 1 : length(group_name)
    disp(['For group ', group_name{n}, ' (n=', num2str(length(stat_peak_ratio{n})), '), ', ...
        num2str(ratio_mean(n)), ' +/- ', num2str(sem_ratio(n))]);
end
[h_peak_ratio, p_peak_ratio, ~, ~] = ttest2(stat_peak_ratio{1}, stat_peak_ratio{2});
if h_peak_ratio == 1
    disp(['There is significant difference between ',group_name{1},...
        ' and ', group_name{2}, '.']);
else
    disp(['There is no significant difference between ', group_name{1},...
        ' and ', group_name{2}, '.']);
end
disp(['The p value is ', num2str(p_peak_ratio), '.']);
disp(' '); 

return;










