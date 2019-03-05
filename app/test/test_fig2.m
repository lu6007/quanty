% test_fig2
% Generate results for Fig 2 . 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name.
%% 
close all;
if ~exist('enable_pause', 'var')
    enable_pause = 1;
end
fprintf('test_fig2: enable_pause = %d\n', enable_pause);
pause_str = 'Press any key to close current figures and continue.';
my = my_function();
root = my.root;

enable_time = 1;
if enable_time, tic; end

%% Figs. 2A and 2B
p = strcat(root, 'fig2/0722_2015_lyn-fyn_kras_cbl/p3/');
% Manual background subtraction
data = load_data(p);
bg_file = strcat(p, 'output/background.mat');
bg_file_manual = strcat(p, 'output/background_manual.mat');
copyfile(bg_file_manual, bg_file);
data = batch_update_figure(data); 
time_manual = data.time(1:25, 2);
time = time_manual - time_manual(1); 
ratio_manual = data.ratio{1}(1:25, 1);
%
iii = (time<=10);
ecfp = data.channel1{1};
fret = data.channel2{1};
fs = 24; lw =3;
my_figure('font_size', fs, 'line_width', lw); hold on;
plot(time(iii), [ecfp(jjj)/ecfp(1), fret(jjj)/fret(1), ratio_manual(jjj)/ratio_manual(1)], ...
    'LineWidth', lw);
axis([0 10 0.9 1.1]); 
xlabel('Time (min)');
ylabel('Normalized Values'); 
legend('ECFP', 'FRET', 'ECFP/FRET Ratio');
%
my.pause(enable_pause, pause_str);

% Automatic background subtraction
data.subtract_background = 2; % Automaticly subtract background
bg_file_auto = strcat(p, 'output/background_auto.mat');
copyfile(bg_file_auto, bg_file);
data = batch_update_figure(data);
ratio_auto = data.ratio{1}(1:25, 1);
%
fs = 16; lw = 2;
my_figure('font_size', fs, 'line_width', lw); hold on; 
plot(time, ratio_auto, 'k', 'LineWidth', lw); 
plot(time, ratio_manual, 'bo', 'LineWidth', lw);
legend('Auto-BG', 'Manual-BG');
xlabel('Time (min)'); ylabel('Intensity Ratio');

%
my.pause(enable_pause, pause_str);
close all;

%%  Figs. 2E and 2F
% previously 
% data.num_roi = 1;
% data.quantify_roi = 1; 
data.num_roi = 3;
data.quantify_roi = 2;
data = rmfield(data, 'roi_bw');
data = batch_update_figure(data);
ratio_manual = data.ratio{1}(data.image_index, :);
my.pause(enable_pause, pause_str);

data.quantify_roi = 3;
data.num_roi = 3;
data = batch_update_figure(data);
ratio_auto = data.ratio{1}(data.image_index, :);
my_figure('font_size', fs, 'line_width', lw); hold on; 
plot(time, ratio_manual, 'LineWidth', lw);
plot(time, ratio_auto(:,1), 'bo', 'LineWidth', lw);
my.pause(enable_pause, pause_str);
% close all;

%% Fig. 2H
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
track_option.max_linking_distance = 70; % default
group.data.track_option = track_option;
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
group_plot(group, 'method', 1, 'normalize', 1, 'save_excel_file', 1, 'sheet_name', 'FHA2BS');
my.pause(enable_pause, pause_str);
close all;

% data = group.data;
% data = batch_update_figure(data);
% coordInfo = multiple_object.getCoord(data);
% [data, cell_location] = multiple_object.simpleTrack(data,coordInfo,'output_cell_location',1);
% frame_with_track = multiple_object.create_frame_track(cell_location);
% overlay_image_track(data, frame_with_track);

if enable_time, toc; end
