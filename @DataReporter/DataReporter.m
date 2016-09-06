classdef DataReporter
    %Class to Handle Updating the Datastore and generating reports
    
    properties
        %Get Access to Datamaster
        dm = Datamaster;
        stats = struct;
    end
    
    
    methods
        function dr = DataReporter()
            %Clean Up Datastore
            dr.dm.Cleanup;
            dr.dm.checkAllDatasourcesExist;
        end
        
        %% Function Signitures
        stats = RefreshDatastore(dr)
        
        checkDetails(dr,hash);
    end
    
    methods(Static)
        stats = RecursivelyOpen(s)
        [success,FinalHash] = ExportDatasource(dataSource,s)
    end
    
end

