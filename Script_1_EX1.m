clear; clc; close all;

%% 1. CONFIGURATION
folderPath = './Road-data-set/Road'; 
filePattern = '*.pgm'; 

% folderPath = './Middleburry-data-set/other-data/RubberWhale';
% filePattern = '*.png'; 

alpha = 10;      % Smoothness
iterations = 50; % Iterations per frame
rSize = 5;       % Resolution of vectors
scale = 3;       % Arrow length scale factor

%% 2. FILE SETUP
imgFiles = dir(fullfile(folderPath, filePattern));

[~, reindex] = sort({imgFiles.name});
imgFiles = imgFiles(reindex);

numImages = length(imgFiles);

if numImages < 2
    error('Not enough images in the directory to calculate flow.');
end

fprintf('Found %d images. Starting processing...\n', numImages);

%% 3. INITIALIZATION

hFig = figure('Name', 'Optical Flow Vector Field', 'NumberTitle', 'off');
set(hFig, 'DoubleBuffer', 'on'); 

u = [];
v = [];

%% 4. MAIN LOOP

for k = 1 : numImages - 1
    
    % A. Load Consecutive Frames
    f1_name = fullfile(folderPath, imgFiles(k).name);
    f2_name = fullfile(folderPath, imgFiles(k+1).name);
    
    im1 = imread(f1_name);
    im2 = imread(f2_name);
    
    [u, v] = HS(im1, im2, alpha, iterations, [], [], 0, []);

    u_plot = u;
    v_plot = v;
    
    for r = 1:size(u_plot,1)
        for c = 1:size(u_plot,2)
            if floor(r/rSize)~=r/rSize || floor(c/rSize)~=c/rSize
                u_plot(r,c) = 0;
                v_plot(r,c) = 0;
            end
        end
    end
    
    % D. Visualization
    figure(hFig); 

    clf; 
    
    quiver(u_plot, v_plot, scale, 'color', 'b', 'linewidth', 1.5);
    
    % Visual formatting
    set(gca, 'YDir', 'reverse'); 
    axis tight; 
    axis on; 
    grid on;
    title(sprintf('Flow: Frame %d -> %d', k, k+1));
    
    drawnow limitrate; 
    
    fprintf('Processed Frame %d/%d\n', k, numImages-1);
end

fprintf('Sequence completed.\n');