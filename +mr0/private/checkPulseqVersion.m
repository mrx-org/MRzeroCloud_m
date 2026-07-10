function checkPulseqVersion(seqPath)
%CHECKPULSEQVERSION Local pre-flight for .seq files (no network I/O).
%   Rejects unsupported files before mr0-cloud submission:
%   Pulseq version must be <= 1.5.0; file must have <= 20000 lines.
    seqPath = char(seqPath);
    if ~isfile(seqPath)
        error('mr0:checkPulseqVersion:MissingSeq', 'Sequence file not found: %s', seqPath);
    end

    txt = fileread(seqPath);
    maxLines = 20000;
    nLines = countLines(txt);
    if nLines > maxLines
        error('mr0:checkPulseqVersion:FileTooLarge', ...
            'Sequence file has %d lines (%d maximum currently supported)', ...
            nLines, maxLines);
    end

    ver = parsePulseqVersion(txt);
    maxVer = struct('major', 1, 'minor', 5, 'revision', 0);

    if isVersionNewerThan(ver, maxVer)
        error('mr0:checkPulseqVersion:UnsupportedVersion', ...
            'Pulseq version %d.%d.%d is not supported (maximum 1.5.0).', ...
            ver.major, ver.minor, ver.revision);
    end
end

function nLines = countLines(txt)
    if isempty(txt)
        nLines = 0;
        return;
    end
    nLines = sum(txt == newline | txt == char(13)) + 1;
end

function ver = parsePulseqVersion(txt)
    ver = struct('major', [], 'minor', [], 'revision', []);
    inVersion = false;

    lines = splitlines(string(txt));
    for k = 1:numel(lines)
        line = strtrim(char(lines(k)));
        if isempty(line) || line(1) == '#'
            continue;
        end
        if strcmp(line, '[VERSION]')
            inVersion = true;
            continue;
        end
        if line(1) == '[' && inVersion
            break;
        end
        if ~inVersion
            continue;
        end

        tokens = regexp(line, '^\s*(\w+)\s+(\S+)', 'tokens', 'once');
        if isempty(tokens)
            continue;
        end
        key = lower(tokens{1});
        val = str2double(tokens{2});
        if isnan(val)
            continue;
        end
        switch key
            case 'major'
                ver.major = val;
            case 'minor'
                ver.minor = val;
            case 'revision'
                ver.revision = val;
        end
    end

    if isempty(ver.major) || isempty(ver.minor) || isempty(ver.revision)
        error('mr0:checkPulseqVersion:MissingVersion', ...
            'Could not parse Pulseq [VERSION] (major/minor/revision) from sequence file');
    end
end

function newer = isVersionNewerThan(ver, maxVer)
    if ver.major > maxVer.major
        newer = true;
        return;
    end
    if ver.major < maxVer.major
        newer = false;
        return;
    end
    if ver.minor > maxVer.minor
        newer = true;
        return;
    end
    if ver.minor < maxVer.minor
        newer = false;
        return;
    end
    newer = ver.revision > maxVer.revision;
end
