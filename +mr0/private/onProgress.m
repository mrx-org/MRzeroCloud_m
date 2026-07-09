function cont = onProgress(msg)
%ONPROGRESS Default progress callback; returns false when abort requested.
    state = packageState('get');
    if state.abortRequested
        cont = false;
        return;
    end
    if isempty(state.onMessage)
        if state.verbose
            fprintf(' > %s\n', msg);
        end
        cont = true;
        return;
    end
    cont = logical(state.onMessage(msg));
end
