classdef datasource < handle
    %Class for structing MoTeC Log Data and supporting documentation
    
    properties (Access = public)
        FinalHash = [];         %Final Hash of the datasource
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
               
        function clearData(ds)
            %Clear Loaded Data from memory
            ds.Data = [];
        end
        %Public Function Signitures
        channel = getChannel(ds,chanName)
        
        TimePlot(ds,varargin)
        
        openInMoTeC(ds)

        duration = driveTime(ds,varargin)
    end
    
    methods (Access = public)
        function loadChannels(ds,channelNames)
            for i = 1:length(ds)
                %Load New Channels
                if isa(channelNames,'cell')
                    newData = load(ds(i).MatPath,channelNames{:});
                else
                    newData = load(ds(i).MatPath,channelNames);
                end
                
                %Append to Data
                vars = fieldnames(newData);
                for j = 1:length(vars)
                    ds(i).Data.(vars{j}) = newData.(vars{j});
                end
            end
        end
    end
    
end

