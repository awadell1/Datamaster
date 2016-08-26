function [status,OriginHash] = CheckLogFileStatus(obj,LogFileLoc)
    %Checks if a Log File has been exported, was modified or new
    
    %Compute the hash of the LogFile
    OriginHash = DataHash(LogFileLoc,obj.HashOptions);
    
    %Compare OriginHash to MasterDatabase
    OriginMatch = strcmp(OriginHash,obj.mDir.OriginHash);
    
    %Trim LogFileLoc to sub \Google Drive\
    RelPath = strfind(LogFileLoc,'\Google Drive\');
    RelPath = LogFileLoc(RelPath:end);
    
    PathMatch = strcmp(RelPath,obj.mDir.Origin);
    
    %Detirmine Status of Log File
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