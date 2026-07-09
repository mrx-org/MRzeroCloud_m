function jobId = submitJob(baseUrl, seqPath, options)
%SUBMITJOB POST /v1/jobs with multipart seq + options JSON.
    import matlab.net.http.*
    import matlab.net.http.io.*

    baseUrl = char(strtrim(string(baseUrl)));
    seqPath = char(seqPath);
    if ~isfile(seqPath)
        error('mr0:submitJob:MissingSeq', 'Sequence file not found: %s', seqPath);
    end

    body = MultipartFormProvider( ...
        'seq', FileProvider(seqPath), ...
        'options', jsonencode(options) ...
    );
    req = RequestMessage('post', [], body);
    uri = URI([baseUrl, '/v1/jobs']);
    resp = req.send(uri);

    if resp.StatusCode ~= 200
        detail = '';
        if ~isempty(resp.Body) && isa(resp.Body, 'matlab.net.http.MessageBody')
            detail = char(resp.Body.string);
        end
        error('mr0:submitJob:HttpError', 'POST /v1/jobs failed (%d): %s', ...
            resp.StatusCode, detail);
    end

    payload = jsondecode(char(resp.Body.string));
    jobId = payload.job_id;
end
