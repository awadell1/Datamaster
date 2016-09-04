function checkAllDatasourcesExist(dm)
    %Check all datasource listed in the directory are present
    
    %Get Final Hashes of Datasource in the Datastore
    items = dir(dm.getDatastore); names = {items.name}';
    rmIndex = false(1,length(names));
    for i = 1:length(names)
        %Strip .mat from file name to get Final Hash
        [~, temp] = fileparts(names{i});
        names{i} = temp;
        
        %Check if name is a hash
        if ~validateHash(names{i})
            %Mark for removal
            rmIndex(i) = true;
        end
    end
    
    %Remove non hashes
    names(rmIndex) = [];
    
    %Check if each entry has a datasource.mat file
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