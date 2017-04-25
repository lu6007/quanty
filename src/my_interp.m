% function y_interp = my_interp(x,y, x_interp)
% Calculate Interpolation
% (1) Allow the interp_time to be longer than the actual image time
% Extend the ratio values to both sides horizontally
% (2) Insert time =0 and average basal value into the time course
% at 0 min.
% (3) Smooth the data before and after stimulation seperately. 
function y_interp = my_interp(x,y, x_interp)
time_interp = x_interp;
ii = ~isnan(y);
this_time = x(ii);
this_ratio = y(ii); 
clear ii;
nn = length(time_interp);
smooth_span = 40;

if min(this_time)>time_interp(1)
    temp = [time_interp(1); this_time]; clear this_time;
    this_time = temp; clear temp;
    temp = [this_ratio(1,:); this_ratio]; clear this_ratio;
    this_ratio = temp; clear temp;
end;
if max(this_time)<time_interp(nn)
    temp = [this_time; time_interp(nn)]; clear this_time;
    this_time = temp; clear temp;
    temp = [this_ratio; this_ratio(length(this_ratio), :)]; clear this_ratio;
    this_ratio = temp; clear temp;
end;

% Insert the 0 min ratio value
index_before = (this_time < 0);
index_0 = (this_time == 0);
index_after = (this_time>0 & this_time<=time_interp(nn));
average_basal = mean(this_ratio(index_before));
% if 0 is not in the array this_time,
% add 0 into the time course
if ~sum(double(index_0))
    temp = [this_time(index_before); 0; this_time(index_after)]; clear this_time;
    this_time = temp; clear temp;
    temp = [this_ratio(index_before); average_basal; this_ratio(index_after)]; clear this_ratio;
    this_ratio = temp; clear temp;
end;

y_interp = interp1(this_time, this_ratio,time_interp,'linear');
% y_before = smooth(y_interp(time_interp<=0), smooth_span);
% y_after = smooth(y_interp(time_interp>0), smooth_span); clear y_interp;
temp = smooth(y_interp(time_interp<=0.5), smooth_span);
y_before = temp(time_interp<=0); clear temp;
temp = smooth(y_interp(time_interp>=-0.5), smooth_span); 
tt = time_interp(time_interp>=-0.5);
y_after = temp(tt>0); clear y_interp temp; % time_interp>0
y_interp = [y_before; y_after];
return;