% Rearrangement of fluocell quantification results based on track information 
% function track_ratio = fluocell_data_rearrange(fluocell_data, track_with_frame)

% clear track_ratio detect_ratio sums track_index track_object_pixels detect_ratio object_centroid object_pixels
% 

function ratio = fluocell_data_rearrange(fluocell_data, track_with_frame)

num_tracks = length(tracksFinal);
num_frames = length(track_with_frame(1).num_pixels);
track_ratio = zeros(num_frames, num_tracks);
object_centroid = cell(num_frames, num_tracks);

for i = 1 : num_tracks
    for ii = 1 : num_frames
        track_object_pixels(ii, i) = track_with_frame(i).num_pixels(ii);
        object_pixels(ii, i) = fluocell_data.cell_size{1, i}(ii);
        detect_ratio(ii, i) = fluocell_data.ratio{1, i}(ii);
        object_centroid{ii, i} = frame_with_track(ii).centroid(i, :);
    end
end


for i = 1 : num_tracks
    for ii = 1 : num_frames
%         fluocell_intensity(i, ii) = fluocell_data.channel1_bg(ii) + fluocell_data.channel2_bg(ii)...
%     + fluocell_data.channel1{1, i}(ii) + fluocell_data.channel2{1, i}(ii);
%         track_intensity(i, ii)  = track_with_frame(i).average_amp(ii);
        track_index= (track_object_pixels(ii, i) == object_pixels);
        sums(ii, i) = sum(sum(track_index)); % if there are more than two objects have the same size
        if sum(sum(track_index)) > 1
            if ii - 1 > 1 % if it is one object in the first frame
                last_object_centroid = object_centroid{ii - 1, i};
            else
                last_object_centroid = object_centroid{ii, i};
            end
            [track_row, track_column] = find((track_object_pixels(ii, i) == object_pixels));
            num_corr = length(track_row);
            temp_centroids = cell(num_corr, 1);
            for n = 1 : num_corr
                temp_centroids{n} = object_centroid{track_row(n), track_column(n)};
                difference(n) = abs(sum(temp_centroids{n} - last_object_centroid));
            end
            track_index = zeros(num_frames, num_tracks);
            if mean(track_column) == i % one object might have same size in different frames
                track_index(ii, i) = 1;
            else
                [~, ind] = min(difference);
                track_index(track_row(ind), track_column(ind)) = 1;
            end
            clear temp_centroids distance last_object_centroid num_corr track_row track_column
        end
        track_ratio = track_ratio + detect_ratio .* track_index;
    end
end

figure;
hold on
plot(1 : num_frames, detect_ratio, 'ro');
plot(1 : num_frames, track_ratio, 'b--');
hold off
ratio = track_ratio;
return

