classdef Datamaster < handle
    % Datamaster handles exporting i2 Pro Log files from MoTeC i2 Pro,
    % curating the exported datasources, enforing good data practices and
    % providing access to the datasource en mass
    
    properties (Access = private)
        mDir = [];       %Connection Handle to the SQL Database
        Datastore = nan             %Location of the Datastore
        
        Details = [];               %Stores a list of Details and their keys
        Channels = [];              %Stores a list of Channels and their keys
        
        %Hashing Settings
        HashOptions = struct('Method','SHA-256',...
            'Format','hex',...
            'Input','file');
    end
    
    methods
        %% Class Constructor
        function dm = Datamaster()
            %Report Current Version info
            reportGitInfo;
            
            % Set Datastore Path
            dm.Datastore = getConfigSetting('Datastore','datastore_path');
            
            % Load Database
            mDirPath = getConfigSetting('Datastore','master_directory_path');
            dm.mDir = connectSQLite(mDirPath);
            
            % Get a list of Details and Channels that have been logged
            dm.updateDetails; dm.updateChannels;
        end
        
        %% Small Public Methods -> Move externally if it grows
        function DatastorePath = getDatastore(obj)
            %Returns the Full Path to the Datastore
            DatastorePath = obj.Datastore;
        end
        
        function num = numEnteries(dm)
            %Returns the number of Datasources stored in the Datastore
            num = size(dm.mDir,2);
        end
        
        function dm = updateDetails(dm)
            %Updates the list of details that have been logged in the
            %database
            dm.Details = dm.mDir.fetch('SELECT DetailName.fieldName, DetailName.id FROM DetailName');
        end
        
        function dm = updateChannels(dm)
            %Updates the list of channels that have been logged in the
            %database
            dm.Channels = dm.mDir.fetch('SELECT ChannelName.channelname, ChannelName.id FROM ChannelName');
        end
        
    end
    
    %% Function Signitures for Public Methods
    methods (Access = public)
        status = CheckLogFileStatus(obj,LogFileLoc)
        
        FinalHash = addDatasource(dm,MoTeCFile,saveFile,Details)
        
        addEntry(dm,MoTeCFile,FinalHash,Details,channels)
        
        Datasource = getDatasource(dm,varargin)
        
        [Entry] = getEntry(dm,varargin)
        
        [index] = getIndex(dm, varargin)
        
        removeEntry(obj,varagin)
        
        Cleanup(obj)
        
        SaveDirectory(obj)
        
        checkAllDatasourcesExist(dm)
        
        LoggedParameters = allLogged(dm,varargin)
    end
    
    methods (Access = public, Static = true)
        
        function DatamasterPath = getPath
        %Function that returns the path to the Datamaster folder
            DatamasterPath = regexpi(which('Datamaster'),...
                '(.*)\\@Datamaster\\Datamaster.m', 'tokens');
            DatamasterPath = DatamasterPath{:}{:};
        end
        
        
        colormap(name)
        
    end
    
end

