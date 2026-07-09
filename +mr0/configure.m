function configure(varargin)
%CONFIGURE Override modal HTTP URL and progress reporting.
%
%   mr0.configure('ModalUrl', 'https://…gateway.modal.run')
%   mr0.configure('OnMessage', @(msg) fprintf('> %s\n', msg))
%   mr0.configure('Verbose', false)
%
%   Name/value pairs:
%     ModalUrl  - override default Modal gateway URL (optional)
%     OnMessage - function handle(msg) -> logical continue (default prints progress)
%     Verbose   - print completion lines (default true)

    p = inputParser;
    p.addParameter('ModalUrl', '', @(x) ischar(x) || isstring(x));
    p.addParameter('OnMessage', [], @(x) isempty(x) || isa(x, 'function_handle'));
    p.addParameter('Verbose', [], @(x) isempty(x) || islogical(x) || isnumeric(x));
    parse(p, varargin{:});

    state = packageState('get');

    if strlength(string(p.Results.ModalUrl)) > 0
        state.modalUrl = char(strtrim(string(p.Results.ModalUrl)));
    end
    if ~isempty(p.Results.OnMessage)
        state.onMessage = p.Results.OnMessage;
    end
    if ~isempty(p.Results.Verbose)
        state.verbose = logical(p.Results.Verbose);
    end

    packageState('set', state);
end
