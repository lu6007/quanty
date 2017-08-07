% test_fig5
% Generate results for Figs 5 . 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name.
%% 
close all;
if ~exist('enable_pause', 'var')
    enable_pause = 1;
end
pause_str = 'Press any key to close current figures and continue.';
my = my_function();
root = my.root;

enable_time = 1;
if enable_time, tic; end

%%
p = strcat(root, 'fig2/0901_qin_tcp_fha2bs_hela/');
data_file = strcat(p, 'output/data.mat'); 
data = load_data(p);
data.path = strcat(p, 'p6/');
% [~,prefix, postfix]=fileparts(data.first_file);
% data.first_file = strcat(data.path, regexprep(prefix, 's1', 's6'), postfix);
data.multiple_object = 1;
data.brightness_factor = 0.7;
data.show_detected_boundary = 1;
data.save_processed_image = 1;
% data.parallel_processing = 0;
% data.index_pattern{1} = 't1';
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
%
group.name = 'p6';
% 
track_option.remove_short_track = 1;
% defautl length is automatically calculated. 
track_option.min_track_length = []; 
track_option.plot_cell_split = 1;
track_option.max_distance = 0.40; % default
track_option.output_cell_location = 0; % default
group.data.track_option = track_option;
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
group_plot(group, 'method', 1, 'normalize', 1, 'save_excel_file', 1, 'sheet_name', 'FHA2BS');
my.pause(enable_pause, pause_str);
close all;

data = group.data;
data = batch_update_figure(data);
coordInfo = multiple_object.getCoord(data);
[data, cell_location] = multiple_object.simpleTrack(data,coordInfo,'output_cell_location',1);
frame_with_track = multiple_object.create_frame_track(cell_location);
overlay_image_track(data, frame_with_track);

if enable_time, toc; end
