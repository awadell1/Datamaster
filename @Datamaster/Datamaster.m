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
            
            %Set Relavant Locations
            dm.Datastore = getConfigSetting('Datastore','datastore_path');
            
            %% Check Datastore for Updates
            
            %Hash Remote Datastore
            mDirRemote = getConfigSetting('Datastore','master_directory_path');
            serverHash = DataHash(mDirRemote, dm.HashOptions);
            
            %Check if Local Copy Exist
            mDirLocal = getConfigSetting('Datastore','master_directory_path_local');
            if exist(mDirLocal,'file')
                %Hash Local Copy
                localHash = DataHash(mDirLocal, dm.HashOptions);
            else
                localHash = '';
            end
            
            %If Hashes don't match -> Copy Server
            if ~strcmp(serverHash, localHash)
                copyfile(mDirRemote, mDirLocal)
            end
            
            %% Load Database
            dm.mDir = connectSQLite(mDirLocal);
            
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
    
end

