% test_fig4
% Generate results for Figs 3 and S4. 
% Update p with your own path, and make sure to use forward slash
% only and inlude the last slash to close the folder name.
%% 
close all;
root = 'D:/doc/paper/2016/fluocell_1221/quanty_dataset_2/';
enable_pause = 1;
enable_time = 1;

if enable_time, tic; end

%%
p = strcat(root, 'fig4/0728/2-test/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t1.TIF');
% data.index_pattern = {'t1','t%d'}; 
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
pause_str = 'test_fig4: paused. Press any key to close current figures and continue.';
if enable_pause
    disp(pause_str);
    pause; 
end
close all;
group_plot(group, 'method', 1, 'normalize', 1);

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
if enable_pause
    disp(pause_str);
    pause; 
end
close all;
group_plot(group,'method',1, 'save_excel_file', 1, 'sheet_name', 'Cyto-Fyn');
axis([-10 65 0.5 3.0]);

%%
p = strcat(root, 'fig4/0728/2-Lyn-Fyn-Cbl-wt/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
data.first_file = strcat(data.path, '6_w1CFP_s1_t2.TIF');
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 1, 'save_file',0);
if enable_pause
    disp(pause_str);
    pause; 
end
close all;
% If the data file does not exist, we can use the GUI to initialize
% fluocell_data. Then copy to data and save as the data.mat file. 
group_plot(group,'method',1, 'save_excel_file', 1, 'sheet_name', 'Lyn-Fyn');
axis([-10 65 0.5 3.0]);
% group_plot(group,'method',1, 'enable_average_plot', 1);
% axis([-10 65 0.5 3.0]);
if enable_pause
    disp(pause_str);
    pause; 
end
close all;
% The excel file 'result-norm.xls' contains the normlized time courses of 
% the Cytosol and Membrane groups. Need to rename the sheet names from
% 'Cyto-Fyn' to 'Cytosol', and 'Lyn-Fyn' to 'Membrane' before this works. 
group_compare(group, 'excel_file', 'result-norm.xls', 'enable_violin_plot', 1, ...
'group_name', {'Cytosol', 'Membrane'}, 'time_range', [10 20]);
p = strcat(group.data.path, '../../pic/');
h = figure(1); axis([-5 65 0.5 2.5]);
print(h, strcat(p, 'cyto_mem_plot.tiff'), '-dtiff', '-r300');
h = figure(2); print(h, strcat(p, 'average_ratio_compare.tiff'), '-dtiff', '-r300');
h = figure(3); print(h, strcat(p, 'peak_time.tiff'), '-dtiff', '-r300');
h = figure(4); print(h, strcat(p, 'peak_ratio.tiff'), '-dtiff', '-r300');
if enable_time, toc, end;
