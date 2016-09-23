function [success,FinalHash] = ExportDatasource(dataSource,s)
    %Interface with the MoTeC i2Pro Application to control the exporting of a
    %log file as a .mat file
    
    %Set Success Flag
    success = false;
    FinalHash = '';
    
    fprintf('Exporting: .%s...',dataSource(length(s.ParentDir)+1:end));
    try
        %Create .mat file for i2Pro to save over -> Use a random filename
        %to prevent lockouts.
        %Created Early to ensure file is free when needed
        saveFile = sprintf('temp_%.f.mat',1e10*rand);
        saveFile = fullfile(fileparts(s.Datamaster.getDatastore),saveFile);
        save(saveFile,'saveFile');
        
        %Open the Log File in MoTeC
        s.i2.DataSources.Open(dataSource);
        pause(0.5);
        
        %Create WShell Object
        h = actxserver('WScript.Shell');
        
        %Active the MoTeC App
        h.AppActivate('Circuit 1'); pause(.01);
        
        %Baseline Delay
        delay = 0.02;
        
        %Open Datasource Details
        h.SendKeys('^d'); pause(delay);
        h.SendKeys('~'); pause(delay);
        
        %Wait for details to open
        pause(0.05)
        
        %Loop over Text boxes and Store
        details = cell(1,13);
        for i = 1:13
            if i ~= 4
                system('echo off | clip');          %Clear the clipboard
                h.SendKeys('^a'); pause(delay);     %Select Textbox
                h.SendKeys('^c'); pause(delay);     %Copy Textbox
                
                details{i} = PasteText();
            end
            h.SendKeys('{TAB}'); pause(delay);  %Move to Next Textbox
        end
        
        %Close Details Menu
        h.SendKeys('{ESC}'); pause(delay);
        h.SendKeys('{ESC}'); pause(delay);
        
        %Save Details
        Details.Event            = details{1};
        Details.Venue            = details{2};
        Details.Length           = details{3};  %Unused
        Details.Driver           = details{5}; 
        Details.VehicleID        = details{6};
        Details.VehicleNumber    = details{7};  %Unused
        Details.VehicleDesc      = details{8};  %Unused
        Details.EngineID         = details{9};
        Details.Session          = details{10};
        Details.StartLap         = details{11}; %Unused
        Details.Short            = details{12};
        Details.Long             = details{13};
        
        %Get Creation date for Datasource
        date = dir(dataSource); date = datetime(date.date);
        Details.Datetime = date;
        
        
        %% Export Datasource as .mat
        
        %Export to the Temp File then copy to a new file
        s.i2.DataSources.ExportMainAsMAT(saveFile); pause(0.1);
        s.i2.DataSources.CloseAll;
        
        %Request to add Datasource to the Datastore
        FinalHash = s.Datamaster.addDatasource(dataSource,saveFile,Details);
        
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
function paste = PasteText()
    %Sometimes Copying fails but retrying usually works
    maxTries = 5; nTry = 0;
    while nTry < maxTries
        try
            paste = clipboard('paste');    %Save Textbox String
            nTry = maxTries;
        catch
            %Wait a bit then try again
            pause(0.1*2^nTry);
            nTry = nTry +1;
            if maxTries == nTry
                error('Copying Failed -> ')
            end
        end
    end
end