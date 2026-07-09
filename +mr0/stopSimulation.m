function stopSimulation()
%STOPSIMULATION Request abort of the current modal simulation poll loop.
%
%   mr0.stopSimulation()
%
%   Sets a flag checked by the progress callback between poll iterations.
%   Call from another thread/timer while simulate() is running.

    state = packageState('get');
    state.abortRequested = true;
    packageState('set', state);
end
