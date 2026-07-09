function [signal, ktraj] = readNpzResult(bytes)
%READNPZRESULT Load signal and ktraj arrays from NPZ bytes.
    entries = extractNpzEntries(bytes);

    if ~isfield(entries, 'signal') || isempty(entries.signal)
        error('mr0:readNpzResult:MissingArrays', 'NPZ must contain signal.npy');
    end
    if ~isfield(entries, 'ktraj') || isempty(entries.ktraj)
        error('mr0:readNpzResult:MissingArrays', 'NPZ must contain ktraj.npy');
    end

    signal = single(readNpy(entries.signal));
    ktraj = single(readNpy(entries.ktraj));
end

function entries = extractNpzEntries(npzBytes)
    import java.io.ByteArrayInputStream
    import java.util.zip.ZipInputStream

    entries = struct();
    bais = ByteArrayInputStream(uint8(npzBytes(:)));
    zis = ZipInputStream(bais);
    entry = zis.getNextEntry();

    while ~isempty(entry)
        baseName = char(java.io.File(char(entry.getName())).getName());
        payload = readZipEntryBytes(zis);

        if strcmp(baseName, 'signal.npy')
            entries.signal = payload;
        elseif strcmp(baseName, 'ktraj.npy')
            entries.ktraj = payload;
        end

        zis.closeEntry();
        entry = zis.getNextEntry();
    end
    zis.close();
end

function bytes = readZipEntryBytes(zis)
    import java.io.ByteArrayOutputStream

    baos = ByteArrayOutputStream();
    nextByte = zis.read();
    while nextByte >= 0
        baos.write(nextByte);
        nextByte = zis.read();
    end
    bytes = typecast(baos.toByteArray(), 'uint8');
end
