% test_group_plot_0902_2017.m

%% Initialize
my = my_function();
root = my.root;
display(strcat('The root data folder is: ', root));
    
p = strcat(root, '../quanty_sample/0902/');
result_file = strcat(p, 'result.mat');
my_fun = my_function();

%% Calculate the ratio arrays.
% Read from 3 different excel files with 2 sheets each
% Combine the time courses into 3 groups
% Save the output to the "result.mat" file
group.index = [1;2];
% group.file = strcat(p, 'result_jcyf_328_1.xlsx');
group.file = strcat(p, 'result_jcyf_3_1.xlsx');
% [time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1, ...
%    'enable_average_plot', 1);
[time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1);
norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array);
time_interp = my_fun.get_time_interp(time_array);
norm_ratio_array_interp = my_fun.interpolate_time_value_array(time_array, norm_ratio_array, time_interp);
nrr_ratio_1 = norm_ratio_array_interp;
nrr_time_1 = time_interp;
clear time_array ratio_array norm_ratio_array time_interp normratio_array_interp
%
% group.file = strcat(p, 'result_jcyf_328_110.xlsx');
group.file = strcat(p, 'result_jcyf_3_110.xlsx');
[time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1);
norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array);
time_interp = my_fun.get_time_interp(time_array);
norm_ratio_array_interp = my_fun.interpolate_time_value_array(time_array, norm_ratio_array, time_interp);
nrr_ratio_110 = norm_ratio_array_interp;
nrr_time_110 = time_interp;
clear time_array ratio_array norm_ratio_array time_interp normratio_array_interp
% 
% group.file = strcat(p, 'result_jcyf_328_150.xlsx');
group.file = strcat(p, 'result_jcyf_3_150.xlsx');
[time_array, ratio_array] = group_plot(group, 'method', 2, 'enable_interpolation', 1);
norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array);
time_interp = my_fun.get_time_interp(time_array);
norm_ratio_array_interp = my_fun.interpolate_time_value_array(time_array, norm_ratio_array, time_interp);
nrr_ratio_150 = norm_ratio_array_interp;
nrr_time_150 = time_interp;
clear time_array ratio_array norm_ratio_array time_interp normratio_array_interp
%
save(result_file, 'nrr_time_1', 'nrr_ratio_1', 'nrr_time_110', ...
'nrr_ratio_110', 'nrr_time_150', 'nrr_ratio_150');
clear nrr_time_1 nrr_ratio_1 nrr_time_110 nrr_ratio_110 
clear nrr_time_150 nrr_ratio_150

%% Statistical analysis
% group_name = {'JCam LckYF Con 100%', 'JCam LckYF Con 10%', 'JCam LckYF Con 2%'};
% num_group = 3;
group_name = {'CD3+CD28 Con 100%', 'CD3+CD28 Con 10% ', 'CD3+CD28 Con 2%  ', ...
  'CD3 Con 100%     ', 'CD3 Con 10%      ', 'CD3 Con 2%       '};
num_group = 6;
%
result_file = strcat(p, 'result_jcyf_328.mat');
res = load(result_file);
time = cell(num_group, 1);
ratio = cell(num_group, 1);
time{1} = res.nrr_time_1;
ratio{1} = res.nrr_ratio_1;
time{2} = res.nrr_time_110;
ratio{2} = res.nrr_ratio_110;
time{3} = res.nrr_time_150;
ratio{3} = res.nrr_ratio_150;
% 
result_file = strcat(p, 'result_jcyf_3.mat');
res3 = load(result_file); 
time{4} = res3.nrr_time_1;
ratio{4} = res3.nrr_ratio_1;
time{5} = res3.nrr_time_110;
ratio{5} = res3.nrr_ratio_110;
time{6} = res3.nrr_time_150;
ratio{6} = res3.nrr_ratio_150;

% Calculate max_ratio, end_ratio between 25-30 min,
% and half_time to reach max. 
% Half time was calculated by 
% (1) Confirm that the max percentage increase >5%
% (2) Find the first positive time point j with a ratio value 
%     > ½ max percentage increase
% (3) Interpolation between the ratio values of j-1 and j to obtain 
% the estimated time point with ½ max.
max_ratio = cell(num_group, 1);
half_time = cell(num_group,1);
end_ratio = cell(num_group,1);
max_deriv = cell(num_group, 1);
min_deriv = cell(num_group, 1);
area_ratio = cell(num_group, 1);
for i = 1:num_group
    ratio{i} = (ratio{i}-1)*100;
    ratio_0 = ratio{i}(time{i}>0, :);
    max_ratio{i} = max(ratio_0,[], 1)';
    num_cell = size(ratio{i},2);
    half_time{i} = nan(num_cell,1);
    max_deriv{i} = nan(num_cell, 1);
    min_deriv{i} = nan(num_cell, 1);
    area_ratio{i} = nan(num_cell, 1);
    for j = 1:num_cell
        if max_ratio{i}(j)<= 5 % 5%
            continue;
        end
        half_max = max_ratio{i}(j)/2;
        jj = find(ratio{i}(:,j)>half_max, 1);
        if jj == 1 || time{i}(jj)<=0
            continue;
        end
        half_time{i}(j) = interp1([ratio{i}(jj-1,j); ratio{i}(jj,j)], ...
            [time{i}(jj-1); time{i}(jj)], half_max);
        [max_deriv{i}(j), ~, min_deriv{i}(j), ~] = my_fun.get_derivative(time{i}, ratio{i}(:, j));
        area_ratio{i}(j) = my_fun.get_area_ratio(time{i}, ratio{i}(:, j));
    end
    half_time{i} = half_time{i}(~isnan(half_time{i}));
    t_25_30 = (time{i}>=25 & time{i} <=30);
    end_ratio{i} = mean(ratio{i}(t_25_30, :),1)';
    %
    max_deriv{i} = max_deriv{i}(~isnan(max_deriv{i}));
    min_deriv{i} = min_deriv{i}(~isnan(min_deriv{i}));
    area_ratio{i} = area_ratio{i}(~isnan(area_ratio{i}));
    
    clear ratio_0;
end

for i = 1:num_group
    ratio{1} = (ratio{i}-1)*100;
    num_cell = size(ratio{i}, 2);
    for j = 1:num_cell
        if max_ratio{i}(j)<= 5 % 5%
            continue;
        end
    end
end

% Plot histograms and perform statistical analysis
num_variable = 6;
variable_name = {'Max Ratio Increase', 'End Ratio Increase', 'Half Time', ...
    'Max Derivative', 'Min Derivative', 'Transient Index'};
variable_unit = {'(%)', '(%)', '(min)', '(%/min)', '(%/min)', '(AU)'};
variable = cell(num_variable, num_group);
for j =1:num_group
    variable{1,j} = max_ratio{j};
    variable{2,j} = end_ratio{j};
    variable{3,j} = half_time{j};
    variable{4,j} = max_deriv{j};
    variable{5,j} = min_deriv{j};
    variable{6,j} = area_ratio{j};
end
clear max_ratio end_ratio half_time;
clear max_deriv min_derive area_ratio;

test_name = 'ranksum'; %'ttest'; %'ranksum';
% test_pair = [1 2; 1 3; 2 3]; 
% test_pair = [4 5; 4 6; 5 6]; 
test_pair = [1 2; 4 5; 1 4; 2 5];
% test_pair = [1 4; 2 5; 3 6]; 
num_test = size(test_pair, 1);
for i = 6:6 % [4, 5, 6] %[1, 3] % variables tested
    for j = 1:num_test
        ii = test_pair(j,1);
        jj = test_pair(j,2);
        figure; hold on; histogram(variable{i,ii}, 20); histogram(variable{i,jj}, 20);
        legend(group_name{ii}, group_name{jj});
        xlabel([variable_name{i} ' ' variable_unit{i}]);
    end
    %
    fprintf('%s: \n', variable_name{i});
    for j = 1:num_test
        ii = test_pair(j,1);
        jj = test_pair(j,2);
        my_fun.statistic_test(variable{i,ii}, variable{i,jj}, 'method', test_name, ...
        'group', sprintf('%s and %s', group_name{ii}, group_name{jj}));
    end

end

%% multiple comparison
% half_time is in variable{3, 1:6}
% transient index is variable{6,1:6}
ii = 6;
num_group = size(variable, 2);
data = variable{ii,1};
tag = get_tag(data, group_name{1});
for i = 2:num_group
    temp = variable{ii, i};
    data = [data; temp];
    tag = [tag; get_tag(temp, group_name{i})];
    clear temp;
end
multiple_comparison(data, tag);



return;






