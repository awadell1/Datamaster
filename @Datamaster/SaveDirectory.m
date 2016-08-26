function SaveDirectory(obj)
    %Overwrite the saved Master Directory with the in memory one
    
    %Get in-memory directory
    saveVars = obj.mDir;
    
    %Save in-memory directory
    fileattrib(obj.mDirLoc,'+w');   %Enable Write access
    save(obj.mDirLoc,'-struct','saveVars'); %Save
    fileattrib(obj.mDirLoc,'-w')    %Disable Write access
end