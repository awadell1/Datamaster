function varargout = allLogged(dm,varargin)
    % Returns a list of every parameter logged for the requested
    % Datasources. Uses getEntry to provide search
    
    persistent p
    if isempty(p)
        p = inputParser;
        p.FunctionName = 'allLogged';
        addRequired(p,'dm',@(x) isa(x,'Datamaster'));
        addOptional(p, 'ReturnType', 'channel', @ischar);
    end
    
    %Parse Inputs
    parse(p,dm,varargin{:});
    
    if strcmp(p.Results.ReturnType, 'channel')
        %Get a list of all logged channels
        LoggedParameters = dm.mDir.fetch(['SELECT channelName FROM ChannelName'...
            ' ORDER BY channelName']);
    elseif strcmp(p.Results.ReturnType, 'detail')
        %Get a list of all logged details
        LoggedParameters = dm.mDir.fetch(['SELECT fieldName FROM DetailName'...
            ' ORDER BY fieldName']);
    end
    
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

        varargout = {};
    else
        %Return a cell array of the logged parameters
        varargout{1} = LoggedParameters;
    end
end

