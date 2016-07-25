% violin plot for statistics purpose
% function violin_plot(data, name, varargin)
% parameter_name = {'div_factor', 'interval', 'fill_color'};
% default_value = {2, 20, [0.8 0.8 0.8]};

% Copyright: Qin Qin, Shaoying Lu and Yingxiao Wang
function violin_plot(data, name, varargin)
parameter_name = {'div_factor', 'interval', 'fill_color', 'title_string', 'line_width', 'font_size'};
default_value = {1, 16, [0.8 0.8 0.8], '', 2, 12};
[div_factor, interval, fill_color, title_string, line_width, font_size] = parse_parameter(parameter_name, default_value, varargin);
set_str_1 = ['set(gca, ''XTick'', [0'];
set_str_2 = ['set(gca, ''XTickLabel'',{''', name{1}, ''','''];
figure;hold on
for n= 1 : length(data)
    % plot the violin plot
%     [x{n},y{n},u{n}] = ksdensity(data{n},'kernel','normal');
    [x{n},y{n},u{n}] = ksdensity(data{n}, 'kernel','normal');
    temp = max(x{1}) - min(x{1});
    if  temp < 1 && temp >= 0.5
        interval_var(n) =  4;
    elseif temp < 0.5 && temp > 0.2
        interval_var(n) = 3;
    elseif temp < 0.2 && temp >= 0.1
        interval_var(n) = 2;
    elseif temp < 0.1
        interval_var(n) = 1;
    else
        interval_var(n) = interval;
    end
end
interval = min(interval_var);
if interval <= 2
    div_factor = 1;
end
for n= 1 : length(data)
    x{n} = x{n} / div_factor;
    % Add two nodes to close the density plot
    xx{n} = [0 x{n} 0]; 
    yy{n} = [y{n}(1) y{n} y{n}(end)];
    fill(xx{n} + 0.5 *interval * (n - 1), yy{n}, fill_color, 'linewidth', line_width);
    fill(-xx{n} + 0.5 *interval * (n - 1), yy{n},  fill_color, 'linewidth', line_width);
    length_mean(n) = length(data{n});
    sort_mean{n} = sort(data{n});
    mean_value(n)  = mean(sort_mean{n});
    median_value(n)  = median(sort_mean{n});
    max_value(n)  = max(sort_mean{n});
    min_value(n) = min(sort_mean{n});
    percentile_75(n)  = sort_mean{n}(ceil(length_mean(n)  * 0.75));
    percentile_25(n)  = sort_mean{n}(ceil(length_mean(n)  * 0.25));

    plot([0.5 * interval * (n - 1), 0.5 * interval * (n - 1)], [min(data{n}), percentile_25(n)],'color',  fill_color, 'linewidth', line_width);
    plot([0.5 * interval * (n - 1), 0.5 * interval * (n - 1)], [percentile_25(n), percentile_75(n)],'color',  'w', 'linewidth', line_width);
    plot([0.5 * interval * (n - 1), 0.5 * interval * (n - 1)], [percentile_75(n), max(data{n})],'color',  fill_color, 'linewidth', line_width);
    % plot boxplot on the top of violin plot
    box_width = interval / 40;
    if interval <= 2
        box_width = interval / 50;
    end
    half_box_width = box_width / 2;

    box_ld{n} = [-half_box_width + 0.5 * interval * (n - 1), percentile_25(n)];
    box_rd{n} = [half_box_width + 0.5 * interval * (n - 1), percentile_25(n)];
    box_ru{n} = [half_box_width + 0.5 * interval * (n - 1), percentile_75(n)];
    box_lu{n} = [-half_box_width + 0.5 * interval * (n - 1), percentile_75(n)];
    % main box
    verts{n} = [box_ld{n}; box_rd{n}; box_ru{n}; box_lu{n}];
    faces{n} = [1, 2, 3, 4];
    p{n} = patch('Faces',faces{n},'Vertices',verts{n},'FaceColor','w');
    set(p{n}, 'linewidth', line_width);
    % min and max bar
    plot([-half_box_width * 2 / 3 + 0.5 * interval * (n - 1), half_box_width * 2 / 3 + 0.5 * interval * (n - 1)], [min_value(n), min_value(n)], 'k', 'linewidth', line_width);
    plot([-half_box_width * 2 / 3 + 0.5 * interval * (n - 1), half_box_width * 2 / 3 + 0.5 * interval * (n - 1)], [max_value(n), max_value(n)], 'k', 'linewidth', line_width);
    % median bar
    plot([-half_box_width + 0.5 * interval * (n - 1), half_box_width + 0.5 * interval * (n - 1)], [median_value(n), median_value(n)], 'r', 'linewidth', line_width);
    % connecting dash line
    plot([0.5 * interval * (n - 1), 0.5 * interval * (n - 1)], [min_value(n), percentile_25(n)], 'k--', 'linewidth', line_width);
    plot([0.5 * interval * (n - 1), 0.5 * interval * (n - 1)], [percentile_75(n), max_value(n)], 'k--', 'linewidth', line_width);
    % preparation for the x-axis
    if n > 1
        set_str_1 = [set_str_1, ' ', num2str(0.5 * interval * (n - 1))];
        set_str_2 = [set_str_2,  name{n}, ''', '''];
    end
    y_min(n) = min(yy{n});
    y_max(n) = max(yy{n});
end
axis([-0.25 * interval, ((n - 1) * 0.5 + 0.25) * interval, min(y_min) - 0.1 * min(y_min) , max(y_max) + 0.1 * min(y_min)]);
set_str_1 = [' ', set_str_1, ']);'];
set_str_2 = set_str_2(1 : end - 3);
set_str_2 = [set_str_2, '});'];
eval(set_str_1);
eval(set_str_2);

title(title_string);
set(gca,'FontSize', font_size, 'FontName','Arial', 'Fontweight', 'bold', 'LineWidth', line_width);
set(findall(gcf,'type','text'),'FontSize', font_size,'FontName','Arial', 'Fontweight', 'bold');
xlabel('Group Name');
return;