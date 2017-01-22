% function g2p_quantify( group, varargin )
% Quantify the time course of imaging data at multiple positions
% parameter_name = {'show_figure','name_i', ...
%     'save_file', 'load_file', 'num_layer','compute_cell_size'};
% default_value = {1, '', 1, 0, 1, 0};
%
% Example:
% group.name = 'p1';
% group.data = g2p_init_data(fluocell_data)
% g2p_quantify(group,'show_figure', 0)
%
% To quantify for only 1 position, use
% g2p_quantify(group, 'show_figure', 0, 'name_i', 'p8');

% Copyright: Shaoying Lu, Ya Gong and Yingxiao Wang 2013 
% Email: shaoying.lu@gmail.com

function g2p_quantify( group, varargin )
parameter_name = {'show_figure','name_i', ...
    'save_file', 'load_file', 'num_layer','compute_cell_size'};
default_value = {1, '', 1, 0, 1, 0};
[show_figure, name_i, ...
    save_file, load_file, num_layer, compute_cell_size] = ...
    parse_parameter(parameter_name, default_value, varargin);
name = group.name;
group.data.show_figure = show_figure; 
group.data.num_layer = num_layer;
data = group.data;
% group.data.save_processed_image = 1;
%
sub_i = 1;

% Choose between quantify for 1 location and multiple locations. 
if isempty(name_i)
    % Loop through the subfolders and
    % start automated processing
    list = dir(strcat(data.path,'../'));
    % ignore the 1st and 2nd folders which are './' and '../'
    num_folder = length(list);
else
    % put name_i into the correct location
    list(3).name = name_i;
    list(3).isdir = 1;
    num_folder = 3;
end;

% Lexie on 04/08/2015
% group.data.num_pos = num_folder - 4;

s1_str = regexprep(name,'p','s'); % p1-> s1
for i = 3: num_folder
    % ignore ./ ../ and all the files
    if ~list(i).isdir
        continue;
    end;
   % ingore the output folder
   if strcmp(list(i).name, 'output') 
       continue;
   end;

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

   [~, ~, ~] = compute_time_course(name_i, data_i, 'subplot_position', sub_i, ...
       'save_file', save_file, 'load_file', load_file, 'compute_cell_size', ...
       compute_cell_size);
   %
   sub_i = sub_i+1;
   clear name_i data_i si_str;
end; % for i 

return;

