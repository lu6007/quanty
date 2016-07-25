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
num_folders = length(list);

s1_str = regexprep(name,'p','s');
num_row = ceil((num_folders - 4) / num_col);
ratio_bd_str = ['[', num2str(data.ratio_bound(1)),', '  num2str(data.ratio_bound(2)), ']'];
num_fig = length(findobj('type', 'figure'));
for n = 1 : length(time_point)
    figure(num_fig + n)
    fig_ha = tight_subplot(num_row, num_col, [.005 .005],[.01 .05], 0);
    for i = 3 : num_folders
        if ~list(i).isdir
            continue;
        end
        if strcmp(list(i).name, 'output')
            continue;
        end

        name_i = list(i).name;
        data_i = data;
        data_i.path = regexprep(data.path, ['\\', name, '\\'], ['\\', name_i, '\\']);

        si_str = regexprep(name_i, 'p','s');
        [~,file,ext] = fileparts(data.first_file);
        temp = strcat(file, ext);
        first_file_no_path = regexprep(temp, s1_str, si_str);
        clear temp;
        
        data_i.first_file = strcat(data_i.path, first_file_no_path);
        % Dispaly the ratio figure of each position at the time point given by
        % user
        output_path = [data_i.path, 'output/'];
        if isfield(data_i, 'output_path'),
            data_i.output_path = output_path;
        end
        out_file = strcat(output_path, 'result.mat');
        data_i.show_figure = 1; 
        % Load the exsiting data.m
        res = load(out_file);
        time = res.time;
        real_time = time(:, 2) - time(1, 2);
        tmp = abs(real_time - time_point(n));
        [~, idx] = min(tmp);
        data_i.index= idx;
        data_i = get_image(data_i,0);
        first_channel_im = preprocess(data_i.im{1}, data_i);
        second_channel_im = preprocess(data_i.im{2}, data_i);
        ratio = compute_ratio(first_channel_im, second_channel_im);
        ratio_im = get_imd_image(ratio, max(first_channel_im, second_channel_im), ...
                'ratio_bound', data_i.ratio_bound, 'intensity_bound', data_i.intensity_bound);
%         subplot(nRow, 5, i - 4), imshow(ratio_im);
        axes(fig_ha(i - 4));
        ratio_fig = insertText(ratio_im, [20, 20], name_i, 'Boxcolor', 'Black', 'TextColor', 'white', 'FontSize', 48);
        imshow(ratio_fig);
        clear name_i data_i si_str output_path real_time ratio ratio_im first_channel_im second_channel_im;
    end
        annotation(figure(num_fig + n), 'textbox', [.35 .9 .1 .1], 'String',{[num2str(time_point(n)), ' min colorbar ',...
            ratio_bd_str]}, 'FitBoxToText','off', 'LineStyle','none');
        set(gca,'FontSize', 9, 'FontName','Arial', 'Fontweight', 'bold');
        set(findall(gcf,'type','text'),'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold');
end
return;

