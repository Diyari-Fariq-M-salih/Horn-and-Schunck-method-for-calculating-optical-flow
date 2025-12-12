% Parameters
alpha = 1;
nIter = 200;

% Read first frame
I0 = double(imread('0000.pgm'));

figure(2);

for cptImage = 1:199
    
    % Filename formatting
    if cptImage < 10
        nom = sprintf('000%d.pgm', cptImage);
    elseif cptImage < 100
        nom = sprintf('00%d.pgm', cptImage);
    else
        nom = sprintf('0%d.pgm', cptImage);
    end
    
    % Read next frame
    I1 = double(imread(nom));
    
    % --- Optical flow computation ---
    [u, v] = horn_schunck(I0, I1, alpha, nIter);
    
    % Left: original image
    subplot(1,2,1);
    imshow(mat2gray(I1));
    title('Road image');

    % Right: optical flow vectors
    subplot(1,2,2);
    quiver_uv(u, v);
    title('Optical flow vectors');

    drawnow;

end
