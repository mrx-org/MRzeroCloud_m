function [signal, ktraj] = readNpzResult(bytes)
%READNPZRESULT Load signal and ktraj arrays from NPZ bytes.
    tmpDir = tempname;
    mkdir(tmpDir);
    cleaner = onCleanup(@() rmdir(tmpDir, 's'));

    zipPath = fullfile(tmpDir, 'result.npz');
    fid = fopen(zipPath, 'w');
    assert(fid > 0);
    fwrite(fid, bytes, 'uint8');
    fclose(fid);

    unzip(zipPath, tmpDir);

    signalPath = fullfile(tmpDir, 'signal.npy');
    ktrajPath = fullfile(tmpDir, 'ktraj.npy');
    if ~isfile(signalPath) || ~isfile(ktrajPath)
        error('mr0:readNpzResult:MissingArrays', 'NPZ must contain signal.npy and ktraj.npy');
    end

    signal = single(readNpy(signalPath));
    ktraj = single(readNpy(ktrajPath));
end
