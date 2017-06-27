% test_fig6.m
%%
close all;
if ~exist('enable_pause', 'var'), enable_pause = 1; end
my = my_function;
root = my.root;
enable_time = 1;

if enable_time, tic; end

%%
p = strcat(root, 'fig3/0722_cyto-fyn_cblwt_pdgf/');
data_file = strcat(p, 'output/data.mat');
load(data_file);
group = g2p_init_data(data, 'load_file', 1);
group_make_movie(group, 'position', 'p3', 'stimulus_info', 'PDGF');

%%
pause_str = 'Press any key to close current figures and continue.';
my.pause(enable_pause, pause_str);
close all;
data.path = strcat(root, 'fig6/1111_h3k9_3/p2/dconv9/');
data.num_figure = 3;
test_3dview(data);
if enable_time, toc; end
