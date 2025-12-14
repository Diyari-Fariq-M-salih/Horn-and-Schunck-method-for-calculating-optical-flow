clear; clc; close all;

%% 1. CONFIGURATION
folderPath = './Middleburry-data-set/other-data/RubberWhale'; 
filePattern = '*.png'; 

% folderPath = './Road-data-set/Road'; 
% filePattern = '*.pgm'; 

alpha = 20;      
iterations = 80; 
rSize = 5;       
scale = 3;       

% FILTERING PARAMETERS (Exercise 2)
median_window = [5 5]; 

time_smoothness = 0.5; 

%% 2. FILE SETUP

imgFiles = dir(fullfile(folderPath, filePattern));
[~, reindex] = sort({imgFiles.name});
imgFiles = imgFiles(reindex);
numImages = length(imgFiles);

if numImages < 2
    error('Not enough images found in %s', folderPath);
end

fprintf('Processing Ex2: Spatial vs Temporal Filtering...\n');

%% 3. INITIALIZATION

hFig = figure('Name', 'Ex2: Spatial & Temporal Filtering Comparison', ...
              'NumberTitle', 'off', 'Position', [50, 50, 1500, 500]);
set(hFig, 'DoubleBuffer', 'on'); 

u_prev_filtered = [];
v_prev_filtered = [];
u_initial_guess = [];
v_initial_guess = [];

%% 4. MAIN LOOP
for k = 1 : numImages - 1
    
    % --- LOAD IMAGES ---
    im1_rgb = double(imread(fullfile(folderPath, imgFiles(k).name)));
    im2_rgb = double(imread(fullfile(folderPath, imgFiles(k+1).name)));
    
    % Convert to Gray for HS calculation
    if size(im1_rgb, 3) == 3
        im1_gray = 0.2989 * im1_rgb(:,:,1) + 0.5870 * im1_rgb(:,:,2) + 0.1140 * im1_rgb(:,:,3);
        im2_gray = 0.2989 * im2_rgb(:,:,1) + 0.5870 * im2_rgb(:,:,2) + 0.1140 * im2_rgb(:,:,3);
    else
        im1_gray = im1_rgb; im2_gray = im2_rgb;
    end
    
    [u_raw, v_raw] = HS(im1_gray, im2_gray, alpha, iterations, u_initial_guess, v_initial_guess, 0, []);

    u_spatial = medfilt2(u_raw, median_window);
    v_spatial = medfilt2(v_raw, median_window);

    if isempty(u_prev_filtered)

        u_temporal = u_raw;
        v_temporal = v_raw;
    else
        u_temporal = (time_smoothness * u_prev_filtered) + ((1 - time_smoothness) * u_raw);
        v_temporal = (time_smoothness * v_prev_filtered) + ((1 - time_smoothness) * v_raw);
    end
    
    u_prev_filtered = u_temporal;
    v_prev_filtered = v_temporal;
    u_initial_guess = u_temporal; 
    v_initial_guess = v_temporal;


    % --- 4. VISUALIZATION ---
    figure(hFig);
    
    % Function to downsample for nicer plots
    downsampler = @(x) x(1:rSize:end, 1:rSize:end);
    
    % Plot 1: RAW
    subplot(1, 3, 1);
    quiver(downsampler(u_raw), downsampler(v_raw), scale, 'color', 'r');
    set(gca, 'YDir', 'reverse'); axis tight; title('1. Raw Flow (Noisy)');
    
    % Plot 2: SPATIAL (Median)
    subplot(1, 3, 2);
    quiver(downsampler(u_spatial), downsampler(v_spatial), scale, 'color', 'b');
    set(gca, 'YDir', 'reverse'); axis tight; title('2. Spatial Filter (Median)');
    
    % Plot 3: TEMPORAL (Smoothed)
    subplot(1, 3, 3);
    quiver(downsampler(u_temporal), downsampler(v_temporal), scale, 'color', 'g');
    set(gca, 'YDir', 'reverse'); axis tight; title('3. Temporal Filter (Time Smooth)');
    
    drawnow limitrate;
    fprintf('Processed Frame %d/%d\n', k, numImages-1);
end