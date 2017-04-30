% function group_image_view(group, varargin)
% Display the ratio image of each position at the nearest time point given by user 
% parameter_name = {'time_point', 'num_col'};
% default_value = {[-5; 30], 5};
%
% Example:
% If you want to check the ratio image at 1 min, 10 min, 20 min 
% group_image_view(group, 'time_point', [1; 10; 20])

% Copyright: Qin Qin, Shaoying Lu and Yingxiao Wang
function group_image_view(group, varargin)
parameter_name = {'time_point', 'num_col'};
default_value = {[-5; 30], 5};
[time_point, num_col] = parse_parameter(parameter_name, default_value, varargin);

name = group.name;
data = group.data;

list = dir([data.path, '../']);
n_list = length(list);
% Count the number of folders. 
% Ignore the first two folders, which are '.' and '..'.
% Also ignore the folder 'output/' and files. 
num_folder = n_list-2;
for i = 3:n_list
    if ~list(i).isdir
        num_folder = num_folder-1;
    elseif strcmp(list(i).name, 'output')
        num_folder = num_folder-1;
    end
end

s1_str = regexprep(name,'p','s');
if num_folder < num_col
    num_row = 1;
    num_col = num_folder;
else
    num_row = ceil(num_folder / num_col);
end
ratio_bd_str = ['[', num2str(data.ratio_bound(1)),', '  num2str(data.ratio_bound(2)), ']'];
num_fig = length(findobj('type', 'figure'));
for n = 1 : length(time_point)
    h = figure(num_fig + n);
    set(h, 'color', 'w');
    fig_ha = tight_subplot(num_row, num_col, [.005 .005],[.01 .1], 0);
    ii = 0;
    for i = 3 : n_list
        if ~list(i).isdir
            continue;
        end
        if strcmp(list(i).name, 'output')
            continue;
        end

        ii = ii+1;
        name_i = list(i).name;
        data_i = data;
        data_i.path = set_path_i(data.path, name, name_i);

        si_str = regexprep(name_i, 'p','s');
        [~,file,ext] = fileparts(data.first_file);
        temp = strcat(file, ext);
        first_file_no_path = regexprep(temp, s1_str, si_str);
        clear temp;
        
        data_i.first_file = strcat(data_i.path, first_file_no_path);
        % Dispaly the ratio figure of each position at the time point given by
        % user
        output_path = [data_i.path, 'output/'];
        if isfield(data_i, 'output_path')
            data_i.output_path = output_path;
        end
        out_file = strcat(output_path, 'result.mat');
        data_i.show_figure = 1; 
        % Load the exsiting data 
        res = load(out_file);
%        time = res.time;
%         real_time = time(:) - time(1);
%         tmp = abs(real_time - time_point(n));
%         [~, idx] = min(tmp);
        [~, idx] = min(abs(res.time - time_point(n)));
        data_i.index= idx;
        data_i = get_image(data_i,0);
        if isempty(data_i.im{1}) 
            continue;
        end
        first_channel_im = preprocess(data_i.im{1}, data_i);
        second_channel_im = preprocess(data_i.im{2}, data_i);
        ratio = compute_ratio(first_channel_im, second_channel_im);
        ratio_im = get_imd_image(ratio, max(first_channel_im, second_channel_im), ...
                'ratio_bound', data_i.ratio_bound, 'intensity_bound', data_i.intensity_bound);
%         subplot(nRow, 5, i - 4), imshow(ratio_im);
        axes(fig_ha(ii));
        ratio_fig = insertText(ratio_im, [20, 20], name_i, 'Boxcolor', 'Black',...
            'TextColor', 'white', 'FontSize', 48);
        imshow(ratio_fig);
        clear name_i data_i si_str output_path real_time ratio ratio_im;
        clear first_channel_im second_channel_im;
    end % for i = 3 : n_list
    
    % Draw a title across all subplot, but not just only one subplot.
    title_string = strcat(num2str(time_point(n)), 'min, ratio bound=', ratio_bd_str); 
    set(gcf,'NextPlot','add'); axes;
    tt = title(title_string);
    set(gca,'Visible','off'); set(tt,'Visible','on');
    set(findall(gcf,'type','text'),'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold');
end
return;

