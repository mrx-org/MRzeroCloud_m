function [signal, ktraj] = simulate(seqPath, varargin)
%SIMULATE Run MRI simulation via tool-mr0sim-modal_http.
%
%   [signal, ktraj] = mr0.simulate('gre.seq')              % default cached phantom
%   [signal, ktraj] = mr0.simulate('gre.seq', 'Worker', 'a10g')
%   [signal, ktraj] = mr0.simulate('gre.seq', 'Config', config)
%
%   Name/value pairs:
%     Config              - flat config struct (see loadConfig / defaultConfig);
%                           omitted → user/numerical_brain_cropped_bifti from cache
%     Accuracy            - simulation accuracy (default 1e-5)
%     UseGpu              - legacy: false → cpu when Worker omitted (default true → t4)
%     ExactTrajectories   - exact k-space trajectories (default true)
%     Worker              - Modal worker tier: cpu, t4, a10g, a100 (default t4)
%     BaseUrl             - override configured modal URL for this call
%     NoiseLevel          - optional complex Gaussian noise scale
%
%   Returns
%     signal - complex single ADC samples (column vector)
%     ktraj  - single k-space trajectory (N×3)

    p = inputParser;
    p.addRequired('seqPath', @(x) ischar(x) || isstring(x));
    p.addParameter('Config', [], @(x) isempty(x) || isstruct(x));
    p.addParameter('Accuracy', 1e-5, @(x) isnumeric(x) && isscalar(x));
    p.addParameter('UseGpu', [], @(x) isempty(x) || isnumeric(x) || islogical(x));
    p.addParameter('ExactTrajectories', [], @(x) isempty(x) || isnumeric(x) || islogical(x));
    p.addParameter('Worker', '', @(x) ischar(x) || isstring(x));
    p.addParameter('BaseUrl', '', @(x) ischar(x) || isstring(x));
    p.addParameter('NoiseLevel', 0, @(x) isnumeric(x) && isscalar(x));
    parse(p, seqPath, varargin{:});

    seqPath = char(seqPath);
    if isempty(p.Results.Config)
        config = defaultConfig(seqPath);
    else
        config = p.Results.Config;
    end

    useGpu = true;
    if ~isempty(p.Results.UseGpu)
        useGpu = logical(p.Results.UseGpu);
    elseif isfield(config, 'use_gpu')
        useGpu = logical(config.use_gpu);
    end

    exactTrajectories = true;
    if ~isempty(p.Results.ExactTrajectories)
        exactTrajectories = logical(p.Results.ExactTrajectories);
    elseif isfield(config, 'exact_trajectories')
        exactTrajectories = logical(config.exact_trajectories);
    end

    worker = char(strtrim(string(p.Results.Worker)));
    if strlength(worker) == 0 && isfield(config, 'worker') && ~isempty(config.worker)
        worker = char(string(config.worker));
    end
    if strlength(worker) == 0
        if ~useGpu
            worker = 'cpu';
        else
            worker = 't4';
        end
    end

    if strlength(string(p.Results.BaseUrl)) > 0
        baseUrl = char(strtrim(string(p.Results.BaseUrl)));
    else
        baseUrl = getModalUrl();
    end

    packageState('resetabort');

    options = buildJobOptions( ...
        config, ...
        p.Results.Accuracy, ...
        useGpu, ...
        exactTrajectories, ...
        worker ...
    );

    if ~onProgress(sprintf('modal: submitting %s → %s', seqPath, baseUrl))
        error('mr0:SimulationAborted', 'modal simulation aborted by client');
    end

    jobId = submitJob(baseUrl, seqPath, options);

    if ~onProgress(sprintf('modal: job %s', jobId))
        abortJob(baseUrl, jobId);
        error('mr0:SimulationAborted', 'modal simulation aborted by client');
    end

    pollJob(baseUrl, jobId);
    [signal, ktraj] = fetchResult(baseUrl, jobId);

    if ~onProgress('modal: complete')
        error('mr0:SimulationAborted', 'modal simulation aborted by client');
    end

    if p.Results.NoiseLevel > 0
        noise = p.Results.NoiseLevel * (randn(size(signal)) + 1i * randn(size(signal)));
        signal = signal + single(noise);
    end
end
