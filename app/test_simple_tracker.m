% function [trackRatio, trackSize] = test_simple_tracker(fluocell_data, image_index, intensity_text, varargin)

% Copyright Shaoying Lu, Lexie Qin Qin 2016, shaoying.lu@gmail.com
function [trackRatio, trackSize] = test_simple_tracker(fluocell_data, image_index, intensity_text, varargin)
parameter = {'method', 'separation'};
default = {'simple_tracker', 0};
[method] = parse_parameter(parameter,default, varargin);


% fluocell_data.image_index = (str2num(image_index))';
fluocell_data.cell_name = 'cell1';
fluocell_data.track_index = (str2num(image_index))';
fluocell_data.cbound = str2num(intensity_text);
fluocell_data.track_max_search_radius = 100;

movie_info = get_movie_info(fluocell_data, 'load_file',0,'save_file',1);

if strcmp(method, 'singleParticleTracking')
    frame_index = 1:length(fluocell_data.image_index);
    tracksFinal = get_track(fluocell_data, movie_info(frame_index), 'load_file', 0, 'save_file', 1); %tracksFinal contains all the FAs (~200 tracks)
    frame_with_track = get_frame_track(tracksFinal,movie_info(frame_index));
    track_with_frame = get_track_frame(fluocell_data, tracksFinal, movie_info(frame_index));
    % track_index = [1 : length(tracksFinal)];
    % overlay_image_track(fluocell_data, frame_with_track, 'image_index', fluocell_data.image_index,...
    % 'load_file', 1, 'track_index', track_index);
    [trackRatio, trackSize] = fluocell_data_rearrange(fluocell_data, track_with_frame,...
        movie_info, tracksFinal, frame_with_track, 'separation', separation);
elseif strcmp(method, 'simple_tracker')
    [trackRatio, trackSize] = simple_tracker(movie_info, fluocell_data, 'plot_track', 0, 'plot_comparison', 1);
end
return;