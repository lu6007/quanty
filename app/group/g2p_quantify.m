% function g2p_quantify( group, varargin )
% Quantify the time course of imaging data at multiple positions
% parameter_name = {'show_figure','position', ...
%     'save_file', 'load_file', 'save_bw_file', 'num_roi'};
% default_value = {1, '', 1, 0, 0, 1, 0};
%
% Example:
% group.name = 'p1';
% group.data = g2p_init_data(fluocell_data)
% g2p_quantify(group,'show_figure', 0)
%
% To quantify for only 1 position, use
% g2p_quantify(group, 'show_figure', 0, 'position', 'p8');

% Copyright: Shaoying Lu, Ya Gong and Yingxiao Wang 2013 
% Email: shaoying.lu@gmail.com

function g2p_quantify( group, varargin )
parameter_name = {'show_figure','position', ...
    'save_file', 'load_file', 'save_bw_file', 'num_roi'};
default_value = {1, '', 1, 0, 0, 1};
[show_figure, position, ...
    save_file, load_file, save_bw_file, num_roi] = ...
    parse_parameter(parameter_name, default_value, varargin);
name = group.name;
group.data.show_figure = show_figure; 
if ~isfield(group.data, 'num_roi') || group.data.num_roi == 0
    group.data.num_roi = num_roi;
end
data = group.data;
% group.data.save_processed_image = 1;

% Choose between quantify for 1 location and multiple locations. 
name_i = position;
if isempty(name_i)
    list = dir(strcat(data.path,'../'));
    num_folder = length(list);
    enable_subplot = 1;
else
    % put name_i into the list
    list(3).name = name_i;
    list(3).isdir = exist(strcat(data.path(1:end-3), name_i), 'dir');
    if ~list(3).isdir
        disp(['g2p_quantfy: the position -', name_i, '- does not exist.']);
    end
    num_folder = 3;
    enable_subplot = 0;
end

% Loop through the subfolders and
% start automated processing
s1_str = regexprep(name,'p','s'); % p1-> s1
pos_i = 0;
for i = 3: num_folder
    % ignore the 1st and 2nd folders which are ./ ../, and all the files
    if ~list(i).isdir
        continue;
    end
   % ingore the output folder
   if strcmp(list(i).name, 'output') 
       continue;
   end

   % if it is a folder, perform quantification
   name_i =list(i).name;
   data_i = data;
   data_i.path = set_path_i(data.path, name, name_i);

% Create the output folder if needed
    output_path = strcat(data_i.path, 'output/');
    if ~exist(output_path, 'dir')
        mkdir(output_path);
    end
   si_str = regexprep(name_i, 'p','s'); %p*->s*
   [~,file,ext] = fileparts(data.first_file);
   data_i.prefix = regexprep(file, s1_str, si_str);
   first_file_no_path = strcat(data_i.prefix, ext);
   data_i.first_file = strcat(data_i.path, first_file_no_path);

   %%% Main sub-function
   [this_image_index, time, intensity, ratio] = ...
       compute_time_course(name_i, data_i, ...
       'save_file', save_file, 'load_file', load_file, 'save_bw_file', save_bw_file);   

   % Plotting the quantifications.
   %%% Configuring the subplots. %%%
   if enable_subplot 
       num_figure = 4;
        subm = 2; % number of rows
        subn = 3; % number of columns
        fn = 2+floor(pos_i/(subm*subn))*num_figure;
        subplot_position = mod(pos_i, subm*subn)+1;
        pos_i = pos_i +1; 
   end

    %%% cfp and yfp Intensities over Index figure. %%%
    if ~enable_subplot
        my_figure; 
    else
        figure(fn+1); 
        subplot(subm,subn,subplot_position); 
        my_figure('handle', fn+1); 
    end
    hold on;

    %Problem: cfp_intensity always seems to be AT LEAST two cells long,
    %irrespective of the actual number of objects in an image.
    %Current workaround: set num_object based on the fret_ratio, which seems to
    %reliably reflect the actual number of objects in an image. -Shannon 8/10/2016
    % num_object = length(cfp_intensity);
%     this_image_index = frame.this_image_index;
%     time = frame.time;
    fret_ratio = ratio;
    num_object = length(fret_ratio);
%     cfp_intensity = value.intensity{1:num_object,1};
%     yfp_intensity = value.intensity{1:num_object, 2};
    for j = 1:num_object
        plot(this_image_index, intensity{j,1}(this_image_index,1), 'b','LineWidth',2); 
        plot(this_image_index, intensity{j, 2}(this_image_index,1), 'g','LineWidth',2);
    end
    j = num_object+1;
    plot(this_image_index, intensity{j,1}(this_image_index), 'b--','LineWidth',2);
    plot(this_image_index, intensity{j,1}(this_image_index), 'g--', 'LineWidth',2);  

    %Set title and legend for figure.
    title(regexprep(name_i,'_','\\_'));
    xlabel('Index'); ylabel('Intensity');
    legend('1^{st} FI','2^{nd} FI','1^{st} FI BG', '2^{nd} FI BG');

    %%% Index over time figure. %%%
    if ~enable_subplot
        my_figure; 
    else
        figure(fn+2); 
        subplot(subm,subn,subplot_position); 
        my_figure('handle', fn+2);
    end
    hold on;
    plot(time, 'LineWidth',2);
    title(regexprep(name_i,'_','\\_'));
    xlabel('Index'); ylabel('Time (min)');

    %%% Intensity Ratio over Index figure. %%%
    if ~enable_subplot
        my_figure; 
    else
        figure(fn+3);
        subplot(subm,subn,subplot_position); 
        my_figure('handle', fn+3); 
    end
    hold on;

    %Loop for plotting multiple objects. - Shannon 8/9/2016
    %Converts from fret_ratio's cell data type to a double data type and also
    %shrinks the matrix to match this_image_index's size so it will plot correctly.
    %Preallocation of matrix space for this_fret_ratio.
    num_image_index = length(this_image_index);
    num_object = length(fret_ratio);
    this_fret_ratio = nan(num_image_index,num_object);
    %Assigns the corresponding fret_ratio value to the matrix.
    for j = 1:num_object
        this_fret_ratio(:,j) = fret_ratio{j}(this_image_index,1);
    %     plot(this_image_index, fret_ratio{i}(this_image_index,1), 'r', 'LineWidth',2);
    end

    plot(this_image_index, this_fret_ratio, 'r','LineWidth',2);
    title(regexprep(name_i,'_','\\_'));
    xlabel('Index'); ylabel('Intensity Ratio');

    %%% Intensity Ratio over Time (min) figure. %%%
    if ~enable_subplot
        my_figure; 
    else
        figure(fn+4);
        subplot(subm,subn,subplot_position); 
        my_figure('handle', fn+4); 
    end
    hold on;
    plot(time(this_image_index), this_fret_ratio, 'r','LineWidth',2);
    title(regexprep(name_i,'_','\\_'));
    xlabel('Time (min)'); ylabel('Intensity Ratio');
    % my_figure('handle', fn+4, 'font_size', 24, 'line_width', 3);
    clear this_fret_ratio;


       clear name_i data_i si_str time value;
end % for i 

return;

