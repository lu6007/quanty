% Test the simple tracker for our data
% Lexie on 04/04/2016
function [simple_track_ratio, simple_track_size] = simple_tracker(movie_info, fluocell_data,varargin)
parameter_name = {'plot_track', 'max_linking_distance', 'max_gap_closing', 'debug',...
    'separate_distance', 'separation', 'size_difference', 'plot_comparison', 'plot_tracking_result'};
default_value = {0, 500, Inf, true, 250, 0, 0.35, 0, 0};
[plot_tracks, max_linking_distance, max_gap_closing, debug, separate_distance, ...
    separation, size_difference, plot_comparison, plot_tracking_result] = parse_parameter(...
    parameter_name, default_value, varargin);

% format the input for this simple tracker
n_frames = length(movie_info);
coord_data = cell(n_frames, 1);
cell_size = cell(n_frames, 1);
cell_ratio = cell(n_frames, 1);
% time = fluocell_data.time(1 : n_frames, 2) - fluocell_data.time(1, 2);

num_tracks = 0;
for i = 1 : n_frames
    if size(movie_info(i).xCoord, 1) > num_tracks
        num_tracks = size(movie_info(i).xCoord, 1);
    end
end
for i = 1 : n_frames
    for j = 1 : num_tracks
        coord_data{i}(j, 1) = movie_info(i).xCoord(j);
        coord_data{i}(j, 2) = movie_info(i).yCoord(j);
        cell_size{i}(j, 1) = fluocell_data.cell_size{j}(i);
        cell_ratio{i}(j, 1) = fluocell_data.ratio{j}(i);
    end
end

[separation, init_track_idx, newTrackIdx] = sparation_recognition(cell_size, movie_info, coord_data, ...
    'separate_distance', separate_distance, 'size_difference', size_difference);

% if it is a separation case, reassign the object size and objects
% coordinate
if separation
    for n = 1 : separation
        for i = 1 : n_frames
            for j = 1 : size(movie_info(end).xCoord, 1)
                if coord_data{i}(j, :) ~= [0, 0]
                    point(j, :) = coord_data{i}(j, :);
                end
                if cell_ratio{i}(j, 1) == inf
                    temp_coord = coord_data{newTrackIdx}(init_track_idx, :);
                    for m = 1 : size(point, 1)
                        distance(m) = pdist([temp_coord; point(m, :)]);
                    end
                    [~, relate_track] = min(distance);
                    cell_ratio{i}(j, 1) = cell_ratio{i}(relate_track, 1);
                    cell_size{i}(j, 1) = cell_size{i}(relate_track, 1);
                    coord_data{i}(j, 1) = movie_info(i).xCoord(relate_track);
                    coord_data{i}(j, 2) = movie_info(i).yCoord(relate_track);
                end
            end
        end
    end
end

[ tracks, adjacency_tracks ] = simpletracker(coord_data,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...
    'Debug', debug);

n_tracks = numel(tracks);
all_points = vertcat(coord_data{:});
all_cell_size = vertcat(cell_size{:});
all_cell_ratio = vertcat(cell_ratio{:});

for i_track = 1 : n_tracks
    track = adjacency_tracks{i_track};
    temp_pixel = all_cell_size(track, :);
    temp_ratio= all_cell_ratio(track, :);
    track_cell_pixels(:, i_track) = temp_pixel;
    track_cell_ratio(:, i_track) = temp_ratio;
end

if plot_tracking_result
    figure;
    hold on
    plot(track_cell_pixels, 'b.-', 'linewidth', 2);
    if separation
        temp_idx = newTrackIdx - 1;
        plot(temp_idx, track_cell_pixels(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
    end
    ylabel('Pixels');
    legend('Simple Tracker Result');
    figure;
    hold on
    plot(track_cell_ratio, 'b.-', 'linewidth', 2);
    if separation
        temp_idx = newTrackIdx - 1;
        plot(temp_idx, track_cell_ratio(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
    end
    legend('Simple Tracker Result');
    ylabel('Ratio');
end

simple_track_ratio = track_cell_ratio;
simple_track_size = track_cell_pixels;

if plot_comparison
    figure; hold on; 
    for i_track = 1 : n_tracks 
        track = adjacency_tracks{i_track};
        temp_pixel = all_cell_size(track, :);
        plot(track_cell_pixels(:,i_track), 'b-', 'linewidth', 2);
        plot(fluocell_data.cell_size{i_track}(1:length(temp_pixel)), 'r*-');
        if separation
            temp_idx = newTrackIdx - 1;
            plot(temp_idx, track_cell_pixels(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
        end
    end
    ylabel('Cell Size');
    legend('Simple Tracker Result', 'Fluocell Result');
    hold off
    
    figure;
    hold on
    for i_track = 1 : n_tracks 
        track = adjacency_tracks{i_track};
        temp_ratio = all_cell_ratio(track, :);
        plot(track_cell_ratio(:,i_track), 'b-', 'linewidth', 2);
        plot(fluocell_data.ratio{i_track}(1:length(temp_ratio)), 'r*-');
    end
    if separation
        temp_idx = newTrackIdx - 1;
        plot(temp_idx, track_cell_ratio(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
    end
    ylabel('Intensity Ratio')
    legend('Simple Tracker Result', 'Fluocell Result');
    hold off
end

% plot tracks
plotTrack(n_tracks, all_points, coord_data, adjacency_tracks, 'plot_tracks', plot_tracks);

return;




















