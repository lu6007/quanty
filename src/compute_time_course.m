% Compute the time course of FRET ratio for a single cell
% 
% Example:
% See g2p_quantify() for details.

% Copyright: Shaoying Lu and Yingxiao Wang 2013 
% Modified by Lexie Qin Qin, Shannon Laub, and Shaoying Lu 2016
% Email: shaoying.lu@gmail.com

function [time, value, data] = compute_time_course(cell_name, data, varargin)
fprintf('Cell Name : %s\n',cell_name);
parameter_name = {'save_file', 'load_file', 'save_bw_file', 'subplot_position'};
default_value = {1, 1, 0, 0};
[save_file, load_file, save_bw_file, subplot_position] =...
    parse_parameter(parameter_name, default_value, varargin);

%Initializing file and location for result.mat (out_file)
output_path = strcat(data.path, 'output/');
if isfield(data, 'output_path')
    data.output_path = output_path;
end
out_file = strcat(output_path, 'result.mat');

if ~exist(out_file,'file') || load_file ==0

    %%% Interface with fluocell %%%
    %%% Main sub-function %%%
    data = batch_update_figure(data, 'save_bw_file', save_bw_file);
    %%% 
    image_index = (1: max(data.image_index))';
    fret_ratio = data.ratio;
    cfp_intensity = data.channel1;
    yfp_intensity = data.channel2;
    cfp_background = data.channel1_bg;
    yfp_background = data.channel2_bg;
%     if compute_cell_size
%         cell_size = data.cell_size;
%     end;
    
    % Correct the time value when imaging pasts midnight
    time = data.time(:,2);
    for i = data.image_index
        if i >= 2 && time(i) >= 0 && time(i) < time(i - 1)
            time(i) = time(i) + 24 * 60;
        end;
    end;     
    % time in minutes PDGF was added 30 seconds before frame (after_pdgf)
    if isfield(data,'pdgf_time')
        pdgf_time = data.pdgf_time;
    elseif isfield(data, 'pdgf_between_frame')
        after_pdgf = data.pdgf_between_frame(2);
        %%% Note that pdgf time is only correct for position 1, but not
        %%% accurate for all the rest of positions. 03/04/2014
        pdgf_time = time(after_pdgf)+0.5;
    else % no pdgf was added
        pdgf_time = time(1)-0.5; % consistent with g2p_init_data
    end;
    time = time - pdgf_time; 

    ii = ~isnan(time);
    this_image_index = image_index(ii); 

    if save_file
            save(out_file, 'image_index', 'this_image_index', ...
                'time', 'cfp_intensity', 'yfp_intensity', 'fret_ratio', ... 
                'cfp_background', 'yfp_background');
    end;
else % if exist(out_file, 'file') && load_file
    res = load(out_file);
    time = res.time;
    % Lexie on 2/18/2015
    cfp_intensity = res.cfp_intensity;
    yfp_intensity = res.yfp_intensity;
    fret_ratio = res.fret_ratio;
    cfp_background = res.cfp_background;
    yfp_background = res.yfp_background;
    image_index = res.image_index;
    this_image_index = res.this_image_index;
end;

clear path output_path;

%% Plotting the quantifications.
%%% Configuring the subplots. %%%
if subplot_position
    enable_subplot = 1;
    num_figures = 4;
    subm = 2; % number of rows
    subn = 3; % number of columns
    fn = 2+floor((subplot_position-1)/(subm*subn))*num_figures;
    subplot_position = mod(subplot_position-1, subm*subn)+1;
else
    enable_subplot = 0;
end;

%%% cfp and yfp Intensities over Index figure. %%%
if ~enable_subplot
    my_figure; 
else
    figure(fn+1); subplot(subm,subn,subplot_position); my_figure('handle', fn+1); 
end;
hold on;

%Problem: cfp_intensity always seems to be AT LEAST two cells long,
%irrespective of the actual number of objects in an image.
%Current workaround: set num_object based on the fret_ratio, which seems to
%reliably reflect the actual number of objects in an image. -Shannon 8/10/2016
% num_object = length(cfp_intensity);
num_object = length(fret_ratio);
for i = 1:num_object
    plot(this_image_index, cfp_intensity{i}(this_image_index,1), 'b','LineWidth',2); 
    plot(this_image_index, yfp_intensity{i}(this_image_index,1), 'g','LineWidth',2);
end
plot(this_image_index, cfp_background(this_image_index), 'b--','LineWidth',2);
plot(this_image_index, yfp_background(this_image_index), 'g--', 'LineWidth',2);  
    
%Set title and legend for figure.
title(regexprep(cell_name,'_','\\_'));
xlabel('Index'); ylabel('Intensity');
legend('1^{st} FI','2^{nd} FI','1^{st} FI BG', '2^{nd} FI BG');

%%% Index over time figure. %%%
if ~enable_subplot
    my_figure; 
else
    figure(fn+2); subplot(subm,subn,subplot_position); my_figure('handle', fn+2); 
end;
hold on;
% Needed for removed files
plot(image_index, time(image_index), 'LineWidth',2);
title(regexprep(cell_name,'_','\\_'));
xlabel('Index'); ylabel('Time (min)');

%%% Intensity Ratio over Index figure. %%%
if ~enable_subplot
    my_figure; 
else
    figure(fn+3); subplot(subm,subn,subplot_position); my_figure('handle', fn+3); 
end;
hold on;

%Created for loop to manage plotting multiple objects. - Shannon 8/9/2016
%Converts from fret_ratio's cell data type to a double data type and also
%shrinks the matrix to match this_image_index's size so it will plot correctly.
%Preallocation of matrix space for this_fret_ratio.
num_image_index = length(this_image_index);
num_object = length(fret_ratio);
this_fret_ratio = nan(num_image_index,num_object);
%Assigns the corresponding fret_ratio value to the matrix.
for i = 1:num_object
    this_fret_ratio(:,i) = fret_ratio{i}(this_image_index,1);
%     plot(this_image_index, fret_ratio{i}(this_image_index,1), 'r', 'LineWidth',2);
end

plot(this_image_index, this_fret_ratio, 'r','LineWidth',2);
title(regexprep(cell_name,'_','\\_'));
xlabel('Index'); ylabel('Intensity Ratio');

%%% Intensity Ratio over Time (min) figure. %%%
if ~enable_subplot
    my_figure; 
else
    figure(fn+4); subplot(subm,subn,subplot_position); 
    my_figure('handle', fn+4); 
    % my_figure('handle', fn+4, 'font_size', 18, 'line_width', 2.5);
end;
hold on;
plot(time(this_image_index), this_fret_ratio, 'r','LineWidth',2);
title(regexprep(cell_name,'_','\\_'));
xlabel('Time (min)'); ylabel('Intensity Ratio');
clear this_fret_ratio;

%% output
temp = time(this_image_index); clear time;
time = temp; clear temp;
value = fret_ratio{1}(this_image_index, 1); 
beep;
return;