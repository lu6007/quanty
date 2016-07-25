% Rearrangement of fluocell quantification results based on track information 
% function track_ratio = fluocell_data_rearrange(fluocell_data, track_with_frame)

% clear track_ratio detect_ratio sums track_index track_object_pixels detect_ratio object_centroid object_pixels
% 

function ratio = fluocell_data_rearrange(fluocell_data, track_with_frame, frame_with_track, movie_info, track_index, varargin)

parameter = {'separation'};
default = {0};
[separation] = parse_parameter(parameter,default, varargin);

num_tracks = length(track_with_frame);
num_frames = length(track_with_frame(1).num_pixels);
track_ratio = zeros(num_frames, num_tracks);
object_centroid = cell(num_frames, num_tracks);
track_object_centroid = cell(num_frames, num_tracks);
track_object_pixels =  zeros(num_frames, num_tracks);


for i = 1 : num_tracks      
    for ii = 1 : num_frames
        track_object_pixels(ii, i) = track_with_frame(i).num_pixels(ii);
        object_pixels(ii, i) = fluocell_data.cell_size{1, i}(ii);
        detect_ratio(ii, i) = fluocell_data.ratio{1, i}(ii);
        track_object_centroid{ii, i} = frame_with_track(ii).centroid(i, :);
        track_centroid_x(ii, i) = track_object_centroid{ii, i}(1, 1);
        track_centroid_y(ii, i) = track_object_centroid{ii, i}(1, 2);
        object_centroid_x(ii, i) = movie_info(ii).xCoord(i, 1);
        object_centroid_y(ii, i) =  movie_info(ii).yCoord(i, 1);
    end
end


% linking data based on the centroid information
for i = 1 : num_tracks
    for ii = 1 : num_frames
        current_centroid_x = track_centroid_x(ii, i);
        current_centroid_y = track_centroid_y(ii, i);
        track_index = (object_centroid_x == current_centroid_x) .* ...
            (object_centroid_y == current_centroid_y);
        if sum(sum(track_index)) > 1
            track_index = track_index .* (track_object_pixels(ii, i) == object_pixels);
        end
        track_ratio(ii, i) = sum(sum(detect_ratio .* track_index));
    end
end

ratio = track_ratio;

figure;
hold on
plot(1, detect_ratio(1, 1), 'ro-');
plot(1, track_ratio(1, 1), 'b--');
plot(1 : num_frames, detect_ratio, 'ro-', 'linewidth', 1);
plot(1 : num_frames, track_ratio, 'b--', 'linewidth', 1);
legend('fluocell-ratio', 'track-ratio');
hold off

figure;
hold on
plot(1, object_pixels(1, 1), 'ro-');
plot(1, track_object_pixels(1, 1), 'b--');
plot(1 : num_frames, object_pixels, 'ro-', 'linewidth', 1);
plot(1 : num_frames, track_object_pixels, 'b--', 'linewidth', 1);
legend('fluocell-cell-size', 'track-cell-size');
hold off
return

