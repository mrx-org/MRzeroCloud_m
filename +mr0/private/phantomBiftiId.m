function biftiId = phantomBiftiId(config)
%PHANTOMBIFTIID Resolve bifti cache id from config.
    if isfield(config, 'phantom_bifti') && ~isempty(config.phantom_bifti)
        biftiId = char(string(config.phantom_bifti));
        return;
    end

    if isfield(config, 'phantom') && ~isempty(config.phantom)
        id = char(string(config.phantom));
        if contains(id, '/')
            biftiId = id;
            return;
        end
    end

    error('mr0:phantomBiftiId:MissingId', ...
        'Set config.phantom_bifti (e.g. user/numerical_brain_cropped_bifti)');
end
