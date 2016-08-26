function Cleanup(obj)
    %Checks for and removes temporary files from the datastore directory
    
    %Get items in the Datastrore Directory
    items = dir(obj.Datastore);
    for i = 1:length(items)
        %Check if item is temporary
        if strncmp('temp',items(i).name,4)
            %Delete Tempoary files
            delete(fullfile(obj.Datastore,items(i).name));
        end
    end
end