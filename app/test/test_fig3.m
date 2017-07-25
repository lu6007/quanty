% test_fig3
% Generate results for Figs 3, S4 and S5. 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name. 

close all;
if ~exist('enable_pause', 'var')
    enable_pause = 1;
end
my = my_function();
root = my.root;

enable_time = 1;
if enable_time, tic; end
load_file = 1; save_file = 0;

%%
p = strcat(root, 'fig3/test/');
data = load_data(p);
data_file = strcat(p, 'output/data.mat'); 
data.path = strcat(p, 'p1/');
data.brightness_factor = 0.7;
data.num_roi = 3;
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file', 1);
pause_str = 'Press any key to close current figures and continue.';
my.pause(enable_pause, pause_str);
close all;
group_image_view(group, 'time_point', [1; 25; 50]);
group_plot(group,'method',1);
my.pause(enable_pause, pause_str);


%%
close all;
p = strcat(root, 'fig3/0722_cyto-fyn_cblwt_pdgf/');
data_file = strcat(p, 'output/data.mat');
data = load_data(p);
data.path = strcat(p, 'p1/');
data.brightness_factor = 0.7;
data.num_roi = 3;
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 0, 'load_file', load_file, 'save_file', save_file);
my.pause(enable_pause, pause_str);
close all;

group_image_view(group, 'time_point', [1; 25; 50]);
my.pause(enable_pause, pause_str);
close all;

% Supplementary Figure 5
group_plot(group,'method',1, 'save_excel_file', 1, 'sheet_name', 'Cyto-Fyn');
axis([-15 65 0.8 3.0]);
group_plot(group,'method',1, 'enable_interpolation', 1, 'enable_average_plot', 1);
axis([-15 65 0.1 0.8]);
my.pause(enable_pause, pause_str);
close all;

%%
p = strcat(root, 'fig3/6position/');
data = load_data(p);
data_file = strcat(p, 'output/data.mat');
data.path = strcat(p, 'p1/');
data.brightness_factor = 0.7;
data.num_roi = 3;
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 0, 'load_file', load_file, 'save_file', save_file);

if enable_time, toc; end
