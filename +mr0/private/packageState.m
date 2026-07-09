function out = packageState(action, value)
%PACKAGESTATE Persistent MRzerocloud_m configuration.
    persistent s
    if isempty(s)
        s = struct( ...
            'modalUrl', 'https://mzaiss--tool-mr0sim-modal-http-gateway.modal.run', ...
            'onMessage', [], ...
            'verbose', true, ...
            'abortRequested', false ...
        );
    end

    switch lower(action)
        case 'get'
            out = s;
        case 'set'
            s = value;
            out = s;
        case 'resetabort'
            s.abortRequested = false;
            out = s;
        otherwise
            error('mr0:packageState:InvalidAction', 'Unknown action: %s', action);
    end
end
