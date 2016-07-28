% plot the tracking result

function plotTrack(n_tracks, all_points, coord_data, adjacency_tracks, varargin)
parameter_name = {'plot_tracks'};
default_value = {0};
[plot_tracks] = parse_parameter(parameter_name, default_value, varargin);

colors = hsv(n_tracks);
all_points = vertcat(coord_data{:});
n_frames = length(coord_data);

if plot_tracks
    figure; clf; hold on;
    for i_frame = 1 : n_frames

        str = num2str(i_frame);
        for j_point = 1 : size(coord_data{i_frame}, 1)
            pos = coord_data{i_frame}(j_point, :);
            plot(pos(1), pos(2), 'x')
            text('Position', pos, 'String', str)
        end
    end
    
    for i_track = 1 : n_tracks

        % We use the adjacency tracks to retrieve the points coordinates. It
        % saves us a loop.

        track = adjacency_tracks{i_track};
        track_points = all_points(track, :);
        plot(track_points(:,1), track_points(:, 2), 'Color', colors(i_track, :));
    end
end

% % plot correction cell size
% figure;
% hold on
% for i_track = 1 : n_tracks 
%     track = adjacency_tracks{i_track};
%     temp_pixel = all_cell_size(track, :);
%     track_cell_pixels(:, i_track) = temp_pixel;
% %     plot(time, track_cell_pixels(:,i_track), 'b-', 'linewidth', 2);
% %     plot(time, fluocell_data.cell_size{i_track}(1:length(temp_pixel)), 'r*-');
%     plot(track_cell_pixels(:,i_track), 'b-', 'linewidth', 2);
%     plot(fluocell_data.cell_size{i_track}(1:length(temp_pixel)), 'r*-');
% end
% if separation
%     temp_idx = newTrackIdx - 1;
%     plot(temp_idx, track_cell_pixels(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
% end
% hold off
% % xlabel('Time/min');
% ylabel('Pixels')
% legend('simple-track-result', 'fluocell-data');
% 
% % 
% % % plot correction ratio
% % 
% figure;
% hold on
% for i_track = 1 : n_tracks 
%     track = adjacency_tracks{i_track};
%     temp_ratio= all_cell_ratio(track, :);
%     track_cell_ratio(:, i_track) = temp_ratio;
% %     plot(time, track_cell_ratio(:,i_track), 'b-', 'linewidth', 2);
% %     plot(time, fluocell_data.ratio{i_track}(1:length(temp_ratio)), 'r*-');
%     plot(track_cell_ratio(:,i_track), 'b-', 'linewidth', 2);
%     plot(fluocell_data.ratio{i_track}(1:length(temp_ratio)), 'r*-');
% end
% if separation
% %     plot(time(temp_idx), track_cell_ratio(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
%     plot(temp_idx, track_cell_ratio(temp_idx,1), 'go', 'MarkerSize',10, 'linewidth', 2);
% end
% hold off
% % xlabel('Time/min');
% ylabel('Ratio')
% legend('simple-track-result', 'fluocell-data');

return;