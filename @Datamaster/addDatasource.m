function FinalHash = addDatasource(dm,MoTeCFile,saveFile,Details)
    
    %Only add Datasource if new
    if strcmp(dm.CheckLogFileStatus(MoTeCFile),'new')
        %% Append Parameters and Details
        maxTries = 10; nTry = 0;
        while nTry < maxTries
            try
                %Get Logged Parameters
                channels = whos('-file',saveFile);
                channels = {channels.name};
                save(saveFile,'channels','Details','-append');
                
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
        FinalHash = DataHash(saveFile,dm.HashOptions);
        
        %% Move to Datastore
        maxTries = 10; nTry = 0;
        while nTry < maxTries
            try
                %Move to Datastore
                saveLoc = fullfile(dm.Datastore,[FinalHash '.mat']);
                movefile(saveFile,saveLoc,'f');
                
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
        dm.addEntry(MoTeCFile,FinalHash,Details,channels)
    else
        error('Can Only Add New Datasources to the Datastore')
    end
end