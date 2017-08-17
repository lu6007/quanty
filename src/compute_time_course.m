% Compute the time course of FRET ratio for a single cell
% function [this_image_index, time, intensity, ratio, value] = ...
% compute_time_course(cell_name, data, varargin)
% parameter_name = {'save_file', 'load_file', 'save_bw_file'};
% default_value = {1, 1, 0};
%
% Output: Intensity{num_object+1,2} containing the average FI from 2 
% channels followed by the background FI at the (num_object+1)the row. 
% 
% Example:
% See g2p_quantify() for details.

% Copyright: Shaoying Lu, Lexie Qin Qin, Shannon Laub, and Yingxiao Wang 2013-2017 
% Email: shaoying.lu@gmail.com
function [this_image_index, time, intensity, ratio, value] = ...
    compute_time_course(cell_name, data, varargin)
parameter_name = {'save_file', 'load_file', 'save_bw_file'};
default_value = {1, 1, 0};
[save_file, load_file, save_bw_file] =...
    parse_parameter(parameter_name, default_value, varargin);
fprintf('Postion: %s\n',cell_name);

%Initializing file and location for result.mat (out_file)
output_path = strcat(data.path, 'output/');
if isfield(data, 'output_path')
    data.output_path = output_path;
end
out_file = strcat(output_path, 'result.mat');

if ~exist(out_file,'file') || load_file ==0

    %%% Interface with fluocell %%%
    %%% Main sub-function %%%
    if isfield(data, 'show_figure')
        show_figure = data.show_figure;
    else
        show_figure = 0;
    end
    if isfield(data, 'save_processed_image')
        save_processed_image = data.save_processed_image;
    else
        save_processed_image = 0;
    end
    data.show_figure = 0;
    data.save_processed_image = 0;
    data = batch_update_figure(data, 'save_bw_file', save_bw_file);
    % run another time to show tracks
    data.show_figure = show_figure;
    data.save_processed_image = save_processed_image;
    data = batch_update_figure(data, 'save_bw_file', 0);
    %%% 
    image_index = (1: max(data.image_index))';
    num_object = length(data.ratio);
    ratio = cell(num_object, 1);
    intensity = cell(num_object, 2);
    value.size = cell(num_object, 1);

    for i = 1:num_object
        ratio{i} = data.ratio{i}(image_index, :);
        intensity{i,1} = data.channel1{i}(image_index, :);
        intensity{i,2} = data.channel2{i}(image_index, :);
        value.size{i} = data.cell_size{i}(image_index, :);
    end
    intensity{num_object+1, 1} = data.channel1_bg(image_index, :);
    intensity{num_object+1, 2} = data.channel2_bg(image_index, :);
        
    % Correct the time value when imaging pasts midnight
    time = data.time(image_index,2);
    for i = (data.image_index)'
        if i >= 2 && time(i) >= 0 && time(i) < time(i - 1)
            time(i) = time(i) + 24 * 60;
        end
    end 
    
    % time in minutes PDGF was added 30 seconds before frame (after_pdgf)
    if isfield(data,'pdgf_time')
        zero_time = data.pdgf_time;
    elseif isfield(data, 'pdgf_between_frame')
        after_pdgf = data.pdgf_between_frame(2);
        % Note that pdgf time is only calculated for position 1, and 
        % used for all the rest of positions. 08/14/17
        zero_time = time(after_pdgf)-0.5; %min
    else % no pdgf was added
        % correct the bug when the first frame was removed. 
        if ~isnan(time(1))
            disp('compute_time_course warning: pdgf_time not defined.')
            disp('Set zero_time = time(1)-0.5');
            zero_time = time(1)-0.5; % consistent with g2p_init_data
        else
            disp('compute_time_course warning: Time(1) is NAN.');
            disp('Set zero_time = 0');
            zero_time = 0; 
        end
    end
    time = time - zero_time; 

    ii = ~isnan(time);
    this_image_index = image_index(ii); 
else % if exist(out_file, 'file') && load_file
    res = load(out_file);
    this_image_index = res.this_image_index;
    time = res.time;
    intensity =res.intensity;
    ratio = res.ratio;
    value.size = res.value.size;
end
clear path output_path;


if save_file
    save(out_file, 'this_image_index', 'time', 'intensity', 'ratio', 'value');
end
    
% beep;
return;