function my = my_function()
    my.pause = @my_pause;
return

function my_pause(enable_pause, pause_str)
if enable_pause
    % find the name of upper level function
    fun = dbstack;
    if length(fun)>=2
        disp([fun(2).name, ': paused. ', pause_str]);
    else
        disp([fun(1).name, ': paused. ', pause_str]);
    end;
    pause;
end
return

