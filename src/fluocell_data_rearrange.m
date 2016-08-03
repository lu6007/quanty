% Rearrangement of fluocell quantification results based on track information 
% function track_ratio = fluocell_data_rearrange(fluocell_data, track_with_frame)

% Copyright Shaoying Lu, Lexie Qin Qin 2016
% shaoying.lu@gmail.com
function [ratio, track_object_pixels] = fluocell_data_rearrange(fluocell_data, ...
    track_with_frame, movie_info, tracksFinal, frame_with_track, varargin)

parameter = {'separation'};
default = {0};
[separation] = parse_parameter(parameter,default, varargin);

num_tracks = length(track_with_frame);
num_frames = length(movie_info);
track_ratio = nan(num_frames, num_tracks);
% track_ratio = nan(num_frames, num_tracks);
object_centroid_x = inf(num_frames, num_tracks);
object_centroid_y = inf(num_frames, num_tracks);
track_centroid_x = inf(num_frames, num_tracks);
track_centroid_y = inf(num_frames, num_tracks);
track_object_pixels = zeros(num_frames, num_tracks);
% track_object_pixels = nan(num_frames, num_tracks);



% for i = 1 : num_tracks 
%     for ii = 1 : num_frames
%         frame_index = track_with_frame(i).frame_index; 
%         if ~separation || length(frame_index) == length(fluocell_data.image_index)     
%             track_object_pixels(ii, i) = track_with_frame(i).num_pixels(ii);
%             object_pixels(ii, i) = fluocell_data.cell_size{1, i}(ii);
%             detect_ratio(ii, i) = fluocell_data.ratio{1, i}(ii);
%             track_object_centroid{ii, i} = frame_with_track(ii).centroid(i, :);
%             track_centroid_x(ii, i) = track_object_centroid{ii, i}(1, 1);
%             track_centroid_y(ii, i) = track_object_centroid{ii, i}(1, 2);
%             object_centroid_x(ii, i) = movie_info(ii).xCoord(i, 1);
%             object_centroid_y(ii, i) =  movie_info(ii).yCoord(i, 1);
%          else
%             if ~ismember(ii, frame_index)
%                 track_object_pixels(ii, i) = track_with_frame(main_track_index).num_pixels(ii);
%                 object_pixels(ii, i) = fluocell_data.cell_size{1, main_track_index}(ii);
%                 detect_ratio(ii, i) = fluocell_data.ratio{1, main_track_index}(ii);
%                 track_object_centroid{ii, i} = frame_with_track(ii).centroid(main_track_index, :);
%                 track_centroid_x(ii, i) = track_object_centroid{ii, main_track_index}(1, 1);
%                 track_centroid_y(ii, i) = track_object_centroid{ii, main_track_index}(1, 2);
%                 object_centroid_x(ii, i) = movie_info(ii).xCoord(main_track_index, 1);
%                 object_centroid_y(ii, i) =  movie_info(ii).yCoord(main_track_index, 1);
%             else
%                 temp_index = find(frame_index == ii);
%                 track_object_pixels(ii, i) = track_with_frame(i).num_pixels(temp_index);
%                 object_pixels(ii, i) = fluocell_data.cell_size{1, i}(ii);
%                 detect_ratio(ii, i) = fluocell_data.ratio{1, i}(ii);
%                 track_object_centroid{ii, i} = frame_with_track(ii).centroid(2, :);
%                 track_centroid_x(ii, i) = track_object_centroid{ii, i}(1, 1);
%                 track_centroid_y(ii, i) = track_object_centroid{ii, i}(1, 2);
%                 object_centroid_x(ii, i) = movie_info(ii).xCoord(2, 1);
%                 object_centroid_y(ii, i) =  movie_info(ii).yCoord(2, 1);
%             end
%          end
%     end
% end

this_index = [];
% Get Fluocell ratio, object size and object coordinate information and put
% them into new data structure for later tracking correction
for i = 1 : num_tracks
    detect_ratio(:, i) = fluocell_data.ratio{i}(fluocell_data.image_index);
    detect_pixels(:, i) = fluocell_data.cell_size{i}(fluocell_data.image_index);
    % change inf to be zero for ratio and pixel value
    [temp_index, ~] = find(detect_ratio == inf);
    detect_ratio(temp_index, i) = 0; clear temp_index
%      detect_ratio(temp_index, i) = 0; clear temp_index
    [temp_index, ~] = find(detect_pixels == inf);
    detect_pixels(temp_index, i) = 0; clear temp_index
%     detect_pixels(temp_index, i) = nan; clear temp_index
    % extract centroid information for both fluocell detect result and
    % tracking result
    start_index = tracksFinal(i).seqOfEvents(1, 1);
    end_index = tracksFinal(i).seqOfEvents(2, 1);
    for ii = start_index : end_index
        if i > length(movie_info(ii).xCoord)
            object_centroid_x(ii, i) = nan;
            object_centroid_x(ii, i) = nan;
        else
            object_centroid_x(ii, i) = movie_info(ii).xCoord(i, 1);
            object_centroid_y(ii, i) = movie_info(ii).yCoord(i, 1);           
        end
    end
    frame_seq = track_with_frame(i).frame_index;
    if length(frame_seq) > length(this_index)
        this_index = frame_seq;
    end
    for ii = 1 : length(frame_seq)
        track_object_pixels(frame_seq(ii), i) = track_with_frame(i).num_pixels(ii);
        track_centroid_x(frame_seq(ii), i) = frame_with_track(frame_seq(ii)).centroid(i, 1);
        track_centroid_y(frame_seq(ii), i) = frame_with_track(frame_seq(ii)).centroid(i, 2);
%         track_centroid_x(frame_seq(ii), i) = tracksFinal(i).tracksCoordAmpCG(8 * ii - 7);
%         track_centroid_y(frame_seq(ii), i) = tracksFinal(i).tracksCoordAmpCG(8 * ii - 6);
    end
    
    
%     for ii = start_index : end_index
%         object_centroid_x(ii, i) = movie_info(ii).xCoord(i, 1);
%         object_centroid_y(ii, i) = movie_info(ii).yCoord(i, 1);
%         if ii > length(track_with_frame(i).num_pixels)
%             temp_index = find([start_index : end_index] == ii);
%             track_object_pixels(ii, i) = track_with_frame(i).num_pixels(temp_index);
%             track_centroid_x(ii, i) = tracksFinal(i).tracksCoordAmpCG(8 * temp_index - 7);
%             track_centroid_y(ii, i) = tracksFinal(i).tracksCoordAmpCG(8 * temp_index - 6);
%             clear temp_index
%         else
%             track_object_pixels(ii, i) = track_with_frame(i).num_pixels(ii);
%             track_centroid_x(ii, i) = tracksFinal(i).tracksCoordAmpCG(8 * ii - 7);
%             track_centroid_y(ii, i) = tracksFinal(i).tracksCoordAmpCG(8 * ii - 6);
%         end
%     end
end

if separation,
    separate_track_index = 0;
    main_track_index = 0;
    temp_length = 10000;  
    % find the separation track for later assignment (shortest one)
    for i = 1 : num_tracks
        if length(tracksFinal(i).tracksFeatIndxCG) < temp_length
            temp_length = length(tracksFinal(i).tracksFeatIndxCG);
            separate_track_index = i;
        end
    end
    % use the separation track to find the main track and get the reference
    % of ratio or pixel value for separation track
    % find the splitting frame
    splitting_index = tracksFinal(separate_track_index).seqOfEvents(1) - 1;
    % find the corrdinate and pixel number of the separation track 
    splitting_centroid_x = track_centroid_x(splitting_index + 1, separate_track_index);
    splitting_centroid_y = track_centroid_y(splitting_index + 1, separate_track_index);
    spliting_num_pixel = track_object_pixels(splitting_index + 1, separate_track_index);
    
    % find the main_track_index
    centroid_distance = inf(1, num_tracks);
    pixel_difference = inf(1, num_tracks);
    for i = 1 : num_tracks
        if i == separate_track_index
            continue;
        else
            centroid_distance(i) = (splitting_centroid_x - track_centroid_x(splitting_index + 1, i))^2 ...
                + (splitting_centroid_y - track_centroid_y(splitting_index + 1, i))^2;
            pixel_difference(i) = abs(spliting_num_pixel - track_object_pixels(splitting_index + 1, i));
        end
    end
    
    [~, indx_centroid] = min(centroid_distance);
    [~, indx_pixel] = min(pixel_difference);
    if indx_centroid == indx_pixel,
        main_track_index = indx_centroid;
    end
    
    
%     % find the main track which ratio could refer to after separation
%     track_length = 0;
%     for i = 1 : length(track_with_frame)
%         temp = length(track_with_frame(i).frame_index);
%         if track_length < temp,
%             track_length = temp;
%             main_track_index = i;
%         end
%     end
% 
%     % Find splitting frame
%     for i = 1 : num_tracks
%         if i ~= main_track_index
%             splitting_index = tracksFinal(i).seqOfEvents(1, 1) - 1;
%         end
%     end
    
    
    % Before splitting, assign ratio of main track to both daughter cells
    detect_ratio(1 : splitting_index, separate_track_index) = detect_ratio(1 : splitting_index, main_track_index);
    detect_pixels(1 : splitting_index, separate_track_index) = detect_pixels(1 : splitting_index, main_track_index);
    object_centroid_x(1 : splitting_index, separate_track_index) = object_centroid_x(1 : splitting_index, main_track_index);
    object_centroid_y(1 : splitting_index, separate_track_index) = object_centroid_y(1 : splitting_index, main_track_index);
    track_centroid_x(1 : splitting_index, separate_track_index) = track_centroid_x(1 : splitting_index, main_track_index);
    track_centroid_y(1 : splitting_index, separate_track_index) = track_centroid_y(1 : splitting_index, main_track_index);
    track_object_pixels(1 : splitting_index, separate_track_index) = track_object_pixels(1 : splitting_index, main_track_index);
end

% linking data based on the centroid information
for i = 1 : num_tracks
    for ii = 1 : num_frames
        current_centroid_x = track_centroid_x(ii, i);
        current_centroid_y = track_centroid_y(ii, i);
        track_index = (object_centroid_x == current_centroid_x) .* ...
            (object_centroid_y == current_centroid_y);
        if sum(sum(track_index)) > 1
            track_index = track_index .* (track_object_pixels(ii, i) == detect_pixels);
            if sum(sum(track_object_pixels(ii, i) == detect_pixels)) > 1
                track_index = track_index / 2;
            end
        end
        track_ratio(ii, i) = sum(sum(detect_ratio .* track_index));
        if track_ratio(ii, i) == 0
            track_ratio(ii, i) = nan;
        end
    end
end
index_temp = find(detect_ratio == 0);
detect_ratio(index_temp) = nan;
clear index_temp
ratio = track_ratio;

figure;
hold on
plot(1, detect_ratio(1, 1), 'r*-');
plot(1, track_ratio(1, 1), 'b--');
plot(1 : length(detect_ratio), detect_ratio, 'r*-', 'linewidth', 1);
plot(this_index, track_ratio(this_index,:), 'b--', 'linewidth', 1);
if separation
    plot(splitting_index, track_ratio(splitting_index, main_track_index), 'go', 'linewidth', 3);
end
legend('fluocell-ratio', 'track-ratio');
hold off

figure;
hold on
plot(1, detect_pixels(1, 1), 'r*-');
plot(1, track_object_pixels(1, 1), 'b--');
plot(1 : length(detect_pixels), detect_pixels, 'r*-', 'linewidth', 1);
plot(this_index, track_object_pixels(this_index, :), 'b--', 'linewidth', 1);
if separation
    plot(splitting_index, track_object_pixels(splitting_index, main_track_index), 'go', 'linewidth', 3);
end
legend('fluocell-cell-size', 'track-cell-size');
hold off
return

