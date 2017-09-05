function my = my_function()
    % Change the following line to the location of your quanty_dataset_2.
    % Close the folder name with '/'
    my.root = '/Users/kathylu/Documents/sof/data/quanty_dataset_2/';
    my.pause = @my_pause;
    my.dir = @my_dir;
    %
    my.get_value_before = @get_value_before;
    my.get_time_interp = @get_time_interp;
    my.normalize_time_value_array = @normalize_time_value_array;
    my.interpolate_time_value_array = @interpolate_time_value_array;
    my.statistic_test = @statistic_test;
return

% function my_pause(enable_pause, pause_str)
% Allows the function name and pause_str to be dislayed
% when enable_pause = 1 . 
function my_pause(enable_pause, pause_str)
if enable_pause
    % find the name of upper level function
    fun = dbstack;
    if length(fun)>=2
        disp([fun(2).name, ': paused. ', pause_str]);
    else
        disp([fun(1).name, ': paused. ', pause_str]);
    end
    pause;
end
return

% Find the list of subfolders
% ignore the 1st and 2nd folders which are './' and '../'
% ignore all the files and the output folder
function list = my_dir(p)
    % Loop through the subfolders 
    % ignore the 1st and 2nd folders which are './' and '../'
    % ignore all the files and the output folder
    list = dir(p);
    num_folder = length(list);
    valid_folder = false(num_folder, 1);
    for i = 3:num_folder
        if list(i).isdir && ~strcmp(list(i).name, 'output')
            valid_folder(i) = true;
        end
    end
    temp = list(valid_folder); clear list;
    list = temp; clear temp; 
return

% function value_before = my_get_value_before(time, value)
% Find average value for time between -15 min and 0 min
function value_before = get_value_before(time, value)
    before_index = (time>=-15) & (time<=0); 
    value_before = mean(value(before_index))';
    if isnan(value_before) 
        % find the first non-nan value and use that to normalize
       ii = find(~isnan(value),1); 
       value_before = value(ii);
    end
return

% function time_interp = my_get_time_interp(time_bound, time_array)
% Caculate time for interpolation from time_bound
% If the user did not specify an itnerpolation range, 
% estimate time_interp from the time_array. 
function time_interp = get_time_interp(time_array, varargin)
    para_name = {'time_bound'};
    default_value = {[]};
    time_bound = parse_parameter(para_name, default_value, varargin);
    
    if isempty(time_bound)   
        jj = 1;
        first_time_point = time_array(jj,end); % extract the first point time of image data
        while isnan(first_time_point) 
            jj = jj+1;
            first_time_point = time_array(jj,1); 
        end
        jj = 0;
        last_time_point = time_array(end-jj,1); % extract the last time point of image data
        while isnan(last_time_point)
            jj = jj+1;
            last_time_point = time_array(end-jj, jj);
        end
        time_bound = [ceil(first_time_point), floor(last_time_point)];
    end % if isempty(time_bound)
    
    time_interp = [time_bound(1):0.5:0, 0.1:0.1:10, 10.5:0.5:time_bound(2)]';
return

% function norm_ratio_array = normalize_time_value_array(time_array, ratio_array )
% Calculated normalized ratio array
function norm_value_array = normalize_time_value_array(time_array, value_array)
    [num_frame, num_cell] = size(time_array);
    norm_value_array = nan(num_frame, num_cell);
    for j = 1:num_cell
        value = value_array(:,j);
        value_before = get_value_before(time_array(:,j), value);
        norm_value_array(:,j) = value/value_before;
        clear value;
    end
return

% function interp_value_array = interpolate_time_value_array(time_array, value_array,...
%    time_interp)
% Calculate interpolation of arrays
function interp_value_array = interpolate_time_value_array(time_array, value_array,...
    time_interp)
    num_time = size(time_interp, 1);
    num_cell = size(value_array, 2);
    interp_value_array = nan(num_time, num_cell);
    for j = 1:num_cell
        interp_value_array(:, j) = my_interp(time_array(:,j),value_array(:, j), ...
            time_interp, 'smooth_span', 10);
    end 
return;

% function p = statistic_test(x,y, test_name)
% Perform 2 sample statistical tests
% test_name can be 'kstes', ranksum', or 'ttest'
function p = statistic_test(x,y, test_name)
    switch test_name
        case 'kstest'
            [~,p] = kstest2(x,y);
        case 'ranksum'
            p = ranksum(x,y);
        case 'ttest' 
            % two-tail and unequal variance
            [~, p] = ttest2(x,y, 'Vartype', 'unequal');
    end
return