function img = computeColor(u, v)
% COMPUTECOLOR Color encoding of optical flow
% Hue = direction, Saturation = magnitude

nanIdx = isnan(u) | isnan(v);
u(nanIdx) = 0;
v(nanIdx) = 0;

% Compute magnitude and angle
rad = sqrt(u.^2 + v.^2);
angle = atan2(-v, -u) / pi;

% Normalize magnitude
maxrad = max(rad(:));
if maxrad > 0
    rad = rad / maxrad;
end

% HSV components
h = (angle + 1) / 2;
s = min(rad * 8, 1);
v = ones(size(h));

% Convert to RGB
img = hsv2rgb(cat(3, h, s, v));
end
