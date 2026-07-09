function v = version()
%VERSION MRzeroCloud_m package version (reads VERSION in package root).
    persistent cached
    if ~isempty(cached)
        v = cached;
        return;
    end

    pkgRoot = fileparts(fileparts(mfilename('fullpath')));
    versionPath = fullfile(pkgRoot, 'VERSION');
    if ~isfile(versionPath)
        error('mr0:version:MissingFile', 'VERSION file not found: %s', versionPath);
    end

    cached = strtrim(fileread(versionPath));
    v = cached;
end
