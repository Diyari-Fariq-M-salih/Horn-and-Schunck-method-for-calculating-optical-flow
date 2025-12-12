function [u, v] = horn_schunck(I1, I2, alpha, nIter)
% HORN_SCHUNCK Computes optical flow using Horn–Schunck method
% I1, I2 : consecutive grayscale images (double)
% alpha  : regularization parameter
% nIter  : number of iterations

% Convert images to double
I1 = double(I1);
I2 = double(I2);

%  Spatial and temporal gradients
kernel_x = 0.25 * [-1 1; -1 1];
kernel_y = 0.25 * [-1 -1; 1 1];
kernel_t = 0.25 * [1 1; 1 1];

Ix = conv2(I1 + I2, kernel_x, 'same');
Iy = conv2(I1 + I2, kernel_y, 'same');
It = conv2(I2 - I1, kernel_t, 'same');

% Initialization 
u = zeros(size(I1));
v = zeros(size(I1));

% Laplacian averaging kernel
kernel_lap = [1/12 1/6 1/12;
              1/6   0   1/6;
              1/12 1/6 1/12];

%  Iterative minimization 
for k = 1:nIter
    
    % Local averages
    u_bar = conv2(u, kernel_lap, 'same');
    v_bar = conv2(v, kernel_lap, 'same');
    
    % Common term
    P = Ix .* u_bar + Iy .* v_bar + It;
    D = alpha^2 + Ix.^2 + Iy.^2;
    
    % Update flow
    u = u_bar - Ix .* P ./ D;
    v = v_bar - Iy .* P ./ D;
end

end
