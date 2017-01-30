classdef DataReporter
    %Class to Handle Updating the Datastore and generating reports
    
    properties
        %Get Access to Datamaster
        dm = Datamaster;
        stats = struct;
    end
    
    
    methods
        function dr = DataReporter()
            %Add Python Folder to search path
            P = py.sys.path;
            pyFolder = fullfile(Datamaster.getPath, 'Python');
            if count(P,pyFolder) == 0
                insert(P,int32(0),pyFolder);
            end
        end
        
        %% Function Signatures
        stats = RefreshDatastore(dr)
        
        
        
        checkDetails(dr,hash);
    end
    
    methods(Static)
        [Details] = getDetails(idxFilename)
    end
    methods(Static, Access = private)
        stats = RecursivelyOpen(s)
        [success,FinalHash] = ExportDatasource(dm,i2,MoTeCFile)
    end
    
end

