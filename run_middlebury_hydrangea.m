clc;
clear;
close all;

%% -------- Paths --------
imgPath = 'Middleburry-data-set/other-data/Hydrangea/';
gtPath  = 'Middleburry-data-set/other-gt-flow/Hydrangea/';

%% -------- Read correct image pair --------
I1 = imread(fullfile(imgPath, 'frame10.png'));
I2 = imread(fullfile(imgPath, 'frame11.png'));

% Convert to grayscale if needed
if size(I1,3) == 3
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
end

I1 = double(I1);
I2 = double(I2);

%% -------- Horn–Schunck parameters --------
alpha = 1.0;
nIter = 300;

%% -------- Compute optical flow --------
[u, v] = horn_schunck(I1, I2, alpha, nIter);

%% -------- Load ground truth flow --------
[ug, vg] = readFlowFile(fullfile(gtPath, 'flow10.flo'));

%% -------- Resize if necessary (safety) --------
if ~isequal(size(u), size(ug))
    u = imresize(u, size(ug));
    v = imresize(v, size(vg));
end

%% -------- Visualization --------
figure;

subplot(1,3,1);
imshow(mat2gray(I1));
title('Hydrangea frame10');

subplot(1,3,2);
imshow(computeColor(u, v));
title('Estimated flow (Horn–Schunck)');

subplot(1,3,3);
imshow(computeColor(ug, vg));
title('Ground truth flow');

sgtitle('Middlebury Hydrangea – frame10 → frame11');

step = 10;     % spacing between vectors
scale = 200;     % arrow length scaling

figure;

% --- Estimated flow ---
subplot(1,2,1);
imshow(mat2gray(I1)); hold on;
quiver( ...
    u(1:step:end, 1:step:end) * scale, ...
    v(1:step:end, 1:step:end) * scale, ...
    'r');
title('Estimated flow (Horn–Schunck)');
axis tight;

% --- Ground truth flow ---
subplot(1,2,2);
imshow(mat2gray(I1)); hold on;
quiver( ...
    ug(1:step:end, 1:step:end) * scale, ...
    vg(1:step:end, 1:step:end) * scale, ...
    'g');
title('Ground truth flow');
axis tight;

