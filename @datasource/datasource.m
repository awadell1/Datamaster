classdef datasource < handle
    %Class for structing MoTeC Log Data and supporting documentation
    
    properties (Access = public)
        Entry = [];         %Datastore Entry
        Data = struct;          %Stucture of Logged Data
        %
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
        
        %Public Function Signitures
        channel = getChannel(ds,chanName)
        
        TimePlot(ds,chanName)
    end
    
    methods (Access = public)
        function loadChannels(ds,channelNames)
            %Load New Channels
            if isa(channelNames,'cell')
                newData = load(ds.MatPath,channelNames{:});
            else
                newData = load(ds.MatPath,channelNames);
            end
            
            
            %Append to Data
            vars = fieldnames(newData);
            for i = 1:length(vars)
                ds.Data.(vars{i}) = newData.(vars{i});
            end
        end
    end
    
end

