% function [separation, init_track_idx, newTrackIdx] = ...
%     detect_separation(object_size, coord_data, varargin)
% Detect splitting events and calculate correspond paramters

% Copyright Shaoying Lu, Lexie Qin Qin 2016
% shaoying.lu@gmail.com
function [separation, init_track_idx, newTrackIdx] = ...
    detect_separation(object_size, coord_data, varargin)
parameter_name = {'separate_distance', 'size_difference'};
default_value = {250, 0.35};
[separate_distance, size_difference] = parse_parameter(parameter_name,...
    default_value, varargin);

% initiation sepration event to be zero
possibleSeparation = 0;
separation = 0;
possibleNewTrackIdx = zeros(100, 1);

new_object_size = zeros(length(object_size), length(object_size{end}));
% pass data in object_size(cell) to a single matrix
for i = 1 : length(object_size)
    for j = 1 : length(object_size{i})
        new_object_size(i, j) = object_size{i}(j);
    end
end

% find possible separation and where new track is created
num_tracks = size(new_object_size, 2);
for i = 1 : num_tracks
    temp = find(new_object_size(:, i) == inf | new_object_size(:,i) == 0);
    if isempty(temp)
        continue;
    elseif temp(1) == 1 && length(temp) >= 2
        possibleSeparation = possibleSeparation + 1;
        possibleNewTrackIdx(possibleSeparation) =  temp(end) + 1;
    end
    clear temp;
end
temp = possibleNewTrackIdx(1:possibleSeparation); 
clear possibleNewTrackIdx;
possibleNewTrackIdx = temp; clear temp;

points_before_new_track = cell(possibleSeparation,1);
points_new_track = cell(possibleSeparation, 1);
if possibleSeparation
    newTrackBeforeIdx = possibleNewTrackIdx -1;
    for i = 1 : possibleSeparation, 
        points_before_new_track{i} = coord_data{newTrackBeforeIdx(i)};
        points_new_track{i} = coord_data{possibleNewTrackIdx(i)};
    end

    % clear the zero coordinate in before new track
    temp = [];
    for i = 1 : length(points_before_new_track)
        for j = 1 : length(points_before_new_track{i})
            if ~points_before_new_track{i}(j, :), 
                continue
            else
                temp = [temp; points_before_new_track{i}(j, :)];
            end
        end
        clear points_before_new_track{i}
        points_before_new_track{i} = temp; clear temp
    end

    % find the index of initial tracks
    for n = 1 : length(points_before_new_track)
        for i = 1 : size(points_before_new_track{n}, 1)
            for j = 1 : size(points_new_track{n}, 1)
                point_1 = points_before_new_track{n}(i, :);
                point_2 = points_new_track{n}(j, :);
                distance(n, i, j) = pdist([point_1; point_2]);
            end
            [~, main_track_idx(n, i)] = min(distance(n, i,:));
        end
    end
    clear distance point_1 point_2
    init_track_idx = [];
    if length(points_before_new_track) == 1
        init_track_idx = 2;
    else
        for n = 1 : length(points_before_new_track)
            for i = 1 : size(points_before_new_track{n}, 1)
                if ~ismember(i, main_track_idx)
                    init_track_idx = [init_track_idx, i];
                end
            end
        end
    end

    % calculate the distance and object size between before/after new track
    % initiated
    NN = length(points_new_track);
    II = length(main_track_idx);
    JJ = length(init_track_idx);
    distance = zeros(NN, II, JJ);
    size_diff = zeros(NN, II, JJ);
    for n = 1 : NN,  
        for i = 1 : II, 
            for j = 1 : JJ, 
                point_1 = points_new_track{n}(init_track_idx(j), :);
                point_2 = points_new_track{n}(main_track_idx(i), :);
                distance(n, j, i) = pdist([point_1; point_2]);
                size_diff(n, j, i) =abs(object_size{possibleNewTrackIdx}(init_track_idx(j)) - ...
                    object_size{possibleNewTrackIdx}(main_track_idx(i))) /...
                    object_size{possibleNewTrackIdx}(init_track_idx(j));
            end
        end    
    end

    % based on the information defined by user, define if new track is an
    % splitting case
    for i = 1 : length(init_track_idx)
        min_distance = min(distance(i, :, :));
        min_size_diff = min(size_diff(i, :, :));
        if min_distance < separate_distance && min_size_diff < size_difference
            separation = separation + 1;
        end
    end
    newTrackIdx = possibleNewTrackIdx;
else
    init_track_idx = []; 
    newTrackIdx = [];
end


return