function removeEntry(dm,varargin)
    
    %Get Enteries to remove
    [entry,index] = dm.getEntry(varargin{:});
    
    if ~isempty(entry)
        %Verify action with user
        prompt = sprintf('Are you sure you want to delete %d datasource(s)?\nThis action cannot be undone',sum(index));
        choice = questdlg(prompt,'Confirm Delete','Yes','No','No');
        
        if strcmp(choice,'Yes')
            %Delete Datasources
            for i = 1:length(entry.FinalHash)
                delete(fullfile(dm.getDatastore,[entry.FinalHash{i} '.mat']))
            end
            
            %Remove Entry from directory
            vars = fieldnames(dm.mDir);
            for i = 1:length(vars)
                dm.mDir.(vars{i})(index) = [];
            end
            
            %Save Directory
            dm.SaveDirectory;
        end
    end
    
    
    
    