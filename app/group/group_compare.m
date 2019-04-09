% function group = group_compare( group, varargin )
% Plot the mean time course of FRET ratio data with standard error bar from different
% groups together
% parameter_name = {'input_file','error_bar_interval',...
%     'enable_box_plot', 'enable_violin_plot', 'load_file', 'time_range'};
% default_value = {'result.xlsx', 5, 0, 0, 0, [10 20]};
%
% Example: 
% >> p = '../doc/project/ode_sys/2017/fyn_gf_copy_0125_2016/data_mingxing_0602/06_2015/01-08-2015_Cyto-Fyn_variable_EGF_HeLa/';
% >> file_name = 'result.xls';
% >> group = group_compare([], 'input_file', strcat(p, file_name), 'error_bar_interval', 3, 'verbose', 1);
% 
% This function visualize the average plots of average time courses with
% standard error bars. 
%
% Next step, please copy the data from group to an excel file
% and then use python/swarm_plot.py to visualize the swarm plots of data. 

% Copyright: Shaoying Lu, Lexie Qin Qin and Yingxiao Wang 2014-2017 
% Email: shaoying.lu@gmail.com

function group = group_compare( group, varargin )
parameter_name = {'input_file','error_bar_interval',...
    'enable_box_plot', 'enable_violin_plot', 'load_file', 'time_range'};
default_value = {'result.xlsx', 5, 0, 0, 0, [10 20]};
[input_file, error_bar_interval, enable_box_plot,...
    enable_violin_plot, load_file, time_range] = parse_parameter...
    (parameter_name, default_value, varargin);

font_size = 24;
line_width = 2;

if exist(input_file, 'file') && isempty(group)
    load_file = 1;
    disp(strcat('group_compare: set load_file = 1')); 
    disp(strcat('loaded input file: ', input_file)); 
end
    
if load_file    
    [~, ~, ext_str] = fileparts(input_file);
    if strcmp(ext_str, '.xls') || strcmp(ext_str, '.xlsx') || strcmp(ext_str, '.cvs')
        % read excel file        
        mat_file = regexprep(input_file, ext_str, '.mat');
        group = excel_read_curve(input_file, 'method', 2);
        save(mat_file, 'group');
        fprintf('group_compare: saved mat_file %s\n', mat_file); 
    else 
        input = load(input_file);
        group = input.group;
        clear input;
    end
end % if load_file

% Calculate the average and std_error of ratio values.
num_group = length(group);
time = cell(num_group);
ratio = cell(num_group);
mean_ratio = cell(num_group);
std_error = cell(num_group);
group_name = cell(num_group, 1);
num_cell = zeros(num_group, 1);
for i = 1:num_group        
    time{i} = group{i}.time;
    ratio{i} = group{i}.ratio;
    num_cell(i) = size(ratio{i}, 2);
    mean_ratio{i} = mean(ratio{i}, 2);
    std_error{i} = std(ratio{i},0,2) / sqrt(num_cell(i));
    group_name{i} = group{i}.name; 
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
my_figure('font_size', font_size, 'line_width', line_width);
xlabel('Time (min)'); ylabel('Normalized Mean Ratio');

% Use matlab default color
co = get(groot, 'defaultAxesColorOrder');
color = {co(1,:), co(2,:), co(3,:), co(4,:), co(5,:), co(6,:), co(7,:), co(1,:)};

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

% Add the error bars
for i = 1:num_group
    iii = (find(~diff(time{i})))'; 
    assert(isempty(iii), ...
        [ 'group_compare(): i=', num2str(i), ', ', ...
        'the time vector has duplicated values at ', num2str(iii)]); 
    add_error_bar(time{i}, mean_ratio{i}, std_error{i}, 'error_bar_color', color{i},...
        'error_bar_interval', error_bar_interval);
end
%
% Generate the legend str
% Lexie on 03112015, clickableLegend can control the curve but not the
% errorbar
legend_str = 'legend(';
for i = 1:num_group-1
    legend_str = strcat(legend_str, '''', group{i}.name, '''', ', ');
end
legend_str = strcat(legend_str, '''', group{num_group}.name, '''', ');');
eval(legend_str);



% statistics part - t-test, Lexie on 02/23/2015
clear ratio; 
ratio = cell(num_group, 1);
stat_average_ratio = cell(num_group, 1);
stat_peak_ratio = cell(num_group, 1);
group_mean = zeros(num_group, 1);
sem = zeros(num_group, 1);
stat_peak_time = cell(num_group, 1);
time_mean = zeros(num_group, 1);
sem_time = zeros(num_group, 1);
ratio_mean = zeros(num_group, 1);
sem_ratio = zeros(num_group, 1);

for n = 1 : num_group
    time_n = time{n};
    ratio{n} = group{n}.ratio;
    ii = (time_n>=time_range(1) & time_n<=time_range(2));
    stat_average_ratio{n} = (mean(ratio{n}(ii, :), 1))';
    temp = max(ratio{n});
    stat_peak_ratio{n} = temp';
    stat_peak_time{n} = zeros(num_cell(n), 1);
    for i = 1:num_cell(n)
        jj = find(ratio{n}(:,i)>0.99*stat_peak_ratio{n}(i), 1);
        stat_peak_time{n}(i) = time_n(jj) ;
    end
    clear temp jj;
    group_mean(n) = mean(stat_average_ratio{n}, 1);
    sem(n) = std(stat_average_ratio{n}) / sqrt(length(stat_average_ratio{n}));
     time_mean(n) = mean(stat_peak_time{n});
     sem_time(n)  = std(stat_peak_time{n}) / sqrt(num_cell(n));
     ratio_mean(n)  = mean(stat_peak_ratio{n});
     sem_ratio(n)  = std(stat_peak_ratio{n}) / sqrt(num_cell(n));
     clear ii;
end % for n = 1 : length(group_name)

% copy the results to output
for n = 1:num_group
    group{n}.peak_ratio = stat_peak_ratio{n}; 
    group{n}.peak_time = stat_peak_time{n}; 
    group{n}.average_ratio = stat_average_ratio{n};
end

% Comparison of the mean ratio between a user specified time range
title_str = strcat('Time interval [', num2str(time_range),']');
if enable_box_plot
    box_plot(stat_average_ratio, group_name, 'title_string', title_str);
    ylabel('Intensity Ratio');
end
if enable_violin_plot
    violin_plot(stat_average_ratio, group_name, 'title_string', title_str,...
        'line_width', lw, 'font_size', fs);
    ylabel('Intensity Ratio');
end
clear title_str
disp(' ');
disp('Mean Ratio +/- Standard Error');
for n = 1 : length(group_name)
    display(['For group ', group_name{n}, ' (n=', num2str(length(stat_average_ratio{n})), '), ',...
        num2str(group_mean(n)), ' +/- ', num2str(sem(n))]);
end 
[h, p, ~, ~] = ttest2(stat_average_ratio{1}, stat_average_ratio{2});
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

% Comparison of peak ratio
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

fprintf('Output: group, disp(group{1})\n'); 
disp(group{1}); 
return;










