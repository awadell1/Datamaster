function stats = RefreshDatastore(dr)
    %Searches the ADL3 Data Folder on Google Drive for any new MoTeC Log
    %Files. New Log Files are then exported and added to the Datastore by
    %Datamaster.
    %Also records summary statistics such as number of new, modified and
    %corrupt log files currently on the Google Drive.
    %Returns a cell array containing the OriginHashes of all newly exported
    %Log Files
    
    %Create Stats to track progress
    stats = struct('New',0,'Duplicate',0,'Modified',0,'Prior',0,'Corupt',0,'NewHash','');
    
    %Assert that the host computer is a pc
    assert(ispc,'Only a pc can export MoTeC Log files')

    %Change the working directory to the datamaster folder
    cd(fileparts(which('reportGitInfo')));
    
    %Get all MoTeC Log files stored on google drive
    MoTeCFile = updateDriveInfo();
      
    %Create MoTeC COM Server
    i2 = actxserver('MoTeC.i2Application');
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
                    stats.NewHash{end+1} = FinalHash;
                else
                    stats.Corupt = stats.Corupt +1;
                end
            case 'corrupt'
                stats.Corupt = stats.Corupt +1;
                fprintf('Corrupt: %s...Skipping\n',MoTeCFile(i).OriginHash);
            case 'modified'
                stats.Modified = stats.Modified +1;
                fprintf('Modified: %s...Skipping\n',MoTeCFile(i).OriginHash);
            case 'duplicate'
                stats.Duplicate = stats.Duplicate +1;
                fprintf('Duplicate: %s...Skipping\n',MoTeCFile(i).OriginHash);
            case 'exported'
                stats.Prior = stats.Prior +1;
                fprintf('Prior Export: %s...Skipping\n',MoTeCFile(i).OriginHash);
        end
        
    end
    
    %Close i2 Pro
    i2.Exit;
       
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
    
    