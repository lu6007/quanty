% Compute the time course of FRET ratio for a single cell
% 
% Example:
% See g2p_quantify() for details.

% Copyright: Shaoying Lu and Yingxiao Wang 2013 
% Email: shaoying.lu@gmail.com

function [time, value, data] = compute_time_course(cell_name, data, varargin)

display(sprintf('Cell Name : %s',cell_name));
parameter_name = {'save_file', 'load_file', 'subplot_position', 'compute_cell_size'};
default_value = {1, 1, 0, 1, 0};
[save_file, load_file, subplot_position, compute_cell_size] =...
    parse_parameter(parameter_name, default_value, varargin);


output_path = strcat(data.path, 'output/');
if isfield(data, 'output_path'),
    data.output_path = output_path;
end
out_file = strcat(output_path, 'result.mat');
if ~exist(out_file,'file') || load_file ==0,

    %%% Interface with fluocell %%%
    data = batch_update_figure(data);
    fret_ratio = data.ratio;
    cfp_intensity = data.channel1;
    yfp_intensity = data.channel2;
    this_image_index = data.image_index;
    cfp_background = data.channel1_bg;
    yfp_background = data.channel2_bg;
    
    % skip deleted frames when plot, Lexie on 2/19/2015
    [~,NAME,EXT] = fileparts(data.first_file);
    first_channel_file = strcat(NAME, EXT);
    for i = data.image_index,
        index = sprintf(data.index_pattern{2}, i);       
        current_file = regexprep(first_channel_file, data.index_pattern{1}, index);
        time(i) = get_time_2(strcat(data.path, current_file));
        if i >= 2 && time(i) >= 0 && time(i) < time(i - 1)
            time(i) = time(i) + 24 * 60;
        end;
        clear index current_file
    end; 
    clear first_channel_file NAME EXT 
    ii = (time > -1);
    temp = this_image_index(ii); clear this_image_index;
    this_image_index = temp; clear temp;
    % 2/19/2015
    
    if compute_cell_size,
        cell_size = data.cell_size;
    end;

    % time in minutes PDGF was added 30 seconds before frame (after_pdgf)
    if isfield(data,'pdgf_time'),
        pdgf_time = data.pdgf_time;
    elseif isfield(data, 'pdgf_between_frame'),
        after_pdgf = data.pdgf_between_frame(2);
        %%% Note that pdgf time is only correct for position 1, but not
        %%% accurate for all the rest of positions. 03/04/2014
        pdgf_time = data.time(after_pdgf)+30/60;
    else % no pdgf was added
        pdgf_time = data.time(1)-0.5; % consistent with g2p_init_data
    end;
    time = data.time - pdgf_time; 

    if save_file,
        if compute_cell_size,
            save(out_file, 'time', 'cfp_intensity', 'yfp_intensity', 'fret_ratio','this_image_index',...
                'cfp_background', 'yfp_background', 'cell_size');
        else
            save(out_file, 'time', 'cfp_intensity', 'yfp_intensity', 'fret_ratio','this_image_index',...
                'cfp_background', 'yfp_background');
        end;

    end;
else % if exist(out_file, 'file') && load_file
    res = load(out_file);
    time = res.time;
    % Lexie on 2/18/2015
    cfp_intensity = res.cfp_intensity;
    yfp_intensity = res.yfp_intensity;
    fret_ratio = res.fret_ratio;
    cfp_background = res.cfp_background;
    yfp_background = res.yfp_background;
    if compute_cell_size,
        cell_size = res.cell_size;
    end;
end;

clear path output_path;


%% Plotting the quantifications.

%%% Configuring the subplots. %%%
if subplot_position,
    enable_subplot = 1;
    if ~compute_cell_size,
        num_figures = 4;
    else
        num_figures = 5;
    end;
    subm = 2; % number of rows
    subn = 3; % number of columns
    fn = 2+floor((subplot_position-1)/(subm*subn))*num_figures;
    subplot_position = mod(subplot_position-1, subm*subn)+1;
else
    enable_subplot = 0;
end;



%%% cfp and yfp Intensities over Index figure. %%%
if ~enable_subplot,
    figure; 
else
    figure(fn+1); subplot(subm,subn,subplot_position);
end;
% make the font and size more fit for publications
set(gca,'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold');
set(findall(gcf,'type','text'),'FontSize', 12,'FontName','Arial', 'Fontweight', 'bold');
hold on;

%Problem: cfp_intensity always seems to be AT LEAST two cells long,
%irrespective of the actual number of objects in an image.
%Current workaround: set num_objects based on the fret_ratio, which seems to
%reliably reflect the actual number of objects in an image. -Shannon 8/10/2016
% num_objects = length(cfp_intensity);
num_objects = length(fret_ratio);
for i = 1:num_objects
    plot(this_image_index, cfp_intensity{i}(this_image_index,1), 'b','LineWidth',2); 
    plot(this_image_index, yfp_intensity{i}(this_image_index,1), 'g','LineWidth',2);
end
plot(this_image_index, cfp_background(this_image_index), 'b--','LineWidth',2);
plot(this_image_index, yfp_background(this_image_index), 'g--', 'LineWidth',2);  
    
% plot(this_image_index, cfp_intensity{1, 1}(this_image_index,1), 'b','LineWidth',2); 
% plot(this_image_index, yfp_intensity{1, 1}(this_image_index,1), 'g','LineWidth',2);
% plot(this_image_index, cfp_background(this_image_index), 'b--','LineWidth',2);
% plot(this_image_index, yfp_background(this_image_index), 'g--', 'LineWidth',2);

%Set title and legend for figure.
title(regexprep(cell_name,'_','\\_'));
xlabel('Index'); ylabel('Intensity');
legend('1^{st} FI','2^{nd} FI','1^{st} FI BG', '2^{nd} FI BG');



%%% Index over time figure. %%%
if ~enable_subplot,
    figure; 
else
    figure(fn+2); subplot(subm,subn,subplot_position);
end;
set(gca,'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
set(findall(gcf,'type','text'),'FontSize',12,'FontName','Arial', 'Fontweight', 'bold');
hold on;
% plot(time(data.image_index,2), 'LineWidth',2);
plot(time(:, 2), 'LineWidth',2);
title(regexprep(cell_name,'_','\\_'));
xlabel('Index'); ylabel('Time (min)');



%%% Intensity Ratio over Index figure. %%%
if ~enable_subplot,
    figure; 
else
    figure(fn+3); subplot(subm,subn,subplot_position);
end;
set(gca,'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
set(findall(gcf,'type','text'),'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
hold on;

%Created for loop to manage plotting multiple objects. - Shannon 8/9/2016
%Converts from fret_ratio's cell data type to a double data type and also
%shrinks the matrix to match this_image_index's size so it will plot correctly.
%Preallocation of matrix space for this_fret_ratio.
num_image_indices = length(this_image_index);
num_objects = length(fret_ratio);
this_fret_ratio = inf(num_image_indices,num_objects);
%Assigns the corresponding fret_ratio value to the matrix.
for i = 1:num_objects
    this_fret_ratio(:,i) = fret_ratio{i}(this_image_index,1);
end

% Assumes only 1 or 2 objects for now.
% Plan to expand to have a loop for n-objects.
% num_objects = length(fret_ratio);
% if num_objects == 1,
%     this_fret_ratio = fret_ratio{1}(this_image_index, 1);
% else % num_objects == 2
%     this_fret_ratio = [fret_ratio{1}(this_image_index, 1), fret_ratio{2}(this_image_index, 1)];
% end;

plot(this_image_index, this_fret_ratio, 'r','LineWidth',2);
%plot(this_image_index, fret_ratio{1}(this_image_index, 1), 'r','LineWidth',2);
title(regexprep(cell_name,'_','\\_'));
% xlabel('Index'); ylabel('ECFP/FRET Ratio');
% change the name of the figure 
xlabel('Index'); ylabel('Intensity Ratio');



%%% Intensity Ratio over Time (min) figure. %%%
if ~enable_subplot,
    figure; 
else
    figure(fn+4); subplot(subm,subn,subplot_position);
end;
set(gca,'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
set(findall(gcf,'type','text'),'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
hold on;
plot(time(this_image_index, 2), this_fret_ratio, 'r','LineWidth',2);
title(regexprep(cell_name,'_','\\_'));
xlabel('Time (min)'); ylabel('Intensity Ratio');
clear this_fret_ratio;



%%%%%%%%10/21/2014 lexie plot cell size change
if compute_cell_size,
    if ~enable_subplot,
        figure;
    else
        figure(fn+5); subplot(subm,subn,subplot_position);
    end;
    set(gca,'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
    set(findall(gcf,'type','text'),'FontSize',12,'FontName','Arial', 'Fontweight', 'bold')
    hold on;
    % plot(this_image_index, cell_size{1}(this_image_index, 1), 'r', 'LineWidth', 2);
    this_cell_size = [cell_size{1}(this_image_index, 1), cell_size{2}(this_image_index, 1)];
    plot(this_image_index, this_cell_size, 'r','LineWidth',2);
    title(regexprep(cell_name,'_','\\_'));
    xlabel('Index'); ylabel('Cell Size');
end;

%% output
temp = time(this_image_index); clear time;
time = temp;
value = fret_ratio{1}(this_image_index); 
beep;
return;