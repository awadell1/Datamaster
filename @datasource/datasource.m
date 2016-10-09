classdef datasource < handle
    %Class for structing MoTeC Log Data and supporting documentation
    
    properties (Access = public)
        Data = struct;          %Stucture of Logged Data
        Entry = [];
    end
    properties (Access = public)
        dm = [];    %Handle to Datamaster Object
        MatPath = '';    %Fullpath to .mat file
    end
    
    methods
        function obj = datasource(dm,Entry)
            obj.dm = dm;
            obj.Entry = Entry;
            
            obj.MatPath = fullfile(dm.getDatastore,[Entry.FinalHash '.mat']);
        end
        
        %Access Methods
        function channels = getLogged(ds)
            channels = ds.Entry.Parameters(:);
        end
        
        function detail = getDetails(ds,Detail)
            detail = ds.Entry.Details.(Detail);
        end
        
        function clearData(ds,varargin)
            switch nargin
                case 1
                    %Clear Loaded Data from memory
                    ds.Data = struct;
                case 2
                    ds.Data = rmfield(ds.Data,varargin{1});
            end
        end
        %Public Function Signitures
        channel = getChannel(ds,chanName,varargin)
        
        TimePlot(ds,varargin)
        
        openInMoTeC(ds)
        
        duration = driveTime(ds,varargin)
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

