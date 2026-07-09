%PROT_SIMPLE Smoke test against the deployed Modal gateway.
%
%   Run from repo root (needs gre.seq on path).

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'MRzerocloud_m'));

seqPath = fullfile(repoRoot, 'gre.seq');
if ~isfile(seqPath)
    error('Missing %s — run from 33_flyio with gre.seq present', seqPath);
end

[signal, ktraj] = mr0.simulate(seqPath);

fprintf('signal: %d samples, ktraj: %dx%d\n', numel(signal), size(ktraj, 1), size(ktraj, 2));

subplot(1, 2, 1);
plot(abs(signal));
title('|signal|');
subplot(1, 2, 2);
plot3(ktraj(:, 1), ktraj(:, 2), ktraj(:, 3), '.');
title('k-space trajectory');
