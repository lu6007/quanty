function my = my_function()
    % Change the following line to the location of your quanty_dataset_2.
    % Close the folder name with '/'
    my.root = '/Users/kathylu/Documents/sof/data/quanty_dataset_2/';
    my.pause = @my_pause;
    my.dir = @my_dir;
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

% Find the list of subfolders
% ignore the 1st and 2nd folders which are './' and '../'
% ignore all the files and the output folder
function list = my_dir(p)
    % Loop through the subfolders 
    % ignore the 1st and 2nd folders which are './' and '../'
    % ignore all the files and the output folder
    list = dir(p);
    num_folder = length(list);
    valid_folder = false(num_folder, 1);
    for i = 3:num_folder
        if list(i).isdir && ~strcmp(list(i).name, 'output')
            valid_folder(i) = true;
        end
    end
    temp = list(valid_folder); clear list;
    list = temp; clear temp; 
return

