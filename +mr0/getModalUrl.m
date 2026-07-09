function url = getModalUrl()
%GETMODALURL Base URL for the Modal HTTP simulation gateway.
    state = packageState('get');
    url = state.modalUrl;
end
