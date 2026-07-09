function arr = readNpy(source)
%READNPY Minimal NumPy .npy reader for float32/complex64 arrays.
    if ischar(source) || isstring(source)
        fid = fopen(char(source), 'rb');
        if fid < 0
            error('mr0:readNpy:OpenFailed', 'Could not open %s', char(source));
        end
        cleaner = onCleanup(@() fclose(fid));
        data = fread(fid, inf, 'uint8');
    else
        data = uint8(source(:))';
    end
    arr = parseNpyBytes(data);
end

function arr = parseNpyBytes(data)
    if numel(data) < 10
        error('mr0:readNpy:BadMagic', 'Not a .npy file (too short)');
    end

    magic = data(1:6);
    expected = [147, uint8('NUMPY')];
    if ~isequal(magic, expected)
        error('mr0:readNpy:BadMagic', 'Not a .npy file (bad magic)');
    end

    major = data(7);
    if major == 1
        headerLen = double(typecast(data(9:10), 'uint16'));
        headerStart = 11;
    elseif major == 2
        headerLen = double(typecast(data(9:12), 'uint32'));
        headerStart = 13;
    else
        error('mr0:readNpy:UnsupportedVersion', 'Unsupported .npy version %d', major);
    end
    headerEnd = headerStart + headerLen - 1;
    header = char(data(headerStart:headerEnd));

    descrTok = regexp(header, '''descr''\s*:\s*''([^'']+)''', 'tokens', 'once');
    if isempty(descrTok)
        error('mr0:readNpy:MissingDescr', 'Missing dtype in .npy header');
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

    payload = data(headerEnd + 1:end);
    arr = decodeNpyPayload(descr, shape, payload);
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
