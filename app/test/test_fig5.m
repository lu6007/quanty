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
p = strcat(root, 'fig5/0901_qin_tcp_fha2bs_hela/');
data_file = strcat(p, 'output/data.mat'); 
load(data_file);
data.path = strcat(p, 'p1/');
% [~,prefix, postfix]=fileparts(data.first_file);
% data.first_file = strcat(data.path, prefix, postfix);
data.multiple_object = 1;
data.show_detected_boundary = 0;
% data.parallel_processing = 0;
% data.index_pattern{1} = 't1';
save(data_file, 'data');
group = g2p_init_data(data, 'load_file', 1);
g2p_quantify(group, 'show_figure', 1, 'load_file', 0, 'save_file',1);
my.pause(enable_pause, pause_str);
close all;
% group_plot(group, 'method', 1, 'normalize', 1);

if enable_time, toc; end
