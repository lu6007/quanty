% function my = group_function()
% my.add_normal_auc = @add_normal_auc;
% Calculate and add the field normal_auc to group{i}.normal_auc

% Copyright: Shaoying Lu shaoying.lu@gmail.com
function my = group_function()
my.add_normal_auc = @add_normal_auc;
return

%
function group = add_normal_auc(group)
tt = 20; % min, time_threshold
ts = 15; % min, time_span
my_fun = my_function;
disp('The normalized AUC is calculated using my_function.get_area_ratio(). ');
disp('with the input of "group{i}.time" and "group{i}.ratio(:,j)-1" from single cells. ');
disp('Its values represent the stability of the time courses. ')
disp(['The AUC was calculated during [', num2str([0 ts]), '] min after the signal peaked. '])
disp(['It is required that the time course peaked within ', num2str(tt), ' min. '])

num_group = length(group);
for i = 1:num_group
    num_cell = size(group{i}.ratio,2);
    group{i}.normal_auc = nan(num_cell, 1);
    time = group{i}.time;
    for j = 1:num_cell
        ratio = group{i}.ratio(:,j);
        group{i}.normal_auc(j) = my_fun.get_area_ratio(time, ratio-1, ...
            'time_threshold', tt, 'time_span', ts, 'verbose', 0);
        clear ratio;
    end
    clear time;
end
return