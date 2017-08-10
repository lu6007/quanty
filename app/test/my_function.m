function my = my_function()
    % Change the following line to the location of your quanty_dataset_2.
    % Close the folder name with '/'
    my.root = '/Users/kathylu/Documents/sof/data/quanty_dataset_2/';
    my.pause = @my_pause;
return

% function my_pause(enable_pause, pause_str)
% Allows the function name and pause_str to be dislayed
% when enable_pause = 1 . 
function my_pause(enable_pause, pause_str)
if enable_pause
    % find the name of upper level function
    fun = dbstack;
    if length(fun)>=2
        disp([fun(2).name, ': paused. ', pause_str]);
    else
        disp([fun(1).name, ': paused. ', pause_str]);
    end
    pause;
end
return

