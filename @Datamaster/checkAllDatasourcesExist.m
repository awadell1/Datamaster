function checkAllDatasourcesExist(dm)
    %Check all datasource listed in the directory are present
    
    %% Check that each .mat file in the datastore has an entry
    items = dir(dm.getDatastore); names = {items.name}';
    rmIndex = false(1,length(names));
    for i = 3:length(names)
        %Strip .mat from file name to get Final Hash
        [~, temp] = fileparts(names{i});
        names{i} = temp;
        
        %Check if name is a hash
        if ~validateHash(dm, names{i}) && ~strcmp(names{i},'mDir')
            %Mark for removal
            rmIndex(i) = true;
        end
    end
    
    %Remove .mat files missing from mDir
    curCD = cd; cd(dm.getDatastore);    %Save Current Dir and Switch to Datastore
    delete(items(rmIndex).name);        %Delete Files
    cd(curCD);                          %Switch back to Current Dir
    
    %% Check if each mDir entry has a datasource.mat file
    rmIndex = false(1,size(dm.mDir,2));
    for i = 1:size(dm.mDir,2)
        FileExist = any(strcmp(dm.mDir(i).FinalHash,names));
        
        if ~FileExist
            %Mark for deletion
            rmIndex(i) = true;
        end
    end
    
    %Remove enteries with missing datasources
    dm.removeEntry(dm.mDir(rmIndex).FinalHash);
end