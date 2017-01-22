% function path_i = get_path_i( pa, name, name_i )
% Replace the folder name in the path pa with the
% folder name_i .
%
% Example:
% >> pa = 'D:/doc/paper/2016/fluocell_1221/data/fig3/6position/p1/';
% >> path_i = set_path_i(pa, 'p1', 'p2')
% Replace the folder name '/p1/' with '/p2/'.
% 
function path_i = set_path_i( pa, name, name_i )
    temp = regexprep(pa, ['\/', name, '\/'], ['\/', name_i, '\/']); 
    path_i = regexprep(temp, ['\\', name, '\\'], ['\\', name_i, '\\']);
end

