function [index] = getIndex(dm, varargin)
    %Gives the id of datasources in the masterDirectory that meet search criteria
    %Inputs: Key-value searches for the following:
    % Search by Details: Search for items logged in the .ldx file by a key value search for the Detail name
    %   Example: 'Driver','alw224' -> Find datasources where 'alw224' was logged as the 'Driver'
    % Search by Date (StartDate, EndDate): Search for datasource before/after/between the provided date range
    %   Inputs: StartDate, EndDate must be either datatime or use the format MM/dd/YYYY
    %   Example: 'StartDate', '09/19/2016', 'EndDate', '09/25/2016'
    % Search by Channel: Find datasource with a given set of parameters
    % Input: channel must be a string (if one channel) or a cell array of strings
    %   Example: 'channel', {'Engine_RPM', 'Throttle_Pos'} or 'channel', 'Engine_RPM'
    %
    % Output:
    % index: array of id integers for Datasource from masterDirectory
    
    
    %% Create Persistent Input Parser to handle reading inputs
    persistent p
    if isempty(p)% || true
        p = inputParser;
        p.FunctionName = 'getEntry';
        addRequired(p,'dm',@(x) isa(x,'Datamaster'));
        addOptional(p,'Hash','',@(x) dm.validateHash(x));
        
        %Add a Parameter for Each fieldname
        for i = 1:length(dm.Details)
            addParameter(p,dm.Details{i,1},    [],     @(x) ischar(x) || iscell(x));
        end
        
        % Add Parameter to search by channel
        addParameter(p,'channel',   [],     @(x) ischar(x) || iscell(x));
        
        % Add a Parameter to a date range of interest
        addParameter(p,'StartDate', [],     @(x) validateDatetime(x));
        addParameter(p,'EndDate',   [],     @(x) validateDatetime(x));
        
        % Add Parameters to control how many results are returned
        addParameter(p,'limit',    [],         @(x) isnumeric(x) && (x == round(x)));
    end
    
    %Parse Inputs and expand to vectors
    parse(p,dm,varargin{:});
    Hash = p.Results.Hash;
    channel = p.Results.channel;
    StartDate = p.Results.StartDate;
    EndDate = p.Results.EndDate;
    
    %Force channel into a cell array
    if ~isa(channel,'cell') && ~isempty(channel)
        channel = {channel};
    end
    
    if nargin == 1
        %If no arguments are supplied return everything
        index = dm.mDir.fetch('SELECT id FROM masterDirectory');
    elseif ~strcmp(Hash,'')
        %Return Database entries for that contain the supplied hash
        if iscellstr(Hash)
            %Join hashes in to a list of hashes
            hashStr = strjoin(Hash,''',''');
        else %Hash is a string
            hashStr = Hash;
        end
        query = sprintf(['SELECT id FROM masterDirectory ',...
            'WHERE masterDirectory.FinalHash IN (''%s'') OR ',...
            'masterDirectory.OriginHash IN (''%s'')'],hashStr, hashStr);
        index = dm.mDir.fetch(query);
        
    else %Search by Request
        
        %Create Cell Array to store each sub query
        fullQuery = {};
        
        %% Search in Field
        % Check if a search has been requested for each field
        query = cell(length(dm.Details),1); % Preallocate cell array to store queries
        for i = 1:length(dm.Details)
            if ~isempty(p.Results.(dm.Details{i}))
                % Search Field for Requested String
                query{i} = sprintf('(DetailName.fieldName = ''%s'' AND DetailLog.value LIKE ''%s'')',dm.Details{i},p.Results.(dm.Details{i}));
            end
        end
        
        %Remove empty queries
        query(cellfun(@isempty,query)) = [];
        
        % Create search query for details
        if ~isempty(query)
            %concatenate queries and add to fullQuery
            fullQuery{end+1} = sprintf(['SELECT masterDirectory.id FROM DetailLog ',...
                'INNER JOIN DetailName ON DetailName.id = DetailLog.fieldId ',...
                'INNER JOIN masterDirectory ON masterDirectory.id = DetailLog.entryId ',...
                'WHERE %s'...
                'GROUP BY entryId HAVING count(*) = %d'],strjoin(query,' OR '),length(query));
        end
        
        
        %% Search by Datetime      
        if ~isempty(StartDate) && ~isempty(EndDate)
            fullQuery{end+1} = sprintf(['SELECT masterDirectory.id FROM masterDirectory ',...
                'WHERE Datetime BETWEEN ''%s'' AND ''%s'''], StartDate, EndDate);
        elseif ~isempty(StartDate)
            fullQuery{end+1} = sprintf(['SELECT masterDirectory.id FROM masterDirectory ',...
                'WHERE Datetime >= ''%s'''],StartDate);
        elseif ~isempty(EndDate)
            fullQuery{end+1} = sprintf(['SELECT masterDirectory.id FROM masterDirectory ',...
                'WHERE Datetime <= ''%s'''],EndDate);
        end
        
        %% Search by Parameters
        if ~isempty(channel)
            fullQuery{end+1} = sprintf(['SELECT masterDirectory.id FROM channelLog ',...
                'INNER JOIN ChannelName ON ChannelName.id = ChannelLog.channelId ',...
                'INNER JOIN masterDirectory ON masterDirectory.id = ChannelLog.entryId ',...
                'WHERE ChannelName.channelName IN (''%s'') ',...
                'GROUP BY masterDirectory.id HAVING count(*) = %d'],...
                strjoin(channel, ''', '''),length(channel));
        end

      
        %% Set Limit
        if ~isempty(p.Results.limit)
            fullQuery{end+1} = sprintf('SELECT masterDirectory.id FROM masterDirectory LIMIT %d', p.Results.limit);
        end
        
        %Combine Queries and get the list of Datasource that meet search criteria
        query = strjoin(fullQuery,' INTERSECT ');
        index = dm.mDir.fetch(query);
    end
    
    %Convert to numerical array
    if ~isempty(index)
        index = [index{:}]';
    end
end