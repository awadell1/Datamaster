function valid = validateHash(dm, hash)
    %Validate the supplied hash is either a string of 64 chars or a cell
    %array of valid hashes
    
    valid = true;
    if iscellstr(hash)
        %Check that each hash in the cell array is valid
        i = 1;
        while i < length(hash) && valid
            valid = dm.validateHash(hash{i}) && valid;
            i = i+1;
        end
    elseif ischar(hash)
        %Valid hashes are of length 64
        if length(hash) ~= 64
            valid = false;
            return
        end

        %Valid Hashes Exist have enteries in the Master Directory
        if length(dm.mDir.fetch(sprintf(['SELECT id FROM masterDirectory ',...
            'WHERE OriginHash = ''%s'' OR FinalHash = ''%s'''],...
            hash, hash))) ~=1
            valid = false;
        end
    else
        %Not a valid input
        valid = false;
    end
end