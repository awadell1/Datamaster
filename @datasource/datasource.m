classdef datasource < handle
    %Class for structing MoTeC Log Data and supporting documentation
    
    properties (Access = public)
        FinalHash = [];         %Final Hash of the datasource
        Data = struct;          %Stucture of Logged Data
        %
    end
    properties (Access = public)
        dm = [];    %Handle to Datamaster Object
        MatPath = '';    %Fullpath to .mat file
    end
    
    methods
        function obj = datasource(dm,FinalHash)
            obj.dm = dm;
            obj.FinalHash = FinalHash;
            
            obj.MatPath = fullfile(dm.getDatastore,[FinalHash '.mat']);
        end
        
        %Access Methods
        function channels = getLogged(ds)
            channels = ds.dm.getEntry(ds.FinalHash).Parameters(:);
        end
        
        function detail = getDetails(ds,Detail)
            detail = ds.dm.getEntry(ds.FinalHash).Details.(Detail);
        end
        
        function clearData(ds)
            %Clear Loaded Data from memory
            ds.Data = [];
        end
        %Public Function Signitures
        channel = getChannel(ds,chanName)
        
        TimePlot(ds,varargin)
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

