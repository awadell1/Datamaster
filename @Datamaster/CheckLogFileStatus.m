function status = CheckLogFileStatus(dm,item)
    %Checks if a Log File has been exported, was modified or new
    % item is structure with the following fields
    %   OriginHash: The concatenated MD5 hashes of the .ld and .ldx [ldHash ldxHash]
    %   ld: The id of the .ld file on Google Drive
    %   ldx: The ldx of the .ldx file on Google Drive
    
    % Compare OriginHash to MasterDatabase
    
    %Find Records with a matching origin hash
    query = sprintf('select id from masterDirectory where OriginHash=''%s''',item.OriginHash);
    OriginMatch = dm.mDir.fetch(query);
    
    %Find Records with matching .ld or .ldx files
    query = sprintf('select id from masterDirectory where ldId=''%s'' OR ldxId=''%s''',item.ld,item.ldx);
    PathMatch = dm.mDir.fetch(query);
    
    %% Determine Status of Log File
    if isempty(OriginMatch)
        if isempty(PathMatch)
            %New Log File
            status = 'new';
        else
            %Log File has been modified
            status = 'modified';
        end
    else
        if isempty(PathMatch)
            %Duplicate Log File
            status = 'duplicate';
        else
            %Log file has already been exported
            status = 'exported';
        end
    end
end