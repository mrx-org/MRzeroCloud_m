function [signal, ktraj] = readNpzResult(bytes)
%READNPZRESULT Load signal and ktraj arrays from NPZ bytes.
    tmpDir = tempname;
    mkdir(tmpDir);
    cleaner = onCleanup(@() rmdir(tmpDir, 's'));

    zipPath = fullfile(tmpDir, 'result.npz');
    fid = fopen(zipPath, 'w');
    if fid < 0
        error('mr0:readNpzResult:WriteFailed', 'Could not write temporary NPZ');
    end
    fwrite(fid, bytes, 'uint8');
    fclose(fid);

    unzip(zipPath, tmpDir);

    signalPath = locateNpy(tmpDir, 'signal.npy');
    ktrajPath = locateNpy(tmpDir, 'ktraj.npy');

    signal = single(readNpy(signalPath));
    ktraj = single(readNpy(ktrajPath));
end

function path = locateNpy(root, leafName)
    listing = dir(fullfile(root, '**', leafName));
    if isempty(listing)
        error('mr0:readNpzResult:MissingArrays', 'NPZ must contain %s', leafName);
    end
    path = fullfile(listing(1).folder, listing(1).name);
end
