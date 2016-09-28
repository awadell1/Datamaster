function LoggedParameters = allLogged(dm,varargin)
    % Returns a list of every parameter logged for the requested
    % Datasources. Uses getEntry to provide search
    
    %Get a list of all logged channels
    channels = [dm.getEntry(varargin{:}).Parameters];
    
    %Return only unique ones
    LoggedParameters = unique(channels);
    
    %Return Column array
    if size(LoggedParameters,1) < size(LoggedParameters,2)
        LoggedParameters = LoggedParameters.';
    end    
end

