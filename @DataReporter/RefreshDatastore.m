function stats = RefreshDatastore(dr)
    %Searches the ADL3 Data Folder on Google Drive for any new MoTeC Log
    %Files. New Log Files are then exported and added to the Datastore by
    %Datamaster.
    %Also records summary satistics such as number of new, modified and
    %corrupt log files currently on the Google Drive.
    %Returns a cell array containg the OriginHashes of all newly exported
    %Log Files
    
    
    %Assert that the host computer is a pc
    assert(ispc,'Only a pc can export MoTeC Log files')
    
    %Get all MoTeC Log files stored on google drive
    MoTeCFile = updateDriveInfo();
    
    %% FOR TESTING ONLY -> LIMIT SIZE OF DATASTORE %%
    MoTeCFile = MoTeCFile(1:20);
    %% FOR TESTING ONLY -> LIMIT SIZE OF DATASTORE %%
    
    %Create MoTeC COM Server
    i2 = actxserver('MoTeC.i2Application');
    i2.Visible = 1;
    pause(1);   %Wait for MoTeC to Open
    
    %Pull Datamaster handle from DataReporter
    dm = dr.dm;
    
    %Set Up Console
    startTime = tic;
    fprintf('\nSearching for New MoTeC Log Files...\n');
    
    %Loop over all log files
    for i = 1:length(MoTeCFile)
        %Check if file as already been exported
        switch dm.CheckLogFileStatus(MoTeCFile(i))
            case 'new'
                %New Data source -> Export
                [success, FinalHash] = DataReporter.ExportDatasource(dm, i2, MoTeCFile(i));
                
                %Check if export was successful
                if success
                    stats.New = stats.New +1;
                    stats.NewHash = [stats.NewHash FinalHash];
                else
                    stats.Corupt = stats.Corupt +1;
                end
            case 'corrupt'
                stats.Corupt = stats.Corupt +1;
                fprintf('Corrupt: .%s...Skipping\n',item(i).name);
            case 'modified'
                stats.Modified = stats.Modified +1;
                fprintf('Modified: .%s...Skipping\n',item(i).name);
            case 'duplicate'
                stats.Duplicate = stats.Duplicate +1;
                fprintf('Duplicate: .%s...Skipping\n',item(i).name);
            case 'exported'
                stats.Prior = stats.Prior +1;
                fprintf('Prior Export: .%s...Skipping\n',item(i).name);
        end
        
    end
    
    % Start Search
    stats = DataReporter.RecursivelyOpen(s);
    
    %Clean up Datastore
    s.Datamaster.Cleanup
    
    %Report Duration
    fprintf('\n\nDatabase Refresh Complete\n');
    
    %Report Export Stats
    vars = fieldnames(stats);
    for i = 1:length(vars)
        switch class(stats.(vars{i}))
            case 'double'
                fprintf('%s Log Files: %.1d\n',vars{i},stats.(vars{i}));
            case 'cell'
                fprintf('Newly Exported Log Files:\n')
                
                temp = stats.(vars{i});
                fprintf('\t%s\n',temp{:});
        end
    end
    fprintf('\n')
    toc(startTime);
    
    %Get Git Version and report
    reportGitInfo;
