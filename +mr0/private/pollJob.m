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
        if isfield(status, 'repetition') && isfield(status, 'total') ...
                && status.repetition > 0 && status.total > 0
            msg = sprintf('%s %d/%d', msg, status.repetition, status.total);
        end

        if strlength(string(msg)) > 0 && ~onProgress(msg)
            abortJob(baseUrl, jobId);
            error('mr0:SimulationAborted', 'modal simulation aborted by client');
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
                error('mr0:SimulationAborted', 'modal simulation aborted');
        end

        pause(pollInterval);
    end

    error('mr0:pollJob:Timeout', 'modal job %s did not finish within %.0f s', jobId, pollTimeout);
end
