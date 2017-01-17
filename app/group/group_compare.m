% function group = group_compare( group, varargin )
% Plot the mean time course of FRET ratio data with standard error bar from different
% groups together
% parameter_name = {'excel_file','error_bar_interval','statistics', ...
%     'time_range', 'group_name', 'enable_box_plot', 'enable_violin_plot', 'load_file'};
% default_value = {'result.xls', 5, 't-test', '', '', 0, 0, 0};

% Copyright: Shaoying Lu, Lexie Qin Qin and Yingxiao Wang 2014 
% Email: shaoying.lu@gmail.com

function group = group_compare( group, varargin )
% parameter_name = {'update_result'};
% default_value = {0};
% [update_result] = parse_parameter(parameter_name, default_value, varargin);
% Read the excel file and save the results
parameter_name = {'excel_file','error_bar_interval','statistics', ...
    'time_range', 'group_name', 'enable_box_plot', 'enable_violin_plot', 'load_file'};
default_value = {'result.xls', 5, 't-test', '', '', 0, 0, 0};
[excel_file, error_bar_interval, statistics, time_range, group_name, ...
    enable_box_plot, enable_violin_plot, load_file] = parse_parameter...
    (parameter_name, default_value, varargin);
% Correct the problem in the program
% excel_file = strcat(group.data.path, '../../',excel_file);
ll = length(group.data.path);
excel_file = strcat(group.data.path(1:ll-3), '../', excel_file);
DeleteEmptyExcelSheets(excel_file);

[~, ~, xls_str] = fileparts(excel_file);
mat_file = regexprep(excel_file, xls_str, '.mat');
if ~exist(mat_file, 'file') || ~load_file,
    exp = excel_read_curve(excel_file, 'method', 2);
    save(mat_file, 'exp');
else 
    input = load(mat_file);
    exp = input.exp;
    clear input;
end;

% Calculate the average and std_error of ratio values.
num_exps = length(exp);
time = cell(num_exps);
mean_ratio = cell(num_exps);
std_error = cell(num_exps);
for i = 1:num_exps,        
    time{i} = exp{i}.time;
    ratio{i} = exp{i}.ratio;
    num_cells = size(ratio{i}, 2);
    mean_ratio{i} = mean(ratio{i}, 2);
    std_error{i} = std(ratio{i},0,2) / sqrt(num_cells);
end; % for i

% Lexie on 03/20/2015, extract the time information about how long it will
% take to reach peak ratio
for i = 1 : num_exps,
    max_ratio = max(ratio{1, i});
    peak_time.name{1, i} = exp{i}.name;
    for j = 1 : length(ratio{1, i}(1, :)),
        index_peak = find((ratio{1, i}(:, j)) == max_ratio(j), 1, 'first');
        peak_time.time{1, i}(j) = time{i, 1}(index_peak);
    end
end
clear max_ratio index_peak;


% Make plots
% Plot the mean ratio with standard error.
figure('color','w'); hold on;
set(gca, 'FontSize', 12, 'FontWeight', 'bold','Box', 'off', 'LineWidth',2); 
xlabel('Time (min)'); ylabel('Normalized Mean Ratio');

color = {'k', 'b', 'r','g', 'm', 'c', 'y'};
colorbase = [0.8 0.5 0.2];
q = 8;
    for j = 1 : 2,
        for n = 1: 3,
            for h = 2: 3,
                color{q} = [colorbase(j) colorbase(n) colorbase(h)];
                q = q + 1;
            end
        end
    end
clear q j h n
% color = lines(30);
            
% Lexie on 2/13/2015
for i = 1:num_exps,
    min_t = min(time{i});
    index11 = 1 : ((abs(min_t) / 0.5) );
    index22 = (abs(min_t) / 0.5 + 1) : 5 : ((abs(min_t) / 0.5 + 5 * 20));
    index33 = (((abs(min_t) / 0.5 + 5 * 20)) + 1): length(time{i});
    index = [index11 index22 index33]';
    t1 = time{i}(index); mr1 = mean_ratio{i}(index);
    set(gca,'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold');
    set(findall(gcf,'type','text'),'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold');
    plot(t1,mr1,'Color', color{i}, 'LineWidth',2);  
    clear t1 mr1 index index1;
end;

% Generate the legend str
% Lexie on 03112015, clickableLegend can control the curve but not the
% errorbar
legend_str = 'legend(';
for i = 1:num_exps-1,
    legend_str = strcat(legend_str, '''', exp{i}.name, '''', ', ');
end;
legend_str = strcat(legend_str, '''', exp{num_exps}.name, '''', ');');
eval(legend_str);


%add the error bar
for i = 1:num_exps,
    add_error_bar(time{i}, mean_ratio{i}, std_error{i}, 'error_bar_color', color{i}, 'error_bar_interva', error_bar_interval);
end;
%

% statistics part - t-test, Lexie on 02/23/2015
if any(strcmp(varargin, 'statistics'))
    if any(strcmp(varargin, 't-test'))
        group_name = varargin{find(strcmp(varargin, 'group_name')) + 1};
        time_range = varargin{find(strcmp(varargin, 'time_range')) + 1};
        time_temp = [((time_range(1) - 10) * 2) : ((time_range(2) - 10) * 2)] + 121;
        for n = 1 : length(group_name)
            stats_data{n} = xlsread(excel_file, group_name{n});
            for i = 1 : (length(stats_data{n}(1,:)) - 1)
                range_data{n}(:, i) = stats_data{n}(time_temp, i + 1);
                test_data{n}(i) = mean(range_data{n}(:, i));
                stat_peak_ratio{n}(i) = max(stats_data{n}(:, i + 1)); 
            end
            group_mean(n) = mean(test_data{n});
            sem(n) = std(test_data{n}) / length(test_data{n});
            %Lexie on 03/23, save the peak time to stat_peak_time;
            %Lexie on 04/06, save the peak ratio to stat_peak_ratio
             index = find(strcmp(peak_time.name, group_name{n}));
             stat_peak_time{n} = peak_time.time{n};
             time_mean(n) = mean(stat_peak_time{n});
             sem_time(n)  = std(stat_peak_time{n}) / length(stat_peak_time{n});
             ratio_mean(n)  = mean(stat_peak_ratio{n});
             sem_ratio(n)  = std(stat_peak_ratio{n}) / length(stat_peak_ratio{n});
             clear index
        end

        % Comparison for the mean ratio between a user specified time range
        title_str = strcat('Time interval [', num2str(time_range),']');
        if enable_box_plot,
            box_plot(test_data, group_name, 'title_string', title_str);
            ylabel('Intensity Ratio');
        end
        if enable_violin_plot,
            violin_plot(test_data, group_name, 'title_string', title_str, 'line_width', 4, 'font_size', 24);
            ylabel('Intensity Ratio');
        end
        clear title_str
        display(' ');
        display('Mean Ratio +/- Standard Error');
        for n = 1 : length(group_name)
            display(['For group ', group_name{n}, '(n = ', num2str(length(test_data{n})), '), ', num2str(group_mean(n)), ' +/- ', num2str(sem(n))]);
        end 
        [h, p, ci, stats] = ttest2(test_data{1}, test_data{2});
        if h == 1,
            display(['There is significant difference between ',group_name{1},...
                ' and ', group_name{2}, '.']);
        else
            display(['There is no significant difference between ', group_name{1},...
                ' and ', group_name{2}, '.']);
        end
        display(['The p value is ', num2str(p), '.']);
        display(' ');

        % Comparison for the time to reach peak ratio
        title_str = 'Peak Time';
        if enable_box_plot,
            box_plot(stat_peak_time, group_name, 'title_string', title_str);
            ylabel('Time(min)');
        end
        if enable_violin_plot,
            violin_plot(stat_peak_time, group_name, 'title_string', title_str, 'line_width', 4, 'font_size', 24);
            ylabel('Time(min)');
        end
        display('Mean Time +/- Standard Error')
        for n = 1 : length(group_name)
            display(['For group ', group_name{n}, '(n = ', num2str(length(stat_peak_time{n})), '),' , num2str(time_mean(n)), ' +/- ', num2str(sem_time(n))]);
        end
        [h_peak_time, p_peak_time, ~, ~] = ttest2(stat_peak_time{1}, stat_peak_time{2});
        if h_peak_time == 1,
            display(['There is significant difference between ',group_name{1},...
                ' and ', group_name{2}, '.']);
        else
            display(['There is no significant difference between ', group_name{1},...
                ' and ', group_name{2}, '.']);
        end
        display(['The p value is ', num2str(p_peak_time), '.']);
        display(' ');
        
        
        title_str = 'Peak Ratio';
        if enable_box_plot,
            box_plot(stat_peak_ratio, group_name, 'title_string', title_str);
            ylabel('Intensity Ratio');
        end
        if enable_violin_plot,
            violin_plot(stat_peak_ratio, group_name, 'title_string', title_str, 'line_width', 4, 'font_size', 24);
            ylabel('Intensity Ratio');
        end
        display('Peak Ratio +/- Standard Error')
        for n = 1 : length(group_name)
            display(['For group ', group_name{n}, '(n = ', num2str(length(stat_peak_ratio{n})), '), ', num2str(ratio_mean(n)), ' +/- ', num2str(sem_ratio(n))]);
        end
        [h_peak_ratio, p_peak_ratio, ~, ~] = ttest2(stat_peak_ratio{1}, stat_peak_ratio{2});
        if h_peak_ratio == 1,
            display(['There is significant difference between ',group_name{1},...
                ' and ', group_name{2}, '.']);
        else
            display(['There is no significant difference between ', group_name{1},...
                ' and ', group_name{2}, '.']);
        end
        display(['The p value is ', num2str(p_peak_ratio), '.']);
        display(' '); 
    end
end

group.exp = exp;
return;

% Lexie on 09/24/2014
% plot the mean normolized ratio array








