% test_group_plot_0902_2017.m

%% Initialize
my_fun = my_function();
p = '/Volumes/KathyWD2TB/data/2017/rongxue_0814/0901_excel_file/0902/';
result_file = strcat(p, 'result.mat');

% %% Calculate the ratio arrays.
% % Read from 3 different excel files with 2 sheets each
% % Combine the time courses into 3 groups
% % Save the output to the "result.mat" file
% group.index = [1;2];
% group.file = strcat(p, 'result_jcyf_328_1.xlsx');
% [time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1);
% norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array);
% time_interp = my_fun.get_time_interp(time_array);
% norm_ratio_array_interp = my_fun.interpolate_time_value_array(time_array, norm_ratio_array, time_interp);
% nrr_ratio_3281 = norm_ratio_array_interp;
% nrr_time_3281 = time_interp;
% clear time_array ratio_array norm_ratio_array time_interp normratio_array_interp
% %
% group.file = strcat(p, 'result_jcyf_328_110.xlsx');
% [time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1);
% norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array);
% time_interp = my_fun.get_time_interp(time_array);
% norm_ratio_array_interp = my_fun.interpolate_time_value_array(time_array, norm_ratio_array, time_interp);
% nrr_ratio_328110 = norm_ratio_array_interp;
% nrr_time_328110 = time_interp;
% clear time_array ratio_array norm_ratio_array time_interp normratio_array_interp
% % 
% group.file = strcat(p, 'result_jcyf_328_150.xlsx');
% [time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1);
% norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array);
% time_interp = my_fun.get_time_interp(time_array);
% norm_ratio_array_interp = my_fun.interpolate_time_value_array(time_array, norm_ratio_array, time_interp);
% nrr_ratio_328150 = norm_ratio_array_interp;
% nrr_time_328150 = time_interp;
% clear time_array ratio_array norm_ratio_array time_interp normratio_array_interp
% %
% save(result_file, 'nrr_time_3281', 'nrr_ratio_3281', 'nrr_time_328110', ...
% 'nrr_ratio_328110', 'nrr_time_328150', 'nrr_ratio_328150');
% clear nrr_time_3281 nrr_ratio_3281 nrr_time_328110 nrr_ratio_328110 
% clear nrr_time_328150 nrr_ratio_328150

%% Statistical analysis
res = load(result_file);
group_name = {'JCam LckYF Con 100%', 'JCam LckYF Con 10%', 'JCam LckYF Con 2%'};
num_group = 3;
time = cell(num_group, 1);
ratio = cell(num_group, 1);
time{1} = res.nrr_time_3281;
ratio{1} = res.nrr_ratio_3281;
time{2} = res.nrr_time_328110;
ratio{2} = res.nrr_ratio_328110;
time{3} = res.nrr_time_328150;
ratio{3} = res.nrr_ratio_328150;

% Calculate max_ratio, half_time to reach max, and end_ratio between 25-30
% min
max_ratio = cell(num_group, 1);
half_time = cell(num_group,1);
end_ratio = cell(num_group,1);
for i = 1:num_group
    ratio{i} = (ratio{i}-1)*100;
    ratio_0 = ratio{i}(time{i}>0, :);
    max_ratio{i} = max(ratio_0,[], 1)';
    num_cell = size(ratio{i},2);
    half_time{i} = nan(num_cell,1);
    for j = 1:num_cell
        half_max = max_ratio{i}(j)/2;
        jj = find(ratio{i}(:,j)>half_max, 1);
        if jj == 1 || time{i}(jj)<=0
            continue;
        end
        half_time{i}(j) = interp1([ratio{i}(jj-1,j); ratio{i}(jj,j)], ...
            [time{i}(jj-1); time{i}(jj)], half_max);
    end
    half_time{i} = half_time{i}(~isnan(half_time{i}));
    t_25_30 = (time{i}>=25 & time{i} <=30);
    end_ratio{i} = mean(ratio{i}(t_25_30, :),1)';
    
    clear ratio_0;
end

% Plot histograms and perform statistical analysis
num_variable = 3;
variable_name = {'Max Ratio Increase', 'End Ratio Increase', 'Half Time'};
variable_unit = {'(%)', '(%)', '(min)'};
variable = cell(num_variable, num_group);
for j =1:num_group
    variable{1,j} = max_ratio{j};
    variable{2,j} = end_ratio{j};
    variable{3,j} = half_time{j};
end
clear max_ratio end_ratio half_time;

test_name = 'kstest'; %'ttest'; %'ranksum';
for i = 1:num_variable
    figure; hold on; histogram(variable{i,1}, 20); histogram(variable{i,2}, 20);
    legend(group_name{1}, group_name{2});
    xlabel([variable_name{i} ' ' variable_unit{i}]);
    figure; hold on; histogram(variable{i,1}, 20); histogram(variable{i,3}, 20);
    legend(group_name{1}, group_name{3});
    xlabel([variable_name{i} ' ' variable_unit{i}]);
    %
    fprintf('n1 = %d, n2 = %d, n3 = %d. \n', size(variable{i,1},1), size(variable{i,2},1),...
        size(variable{i,3}, 1));
    disp(['Compare ' variable_name{i} ' between ' group_name{1} ' and ' group_name{2} ':']);
    p = my_fun.statistic_test(variable{i,1}, variable{i,2}, test_name);
    fprintf('p = %f\n\n', p);
    disp(['Compare ' variable_name{i} ' between ' group_name{1} ' and ' group_name{3} ':']);
    p = my_fun.statistic_test(variable{i,1}, variable{i,3}, test_name);
    fprintf('p = %f\n\n', p);
end






