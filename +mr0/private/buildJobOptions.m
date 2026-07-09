function options = buildJobOptions(config, accuracy, useGpu, exactTrajectories, worker)
%BUILDJOBOPTIONS JSON options payload for POST /v1/jobs.
    if nargin < 2 || isempty(accuracy)
        accuracy = 1e-5;
    end
    if nargin < 3 || isempty(useGpu)
        useGpu = true;
    end
    if nargin < 4 || isempty(exactTrajectories)
        exactTrajectories = true;
    end

    options = struct();
    options.exact_trajectories = logical(exactTrajectories);
    options.accuracy = double(accuracy);

    phantom = struct( ...
        'type', 'bifti', ...
        'id', phantomBiftiId(config) ...
    );

    if isfield(config, 'res') && ~isempty(config.res)
        res = config.res(:)';
        if numel(res) ~= 3
            error('mr0:buildJobOptions:InvalidRes', 'config.res must be [x, y, z]');
        end
        if ~isfield(config, 'affine') || isempty(config.affine)
            error('mr0:buildJobOptions:MissingAffine', ...
                'config.affine is required when config.res is set');
        end
        affine = config.affine;
        if size(affine, 1) ~= 3 || size(affine, 2) ~= 4
            error('mr0:buildJobOptions:InvalidAffine', 'config.affine must be 3x4');
        end
        phantom.res = res;
        phantom.affine = affine;
    end

    options.phantom = phantom;

    if nargin >= 5 && ~isempty(worker)
        options.worker = char(worker);
    else
        options.use_gpu = logical(useGpu);
    end
end
