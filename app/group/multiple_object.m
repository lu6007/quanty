classdef multiple_object
    %multiple_object contains functions for tracking multiple objects in
    %one frame.
    methods (Static)
        function data = simpletracking(data, coordInfo, varargin)
            
            %Initializing parameter/variable values.
            parameter_name = {'remove_short_track', 'min_track_length',...
                'plot_cell_split','max_distance'};
            default_min_track_length = ceil(0.5*length(coordInfo));
            default_value = {0, default_min_track_length, 0, 0.40};
            [remove_short_track, min_track_length,...
                plot_cell_split, max_distance] =...
                parse_parameter(parameter_name, default_value, varargin);
            
            %Debug
            remove_short_track = 1;
%             min_track_length = 8;
            plot_cell_split = 1;
            max_distance = 0.40;            
            
            %Convert coordInfo to a data structure that simpletracker can use.
            coordInfo = struct2cell(coordInfo)';
            numFrames = length(coordInfo);
            d = cell(numFrames,1);
            for i = 1:numFrames
                d{i,1}=cell2mat(coordInfo(i,:));
            end
            coordInfo = d; 
            clear i d;
            
            % Accounting for empty frames before running simpletracker().
            removedFramesIndex = find(cellfun('isempty',coordInfo))'; %Getting the indices for empty frames.
%             frameIndex = data.image_index(removedFramesIndex);
            frameIndex = find(~cellfun('isempty',coordInfo))';
            coordInfo = coordInfo(frameIndex);
            
            % Running simpletracker.
            maxLinkingDistance = 500;
            maxGapClosing = 3;
            debug = true;
            [ tracks, adjacency_tracks ] = simpletracker(coordInfo,...
                'MaxLinkingDistance', maxLinkingDistance, ...
                'MaxGapClosing', maxGapClosing, ...
                'Debug', debug);
            
            %% Reformatting the data using information from simpletracker(), Part 1 of 2.
            %Concatenate data the same way that simpletracker concatenates.
            
            %Initialize new data.ratio, channel1, channel2, etc.
            %num_tracks is the number of objects that simpletracker has determined!
            num_tracks = numel(tracks);
            
            %Initialize temp variables.
            temp_ratio = cell(1,num_tracks);
            temp_channel1 = cell(1,num_tracks);
            temp_channel2 = cell(1,num_tracks);
            temp_cellSize = cell(1,num_tracks);
            temp_location = cell(size(coordInfo,1),num_tracks);
            
            %Initialize variables.
            dataRatio = [];
            dataChannel1 = [];
            dataChannel2 = [];
            dataCellSize = [];

            allRatio = [];
            allChannel1 = [];
            allChannel2 = [];
            allCellSize = [];
            
            %Converting cell array to a double array.
            for i = 1:length(data.ratio)
                dataRatio = [dataRatio data.ratio{i}];
                dataChannel1 = [dataChannel1 data.channel1{i}];
                dataChannel2 = [dataChannel2 data.channel2{i}];
                dataCellSize = [dataCellSize data.cell_size{i}];
            end; clear i;
            
            %Concatenating values.
            for i = 1:numFrames
                allRatio = [allRatio horzcat(dataRatio(i,:))];
                allChannel1 = [allChannel1 horzcat(dataChannel1(i,:))];
                allChannel2 = [allChannel2 horzcat(dataChannel2(i,:))];
                allCellSize = [allCellSize horzcat(dataCellSize(i,:))];
            end; clear i;
            
            %Remove NaN values.
            allRatio(isnan(allRatio(:)) ) = [];
            allChannel1(isnan(allChannel1(:)) ) = [];
            allChannel2(isnan(allChannel2(:)) ) = [];
            allCellSize(isnan(allCellSize(:)) ) = [];

            %Convert row to column.
            allRatio = allRatio';
            allChannel1 = allChannel1';
            allChannel2 = allChannel2';
            allCellSize = allCellSize';
            allLocation = vertcat(coordInfo{:});

            %% Reformatting the data using information from simpletracker(), Part 2 of 2.
            %Reformat data using tracking information from simpletracker().
            for i = 1:num_tracks
               %Account for the different row indexing of tracks and adjacency_tracks.
               trackIndex = 1;
               adjIndex = 1;
               for j = 1:numFrames
                   %Adding NaN values where a frame was removed.
                   if any(removedFramesIndex == j)
                       for b = 1:num_tracks
                           temp_ratio{b}(j,1) = nan;
                           temp_channel1{b}(j,1) = nan;
                           temp_channel2{b}(j,1) = nan;
                           temp_cellSize{b}(j,1) = nan;
                           temp_location{j,b} = nan;
                       end
                   %Save NaN value if 'tracks' was NaN at frame number 'j'.
                   elseif isnan(tracks{i}(trackIndex))
                       temp_ratio{i}(j,1) = nan;
                       temp_channel1{i}(j,1) = nan;
                       temp_channel2{i}(j,1) = nan;
                       temp_cellSize{i}(j,1) = nan;
                       temp_location{j,i} = nan;
                       trackIndex = trackIndex + 1;
                   else %if 'tracks' is not NaN
                       temp_ratio{i}(j,1) = allRatio(adjacency_tracks{i}(adjIndex));
                       temp_channel1{i}(j,1) = allChannel1(adjacency_tracks{i}(adjIndex));
                       temp_channel2{i}(j,1) = allChannel2(adjacency_tracks{i}(adjIndex));
                       temp_cellSize{i}(j,1) = allCellSize(adjacency_tracks{i}(adjIndex));
                       temp_location{j,i} = allLocation(adjacency_tracks{i}(adjIndex),:);
                       adjIndex = adjIndex + 1;
                       trackIndex = trackIndex + 1;
                   end
               end
            end
            clear i j b trackIndex adjIndex
            
      
            %% Checking and plotting cell splitting.
            %Run two checks when a new cell appears:
            %Check cell size - seems to shrink ~half about 1-3 frames before split
            %Check cell location - ensure new and old cells are sufficiently close
            if plot_cell_split == 1
                if num_tracks > 1                    
                    track_cell_size = nan(numFrames,num_tracks);
                    for k = 1:num_tracks
                        track_cell_size(:,k) = temp_cellSize{k}(:);
                    end
                    clear k;
                    for i = 1:num_tracks
                        %Will only run splitting detection if a cell was not present in
                        %the first frame.
                        if isnan(temp_ratio{i}(1))
                            for j = 2:numFrames
                                %continue if current frame has NaN value in this track
                                if isnan(temp_ratio{i}(j))
                                    continue;
                                end
                                
                                
                                %>>Check if any other cells have shrunk in the same frame.
                                %Compare using the average of the last 3ish frames.
                                if j <= 3
                                    %Using 1:j-1 so there are at least 2 rows for nanmean.
                                    %Min j value is 2. Max j value is num of time frames.
                                    avg_pixel = nanmean(track_cell_size(1:j-1,:));
                                else
                                    avg_pixel = nanmean(track_cell_size(j-3:j-1,:));
                                end
                                %Difference between avg of last ~3 frames & current frame
                                %Positive > cell shrank. Negative > cell grew.
                                diff_pixel = avg_pixel - track_cell_size(j,:);
                                
                                
                                %>>Check distance between the cells.
                                if any(diff_pixel > 0) %&& any(diff_pixel > 0.2*avg_pixel)
                                    %Gets index of the cell w/ the max size difference.
                                    [~,I] = max(diff_pixel);
                                    % i is new cell, I is cell it split from
                                    
                                    % Check if cells are sufficiently close to each other.
                                    distance = pdist([temp_location{j,i}; temp_location{j,I}]);
                                    
                                    im_size = size(data.im{1});
                                    maximum_distance = max_distance * max(im_size);
                                    
                                    if distance < maximum_distance
                                        %"Merge" the plot of the new cell w/ the original cell.
                                        track_cell_size(1:j-1,i) = track_cell_size(1:j-1,I);
                                        temp_ratio{i}(1:j-1) = temp_ratio{I}(1:j-1);
                                        %Saving frame of split for plotting later.
%                                         split_pixel = [split_pixel; track_cell_pixel(j-1,i) j-1];
%                                         split_ratio = [split_ratio; temp_ratio(j-1,i) j-1];
                                        disp('An instance of cell splitting was detected.');
                                    end
                                end
                                
                                
                                break;
                            end
                        end
                    end
                    clear i j;
                end
            end
            
            %% Option for removing very short tracks.
            %Function parameter: min_track_length >> default = 2
            if remove_short_track == 1
                k = 0; %Initialize for tracking the number of removed tracks.
                for i = 1:num_tracks
                    j = i - k; %Update index to account for removed tracks.
                    %Check if the track is shorter than the min track length.
                    if sum(~isnan(temp_ratio{j})) <= min_track_length
                        temp_ratio(j)=[]; %Remove short track.
                        temp_channel1(j)=[]; %Remove short track.
                        temp_channel2(j)=[]; %Remove short track.
                        temp_cellSize(j)=[]; %Remove short track.
                        k = k + 1; %Number of removed tracks.
                    end
                end
%                 num_tracks = num_tracks - k; %Updating value of num_tracks.
                clear i j k; %Clear counter variables.
            end
          
            %% Exporting the processed data.
            data.ratio = temp_ratio;
            data.channel1 = temp_channel1;
            data.channel2 = temp_channel2;
            data.cell_size = temp_cellSize;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        function coordInfo = getCoord(data)
            % Returns the coordinates of the centroid of each object
            % as a data structure. Fields are 'xCoord' and 'yCoord'.
            
            pattern = data.index_pattern{2};
            % initialize movie_info
            num_frames = length(data.image_index);
            field = {'xCoord', 'yCoord'};
            num_fields = length(field);
            c = cell(num_frames, num_fields);
                        
            for k = data.image_index                
                data.index = data.image_index(k);
                data = get_image(data, 0);
                
                index_str = sprintf(pattern, data.index);
                file_name = strcat(data.path, 'output\cell_bw.', index_str, '.mat');
                if ~exist(file_name,'file')
                   continue; 
                end
                result = load(file_name);
                object_bw = result.cell_bw;
                clear result;
                
                [object_bd, object_label] = bwboundaries(object_bw, 8, 'noholes');
                object_prop = regionprops(object_label, 'Centroid', 'PixelList');
                object_centroid = cat(1, object_prop.Centroid);
                
                %If frame does not exist, allow the tracker to skip the frame.
                if ~exist(data.file{1}, 'file')
                    continue;
                end
                clear first_file_path second_file_path
                
                c{k,1} = object_centroid(:,1);
                c{k,2} = object_centroid(:,2);
                clear im_fak im_object im_ratio object_centroid object_total_intensity object_label...
                    object_prop object_bd fak_total_intensity pax_total_intensity z
            end % for k = 1:5
            coordInfo = cell2struct(c, field, 2);
            return
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function data = postprocessing(data)
            %Shortens data.--- if 
            
            %lengthen all cells of
            % data.channel1, channel2, ratio to 1 x image_index
            % change zeros to NaN
            % shorten the first cell to the length of image_index, instead of 200
            num_objects = length(data.ratio);
            num_timeframes = length(data.image_index);
            
            %Updating length of each cell that contains an object.
            for i = 1:num_objects
                num_indices = length(data.ratio{i});
                track_length = length(data.ratio{i}(:));
                
                %Truncates data.--- if it is longer than num_timeframes.
                %Currently, data.---{1} is set to 200 by default.
                if track_length > num_timeframes
                    data.ratio{i}(num_timeframes+1:num_indices,:) = [];
                    data.channel1{i}(num_timeframes+1:num_indices,:) = [];
                    data.channel2{i}(num_timeframes+1:num_indices,:) = [];
%                     data.cell_size{i}(num_timeframes+1:num_indices,:) = [];
                    %at data.cell_size, "Matrix index is out of range for deletion."
                    %cell_size is not initialized to a longer length like
                    %data.ratio, channel1 and channel2
                    %cell_size is set in quantify_region_of_interest().
                    
                    %data.cell_size{1} is not set to 200 by default.
                    %Lengthens data.cell_size{1} if it is shorter than the
                    %other data.--- variables.
                    if length(data.cell_size{i}(:)) < num_timeframes
                        num_indices = length(data.cell_size{i});
                        data.cell_size{i}(num_indices+1:num_timeframes,:) = nan;
                    end
                else
                    %Lengthening truncated tracks. Make new entries NaN
                    data.ratio{i}(num_indices+1:num_timeframes,:) = nan;
                    data.channel1{i}(num_indices+1:num_timeframes,:) = nan;
                    data.channel2{i}(num_indices+1:num_timeframes,:) = nan;
                    data.cell_size{i}(num_indices+1:num_timeframes,:) = nan;
                end
            end
            
            for i = data.image_index %double check this
                for j = 1:num_objects
                    num_layers = size(data.ratio{j},2);%get the num of subcellular layers
                    % ^^ Could change this to if-statement for num_layers instead ^^
                    for k = 1:num_layers
                        %Converts any 0 values to NaN.
                        if data.ratio{j}(i,k) == 0
                            data.ratio{j}(i,k) = nan;
                            data.channel1{j}(i,k) = nan;
                            data.channel2{j}(i,k) = nan;
                            data.cell_size{j}(i,k) = nan;
                        end
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    end
end