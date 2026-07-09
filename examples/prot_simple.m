%PROT_SIMPLE Smoke test against mr0-cloud with simple FFT recon.
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

figure;
subplot(1, 2, 1);
plot(abs(signal));
title('|signal|');
subplot(1, 2, 2);
plot3(ktraj(:, 1), ktraj(:, 2), ktraj(:, 3), '.');
title('k-space trajectory');

%% S6: MR image recon of signal (MRzero FLASH notebook port)
[Nread, Nphase, permvec] = recoParamsFromSeq(seqPath, numel(signal));

kspace = reshape(signal, [Nread, Nphase]);
[~, ipermvec] = sort(permvec(:) + 1);
kspace = kspace(:, ipermvec);

spectrum = fftshift(kspace, [1 2]);
space = fft2(spectrum);
space = ifftshift(space, [1 2]);

figure('Position', [100 100 1000 220]);
subplot(1, 4, 1);
imagesc(abs(kspace));
axis image off;
colormap(gca, gray);
title('k-space');
subplot(1, 4, 2);
imagesc(log(abs(kspace)));
axis image off;
colormap(gca, gray);
title('log. k-space');
subplot(1, 4, 3);
imagesc(abs(space));
axis image off;
colormap(gca, gray);
title('FFT-magnitude');
colorbar;
subplot(1, 4, 4);
imagesc(angle(space), [-pi, pi]);
axis image off;
colormap(gca, gray);
title('FFT-phase');
colorbar;

function [Nread, Nphase, permvec] = recoParamsFromSeq(seqPath, numSamples)
    txt = fileread(seqPath);
    Nread = parseFirstAdcNumSamples(txt);
    Nphase = countAdcBlocks(txt);
    if isempty(Nread) || Nphase == 0
        error('prot_simple:SeqParse', 'Could not parse ADC layout from %s', seqPath);
    end
    if Nread * Nphase ~= numSamples
        error('prot_simple:SeqParse', ...
            'Signal length %d != %d x %d from seq', numSamples, Nread, Nphase);
    end
    permvec = parsePermvecDefinition(txt);
    if isempty(permvec)
        permvec = (0:Nphase - 1)'; % identity order (0-based, as in FLASH notebook)
    end
end

function nread = parseFirstAdcNumSamples(txt)
    nread = [];
    inAdc = false;
    for line = splitlines(string(txt))
        line = strtrim(line);
        if line == "[ADC]"
            inAdc = true;
            continue;
        end
        if startsWith(line, "[") && inAdc
            return;
        end
        if ~inAdc || strlength(line) == 0 || startsWith(line, "#")
            continue;
        end
        parts = sscanf(char(line), '%f');
        if numel(parts) >= 2 && parts(1) == 1
            nread = parts(2);
            return;
        end
    end
end

function nphase = countAdcBlocks(txt)
    nphase = 0;
    inBlocks = false;
    for line = splitlines(string(txt))
        line = strtrim(line);
        if line == "[BLOCKS]"
            inBlocks = true;
            continue;
        end
        if startsWith(line, "[") && inBlocks
            return;
        end
        if ~inBlocks || strlength(line) == 0 || startsWith(line, "#")
            continue;
        end
        vals = sscanf(char(line), '%f');
        if numel(vals) >= 7 && vals(7) ~= 0
            nphase = nphase + 1;
        end
    end
end

function permvec = parsePermvecDefinition(txt)
    permvec = [];
    inDefs = false;
    for line = splitlines(string(txt))
        line = strtrim(line);
        if line == "[DEFINITIONS]"
            inDefs = true;
            continue;
        end
        if startsWith(line, "[") && inDefs
            return;
        end
        if ~inDefs || strlength(line) == 0 || startsWith(line, "#")
            continue;
        end
        if startsWith(line, "permvec")
            vals = sscanf(char(line), '%f');
            permvec = vals(2:end).';
            return;
        end
    end
end
