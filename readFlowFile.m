function [u, v] = readFlowFile(filename)
% READFLOWFILE Read optical flow from Middlebury .flo file
% Returns horizontal (u) and vertical (v) flow components

fid = fopen(filename, 'rb');
if fid < 0
    error('Cannot open flow file.');
end

% Check magic number
tag = fread(fid, 1, 'float32');
if tag ~= 202021.25
    fclose(fid);
    error('Invalid .flo file (wrong tag).');
end

% Read width and height
width  = fread(fid, 1, 'int32');
height = fread(fid, 1, 'int32');

% Read flow data
data = fread(fid, [2*width, height], 'float32');
fclose(fid);

% Reshape
data = reshape(data, [2, width, height]);
data = permute(data, [3 2 1]);

u = data(:,:,1);
v = data(:,:,2);
end
