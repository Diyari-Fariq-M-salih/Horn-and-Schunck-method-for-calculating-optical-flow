function quiver_uv(u, v)

    % Resize u and v so we can actually see something in the quiver plot
    scalefactor = 50 / size(u, 2);
    u_ = scalefactor * imresize(u, scalefactor, 'bilinear');
    v_ = scalefactor * imresize(v, scalefactor, 'bilinear');

    % Run quiver taking into account MATLAB coordinate system quirks
    % and scale the magnitude of (u, v) by 2 for visibility.
    quiver(u_(end:-1:1, :), -v_(end:-1:1, :), 2);
    axis('tight');

end
