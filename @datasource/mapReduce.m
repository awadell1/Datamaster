function varargout = mapReduce(ds, mapFun, reduceFun, varargin)
    %Function for applying a function (mapFun) to each datasource
    
    %Create Input Parser
    persistent p
    if isempty(p)
        p = inputParser;
        p.FunctionName = 'mapReduce';
        p.addRequired('ds',             @(x) isa(x, 'datasource') && ~isempty(x));
        p.addRequired('mapFun',         @(x) isa(x, 'function_handle') && nargin(x) == 1);
        p.addRequired('reduceFun',      @(x) isa(x, 'function_handle'));
        p.addOptional('channel',   [], @(x) iscellstr(x) || ischar(x))
    end
    
    %Process Inputs
    parse(p, ds, mapFun, reduceFun, varargin{:});
    ds = p.Results.ds;
    mapFun = p.Results.mapFun;
    reduceFun =p.Results.reduceFun;
    
    %Grab datamaster from one of the datasources
    dm = ds(1).dm;
    
    %% Check for repeated required channels
    if ~iscell(p.Results.channel)
        ReqChannel = {p.Results.channel};
    else
        ReqChannel = p.Results.channel;
    end
    ReqChannel = unique(ReqChannel);
    
    %% Filter out datasources missing required channels
    if ~isempty(p.Results.channel)
        %Find datasources with the required channels
        hasRequired = dm.getIndex('channel', ReqChannel);
        
        %Get the index of the current datasources
        currentIndex = [ds.Index];
        
        %Filter out datasource missing all required variables
        [~, dropIndex] = setxor(currentIndex, hasRequired);
        ds(dropIndex) = [];
        
        %If no datasource remain throw error
        if isempty(ds)
            error('No datasource had all required channels');
        end
    end
    
    %Initialize array for holding results
    MapFunOut = cell(length(ds), abs(nargout(mapFun)));
    
    %% Loop over each datasource
    nDatasource = length(ds);
    textprogressbar('Processing Datasources: ', 'new');
    for i = 1:nDatasource
        %Attempt to load required channels
        if ~isempty(p.Results.channel)
            ds(i).loadChannel(p.Results.channel);
        end
        %Apply mapFunction to each Datasource
        [MapFunOut{i,:}] = mapFun(ds(i));
        
        %Make sure all data is unloaded
        ds(i).clearData;
        
        %Update progress bar
        textprogressbar(100*i/nDatasource);
    end
    textprogressbar('done');
    
    %Expand MapFunOut to separate each output of mapFun
    results = cell(size(MapFunOut,2),1);
    for i = 1:size(MapFunOut,2)
        %Keep results as a cell array
        results{i} = MapFunOut(:,i);       
    end
    
    %% Pass the consolidated outputs of mapFun to reduceFun
    
    %Initialize varargout to capture all the outputs of reduceFun
    varargout = cell(1,nargout(reduceFun));
    
    %Run reduceFun
    [varargout{:}] = reduceFun(results{:});