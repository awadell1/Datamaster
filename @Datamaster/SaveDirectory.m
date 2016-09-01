function SaveDirectory(dm)
    %Overwrite the saved Master Directory with the in memory one
    
    %Grab Master Directory
    mDir = dm.mDir;
    
    %Save in-memory directory
    if exist(dm.mDirLoc,'file')
        fileattrib(dm.mDirLoc,'+w');   %Enable Write access
        save(dm.mDirLoc,'mDir'); %Save
        fileattrib(dm.mDirLoc,'-w')    %Disable Write access
    else
        save(dm.mDirLoc,'mDir'); %Save
    end
end