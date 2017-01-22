% test_fig4
% Generate results for Figs 3 and S4. 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name.
%% 
close all;
root = 'D:/doc/paper/2016/fluocell_1221/data/';

%%
p = strcat(root, 'fig4/0728/2-test/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t2.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
pause; close all;
group_plot(group, 'method', 3, 'normalize', 1);

%%
p = strcat(root, 'fig4/0728/1-Cyto-Fyn-Cbl-wt/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 1, 'save_file',0);
pause; close all;
group_plot(group,'method',3, 'save_excel_file', 1, 'sheet_name', 'Cyto-Fyn-Interp');

%%
p = strcat(root, 'fig4/0728/2-Lyn-Fyn-Cbl-wt/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t2.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
g2p_quantify(group, 'show_figure', 1, 'lo ad_file', 1, 'save_file',0);
pause; close all;
% Alternatively, we can initialize data as fluocell_data by using the GUI.
% Then, we update the data.
% group = g2p_init_data(fluocell_data);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
% group_plot(group, 'method', 3, 'normalize', 1);
group_plot(group,'method',3, 'save_excel_file', 1, 'sheet_name', 'Lyn-Fyn-Interp');

