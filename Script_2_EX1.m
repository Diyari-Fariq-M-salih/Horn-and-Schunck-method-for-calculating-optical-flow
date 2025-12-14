clear; clc; close all;

%% 1. CONFIGURATION
% folderPath = './Middleburry-data-set/other-data/RubberWhale'; 
% filePattern = '*.png'; 

folderPath = './Road-data-set/Road'; 
filePattern = '*.pgm'; 

alpha = 20;      
iterations = 100; 
rSize = 5;       
scale = 3;      

%% 2. FILE SETUP
imgFiles = dir(fullfile(folderPath, filePattern));
[~, reindex] = sort({imgFiles.name});
imgFiles = imgFiles(reindex);
numImages = length(imgFiles);

if numImages < 2
    error('Not enough images found in %s', folderPath);
end

fprintf('Found %d images. Starting...\n', numImages);

%% 3. INITIALIZATION
hFig = figure('Name', 'Optical Flow Station', 'NumberTitle', 'off', 'Position', [50, 50, 1200, 800]);
set(hFig, 'DoubleBuffer', 'on'); 

u = [];
v = [];

%% 4. MAIN LOOP
for k = 1 : numImages - 1
    
    im1_rgb = double(imread(fullfile(folderPath, imgFiles(k).name)));
    im2_rgb = double(imread(fullfile(folderPath, imgFiles(k+1).name)));
   
    if size(im1_rgb, 3) == 3
        im1_gray = 0.2989 * im1_rgb(:,:,1) + 0.5870 * im1_rgb(:,:,2) + 0.1140 * im1_rgb(:,:,3);
        im2_gray = 0.2989 * im2_rgb(:,:,1) + 0.5870 * im2_rgb(:,:,2) + 0.1140 * im2_rgb(:,:,3);
    else
        im1_gray = im1_rgb;
        im2_gray = im2_rgb;
    end
    
    [u, v] = HS(im1_gray, im2_gray, alpha, iterations, u, v, 0, []);


    im2_warped = warpImage(im2_rgb, u, v);
    

    if size(im1_rgb,3) == 3
        im2_warped_gray = 0.2989 * im2_warped(:,:,1) + 0.5870 * im2_warped(:,:,2) + 0.1140 * im2_warped(:,:,3);
        residual = abs(im1_gray - im2_warped_gray);
    else
        residual = abs(im1_gray - im2_warped);
    end
    mean_error = mean(residual(:));

    u_plot = u; v_plot = v;
    for r = 1:size(u_plot,1)
        for c = 1:size(u_plot,2)
            if floor(r/rSize)~=r/rSize || floor(c/rSize)~=c/rSize
                u_plot(r,c) = 0; v_plot(r,c) = 0;
            end
        end
    end
    
    % 2. Create Color Flow Map
    mag = sqrt(u.^2 + v.^2);
    ang = atan2(v, u); 
    hue = (ang + pi) / (2*pi);
    sat = min(mag / 4, 1); 
    val = ones(size(mag));
    rgb_flow = hsv2rgb(cat(3, hue, sat, val));
    rgb_flow = rgb_flow .* (mag > 0.1);
    
    figure(hFig);
    
    % Top Left: Vector Field
    subplot(2,2,1);
    imshow(uint8(im1_rgb)); hold on;
    quiver(u_plot, v_plot, scale, 'color', 'g', 'linewidth', 1);
    title(sprintf('Vectors: %s', imgFiles(k).name), 'Interpreter', 'none');
    hold off;

    % Top Right: Color Flow
    subplot(2,2,2);
    imshow(rgb_flow);
    title('Color Flow (Hue=Dir, Sat=Mag)');
    
    % Bottom Left: Motion Components
    subplot(2,2,3);
    imagesc([u, v]); 
    colormap(gca, 'jet'); colorbar;
    title('Components: Left=U, Right=V');
    axis on;
    grid on;
    
    % Bottom Right: Residual Error
    subplot(2,2,4);
    imagesc(residual, [0 50]);
    colormap(gca, 'hot'); 
    title(sprintf('Warp Error (Mean: %.2f)', mean_error));
    axis off;

    drawnow limitrate;
    fprintf('Processed Frame %d/%d | Mean Error: %.2f\n', k, numImages-1, mean_error);
end
fprintf('Done.\n');


%% HELPER FUNCTION: ROBUST WARP
function warped = warpImage(im, u, v)

    [h, w, channels] = size(im);

    [xx, yy] = meshgrid(1:w, 1:h);

    xx_sample = xx + u;
    yy_sample = yy + v;

    warped = zeros(size(im));
    
    for c = 1:channels
        warped(:,:,c) = interp2(xx, yy, im(:,:,c), xx_sample, yy_sample, 'linear', 0);
    end
    
    % Clean up NaNs
    warped(isnan(warped)) = 0;
end