function removeEntry(dm,varargin)
    
    %Get Enteries to remove
    [entry,index] = dm.getEntry(varargin{:});
    
    if ~isempty(entry)
        %Verify action with user
        prompt = sprintf('Are you sure you want to delete %d datasource(s)?\nThis action cannot be undone',sum(index ~= false));
        choice = questdlg(prompt,'Confirm Delete','Yes','No','No');
        
        if strcmp(choice,'Yes')
            %Delete Datasources
            for i = 1:size(entry,2)
                delete(fullfile(dm.getDatastore,[entry(i).FinalHash '.mat']));
            end
            
            %Remove Entry from directory
            dm.mDir(index) = [];
            
            %Save Directory
            dm.SaveDirectory;
        end
    end
    
    
    
    