function url = getModalUrl()
%GETMODALURL Base URL for the Modal HTTP simulation gateway.
    state = mr0.private.packageState('get');
    url = state.modalUrl;
end
