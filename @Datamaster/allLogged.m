function LoggedParameters = allLogged(dm,varargin)
    % Returns a list of every parameter logged for the requested
    % Datasources. Uses getEntry to provide search
    
    %Get a list of all logged channels
    LoggedParameters = mksqlite(dm.mDir, ['SELECT channelName FROM ChannelName'...
        ' ORDER BY channelName']);
end

