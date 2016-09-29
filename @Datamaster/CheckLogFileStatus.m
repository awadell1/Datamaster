function status = CheckLogFileStatus(obj,item)
    %Checks if a Log File has been exported, was modified or new
    % item is structure with the following fields
    % OriginHash: The concated MD5 hashes of the .ld and .ldx [ldHash ldxHash]
    % ld: The id of the .ld file on Google Drive
    % ldx: The ldx of the .ldx file on Google Drive
    
    % Compare OriginHash to MasterDatabase
    OriginMatch = strcmp(item.OriginHash,{obj.mDir.OriginHash});
    
    % Compare file ids to the Master Database
    if ~isempty(obj.mDir)
        PathMatch = strcmp(item.ld,{obj.mDir.OriginLd}) || strcmp(item.ldx,{obj.mDir.OriginLdx});
    else
        PathMatch = false;
    end
    
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