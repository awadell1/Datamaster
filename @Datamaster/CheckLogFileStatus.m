function [status,OriginHash] = CheckLogFileStatus(obj,LogFileLoc)
    %Checks if a Log File has been exported, was modified or new
    
    %% Compare the hash to the Directory
    
    %Extract the path and file name and place into a char array
    file = regexp(LogFileLoc,'(.)+\.ld','tokens'); file = file{:}{:};
    
    %Clean up LogFileLoc
    LogFileLoc = [file '.ld'];
    
    %Check the both Log Files Exist
    if ~exist([file,'.ldx'],'file') || ~exist([file,'.ld'],'file')
        %Missing the .ld or .ldx file -> Report as corrupt
        status = 'corrupt';
    else
        
        %Compute the Hash for both the .ldx and .ld file
        ldxHash = DataHash([file,'.ldx'],obj.HashOptions);
        ldHash =  DataHash([file,'.ld'],obj.HashOptions);
        
        %Combine into a single hash
        combineOpts = obj.HashOptions; combineOpts.Input = 'array';
        OriginHash = DataHash({ldxHash,ldHash},combineOpts);
        
        %Compare OriginHash to MasterDatabase
        OriginMatch = strcmp(OriginHash,{obj.mDir.OriginHash});
        
        %% Compare Log File Location to Directory
        %Trim LogFileLoc to sub \Google Drive\
        RelPath = strfind(LogFileLoc,'\Google Drive\');
        RelPath = LogFileLoc(RelPath:end);
        
        PathMatch = strcmp(RelPath,{obj.mDir.Origin});
        
        %% Detirmine Status of Log File
        if sum(OriginMatch) <= 1 && sum(PathMatch) <= 1
            if sum(OriginMatch) == 1 && sum(PathMatch) == 1
                %Already Exported
                status = 'exported';
            elseif sum(PathMatch) == 1
                %Log File has been modified
                status = 'modified';
            elseif sum(OriginMatch) == 1
                %Log File is a duplicate
                status = 'duplicate';
            else
                status = 'new';
            end
        else
            %Database Corruption has occured -> Manual Correction will
            %be required to recover
            error('Database Corruption: Check for duplicates of: %s (%s)',RelPath,OriginHash);
        end
    end
end