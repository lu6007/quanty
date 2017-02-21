% test_fig3
% Generate results for Figs 3, S4 and S5. 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name. 

close all;
root = 'D:/doc/paper/2016/fluocell_1221/quanty_dataset_2/';
if ~exist('enable_pause', 'var')
    enable_pause = 1;
end;
enable_time = 1;

if enable_time, tic; end

%%
p = strcat(root, 'fig3/test/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file', 1);
pause_str = 'test_fig3: paused. Press any key to close current figures and continue.';
if enable_pause
    disp(pause_str);
    pause; 
end
close all;
group_image_view(group, 'time_point', [1; 25; 50]);
if enable_pause
    disp(pause_str);
    pause; 
end
close all;

%%
p = strcat(root, 'fig3/0722_cyto-fyn_cblwt_pdgf/');
data_file = strcat(p, 'output/data.mat');
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 0, 'load_file', 1, 'save_file',0);
if enable_pause
    disp(pause_str);
    pause; 
end
close all;
group_image_view(group, 'time_point', [1; 25; 50]);
if enable_pause
    disp(pause_str);
    pause; 
end
close all;

% Supplementary Figure 5
group_plot(group,'method',1, 'enable_interpolation', 1, 'save_excel_file', 1, 'sheet_name', 'Cyto-Fyn');
axis([-15 65 0.8 3.0]);
group_plot(group,'method',1, 'enable_interpolation', 1, 'enable_average_plot', 1);
axis([-15 65 0.1 0.8]);
if enable_pause
    disp(pause_str);
    pause; 
end
close all;

%%
p = strcat(root, 'fig3/6position/');
data_file = strcat(p, 'output/data.mat');
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 1, 'save_file',0);
g2p_quantify(group, 'show_figure', 0, 'load_file', 1, 'save_file', 0);

if enable_time, toc; end
