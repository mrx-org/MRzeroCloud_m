function checkPulseqVersion(seqPath)
%CHECKPULSEQVERSION Reject unsupported .seq files before simulation.
%   Pulseq version must be <= 1.4.2; file must have <= 20000 lines.
    seqPath = char(seqPath);
    if ~isfile(seqPath)
        error('mr0:checkPulseqVersion:MissingSeq', 'Sequence file not found: %s', seqPath);
    end

    txt = fileread(seqPath);
    maxLines = 20000;
    nLines = numel(splitlines(string(txt)));
    if nLines > maxLines
        error('mr0:checkPulseqVersion:FileTooLarge', ...
            'Sequence file has %d lines (%d maximum currently supported)', ...
            nLines, maxLines);
    end

    ver = parsePulseqVersion(txt);
    maxVer = struct('major', 1, 'minor', 4, 'revision', 2);

    if isVersionNewerThan(ver, maxVer)
        error('mr0:checkPulseqVersion:UnsupportedVersion', ...
            ['Pulseq version %d.%d.%d is not supported (maximum 1.4.2). ', ...
            'Re-export the sequence with pypulseq <= 1.4.2.'], ...
            ver.major, ver.minor, ver.revision);
    end
end

function ver = parsePulseqVersion(txt)
    ver = struct('major', [], 'minor', [], 'revision', []);
    inVersion = false;

    for line = splitlines(string(txt))
        line = strtrim(line);
        if strlength(line) == 0 || startsWith(line, "#")
            continue;
        end
        if line == "[VERSION]"
            inVersion = true;
            continue;
        end
        if startsWith(line, "[") && inVersion
            break;
        end
        if ~inVersion
            continue;
        end

        parts = split(line);
        if numel(parts) < 2
            continue;
        end
        key = lower(char(parts(1)));
        val = str2double(parts(2));
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
