classdef my
    %my customizes existing MATLAB functions
    %Currently not in use.
    methods (Static)
        function output = dir(input,varargin)
            %dir list folder contents
            % my.dir removes hidden folders: '.' and '..' from the output
            % dir(input) --> run dir as normal
            % Options:
            % - 'remove_hidden': removes hidden directories: '.' and '..'
            % - 'remove_nondir': removes files that aren't directories
            % - 'remove_output': removes the output folder from the 
            %   file list
            
            parameter_name = {'remove_hidden','remove_nondir','remove_output'};
            default_value = {false, false, false};
            [remove_hidden, remove_nondir, remove_output] = ...
                parse_parameter(parameter_name, default_value, varargin);
            clear default_value parameter_name
            
            index = [];
            fileList = dir(input);
            
            %Search for hidden folders: '.' and '..'
            %Record index of folders/files for removal
            for i = 1:length(fileList)
                %Remove hidden directories
                if (remove_hidden && fileList(i).isdir && ...
                        (strcmpi(fileList(i).name,'.') || strcmpi(fileList(i).name,'..')))...
                        ...%Remove nondirectories
                        || (remove_nondir && ~fileList(i).isdir)...
                        ...%Remove the output folder
                        || (remove_output && strcmpi(fileList(i).name,'output'))
                    index = [index,i];
                end
            end
            
            %Remove the hidden folders from 'content' based on their index
            if ~isempty(index)
                fileList(index) = [];
            end
            
            %Output modified list of folder contents
            output = fileList;
        end
        
        function indexes = checkFiles(directory, firstChannelPattern, indexPattern)
            %HAS NOT BEEN TESTED FOR WHEN indexPattern{2} IS NOT t%d
            %Reads the indices of the files in the folder of the current
            %position.
            %Example
            % directory = fluocell_data.path;
            % firstChannelPattern = fluocell_data.channel_pattern{1};
            % indexPattern = fluocell_data.index_pattern{2};
            % my.checkFiles(directory, firstChannelPattern, indexPattern);
            
            fileList = my.dir(directory,'remove_hidden',1,'remove_output',1);
            fileName = {fileList(:).name}';
            fileFirstChannel = strfind(fileName,firstChannelPattern);
            fileIndex = ~cellfun('isempty',fileFirstChannel);
            fileName = fileName(fileIndex);
            
            expression = regexprep(indexPattern, '%', '\');
            expression = strcat('_',expression,'+');
            
            out = regexp(fileName,expression,'match');
            out = cellfun(@(x) x{1}, out, 'UniformOutput', false);
            indexes = regexp(out, '\d+','match');
            indexes = cellfun(@(x) str2double(x{1}), indexes, 'UniformOutput', false);
%             indexes = cellfun(@num2str, indexes, 'UniformOutput', false);
            indexes = cell2mat(indexes)';
            %Outputs vector with the indices in the folder.
            
        end
    end
end