% function [time_interp, ratio_array, group_name] = group_plot( name, varargin )
% Plot the time course of FRET ratio together
% parameter_name = {'update_result','enable_plot','i_layer', 'normalize','method',...
%     'save_excel_file','sheet_name','y_limit', 't_limit', 'compute_cell_size'};
% default_value = {0, 1, 1, 1, 1, 0, '', [0.8 3],[-10 100], 0};
%
% Example:
% For method = 1, load the compute_time_course result.mat
% >> group.name = 'FN1_2';
% >> group_plot(group, 'method', 1); 
%
% For method = 2, read the excel file.
% >> p = 'C:\Users\public.BIOE-FRET-03.000\Documents\kathy\data\mingxing\lynfyn_0225_2014\';
% >> group.file = strcat(p, 'Quantification_02-26-2014');
% >> group.index = 1;
% >> group_plot(group, 'method', 2);
% The excel file has the format "time, ratio, time, ratio, ..., ratio'
% 
% For method = 3, load data from fluocell_data
% >> group.name = 'p1';
% >> group.data = data;
% >> group_plot(group, 'method', 3);
% or
% >> group_plot(group, 'method', 3, 'normalize', 1);
% 
% To save excel files
% group_plot(group,'method',3, 'save_excel_file', 1, 'sheet_name', 'Dish5');
%
% To specify y-limit
% group_plot(group,'method',3, 'save_excel_file', 1, 'sheet_name', 'Dish5',
% 'y_limit', [0.8 2]);
%
% To plot cell-size figure and output the result to excel file
% group_plot(group,'method',3, 'save_excel_file', 1, 'sheet_name',
% 'Dish5','compute_cell_size','1');


% Copyright: Shaoying Lu and Yingxiao Wang 2013-2017 
% Email: shaoying.lu@gmail.com

function [time_interp, ratio_array, group_name] = group_plot( group, varargin )
parameter_name = {'update_result','enable_plot','i_layer', 'normalize','method',...
    'save_excel_file','sheet_name','y_limit', 'y_limit_before_norm', 't_limit',...
    'compute_cell_size', 'tag_curve', 'shift', 'enable_average_plot', 'error_bar_interval'};
default_value = {0, 1, 1, 1, 1, ...
    0, '', [0.8 3],[0.1 0.8],[-10 100], 0, 0, 10, 0, 5};
[update_result, enable_plot, i_layer, normalize, method,...
    save_excel_file, sheet_name, y_limit, y_limit_before_norm, t_limit,...
    compute_cell_size, tag_curve, shift, enable_average_plot, error_bar_interval] = ...
    parse_parameter(parameter_name, default_value, varargin);
% i_layer : default = 1, outer layer

% time_interp = [-15:0.5:0,0:0.1:10,10:0.5:140]';
% lexie 10032014

%time_interp = [-20:2:0,0:1:10,10:2:160]';
if method ==1 || method ==3 
    group_name = group.name;
    fprintf('Group Name : %s\n', group_name);
elseif method ==2 || method == 4 
    file_name = group.file;
    group_index = group.index;
end;

result_file = strcat(group.data.path,'output/', 'result.mat');
% method == 1 is the same as method == 3
% so we can merge them together. 
if method == 1 % load result.mat
    % exp = init_group(group_name);
    res = load(result_file);
    exp = res.exp; clear res;
    num_exp = length(exp);

    if update_result % default = 0
        for i = 1:num_exp
            num_cell = length(exp{i}.cell_name);
            for j = 1:num_cell
                this_cell_name = exp{i}.cell_name{j};
                 data = init_data(this_cell_name);
                 % result_file = strcat(data.path, 'output/', 'result.mat');
                 delete(result_file);
                 compute_time_course(this_cell_name, data);
            end;
        end;        
    end;
    
    % load the time and ratio values from result.mat file
    % load the area variable if it exists
    for i = 1:num_exp
        num_cell = length(exp{i}.cell_name);
        %exp{i}.cell = cell(num_cell, 1);
        for j = 1:num_cell
            this_cell_name = exp{i}.cell_name{j};
            data = init_data(this_cell_name);
            result_file = strcat(data.path, 'output/','result.mat');
            res = load(result_file);
            exp{i}.cell(j).time = res.time(data.image_index);
            exp{i}.cell(j).value = res.fret_ratio(data.image_index, i_layer);
            if compute_cell_size
                exp{i}.cell(j).size = res.cell_size(data.image_index);
            end;
            clear cell_name data result_file res;
        end;
    end;
elseif method ==2 % read the time and ratio values from the excel file
    num_exp = 1;
    old_exp = excel_read_curve(file_name);
    exp{1} = old_exp{group_index};
    % pdgf time is saved to the last row of the first time column
    % Need to improve the excel_read_curve function later
    nnn = length(exp{1}.cell(1).time);
    tt = exp{1}.cell(1).time(nnn);
    for j = 1:length(exp{1}.cell)
        exp{1}.cell(j).time = exp{1}.cell(j).time -tt;
    end;
    group_name = exp{1}.name;
     
elseif method == 3 
    % loop through the subfolders and automatically 
    % process the data. 
    data = group.data;
    name = group.name;
    % Loop through the subfolders 
    list = dir(strcat(data.path,'../'));
    % ignore the 1st and 2nd folders which are './' and '../'
    num_folder = length(list);
    num_exp =1;
    exp = cell(num_exp, 1);
    j=0;
    for i = 3: num_folder
        % Going through all subfolders, ignoring files, ./ , ../,  the output
        % folder
        if ~list(i).isdir % ignore all the files
            continue;
        end;
       data_i = data;
       name_i =list(i).name;
       if strcmp(name_i, 'output') % ingore the output folder
           continue;
       end;

       data_i.path = set_path_i(data.path, name, name_i); 
       result_file = strcat(data_i.path, 'output/','result.mat');
        if update_result
            delete(result_file);
            compute_time_course(name_i, data_i);
        end;
        res = load(result_file);
        
        %Adding for loop to try to adapt group_plot() for multiple objects in one image -Shannon 8/12/2016
        num_object = length(res.fret_ratio);
        for k = 1:num_object
            j = j+1;

        % read the right time for plotting, Lexie on 02/19/2015
%         exp{1}.cell(j).time = res.time(res.this_image_index);
            exp{1}.cell(j).time = res.time(res.this_image_index,2);
        
        % Adapting group_plot() for multiple objects. -Shannon 8/12/2016
        % i_layer is currently the first (outer) layer or the first roi. 
            exp{1}.cell(j).value = res.fret_ratio{k}(res.this_image_index, i_layer);
            if compute_cell_size
                exp{1}.cell(j).size = res.cell_size{k}(res.this_image_index);
            end;
        end
        
        clear result_file res name_i data_i si_str;
    end; % for i 
end; % if method == 1, 


% preparation for interpolation
first_point_time = exp{1, 1}.cell(1).time(1); % extract the first point time of image data
last_point_time = ceil(exp{1, 1}.cell(end).time(end)); % extract the last time point of image data
if any(strcmp(varargin, 't_limit'))   % user specifies a interplotation range, use this range
    t_left_limit = t_limit(1);
    t_right_limit = t_limit(2);
else
    t_left_limit = floor(first_point_time); % if there is no such input, extract information from image data
    t_right_limit = ceil(last_point_time);
end
t_limit = [t_left_limit, t_right_limit];
time_interp = [t_limit(1) : 0.5 : -0.5,0 : 0.1 : 10,10.5 : 0.5 : t_limit(2)]';

% Gather the cfp/fret ratio together 
% Calculate Interpolation
% Allow the interp_time to be longer than the actual image time %%% Shoud
% not allow this
% Extend the ratio values to both sides horizontally 

% Initialize the vectors/matrices
num_cell_total =0;
for i =1:num_exp
    num_cell_total = num_cell_total+ length(exp{i}.cell);
end;
nn = length(time_interp); % number of time_points
ratio_array=zeros(nn, num_cell_total);
size_array = zeros(nn, num_cell_total);
this_cell = 1;
for i = 1:num_exp
    num_cell = length(exp{i}.cell);
    for j = 1:num_cell
        this_time = exp{i}.cell(j).time;
        this_ratio = exp{i}.cell(j).value;
        ratio_array(:,this_cell) = my_interp(this_time, this_ratio, time_interp);
        if compute_cell_size
            this_size = exp{i}.cell(j).size;
            size_array(:, this_cell) = my_interp(this_time, this_size, time_interp);
        end;
        this_cell = this_cell+1;
        clear this_cell_name data result_file res this ratio;
    end;
end;

% Normalized cfp/fret ratio
norm_ratio_array = zeros(size(ratio_array));
this_cell = 1;
% Between -5 and -2 minutes
before_index = (time_interp<=0)&(time_interp>=-15); 
ratio_before = (mean(ratio_array(before_index, :)))';
for i = 1:num_exp
    num_cell = length(exp{i}.cell);
    for j = 1:num_cell
        norm_ratio_array(:,this_cell) = ratio_array(:,this_cell)/ratio_before(this_cell);
        exp{i}.cell(j).norm_value = exp{i}.cell(j).value/ratio_before(this_cell);
        this_cell = this_cell+1;
    end;
end;

% make the right name for plots, Lexie on 02/19/2015
if any(strcmp(varargin, 'sheet_name'))
    index_temp = find(strcmp(varargin, 'sheet_name')) + 1;
    plot_title = varargin{1, index_temp};
else
    plot_title = '';
end; clear intex_temp
    

% Make plots of the CFP/FRET and Normalized ECFP/FRET ratios
if enable_plot
    % Plot the Ratio Arrays
    my_plot(time_interp, ratio_array, ...
        'title_str',  plot_title);
    ylabel('Intensity Ratio');
    if tag_curve
        str = {'Please choose the curves that need to be removed',...
            'Click the red circle on time axis to finish the process'};
        title(str); clear str;
        hold on
        plot(0, y_limit_before_norm(1), 'ro', 'LineWidth', 3);
        for n = 1 : length(ratio_array(1,:))
            index = time_interp == n + shift;
            plot(n + shift, min(y_limit_before_norm(2) - 0.05, ratio_array(index, n)),...
                'ro', 'LineWidth', 3);
        end 
        hold off
        x_index = 1;
        [x(x_index), ~] = ginput(tag_curve);
        while(round(x(x_index)) >=  shift)
            x_index = x_index + 1;
            [x(x_index), ~] = ginput(tag_curve);
        end
        x(length(x)) = [];
        index_bad_position = round(x) - shift; % the index number of the bad position
        % list(1).name = '.'; list(2).name = '..';
        % list(3).name = 6.nd; list(4).name ='output';
        % So we are ingoring the first 4 folders and index into the 5th
        % folder directly. This may need to be revised if
        % input images are not from metamorph. 
        for ii = 1 : length(index_bad_position)
            bad_pos{ii}= list(index_bad_position(ii) + 4).name;
        end
        % bad_pos = ['p', num2str(nn)];
        % If bad positions are specified by the user, 
        % move the files to the output folder.
        % If there is no bad position, do nothing.
        if exist('bad_pos', 'var')
            curve_path = strrep(group.data.path, 'p1', bad_pos);
            des_path = strrep(group.data.path, 'p1', 'output');
            if length(bad_pos) == 1
                prompt = ['The position chosen here is ', bad_pos{1}, ...
                    ', Do you want to exclude it? Y/N [N]: '];
            else
                prompt = 'The positions chosen here are ';
                for ii = 1 : length(bad_pos) - 1
                    if length(bad_pos) - 1 == 1
                        prompt = [prompt, bad_pos{ii}];
                    else
                        if ii == length(bad_pos) - 1
                            prompt = [prompt, bad_pos{ii}];
                        else
                            prompt = [prompt, bad_pos{ii}, ', '];
                        end
                    end
                end
                prompt = [prompt, ' and ', bad_pos{length(bad_pos)}, ...
                    ', Do you want to exclude them? Y/N [N]: '];
            end
            str = input(prompt, 's');
            if isempty(str)
                str = 'N';
            end
            if strcmp(str, 'Y') || strcmp(str, 'y')
                for ii = 1 : length(curve_path)
                    [~, ~, ~] = movefile(curve_path{ii}, des_path, 'f');
                end
                norm_ratio_array(:, index_bad_position) = [];
                ratio_array(:, index_bad_position) = [];
            end
        end
        my_plot(time_interp, ratio_array, 'title_str',  plot_title);
            ylabel('Intensity Ratio');
    end; % if tag_curve
    my_plot(time_interp, norm_ratio_array, 'title_str',  plot_title);
    ylabel('Normalized Intensity Ratio');
    
end; % if enable_plot

% Normalize cell size
if sum(sum(size_array))>0
    norm_size_array = zeros(size(size_array));
    this_cell = 1;
    size_before = (mean(size_array(before_index, :)))';
    for j = 1:num_cell
        norm_size_array(:,this_cell) = size_array(:,this_cell)/size_before(this_cell);
        this_cell = this_cell+1;
    end; 
    if enable_plot
        % Plot the size arrays
        my_plot(time_interp, size_array, 'title_str',  plot_title);
        ylabel('Cell Size');
        % axis([min(time_interp) max(time_interp) 10000 200000]);
        axis auto;
        my_plot(time_interp, norm_size_array, 'title_str',  plot_title);
        ylabel('Normalized Cell Size');
        % axis([min(time_interp) max(time_interp) 0.5 2]);
        axis auto;
    end;
end;

% plot the average curve with all normalized data ploted as circles
font_size = 24;
line_width= 3;
if enable_average_plot
    stop_index = find(time_interp == last_point_time);
    mean_ratio_array = mean(norm_ratio_array(1:stop_index, :), 2);
    figure('color', 'w');
    set(gca, 'LineWidth', line_width,'FontWeight','bold', 'FontSize', font_size);
    set(gca,'FontSize',font_size,'FontName','Arial', 'Fontweight', 'bold')
    set(findall(gcf,'type','text'),'FontSize',font_size,'FontName','Arial', 'Fontweight', 'bold');
    % set(gcf, 'Position', [400 400 600 450]); 
    hold on;
    for n = 1 : length(exp{1, 1}.cell)      
        plot(exp{1, 1}.cell(n).time, exp{1, 1}.cell(n).norm_value, 'o', 'color', [0.5 0.5 0.5]);
        % plot(time_interp, norm_ratio_array, 'o', 'color', [0.5 0.5 0.5]);
    end 
    % add the error bar
    plot(time_interp(1 : stop_index), mean_ratio_array, 'k', 'LineWidth', line_width);
    std_error = std(norm_ratio_array,0,2) / sqrt(size(norm_ratio_array, 2));
    add_error_bar(time_interp, mean(norm_ratio_array, 2), std_error, 'error_bar_interval', error_bar_interval);
    ylabel('Intensity Ratio');
    xlabel('Time (min)'); 
    title('Average Plot with Single Cell Data'); axis auto;
    % axis([t_limit, y_limit_before_norm]);
end % plot the average curve with all original data ploted as circles


% violin plot as an indication of group density distribution

    

% %%%%%%%%%%%%%%%%%%%%%%%output original ratio value; Lexie on 0918
%cancel clear variable 
% if normalize, % return the normalized ratio array
%     clear ratio_array;
%     ratio_array = norm_ratio_array; clear norm_ratio_array;
% end;
% %%%%%%%%%%%%%%%%%end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% export to excel files
if save_excel_file
    time_ratio = [time_interp norm_ratio_array];
    file_name = strcat(group.data.path,'../../', 'result-norm');
    if ~isempty(sheet_name)
        xlswrite(file_name, time_ratio, sheet_name);
    else
        xlswrite(file_name, time_ratio);
    end;
    
    %%%%%%%%%%%%%%%%%%%%%output the original ratio value
    time_ratio1 = [time_interp ratio_array];
    file_name1 = strcat(group.data.path,'../../', 'result-raw');
    if ~isempty(sheet_name)
        xlswrite(file_name1, time_ratio1, sheet_name);
    else
        xlswrite(file_name1, time_ratio1);
    end;
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%end
    %%%%%10/21/2014 Lexie output the excel file of cell size
    if compute_cell_size
        time_size = [time_interp norm_size_array];
        file_name = strcat(group.data.path,'../../','cell-size');
        if ~isempty(sheet_name)
            xlswrite(file_name, time_size, sheet_name);
        else
            xlswrite(file_name, time_size);
        end
    end;

end % if save_exel_file
return;

% Calculate Interpolation
% (1) Allow the interp_time to be longer than the actual image time
% Extend the ratio values to both sides horizontally
% (2) Insert time =0 and average basal value into the time course
% at 0 min.
function y_interp = my_interp(x,y, x_interp)
this_time = x;
time_interp = x_interp;
this_ratio = y;
nn = length(time_interp);
smooth_span = 40;

if min(this_time)>time_interp(1)
    temp = [time_interp(1); this_time]; clear this_time;
    this_time = temp; clear temp;
    temp = [this_ratio(1,:); this_ratio]; clear this_ratio;
    this_ratio = temp; clear temp;
end;
if max(this_time)<time_interp(nn)
    temp = [this_time; time_interp(nn)]; clear this_time;
    this_time = temp; clear temp;
    temp = [this_ratio; this_ratio(length(this_ratio), :)]; clear this_ratio;
    this_ratio = temp; clear temp;
end;

% Insert 0 min ratio value
index_before = (this_time < 0);
index_0 = (this_time == 0);
index_after = (this_time>0 & this_time<=time_interp(nn));
average_basal = mean(this_ratio(index_before));
% if 0 is not in the array this_time,
% add 0 into the time course
if ~sum(double(index_0))
    temp = [this_time(index_before); 0; this_time(index_after)]; clear this_time;
    this_time = temp; clear temp;
    temp = [this_ratio(index_before); average_basal; this_ratio(index_after)]; clear this_ratio;
    this_ratio = temp; clear temp;
end;

y_interp = interp1(this_time, this_ratio,time_interp,'pchip');
y_before = smooth(y_interp(time_interp<=0), smooth_span);
y_after = smooth(y_interp(time_interp>0), smooth_span); clear y_interp;
y_interp = [y_before; y_after];

% figure; plot(this_time, this_ratio, '+'); hold on; plot(time_interp, y_interp);

return;


% Plot the Ratio Array
function my_plot(x, y, varargin)
    parameter_name = {'title_str'};
    default_value ={''};
    title_str = parse_parameter(parameter_name, default_value, varargin);
    
    font_size = 24;
    figure('color', 'w'); hold on;
    set(gca, 'LineWidth', 1.5,'FontWeight','bold', 'FontSize', font_size);
    set(gca,'FontSize',font_size,'FontName','Arial', 'Fontweight', 'bold')
    set(findall(gcf,'type','text'),'FontSize',font_size,'FontName','Arial', 'Fontweight', 'bold');
    % set(gcf, 'Position', [400 400 600 450]); 
    plot(x, y, 'LineWidth',1.5);
    title(regexprep(title_str,'_','\\_'));
    xlabel('Time (min)');
return;
