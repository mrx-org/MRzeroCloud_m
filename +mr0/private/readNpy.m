function arr = readNpy(filename)
%READNPY Minimal NumPy .npy reader for float32/complex64 arrays.
    fid = fopen(filename, 'rb');
    assert(fid > 0, 'Could not open %s', filename);
    cleaner = onCleanup(@() fclose(fid));

    magic = fread(fid, 6, '*char')';
    if ~startsWith(magic, char(147))
        error('mr0:readNpy:BadMagic', 'Not a .npy file: %s', filename);
    end

    ver = fread(fid, 2, 'uint8');
    if ver(1) == 1
        headerLen = fread(fid, 1, 'uint16');
    else
        headerLen = fread(fid, 1, 'uint32');
    end
    header = fread(fid, headerLen, '*char')';

    descrTok = regexp(header, '''descr''\s*:\s*''([^'']+)''', 'tokens', 'once');
    if isempty(descrTok)
        error('mr0:readNpy:MissingDescr', 'Missing dtype in %s', filename);
    end
    descr = descrTok{1};

    shapeTok = regexp(header, '''shape''\s*:\s*\(([^)]*)\)', 'tokens', 'once');
    shape = [];
    if ~isempty(shapeTok)
        nums = regexp(shapeTok{1}, '\d+', 'match');
        for i = 1:numel(nums)
            shape(i) = str2double(nums{i}); %#ok<AGROW>
        end
    end
    if isempty(shape)
        shape = 1;
    end

    data = fread(fid, inf, '*uint8');
    arr = decodeNpyPayload(descr, shape, data);
end

function arr = decodeNpyPayload(descr, shape, data)
    switch descr
        case {'<f4', '|f4', '>f4'}
            raw = typecast(uint8(data), 'single');
            arr = double(raw);
        case {'<c8', '|c8', '>c8'}
            raw = typecast(uint8(data), 'single');
            raw = reshape(raw, 2, []).';
            arr = complex(double(raw(:, 1)), double(raw(:, 2)));
        otherwise
            error('mr0:readNpy:UnsupportedDtype', 'Unsupported dtype %s', descr);
    end

    if numel(shape) == 1 || prod(shape) == numel(arr)
        arr = arr(:);
        return;
    end
    if numel(shape) == 2
        arr = reshape(arr, shape(2), shape(1)).';
        return;
    end
    arr = reshape(arr, fliplr(shape));
end
