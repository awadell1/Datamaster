function LoggedParameters = allLogged(dm,varargin)
    % Returns a list of every parameter logged for the requested
    % Datasources. Uses getEntry to provide search
    
    %Get a list of all logged channels
    LoggedParameters = dm.mDir.fetch(['SELECT channelName FROM ChannelName'...
        ' ORDER BY channelName']);
    
    %Print Channels logged to console if no output requested
    if nargout == 0
       %Find the length of the longest string
       maxLength = max(cellfun(@length, LoggedParameters));
       
       %Set Format Spec
       formatStr = ['%-' sprintf('%d', maxLength) 's\t'];
       formatStr = [repmat(formatStr, [1 4]) '\n'];
       
       %Output String
       fprintf(formatStr, LoggedParameters{:})
       fprintf('\n')
    end
end

