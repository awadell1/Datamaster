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
    
    fprintf('Exporting: .%s',MoTeCFile.OriginHash);
    try
        %Create a random temp .mat file to export MoTeC Log file to
        saveFile = sprintf('temp_%.f.mat',1e10*rand);
        saveFile = fullfile(fileparts(dm.getDatastore),saveFile);
        save(saveFile,'saveFile');
        
        %Download the .ld and .ldx file to the Datastore
        dsPath = getDatasourceDrive(MoTeCFile,dm.getDatastore);
        
        %Open the Log File in MoTeC
        i2.DataSources.Open(dsPath); pause(0.5);
        
        %% Export Datasource as .mat
        %Export to the Temp File then copy to a new file
        i2.DataSources.ExportMainAsMAT(saveFile); pause(0.1);
        i2.DataSources.CloseAll;
        
        %Request to add Datasource to the Datastore
        FinalHash = dm.addDatasource(MoTeCFile,saveFile,Details);
        
        %% Clean Up
        %Close out WShell Object
        h.delete
        fprintf('done.\n')
        
        %Set success flag
        success = true;
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