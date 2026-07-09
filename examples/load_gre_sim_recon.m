%LOAD_GRE_SIM_RECON Simulate gre.seq on mr0-cloud and FFT recon.
%
%   Uses gre.seq in this examples/ folder.

exampleDir = fileparts(mfilename('fullpath'));
pkgRoot = fileparts(exampleDir);
addpath(pkgRoot);

seqPath = fullfile(exampleDir, 'gre.seq');
if ~isfile(seqPath)
    error('Missing %s', seqPath);
end

[signal, ktraj] = mr0.simulate(seqPath);

fprintf('signal: %d samples, ktraj: %dx%d\n', numel(signal), size(ktraj, 1), size(ktraj, 2));

%% signal and k-traj

figure;
subplot(2, 1, 1);
plot(abs(signal));
title('|signal|');
subplot(2, 2, 3);
plot(ktraj(:, 1), ktraj(:, 2),'.'); 
subplot(2, 2, 4);
plot(ktraj(:, 2), ktraj(:, 3),'.');
title('k-space trajectory');

%% MR image recon of signal (MRzero FLASH notebook port)

Nread=sqrt(numel(signal));  % assume square matrix
Nphase=sqrt(numel(signal)); % assume square matrix

kspace = reshape(signal, [Nread, Nphase]);

spectrum = fftshift(kspace);
space = fft2(spectrum);
space = ifftshift(space);

figure();
subplot(2, 2, 1);
imagesc(flipud(abs(kspace.')));
axis image;
colormap(gca, gray);colorbar;
title('k-space');

subplot(2, 2, 2);
imagesc(flipud(log(abs(kspace.'))));
axis image;
colormap(gca, gray); colorbar;
title('log. k-space');

subplot(2, 2, 3);
imagesc(flipud(abs(space.')));
axis image; 
colormap(gca, gray);colorbar;
title('FFT-magnitude');

subplot(2, 2, 4);
imagesc(flipud(angle(space.')), [-pi, pi]);
axis image; 
colormap(gca, gray);colorbar;
title('FFT-phase');
