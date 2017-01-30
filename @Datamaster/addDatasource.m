function FinalHash = addDatasource(dm,MoTeCFile,saveFile,Details)
    
    %Only add Datasource if new
    if strcmp(dm.CheckLogFileStatus(MoTeCFile),'new')
        %% Append Parameters and Details
        %Load temporary mat file into workspace
        ds = load(saveFile);
        
        
        %Convert Double Precision values to signal precision MoTeC Logs
        %data using ~12-14 bits per sample, thus using a 32 bit float
        %(single-precision float) more then sufficient to store the data. By
        %not storing samples as a double (64 bits), the final file size is
        %reduced by ~33%, with marginal errors due to truncation (On the
        %order of 1e-6)
        channels = fieldnames(ds);
        for i = 1:length(channels)
            %Check each subfield is a channel
            if isstruct(ds.(channels{i})) && isfield(ds.(channels{i}),'Time') && ...
                    isfield(ds.(channels{i}),'Value') && isfield(ds.(channels{i}),'Units')
                %Loop over numeric fields for each channel
                for fields = {'Time', 'Value'}
                    field = fields{:}; %Get string from cell array
                    
                    %Only reduce if data type is double
                    if isa(ds.(channels{i}).(field),'double')
                        %Convert Double to Single Precision float
                        ds.(channels{i}).(field) = single(ds.(channels{i}).(field));
                    end
                end
            end
        end
        
        %Add Logged Parameters to temporary mat file
        ds.Channels = channels;
        
        %Add Details to temporary mat file
        ds.Details = Details;
        
        %Re-save temporary mat file using v7
        save(saveFile,'-struct','ds','-v7');
        
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