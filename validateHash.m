function valid = validateHash(hash)
    %Validate the supplied hash is either a string of 64 chars or a cell
    %array of valid hashes
    
    switch class(hash)
        case 'cell'
            %Check that each hash in the cell array is valid
            valid = true;
            for i = 1:length(hash)
                valid = validateHash(hash{i}) && valid;
            end
        case 'char'
            %Valid hashes are of length 64
            if length(hash) ~= 64
                valid = false;
            else
                valid = true;
            end
    end
end