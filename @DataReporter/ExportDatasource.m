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
        %Create a temporary mat file that will be overwritten by i2Pro
        saveFile = [tempname '.mat'];
        save(saveFile, 'saveFile');
        
        %Download the .ld and .ldx file from Google Drive
        [ldPath, ldxPath] = getDatasourceDrive(MoTeCFile);
        
        %% Export Datasource as .mat
        %Export to the Temp File then copy to a new file
        tic
        fprintf('\tExporting from MoTeC...')
        i2.DataSources.Open(ldPath);
        i2.DataSources.ExportMainAsMAT(saveFile);
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
        delete(ldPath); delete(ldxPath); %Remove MoTeC Files
        success = true;
        fprintf('\tdone in %3.2f s.\n',toc(startExport))
    catch e
        switch e.identifier
            case 'MATLAB:COM:E0'
                %MoTeC Export Failed
                fprintf('Export Failed\n')
                
                %Delete Temporary mat file if it exist
                if exist(saveFile,'file')
                    delete(saveFile);
                end
                
                %Delete ld file if it exist
                if exist(ldPath,'file')
                    delete(ldPath);
                end
                
                %Delete ldx mat file if it exist
                if exist(ldxPath,'file')
                    delete(ldxPath);
                end
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