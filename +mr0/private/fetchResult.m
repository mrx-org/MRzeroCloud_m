function [signal, ktraj] = fetchResult(baseUrl, jobId)
%FETCHRESULT GET /v1/jobs/{id}/result and decode NPZ payload.
    opts = weboptions('ContentType', 'binary', 'Timeout', 120);
    bytes = webread([char(baseUrl), '/v1/jobs/', char(jobId), '/result'], opts);
    [signal, ktraj] = readNpzResult(bytes);
    if isempty(signal)
        error('mr0:fetchResult:EmptySignal', 'modal backend returned empty signal');
    end
end
