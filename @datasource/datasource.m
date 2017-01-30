classdef datasource < handle
    %Class for accessing data stored in datasources
    
    properties (Access = private)
        Index = [];             %Location of Entry in datastore
        Data = struct;          %Structure of Logged Data
        Entry = struct;         %Structure of masterDirectory
        Channel = {};           %Cell Array of logged channels
        Detail = [];            %Structure of Details
        dm = [];                %Handle to Datamaster Object
        MatPath = '';           %Full path to .mat file
    end
    
    methods
        function obj = datasource(dm,Entry)
            obj.dm = dm;
            obj.Entry = Entry;
            obj.Index = Entry.Index;
            
            obj.MatPath = fullfile(dm.getDatastore,[Entry.FinalHash '.mat']);
        end
        
        %Access Methods
        function channels = getLogged(ds)
            channels = ds.Entry.Channel(:);
        end
                
        function entry = getEntry(ds)
            
            %Assert that ds is singular
            assert(length(ds) ==1, 'getDetails only supports singular datasources');
            
            %Return Entry
            entry = ds.Entry;
        end
        
        function clearData(ds,varargin)
            %Used to clear channel data loaded into memory by the datasource.
            
            %Assert that ds is singular
            assert(length(ds) ==1, 'clearData only supports singular datasources');

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
        
        %Public Function Signatures
        channel = getChannel(ds,chanName,varargin)
        
        TimePlot(ds,varargin)
        
        openInMoTeC(ds)
        
        loadChannel(ds,channelNames)

        detail = getDetail(ds,Detail)

        duration = driveTime(ds,varargin)
        
        newTime = Sync(varargin)
        
        varargout = mapReduce(ds, mapFun, reduceFun, varargin)
        
        [cdf_2, x, y, duration] = CDF2(ds,varargin)
    end
    
end

