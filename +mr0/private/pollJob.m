function pollJob(baseUrl, jobId)
%POLLJOB Poll GET /v1/jobs/{id} until done, failed, or aborted.
    pollInterval = 5.0;
    pollTimeout = 3600.0;
    t0 = tic;

    while toc(t0) < pollTimeout
        status = webread([char(baseUrl), '/v1/jobs/', char(jobId)]);
        msg = '';
        if isfield(status, 'message') && ~isempty(status.message)
            msg = char(status.message);
        elseif isfield(status, 'status')
            msg = char(status.status);
        end
        rep = scalarCount(status, 'repetition');
        tot = scalarCount(status, 'total');
        if rep > 0 && tot > 0
            msg = sprintf('%s %d/%d', msg, rep, tot);
        end

        if strlength(string(msg)) > 0 && ~onProgress(msg)
            abortJob(baseUrl, jobId);
            error('mr0:SimulationAborted', 'mr0-cloud simulation aborted by client');
        end

        switch char(status.status)
            case 'done'
                return;
            case 'failed'
                detail = msg;
                if isfield(status, 'error') && ~isempty(status.error)
                    detail = char(status.error);
                end
                error('mr0:pollJob:Failed', '%s', detail);
            case 'aborted'
                error('mr0:SimulationAborted', 'mr0-cloud simulation aborted');
        end

        pause(pollInterval);
    end

    error('mr0:pollJob:Timeout', 'mr0-cloud job %s did not finish within %.0f s', jobId, pollTimeout);
end

function n = scalarCount(status, fieldName)
%SCALARCOUNT Read a non-negative scalar count from a JSON status struct.
    n = 0;
    if ~isfield(status, fieldName) || isempty(status.(fieldName))
        return;
    end
    value = status.(fieldName);
    if isnumeric(value) || islogical(value)
        n = double(value(1));
    end
end
