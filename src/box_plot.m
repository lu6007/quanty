% Draw box plot in groups
% function box_plot(data, name, varargin)
% parameter_name = {'title_string'};
% default_value = {''};

% Copyright: Qin Qin, Shaoying Lu and Yingxiao Wang 2015
function box_plot(data, name, varargin)
parameter_name = {'title_string'};
default_value = {''};
[title_string] = parse_parameter(parameter_name, default_value, varargin);

box_plot_str = 'boxplot([';
formatted_matrix = [];
for n = 1 : length(data)
    temp1{n} = repmat({name{n}}, length(data{n}), 1);
    formatted_matrix = [formatted_matrix; temp1{n}];
    box_plot_str = [box_plot_str, 'data{', num2str(n), '}; '];
end
temp2 = size(data{1});
if temp2(2) ~= 1,
    for n = 1 : length(data)
        temp3{n} = data{n}';
    end
    data = temp3;
    clear temp2 temp3
end
box_plot_str = box_plot_str(1 : end - 2);
box_plot_str = [box_plot_str, '], formatted_matrix);'];
% box_plot_str = [box_plot_str, '], formatted_matrix, ''LineWidths'', 1.5);'];
figure;
eval(box_plot_str)
title(title_string);
set(gca,'FontSize', 12, 'FontName','Arial', 'Fontweight', 'bold', 'LineWidth', 1.5);
set(findall(gcf,'type','text'),'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold', 'LineWidth', 1.5);
set(findobj(gca, 'type', 'line'), 'linew', 1.5);
xlabel('Group Name');
return;