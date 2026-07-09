function config = defaultConfig(~)
%DEFAULTCONFIG Standalone defaults for modal HTTP simulation.
%
%   Uses cached single-slice bifti phantom user/numerical_brain_cropped_bifti.
%   res/affine match the phantom's native NIfTI grid (gateway requires both on
%   bifti jobs; no FOV change from the cached geometry).

    config = struct();
    config.phantom_bifti = 'user/numerical_brain_cropped_bifti';
    config.res = [141, 161, 1];
    config.affine = [
        1.418, 0.0, 0.0, -100.0;
        0.0, 1.242, 0.0, -100.0;
        0.0, 0.0, 8.0, -4.0
    ];
    config.worker = 't4';
    config.exact_trajectories = true;
end
