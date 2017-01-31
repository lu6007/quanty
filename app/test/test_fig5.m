% test_fig5.m
%%
close all;
root = 'D:/doc/paper/2016/fluocell_1221/data/';
enable_pause = 0;
enable_time = 1;

if enable_time, tic; end

%%
p = strcat(root, 'fig3/0722_cyto-fyn_cblwt_pdgf/');
data_file = strcat(p, 'output/data.mat');
load(data_file);
group = g2p_init_data(data, 'load_file', 1);
group_make_movie(group, 'position', 'p3', 'stimulus_info', 'PDGF');

%%
if enable_pause, pause; end
close all;
test_3dview;
