classdef datasource < handle
    %Class for structing MoTeC Log Data and supporting documentation
    
    properties (Access = private)
        Data = struct;          %Structure of Logged Data
        Entry = struct;         %Structure of masterDirectory
        Channel = {};           %Cell Array of logged channels
        Detail = struct;        %Structure of Details
        Gate = struct;          %Sturcture for gating function
        dm = [];                %Handle to Datamaster Object
        MatPath = '';           %Fullpath to .mat file
    end
    
    methods
        function obj = datasource(dm,Entry)
            obj.dm = dm;
            obj.Entry = Entry;
            
            obj.MatPath = fullfile(dm.getDatastore,[Entry.FinalHash '.mat']);
        end
        
        %Access Methods
        function channels = getLogged(ds)
            channels = ds.Entry.Channel(:);
        end
        
        function detail = getDetail(ds,Detail)
            %Get a sepecfic detail from Detail Log
            
            %Assert that ds is singluar
            assert(length(ds) ==1, 'getDetails only supports singular datasources');
            
            %Load Details if missing
            if isempty(ds.Detail)
                %Fetch Details from datastore
                DetailLog = mksqlite(ds.dm.mDir, sprintf(['SELECT DetailLog.entryId, '...
                    'DetailName.fieldName, DetailLog.value, DetailLog.unit FROM DetailLog ',...
                    'INNER JOIN DetailName ON DetailName.id = DetailLog.fieldId ',...
                    'WHERE DetailLog.entryId IN (%s)'], strjoin(sprintfc('%d',ds.Entry.Index),',')));
                
                %Add DetailLog records to Details
                for j = 1:length(DetailLog)
                    if strcmp(DetailLog{j,4},'null')
                        ds.Detail.(DetailLog{j,2}) = DetailLog{j,3};
                    else
                        ds.Detail.(DetailLog{j,2}).Value = DetailLog{j,3};
                        ds.Detail.(DetailLog{j,2}).Unit = DetailLog{j,4};
                    end
                end
            end
            
            %Check if Detail exist
            if isfield(ds.Detail, Detail)
                detail = ds.Detail.Detail;  %Return Detail
            else
                detail = '';    %Detail is missing return empty
            end
        end
        
        function entry = getEntry(ds)
            
            %Assert that ds is singluar
            assert(length(ds) ==1, 'getDetails only supports singular datasources');
            
            %Return Entry
            entry = ds.Entry;
        end
        
        function clearData(ds,varargin)
            switch nargin
                case 1
                    %Clear Loaded Data from memory
                    ds.Data = struct;
                case 2
                    if isfield(ds.Data,varargin{1})
                        ds.Data = rmfield(ds.Data,varargin{1});
                    end
            end
        end
        %Public Function Signitures
        channel = getChannel(ds,chanName,varargin)
        
        TimePlot(ds,varargin)
        
        openInMoTeC(ds)
        
        duration = driveTime(ds,varargin)
        
        newTime = Sync(varargin)
        
        setGate(ds, filterHandle)
    end
    
    methods (Access = public)
        function loadChannels(ds,channelNames)
            
            %Force channel names into a cell array
            if ~iscell(channelNames)
                channelNames = {channelNames};
            end
            
            %Loop over each datasource
            for i = 1:length(ds)
                %Find missing channels
                isMissing = ~isfield(ds(i).Data,channelNames);
                
                %Load Missing Channels
                if any(isMissing)
                    newData = load(ds(i).MatPath,channelNames{isMissing});
                    
                    %Check that missing was loaded
                    assert(isfield(newData, channelNames{isMissing}),...
                        'Channel Not Logged')
                    
                    %Append to Data
                    vars = fieldnames(newData);
                    for j = 1:length(vars)
                        ds(i).Data.(vars{j}) = newData.(vars{j});
                    end
                end
            end
        end
    end
    
end

