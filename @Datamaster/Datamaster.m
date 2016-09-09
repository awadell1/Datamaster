classdef Datamaster < handle
    % Datamaster handles exporting i2 Pro Log files from MoTeC i2 Pro,
    % curating the exported datasources, enforing good data practices and
    % providing access to the datasource en mass
    
    properties (Access = private)
        mDir = struct;             %Handle to the mat file storing information on all datasources
        Datastore = nan;           %Location of the Datastore
        mDirLoc = nan;             %Location of the master directory
        
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
            obj.Datastore = 'C:\Users\Alex\OneDrive\ARG17\Datamaster\Datastore\';
            obj.mDirLoc = fullfile(obj.Datastore,'mDir.mat');
            
            %Connect to the Directory
            if exist(obj.mDirLoc,'file')
                load(obj.mDirLoc); obj.mDir = mDir;
            else
                obj.mDir = struct('Origin',{},'OriginHash',{},'FinalHash',{},...
                    'Details',{},'Parameters',{});
            end        
        end
        
        %% Small Public Methods -> Move externally if it grows
        function DatastorePath = getDatastore(obj)
            %Returns the Full Path to the Datastore
            DatastorePath = obj.Datastore;
        end
        
        function delete(obj)
            %Method for deleteing Datamaster Object
            
            %Save Current Directory
            obj.SaveDirectory;
        end
        
        function num = numEnteries(dm)
            %Returns the number of Datasources stored in the Datastore
            num = size(dm.mDir,2);
        end
    end
    
    %% Function Signitures for Public Methods
    methods (Access = public)
        [status,OriginHash] = CheckLogFileStatus(obj,LogFileLoc)
        
        FinalHash = addDatasource(obj,Origin,DatasourceLoc,Details)
        
        addEntry(obj,Origin,OriginHash,FinalHash,Details,Parameters)
        
        Datasource = getDatasource(obj,varargin)
        
        [Entry,index] = getEntry(obj,varargin)
        
        removeEntry(obj,varagin)
        
        Cleanup(obj)
        
        SaveDirectory(obj)
        
        checkAllDatasourcesExist(dm)
        
        valid = validateHash(dm, hash)
        
    end
    
end

