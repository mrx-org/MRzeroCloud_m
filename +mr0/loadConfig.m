function config = loadConfig(source)
%LOADCONFIG Parse AnyField metadata into a flat config struct.
%
%   config = mr0.loadConfig(jsonText)
%   config = mr0.loadConfig(struct(...))

    defaultBiftiId = 'user/numerical_brain_cropped_bifti';

    if nargin < 1 || isempty(source)
        error('mr0:loadConfig:MissingSource', 'Pass metadata to loadConfig');
    end

    if isstruct(source)
        raw = source;
    elseif ischar(source) || isstring(source)
        raw = jsondecode(char(source));
    else
        error('mr0:loadConfig:InvalidSource', 'Expected JSON text or struct');
    end

    if isfield(raw, 'phantom_bifti') || isfield(raw, 'affine') || isfield(raw, 'res')
        config = raw;
        if ~isfield(config, 'phantom_bifti') || isempty(config.phantom_bifti)
            config.phantom_bifti = defaultBiftiId;
        end
        if ~isfield(config, 'worker') || isempty(config.worker)
            config.worker = 't4';
        end
        return;
    end

    defaultMatrix = [64, 64, 1];

    sim = struct();
    recon = struct();
    if isfield(raw, 'simulation')
        sim = raw.simulation;
    end
    if isfield(raw, 'recon')
        recon = raw.recon;
    end

    if isfield(sim, 'phantom_matrix')
        matrix = sim.phantom_matrix;
    else
        matrix = defaultMatrix;
    end

    if isfield(recon, 'matrix')
        reconMatrix = recon.matrix;
    else
        reconMatrix = matrix;
    end

    config = struct();
    config.phantom_bifti = defaultBiftiId;
    if isfield(sim, 'phantom_bifti') && ~isempty(sim.phantom_bifti)
        config.phantom_bifti = char(string(sim.phantom_bifti));
    elseif isfield(sim, 'phantom') && ~isempty(sim.phantom)
        phantom = sim.phantom;
        if ischar(phantom) || isstring(phantom)
            config.phantom_bifti = char(string(phantom));
        end
    end

    if isfield(sim, 'phantom_fov_affine')
        config.affine = affineFromFlat(sim.phantom_fov_affine);
        config.res = matrix(:)';
    end
    config.recon_matrix = reconMatrix(:)';

    if isfield(sim, 'worker') && ~isempty(sim.worker)
        config.worker = char(string(sim.worker));
    else
        config.worker = 't4';
    end
    if isfield(sim, 'use_gpu')
        config.use_gpu = logical(sim.use_gpu);
    end
    if isfield(sim, 'exact_trajectories')
        config.exact_trajectories = logical(sim.exact_trajectories);
    end
end
