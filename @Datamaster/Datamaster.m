classdef Datamaster < handle
    % Datamaster handles exporting i2 Pro Log files from MoTeC i2 Pro,
    % curating the exported datasources, enforing good data practices and
    % providing access to the datasource en mass
    
    properties (Access = private)
        mDir = struct;             %Handle to the mat file storing information on all datasources
        Datastore = nan;        %Location of the Datastore
        mDirLoc = nan;          %Location of the master directory
        
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
                obj.mDir = load(obj.mDirLoc);
                
                %Ensure all Required Variables have been created
                Existing_Vars = fieldnames(obj.mDir);
            else
                Existing_Vars = {''};
            end
            
            %Set Required Variables
            req_Vars = {'Origin',....       %Relative Path from \Google Drive\
                'OriginHash',...    %Hash of the origin .ld file
                'FinalHash',...     %Hash of the Datastore
                'Details',...       %Copy of the Datastore's Details
                'Parameters'};      %List of Parameters logged
            
            % Check Required Variables Exist
            for i = 1:length(req_Vars)
                %Check if required variable exist
                checksum = sum(strcmp(req_Vars{i},Existing_Vars));
                if checksum == 1
                    %Matfile Contains exactly one copy of the required
                    %variable
                    
                elseif checksum < 1
                    %Mat file is missing required variable -> Create
                    obj.mDir.(req_Vars{i}) = {};
                else
                    %Multiple compies of a required varaiable exist ->
                    %Directory has been corupted and will need to be
                    %manually recovered
                    error('Master Directory Corrupted')
                end
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
            
        end
        
end

