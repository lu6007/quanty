% test_fig4
% Generate results for Figs 3 and S4. 
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
p = strcat(root, 'fig4/0728/2-test/'); % Lyn-Fyn group
data = load_data(p);
data_file = strcat(p, 'output/data.mat'); 
data.path = strcat(p, 'p1/');
data.show_detected_boundary = 1;
data.ratio_bound = [0.1 0.5]; 
data.intensity_bound = [];
data.brightness_factor = 0.8;
data.parallel_processing = 0;
% data.index_pattern{1} = 't1';
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
my.pause(enable_pause, pause_str);
close all;
group_plot(group, 'method', 1, 'normalize', 1);

%% Figures S5, Fig. 3A left panel
p = strcat(root, 'fig4/0728/1-Cyto-Fyn-Cbl-wt/');
data = load_data(p);
data_file = strcat(p, 'output/data.mat'); 
data.path = strcat(p, 'p1/');
data.show_detected_boundary = 1;
data.ratio_bound = [0.1 0.5]; 
data.intensity_bound = [];
data.brightness_factor = 0.7;  
data.parallel_processing = 0; 
data.quantify_roi = 3;
data.num_roi = 3; 
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 0, 'load_file', 1, 'save_file', 0);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 1, 'save_file',0);
my.pause(enable_pause, pause_str);
close all;
group_plot(group,'method',1, 'enable_interpolate', 1, 'enable_normalize', 1, ...
    'save_excel_file', 1, 'sheet_name', 'Cytosol'); % Cyto-Fyn
axis([-10 65 0.5 3.0]);
group_plot(group,'method',1, 'enable_average_plot', 1);
axis([-10 65 0.1 0.6]);
group_image_view(group, 'time_point', [-1; 25]);

%% Fig. S5, Figs 3A (right panel), 3B and 3C
p = strcat(root, 'fig4/0728/2-Lyn-Fyn-Cbl-wt/');
data = load_data(p);
data_file = strcat(p, 'output/data.mat'); 
data.path = strcat(p, 'p1/');
data.show_detected_boundary = 1;
data.ratio_bound = [0.1 0.5]; 
data.intensity_bound = [];
data.brightness_factor = 0.8; 
data.index_pattern{1} = 't1';
data.parallel_processing = 0; 
data.quantify_roi = 3;
data.num_roi = 3; 
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 0, 'load_file', 1, 'save_file', 0);
% g2p_quantify(group, 'show_figure', 1, 'load_file', 1, 'save_file',0);
% g2p_quantify(group, 'show_figure', 0, 'load_file', 0, 'save_file', 1
% 'position', 'p1');
my.pause(enable_pause, pause_str);
close all;
% If the data file does not exist, we can use the GUI to initialize
% fluocell_data. Then copy to data and save as the data.mat file. 
group_plot(group,'method',1, 'enable_interpolate', 1, 'enable_normalize', 1, ...
    'save_excel_file', 1, 'sheet_name', 'Membrane'); % Lyn-Fyn
axis([-10 65 0.5 3.0]);
group_plot(group,'method',1, 'enable_average_plot', 1, 'enable_normalize', 0);
axis([-10 65 0.1 0.6]);
group_image_view(group, 'time_point', [-1; 25]);
my.pause(enable_pause, pause_str);
close all;
% The excel file 'result-norm.xls' contains the normlized time courses of 
% the Cytosol and Membrane groups. Need to rename the sheet names from
% 'Cyto-Fyn' to 'Cytosol', and 'Lyn-Fyn' to 'Membrane' before this works. 
group_compare(group, 'input_file', strcat(p, '../result-norm.xlsx'), 'enable_violin_plot', 1, ...
'group_name', {'Cytosol-Interp', 'Membrane-Interp'}, 'time_range', [10 20], 'load_file', 1);
p = strcat(group.data.path, '../../pic/');
h = figure(1); axis([-5 65 0.5 2.5]);
print(h, strcat(p, 'cyto_mem_plot.tiff'), '-dtiff', '-r300');
h = figure(2); print(h, strcat(p, 'average_ratio_compare.tiff'), '-dtiff', '-r300');
h = figure(3); print(h, strcat(p, 'peak_time.tiff'), '-dtiff', '-r300');
h = figure(4); print(h, strcat(p, 'peak_ratio.tiff'), '-dtiff', '-r300');
if enable_time, toc; end
