function FinalHash = addDatasource(dm,MoTeCFile,saveFile,Details)
    
    %Only add Datasource if new
    if strcmp(dm.CheckLogFileStatus(MoTeCFile),'new')
        %% Append Parameters and Details
        %Load temporary mat file into workspace
        ds = load(saveFile);
        
        %% Compress Save Datasource
        %Record Mean Sampling Rate instead of a Time Vector: Channels are
        %logged at a constant rate -> Recording exact time is exccessive
        %
        %Convert Double Precision values to signal precision MoTeC Logs
        %data using ~12-14 bits per sample, thus using a 32 bit float
        %(single-precision float) more then sufficient to store the data. By
        %not storing samples as a double (64 bits), the final file size is
        %reduced by ~33%, with marginal errors due to truncation (On the
        %order of 1e-6). Then further compress Channel Values using dzip
        %
        % Overall Lossless Compressiong Ratio: ~12

        channels = fieldnames(ds);
        for i = 1:length(channels)
            %Check each subfield is a channel
            if isstruct(ds.(channels{i})) && isfield(ds.(channels{i}),'Time') && ...
                    isfield(ds.(channels{i}),'Value') && isfield(ds.(channels{i}),'Units')
                
                %Compress Value Field: Convert to Single Precision
                value = single(ds.(channels{i}).Value);
                
                %Compress with dzip
                ds.(channels{i}).Value = dzip(value);
                                
                %Compress Time Field: Convert to Sample Rate
                ds.(channels{i}).SampleRate = mean(diff(ds.(channels{i}).Time));
                ds.(channels{i}).Time = rmfield(ds.(channels{i}), 'Time');
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