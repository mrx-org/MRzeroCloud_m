function abortJob(baseUrl, jobId)
%ABORTJOB POST /v1/jobs/{id}/abort (best effort).
    import matlab.net.http.*

    try
        req = RequestMessage('post');
        uri = URI([char(baseUrl), '/v1/jobs/', char(jobId), '/abort']);
        req.send(uri);
    catch
        % Ignore network errors during cooperative abort.
    end
end
