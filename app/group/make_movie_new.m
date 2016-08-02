% function make_movie_new(group, varargin)
% The function make_movie_new will take pre-existing image and assemble them into movies
% If there is no image saved previously, make_movie_new will also help save the ratio image in corresponding folder
% Example:
% make_movie_new(group, 'position', 'p1')

function make_movie_new(group, varargin)
parameter_name = {'position', 'color_bar', 'movie_name', 'load_file', 'save_file', 'ratio_bound'};
default_value = {'p1', 0, 'FRET', 0, 1, [0.2, 0.5]};
[position, color_bar, movie_name, load_file, save_file, ratio_bound] = parse_parameter(parameter_name, default_value, varargin);


data = group.data;
movie_info.path = regexprep(data.path, 'p1', position);
movie_info.file_name = [movie_info.path, 'output/', movie_name];
movie_info.image_index = data.image_index;
movie_info.index_pattern = data.index_pattern;

ratio_str = [num2str(data.ratio_bound(1)), '-', num2str(data.ratio_bound(2))];


% If there is no ratio image
if ~load_file
    name = group.name;
    s1_str = regexprep(name, 'p', 's');
    name_i = position;
    data_i = data;
    data_i.path = movie_info.path;
    data_i.output_path = [data_i.path, 'output/'];
    si_str = regexprep(name_i, 'p','s');
    [~,file,ext] = fileparts(data.first_file);
    temp_1 = strcat(file, ext);
    first_file_no_path = regexprep(temp_1, s1_str, si_str);
    lists = dir(data_i.path);
    temp = find(data_i.prefix == 't');
    str = data_i.prefix(1:temp);
    str = regexprep(str, s1_str, si_str);
    num_frames = 0;
    for i = 3 : length(lists)
        if strfind(lists(i).name, str)
            [~, pre, ~] = fileparts(lists(i).name);
            num = str2num(pre((temp + 1):end));
            if num_frames == 0,
                num_frames = 1;
            else
                num_frames = [num_frames, num];
            end
        end
    end
    clear temp temp_1;
    index_frames = sort(num_frames);
    data_i.first_file = strcat(data_i.path, first_file_no_path);
    if save_file,
        ratio_folder = [data_i.output_path, ratio_str, '/'];
        if ~isdir(ratio_folder)
            mkdir(ratio_folder);
        end
    end
    for i = index_frames
        data_i.index = i;
        data_i = get_image(data_i, 0);
        first_channel_im = preprocess(data_i.im{1}, data_i);
        second_channel_im = preprocess(data_i.im{2}, data_i);
        ratio = compute_ratio(first_channel_im, second_channel_im);
        ratio_im{i} = get_imd_image(ratio, max(first_channel_im, second_channel_im), ...
                'ratio_bound', data_i.ratio_bound, 'intensity_bound', data_i.intensity_bound);
        if save_file,
            temp_file = [ratio_folder, str, num2str(i), '.tiff'];
            ratio_file = regexprep(temp_file, data_i.channel_pattern{1}, 'ratio');
            clear temp_file;
            imwrite(ratio_im{i}, ratio_file, 'tiff', 'compression', 'none');
        end          
    end  
end
list = dir([movie_info.path, 'output/', ratio_str]);
if isempty(list) && load_file,
    display('There is no saved ratio image, please save it first.');
    return;
end
movie_info.first_file = ['output/', ratio_str, '/', list(3).name];
prefix = regexprep(data.prefix, 's1', ['s', position(2:end)]);
data.prefix = prefix;




% If all the ratio images are already saved 
% Lexie - Copy from the original make_movie with modification on the loop parameter
if isfield(movie_info, 'time'),
    time = movie_info.time; %minute
end;

% Windows 64 bit, use VideoWriter
if strcmp(computer, 'PCWIN64'),
    use_video_writer = 1;
    video_object = VideoWriter(movie_info.file_name, 'Motion JPEG AVI');
    video_object.FrameRate = 3;
    video_object.Quality = 75;
    open(video_object);
else
    use_video_writer = 0;
end;
num_frames = length(list) - 2;
screen_size = get(0,'ScreenSize');
h = figure('Position',[1 1 screen_size(4) screen_size(4)],'color', 'w');
first_file = strcat(movie_info.path, movie_info.first_file);
movie_F = cell(num_frames,2);
fields = {'cdata', 'colormap'};
idx = 1;
count = 0;
while(count < num_frames)
    pattern = movie_info.index_pattern;
    file_name = regexprep(first_file, pattern{1}, sprintf(pattern{2}, idx));
    if ~exist(file_name)
        idx = idx + 1;
        continue;
    end
    
    % Get the time information for each frame
    index = sprintf(data.index_pattern{2}, idx);
    current_file = regexprep([data.prefix, data.postfix], data.index_pattern{1}, index);
    time(idx) = get_time_2(strcat(movie_info.path, current_file));
        if idx>= 2 && time(idx) >= 0 && time(idx) < time(idx - 1)
            time(idx) = time(idx) + 24 * 60;
        end;
        
    m = sprintf('%0.1f', time(idx));    
    ratio_im = imread(file_name);
    im_fig = insertText(ratio_im, [340, 20], [num2str(m), ' min'], 'Boxcolor', 'Black', 'TextColor', 'white', 'FontSize', 30);
    im_fig = insertText(im_fig, [20, 20], movie_name, 'Boxcolor', 'Black', 'TextColor', 'white', 'FontSize', 30);
    figure(h); imshow(im_fig); 
%     title(movie_name, 'fontsize', 16);
    if color_bar,
        a1 = colorbar;
        colormap(jet);
        caxis(data.ratio_bound);
        ticks = get(a1, 'YTick');
        l = length(ticks);
        ticks = linspace(data.ratio_bound(1), data.ratio_bound(2), l);
        set(a1, 'YTickLabel', ticks, 'fontsize', 16);
    end
    if isfield(movie_info, 'time_location'),
        tl = movie_info.time_location;
        el = movie_info.event_location;
        text(tl(1), tl(2), strcat(sprintf('%4.1f ', time(i)), ' min'),...
            'Color', 'w','FontSize', 16,'FontWeight', 'bold');
        tag = movie_info.has_event(j);
        if tag>0,
            text(el(1), el(2), movie_info.event_text{tag}, ...
                'Color', 'w', 'FontSize', 16,'FontWeight', 'bold');
        end
    end
    if isfield(movie_info, 'title'),
        title(movie_info.title);
    end
    if isfield(movie_info, 'axis')>0, 
        axis(movie_info.axis);
    end;
    temp =getframe(gcf);
    if isfield(movie_info, 'movie_frame')>0,
        mf  = movie_info.movie_frame;
        this_frame = temp.cdata(mf(1):mf(2),  mf(3):mf(4), :);
        clear mf;
    else
        this_frame = temp.cdata;
    end;
    movie_F{idx,1} = this_frame;
    movie_F{idx,2} = temp.colormap;
    idx = idx + 1;
    count = count + 1;
    if use_video_writer,
        writeVideo(video_object, this_frame);
    end;
    clear temp this_frame;
end;
my_movie = cell2struct(movie_F, fields,2);

if use_video_writer,
    close(video_object);
else
    if strcmp(computer, 'PCWIN32')
        movie2avi(my_movie, movie_info.file_name, ...
        'compression', 'Cinepak', 'fps',3,'quality', 75);
    else
    % if 'Cinepak' not working, can switch to 'None'
        movie2avi(my_movie, movie_info.file_name, ...
        'compression', 'None', 'fps',3,'quality', 75);
    end;
    
end;

beep;
return;
