function [success,FinalHash] = ExportDatasource(dm,i2,MoTeCFile)
    %Interface with the MoTeC i2Pro Application to control the exporting of a
    %log file as a .mat file
    % MoTeCFile: Struct w/ the following fields
    %   ld: The file id of the .ld file to download
    %   ldx: The file id of the .ldx file to download
    %   OriginHash: MD5 Hash of the .ld and .ldx files
    
    %Set Success Flag
    success = false;
    FinalHash = '';
    
    fprintf('Exporting: %s',MoTeCFile.OriginHash);
    startExport = tic;
    try
        %Create a random temp .mat file to export MoTeC Log file to
        tempSaveLoc = getConfigSetting('Datastore','temp_path');
        saveFile = sprintf('temp_%.f.mat',1e10*rand);
        saveFile = fullfile(tempSaveLoc,saveFile);
        save(saveFile,'saveFile');
        
        %Download the .ld and .ldx file to the Datastore
        motecSaveLoc = getConfigSetting('Datastore','motec_path');      %Get the save location from the config file
        [ldPath, ldxPath] = getDatasourceDrive(MoTeCFile,motecSaveLoc); %Download files from Google
        
        %Open the Log File in MoTeC
        i2.DataSources.Open(ldPath); pause(0.5);
        
        %% Export Datasource as .mat
        %Export to the Temp File then copy to a new file
        tic
        fprintf('\tExporting from MoTeC...')
        i2.DataSources.ExportMainAsMAT(saveFile); pause(0.1);
        i2.DataSources.CloseAll;
        
        %Extract the Details
        Details = getDetails(ldxPath);
        fprintf('done in %3.2f s\n',toc);
        
        %Request to add Datasource to the Datastore
        tic
        fprintf('\tAdding to database...')
        FinalHash = dm.addDatasource(MoTeCFile,saveFile,Details);
        fprintf('done in %3.2f s\n',toc);
        
        %Clean up
        success = true;
        fprintf('\tdone in %3.2f s.\n',toc(startExport))
    catch e
        switch e.identifier
            case 'MATLAB:COM:E0'
                %MoTeC Export Failed
                fprintf('Export Failed\n')
            otherwise
                %Something Bad Happended
                rethrow(e);
        end
        %Clean up Temp File
        if exist(saveFile,'var')
            delete(saveFile);
        end
    end
end