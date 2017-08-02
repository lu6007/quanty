% make movie based on the input - 'group' data structure

% Copyright: Qin Qin, Shaoying Lu and Yingxiao Wang
function group_make_movie(group,varargin)
parameter_name = {'position', 'color_bar', 'movie_name', 'load_file', 'save_file', 'stimulus_info', 'intensity_bound'};
default_value = {'p1', 0, 'FRET', 0, 1, '', ''};
[position, color_bar, movie_name, load_file, save_file, stimulus_info, intensity_bound]...
    = parse_parameter(parameter_name, default_value, varargin);

data = group.data;
movie_info.path = regexprep(data.path, group.name, position);
% movie_info.path = strcat(data.path, position, '/');
movie_info.movie_name = [movie_info.path, 'output/', movie_name];
movie_info.image_index = data.image_index;
movie_info.index_pattern = data.index_pattern;
if ~isempty(intensity_bound)
    data.intensity_bound = intensity_bound;
end

% Initialize the ratio images
ratio_str = [num2str(data.ratio_bound(1)), '-', num2str(data.ratio_bound(2))];
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
    temp = find(data_i.prefix == 't');
    str = data_i.prefix(1:temp);
    str = regexprep(str, s1_str, si_str);
    data_i.first_file = strcat(data_i.path, first_file_no_path);
    if save_file
        ratio_folder = [data_i.output_path, ratio_str, '/'];
        if ~isdir(ratio_folder)
            mkdir(ratio_folder);
        end
    end
    ratio_im = cell(max(movie_info.image_index),1);
    for i = (movie_info.image_index)'
        data_i.index = i;
        data_i = get_image(data_i, 0);
        if isempty(data_i.im{1})
            continue;
        end
        first_channel_im = preprocess(data_i.im{1}, data_i);
        second_channel_im = preprocess(data_i.im{2}, data_i);
        ratio = compute_ratio(first_channel_im, second_channel_im);
        ratio_im{i} = get_imd_image(ratio, max(first_channel_im, second_channel_im), ...
                'ratio_bound', data_i.ratio_bound, 'intensity_bound', data_i.intensity_bound);
        if save_file
            temp_file = [ratio_folder, str, num2str(i), '.tiff'];
            ratio_file = regexprep(temp_file, data_i.channel_pattern{1}, 'ratio');
            clear temp_file;
            imwrite(ratio_im{i}, ratio_file, 'tiff', 'compression', 'none');
        end          
    end  
end
list = dir([movie_info.path, 'output/', ratio_str]);
if isempty(list) && load_file
    disp('There is no saved ratio image, please set the "load_file" to be 0.');
    return;
end
%

% Make movie
movie_info.first_file = ['output/', ratio_str, '/', list(3).name];
prefix = regexprep(data.prefix, 's1', ['s', position(2:end)]);
data.prefix = prefix;

first_file = strcat(movie_info.path, movie_info.first_file);
pattern = movie_info.index_pattern;
num_frames = length(list) - 2;
idx = 1;
count = 0;
time = zeros(num_frames, 1);
while(count < num_frames)
    im_file = regexprep(first_file, pattern{1}, sprintf(pattern{2}, idx));
    if ~exist(im_file, 'file')
        idx = idx + 1;
        continue;
    end
    index = sprintf(data.index_pattern{2}, idx);
    current_file = regexprep([data.prefix, data.postfix], data.index_pattern{1}, index);
    time(idx) = get_time_2(strcat(movie_info.path, current_file));
    if idx>= 2 && time(idx) >= 0 && time(idx) < time(idx - 1)
        time(idx) = time(idx) + 24 * 60;
    end
    movie_info.time(idx) = time(idx);
    idx = idx + 1;
    count = count + 1;
end

% find the frame when the stimulus added
stimulus_frame = data.pdgf_between_frame(2);

% >> movie_info.has_event(1:9) = 1;
% >> movie_info.has_event(10:length(image_index)) = 2;
% >> movie_info.event_text = {'Before PDGF', 'After PDGF'};
movie_info.time_location = [340, 20];
movie_info.event_location = [20, 20];
movie_info.has_event = zeros(max(movie_info.image_index), 1);
movie_info.has_event(stimulus_frame:end) = 1;
movie_info.event_text{1} = ['+', stimulus_info];

% calculate the pdgf time
movie_info.time = time - data.pdgf_time;
make_movie(movie_info, 'movie_name', movie_name, 'color_bar', color_bar, 'ratio_bound', data.ratio_bound);

return;

