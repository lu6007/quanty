% test_fig3
% Generate results for Figs 3 and S4. 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name. 

close all;
root = 'D:/doc/paper/2016/fluocell_1221/data/';
enable_pause = 0;
enable_time = 1;

if enable_time, tic; end

p = strcat(root, 'fig3/test/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 0);
if enable_pause, pause; end
close all;
group_image_view(group, 'time_point', [1; 25; 50]);
if enable_pause, pause; end
close all;

p = strcat(root, 'fig3/0722_cyto-fyn_cblwt_pdgf/');
data_file = strcat(p, 'output/data.mat');
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
group_image_view(group, 'time_point', [1; 25; 50]);
if enable_pause, pause; end
close all;

p = strcat(root, 'fig3/6position/');
data_file = strcat(p, 'output/data.mat');
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 1, 'save_file',0);

if enable_time, toc; end
