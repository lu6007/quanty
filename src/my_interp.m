% function y_interp = my_interp(x,y, x_interp)
% Calculate Interpolation
% (1) The interp_time is shorter shorter than the actual image time
% (2) Insert time = 0 and average basal value into the time course
% at 0 min.
% (3) Smooth the data before and after stimulation seperately. 
% (4) Ignore 'NaN' in the ratio data. 
function y_interp = my_interp(x,y, x_interp, varargin)
para_name = {'smooth_span'};
default_value = {40}; 
smooth_span = parse_parameter(para_name, default_value, varargin);
time_interp = x_interp;
ii = ~isnan(y);
this_time = x(ii);
this_ratio = y(ii); 
clear ii;

% Insert Nan to other locations
this_index = (time_interp>= min(this_time)) & (time_interp <= max(this_time));
time_interp(~this_index) = NaN; 
% Insert time = 0
ii_equal = find(this_time == 0, 1);
if isempty(ii_equal)
    ii_before = (this_time<0);
    if ~isempty(ii_before)
        ii_after = (this_time>0);
        temp = [this_time(ii_before); 0; this_time(ii_after)]; clear this_time;
        this_time = temp; clear temp;
        ratio_before = this_ratio(ii_before); 
        temp = [ratio_before; ratio_before(end); this_ratio(ii_after)]; clear this_ratio;
        this_ratio = temp; clear temp ratio_before ii_after; 
    end
    clear ii_before; 
end
y_interp = interp1(this_time, this_ratio, time_interp); % default linear interpolation

% y_before = smooth(y_interp(time_interp<=0), smooth_span);
% y_after = smooth(y_interp(time_interp>0), smooth_span); clear y_interp;
index_interp_before = (time_interp<=0);
time_interp_before = time_interp(index_interp_before);
short_span = floor(smooth_span/3+1);
if size(time_interp_before, 1)>=short_span
    temp = smooth(time_interp(index_interp_before), y_interp(index_interp_before), ...
        short_span, 'lowess');
    y_before = temp; clear temp;
else
    y_before = zeros(size(time_interp_before));
    y_before(:) = mean(this_ratio(index_interp_before));
end
index_interp_after = (time_interp>0);
y_after = smooth(time_interp(index_interp_after), y_interp(index_interp_after), smooth_span, 'lowess'); 
y_interp(index_interp_before | index_interp_after) = [y_before; y_after];

% 
% figure; hold on; plot(time_interp, y_interp); 
% plot(this_time, this_ratio, '+'); 
return;