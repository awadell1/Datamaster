function addEntry(dm,Origin,OriginHash,FinalHash,Details,Parameters)
    
    %Get Index of new directory Entry
    Index = dm.numEnteries +1;
    
    %Trim Origin to \Google Drive\
    PathStart = strfind(Origin,'\Google Drive\');
    Origin = Origin(PathStart:end);
    
    dm.mDir(Index).Origin = Origin;
    dm.mDir(Index).OriginHash = OriginHash;
    dm.mDir(Index).FinalHash = FinalHash;
    dm.mDir(Index).Details = Details;
    dm.mDir(Index).Parameters = Parameters;
    
    %Update the Master Directory
    SaveDirectory(dm)
end