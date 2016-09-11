function FinalHash = addDatasource(obj,Origin,DatasourceLoc,Details)
    %Controls Adding Datasources to the Database
    FinalHash = '';
    
    
    %Check Log File Status
    [status,OriginHash] = obj.CheckLogFileStatus(Origin);
    if strcmp(status,'new')
        %% Append Parameters and Details
        maxTries = 10; nTry = 0;
        while nTry < maxTries
            try
                %Get Logged Parameters
                Parameters = whos('-file',DatasourceLoc);
                Parameters = {Parameters.name};
                save(DatasourceLoc,'Parameters','Details','-append');
                
                %Mark as successful
                nTry = maxTries;
            catch e
                if strcmp(e.identifier,'MATLAB:save:unableToWriteToMatFile')
                    pause(0.5*2^nTry);
                    nTry = nTry +1;
                    if nTry == maxTries
                        rethrow(e)
                    end
                end
            end
        end
        
        %Compute Hash of Datasource
        FinalHash = DataHash(DatasourceLoc,obj.HashOptions);
        
        %% Move to Datastore
        maxTries = 10; nTry = 0;
        while nTry < maxTries
            try
                %Move to Datastore
                saveLoc = fullfile(obj.Datastore,[FinalHash '.mat']);
                movefile(DatasourceLoc,saveLoc,'f');
                
                %Ensure file is read only
                fileattrib(saveLoc,'-w');
                
                %Mark as successful
                nTry = maxTries;
            catch e
                if strcmp(e.identifier,'MATLAB:save:unableToWriteToMatFile')
                    pause(0.5*2^nTry);
                    nTry = nTry +1;
                    if nTry == maxTries
                        rethrow(e)
                    end
                end
            end
        end
        
        %Add to Master Directory
        obj.addEntry(Origin,OriginHash,FinalHash,Details,Parameters)
    else
        error('Can Only Add New Datasources to the Datastore')
    end
end