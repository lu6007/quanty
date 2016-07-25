% function add_error_bar(time, mean_ratio, std_error, varargin)
% Add error bar on the average curve
% parameter_name = {'error_bar_interval', 'error_bar_color'};
% default_value = {5, 'k'}; % 5 minutes
% [error_bar_interval, error_bar_color]= parse_parameter(parameter_name, default_value, varargin);

% Copyright: Shaoying Lu, Qin Qin, and Yingxiao Wang
function add_error_bar(time, mean_ratio, std_error, varargin)
parameter_name = {'error_bar_interval', 'error_bar_color'};
default_value = {5, 'k'};
[error_bar_interval, error_bar_color]= parse_parameter(parameter_name, default_value, varargin);

time_eb = min(time):error_bar_interval:max(time);
std_error_eb = interp1(time, std_error, time_eb);
mean_ratio_eb = interp1(time, mean_ratio, time_eb);
errorbar(time_eb, mean_ratio_eb, std_error_eb,'.','Color', error_bar_color, 'LineWidth',2);
return;