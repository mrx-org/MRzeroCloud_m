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
    import java.io.ByteArrayOutputStream
    import java.util.zip.ZipInputStream

    entries = struct();
    bais = ByteArrayInputStream(uint8(npzBytes(:)));
    zis = ZipInputStream(bais);
    entry = zis.getNextEntry();
    buffer = javaArray('byte', 8192);

    while ~isempty(entry)
        name = char(entry.getName());
        baseName = char(java.io.File(name).getName());
        payload = readZipEntryBytes(zis, buffer);

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

function bytes = readZipEntryBytes(zis, buffer)
    import java.io.ByteArrayOutputStream

    baos = ByteArrayOutputStream();
    n = zis.read(buffer);
    while n > 0
        baos.write(buffer, 0, n);
        n = zis.read(buffer);
    end
    bytes = typecast(baos.toByteArray(), 'uint8');
end
