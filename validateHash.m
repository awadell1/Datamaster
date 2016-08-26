function validateHash(hash)
    %Validate the supplied hash is either a string of 64 chars or a cell
    %array of valid hashes
    switch class(hash)
        case 'cell'
            %Check that each hash in the cell array is valid
            for i = 1:length(hash)
                validateHash(hash{i});
            end
        case 'char'
            %Valid hashes are of length 64
            assert(length(hash) == 64,'Invalid Hash Length');
    end
end