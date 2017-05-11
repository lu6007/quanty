% function group = g2p_init_data(fluocell_data, varargin)
% converts the fluocell_data to 
% the data as input for cell detection and time course computing
%
% parameter_name = {'group_data','pdgf_time_shift', 'load_file'};
% default_value = {[], -0.5, 0};
%
% If there is group_data, the function updates group_data to the file
% If group_data = [] from the input, the function updates group_data from
% the data file
% If group_data = [] and the data file is not there, the function 
% updates group_data from fluocell_data.
%
% Example:
% name = 'p1';
% fluocell_data.pdgf_between_frame = [7; 8];
% fluocell_data.image_index = [1:14 16];
% fluocell_data.quantify_roi = 3;
% group = g2p_init_data(fluocell_data)

% Copyright: Shaoying Lu and Yingxiao Wang 2013-2017 
% Email: shaoying.lu@gmail.com

function group = g2p_init_data(fluocell_data, varargin)
parameter_name = {'group_data','pdgf_time_shift', 'load_file'};
default_value = {[], -0.5, 0};
[group_data, pdgf_time_shift, load_file] = parse_parameter(parameter_name, default_value, varargin);
save_data = 1;
group.name = 'p1';
%load_data = 0;

%
% if group_data is empty, change the path to output and load fluocell_data;
%
if isempty(group_data) 
    p = fluocell_data.path;
    output_file = strcat(p(1:end-3), 'output/data.mat'); % avoid problem when 'p1/' does not exist
else
    output_file = strcat(group_data.path(1:end-3), 'output/data.mat');
end
if ~exist(fileparts(output_file), 'dir')
    mkdir(fileparts(output_file));
end

% if there is group_data, load group_data
% if there is no group_data and there is data file, load file
% if there no group_data or data file, load from fluocell_data
if ~isempty(group_data)
    data = group_data;
    
    if ~isfield(data, 'pdgf_between_frame')
        pp = data.path;
        temp = data.first_cfp_file;
    elseif length(data.pdgf_between_frame)==2 % there is data.pdgf_between_frame
        % calculate the pdgf_time
        % find the cfp file at cycle between_pdgf_frame(2) and position 1
        % extract the time info when the file was first saved
        % allow 0.5 min between PDGF addition and the start of imaging
        ii = data.pdgf_between_frame(2); % cycle number/time frame
        ii_str = sprintf(data.index_pattern{2}, ii);
        temp = regexprep(data.first_file, data.index_pattern{1}, ii_str);
        pp = data.path;
    elseif length(data.pdgf_between_frame)==4 % backward compatible with only 2 input
        % from pdgf_between_frame.
        
        % modify file name
        jj = data.pdgf_between_frame(4); % position number
        jj_s = sprintf('_s%d_',jj);
        temp_s = regexprep(temp, '_s1_', jj_s); clear temp;
        temp = temp_s; clear temp_s;
        % modify file path
        jj_p = sprintf('p%d', jj);
        temp_pp = regexprep(pp, strcat('\\','p1','\\'), ...
            strcat('\\',jj_p,'\\')); clear pp;
        pp = temp_pp; clear temp_pp;
    else
        disp('Warning: g2p_init_data - Problem with pdgf_between_frame');
    end
    
    %
    cfp_file = strcat(pp, temp); clear temp;
    
    data.pdgf_time = get_time_2(cfp_file)+ pdgf_time_shift;
    fprintf('pdgf time = %f sec\n', data.pdgf_time);
    disp('g2p_init_data: Update group.data from input group_data. ');

    if save_data
        disp('g2p_init_data: Update data file from input group_data.');
        save(output_file,'data');
    end
elseif exist(output_file, 'file') && load_file % group_data is empty
    disp('g2p_init_data: Update from the data file since there is no input of group data. ');
    res = load(output_file);
    data = res.data;
    % make the old and new format compatible, index --> image_index
    if isfield(data,'index')&&~isfield(data,'image_index')
        if size(data.index,1)>1 % transpose row vectors
            data.image_index = data.index'; 
        else % copy column vectors
            data.image_index = data.index; 
        end
        data = rmfield(data,'index');
        data.index = fluocell_data.index;
    elseif ~isfield(data, 'index')
        data.index = fluocell_data.index;
    end
    if isfield(data,'cfp_channel')
        data = rmfield(data,'cfp_channel');
        data = rmfield(data,'yfp_channel');
    end
    if isfield(data,'first_cfp_file')&&~isfield(data,'first_file')
        data.first_file = strcat(data.path,data.first_cfp_file);
        data = rmfield(data,'first_cfp_file');
    end
    % if there is no prefix and postfix, generate them in the group data
    % structure
    if ~isfield(data, 'prefix') && ~isfield(data, 'postfix')
        [~, name, ext] = fileparts(data.first_file);
        data.prefix = name;
        data.postfix = ext;
        data.first_file = strcat(data.path, data.prefix, data.postfix); 
        clear name ext;
    end
    % Lexie on 05/05/2015
    if ~isfield(data,'output_path')
        data.output_path = fluocell_data.output_path;
    end
    if ~isfield(data,'quantify_roi') || data.quantify_roi == 0
        data.quantify_roi = 3;
        data.num_layers = 3;
    end
    
elseif exist(strcat(fileparts(output_file),'/../p1/output/data.mat'), 'file')
    % For backward compatibility 09/09/2014
    disp('g2p_init_data: Update from the data file since there is no input of group data. ');
    disp('Backward compatible: move data from p1/output/ to output/ ');
    temp = strcat(fileparts(output_file),'/../p1/output/data.mat');
    res = load(temp);
    data = res.data;
    movefile(temp, output_file);
else % ~exist(output_file, 'file') && isemty(group_data) && load_file = 0;
    disp('g2p_init_data: Update from fluocell_data since there is no input of group data or the data file. ');
    disp('g2p_init_data: Please make sure that fluocell is reading images from the p1 position.');
    data.num_layers  = 1;
    data.pdgf_between_frame = fluocell_data.pdgf_between_frame; 
    data.yfp_cbound = [];
    data = fluocell_data;
    
    % delete some data which will cause problems in the quantification
    % stop reading bg_bw info from the first file, Lexie on 2/17/2015
    if isfield(data, 'bg_poly')
        temp = rmfield(data,'bg_poly'); clear data;
        data = rmfield(temp, 'bg_bw'); clear temp;
    end
    % calculate the pdgf_time
    if isfield(data, 'pdgf_between_frame') && ~isempty(data.pdgf_between_frame)
        ii = data.pdgf_between_frame(2);
    else
        ii = 1;
    end
    ii_str = sprintf(data.index_pattern{2}, ii);
    temp = regexprep(data.first_file, data.index_pattern{1}, ii_str);
    pp = data.path;
    %
    if length(data.pdgf_between_frame)>=4 % backward compatible with only 2 input
        % from pdgf_between_frame.
        
        % modify file name
        jj = data.pdgf_between_frame(4); % position number
        jj_s = sprintf('_s%d_',jj);
        temp_s = regexprep(temp, '_s1_', jj_s); clear temp;
        temp = temp_s; clear temp_s;
        % modify file path
        jj_p = sprintf('p%d', jj);
        temp_pp = regexprep(pp, strcat('\\','p1','\\'), ...
            strcat('\\',jj_p,'\\')); clear pp;
        pp = temp_pp; clear temp_pp;
    end
    

%     cfp_file = strcat(pp, temp); clear temp;
    cfp_file = temp; clear temp;
    data.pdgf_time = get_time_2(cfp_file) + pdgf_time_shift;
    fprintf('pdgf time = %f sec\n', data.pdgf_time);
    % save data
    if save_data
        save(output_file, 'data');
    end
end % if ~isempty(group_data),
group.data = data;

return

