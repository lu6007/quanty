% function [time_array, ratio_array, group_name] = group_plot( group, varargin )
%     parameter_name = {'update_result','enable_plot','i_layer', 'method',...
%         'save_excel_file','sheet_name','enable_interpolate', 'time_bound', 'smooth_span', ...
%         'enable_average_plot', 'error_bar_interval', ...
%         'enable_normalize', 'normalize_time_bound', 'select_track'};
%     default_value = {0, 1, 1, 1, ...
%         0, '', 0, [], 9, ...
%         0, 5, ...
%         0, [-15 0], {}};
%
% Example:
% For method = 1 , load data from fluocell_data
% and load the compute_time_course result.mat
% >> group.name = 'p1';
% >> group.data = data;
% >> group_plot(group, 'method', 1);
% or
% >> group_plot(group, 'method', 1, 'enable_normalize', 1);
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
%
% For select_track, it is used to select good tracks from the quantified time
% cousrse. select_track is a cell with the same number of entries as the
% number of valid subfolders/positions. Each entry contains a column vector
% indicating the tracks to be selected. 
% Example: 
% >> select_track = {[2], [1;2], [1;3]};
% >> group_plot(group, 'method', 1, 'enable_normalize', 1, 'save_excel_file', 1, ...
%  'sheet_name', 'ratio', 'select_track', select_track);

% Copyright: Shaoying Lu and Yingxiao Wang 2013-2017 
% Email: shaoying.lu@gmail.com

function [time_array, ratio_array, group_name] = group_plot( group, varargin )
    parameter_name = {'update_result','enable_plot','i_layer', 'method',...
        'save_excel_file','sheet_name','enable_interpolate', 'time_bound', 'smooth_span', ...
        'enable_average_plot', 'error_bar_interval', ...
        'enable_normalize', 'normalize_time_bound', 'select_track'};
    default_value = {0, 1, 1, 1, ...
        0, '', 0, [], 9, ...
        0, 5, ...
        0, [-15 0], {}};
    [update_result, enable_plot, i_layer, method,...
        save_excel_file, sheet_name, enable_interpolate, time_bound, smooth_span, ...
        enable_average_plot, error_bar_interval, ...
        enable_normalize, normalize_time_bound, select_track] = ...
        parse_parameter(parameter_name, default_value, varargin);
    % i_layer : default = 1, outer layer

    if method ==1 
        group_name = group.name;
        fprintf('Group Name : %s\n', group_name);
     elseif method ==2  
        file_name = group.file;
        group_index = group.index;
    end

    if method == 1 
        % loop through the subfolders and automatically 
        % process the data. 
        data = group.data;
        name = group.name;
        % Loop through the subfolders 
        my_fun = my_function();
        list = my_fun.dir(strcat(data.path, '../'));
        num_folder = length(list);
        
        num_exp = 1;
        exp = cell(num_exp, 1);
        j=0;
        for i = 1: num_folder
           data_i = data;
           name_i =list(i).name;
           data_i.path = set_path_i(data.path, name, name_i); 
           result_file = strcat(data_i.path, 'output/','result.mat');
            if update_result
                delete(result_file);
                compute_time_course(name_i, data_i);
            end
            %%%
            res = load(result_file);
            %%%

            num_object = length(res.ratio);
            if isempty(select_track) || isempty(select_track{i})
                loop_index = (1:num_object)';
            else
                loop_index = select_track{i};
            end
            % To pre-allocate cell(j), need to make a cell array,
            % then convert the cell array to structure.
            for k = loop_index'
                j = j+1;
%                % Adapting group_plot() for multiple objects. -Shannon 8/12/2016
%                % i_layer is currently the first (outer) layer or the first roi. 
                exp{1}.cell(j).this_image_index = res.this_image_index;
                exp{1}.cell(j).time = res.time;
                ratio = res.ratio{k}(:, i_layer);
                exp{1}.cell(j).value = ratio; 
                clear ratio; 
            end

            clear result_file res name_i data_i si_str loop_index;
        end % for i 
      
    elseif method ==2 % read the time and ratio values from the excel file
        old_exp = excel_read_curve(file_name);
        num_exp = length(group_index);
        exp = cell(num_exp, 1);
        ii = 1;
        for i = group_index'
            exp{ii} = old_exp{i};
            ii = ii+1;
        end
        group_name = exp{1}.name;   
        clear old_exp;
    end % if method == 1 || method ==3

    my_fun = my_function();
    
    % Pre-count the total number of cells and the max number of frames
    num_cell_total = 0;
    num_frame_temp = zeros(num_exp, 1); 
    for i =1:num_exp
        num_cell = length(exp{i}.cell); 
        exp{i}.num_cell = num_cell;
        num_cell_total = num_cell_total+ num_cell;
        temp = zeros(num_cell, 1);
        for j = 1:num_cell
            temp(j) = size(exp{i}.cell(j).value, 1);
        end
        num_frame_temp(i) = max(temp);
        clear temp
    end
    num_frame = max(num_frame_temp); clear num_frame_temp;
    
    % Make plots and possibly export to excel files
    ii = 1;
    time_array = nan(num_frame, num_cell);
    ratio_array = nan(num_frame, num_cell);
    for i = 1:num_exp
        for j = 1:exp{i}.num_cell
            time = exp{i}.cell(j).time;
            nn = size(time, 1);
            time_array(1:nn,ii) = time;
            ratio_array(1:nn,ii) = exp{i}.cell(j).value;
            ii = ii+1;
            clear time;
       end
    end %for i = 1:num_exp
    
%     %%%
%     time_array = time_array-810; 
%     %%%
        
    if enable_normalize
        norm_ratio_array = my_fun.normalize_time_value_array(time_array, ratio_array, ...
            'time_bound', normalize_time_bound);
        clear ratio_array; 
        ratio_array = norm_ratio_array; 
        clear norm_ratio_array; 
        % time_array will be the same
    end

    original_time_array = time_array;
    original_ratio_array = ratio_array; 
    
    % Calculate Interpolation
    % Allow the interp_time to be longer than the actual image time 
    % (should not allow this)
    % Extend the ratio values to both sides horizontally 
    if enable_interpolate
        [time_array_interp, ratio_array_interp] = ...
            my_fun.interpolate_time_value_array(time_array, ratio_array, ...
            'time_bound', time_bound, 'smooth_span', smooth_span);
        clear time_array; time_array = time_array_interp; clear time_array_interp; 
        clear ratio_array; ratio_array = ratio_array_interp; clear ratio_array_interp;
    end 
        
    font_size = 24;
    line_width= 3;
    if ~enable_normalize && ~enable_interpolate
        title_str = 'Single-cell Time Courses'; 
        output_file = 'result-raw.xlsx';
    elseif enable_normalize && ~enable_interpolate
        title_str = 'Normalized Time Courses';
        output_file = 'result-normaliz.xlsx';
    elseif ~enable_normalize && enable_interpolate
        title_str = 'Single-cell Time Courses';
        output_file = 'result-interpolate.xlsx';
    else % enable_normalize && enable_interpolate
        title_str = 'Normalize Time Courses';
        output_file = 'result-normalize-interpolate.xlsx';
    end
    
    if enable_plot
        my_figure('line_width', line_width,'font_size', font_size);
        plot(time_array, ratio_array, 'LineWidth', line_width);
        ylabel('Intensity Ratio'); xlabel('Time (min)'); 
        title(title_str); axis auto;
        % set(gca, 'LineWidth', line_width, 'FontSize', font_size);
    end

%     % make the right name for plots, Lexie on 02/19/2015
% ...
%         index_temp = find(strcmp(varargin, 'sheet_name')) + 1;
%         plot_title = varargin{1, index_temp};
%         title_str = plot_title;
%         title(regexprep(title_str,'_','\\_'));
% ... 
%     end % if enable_plot

    
    if save_excel_file 
        if ~enable_interp
            [num_frame, num_cell] = size(time_array);
            time_ratio_array = nan(num_frame, 2*num_cell);
            time_ratio_array(:, 1:2:2*num_cell-1) = time_array;
            time_ratio_array(:, 2:2:2*num_cell) = ratio_array;
        else 
            time_ratio_array = [time_array ratio_array];
        end
         file_name = strcat(group.data.path,'../output/', output_file);
         % Save the original and normalized results
         % Time, Ratio, Time, Ratio at the same length with nan for missing files.   
        original_sheet = strcat(sheet_name, '-', num2str(i));
        xlswrite(file_name, time_ratio_array, original_sheet, 'A1');
        clear time_ratio_array original_sheet norm_time_ratio_array norm_sheet;        
    end
    
    % plot the average curve with all data ploted as circles
    if enable_average_plot && enable_interpolate
        % stop_index = find(time_array_interp == last_time_point);
        num_cell = size(ratio_array, 2);
        mean_ratio_array = mean(ratio_array, 2, 'omitnan');
        std_error = std(ratio_array, 0, 2 , 'omitnan')/sqrt(num_cell);
        h = figure; hold on;
        for i = 1:num_cell 
            plot(original_time_array(:, i), original_ratio_array(:,i), 'o', 'color', [0.5 0.5 0.5]);
        end
            
        % add the error bar
        plot(time_array, mean_ratio_array, 'k', 'LineWidth', line_width);
        add_error_bar(time_array, mean_ratio_array, std_error,...
            'error_bar_interval', error_bar_interval);
        my_figure('handle', h, 'line_width', line_width, 'font_size', font_size);
        ylabel('Intensity Ratio');
        xlabel('Time (min)'); 
        title('Average Plot with Single Cell Data'); axis auto;
        % axis([time_bound, y_limit_before_norm]);
    end % plot the average curve with all original data ploted as circles
    
    clear original_time_array original_ratio_array; 

return;





