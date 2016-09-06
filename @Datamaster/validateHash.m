function valid = validateHash(dm, hash)
    %Validate the supplied hash is either a string of 64 chars or a cell
    %array of valid hashes
    
    valid = true;
    switch class(hash)
        case 'cell'
            %Check that each hash in the cell array is valid
            i = 1;
            while i < length(hash) && valid
                valid = validateHash(hash{i}) && valid;
                i = i+1;
            end
        case 'char'
            %Valid hashes are of length 64
            if length(hash) ~= 64
                valid = false;
            end
            
            %Valid Hashes Exist have enteries in the Master Directory
            if ~any(strcmp(hash,[{dm.mDir.OriginHash} {''}]) | strcmp(hash,[{dm.mDir.FinalHash} {''}]))
                valid = false;
            end
    end
end