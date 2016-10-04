classdef Datamaster < handle
    % Datamaster handles exporting i2 Pro Log files from MoTeC i2 Pro,
    % curating the exported datasources, enforing good data practices and
    % providing access to the datasource en mass
    
    properties (Access = private)
        mDir = connectSQLite;      %Connection Handle to the SQL Database
        Datastore = nan;           %Location of the Datastore
        
        %Hashing Settings
        HashOptions = struct('Method','SHA-256',...
                             'Format','hex',...
                             'Input','file');
    end
    
    methods
        %% Class Constructor
        function obj = Datamaster()
            %Report Current Version info
            reportGitInfo;

            %Set Relavant Locations
            obj.Datastore = getConfigSetting('Datastore','datastore_path');     
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
    end
    
    %% Function Signitures for Public Methods
    methods (Access = public)
        status = CheckLogFileStatus(obj,LogFileLoc)
        
        FinalHash = addDatasource(dm,MoTeCFile,saveFile,Details)
        
        addEntry(dm,MoTeCFile,FinalHash,Details,channels)
        
        Datasource = getDatasource(obj,varargin)
        
        [Entry,index] = getEntry(obj,varargin)
        
        removeEntry(obj,varagin)
        
        Cleanup(obj)
        
        SaveDirectory(obj)
        
        checkAllDatasourcesExist(dm)
        
        valid = validateHash(dm, hash)
        
        LoggedParameters = allLogged(dm,varargin)
    end
    
end

