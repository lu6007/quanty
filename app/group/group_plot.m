% function [time_interp, ratio_array, group_name] = group_plot( group, varargin )
%     parameter_name = {'update_result','enable_plot','i_layer', 'method',...
%         'save_excel_file','sheet_name','t_limit',...
%         'enable_interpolation', 'enable_average_plot',...
%         'error_bar_interval', 'normalize'};
%     default_value = {0, 1, 1, 1, ...
%         0, '', [], 0,     0, 5, 0};
%
% Example:
% For method = 1 , load data from fluocell_data
% and load the compute_time_course result.mat
% >> group.name = 'p1';
% >> group.data = data;
% >> group_plot(group, 'method', 1);
% or
% >> group_plot(group, 'method', 1, 'normalize', 1);
%
% To save excel files
% group_plot(group,'method',1, 'save_excel_file', 1, 'sheet_name', 'Dish5');
%
% To specify y-limit
% group_plot(group,'method',1, 'save_excel_file', 1, 'sheet_name', 'Dish5',
% 'y_limit', [0.8 2]);
%
% For method = 2, read the excel file.
% >> p = 'C:\Users\public.BIOE-FRET-03.000\Documents\kathy\data\mingxing\lynfyn_0225_2014\';
% >> group.file = strcat(p, 'Quantification_02-26-2014');
% >> group.index = 1;
% >> group_plot(group, 'method', 2);
% The excel file has the format "time, ratio, time, ratio, ..., ratio'

% Copyright: Shaoying Lu and Yingxiao Wang 2013-2017 
% Email: shaoying.lu@gmail.com

function [time_interp, ratio_array, group_name] = group_plot( group, varargin )
    parameter_name = {'update_result','enable_plot','i_layer', 'method',...
        'save_excel_file','sheet_name','t_limit',...
        'enable_interpolation', 'enable_average_plot',...
        'error_bar_interval', 'normalize'};
    default_value = {0, 1, 1, 1, ...
        0, '', [], 0,     0, 5, 0};
    [update_result, enable_plot, i_layer, method,...
        save_excel_file, sheet_name, t_limit,enable_interpolation, ... 
        enable_average_plot, error_bar_interval, normalize] = ...
        parse_parameter(parameter_name, default_value, varargin);
    % i_layer : default = 1, outer layer

    if method ==1  
        group_name = group.name;
        fprintf('Group Name : %s\n', group_name);
     elseif method ==2  
        file_name = group.file;
        group_index = group.index;
    end;

    if method == 1 
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
            % Going through all subfolders, ignoring files, ./ , ../,  and the
            % output folder. 
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
            %%%
            res = load(result_file);
            %%%

            % Adding for loop to try to adapt group_plot() for multiple objects in one image -Shannon 8/12/2016
            num_object = length(res.ratio);
            for k = 1:num_object
                j = j+1;
%                % Adapting group_plot() for multiple objects. -Shannon 8/12/2016
%                % i_layer is currently the first (outer) layer or the first roi. 
                exp{1}.cell(j).this_image_index = res.this_image_index;
                exp{1}.cell(j).time = res.time;
                exp{1}.cell(j).value = res.ratio{k}(:,i_layer);
            end

            clear result_file res name_i data_i si_str;
        end; % for i 
      
    elseif method ==2 % read the time and ratio values from the excel file
        num_exp = 1;
        old_exp = excel_read_curve(file_name);
        exp{1} = old_exp{group_index};
        group_name = exp{1}.name;
        
   end; % if method == 1 || method ==3

  
    %% Make plots and possibly export to excel files
     for i = 1:num_exp
        num_cell = length(exp{i}.cell);
        num_frame = max(size(exp{i}.cell(1).time,1), size(exp{i}.cell(num_cell).time, 1));
        time_array = nan(num_frame, num_cell);
        ratio_array = nan(num_frame, num_cell);
        norm_ratio_array = nan(num_frame, num_cell);
        time_ratio_array = nan(num_frame, 2*num_cell);
        norm_time_ratio_array = nan(num_frame, 2*num_cell);

       for j = 1:num_cell
            time = exp{i}.cell(j).time;
            value = exp{i}.cell(j).value;
            time_array(:,j) = time;
            ratio_array(:,j) = value;
            time_ratio_array(:,j*2-1) = time;
            time_ratio_array(:,j*2) = value;

            before_index = (time>=-15) & (time<=0); 
            value_before = mean(value(before_index))';
            norm_ratio_array(:,j) = value/value_before;
            norm_time_ratio_array(:, j*2-1) = time;
            norm_time_ratio_array(:, j*2) = value/value_before;
            clear time value before_index;
        end;
    end %for i = 1:num_exp
    
    font_size = 24;
    line_width= 3;
    if enable_plot
        h = figure;
        plot(time_array, ratio_array, 'LineWidth', line_width);
        ylabel('Intensity Ratio');
        xlabel('Time (min)'); 
        title('Average Plot with Single Cell Data'); axis auto;
        my_figure('handle', h, 'line_width', line_width,'font_size', font_size);
%         set(gca, 'LineWidth', line_width,'FontWeight','bold', 'FontSize', font_size);
%         set(gca,'FontSize',font_size,'FontName','Arial', 'Fontweight', 'bold')
        
        h = figure;        
        plot(time_array, norm_ratio_array, 'LineWidth', line_width);
        ylabel('Intensity Ratio');
        xlabel('Time (min)'); 
        title('Average Plot with Single Cell Data'); axis auto;
        my_figure('handle', h, 'line_width', line_width, 'font_size', font_size);
%         set(gca, 'LineWidth', line_width,'FontWeight','bold', 'FontSize', font_size);
%         set(gca,'FontSize',font_size,'FontName','Arial', 'Fontweight', 'bold')
     end;
     clear time_array ratio_array norm_ratio_array;

     if save_excel_file
         file_name = strcat(group.data.path,'../../', 'result.xlsx');
         % Save the original and normalized results
         % Time, Ratio, Time, Ratio at the same length with nan for missing files.   
        original_sheet = strcat(sheet_name, '-', num2str(i));
        xlswrite(file_name, time_ratio_array, original_sheet, 'A1');
        norm_sheet = strcat(sheet_name, '-Norm-', num2str(i));
        xlswrite(file_name, norm_time_ratio_array, norm_sheet, 'A1');
    end;
    clear time_ratio_array original_sheet norm_time_ratio_array norm_sheet;
        

    % Prepare for interpolation
    % If the user did not specify an itnerpolation range, extract
    % information from image data. 
    if isempty(t_limit)   
        jj = 1;
        first_time_point = exp{1}.cell(end).time(jj); % extract the first point time of image data
        while isnan(first_time_point) 
            jj = jj+1;
            first_time_point = exp{1}.cell(jj).time(1); 
        end;
        jj = 0;
        last_time_point = exp{1}.cell(1).time(end-jj); % extract the last time point of image data
        while isnan(last_time_point)
            jj = jj+1;
            last_time_point = exp{1}.cell(jj).time(end-jj);
        end;
        t_left_limit = ceil(first_time_point); 
        t_right_limit = floor(last_time_point);
        t_limit = [t_left_limit, t_right_limit];
    end % if isempty(t_limit)
    
    time_interp = [t_limit(1):0.5:0, 0.1:0.1:10, 10.5:0.5:t_limit(2)]';

    % Gather the cfp/fret ratio together 
    % Calculate Interpolation
    % Allow the interp_time to be longer than the actual image time 
    % (should not allow this)
    % Extend the ratio values to both sides horizontally 

    % Initialize the vectors/matrices
    num_cell_total =0;
    for i =1:num_exp
        num_cell_total = num_cell_total+ length(exp{i}.cell);
    end;
    nn = length(time_interp); % number of time_points
    ratio_array=zeros(nn, num_cell_total);
    this_cell = 1;
    for i = 1:num_exp
        num_cell = length(exp{i}.cell);
        for j = 1:num_cell
            this_image_index = exp{i}.cell(j).this_image_index;
            this_time = exp{i}.cell(j).time(this_image_index);
            this_ratio = exp{i}.cell(j).value(this_image_index);
            ratio_array(:,this_cell) = my_interp(this_time, this_ratio, time_interp);
            this_cell = this_cell+1;
            clear this_cell_name data result_file res this ratio this_image_index;
        end;
    end;

    % Normalized cfp/fret ratio
    norm_ratio_array = zeros(size(ratio_array));
    this_cell = 1;
    % Between -15 and 0 minutes
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
    if enable_plot  && enable_interpolation
        title_str = plot_title;
        % Plot the Ratio Arrays
        h=figure;
        plot(time_interp, ratio_array, 'LineWidth', line_width);
        my_figure('handle', h, 'line_width', line_width, 'font_size', font_size);
        title(regexprep(title_str,'_','\\_'));
        xlabel('Time (min)');
        ylabel('Intensity Ratio');


        h=figure;
        plot(time_interp, norm_ratio_array, 'LineWidth', line_width);
        my_figure('handle', h, 'line_width', line_width, 'font_size', font_size);
        title(regexprep(title_str,'_','\\_'));
        xlabel('Time (min)');
        ylabel('Norm. Intensity Ratio');

    end; % if enable_plot

    % plot the average curve with all data ploted as circles
    if enable_average_plot
        % stop_index = find(time_interp == last_time_point);
        num_cell = size(norm_ratio_array, 2);
        if normalize
            mean_ratio_array = mean(norm_ratio_array, 2);
            std_error = std(norm_ratio_array, 0, 2)/sqrt(num_cell);
        else
            mean_ratio_array = mean(ratio_array, 2);
            std_error = std(ratio_array, 0, 2)/sqrt(num_cell);
        end;
        h = figure; hold on;
        for n = 1 : length(exp{1, 1}.cell)      
            if normalize
                value = exp{1}.cell(n).norm_value;
            else
                value = exp{1}.cell(n).value;
            end;
            plot(exp{1}.cell(n).time, value, 'o', 'color', [0.5 0.5 0.5]);
            clear value;
            % plot(time_interp, norm_ratio_array, 'o', 'color', [0.5 0.5 0.5]);
        end 
        % add the error bar
        plot(time_interp, mean_ratio_array, 'k', 'LineWidth', line_width);
        add_error_bar(time_interp, mean_ratio_array, std_error,...
            'error_bar_interval', error_bar_interval);
        my_figure('handle', h, 'line_width', line_width, 'font_size', font_size);
        ylabel('Intensity Ratio');
        xlabel('Time (min)'); 
        title('Average Plot with Single Cell Data'); axis auto;
        % axis([t_limit, y_limit_before_norm]);
    end % plot the average curve with all original data ploted as circles

    %% export to excel files
    if save_excel_file
        time_ratio = [time_interp norm_ratio_array];
        file_name = strcat(group.data.path,'../../', 'result-norm.xlsx');
        if ~isempty(sheet_name)
            xlswrite(file_name, time_ratio, strcat(sheet_name,'-Interp'));
        else
            xlswrite(file_name, time_ratio);
        end;

        %%%%%%%%%%%%%%%%%%%%%output the original ratio value
        time_ratio1 = [time_interp ratio_array];
        file_name1 = strcat(group.data.path,'../../', 'result-interp.xlsx');
        if ~isempty(sheet_name)
            xlswrite(file_name1, time_ratio1, strcat(sheet_name,'-Interp'));
        else
            xlswrite(file_name1, time_ratio1);
        end;
    end % if save_exel_file

return;

% Calculate Interpolation
% (1) Allow the interp_time to be longer than the actual image time
% Extend the ratio values to both sides horizontally
% (2) Insert time =0 and average basal value into the time course
% at 0 min.
% (3) Smooth the data before and after interpolation seperately. 
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

% Insert the 0 min ratio value
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

y_interp = interp1(this_time, this_ratio,time_interp,'linear');
% y_before = smooth(y_interp(time_interp<=0), smooth_span);
% y_after = smooth(y_interp(time_interp>0), smooth_span); clear y_interp;
temp = smooth(y_interp(time_interp<=0.5), smooth_span);
y_before = temp(time_interp<=0); clear temp;
temp = smooth(y_interp(time_interp>=-0.5), smooth_span); 
y_after = temp(3:end); clear y_interp temp; % time_interp>0
y_interp = [y_before; y_after];
return;



