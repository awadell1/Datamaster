function FinalHash = addDatasource(obj,Origin,DatasourceLoc,Details)
    %Controls Adding Datasources to the Database
    FinalHash = '';
    
    
    %Check Log File Status
    [status,OriginHash] = obj.CheckLogFileStatus(Origin);
    if strcmp(status,'new')
        %Create Datasource and move to Datastore
        save(DatasourceLoc,'Details','-append');
        
        %Get Logged Parameters
        Parameters = whos('-file',DatasourceLoc);
        Parameters = {Parameters.name};
        save(DatasourceLoc,'Parameters','-append');
        
        %Compute Hash of Datasource
        FinalHash = DataHash(DatasourceLoc,obj.HashOptions);
        
        %Move to Datastore
        saveLoc = fullfile(obj.Datastore,[FinalHash '.mat']);
        movefile(DatasourceLoc,saveLoc,'f');
        
        %Ensure file is read only
        fileattrib(saveLoc,'-w');
        
        %Add to Master Directory
        obj.addEntry(Origin,OriginHash,FinalHash,Details,Parameters)
    else
        error('Can Only Add New Datasources to the Datastore')
    end
end