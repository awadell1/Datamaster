function addEntry(obj,Origin,OriginHash,FinalHash,Details,Parameters)
    
    %Get Index of new directory Entry
    Index = length(obj.mDir.Origin)+1;
    
    %Trim Origin to \Google Drive\
    PathStart = strfind(Origin,'\Google Drive\');
    Origin = Origin(PathStart:end);
    
    obj.mDir.Origin{Index} = Origin;
    obj.mDir.OriginHash{Index} = OriginHash;
    obj.mDir.FinalHash{Index} = FinalHash;
    obj.mDir.Details{Index} = Details;
    obj.mDir.Parameters{Index} = Parameters;
    
    %Update the Master Directory
    SaveDirectory(obj)
end